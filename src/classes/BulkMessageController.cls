public with sharing class BulkMessageController {

    public List<String> groups { get; set; }
    public List<String> people { get; set; }
    public List<String> sendees { get; set; }
    private Map<String, String> variableMap = new Map<String, String>();

    public String subject { get; set; }
    public String messageText { get; set; }
    public Boolean sendViaSms { get; set; }
    public Boolean sendViaPulse { get; set; }
    public String senderId { get; set; }
<<<<<<< HEAD
=======
    public String category { get; set; }
>>>>>>> origin/ci

    // We need this message field so that we can create a DatePicker on the VF
    // page using the apex:inputField control (it will only create a DatePicker
    // if it is bound to an sObject field)
    public Message__c dummyMessage { get; set; }
    public Message__c dummyMessage2 { get; set; }

    // Constructor for the controller
    public BulkMessageController() {
        this.dummyMessage = new Message__c();
        this.dummyMessage2 = new Message__c();
        this.sendViaSms = false;
<<<<<<< HEAD
        this.sendViaPulse = false;
=======
        this.sendViaPulse = true;//default true
>>>>>>> origin/ci
        this.groups = new List<String>();
        this.people = new List<String>();
        this.sendees = new List<String>();
    }

    public PageReference getSelectedGroups() {
        this.groups = Apexpages.currentPage().getParameters().get('groups').split(',');
        return null;
    }

<<<<<<< HEAD
=======
    public List<SelectOption> categoryType { 
    	get {
	        List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('', ''));
			for(Schema.PicklistEntry item : Case.Category__c.getDescribe().getPicklistValues()) {
				options.add(new SelectOption(item.getLabel(), item.getLabel()));
			}
	        return options;
    	}
	}
	
>>>>>>> origin/ci
    /**
     * Submit the message. This will either send it immediately or schedule it for sending at a later date
     * A Scheduled_Message_Queue__c object can link to a person or a group. If it is linked to a group
     * the group is expanded to get all the recipients in that group at the point of sending. This means
     * that anyone added to the group between scheduling and sending will also get the message
     */
    public PageReference submit() {

        String groupParam = Apexpages.currentPage().getParameters().get('groupsParam');
        if (groupParam != null && !groupParam.equals('')) {
            this.groups = groupParam.split(',');
        }
        String peopleParam = Apexpages.currentPage().getParameters().get('peopleParam');
        if (groupParam != null && !peopleParam.equals('')) {
            this.sendees = peopleParam.split(',');
        }

        if (validateFields()) {

            // Get the user that the message is from
            User sender = [
                SELECT
                    Id,
                    Name
                FROM
                    User
                WHERE
                    id = :this.senderId
                LIMIT 1];

            List<Id> recipients = new List<Id>();
            List<Id> groupsToSendTo = new List<Id>();
            List<Id> groupRecipients = new List<Id>();

            // Message is being sent to people. Overrides group send
            if (sendees.size() > 0) {
                for (String personId : this.sendees) {

                    // Sending the message to all members of a group
                    if (personId.startsWith('g_')) {
                        groupsToSendTo.add(personId.replace('g_',''));
                    }
                    else {
                        recipients.add(personId);
                    }
                }
            }
            else {
                if (groups.size() > 0) {
                    for (String groupId : this.groups) {
                        groupsToSendTo.add(groupId);
                    }
                }
            }

            // Add the group recipients
            groupRecipients.addAll(SendSMSHelpers.getGroupMemberIds(groupsToSendTo));

            Boolean sendNow = this.dummyMessage.Expiration_Time__c <= datetime.now();
            Boolean rescheduled = false;
            System.debug(LoggingLevel.INFO, 'SEND NOW = ' + sendNow);
            if (sendNow) {

                // Send the messages immediately through the relevant gateways
                recipients.addAll(groupRecipients);
                rescheduled = SendSmsHelpers.sendThroughGateways(
                    SendSmsHelpers.generateMessage(
<<<<<<< HEAD
                        recipients, this.subject, this.messageText, sender.Id, sender.Name, this.sendViaPulse, this.sendViaSms, this.dummyMessage.Expiration_Time__c, this.dummyMessage2.Expiration_Time__c
=======
                        recipients, this.subject, this.messageText, sender.Id, sender.Name, this.sendViaPulse, this.sendViaSms, this.dummyMessage.Expiration_Time__c, this.dummyMessage2.Expiration_Time__c, category 
>>>>>>> origin/ci
                    ), true
                );
            }
            else {

                // Add the messages to the queue
                System.debug(LoggingLevel.INFO, 'SETTING THE SAVEPOINT');
                Savepoint sp = Database.setSavepoint();
                List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
                for (Id recipient : recipients) {
                    Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                       Subject__c = this.subject,
                       Message__c = this.messageText,
                       Sender__c = sender.Id,
                       Expiration_Date__c = this.dummyMessage2.Expiration_Time__c,
                       Send_Via_Pulse__c = this.sendViaPulse,
                       Send_Via_SMS__c = this.sendViaSms,
                       Send_Date_Time__c = this.dummyMessage.Expiration_Time__c,
<<<<<<< HEAD
                       Person__c = recipient
=======
                       Person__c = recipient,
                       Category__c = category
>>>>>>> origin/ci
                    );
                    messageQueue.add(message);
                }
                for (Id g : groupsToSendTo) {
                    Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                       Subject__c = this.subject,
                       Message__c = this.messageText,
                       Sender__c = sender.Id,
                       Expiration_Date__c = this.dummyMessage2.Expiration_Time__c,
                       Send_Via_Pulse__c = this.sendViaPulse,
                       Send_Via_SMS__c = this.sendViaSms,
                       Send_Date_Time__c = this.dummyMessage.Expiration_Time__c,
<<<<<<< HEAD
                       Group__c = g
=======
                       Group__c = g,
                       Category__c = category
>>>>>>> origin/ci
                    );
                    messageQueue.add(message);
                }

                // Save the scheduled messsages. Parse the SaveResults and roll back all the new messages if there is a failure.
                // User will have to reschedule the messages them selves
                Database.SaveResult[] saveMessageResults = Database.insert(messageQueue, false);
                for (Database.SaveResult result : saveMessageResults) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug(LoggingLevel.INFO, error.getMessage());
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_FAILED_QUEUE_ADD));
                        Database.rollBack(sp);
                        return null;
                    }
                }
            }
            if (rescheduled) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.BULK_MESSAGE_PAGE_SOME_MESSAGES_SCHEDULED_NOW));
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.BULK_MESSAGE_PAGE_SEND_ANOTHER));
        }
        return null;
    }

    /**
     * Validate the fields sent from the user
     * TODO - Make these checks be client side
     */
    private Boolean validateFields() {

        if (((this.groups.size() == 0) || (this.groups.size() == 1  && this.groups[0] == '')) && ((this.sendees.size() == 0) || (this.sendees.size() == 1 && this.sendees[0] == ''))) {
            System.debug(LoggingLevel.INFO, 'Validation failed as no groups or sendees selected');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_NO_RECIPIENTS));
            return false;
        }
        if (this.senderId == null) {
            System.debug(LoggingLevel.INFO, 'No user selected');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_NO_SENDER));
            return false;
        }
        if (!this.sendViaPulse && !this.sendViaSms) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_NO_SEND_OPTION));
            System.debug(LoggingLevel.INFO, 'Sending method not selected');
            return false;
        }
        if (this.subject == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_SUBJECT_REQUIRED));
            System.debug(LoggingLevel.INFO, 'No subject entered');
            return false;
        }
        if (this.messageText == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.BULK_MESSAGE_PAGE_MESSAGE_REQUIRED));
            System.debug(LoggingLevel.INFO, 'No message entered');
            return false;
        }
        return true;
    }

    public List<SelectOption> getGroupItems() {

        Group__c[] groups = [SELECT Id, Name from Group__c Where Membership_Count__c > 1 ORDER BY name limit 1000];
        List<SelectOption> options = new List<SelectOption>();
        for (Group__c currentGroup : groups) {
            options.add(new SelectOption(currentGroup.id, currentGroup.name));
        }
        return options;
    }

    public List<SelectOption> getSendeeItems() {

        List<SelectOption> options = new List<SelectOption>();
        if (groups.size() > 0 && groups.size() < 1000) {

            // Add the "All group member" items
            // Need to get group names, sorted alphabetically
            for (Group__c[] groups : [
                    SELECT
                        Id,
                        Name
                    FROM
                        Group__c
                    WHERE
                        Id IN :groups
            ]) {
                for (Group__c groupMember : groups) {
                    options.add(new SelectOption('g_' + groupMember.Id, '[All '+ groupMember.Name +' Members]'));
                }
            }

            // This needs to be an aggregate query so as to only get distinct people
<<<<<<< HEAD
            String selectClause =
                'SELECT '+
                'Person__c, '+
                'Person__r.First_Name__c firstname, '+
                'Person__r.Middle_Name__c middlename, '+
                'Person__r.Last_Name__c lastname '+
=======
            // Limit of records set to less. User should user groups to avoid dealing with alot of data
            String selectClause =
                'SELECT '+
                'Person__c, '+
                'Person__r.First_Name__c, '+
                'Person__r.Middle_Name__c, '+
                'Person__r.Last_Name__c '+
>>>>>>> origin/ci
            'FROM ' +
                'Person_Group_Association__c ' +
            'WHERE ' +
                 'Group__c IN (' + MetricHelpers.generateCommaSeperatedString(groups,true) + ') '  +
<<<<<<< HEAD
            'GROUP BY ' + 
                'Person__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Middle_Name__c, ' +
                'Person__r.Last_Name__c ' +
            'ORDER BY ' +
                'Person__r.First_Name__c ' +
            'LIMIT ' + (1000 - groups.size());
            for (AggregateResult[] people : database.query(SelectClause)) {
                for (AggregateResult person : people) {
                    String fullName = (String)person.get('firstname');
                    if (person.get('middlename') != null) {
                       fullName += ' ' + (String)person.get('middlename');
                    }
                    if (person.get('lastname') != null) {
                       fullName += ' ' + (String)person.get('lastname');
                    }
                    options.add(new SelectOption((String)person.get('Person__c'), fullName));
=======
            'ORDER BY ' +
                'Person__r.First_Name__c ' +
            'LIMIT 1000';
            for (Person_Group_Association__c[] people : database.query(SelectClause)) {
                for (Person_Group_Association__c person : people) {
                    String fullName = person.Person__r.First_Name__c;
                    if (person.Person__r.Middle_Name__c != null) {
                       fullName += ' ' + person.Person__r.Middle_Name__c;
                    }
                    if (person.Person__r.Last_Name__c != null) {
                       fullName += ' ' + person.Person__r.Last_Name__c;
                    }
                    options.add(new SelectOption(String.valueOf(person.Person__r.Id), fullName));
>>>>>>> origin/ci
                }
            }
        }
        else {
<<<<<<< HEAD
            for (Person__c[] people : [
=======
            // degailt loading of people makes pageload time out
            /*for (Person__c[] people : [
>>>>>>> origin/ci
                    SELECT
                        Id,
                        First_Name__c,
                        Middle_Name__c,
                        Last_Name__c
                    FROM 
                        Person__c
                    ORDER BY
                        First_Name__c
<<<<<<< HEAD
                    LIMIT 1000
=======
                    LIMIT 100
>>>>>>> origin/ci
            ]) {
                for (Person__c person : people) {
                    String fullName = person.First_Name__c;
                    if (person.Middle_Name__c != null) {
                        fullName += ' ' + person.Middle_Name__c;
                    }
                    if (person.Last_Name__c != null) {
                        fullName += ' ' + person.Last_Name__c;
                    }
                    options.add(new SelectOption(person.Id, fullName));
                }
<<<<<<< HEAD
            }
=======
            }*/
>>>>>>> origin/ci
        }
        return options;
    }

    public List<SelectOption> getUserItems() {

		String name = UserInfo.getUserId();
        List<SelectOption> options = new List<SelectOption>();
        for (User[] currentUsers :  [SELECT Id, Name FROM User WHERE IsActive = true ORDER BY Name ASC]) {
            for (User currentUser : currentUsers) {
                options.add(new SelectOption(currentUser.id, currentUser.name));
                if(name.equals(currentUser.id)) {
                	senderId = currentUser.id;
                }
            }
        }
        return options;
    }
}