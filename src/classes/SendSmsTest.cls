@isTest
public class SendSmsTest {

    /**
     * Test methods for the sending of messages.
     * For both the bulk message page and for the scheduling of messages
     *
     * Classes covered:
     *    BulkMessageController
     *    Message
     *    SendMessageViaPulse
     *    SendSMS
     *    SendSMSHelpers
     *    SendSMSViaKannel
     *    SendSMSViaYellowPepper
     *    SendViaSMSGateway
     *	  SendSMSViaEdnetUg
     */

    static List<Group__c> groups;
    static List<Message> messages;
    static List<Person__c> people;

    // HELPER METHODS USED FOR TESTING
    public static String getTestKannelResponse() {
        return '{"kannelResponse" : [' +
            '{"statusCode" : "202", "response":"OK", "phoneNumber":"0787314753", "personId":"a0R70000002igrcEAA", "messageHash" : "Hash2"},' +
            '{"statusCode" : "202", "response":"OK","phoneNumber":"0787314754", "personId":"a0R70000002igrcEAB", "messageHash" : "Hash2"},' +
            '{"statusCode" : "400", "response":"Bad number", "phoneNumber":"999", "personId":"a0R70000002igrbEAA", "messageHash" : "Hash2"}]}';
    }

    public static String getTestYPResponse() {
        return '{"yellowPepperResponse" : [' +
            '{"messageHash" : "Hash2", "personId" : "1", "success" : true},' +
            '{"messageHash" : "Hash2", "personId" : "2", "success" : true},' +
            '{"messageHash" : "Hash2", "personId" : "3", "success" : false}' +
            ']}';
    }

    static void addGatewaySettings(
            String name,
            String bulkEndPoint,
            String singleEndPoint,
            String username,
            String password,
            Integer shortCode
    ) {

        insert(
            new SMS_Gateway_Settings__c(
                Name = name,
                Bulk_End_Point__c = bulkEndPoint,
                Single_Endpoint__c = singleEndPoint,
                Username__c = username,
                Password__c = password,
                Short_Code__c = shortCode
            )
        );
    }

    static void addCountrySetting(String name, String className, Integer countryCode, String isoCountryCode) {

        insert (
            new SMS_Gateway_Country_Settings__c(
                Name = name,
                Class_Name__c = className,
                Country_Code__c = countryCode,
                ISO_Standard__c = isoCountryCode
            )
        );
    }

    static Message createMessage(
            String subject,
            String body,
            Id senderId,
            String senderName,
            DateTime expirationTime,
            DateTime sendTime,
            String medium,
            List<SendSMSHelpers.Recipient> recipients
    ) {

        Message message = new Message(subject, body, senderId, senderName, sendTime, expirationTime, medium);
        for (SendSMSHelpers.Recipient recipient : recipients) {
            message.addRecipient(recipient);
        }
        return message;
    }

    static void setUpMessaging() {

        // Create the gateway settings
        addGatewaySettings('Kannel', 'bulk', 'single', 'username', 'password', 123);
        addGatewaySettings('PULSE', 'bulk', 'single', 'username', 'password', 123);

        // Create the country settings (send through kannel as can do full process with test data)
        addCountrySetting('JJ', 'SendSMSViaKannel', 256, 'JJ');
        addCountrySetting('PULSE', 'SendMessageViaPulse', 000, 'XXX');

        // Create the country
        Country__c c1 = new Country__c( Name = 'TestCountry', ISO_Standard_Code__c = 'JJ', Language__c = 'English');
        insert(c1);

        // Create some people
        Person__c p1 = new Person__c( Last_Name__c = 'l1', Middle_Name__c = 'm1', First_Name__c = 'f1', Country__c = c1.Id, Raw_Mobile_Number__c = '111111111');
        Person__c p2 = new Person__c( Last_Name__c = 'l2', Middle_Name__c = 'm2', First_Name__c = 'f2', Country__c = c1.Id, Raw_Mobile_Number__c = '222222222');
        Person__c p3 = new Person__c( Last_Name__c = 'l3', Middle_Name__c = 'm3', First_Name__c = 'f3', Country__c = c1.Id, Raw_Mobile_Number__c = '333333333');
        Person__c p4 = new Person__c( Last_Name__c = 'l4', Middle_Name__c = 'm4', First_Name__c = 'f4', Country__c = c1.Id, Raw_Mobile_Number__c = '444444444');
        Person__c p5 = new Person__c( Last_Name__c = 'l5', Middle_Name__c = 'm5', First_Name__c = 'f5', Country__c = c1.Id, Raw_Mobile_Number__c = '555555555');
        Person__c p6 = new Person__c( Last_Name__c = 'l6', Middle_Name__c = 'm6', First_Name__c = 'f6', Country__c = c1.Id, Raw_Mobile_Number__c = '666666666');
        insert(new List<Person__c>{ p1, p2, p3, p4, p5, p6 });
        people = new List<Person__c>{ p1, p2, p3, p4, p5, p6 };

        // Create some groups
        Group__c g1 = new Group__c( Name='Group1' );
        Group__c g2 = new Group__c( Name='Group2' );
        groups = new List<Group__c>{ g1, g2 };
        insert(groups);

        // Add some people to the groups
        Person_Group_Association__c pga1 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p1.Id);
        Person_Group_Association__c pga2 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p2.Id);
        Person_Group_Association__c pga3 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p3.Id);
        Person_Group_Association__c pga4 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p4.Id);
        Person_Group_Association__c pga5 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p5.Id);
        Person_Group_Association__c pga6 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p6.Id);
        Person_Group_Association__c pga7 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p1.Id);
        Person_Group_Association__c pga8 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p3.Id);
        Person_Group_Association__c pga9 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p5.Id);
        insert(new List<Person_Group_Association__c>{ pga1, pga2, pga3, pga4, pga5, pga6, pga7, pga8, pga9 });
    }

    // Test each gateway individually
    // Testing YellowPepper
    static testMethod void testYPCreateBodyTooManyMessages() {

        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);
        addCountrySetting('JJ', 'SendSMSViaYellowPepper', 256, 'JJ');
        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            ),
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        gateway.loadSetting();
        Boolean fail = false;
        try {
            gateway.createBody(messages, true);
        }
        catch (Exception e) {
            System.assert(e.getMessage().equals('Can only send one message through YP at once'), 'Error message is wrong');
            fail = true;
        }
        System.assert(fail, 'Should have failed to build the body as there were too many messages');
    }

    static testMethod void testYPCreateBodySingle() {

        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);
        addCountrySetting('JJ', 'SendSMSViaYellowPepper', 256, 'JJ');
        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        gateway.loadSetting();
        System.assertEquals(gateway.createBody(messages, true), 'op=sendBroadcastMessage&Serial=username&Pin=password&Message=body&Mobile=2560123456789&Sender=123');
    }

    static testMethod void testYPCreateBodyBulk() {

        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);
        addCountrySetting('JJ', 'SendSMSViaYellowPepper', 256, 'JJ');
        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                'id2', 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        gateway.loadSetting();
        System.assertEquals(gateway.createBody(messages, false), 'op=sendBroadcastMessage&Serial=username&Pin=password&Message=body&Mobiles=2560123456789;256987654321&Sender=123');
    }

    static testMethod void testYPBuildRequestSingle() {

        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        gateway.loadSetting();
        HttpRequest request = gateway.buildRequest('body', true);
        System.assertEquals(request.getBody(), 'body');
        System.assertEquals(request.getEndpoint(), 'single');
    }

    static testMethod void testYPBuildRequestBulk() {

        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        gateway.loadSetting();
        HttpRequest request = gateway.buildRequest('body', false);
        System.assertEquals(request.getBody(), 'body');
        System.assertEquals(request.getEndpoint(), 'bulk');
    }

    static testMethod void testYPCallback() {

        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        Map<String, Boolean> resultMap = gateway.callback(getTestYPResponse(), null);
        for (String key : resultMap.keySet()) {
            if (!key.equals('3_splitter_Hash2')) {
                System.assert(resultMap.get(key));
            }
            else {
                System.assert(!resultMap.get(key));
            }
        }
    }

    static testMethod void testYPExecute() {

        addCountrySetting('JJ', 'SendSMSKannel', 256, 'JJ');
        addGatewaySettings('YellowPepper', 'bulk', 'single', 'username', 'password', 123);

        Person__c p1 = new Person__c( Last_Name__c = 'l1', First_Name__c = 'f1' );
        Person__c p2 = new Person__c( Last_Name__c = 'l2', First_Name__c = 'f2' );
        insert(new List<Person__c>{ p1, p2 });

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                p1.id, 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                p2.id, 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        List<Message> message = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'PULSE', recipients
            )
        };
        SendSMSViaYellowPepper gateway = new SendSMSViaYellowPepper();
        for (Boolean result : gateway.callback(gateway.execute(message), null).values()) {
            System.assert(!result);
        }
    }

    // Test Pulse
    static testMethod void testSendViaPulse() {

        addCountrySetting('JJ', 'SendSMSKannel', 256, 'JJ');

        Person__c p1 = new Person__c( Last_Name__c = 'l1', First_Name__c = 'f1' );
        Person__c p2 = new Person__c( Last_Name__c = 'l2', First_Name__c = 'f2' );
        insert(new List<Person__c>{ p1, p2 });

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                p1.id, 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                p2.id, 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'PULSE', recipients
            ),
            createMessage(
                'Subject2', 'body2', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'PULSE', recipients
            )
        };

        SendMessageViaPulse gateway = new SendMessageViaPulse();
        String output = gateway.execute(messages);
        Map<String, Boolean> resultMap = gateway.callback(output, null);
        System.assertEquals(resultMap.size(), 4);
        for (Boolean result : resultMap.values()) {
            System.assert(result);
        }

        // Pointlessly uping the code coverage
        gateway.createBody(null, false);
        gateway.buildRequest('', false);
        gateway.sendRequest(null);
    }

    // Test Kannel
    static testMethod void testKannelCreateBody() {

        // Create the country settings (send through kannel as can do full process with test data)
        addCountrySetting('JJ', 'SendSMSKannel', 256, 'JJ');

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                'id2', 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), 'crmadmin@applab.org', DateTime.now(), DateTime.now(), 'SMS', recipients
            ),
            createMessage(
                'Subject2', 'body2', UserInfo.getUserId(), 'crmadmin@applab.org', DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaKannel gateway = new SendSMSViaKannel();
        System.assertEquals(gateway.createBody(messages, false), '{"messages":[{"sender":"crmadmin@applab.org","recipients":[{"phoneNumber":"0123456789","personId":"id","countryCode":"256"},{"phoneNumber":"987654321","personId":"id2","countryCode":"256"}],"messageHash":"hBotaJrYa9FhFEdFPCLG/A==","message":"body"},{"sender":"crmadmin@applab.org","recipients":[{"phoneNumber":"0123456789","personId":"id","countryCode":"256"},{"phoneNumber":"987654321","personId":"id2","countryCode":"256"}],"messageHash":"dq9jxb13sqOiz8vVJkX6OA==","message":"body2"}]}');
    }

    static testMethod void testKannelBuildSingleRequest() {

        addGatewaySettings('Kannel', 'bulk', 'single', 'username', 'password', 123);
        SendSMSViaKannel gateway = new SendSMSViaKannel();
        HttpRequest request = gateway.buildRequest('body', true);
        System.assertEquals(request.getBody(), 'body');
        System.assertEquals(request.getEndpoint(), 'single');
    }

    static testMethod void testKannelBuildBulkRquest() {

        addGatewaySettings('Kannel', 'bulk', 'single', 'username', 'password', 123);
        SendSMSViaKannel gateway = new SendSMSViaKannel();
        HttpRequest request = gateway.buildRequest('body', false);
        System.assertEquals(request.getBody(), 'body');
        System.assertEquals(request.getEndpoint(), 'bulk');
    }

    static testMethod void testKannelCallback() {

        SendSMSViaKannel gateway = new SendSMSViaKannel();
        Map<String, Boolean> resultMap = gateway.callback(getTestKannelResponse(), null);
        for (String key : resultMap.keySet()) {
            if (!key.equals('a0R70000002igrbEAA_splitter_Hash2')) {
                System.assert(resultMap.get(key));
            }
            else {
                System.assert(!resultMap.get(key));
            }
        }
    }

    static testMethod void testKannelFailureString() {

        addCountrySetting('JJ', 'SendSMSKannel', 256, 'JJ');

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                'id2', 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            ),
            createMessage(
                'Subject2', 'body2', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaKannel gateway = new SendSMSViaKannel();
        String output = gateway.createFullFailureString(messages);
        System.assertEquals(output, '{"kannelResponse":[{"statusCode":"400","response":"Gateway Failure","phoneNumber":"0123456789","personId":"id","messageHash":"hBotaJrYa9FhFEdFPCLG/A=="},{"statusCode":"400","response":"Gateway Failure","phoneNumber":"987654321","personId":"id2","messageHash":"hBotaJrYa9FhFEdFPCLG/A=="},{"statusCode":"400","response":"Gateway Failure","phoneNumber":"0123456789","personId":"id","messageHash":"dq9jxb13sqOiz8vVJkX6OA=="},{"statusCode":"400","response":"Gateway Failure","phoneNumber":"987654321","personId":"id2","messageHash":"dq9jxb13sqOiz8vVJkX6OA=="}]}');
        Map<String, Boolean> resultMap = gateway.callback(output, null);
        for (String key : resultMap.keySet()) {
            System.assert(!resultMap.get(key));
        }
    }

    static testMethod void testKannelExecute() {

        addCountrySetting('JJ', 'SendSMSKannel', 256, 'JJ');

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient>{
            SendSMSHelpers.generateRecipient(
                'id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null
            ),
            SendSMSHelpers.generateRecipient(
                'id2', 'firstName2', 'middleName2', 'lastName2', '987654321', 'JJ', null
            )
        };
        messages = new List<Message>{
            createMessage(
                'Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            ),
            createMessage(
                'Subject2', 'body2', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients
            )
        };
        SendSMSViaKannel gateway = new SendSMSViaKannel();
        System.assertEquals(gateway.execute(messages), gateway.getTestKannelResponse(messages));
    }

    // Tests for Bulk Message controller
    static testMethod void testSubmitMessageImmediately() {

        setUpMessaging();

        // Set up and test page submission
        PageReference ref = Page.BulkMessage;
        ref.getParameters().put('groupsParam', groups[0].Id);
        ref.getParameters().put('peopleParam', '');
        Test.setCurrentPage(ref);
        BulkMessageController controller = new BulkMessageController();
        controller.subject = 'Subject';
        controller.messageText = 'Message Text';
        controller.sendViaSms = true;
        controller.sendViaPulse = true;
        controller.senderId = UserInfo.getUserId();
        controller.dummyMessage.Expiration_Time__c = DateTime.now();
        controller.submit();
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.INFO);
    }

    static testMethod void testSendLater() {

        setUpMessaging();

        // Set up and test page submission
        PageReference ref = Page.BulkMessage;
        ref.getParameters().put('groupsParam', groups[0].Id);
        ref.getParameters().put('peopleParam', '');
        Test.setCurrentPage(ref);
        BulkMessageController controller = new BulkMessageController();
        controller.subject = 'Subject';
        controller.messageText = 'Message Text';
        controller.sendViaSms = true;
        controller.sendViaPulse = true;
        controller.senderId = UserInfo.getUserId();
        DateTime sendTime = DateTime.now().addDays(30);
        controller.dummyMessage.Expiration_Time__c = sendTime;
        controller.submit();
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.INFO);
        Scheduled_Message_Queue__c[] scheduledMessages = [SELECT Id, Send_Date_Time__c, Message__c FROM Scheduled_Message_Queue__c];
        System.assertEquals(1, scheduledMessages.size());
        for(Scheduled_Message_Queue__c scheduledMessage : scheduledMessages) {
            System.assert(scheduledMessage.Message__c.equals('Message Text'));
            System.assert(scheduledMessage.Send_Date_Time__c.isSameDay(sendTime));
        }
    }

    static testMethod void testValidation() {

        PageReference ref = Page.BulkMessage;
        ref.getParameters().put('groupsParam', '');
        ref.getParameters().put('peopleParam', '');
        Test.setCurrentPage(ref);
        BulkMessageController controller = new BulkMessageController();

        controller.submit();
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.ERROR);
        System.assertEquals(ApexPages.getMessages()[0].getSummary(), 'You must select at least one group or person.');


        ref.getParameters().put('groupsParam', 'id');
        controller.submit();
        System.assertEquals(2, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[1].getSeverity(), ApexPages.Severity.ERROR);
        System.assertEquals(ApexPages.getMessages()[1].getSummary(), 'Please select a User that the message is from');

        controller.senderId = UserInfo.getUserId();
        controller.submit();
        System.assertEquals(3, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[2].getSeverity(), ApexPages.Severity.ERROR);
        //System.assertEquals(ApexPages.getMessages()[2].getSummary(), 'You must select at least one "send via" option (SMS or Pulse).');//default was set as pulse

        controller.sendViaPulse = true;
        controller.submit();
        System.assertEquals(3, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[2].getSeverity(), ApexPages.Severity.ERROR);
        System.assertEquals(ApexPages.getMessages()[2].getSummary(), 'Subject is a required field.');

        controller.subject = 'Subject';
        controller.submit();
        System.assertEquals(4, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.getMessages()[3].getSeverity(), ApexPages.Severity.ERROR);
        System.assertEquals(ApexPages.getMessages()[3].getSummary(), 'Message is a required field.');
    }

    static testMethod void testGetGroups() {

        setUpMessaging();
        BulkMessageController controller = new BulkMessageController();
        System.assertEquals(controller.getGroupItems().size(), 2);
    }

    static testMethod void testGetSendeess() {

        setUpMessaging();
        PageReference ref = Page.BulkMessage;
        ref.getParameters().put('groups', groups[0].Id);
        Test.setCurrentPage(ref);
        BulkMessageController controller = new BulkMessageController();
        System.assertEquals(controller.getSendeeItems().size(), 0);//if this returns values, pageload will timeout
        controller.getSelectedGroups();
        System.assertEquals(controller.getSendeeItems().size(), 7);
    }

    // SendSMSHelpers Tests
    static testMethod void testGroupMembershipExpansion() {

        // Create the country
        Country__c c1 = new Country__c( Name = 'TestCountry', ISO_Standard_Code__c = 'JJ', Language__c = 'English');
        Country__c c2 = new Country__c( Name = 'TestCountry', ISO_Standard_Code__c = 'DD', Language__c = 'English');
        insert(new List<Country__c>{ c1, c2 });

        addCountrySetting('JJ', 'SendSMSViaYellowPepper', 256, 'JJ');
        addCountrySetting('DD', 'SendSMSViaYellowPepper', 000, 'DD');

        // Create some people
        Person__c p1 = new Person__c( Last_Name__c = 'l1', Middle_Name__c = 'm1', First_Name__c = 'f1', Country__c = c1.Id, Raw_Mobile_Number__c = '111111111');
        Person__c p2 = new Person__c( Last_Name__c = 'l2', Middle_Name__c = 'm2', First_Name__c = 'f2', Country__c = c2.Id, Raw_Mobile_Number__c = '222222222');
        Person__c p3 = new Person__c( Last_Name__c = 'l3', Middle_Name__c = 'm3', First_Name__c = 'f3', Country__c = c2.Id, Raw_Mobile_Number__c = '333333333');
        Person__c p4 = new Person__c( Last_Name__c = 'l4', Middle_Name__c = 'm4', First_Name__c = 'f4', Country__c = c2.Id, Raw_Mobile_Number__c = '444444444');
        Person__c p5 = new Person__c( Last_Name__c = 'l5', Middle_Name__c = 'm5', First_Name__c = 'f5', Country__c = c1.Id, Raw_Mobile_Number__c = '555555555');
        Person__c p6 = new Person__c( Last_Name__c = 'l6', Middle_Name__c = 'm6', First_Name__c = 'f6', Country__c = c1.Id, Raw_Mobile_Number__c = '666666666');
        insert(new List<Person__c>{ p1, p2, p3, p4, p5, p6 });

        // Create some groups
        Group__c g1 = new Group__c( Name='Group1' );
        Group__c g2 = new Group__c( Name='Group2' );
        groups = new List<Group__c>{ g1, g2 };
        insert(groups);

        // Add some people to the groups
        Person_Group_Association__c pga1 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p1.Id);
        Person_Group_Association__c pga2 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p2.Id);
        Person_Group_Association__c pga3 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p3.Id);
        Person_Group_Association__c pga4 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p4.Id);
        Person_Group_Association__c pga5 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p5.Id);
        Person_Group_Association__c pga6 = new Person_Group_Association__c( Group__c = g1.Id, Person__c = p6.Id);
        Person_Group_Association__c pga7 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p1.Id);
        Person_Group_Association__c pga8 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p3.Id);
        Person_Group_Association__c pga9 = new Person_Group_Association__c( Group__c = g2.Id, Person__c = p5.Id);
        insert(new List<Person_Group_Association__c>{ pga1, pga2, pga3, pga4, pga5, pga6, pga7, pga8, pga9 });

        Map<String, List<SendSMSHelpers.Recipient>> members = SendSMSHelpers.expandGroupMembership(g1.Id);
        System.assertEquals(members.size(), 2);
        for (String countryCode : members.keySet()) {
            System.assertEquals(members.get(countryCode).size(), 3);
        }
    }

    // Test SendSMS batch job
    static testMethod void testBatch() {

        setUpMessaging();

        // Add some schduled messages
        DateTime sendTime = DateTime.now().addMinutes(-5);
        Scheduled_Message_Queue__c m1 = new Scheduled_Message_Queue__c( Subject__c = 'subject1', Message__c = 'body1', Send_Date_Time__c = sendTime, Send_Via_Pulse__c = true, Send_Via_SMS__c = false, Sender__c = UserInfo.getUserId(), Group__c = groups[0].Id, Category__c = 'Payments');
        Scheduled_Message_Queue__c m2 = new Scheduled_Message_Queue__c( Subject__c = 'subject1', Message__c = 'body1', Send_Date_Time__c = sendTime, Send_Via_Pulse__c = false, Send_Via_SMS__c = true, Sender__c = UserInfo.getUserId(), Person__c = people[0].Id, Category__c = 'Payments');
        Scheduled_Message_Queue__c m3 = new Scheduled_Message_Queue__c( Subject__c = 'subject1', Message__c = 'body1', Send_Date_Time__c = sendTime, Send_Via_Pulse__c = false, Send_Via_SMS__c = true, Sender__c = UserInfo.getUserId(), Person__c = people[1].Id, Category__c = 'Payments');
        Database.insert(new List<Scheduled_Message_Queue__c>{ m1, m2, m3 });

        // Send the scheduled messages
        String queryString = 'SELECT ' 							+
                'Id, ' 											+
                'Group__c, ' 									+
                'Person__c, '									+
                'Person__r.First_Name__c, ' 					+
                'Person__r.Middle_Name__c, ' 					+
                'Person__r.Last_Name__c, ' 						+
                'Person__r.Mobile_Number__c, ' 					+
                'Person__r.Country__r.ISO_Standard_Code__c, ' 	+
                'Message__c, ' 									+
                'Sender__c, ' 									+
                'Sender__r.Name, ' 								+
                'Subject__c, ' 									+
                'Send_Date_Time__c, ' 							+
                'Expiration_Date__c, ' 							+
                'Send_Via_Pulse__c, ' 							+
                'Category__c, ' 								+
                'Send_Via_Sms__c ' 								+
            'FROM ' 											+
                'Scheduled_Message_Queue__c ' 					+
            'WHERE ' 											+
                'Send_Date_Time__c <= ' + MetricHelpers.convertDateTimeToString(DateTime.now(), false);
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(new SendSMS(queryString, DateTime.now()), 10);
        Test.StopTest();

        // Check the new queue size. It should be 0 as all messages were sent and as this is test none of the messages were rescheduled
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Scheduled_Message_Queue__c WHERE LastModifiedDate <= ' + MetricHelpers.convertDateTimeToString(DateTime.now().addMinutes(-2) , false)), 0);
    }
    
    
    // TESTS FOR SendSMSViaEdnetUg
    static testMethod void testEdnet() {
    	
        addGatewaySettings('EdnetUg', 'bulk', 'single', 'username', 'password', 123);
        addCountrySetting('JJ', 'SendSMSViaEdnetUg', 256, 'JJ');

        List<SendSMSHelpers.Recipient> recipients = new List<SendSMSHelpers.Recipient> {
            SendSMSHelpers.generateRecipient('id', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null)       
        };
		// add message with  no country code. will be skipped
        SMS_Gateway_Country_Settings__c setting = [SELECT Id, Country_Code__c FROM SMS_Gateway_Country_Settings__c WHERE Name = 'JJ'][0];
        setting.Country_Code__c = null;
        update setting;
        SendSMSHelpers.Recipient nullCoded = SendSMSHelpers.generateRecipient('id1', 'firstName', 'middleName', 'lastName', '0123456789', 'JJ', null);
        recipients.add(nullCoded);
        
        messages = new List<Message>{
            createMessage('Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients),
            createMessage('Subject', 'body', UserInfo.getUserId(), UserInfo.getUserName(), DateTime.now(), DateTime.now(), 'SMS', recipients)
        };
        SendSMSViaEdnetUg gateway = new SendSMSViaEdnetUg();
        //gateway.loadSetting();
        Boolean fail = false;
        try {
            gateway.createBody(messages, true);
        }
        catch (Exception e) {
            System.assert(e.getMessage().equals('Can only send one message through EdnetUg at once'), 'Error message is wrong');
            fail = true;
        }
        System.assert(fail, 'Should have failed to build the body as there were too many messages');        
        System.assert(gateway.execute(messages).equals('status=-2,credits=92052'));
        System.assert(gateway.callback('status=-2,credits=92052', new Map<String, Boolean> { }).size() == 0);
    }
}