public class TestSupportTrigger {

    static testMethod void testSupportTrigger() {
    	
        Case testCase = new Case();

        Person__c person = new Person__c();
        person.First_Name__c = 'test';        
        database.insert(person);

		Integer beforeMessageCount = [SELECT COUNT() FROM Message__c WHERE Recipient__c =:person.id];

        testCase.Person__c = person.id;
        testCase.Subject = 'test';
        database.insert(testCase);

        testCase.Response__c = 'test response';
        database.update(testCase);       
                
		Integer afterMessageCount = [SELECT COUNT() FROM Message__c WHERE Recipient__c =:person.id];
        System.assert(afterMessageCount - beforeMessageCount == 1);
    }
}