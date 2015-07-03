@isTest
public class TestCreateMonthlyCkwVisit {

    @isTest static void testCreateVisit() {
        Contact focontact = new Contact(FirstName = 'Brown', LastName = 'Amooti');
        insert focontact;
        Contact ckwcontact = new Contact(FirstName = 'White', LastName = 'Araali');
        insert ckwcontact;
        
        CKW_Cluster_Meeting__c meeting = new CKW_Cluster_Meeting__c();
        meeting.FO__c = focontact.id;
        meeting.CKW_Full_Name__c= 'White Araali';
        meeting.Meeting_date__c = date.today().addDays(-1);
        meeting.Any_Banana_GAPS_discussed__c = 'No';
        meeting.Any_Banana_GAPS_discussed__c = 'No';
        meeting.Any_Banana_GAPS_discussed__c = 'No';
        meeting.Market_information_discussed__c = 'Yes';
        meeting.Weather_information_discussed__c = 'Yes';
        insert meeting;
        
        test.startTest();
        Date thisDate = date.today().addDays(1);
        CreateMonthlyCkwVisit.createVisit(thisDate);
        List<Monthly_CKW_Visit__c> visits = [Select Id from Monthly_CKW_Visit__c];
        System.assertEquals(1, visits.size());
        test.stopTest();
    }
}