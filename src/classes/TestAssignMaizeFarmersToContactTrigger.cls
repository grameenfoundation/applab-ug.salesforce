@isTest
public class TestAssignMaizeFarmersToContactTrigger {

    @isTest static void TestAssignSingleMaizeFarmerToContact() {
        

        Maize_Farmer__c maizeFarmer = createSingleFarmer();
        insert maizeFarmer;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Maize_Farmer__c'
                                                              and
                                                                gfsurveys__Contact__c =:maizeFarmer.Registered_By__c];
        System.assertEquals(maizeFarmer.Id, scas[0].gfsurveys__AssociatedIds__c);
        Test.stopTest();
    }
    
    @isTest static void testAssignMultipleFarmersToContacts() {
        List<Maize_Farmer__c> maizeFarmers = createMultipleFarmers();
        insert maizeFarmers;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Maize_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }
    
    @isTest static void testAssignMultipleFarmersOneAtaTime() {
        List<Maize_Farmer__c> maizeFarmers = createMultipleFarmers();
        for (Maize_Farmer__c maizeFarmer : maizeFarmers) {
            insert maizeFarmer;
        }
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Maize_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }
    
    private static Maize_Farmer__c createSingleFarmer() {
        // Create the contact who registers the maize farmer
        Contact ckw = new Contact();
        ckw.FirstName = 'test';
        ckw.LastName = 'ckw';
        insert ckw;

        // Create a test person
        Person__c person = new Person__c();
        person.First_Name__c = 'Test1';
        person.Last_Name__c = 'Test2';
        person.Gender__c = 'Female';
        person.Type__c = 'Focus Farmer';
        insert person;

        // Create a focus farmer
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = person.id;
        focusFarmer.Farmer_Type__c = 'Maize';
        insert focusFarmer;

        // Create a food security detail
        Food_Security_Detail__c foodSecurity = new Food_Security_Detail__c();
        foodSecurity.Focus_Farmer__c = focusFarmer.Id;
        insert foodSecurity;

        // Create a maize farmer object
        Maize_Farmer__c maizeFarmer = new Maize_Farmer__c();
        maizeFarmer.Focus_Farmer__c = focusFarmer.Id;
        maizeFarmer.Registered_By__c = ckw.Id;
        return maizeFarmer;
    }
    
    private static List<Maize_Farmer__c> createMultipleFarmers() {
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
        person.Type__c = 'Focus Farmer';
        insert person;
        
        Person__c person2 = new Person__c();
        person2.First_Name__c = 'Test12';
        person2.Last_Name__c = 'Test22';
        person2.Gender__c = 'Male';
        person2.Type__c = 'Focus Farmer';
        insert person2;
        
        Person__c person3 = new Person__c();
        person3.First_Name__c = 'Test13';
        person3.Last_Name__c = 'Test23';
        person3.Gender__c = 'Female';
        person3.Type__c = 'Focus Farmer';
        insert person3;
        
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = person.id;
        focusFarmer.Farmer_Type__c = 'Maize';
        insert focusFarmer;
        
        Focus_Farmer__c focusFarmer2 = new Focus_Farmer__c();
        focusFarmer2.Person__c = person2.id;
        focusFarmer2.Farmer_Type__c = 'Maize';
        insert focusFarmer2;
        
        Focus_Farmer__c focusFarmer3 = new Focus_Farmer__c();
        focusFarmer3.Person__c = person3.id;
        focusFarmer3.Farmer_Type__c = 'Maize';
        insert focusFarmer3;
        
        Food_Security_Detail__c foodSecurity = new Food_Security_Detail__c();
        foodSecurity.Focus_Farmer__c = focusFarmer.Id;
        insert foodSecurity;
        
        Food_Security_Detail__c foodSecurity2 = new Food_Security_Detail__c();
        foodSecurity2.Focus_Farmer__c = focusFarmer2.Id;
        insert foodSecurity2;
        
        Food_Security_Detail__c foodSecurity3 = new Food_Security_Detail__c();
        foodSecurity3.Focus_Farmer__c = focusFarmer3.Id;
        insert foodSecurity3;
        
        Maize_Farmer__c maizeFarmer = new Maize_Farmer__c();
        maizeFarmer.Focus_Farmer__c = focusFarmer3.Id;
        maizeFarmer.Registered_By__c = ckw.Id;
        
        Maize_Farmer__c maizeFarmer2 = new Maize_Farmer__c();
        maizeFarmer2.Focus_Farmer__c = focusFarmer3.Id;
        maizeFarmer2.Registered_By__c = ckw.Id;
        
        Maize_Farmer__c maizeFarmer3 = new Maize_Farmer__c();
        maizeFarmer3.Focus_Farmer__c = focusFarmer3.Id;
        maizeFarmer3.Registered_By__c = ckw2.Id;
        
        return new List<Maize_Farmer__c>{maizeFarmer, maizeFarmer2, maizeFarmer3};
    }
}