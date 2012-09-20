@isTest
public class SendEmailResponseTest {
 
    public static void sendMail() {
        
        string message = 'This is a message.';
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'some@email.com'};
        String[] ccAddresses = new String[] {'some1@email.com'};
            
        mail.setToAddresses(toAddresses);
        mail.setToAddresses(ccAddresses);
 
        mail.setReplyTo('info@applab.org');
        mail.setSenderDisplayName('Grameen foundation');
        mail.setSubject('My Subject');
        
        mail.setBccSender(false);
        mail.setUseSignature(true);
        mail.setPlainTextBody(message);
        mail.setHtmlBody(message);
 
        // Send the email
        Test.startTest();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Test.stopTest();
    }    
}