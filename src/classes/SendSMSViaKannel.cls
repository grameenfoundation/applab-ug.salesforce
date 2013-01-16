public class SendSMSViaKannel implements SendViaSMSGateway {

    /**
     * Send out SMS via Kannel. Messages to Kannel are sent via the middle tier.
     * Implements the SendViaSMSGateway interface
     */
    public String execute(List<Message> inputMessages) {

        Boolean single = inputMessages.size() == 1 && inputMessages[0].recipients.size() == 1;
        String output = '';

        // If this is not a test then send the call out
        if (Test.isRunningTest()) {
            output = getTestKannelResponse(inputMessages);
        }
        else {
            HttpResponse response = sendRequest(buildRequest(createBody(inputMessages, single), single));
            if (response.getStatusCode() != 202) {

                // The whole thing has failed so pass back an error string
                System.debug(LoggingLevel.INFO, 'Failed to send SMS through Kannel');
                output = createFullFailureString(inputMessages);
            }
            else {
                output = response.getBody();
                if (output == null || output.equals('')) {
                    System.debug(LoggingLevel.INFO, 'Response from gateway is blank');
                    output = createFullFailureString(inputMessages);
                }
            }
        }
        System.debug(LoggingLevel.INFO, output);
        return output;
    }

    public String createBody(List<Message> inputMessages, Boolean single) {

        KannelMessages kannelMessages = new KannelMessages();
        for (Message message : inputMessages) {

            // Create the Kannel Message. This is its own object for ease of JSON serialising
            KannelMessage kannelMessage = new KannelMessage(message.body, message.senderName);

            // Add the recipients
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                kannelMessage.addKannelRecipient(
                    recipient.personId,
                    recipient.phoneNumber,
                    String.valueOf(recipient.countryDialingCode)
                );
            }
            kannelMessages.addMessage(kannelMessage);
        }

        // Generate the JSON String to send to the middle tier
        return JSON.serialize(kannelMessages);
    }

    public HttpRequest buildRequest(String body, Boolean single) {

        // Get Kannel configuration
        SMS_Gateway_Settings__c settings = SMS_Gateway_Settings__c.getInstance('Kannel');

        // Create the http request
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        String endpoint = settings.Bulk_End_Point__c;
        if (single) {
            endpoint = settings.Single_Endpoint__c;
        }
        request.setEndpoint(endpoint);
        return request;
    }

    public HttpResponse sendRequest(HttpRequest request) {

        // Send the request
        Http http = new Http();
        return http.send(request);
    }

    // Key to the map is personId_splitter_messageHash
    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {

        if (resultMap == null) {
            resultMap = new Map<String, Boolean>();
        }
        KannelResponse responses = (KannelResponse)JSON.deserialize(results, KannelResponse.class);
        List<Id> successfullRecipients = new List<Id>();
        for (KannelResponseLine response : responses.kannelResponse) {
            String key = response.personId + '_splitter_' + response.messageHash;
            Boolean success = false;
            if (response.statusCode.equals('202')) {
                success = true;
                successfullRecipients.add(response.personId);
            }
            resultMap.put(key, success);
        }

        // Check the sms interactions metric
        return resultMap;
    }

    /**
     * Create a fake response string that indicates complete failure of the kannel gateway.
     * This will allow us to reschedule all the kannel messages for resend
     */
    public String createFullFailureString(List<Message> inputMessages) {

        String output = '';
        KannelResponse response = new KannelResponse(new List<KannelResponseLine>());
        for (Message message : inputMessages) {
            String messageHash = message.getMessageHash();
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                response.kannelResponse.add(
                    new KannelResponseLine(messageHash, recipient.personId, '400', 'Gateway Failure', recipient.phoneNumber)
                );
            }
        }
        return JSON.serialize(response);
    }

    // HELPER METHODS USED FOR TESTING
    private String getTestKannelResponse(List<Message> inputMessages) {

        String output = '';
        KannelResponse response = new KannelResponse(new List<KannelResponseLine>());
        for (Message message : inputMessages) {
            String messageHash = message.getMessageHash();
            for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
                response.kannelResponse.add(
                    new KannelResponseLine(messageHash, recipient.personId, '202', 'Gateway Failure', recipient.phoneNumber)
                );
            }
        }
        return JSON.serialize(response);
    }

    /**
     * Private class to represent a list of Kannel messages used for JSON serialisation.
     */
    private class KannelMessages {
        List<KannelMessage> messages;

        public KannelMessages() {
            this.messages = new List<KannelMessage>();
        }
        public void addMessage(KannelMessage message) {
            this.messages.add(message);
        }
    }

    /**
     * Private class that represents a Kannel message. This class allows for easy JSON serialisation
     * Is needed as kannel requires different details than other gateways so the SendSMSHelpers.Recipient
     * class would be too bloated
     */
    private class KannelMessage {
        String message;
        String messageHash;
        String sender;
        List<KannelRecipient> recipients;

        public KannelMessage(String message, String sender) {
            this.message = message;
            this.messageHash = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(message)));
            this.sender = sender;
            this.recipients = new List<KannelRecipient>();
        }
        public void addKannelRecipient(String personId, String phoneNumber, String countryCode) {
            this.recipients.add(
                new KannelRecipient(
                    personId,
                    phoneNumber,
                    countryCode
                )
            );
        }
    }

    private class KannelRecipient {
        String personId;
        String phoneNumber;
        String countryCode;

        public KannelRecipient(String personId, String phoneNumber, String countryCode) {
            this.personId = personId;
            this.phoneNumber = phoneNumber;
            this.countryCode = countryCode;
        }
        public String getId() {
            return this.personId;
        }
    }

    private class KannelResponse {
        List<KannelResponseLine> kannelResponse;
        public KannelResponse(List<KannelResponseLine> KannelResponse) {
            this.KannelResponse = KannelResponse;
        }
    }

    private class KannelResponseLine {
        String messageHash;
        String personId;
        String statusCode;
        String response;
        String phoneNumber;

        public KannelResponseLine(String messageHash, String personId, String statusCode, String response, String phoneNumber) {
            this.messageHash = messageHash;
            this.personId = personId;
            this.statusCode = statusCode;
            this.response = response;
            this.phoneNumber = phoneNumber;
        }
    }
}