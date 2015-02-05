@isTest
public class TestPopulatePersonFieldTrigger {

    @isTest static void testTrigger() {
        Contact contact = new Contact(FirstName = 'Ridley', LastName = 'Scott');
        insert contact;
        Person__c person = new Person__c(First_Name__c = 'Ridley', Gender__c = 'Male', Contact__c = contact.Id);
        insert person;
        Test.startTest();
        C3P0_CKW__c ckw = new C3P0_CKW__c();
        ckw.Contact__c = contact.Id;
        ckw.Gender__c = 'Male';
        ckw.Highest_Level_of_Education__c = 'None';
        ckw.Age__c = 30;
        insert ckw;
        Test.stopTest();
        ckw = [Select Person__c from C3P0_CKW__c where Id =: ckw.Id];
        System.assertEquals(person.Id, ckw.Person__c);
    }
}