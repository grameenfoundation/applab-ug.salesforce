public class SendMessageViaPulse implements SendViaSMSGateway {

    /**
     * Send a message via pulse.
     */

    public String execute(List<Message> inputMessages) {

        String output = '';
        List<Message__c> messages = new List<Message__c>();
        for (Message inputMessage : inputMessages) {
            for (SendSMSHelpers.Recipient recipient : inputMessage.recipients.values()) {
                messages.add(new Message__c(
                    Body__c = inputMessage.body,
                    Recipient__c = recipient.personId,
                    Subject__c = inputMessage.subject,
                    From__c = inputMessage.senderId,
                    Expiration_Time__c = inputMessage.expirationTime,
                    Sent_Time__c = inputMessage.sentTime,
                    Category__c = inputMessage.catgory
                ));
                output += recipient.personId + '_splitter_' + inputMessage.getMessageHash() + ',';
            }
        }

        // May have to move this inside the outer for loop if groups get very very large
        try {
            insert messages;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            return 'FAIL,' + output;
        }
        return 'SUCCESS,' + output;
    }

    // Not needed as no callout is made to save pulse messages
    public String createBody(List<Message> inputMessages, Boolean single) {
        return '';
    }
    public HttpRequest buildRequest(String body, Boolean single) {
        return null;
    }
    public HttpResponse sendRequest(HttpRequest request) {
        return null;
    }

    // Callback implementation
    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {

        if (resultMap == null) {
            resultMap = new Map<String, Boolean>();
        }
        List<String> idList = results.split(',');
        Boolean success = true;
        if (idList.size() == 1 || idList[0].equals('FAIL')) {
            success = false;
        }

        idList.remove(0);
        for (String key : idList) {
            resultMap.put(key, success);
        }
        return resultMap;
    }
}