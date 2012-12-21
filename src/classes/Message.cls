public with sharing class Message {

    /**
     * Encapsulates the information that is needed to send an SMS to a given gateway for a given list of recipients
     */
    public String subject;
    public String body;
    public Id senderId;
    public String senderName;
    public Map<String, SendSMSHelpers.Recipient> recipients;
    public DateTime expirationTime;
    public DateTime sentTime;
    public String medium;

    public Message(
            String subject,
            String body,
            Id senderId,
            String senderName,
            DateTime expirationTime,
            DateTime sentTime,
            String medium
    ) {

        this.subject = subject;
        this.body = body;
        this.senderId = senderId;
        this.senderName = senderName;
        this.recipients = new Map<String, SendSMSHelpers.Recipient>();
        this.expirationTime = expirationTime;
        this.sentTime = sentTime;
        this.medium = medium;
    }

    public void addRecipient(SendSMSHelpers.Recipient recipient) {
        this.recipients.put(recipient.personId, recipient);
    }

    /**
     * Create a MD5 hash of the message text. This can then be used a key to a map to identify the message easily
     *
     * @return - The hash string
     */
    public String getMessageHash() {
        return EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(this.body)));
    }







/*
    private String body;
    private String subject;
    private Map<String, String> recipientMap; // Contains Person Id as Key and Mobile Number as Value
    private User sender;
    private String serverUrl;
    private DateTime expirationDate;
    private List<Recipient> recipients;

    public Message(String subject, String body, List<Recipient> recipients, User sender, DateTime expirationDate, Server_Configuration__c configuration) {

        if (subject == null) {
            throw new IllegalArgumentException('subject may not be null');
        }
        if (body == null) {
            throw new IllegalArgumentException('body may not be null');
        }
        if (recipients == null || recipients.size() == 0) {
            throw new IllegalArgumentException('recipients must be non-empty and non-null');
        }
        if (sender == null) {
            throw new IllegalArgumentException('sender must not be null');
        }
        this.body = body;
        this.subject = subject;
        this.sender = sender;
        this.expirationDate = expirationDate;
        this.recipients = recipients;
        this.serverUrl = configuration.URL__c;
    }

    public void sendViaPulse() {

           expandGroupMembership(false, true);
           if (this.recipientMap != null && this.recipientMap.size() > 0) {
                List<String> recipientIds = new List<String>();
                recipientIds.addAll(recipientMap.keySet());
                List<Message__c> messages = new List<Message__c>();
                for (String recipientId : recipientIds) {
                    System.debug('Sending message to recipient ' + recipientId);
                    Message__c msg = new Message__c();
                    msg.Body__c = this.body;
                    msg.Recipient__c = recipientId;
                    msg.Subject__c = this.subject;
                    msg.From__c = this.sender.id;
                    if (this.expirationDate != null) {
                        msg.Expiration_Time__c = this.expirationDate;
                    }
                    messages.add(msg);
                }
                Database.insert(messages);
           }
    }

    public void sendViaSms() {

        // This method will send SMS messages to all recipients for whom we have phone
        // numbers. If a user doesn't have a phone number, they will be skipped.
        expandGroupMembership(true, false);
        if (this.recipientMap != null && this.recipientMap.size() > 0) {
            String requestBody = buildSmsRequest();
            internalSendViaSms(this.serverUrl, requestBody);
        }
    }

    /**
     * We need this static helper method because only @future methods can make we service
     * calls, and @future methods must be static, void, and may only accept primitive types
     * as parameters
     *
    @future(callout=true)
    private static void internalSendViaSms(String serverUrl, String requestBody) {
        updateSmsMetric(parseResponse(SqlHelpers.postServletRequest(serverUrl, 'sendSms', requestBody)));
        //SqlHelpers.postServletRequest(serverUrl, 'sendSms', requestBody);
    }

    public static void sendScheduledMessages() {

       try {
           Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c
                LIMIT 1];
        datetime presentHour = datetime.now();
        List<User> senders = new List<User>();
        for (User[] senderObjects : [SELECT id, name  FROM User]) {
             for (User senderObject : senderObjects) {
                  senders.add(senderObject);
             }
        }
        for ( Scheduled_Message_Queue__c[] scheduledMessageQueue : [
            SELECT 
                Id, 
                Group__c, 
                Person__c, 
                Message__c, 
                Sender__c, 
                Subject__c, 
                Send_Date_Time__c, 
                Expiration_Date__c,
                Send_Via_Pulse__c,
                Send_Via_Sms__c
            FROM 
                Scheduled_Message_Queue__c 
            WHERE 
                Send_Date_Time__c <= :presentHour]
        ) {

             System.debug(scheduledMessageQueue.size());

            if (scheduledMessageQueue.size() > 0) {
                for (Scheduled_Message_Queue__c scheduledMessage : scheduledMessageQueue) {
                    User sender;
                    for (User user : senders) {
                        if (user.Id == scheduledMessage.Sender__c) {
                            sender = user;
                            break;
                        }
                    }
                    List<Recipient> recipients = new List<Recipient>();
                    if (scheduledMessage.Expiration_Date__c < datetime.now()) {
                       System.debug('Message already expired!!!');
                        continue;
                    }
                    if (scheduledMessage.Person__c == null) {
                        recipients.add(new Recipient(scheduledMessage.Group__c, Recipient.RecipientType.DistributionGroup));
                    }
                    else {
                        recipients.add(new Recipient(scheduledMessage.Person__c, Recipient.RecipientType.Person));
                    }
                    Message msg = new Message(
                        scheduledMessage.Subject__c,
                        scheduledMessage.Message__c,
                        recipients,
                        sender,
                        scheduledMessage.Expiration_Date__c,
                        configuration
                    );

                    if (scheduledMessage.Send_Via_Pulse__c) {
                        System.debug('Message sending via pulse!');
                        msg.sendViaPulse();
                    }
                    if (scheduledMessage.Send_Via_Sms__c ) {
                        System.debug('Message sending via SMS!');
                        msg.sendViaSms();
                    }
               }
            }
            database.delete(scheduledMessageQueue);
         }
       }
       catch(Exception e) {
           ErrorLog.writeLater('SchdeduledSender', 'processHourlyMessages()', e.getMessage(), 1);
       }
    }

    public void scheduleMessage(datetime sendDate, Boolean sendViaPulse, Boolean sendViaSms) {
        if (this.recipients.size() > 0) {
            List<Scheduled_Message_Queue__c> scheduledMessages = new List<Scheduled_Message_Queue__c>();
            for (Recipient messageRecipient : this.recipients) {
                    Scheduled_Message_Queue__c scheduledMessage = new Scheduled_Message_Queue__c();
                    scheduledMessage.Message__c = this.body;
                    scheduledMessage.Send_Date_Time__c = sendDate;
                    scheduledMessage.Expiration_Date__c = this.expirationDate;
                    scheduledMessage.Sender__c = this.sender.Id;
                    scheduledMessage.Subject__c = this.subject;

                    if (sendViaPulse) {
                        scheduledMessage.Send_Via_Pulse__c = true;
                    } else {
                        scheduledMessage.Send_Via_Pulse__c = false;
                    }
                    
                    if (sendViaSms) {
                        scheduledMessage.Send_Via_Sms__c = true;
                    }
                    else {
                         scheduledMessage.Send_Via_Sms__c = false;
                    }

                    if (messageRecipient.getRecipientType() == Recipient.RecipientType.Person) {
                        scheduledMessage.Person__c = messageRecipient.getRecipientId();
                    }
                    else {
                        scheduledMessage.Group__c = messageRecipient.getRecipientId();
                    }
                    scheduledMessages.add(scheduledMessage);
            }
            Database.insert(scheduledMessages);
        }
    }

    private void expandGroupMembership(Boolean sendViaSms, Boolean sendViaPulse) {
        // Need to use a dictionary so that we don't send duplicate messages to people
        // who are in more than one group
        this.recipientMap = new Map<String, String>();

        for (Recipient messageRecipient : this.recipients) {
            if (messageRecipient.getRecipientType() == Recipient.RecipientType.DistributionGroup) {
                if (sendViaPulse) {
                     for (Person_Group_Association__c[] personAssociations : [SELECT 
                                                                                                          Person__c, 
                                                                                                          Person__r.Mobile_Number__c 
                                                                                                        FROM
                                                                                                          Person_Group_Association__c
                                                                                                        WHERE 
                                                                                                        Group__c = :messageRecipient.getRecipientId()]) { 
                                for (Person_Group_Association__c personAssociation : personAssociations) {
                                     recipientMap.put(personAssociation.Person__c, personAssociation.Person__r.Mobile_Number__c);
                                }
                      }
                            
                } else if (sendviaSms) {
                     for (Person_Group_Association__c[]  personAssociations : [SELECT 
                                                                                                          Person__c, 
                                                                                                          Person__r.Mobile_Number__c 
                                                                                                        FROM
                                                                                                          Person_Group_Association__c
                                                                                                        WHERE Group__c = :messageRecipient.getRecipientId()  
                                                                                                        AND
                                                                                                           Person__r.Mobile_Number__c != null]) { 
                             for (Person_Group_Association__c personAssociation : personAssociations) {
                                     recipientMap.put(personAssociation.Person__c, personAssociation.Person__r.Mobile_Number__c);
                             }
                     }
                }
            } else if (messageRecipient.getRecipientType() == Recipient.RecipientType.Person && 
                !recipientMap.containsKey(messageRecipient.getRecipientId())) {
                // looking for a single person, but may be zero length
                if (sendViaSms) {
                    for (Person__c[] people : [SELECT 
                                                            id, 
                                                            Mobile_Number__c 
                                                        FROM 
                                                            Person__c
                                                        WHERE 
                                                            id = :messageRecipient.getRecipientId() 
                                                        AND 
                                                            Mobile_Number__c != null]) { 
                                for (Person__c person : people) {
                                    recipientMap.put(person.id, person.Mobile_Number__c);
                                }
                    }
                }
                else {
                    for (Person__c[] people : [SELECT 
                                                           id, 
                                                           Mobile_Number__c 
                                                       FROM 
                                                           Person__c 
                                                       WHERE 
                                                           id = :messageRecipient.getRecipientId()]) {
                            for (Person__c person : people) {
                                recipientMap.put(person.id, person.Mobile_Number__c);
                            }
                    }
                }
            }
        }
    }

    private static Decimal parseResponse(String xml) {

        List<String> personId = new List<String>();
        XmlStreamReader responseReader = new XmlStreamReader(xml);
        responseReader.next();

        while(responseReader.hasNext()) {
            if(responseReader.isStartElement()) {
                if (responseReader.getAttributeValue(null, 'statusCode') == '202') {
                    personId.add(responseReader.getAttributeValue(null, 'personId'));
                }
            }
            responseReader.next();
        }
        return getNonCkws(personId);
    }

    private static Decimal getNonCkws(List<String> personIds) {

        String ids = MetricHelpers.generateCommaSeperatedString(personIds, true);
        String query = 'SELECT '                      +
                'id '                                 +
            'FROM '                                   +
                'Person__c '                          +
            'WHERE '                                  +
                'id IN (' + ids + ')'                 +
                'AND id NOT IN ('                     +
                    'SELECT Person__c FROM CKW__c'    +
                ')';
        Person__c[] people = database.query(query);
        return Decimal.valueOf(people.size());
    }

    private static void updateSmsMetric(Decimal actualValue) {
        MetricHelpers.updateMetric('total_interactions_channels', actualValue, null, null, null, null, true);
    }

    private string buildSmsRequest() {
        String request = '<?xml version="1.0"?>' +
            '<SendSmsRequest xmlns="http://schemas.applab.org/2010/08" from="' + this.sender.name + '">' +
            '<Message>' + this.body + '</Message>' +
            '<Recipients>';

        // We know the recipientMap is non-empty because the caller checked
        for (String personId : this.recipientMap.keySet()) {
            if (this.recipientMap.get(personId) != null 
            ) {
                request += '<Recipient personId="' + personId + '">' + this.recipientMap.get(personId) + '</Recipient>';
            }
        }

        request += '</Recipients></SendSmsRequest>';

        System.debug('REQUEST XML: ' + request);
        return request;
    }

    public class IllegalArgumentException extends Exception {}

    private static Message constructTestMessage() {

        String subject = 'Test message';
        String body = 'This is a message to be sent via Pulse';
        User sender = [SELECT id,name FROM User LIMIT 1];
        List<Recipient> recipients = new List<Recipient>();

        Group__c currentGroup = [SELECT id FROM Group__c LIMIT 1];
      recipients.add(new Recipient(currentGroup.id, Recipient.RecipientType.DistributionGroup));

        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c
            LIMIT 1];

        return new Message(subject, body, recipients, sender, null, configuration); 
    }

    static testMethod void testSendViaPulse() {

        Message message = constructTestMessage();       
        Message__c beforeMessageId = [SELECT Id FROM Message__c ORDER BY CreatedDate DESC LIMIT 1];
        message.sendViaPulse();
        Integer recipientCount = message.recipientMap.size();
        Message__c afterMessageId = [SELECT Id FROM Message__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(afterMessageId != beforeMessageId);
    }

    static testMethod void testSendViaSms() {

        Message message = constructTestMessage();

        // Because we can't call HTTP callouts from test methods, the best we can do is validate
        // that the request is created/processed correctly
        message.expandGroupMembership(true, false);
        String request = message.buildSmsRequest();
        System.assert(request.contains(message.body));
        System.assert(request.contains(message.sender.name));       
    }

    static testMethod void testScheduleMessage() {

        Message message = constructTestMessage();

        // Schedule a message to be sent 3 hours from now, via pulse
        message.scheduleMessage(datetime.now().addHours(3), true, false);
        Boolean messageInQueue = false;
        for ( Scheduled_Message_Queue__c[] scheduledMessageQueue : [
            SELECT 
                Id, 
                Group__c, 
                Person__c, 
                Message__c, 
                Sender__c, 
                Subject__c, 
                Send_Date_Time__c, 
                Expiration_Date__c,
                Send_Via_Pulse__c,
                Send_Via_Sms__c
            FROM 
                Scheduled_Message_Queue__c ]
        ) {
            for (Scheduled_Message_Queue__c scheduledMessage : scheduledMessageQueue) {
                if (scheduledMessage.Message__c == 'This is a message to be sent via Pulse') {
                    messageInQueue = true;
                    break;
                }
            }
        }
        System.assert(messageInQueue);
    }

    static testMethod void testParseResponse() {

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        database.insert(testCkw);
        CKW__c testCkw2 = [SELECT name from CKW__c where id =:testCkw.id];  

        // Create test farmer
        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = 'FirstName';
        testPerson1.Last_Name__c = 'LastName';
        testPerson1.Gender__c = 'Female';
        database.insert(testPerson1);

        Farmer__c testFarmer1 = new Farmer__c();
        testFarmer1.Person__c = testPerson1.Id;
        database.insert(testFarmer1);

        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson1.Gender__c = 'Male';
        database.insert(testPerson2);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson2.Id;
        database.insert(testFarmer2);
 
        String xml = '<SendSmsResponse xmlns="http://schemas.applab.org/2010/08">' +
            '<SmsResult personId="' + testPerson.Id + '" statusCode="202" recipient="256123456">OK</SmsResult>' +
            '<SmsResult personId="' + testPerson1.Id + '" statusCode="400" recipient="0987654">Bad phone number</SmsResult>' +
            '<SmsResult personId="' + testPerson2.Id + '" statusCode="202" recipient="0987654">OK</SmsResult>' +
            '</SendSmsResponse>';

        System.assertEquals(parseResponse(xml), 1.0);
    }
*/
}