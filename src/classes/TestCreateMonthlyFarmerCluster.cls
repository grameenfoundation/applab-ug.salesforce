@isTest
public class TestCreateMonthlyFarmerCluster {

    @isTest static void testCreateVisit() {
        Contact ckwContact = new Contact(FirstName='Bob', LastName='Zaabu');
        insert ckwContact;
        
        // Create a Banana Farmer, along with its parent objects
        Country__c country = new Country__c(Name='Uganda', ISO_Standard_Code__c='UG');
        insert country;
        Person__c person = new Person__c();
        person.First_Name__c = 'Suubi';
        person.Last_Name__c = 'Ggoonya';
        insert person;
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = person.id;
        insert focusFarmer;
        Banana_Farmer__c bananaFarmer = new Banana_Farmer__c();
        bananaFarmer.Focus_Farmer__c = focusFarmer.Id;
        bananaFarmer.Registered_By__c = ckwContact.Id;
        insert bananaFarmer;
        
        // Create a Banana Cluster Meeting
        Banana_Cluster_Meeting__c bananaCluster = new Banana_Cluster_Meeting__c();
        bananaCluster.Banana_Farmer__c = bananaFarmer.Id;
        bananaCluster.Contact__c = ckwContact.Id;
        bananaCluster.GPS__Latitude__s = 0.00000;
        bananaCluster.GPS__Longitude__s = 0.00000;
        bananaCluster.What_GAPs_were_discussed_at_the_meeting__c = 'GAP 1: Soil fertility management';
        bananaCluster.Was_market_information_provided_today__c = 'Yes';
        bananaCluster.Was_weather_information_provided_today__c = 'Yes';
        bananaCluster.Meeting_Date__c = date.today();
        insert bananaCluster;
        
        test.startTest();
        Date thisDate = date.today().addDays(1);
        CreateMonthlyFarmerCluster.createVisit(thisDate);
        List<Farmer_Cluster_Meeting__c> visits = [Select Id from Farmer_Cluster_Meeting__c];
        System.assertEquals(1, visits.size());
        test.stopTest();
    }
}