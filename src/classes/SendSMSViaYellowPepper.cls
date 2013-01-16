public class SendSMSViaYellowPepper implements SendViaSMSGateway {

    /**
     * Send SMS through the Yellow Pepper gateway.
     * YellowPeppe offer two services:
     *    metroLine for single messages
     *    metroBroadcast for multiple messages
     *
     * This class requires a SMS_Gateway_Settings__c custom setting to be created that is called YellowPepper.
     * This setting contains the endpoints for the two services and the login credentials
     *
     */

    // Custom setting that stores the configuration for the YP gateway
    private static SMS_Gateway_Settings__c setting;

    /**
     * Takes a list of Message objects and sends them one by one to the single or bulk endpoint depending on the number of recipients
     *
     * @param inputMessages - A list of Message objects that describe the messages being sent out
     *
     * @ return - A string that indicates which messages were successful. This string can then be processed by the callback to indicate rescheduling
     */
    public String execute(List<Message> inputMessages) {

        // Get the settings for the gateway
        loadSetting();

        YellowPepperResults results = new YellowPepperResults();

        // Loop through the messages
        for (Message message : inputMessages) {

            // Send each message via HTTP Post using metroBroadcast if more than one recipient
            // Metroline if just one guy getting it
            Boolean singleMessage = false;
            if (message.recipients.size() == 1) {
                singleMessage = true;
            }
            HttpRequest request = buildRequest(createBody(new List<Message>{ message }, singleMessage), singleMessage);
            HttpResponse response = sendRequest(request);

            // Parse the response
            Boolean success = false;
            if (checkSuccess(parseResponse(response.getBody()))) {
                success = true;
            }

            // Go throught recipients of the message and indicate if they got the message
            String messageHash = message.getMessageHash();
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                results.yellowPepperResponse.add(new YellowPepperResult(messageHash, recipient.personId, success));
            }
        }

        // Return json String of YellowPepperResults. This can then be passed into the callback if needed
        return JSON.serialize(results);
    }

    /**
     * The inputMessage list should be singleton as YP API doesn't allow for different messages to be sent
     * in one go
     */
    public String createBody(List<Message> inputMessages, Boolean single) {

        // Check the length of the message list and throw error if needed
        if (inputMessages.size() > 1) {
            throw new SendSMSHelpers.SendMessageException('Can only send one message through YP at once');
        }

        String body =
            'op=sendBroadcastMessage' + 
            '&Serial=' + EncodingUtil.urlEncode(setting.Username__c, 'UTF-8') +
            '&Pin=' + setting.Password__c +
            '&Message=' + EncodingUtil.urlEncode(inputMessages[0].body, 'UTF-8') +
            '&Mobile';
        if (single) {
            body += '=' + EncodingUtil.urlEncode(String.valueOf(inputMessages[0].recipients.values()[0].countryDialingCode), 'UTF-8') + EncodingUtil.urlEncode(inputMessages[0].recipients.values()[0].phoneNumber, 'UTF-8');
        }
        else {
            body +='s=';
            for (SendSMSHelpers.Recipient recipient : inputMessages[0].recipients.values()) {
                if (recipient.countryDialingCode == null) {
                    continue;
                }
                body += EncodingUtil.urlEncode(String.valueOf(recipient.countryDialingCode), 'UTF-8') + EncodingUtil.urlEncode(recipient.phoneNumber, 'UTF-8') + ';';
            }

            // Take of the last ;
            body = body.substring(0, body.length() - 1);
        }
        body += '&Sender=' + EncodingUtil.urlEncode(String.valueOf(inputMessages[0].senderName), 'UTF-8');
        return body;
    }

    /**
     * Build the request that will be sent to the YP gateway
     * Request is sent using HTTP POST
     *
     * @param body   - The body of the message that is to be sent to the Gateway
     * @param single - Boolean indicating if the message is being sent to single recipient
     *
     * @return - THe HttpRequest that is to be sent to YP
     */
    public HttpRequest buildRequest(String body, Boolean single) {

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setBodyAsBlob(Blob.valueOf(body));
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Length', String.valueOf(body.length()));

        // Get the endpoint for the request. Will be different if a single message or multiple messages are being sent
        if (single) {
            request.setEndpoint(setting.Single_Endpoint__c);
        }
        else {
            request.setEndpoint(setting.Bulk_End_Point__c);
        }
        return request;
    }

    /**
     * Send the request. This is refactored out to here so code can be tested as callouts are not allowed in tests
     *
     * @param request - The HttpRequest object that is to be sent
     *
     * @return - The HttpResponse 
     */
    public HttpResponse sendRequest(HttpRequest request) {

        // Send the request
        Http http = new Http();
        return http.send(request);
    }

    /**
     * Implimentation of the callback method for the interface
     */
    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {

        if (resultMap == null) {
            resultMap = new Map<String, Boolean>();
        }
        YellowPepperResults responses = (YellowPepperResults)JSON.deserialize(results, YellowPepperResults.class);
        for (YellowPepperResult response : responses.yellowPepperResponse) {
            String key = response.personId + '_splitter_' + response.messageHash;
            resultMap.put(key, response.success);
        }
        return resultMap;
    }

    /**
     * Dig out the response code. This would be the error code or a 16 digit alphanumeric code to uniquely id the message in the YP system
     *
     * @param response - The XML that was returned from the callout
     *                       format is:
     *                           <?xml version="1.0" encoding="utf-8"?>
     *                           <string xmlns="http://yellowpepper.com/webservices/literalTypes">responseString</string>
     *
     * @return - The response code
     */
    private String parseResponse(String response) {

        DOM.Document doc = new DOM.Document();
        try {
            doc.load(response);
            DOM.XMLNode root = doc.getRootElement();
            if (root.getNodeType() == DOM.XMLNodeType.ELEMENT && root.getName().equals('string')) {
                return root.getText().trim();
            }
            else {
                System.debug(LoggingLevel.INFO, 'YP have changed their response format. Find out what is going on!');
                return '-1';
            }
        }
        catch (System.XMLException e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            return '-1';
        }
    }

    // Map to translate the YP error codes into a human readable message
    private Map<String, String> errorCodeMessage = new Map<String, String> {
        '9989' => 'Invalid Authentication provided for Yellow Pepper Gateway',
        '9969' => 'Invalid parameter sent to Yellow Pepper Gateway',
        '9949' => 'SMS Limit exceeded',
        '9939' => 'Invalid short code',
        '9999' => 'Unauthorized service'
    };

    /**
     * Indicates if the response was successful and if not will log the error message
     * Successful messages return a 16 character string
     *
     * @param code - The message string returned by YP
     *
     * @return - Boolean indicating if the message was successfully sent
     */
    private Boolean checkSuccess(String code) {

        if (!errorCodeMessage.containsKey(code) && code.length() == 16) {
            return true;
        }
        System.debug(LoggingLevel.INFO, errorCodeMessage.get(code));
        return false;
    }

    /**
     * Load the custom setting for the Yellow Pepper gateway.
     * The custom setting must be set up otherwise this gateway will not work
     */
   public void loadSetting() {
        setting = SMS_Gateway_Settings__c.getInstance('YellowPepper');
    }

    /**
     * Private classs that represents a list of the results from a call to the Yellow Pepper gateway
     * It is used to make JSON serialization easier
     */
    private class YellowPepperResults {
        List<YellowPepperResult> yellowPepperResponse;

        public YellowPepperResults() {
            this.yellowPepperResponse = new List<YellowPepperResult>();
        }
    }

    /**
     * Private class for the result to an individual recipient
     * It is used to make JSON serialization easier
     */
    private class YellowPepperResult {
        String messageHash;
        String personId;
        Boolean success;

        public YellowPepperResult (String messageHash, String personId, Boolean success) {
            this.messageHash = messageHash;
            this.personId = personId;
            this.success = success;
        }
    }
}