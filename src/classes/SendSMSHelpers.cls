/**
 * Helper class for sending SMS messages.
 * Has methods used by the sendSMS Bulk class as well as the individual SMSGateway classes
 */
public class SendSMSHelpers {

    // Exception class for sending messages
    public class SendMessageException extends Exception {}

    public static final String pulse = 'PULSE';

    /**
     * Expands a group by splitting all the members by country and adding their details
     *
     * @param groupId - The id of the group that is being expanded
     *
     * @return - A Map for that group and their details where the key for each map is a country code
     */
    public static Map<String, List<SendSMSHelpers.Recipient>> expandGroupMembership(Id groupId) {

        Map<String, List<SendSMSHelpers.Recipient>> recipientMap = new Map<String, List<SendSMSHelpers.Recipient>>();

        // Create a set of phone numbers so that the same phone number is not added more than once
        Set<String> phoneNumberSet = new Set<String>();
        for (Person_Group_Association__c[] pgas : [
                SELECT
                    Person__c,
                    Person__r.Last_Name__c,
                    Person__r.Middle_Name__c,
                    Person__r.First_Name__c,
                    Person__r.Country__r.ISO_Standard_Code__c,
                    Person__r.Mobile_Number__c
                FROM
                    Person_Group_Association__c
                WHERE
                    Group__c = :groupId
        ]) {
            for (Person_Group_Association__c pga : pgas) {
                if (pga.Person__r.Mobile_Number__c == null || !phoneNumberSet.add(pga.Person__r.Mobile_Number__c)) {
                    continue;
                }
                String countryCode = pga.Person__r.Country__r.ISO_Standard_Code__c;
                if (countryCode == null) {
                    countryCode = 'UG';
                }
                if (recipientMap.containsKey(countryCode)) {
                    recipientMap.get(countryCode).add(
                        SendSMSHelpers.generateRecipient(
                            pga.Person__c,
                            pga.Person__r.First_Name__c,
                            pga.Person__r.Middle_Name__c,
                            pga.Person__r.Last_Name__c,
                            pga.Person__r.Mobile_Number__c,
                            pga.Person__r.Country__r.ISO_Standard_Code__c,
                            null
                        )
                    );
                }
                else {
                    recipientMap.put(countryCode, new List<SendSMSHelpers.Recipient>{
                        SendSMSHelpers.generateRecipient(
                            pga.Person__c,
                            pga.Person__r.First_Name__c,
                            pga.Person__r.Middle_Name__c,
                            pga.Person__r.Last_Name__c,
                            pga.Person__r.Mobile_Number__c,
                            pga.Person__r.Country__r.ISO_Standard_Code__c,
                            null
                        )
                    });
                }
            }
        }
        return recipientMap;
    }

    /**
     * Get the ids of all the members of a group
     *
     * @param groupId - The Id of the group
     *
     * @return - A list of the Ids for the members of that group
     */
    public static List<Id> getGroupMemberIds(List<Id> groupId) {
        Person_Group_Association__c[] pgas = [SELECT Person__c FROM Person_Group_Association__c WHERE Group__c IN :groupId];
        List<Id> returnlist = new List<Id>();
        for (Person_Group_Association__c pga : pgas) {
            returnList.add(pga.Person__c);
        }
        return returnList;
    }

    /**
     * Generate a message that can be sent through various gateways in one go. Used when send a message
     * immediately
     *
     * @param recipients     - A list of Person__c.Id for the people who are to be sent messages
     * @param subject        - The subject of the message
     * @param messageText    - The text of the message
     * @param senderId       - The User.Id of the User who sent the message
     * @param senderName     - The User.Name of the User who sent the message
     * @param sendViaPulse   - Boolean indicating if the message is to be sent via pulse
     * @param sendViaSms     - Boolean indicating if the message is to be sent via sms
     * @param sendTime       - The time that the message should be sent
     * @param expirationTime - The time that the message stops showing in pulse
     *
     * @return - A map where the key is the country code and the values are messages
     */
    public static Map<String, Map<String, Message>> generateMessage(
            List<Id> recipients,
            String subject,
            String messageText,
            Id senderId,
            String senderName,
            Boolean sendViaPulse,
            Boolean sendViaSms,
            DateTime sendTime,
            DateTime expirationTime
    ) {

        Map<String, Map<String, Message>> messages = new Map<String, Map<String, Message>>();

        // One of these must be selected so bail out if they are both false
        if (!sendViaPulse && !sendViaSms) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must send a message either via SMS or Pulse.'));
            return messages;
        }

        // Hash the message text so it can be used as a key to a map
        String messageHash = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(messageText)));

        // Get all the people to send the message to
        for (Person__c[] people : [
                SELECT
                    Id,
                    First_Name__c,
                    Middle_Name__c,
                    Last_Name__c,
                    Mobile_Number__c,
                    Country__r.ISO_Standard_Code__c
                FROM
                    Person__c
                WHERE
                    Id IN :recipients
        ]) {
            for (Person__c person : people) {
                SendSMSHelpers.Recipient recipient = SendSMSHelpers.generateRecipient(
                    person.Id,
                    person.First_Name__c,
                    person.Middle_Name__c,
                    person.Last_Name__c,
                    person.Mobile_Number__c,
                    person.Country__r.ISO_Standard_Code__c,
                    null
                );
                if (sendViaSms) {
                    if (!messages.containsKey(recipient.countryCode)) {
                        messages.put(recipient.countryCode, new Map<String, Message>());
                    }
                    Message message = messages.get(recipient.countryCode).get(messageHash);
                    if (message == null) {
                        message = new Message(subject, messageText, senderId, senderName, sendTime, expirationTime, 'SMS');
                    }
                    message.addRecipient(recipient);
                    messages.get(recipient.countryCode).put(messageHash, message);
                }
                if (sendViaPulse) {
                    if (!messages.containsKey(pulse)) {
                        messages.put(pulse, new Map<String, Message>());
                    }
                    Message message = messages.get(pulse).get(messageHash);
                    if (message == null) {
                        message = new Message(subject, messageText, senderId, senderName, sendTime, expirationTime, pulse);
                    }
                    message.addRecipient(recipient);
                    messages.get(pulse).put(messageHash, message);
                }
            }
        }
        return messages;
    }

    /**
     * Send a group of messages to a gateway based on the country code for the recipients of the messages
     *
     * @param messages          - A map of maps that contain the messages
     *                             The key to the outer map is the country code
     *                             The key to the inner map is the message hash
     * @param scheduleForResend - Boolean indicating that the failed messages should be resent
     */
    public static Boolean sendThroughGateways(Map<String, Map<String, Message>> messages, Boolean scheduleForResend) {

        Map<String, Boolean> resultMap = new Map<String, Boolean>();

        // Go through the created messages and send to the correct gateway
        for (String countryCode : messages.keySet()) {
            SMS_Gateway_Country_Settings__c gatewaySetting = SMS_Gateway_Country_Settings__c.getInstance(countryCode);
            if (gatewaySetting == null) {

                // Gateway setting does not exist so skip. Send email to inform setup that this has happened
                // TODO - SEND AN EMAIL TO TECH INFORMING THEM OF THIS
                System.debug(LoggingLevel.INFO, 'Gateway for country: ' + countryCode + ' not set up');
                continue;
            }
            Type t = Type.forName('', gatewaySetting.Class_Name__c);
            if (t == null) {

                // Country code does not have an implemented gateway associated with it
                // TODO - SEND AN EMAIL TO TECH INFORMING THEM OF THIS
                System.debug(LoggingLevel.INFO, 'ClassName for: ' + gatewaySetting.Class_Name__c + '. for country: ' + countryCode + ' not set up');
                continue;
            }
            SendViaSMSGateway gateWay = (SendViaSMSGateway)t.newInstance();
            gateWay.callback(gateWay.execute(messages.get(countryCode).values()), resultMap);
        }

        // If we are allowing resends then add the messages that failed to the schedular
        Boolean rescheduled = false;
        if (scheduleForResend && resultMap.size() > 0) {
            rescheduled = scheduleMessagesForResend(resultMap, messages);
        }
        return rescheduled;
    }

    /**
     * Schedule messages for resend if the message failed to send. The resultMap should be generated by the gateway
     *
     * @param resultMap - Map indicating the success of a message. Key is of the following format <personId>_splitter_<messageHash>
     * @param messages  - A map of maps that contain the messages
     *                      The key to the outer map is the country code
     *                      The key to the inner map is the message hash
     */
    public static Boolean scheduleMessagesForResend(Map<String, Boolean> resultMap, Map<String, Map<String, Message>> messages) {

        Boolean rescheduled = false;
        DateTime nextSend = DateTime.now().addHours(1);
        List<Scheduled_Message_Queue__c> resendMessages = new List<Scheduled_Message_Queue__c>();
        for (String countryCode : messages.keySet()) {
            for (String messageHash : messages.get(countryCode).keySet()) {
                Message messageToBeResent = messages.get(countryCode).get(messageHash);
                for (SendSMSHelpers.Recipient recipient : messageToBeResent.recipients.values()) {

                    if (!resultMap.get(recipient.personId + '_splitter_' + messageHash)) {

                        if (recipient.messages.containsKey(messageHash)) {

                            // Existing message needs re-sending
                            Scheduled_Message_Queue__c message = recipient.messages.get(messageHash);
                            message.Number_Of_Resends__c++;
                            resendMessages.add(message);
                            rescheduled = true;
                        }
                        else {

                            // New message needs scheduling for the first time
                            Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                                Subject__c = messageToBeResent.subject,
                                Message__c = messageToBeResent.body,
                                Sender__c = messageToBeResent.senderId,
                                Expiration_Date__c = messageToBeResent.expirationTime,
                                Send_Via_Pulse__c = messageToBeResent.medium.equals('PULSE'),
                                Send_Via_SMS__c = messageToBeResent.medium.equals('SMS'),
                                Send_Date_Time__c = DateTime.now().addMinutes(5),
                                Person__c = recipient.personId
                            );  
                            resendMessages.add(message);
                            rescheduled = true;
                        }
                    }
                }
            }
        }
        if (rescheduled) {
            upsert(resendMessages);
        }
        return rescheduled;
    }

    /**
     * Create a recipient
     *
     * @param personId - The id of the person to be turned into a reipient
     *
     * @return - The new recipient or null if they do not exist
     */
    public static SendSMSHelpers.Recipient generateRecipient(
            String personId,
            String firstName,
            String middleName,
            String lastName,
            String mobileNumber,
            String countryCode,
            Scheduled_Message_Queue__c message
    ) {

        if (countryCode == null) {
            countryCode = 'UG';
        }

        // Get the country Dialing code for this person
        Decimal countryDialingCode = null;
        SMS_Gateway_Country_Settings__c setting = SMS_Gateway_Country_Settings__c.getInstance(countryCode);
        if (setting != null) {
            countryDialingCode = setting.Country_Code__c;
        }
        return new SendSMSHelpers.Recipient(
            countryCode,
            firstName,
            middleName,
            lastName,
            mobileNumber,
            countryDialingCode,
            personId,
            message
       );
    }

    /**
     * Generate a recipient
     */
    public class Recipient {
        public String countryCode;
        public String fullName;

        // Phone number is the raw local number. No country code and no trailing 0
        public String phoneNumber;
        public Integer countryDialingCode;
        public String personId;
        public Map<String, Scheduled_Message_Queue__c> messages;

        public Recipient(
                String countryCode,
                String firstName,
                String middleName,
                String lastName,
                String phoneNumber,
                Decimal countryDialingCode,
                String personId,
                Scheduled_Message_Queue__c message
        ) {
            this.countryCode = countryCode;
            if (middleName != null) {
                firstName = firstName + ' ' + middleName;
            }
            this.fullName = firstName + ' ' + lastName;
            this.phoneNumber = phoneNumber;
            this.countryDialingCode = countryDialingCode.intValue();
            this.personId = personId;
            this.messages = new Map<String, Scheduled_Message_Queue__c>();
            if (message != null) {
                this.messages.put(EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(message.Message__c))), message);
            }
        }

        public void addMessage(Scheduled_Message_Queue__c message) {
            this.messages.put(EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(message.Message__c))), message);
        }
    }

    // DELETE THIS METHOD. USED BY ANNOYMOUS APEX TO CALL YP TEST ENV FOR TESTING
    public static void sendToYp(List<Person__c> recipients, Id userId, String userName, String messageText, String subject, DateTime expirationTime,
            DateTime sendTime
    ) {

        Message message = new Message(
            subject,
            messageText,
            userId,
            userName,
            sendTime,
            expirationTime,
            'SMS'
        );
        for (Person__c person : recipients) {
            Recipient recipient = generateRecipient(
                person.Id,
                person.First_Name__c,
                person.Middle_Name__c,
                person.Last_Name__c,
                person.Mobile_Number__c,
                person.Country__r.ISO_Standard_Code__c,
                null
            );
            message.addRecipient(recipient);
        }
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        //gateway.loadSetting();
        //String body = gateway.createBody(new List<Message>{ message }, recipients.size() == 1);
        //System.debug(LoggingLevel.INFO, body);
        //HttpResponse response = gateway.sendRequest(gateway.buildRequest(body, recipients.size() == 1));
        //System.debug(LoggingLevel.INFO, response.getBody());
        System.debug(gateway.execute(new List<Message>{ message }));
    }
/*
    public static String sendMessage(String message, String countryCode) {

        SMS_Gateway_Settings__c setting = SMS_Gateway_Settings__c.getInstance(countryCode);
        Type t = Type.forName('', setting.Class_Name__c);
        if (t == null) {
            return 'FAIL';
        }
        SendViaSMSGateway gateWay = (SendViaSMSGateway)t.newInstance();
        return gateWay.execute(message);
    }

    static testMethod void testKannel() {
        Database.insert(new SMS_Gateway_Settings__c( Name = 'UG', ISO_Standard__c = 'UG', Country_Code__c = 256, Class_Name__c = 'SendSMSViaKannel' ));
        System.debug(LoggingLevel.INFO, SendSMS.sendMessage('Testing Kannel', 'UG'));
    }

    static testMethod void testFailure() {
        Database.insert(new SMS_Gateway_Settings__c( Name = 'UG', ISO_Standard__c = 'UG', Country_Code__c = 256, Class_Name__c = 'ThisDoesNotExist' ));
        System.assert(SendSMS.sendMessage('Testing Kannel', 'UG').equals('FAIL'));
    }*/
}