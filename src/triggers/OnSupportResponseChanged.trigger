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

        User sender = [SELECT Id, Name FROM User WHERE Name = 'ckw support' LIMIT 1];
        DateTime expirationDate = Date.today().addDays(7);

        // Send the message through the pulse gateway. This will reschedule if there is a failure
        SendSmsHelpers.sendThroughGateways(
            SendSmsHelpers.generateMessage(
                new List<Id>{ supportCase.Person__c }, subject, body, sender.Id, sender.Name, true, false, DateTime.now(), expirationDate, ''
            ), true
        );
    }
}
