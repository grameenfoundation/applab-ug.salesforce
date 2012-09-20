trigger SendEmailResponse on Case (after Update) {

    for(case c: Trigger.new){
        if (c.Origin == 'Email'){
            Messaging.reserveSingleEmailCapacity(2);
        
            if (c.Response__c != null){
        
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
                String[] toAddresses = new String[]{c.SuppliedEmail};
                String[] ccAddresses = new String[]{'info@applab.org'};
            
                mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccaddresses);
            
                //address to which recipients reply
                mail.setReplyTo('info@applab.org');
                //name displayed to the user as the person they are interacting with
                mail.setSenderDisplayName('Grameen Foundation');
                //The subject of the email being sent
                mail.setSubject(c.Subject);
                //Email content
                mail.setPlainTextBody(c.Response__c);
            
                //send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            
            }else{
        
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
                String[] toAddresses = new String[]{'info@applab.org'};
                String[] ccAddresses = new String[]{'enemilyn@gmail.com'};
            
                mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccaddresses);
            
                //address to which recipients reply
                mail.setReplyTo('info@applab.org');
                //name displayed to the user as the person they are interacting with
                mail.setSenderDisplayName('Grameen Foundation');
                //The subject of the email being sent
                mail.setSubject('Case: '+c.CaseNumber+ ' on '+ c.Subject);
                //Email content
                mail.setPlainTextBody('I have made changes to case '+c.CaseNumber+'.<br> Please go check.');
           
                //send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    }
}