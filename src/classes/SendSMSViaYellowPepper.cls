public class SendSMSViaYellowPepper implements SendViaSMSGateway {

    private static SMS_Gateway_Settings__c setting;

    public String execute(List<Message> inputMessages) {
        String output = '';

        // Get the settings for the gateway
        loadSetting();

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
            

            // Go throught recipients of the message and indicate if they got the message
            output += response.getBody();
        }

        // Return json String of YellowPepperResults. This can then be passed into the callback if needed
        return output;
    }

    /**
     * The inputMessage list should be singleton as YP API doesn't allow for different messages to be sent
     * in one go
     */
    public String createBody(List<Message> inputMessages, Boolean single) {

        // Check the length of the message list and throw error if needed
//'&Pin=' + EncodingUtil.urlEncode(setting.Password__c, 'UTF-8') +
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

            // Take of the last ,
            body = body.substring(0, body.length() - 1);
        }
        body += '&Sender=45678';
System.debug(LoggingLevel.INFO, body);
        return body;
    }

    public HttpRequest buildRequest(String body, Boolean single) {

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setBodyAsBlob(Blob.valueOf(body));
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        if (single) {
            request.setEndpoint(setting.Single_Endpoint__c);
        }
        else {
            request.setEndpoint(setting.Bulk_End_Point__c);
        }
System.debug(LoggingLevel.INFO, request.toString());
        return request;
    }

    public HttpResponse sendRequest(HttpRequest request) {

        // Send the request
        Http http = new Http();
        return http.send(request);
    }

    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {

        return resultMap;
    }

    public void loadSetting() {
        setting = SMS_Gateway_Settings__c.getInstance('YellowPepper');
    }

    private class YellowPepperResult {

        String messageHash;
        String personId;
        Boolean success;
    }
}