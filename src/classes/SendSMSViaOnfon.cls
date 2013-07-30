public with sharing class SendSMSViaOnfon implements SendViaSMSGateway {

    /**
     * Send SMS through the Onfon gateway.
     *
     * This class requires a SMS_Gateway_Settings__c custom setting to be created that is called Onfon
     * This setting contains the endpoints for the two services and the login credentials
     *
     */

    // Custom setting that stores the configuration for the Infobip gateway
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

        OnfonResults results = new OnfonResults();

        Boolean success = true;
        String responseBody = '';
        // Loop through the messages
        for (Message message : inputMessages) {

            // Send each message via HTTP Post using metroBroadcast if more than one recipient
            Boolean singleMessage = false;
            if (message.recipients.size() == 1) {
                singleMessage = true;
            }
            HttpRequest request = buildRequest(createBody(new List<Message>{ message }, singleMessage), singleMessage);

            // If this is not a test then send the call out
            if (Test.isRunningTest()) {
                responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
                    '<results>' +
                        '<result>' +
                        '<status>0</status>' +
                        '<messageid>092052214394830334</messageid>' +
                        '<destination>385951111111</destination>' +
                        '</result>' +
                    '</results>';
            }
            else {
                HttpResponse response = sendRequest(request);
                responseBody = response.getBody();
                if (response.getStatusCode() != 200) {
                    success = false;
                }
            }

            if (!success) {

                // The whole thing has failed so pass back an error string
                System.debug(LoggingLevel.WARN, 'Failed to send SMS through Onfon');
                responseBody = createFullFailureString(inputMessages);
            }
            else {
                if (responseBody == null || responseBody.equals('')) {
                    System.debug(LoggingLevel.WARN, 'Response from gateway is blank');
                    responseBody = createFullFailureString(inputMessages);
                }
            }
            
                    
            // Go throught recipients of the message and indicate if they got the message
            String messageHash = message.getMessageHash();
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                results.onfonResponse.add(new OnfonResult(messageHash, recipient.personId, success));
            }
        }
        System.debug(LoggingLevel.WARN, responseBody);

        return responseBody;
    }

    /**
     * The inputMessage list should be singleton as Onfon API doesn't allow for different messages to be sent
     * in one go
     */
    public String createBody(List<Message> inputMessages, Boolean single) {
    
        Map<String, String> messagesToSend = new Map<String, String>();

        // Check the length of the message list and throw error if needed
        if (inputMessages.size() > 1) {
            throw new SendSMSHelpers.SendMessageException('Can only send one message through Onfon at once');
        }
        
        //String body = 'key=' + EncodingUtil.urlEncode(setting.Password__c, 'UTF-8');
        String body = 'key=' + setting.Password__c;
        if (single) {
            messagesToSend.put('phone', inputMessages[0].recipients.values()[0].phoneNumber);
            messagesToSend.put('message',  EncodingUtil.urlEncode(inputMessages[0].body, 'UTF-8'));
            messagesToSend.put('unique_id',  EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(inputMessages[0].body + inputMessages[0].recipients.values()[0].phoneNumber))));
        }
        else {
            for (SendSMSHelpers.Recipient recipient : inputMessages[0].recipients.values()) {
                if (recipient.countryDialingCode == null) {
                    continue;
                }
                messagesToSend.put('phone', recipient.phoneNumber);
                messagesToSend.put('message',  EncodingUtil.urlEncode(inputMessages[0].body, 'UTF-8'));
                messagesToSend.put('unique_id',  EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(inputMessages[0].body + recipient.phoneNumber))));
            }
        }
        String query = JSON.serialize(messagesToSend);
        system.debug(LoggingLevel.WARN, query);
        body += '&query=[' + query + ']';
//        body += '&query=' + EncodingUtil.urlEncode(query, 'UTF-8');
        system.debug(LoggingLevel.WARN, body);
        return body;
    }

    /**
     * Build the request that will be sent to the gateway
     * Request is sent using HTTP POST
     *
     * @param body   - The body of the message that is to be sent to the Gateway
     * @param single - Boolean indicating if the message is being sent to single recipient
     *
     * @return - THe HttpRequest that is to be sent to the gateway
     */
    public HttpRequest buildRequest(String body, Boolean single) {

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setBodyAsBlob(Blob.valueOf(body));
        //request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept:', '*/*');
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
     * Implementation of the callback method for the interface
     */
    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {

        if (resultMap == null) {
            resultMap = new Map<String, Boolean>();
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
                System.debug(LoggingLevel.WARN, 'YP have changed their response format. Find out what is going on!');
                return '-1';
            }
        }
        catch (System.XMLException e) {
            System.debug(LoggingLevel.WARN, e.getMessage());
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
        System.debug(LoggingLevel.WARN, errorCodeMessage.get(code));
        return false;
    }

    /**
     * Load the custom setting for the Infobip gateway.
     * The custom setting must be set up otherwise this gateway will not work
     */
   public void loadSetting() {
        setting = SMS_Gateway_Settings__c.getInstance('Onfon');
    }

    /**
     * Private class that represents a list of the results from a call to the Infobip gateway
     * It is used to make XML serialization easier
     */
    private class OnfonResults {
        List<OnfonResult> onfonResponse;

        public OnfonResults() {
            this.onfonResponse = new List<OnfonResult>();
        }
    }

    /**
     * Private class for the result to an individual recipient
     * It is used to make JSON serialization easier
     */
    private class OnfonResult {
        String messageHash;
        String personId;
        Boolean success;

        public OnfonResult (String messageHash, String personId, Boolean success) {
            this.messageHash = messageHash;
            this.personId = personId;
            this.success = success;
        }
    }
    
        /**
     * Create a fake response string that indicates complete failure of the kannel gateway.
     * This will allow us to reschedule all the kannel messages for resend
     */
    public String createFullFailureString(List<Message> inputMessages) {

        String output = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<results>';
        for (Message message : inputMessages) {
            String messageHash = message.getMessageHash();
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                                
                        output += '<result>' +
                        '<status>0</status>' +
                        '<messageid>092052214394830334</messageid>' +
                        '<destination>385951111111</destination>' +
                        '</result>';
            }
        }
        output += '</results>';

        return output;
    }
}