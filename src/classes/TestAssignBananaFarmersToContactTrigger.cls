@isTest
public class TestAssignBananaFarmersToContactTrigger {
	@isTest static void TestAssignBananaFarmersToContactTrigger() {
        

        Banana_Farmer__c BananaFarmer = createSingleFarmer();
        insert BananaFarmer;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Banana_Farmer__c'
                                                              and
                                                                gfsurveys__Contact__c =:BananaFarmer.Registered_By__c];
        System.assertEquals(BananaFarmer.Id, scas[0].gfsurveys__AssociatedIds__c);
        Test.stopTest();
    }
    
    @isTest static void testAssignMultipleFarmersToContacts() {
        List<Banana_Farmer__c> BananaFarmers = createMultipleFarmers();
        insert BananaFarmers;
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Banana_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }
    
    @isTest static void testAssignMultipleFarmersOneAtaTime() {
        List<Banana_Farmer__c> BananaFarmers = createMultipleFarmers();
        for (Banana_Farmer__c BananaFarmer : BananaFarmers) {
            insert BananaFarmer;
        }
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Banana_Farmer__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }
    
    private static Banana_Farmer__c createSingleFarmer() {
    
        // Create the Country record for Uganda
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'ENglish';
        insert uganda;
        
        // Create the contact who registers the Banana farmer
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
        focusFarmer.Farmer_Type__c = 'Banana';
        insert focusFarmer;

        // Create a food security detail
        Food_Security_Detail__c foodSecurity = new Food_Security_Detail__c();
        foodSecurity.Focus_Farmer__c = focusFarmer.Id;
        insert foodSecurity;

        // Create a Banana farmer object
        Banana_Farmer__c BananaFarmer = new Banana_Farmer__c();
        BananaFarmer.Focus_Farmer__c = focusFarmer.Id;
        BananaFarmer.Registered_By__c = ckw.Id;
        return BananaFarmer;
    }
    
    private static List<Banana_Farmer__c> createMultipleFarmers() {
    
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'ENglish';
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
        focusFarmer.Farmer_Type__c = 'Banana';
        insert focusFarmer;
        
        Focus_Farmer__c focusFarmer2 = new Focus_Farmer__c();
        focusFarmer2.Person__c = person2.id;
        focusFarmer2.Farmer_Type__c = 'Banana';
        insert focusFarmer2;
        
        Focus_Farmer__c focusFarmer3 = new Focus_Farmer__c();
        focusFarmer3.Person__c = person3.id;
        focusFarmer3.Farmer_Type__c = 'Banana';
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

        
        Banana_Farmer__c BananaFarmer = new Banana_Farmer__c();
        BananaFarmer.Focus_Farmer__c = focusFarmer.Id;
        BananaFarmer.Registered_By__c = ckw.Id;

        
        Banana_Farmer__c BananaFarmer2 = new Banana_Farmer__c();
        BananaFarmer2.Focus_Farmer__c = focusFarmer2.Id;
        BananaFarmer2.Registered_By__c = ckw.Id;

        Banana_Farmer__c BananaFarmer3 = new Banana_Farmer__c();
        BananaFarmer3.Focus_Farmer__c = focusFarmer3.Id;
        BananaFarmer3.Registered_By__c = ckw2.Id;

        
        return new List<Banana_Farmer__c>{BananaFarmer, BananaFarmer2, BananaFarmer3};
    }
}