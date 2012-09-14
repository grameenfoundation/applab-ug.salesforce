// This trigger sends an email to the creator of a support request when the support
// response changes. It allows us to do away with the clunky workflow that support
// has been using to update a CKW's support case status.
trigger OnSupportResponseChanged on Case (after update) {

    if(Trigger.old[0].Response__c != Trigger.new[0].Response__c){        
        Case supportCase = Trigger.new[0];
        
        String subject = 'Case ' + supportCase.CaseNumber;
        if (supportCase.Subject != null) {
            subject += ': ' + supportCase.Subject;
        }
        String body = supportCase.Response__c;
        List<Recipient> recipients = new List<Recipient>();
         
        recipients.Add(new Recipient(supportCase.Person__c, Recipient.RecipientType.Person));
        User sender = [SELECT id FROM User WHERE name='ckw support' LIMIT 1];
        DateTime expirationDate = Date.today().addDays(7);
        
        Server_Configuration__c configuration = [SELECT URL__c, Survey_Database__c, Search_Database__c
            FROM Server_Configuration__c LIMIT 1];

        Message supportMessage = new Message(subject, body, recipients, sender, expirationDate, configuration);
        supportMessage.sendViaPulse();
    }
}