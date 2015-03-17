@isTest
public class TestAssignDairyFarmersToContact {

    @isTest static void testAssignSingleDairyFarmer() {
        Dairy_Cattle_Farmer__c dairyFarmer = createSingleFarmer();
        insert dairyFarmer;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Dairy_Cattle_Farmer__c'
                                                              and
                                                                gfsurveys__Contact__c =:dairyFarmer.Registered_By__c];
        System.assertEquals(dairyFarmer.Id, scas[0].gfsurveys__AssociatedIds__c);
        Test.stopTest();
    }
    
    @isTest static void testAssignMultipleDairyFarmers() {
        List<Dairy_Cattle_Farmer__c> dairyFarmers = createMultipleFarmers();
        insert dairyFarmers;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Dairy_Cattle_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }

    @isTest static void testAssignMultipleFarmersOneAtaTime() {
        List<Dairy_Cattle_Farmer__c> dairyFarmers = createMultipleFarmers();
        for (Dairy_Cattle_Farmer__c dairyFarmer : dairyFarmers) {
            insert dairyFarmer;
        }
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Dairy_Cattle_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }

    private static Dairy_Cattle_Farmer__c createSingleFarmer() {
    
        // Create the Country record for Uganda
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'English';
        insert uganda;
        
        // Create the contact who registers the Dairy farmer
        Contact ckw = new Contact();
        ckw.FirstName = 'test';
        ckw.LastName = 'ckw';
        insert ckw;

        // Create a test person
        Person__c person = new Person__c();
        person.First_Name__c = 'Test1';
        person.Last_Name__c = 'Test2';
        person.Gender__c = 'Female';
        person.Type__c = 'Dairy Farmer';
        insert person;

        // Create a Dairy farmer object
        Dairy_Cattle_Farmer__c dairyFarmer = new Dairy_Cattle_Farmer__c();
        dairyFarmer.Person__c = person.Id;
        dairyFarmer.Registered_By__c = ckw.Id;
        dairyFarmer.Village__c = 'village1';
        dairyFarmer.PPI_Score__c = 80;
        dairyFarmer.District__c = 'District';
        dairyFarmer.Subcounty__c = 'Subcounty';
        dairyFarmer.Parish__c = 'Parish';
        return dairyFarmer;
    }
    
    private static List<Dairy_Cattle_Farmer__c> createMultipleFarmers() {
    
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'English';
        insert uganda;
        
        Contact ckw = new Contact();
        ckw.FirstName = 'test';
        ckw.LastName = 'ckw';
        insert ckw;
        
        Contact ckw2 = new Contact();
        ckw2.FirstName = 'test2';
        ckw2.LastName = 'ckw2';
        insert ckw2;
        
        Person__c person = new Person__c();
        person.First_Name__c = 'Test1';
        person.Last_Name__c = 'Test2';
        person.Gender__c = 'Female';
        person.Type__c = 'Dairy Farmer';
        insert person;
        
        Person__c person2 = new Person__c();
        person2.First_Name__c = 'Test12';
        person2.Last_Name__c = 'Test22';
        person2.Gender__c = 'Male';
        person2.Type__c = 'Dairy Farmer';
        insert person2;

        Person__c person3 = new Person__c();
        person3.First_Name__c = 'Test13';
        person3.Last_Name__c = 'Test23';
        person3.Gender__c = 'Female';
        person3.Type__c = 'Dairy Farmer';
        insert person3;

        Dairy_Cattle_Farmer__c dairyFarmer = new Dairy_Cattle_Farmer__c();
        dairyFarmer.Person__c = person.Id;
        dairyFarmer.Registered_By__c = ckw.Id;
        dairyFarmer.Village__c = 'village1';
        dairyFarmer.PPI_Score__c = 80;
        dairyFarmer.District__c = 'District';
        dairyFarmer.Subcounty__c = 'Subcounty';
        dairyFarmer.Parish__c = 'Parish';

        Dairy_Cattle_Farmer__c dairyFarmer2 = new Dairy_Cattle_Farmer__c();
        dairyFarmer2.Person__c = person2.Id;
        dairyFarmer2.Registered_By__c = ckw.Id;
        dairyFarmer2.Village__c = 'village2';
        dairyFarmer2.PPI_Score__c = 82;
        dairyFarmer2.District__c = 'District';
        dairyFarmer2.Subcounty__c = 'Subcounty';
        dairyFarmer2.Parish__c = 'Parish';

        Dairy_Cattle_Farmer__c dairyFarmer3 = new Dairy_Cattle_Farmer__c();
        dairyFarmer3.Person__c = person3.Id;
        dairyFarmer3.Registered_By__c = ckw2.Id;
        dairyFarmer3.Village__c = 'village3';
        dairyFarmer3.PPI_Score__c = 83;
        dairyFarmer3.District__c = 'District';
        dairyFarmer3.Subcounty__c = 'Subcounty';
        dairyFarmer3.Parish__c = 'Parish';

        return new List<Dairy_Cattle_Farmer__c>{dairyFarmer, dairyFarmer2, dairyFarmer3};
    }
}