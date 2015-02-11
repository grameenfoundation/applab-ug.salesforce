@isTest
public class TestCreateMonthlyFarmerVisit {

    @isTest
    static void testCreateVisit() {
        
        // Create an Interviewer Contact, Person,  as well as an interviewee Person
        Contact contact = new Contact(FirstName = 'Brown', LastName = 'Amooti');
        insert contact;
        Person__c interviewer = new Person__c();
        interviewer.First_Name__c = 'Brown';
        interviewer.Last_Name__c = 'Amooti';
        interviewer.Contact__c = contact.Id;
        insert interviewer;
        Person__c interviewee = new Person__c();
        interviewee.First_Name__c = 'White';
        interviewee.Last_Name__c = 'Akiiki';
        insert interviewee;
        
        // Create a Search Log
        Search_Log__c searchLog = new Search_Log__c();
        searchLog.Interviewer_Contact__c = contact.id;
        searchLog.Interviewee__c = interviewee.id;
        searchLog.Interviewer__c = interviewer.Id;
        insert searchLog;
        
        test.startTest();
        Date thisDate = date.today().addDays(1);
        CreateMonthlyFarmerVisit.createVisit(thisDate);
        List<C3P0_Farmer_Visit__c> visits = [Select Id from C3P0_Farmer_Visit__c];
        System.assertEquals(1, visits.size());
        test.stopTest();
    }
}