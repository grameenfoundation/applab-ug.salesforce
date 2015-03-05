global class SendSMS implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    /**
     * Batch class that sends scheduled messages to the required gateway. Will bulk the messages within an individual batch
     * The batch can only be of size 10 as it could be possible that each message goes to a different gateway so a limit of 10
     * stops the callout limit coming into play
     */
    global final String query;
    global final DateTime startTime;
    global static final String pulse = 'PULSE';

    // Key of first map is the country code. Key of second map is the message in a MD5 hash
    global final Map<String, Map<String, Message>> messages;

    // Recipient Map for messages sent to individuals. Key is the recipient's Person__c.Id
    global Map<Id, SendSMSHelpers.Recipient> recipientMap;
    global Map<String, Map<String, List<SendSMSHelpers.Recipient>>> groupMap;

    // A list of all the Scheduled Messages that have been processed by this batch
    global Map<String, Scheduled_Message_Queue__c> inputMessageMap;

    // A map of the results from the various gateways
    global Map<String, Boolean> resultMap;

    global SendSMS (String baseQuery, DateTime startTime) {
        query = baseQuery;
        messages = new Map<String, Map<String, Message>>();
        recipientMap = new Map<Id, SendSMSHelpers.Recipient>();
        inputMessageMap = new Map<String, Scheduled_Message_Queue__c>();
        resultMap = new Map<String, Boolean>();
        startTime = DateTime.now();
        groupMap = new Map<String, Map<String, List<SendSMSHelpers.Recipient>>>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Scheduled_Message_Queue__c> inputMessages) {

        for (Scheduled_Message_Queue__c message : inputMessages) {

            // Hash the message text so it can be used as a key to a map
            String messageHash = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(message.Message__c)));

            // Message is for a group
            if (message.Group__c != null) {

                // See if that group has already been expanded
                if (!groupMap.containsKey(message.Group__c)) {

                    // Expand the group
                    groupMap.put(message.Group__c, SendSMSHelpers.expandGroupMembership(message.Group__c));
                }

                // Create a Message object for each country that is in the group if sending that way
                for (String countryCode : groupMap.get(message.Group__c).keySet()) {

                    // Init the message map if needed
                    if (message.Send_Via_SMS__c && messages.get(countryCode) == null) {
                        messages.put(countryCode, new Map<String, Message>());
                    }

                    // Send message via sms if needed
                    Message messageToSend;
                    if (message.Send_Via_SMS__c) {
                        if (messages.get(countryCode) == null) {
                            messages.put(countryCode, new Map<String, Message>());
                        }
                        messageToSend = messages.get(countryCode).get(messageHash);
                        if (messageToSend == null) {
                            messageToSend = new Message(message.Subject__c, message.Message__c, message.Sender__c, message.Sender__r.Name, message.Expiration_Date__c, message.Send_Date_Time__c, 'SMS');
                        }
                    	messageToSend.catgory = message.Category__c;
                    }

                    // Send message via pulse as well if needed
                    Message pulseMessage;
                    if (message.Send_Via_Pulse__c) {
                        if (messages.get(pulse) == null) {
                            messages.put(pulse, new Map<String, Message>());
                        }
                        pulseMessage = messages.get(pulse).get(messageHash);
                        if (pulseMessage == null) {
                            pulseMessage = new Message(message.Subject__c, message.Message__c, message.Sender__c, message.Sender__r.Name, message.Expiration_Date__c, message.Send_Date_Time__c, pulse);
                        }
                    	pulseMessage.catgory = message.Category__c;
                    }
                    for (SendSMSHelpers.Recipient recipient : groupMap.get(message.Group__c).get(countryCode)) {
                        recipient.addMessage(message);
                        if (messageToSend != null) {
                            messageToSend.addRecipient(recipient);
                        }
                        if (pulseMessage!= null) {
                            pulseMessage.addRecipient(recipient);
                        }
                    }
                    if (message.Send_Via_SMS__c) {
                        messages.get(countryCode).put(messageHash, messageToSend);
                    }
                    if (message.Send_Via_Pulse__c) {
                        messages.get(pulse).put(messageHash, pulseMessage);
                    }
                }
            }

            // Message is for a person
            if (message.Person__c != null) {

                inputMessageMap.put(message.Person__c + messageHash, message);

                // Get the recipient ADD Mulitple messages if the recipient is getting more than one
                SendSMSHelpers.Recipient recipient = recipientMap.get(message.Person__c);
                if (recipient == null) {
                    recipient = SendSMSHelpers.generateRecipient(
                        message.Person__c,
                        message.Person__r.First_Name__c,
                        message.Person__r.Middle_Name__c,
                        message.Person__r.Last_Name__c,
                        message.Person__r.Mobile_Number__c,
                        message.Person__r.Country__r.ISO_Standard_Code__c,
                        message
                    );
                    recipientMap.put(message.Person__c, recipient);
                }
                else {
                    recipient.addMessage(message);
                }
                if (message.Send_Via_SMS__c) {

                    // Init the message map if needed
                    if (messages.get(recipient.countryCode) == null) {
                        messages.put(recipient.countryCode, new Map<String, Message>());
                    }
                    Message messageToSend = messages.get(recipient.countryCode).get(messageHash);
                    if (messageToSend == null) {
                        messageToSend = new Message(message.Subject__c, message.Message__c, message.Sender__c, message.Sender__r.Name, message.Expiration_Date__c, message.Send_Date_Time__c, 'SMS');
                    }
                    messageToSend.catgory = message.Category__c;
                    messageToSend.addRecipient(recipient);
                    messages.get(recipient.countryCode).put(messageHash, messageToSend);
                }
                if (message.Send_Via_Pulse__c) {

                    // Init the message map if needed
                    if (messages.get(pulse) == null) {
                        messages.put(pulse, new Map<String, Message>());
                    }
                    Message messageToSend = messages.get(pulse).get(messageHash);
                    if (messageToSend == null) {
                        messageToSend = new Message(message.Subject__c, message.Message__c, message.Sender__c, message.Sender__r.Name, message.Expiration_Date__c, message.Send_Date_Time__c, pulse);
                    }
                    messageToSend.catgory = message.Category__c;
                    messageToSend.addRecipient(recipient);
                    messages.get(pulse).put(messageHash, messageToSend);
                }
            }
        }

        // Go through the created messages and send to the correct gateway
        SendSmsHelpers.sendThroughGateways(messages, true);
    }

    global void finish(Database.BatchableContext BC) {

        // Delete all the scheduled messages that have been sent out
        Database.delete([SELECT Id FROM Scheduled_Message_Queue__c WHERE LastModifiedDate < :startTime]);
    }
}