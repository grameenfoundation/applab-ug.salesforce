/**
 *  Helper file to deal wil email sending
 *
 *  Copyright (c) 2011 AppLab, Grameen Foundation
 */

public with sharing class EmailHelpers {

    /**
     *  Create an individual email to a set of people
     *
     *  @param emailAddress - A list of the email address the email is to be sent to
     *  @param subject      - The subject for the email
     *  @param message      - The message that is to be sent
     */
    public static Messaging.SingleEmailMessage createEmail(
            List<String> emailAddresses,
            String subject,
            String message
    ) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(message);
        return mail;
    }

    /**
     *  Create an individual html email to a set of people
     *
     *  @param emailAddress - A list of the email address the email is to be sent to
     *  @param subject      - The subject for the email
     *  @param message      - The message that is to be sent
     */
    public static Messaging.SingleEmailMessage createHtmlEmail(
            List<String> emailAddresses,
            String subject,
            String message
    ) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(message);
        return mail;
    }
    /**
     *  Send a bunch of emails and parse the errors
     *
     *  @param email - A list of the emails to be sent
     *
     *  @return - A tuple list that states success and any error
     */
    public static List<String> sendEmails(List<Messaging.SingleEmailMessage> emails) {

        String success = 'true';
        String message = '';

        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emails);
        for (Messaging.SendEmailResult result : emailResults) {
            if (!result.isSuccess()) {
                success = 'false';
                for (Messaging.SendEmailError error : result.getErrors()) {
                    message = addErrorMessage(message, error.getMessage());
                }
            }
        }

        return new String[] { success, message };
    }

    /**
     *  Construct an error message
     *
     *  @param message  - The existing message to be added to
     *  @param errorMsg - The error message to be added to
     *
     *  @return - The new error message
     */
    private static String addErrorMessage(String message, String errorMsg) {

        if (message.equals('')) {
            return errorMsg;
        }
        return message + '\n' + errorMsg;
    }

    /**
     *  Get the email address for the techgroup
     *
     *  @return - The email address for the techGroup
     */
    public static String getTechEmailAddress() {
        return 'techgroup@applab.org';
    }

    // Test methods are below
    static testMethod void testGetTechEmail() {
        System.assert(getTechEmailAddress().equals('techgroup@applab.org'));
    }

    static testMethod void testErrorMessage() {

        String message = '';
        message = addErrorMessage(message, 'THIS');
        System.assert(message.equals('THIS'));
        message = addErrorMessage(message, 'THAT');
        System.assert(message.contains('THAT'));
        
    }

    static testMethod void testSendEmail() {

        String[] toAddress = new String[]{};
        toAddress.add(EmailHelpers.getTechEmailAddress());
        String subject = 'Test Email';
        String message = 'Test Email';
        Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[] { EmailHelpers.createEmail(toAddress, subject, message) };
        EmailHelpers.sendEmails(mail);
    }
}