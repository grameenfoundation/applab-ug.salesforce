@isTest
public class TestPopulateContactLookup {

    @isTest static void testPopulateContactLookup() {
        Contact ckwContact = new Contact(FirstName='ckw', LastName='ckw');
        insert ckwContact;
        Contact foContact = new Contact(FirstName='fo', LastName='fo');
        insert foContact;
        CKW_Cluster_Meeting__c clusterMeeting = new CKW_Cluster_Meeting__c();
        clusterMeeting.CKW_Full_Name__c = 'ckw ckw';
        clusterMeeting.FO__c = foContact.Id;
        clusterMeeting.Any_Banana_GAPS_discussed__c = 'No';
        clusterMeeting.Any_Coffee_GAPS_discussed__c = 'No';
        clusterMeeting.Any_Maize_GAPS_discussed__c = 'No';
        clusterMeeting.Market_information_discussed__c = 'Yes';
        clusterMeeting.Weather_information_discussed__c = 'No';
        clusterMeeting.Meeting_date__c = date.today();
        insert clusterMeeting;
        Test.startTest();
        clusterMeeting = [Select CKW__c from CKW_Cluster_Meeting__c where Id =:clusterMeeting.Id];
        Test.stopTest();
        System.assertEquals(ckwContact.Id, clusterMeeting.CKW__c);
    }
}