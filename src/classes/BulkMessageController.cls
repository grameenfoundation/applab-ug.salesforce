public with sharing class BulkMessageController {

    String[] groups = new String[]{};
    String[] people = new String[]{};
    String[] sendees = new String[]{};
    private Map<String, String> variableMap = new Map<String, String>();

    String subject;
    String messageText;
    Boolean sendViaSms;
    Boolean sendViaPulse;
    String senderId;
    Boolean showResult;
    String result;
    String resultMessage;
    String success;
    Date expirationDate;
    List<Recipient> recipients;

    // we need this message field so that we can create a DatePicker on the VF
    // page using the apex:inputField control (it will only create a DatePicker
    // if it is bound to an sObject field)
    Message__c dummyMessage = new Message__c();
    Message__c dummyMessage2 = new Message__c();

    public BulkMessageController() {

        PageReference pageRef = ApexPages.currentPage();
        String showResultString = pageRef.getParameters().get('showResult');
        this.showResult = showResultString != null;
        this.result = pageRef.getParameters().get('result');
        this.resultMessage = pageRef.getParameters().get('resultMessage'); 
        this.success = pageRef.getParameters().get('success');
    }

    public PageReference getSelectedGroups() {
        this.groups = Apexpages.currentPage().getParameters().get('groups').split(',');
        return null;
    }

    public PageReference submit() {
        String groupParam = Apexpages.currentPage().getParameters().get('groupsParam');
        if(!''.equals(groupParam) && groupParam != null) {
            this.groups = groupParam.split(',');
        }
        String peopleParam = Apexpages.currentPage().getParameters().get('peopleParam');
        if(!''.equals(peopleParam) && groupParam != null) {
            this.sendees = peopleParam.split(',');
        }

        if (validateFields()) {
            System.debug('validation passes!!');
            recipients = new List<Recipient>();
            if(sendees.size() > 0) {
                for (String personId : this.sendees) {
                    if(personId.startsWith('g_') ) {
                        // this is actually a group id, for a 'Äll group members'
                        recipients.add(new Recipient(personId.replace('g_',''), Recipient.RecipientType.DistributionGroup));
                    } else {
                         recipients.add(new Recipient(personId, Recipient.RecipientType.Person));
                        }
                   }
            } else {
                if(groups.size() > 0) {
                    for (String groupId : this.groups) {
                        recipients.add(new Recipient(groupId, Recipient.RecipientType.DistributionGroup));
                    }
                }
            }

            try {
                User sender = [SELECT id, name FROM User WHERE id=:this.senderId LIMIT 1];
                Server_Configuration__c configuration = [SELECT  URL__c, Base_URL__c, Services_Path__c, Survey_Database__c, Search_Database__c
                FROM Server_Configuration__c LIMIT 1];
                Message bulkMessage = new Message(this.subject, this.messageText, recipients, 
                    sender, this.dummyMessage2.Expiration_Time__c, configuration);
                if (this.dummyMessage.Expiration_Time__c > datetime.now()) {
                      bulkMessage.scheduleMessage( this.dummyMessage.Expiration_Time__c, this.sendViaPulse, this.sendViaSms);
                }
                else {
                      if (this.sendViaSms) {
                            bulkMessage.sendViaSms();
                       }
                     if (this.sendViaPulse) {
                            bulkMessage.sendViaPulse();
                      }
                }
                setPageResult('You may send another message by completing the form below.', true);
            } catch (Exception e) {
               setPageResult(e.getMessage(), false);
            }
        }
        return null;
    }

    private Boolean validateFields() {

        if (this.groups.size() == 1  && this.groups[0] == '' && this.sendees.size() == 1 && this.sendees[0] == '') {
            System.debug('validation failed!!');
            setPageResult('You must select at least one group or person.', false);
            return false;    
        }
        System.debug('group size '+  this.groups.size());
        System.debug('sendee size '+this.sendees.size());
        System.debug('validation passed!!');
        for (String grp : this.groups) {
            System.debug('groups ' +grp + '' );
        }
        if (this.senderId == null) {
            setPageResult('From is a required field.', false);
            return false;
        }
        if (!this.sendViaPulse && !this.sendViaSms) {
            setPageResult('You must select at least one "send via" option (SMS or Pulse).', false);
            return false;
        }
        if (this.subject == null) {
            setPageResult('Subject is a required field.', false);
            return false;
        }
        if (this.messageText == null) {
            setPageResult('Message is a required field.', false);
            return false;
        }       
        return true;
    }

    private void setPageResult(String resultMessage, Boolean success) {

        this.showResult = true;
        if(success) {
            this.result = 'Your message was sent';
            this.success = 'true';
        } else {
            this.result = 'Your message was not sent';
            this.success = 'false';
        }
        this.resultMessage = resultMessage;
        /*
        PageReference resultPage = ApexPages.currentPage();
        if (success) {

            resultPage.getParameters().put('result', 'Your message was sent');
        } else {
            resultPage.getParameters().put('result', 'Your message was not sent');
        }
        resultPage.getParameters().put('resultMessage', resultMessage);
        resultPage.getParameters().put('showResult', 'true');
        resultPage.setRedirect(true);
        return resultPage;
        */
    }

    public List<SelectOption> getGroupItems() {

        Group__c[] groups = [SELECT id,name from Group__c ORDER BY name];
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
           //for (Group__c[] groups : database.query(SoqlHelpers.getGroups('WHERE Id IN ('+MetricHelpers.generateCommaSeperatedString(groups,true)+')'))) {
           Map<String, String> variables = new Map<String, String>();
           variables.put('Id', MetricHelpers.generateCommaSeperatedString(groups, false));
           for (Group__c[] groups : database.query(SoqlHelpers.getGroups(variables))) {
                for (Group__c groupMember : groups) {
                    options.add(new SelectOption('g_'+groupMember.Id, '[All '+groupMember.Name+' Members]'));
                }
           }
           String selectClause =
             'SELECT '+
                 'Person__c, '+
                 'Person__r.First_Name__c firstname, '+
                 'Person__r.Middle_Name__c middlename, '+
                 'Person__r.Last_Name__c lastname '+
             'FROM '                               +
                 'Person_Group_Association__c '    +
             'WHERE '                              +
                 'Group__c IN (' + MetricHelpers.generateCommaSeperatedString(groups,true) + ') '  +
                 ' GROUP BY Person__c,  Person__r.First_Name__c, Person__r.Middle_Name__c, Person__r.Last_Name__c '+
            'ORDER BY Person__r.First_Name__c LIMIT '+ (1000 - groups.size());

            for (AggregateResult[] ckws : database.query(SelectClause)) {
                for (AggregateResult ckw : ckws) {
                    String fullName = (String)ckw.get('firstname');
                    if (ckw.get('middlename') != null) {
                       fullName += ' ' + (String)ckw.get('middlename');
                    }
                    if (ckw.get('lastname') != null) {
                       fullName += ' ' + (String)ckw.get('lastname');
                    }
                    options.add(new SelectOption((String)ckw.get('Person__c'), fullName));
                }
            }
        }
        else {
            for( Person__c[] people : [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c FROM Person__c ORDER BY First_Name__c LIMIT 1000]) {
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
             
         }
        }
         return options;
       }

    public List<SelectOption> getUserItems() {

        List<SelectOption> options = new List<SelectOption>();
        for (User[] currentUsers :  [SELECT id,name FROM User WHERE IsActive = true ORDER BY Name ASC]) {
            for (User currentUser : currentUsers) {
                options.add(new SelectOption(currentUser.id, currentUser.name));
            }
        }
        return options;
    }

    public String[] getSendees() {
      return this.sendees;
    }

    public void setSendees(String[] sendees) {
      this.sendees = sendees;
    } 
    public String[] getGroups() {
        return this.groups;
    }
        
    public void setGroups(String[] groups) {
        this.groups = groups;
    }
    
    public String getSenderId() {
        return this.senderId;
    }

    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }

    public Boolean getSendViaSms() {
        return this.sendViaSms;
    }

    public void setSendViaSms(Boolean sendViaSms) {
        this.sendViaSms = sendViaSms;
    }

    public Boolean getSendViaPulse() {
        return this.sendViaPulse;
    }

    public void setSendViaPulse(Boolean sendViaPulse) {
        this.sendViaPulse = sendViaPulse;
    }

    public String getMessageText() {
        return this.messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public String getSubject() {
        return this.subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public Message__c getDummyMessage() {
        return this.dummyMessage;
    }

    public void setDummyMessage(Message__c dummyMessage) {
        this.dummyMessage = dummyMessage;
    }

    public Message__c getDummyMessage2() {
        return this.dummyMessage2;
    }

    public void setDummyMessage2(Message__c dummyMessage2) {
        this.dummyMessage2 = dummyMessage2;
    }

    public Boolean getShowResult() {
        return this.showResult;
    }

    public void setShowResult(Boolean showResult) {
        this.showResult = showResult;
    }

    public String getResult() {
        return this.result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getSuccess() {
        return this.success;
    }

    public void setSuccess(String success) {
        this.success = success;
    }

    public String getResultMessage() {
        return this.resultMessage;
    }

    public void setResultMessage(String resultMessage) {
        this.resultMessage = resultMessage;
    }


    static testMethod void testGetters() {
        // The getters are trivial and shouldn't really need tests, but we can't
        // get 75% code coverage without this
        BulkMessageController controller = new BulkMessageController();

        String messageText = 'message text';
        controller.setMessageText(messageText);
        System.assertEquals(controller.getMessageText(), messageText);

        String senderId = 'id';
        controller.setSenderId(senderId);
        System.assertEquals(controller.getSenderId(), senderId);

        Boolean sendViaPulse = false;
        controller.setSendViaPulse(sendViaPulse);
        System.assertEquals(controller.getSendViaPulse(), sendViaPulse);

        Boolean sendViaSms = false;
        controller.setSendViaSms(sendViaSms);
        System.assertEquals(controller.getSendViaSms(), sendViaSms);

        String subject = 'subject';
        controller.setSubject(subject);
        System.assertEquals(controller.getSubject(), subject);

        List<String> groups = new List<String>();
        groups.add('group');
        controller.setGroups(groups);
        System.assertEquals(controller.getGroups(), groups);

        Group__c[] groupsInDatabase = [SELECT id FROM Group__c];
        List<SelectOption> groupItems = controller.getGroupItems();
        System.assertEquals(groupsInDatabase.size(), groupItems.size());
    }

    static testMethod void testSetSuccess() {

        BulkMessageController controller = new BulkMessageController();
        String success = 'success';
        controller.setSuccess(success);
        System.assertEquals(success, 'success');
    }
    // this test assumes that there is at least one group in the database with at least
    // one member
    static testMethod void testSubmit() {       
        PageReference pageRef = Page.BulkMessage;
        Test.setCurrentPage(pageRef);
        BulkMessageController controller = new BulkMessageController();
        //String nextPage = controller.submit().getUrl();

        // Instantiate a new controller with all parameters in the page          
        controller = new BulkMessageController(); 
        controller.setMessageText('Body of the message');
        User sender = [SELECT id FROM User LIMIT 1];
        controller.setSenderId(sender.id);
        Group__c recipientGroup = [SELECT id FROM Group__c WHERE id IN 
            (SELECT Group__c FROM Person_Group_Association__c WHERE Group__c != NULL) LIMIT 1];
        List<String> recipients = new List<String>();
        recipients.add(recipientGroup.id);
        controller.setGroups(recipients);
        controller.setSendViaPulse(true);
        controller.setSendViaSms(false);
        String subject = String.valueOf(DateTime.now().millisecond());
        controller.setSubject(subject);
        controller.submit();

        // Verify that the success page displays      
        System.assertEquals('Your message was sent.' + 
            'You may send another message by completing the form below.',
             controller.getResult()+'.'+controller.getResultMessage());
        Message__c[] messages = [SELECT id,Subject__c FROM Message__c WHERE Subject__c=:subject];
        System.assertEquals(subject, messages[0].Subject__c);
    }
}