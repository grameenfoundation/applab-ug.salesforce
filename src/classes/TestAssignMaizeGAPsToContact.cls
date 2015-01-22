@isTest
public class TestAssignMaizeGAPsToContact {

    @isTest static void TestAssignGAPsToContact() {

        // Create the Country record for Uganda
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'English';
        insert uganda;
        
        // Create the contact who registers the Maize farmer
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
        
        // Create a Maize farmer object
        Maize_Farmer__c maizeFarmer = new Maize_Farmer__c();
        maizeFarmer.Focus_Farmer__c = focusFarmer.Id;
        maizeFarmer.Registered_By__c = ckw.Id;
        insert maizeFarmer;
        
        // Create a Maize Farmer GAPs object
        Maize_Farmer_GAPs_Selection__c gap = new Maize_Farmer_GAPs_Selection__c();
        gap.CKW_Contact__c = ckw.Id;
        gap.Maize_Farmer__c = maizeFarmer.Id;
        gap.Location__latitude__s = 30.117334;
        gap.Location__longitude__s = 0.396258;
        insert gap;
        
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Maize_Farmer_GAPs_Selection__c'
                                                              and
                                                                gfsurveys__Contact__c =:gap.CKW_Contact__c];
        System.assertEquals(gap.Id, scas[0].gfsurveys__AssociatedIds__c);
        Test.stopTest();
    }
    
    @isTest static void TestAssignGAPsToContacts() {
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
        
        Maize_Farmer__c maizeFarmer = new Maize_Farmer__c();
        maizeFarmer.Focus_Farmer__c = focusFarmer.Id;
        maizeFarmer.Registered_By__c = ckw.Id;
        insert maizeFarmer;
        
        Maize_Farmer__c maizeFarmer2 = new Maize_Farmer__c();
        maizeFarmer2.Focus_Farmer__c = focusFarmer2.Id;
        maizeFarmer2.Registered_By__c = ckw.Id;
        insert maizeFarmer2;
        
        Maize_Farmer__c maizeFarmer3 = new Maize_Farmer__c();
        maizeFarmer3.Focus_Farmer__c = focusFarmer3.Id;
        maizeFarmer3.Registered_By__c = ckw2.Id;
        insert maizeFarmer3;
        
        // Create a Maize Farmer GAPs object
        Maize_Farmer_GAPs_Selection__c gap = new Maize_Farmer_GAPs_Selection__c();
        gap.CKW_Contact__c = ckw.Id;
        gap.Maize_Farmer__c = maizeFarmer.Id;
        gap.Location__latitude__s = 30.117334;
        gap.Location__longitude__s = 0.396258;
        
        // Create a Maize Farmer GAPs object
        Maize_Farmer_GAPs_Selection__c gap2 = new Maize_Farmer_GAPs_Selection__c();
        gap2.CKW_Contact__c = ckw.Id;
        gap2.Maize_Farmer__c = maizeFarmer2.Id;
        gap2.Location__latitude__s = 29.950921;
        gap2.Location__longitude__s = 0.111868;
        
        // Create a Maize Farmer GAPs object
        Maize_Farmer_GAPs_Selection__c gap3 = new Maize_Farmer_GAPs_Selection__c();
        gap3.CKW_Contact__c = ckw2.Id;
        gap3.Maize_Farmer__c = maizeFarmer3.Id;
        gap3.Location__latitude__s = 30.108763;
        gap3.Location__longitude__s = -0.195478;
        
        insert gap;
        insert new Maize_Farmer_GAPs_Selection__c [] {gap2, gap3};
        
        Test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
                                                                gfsurveys__AssociatedIds__c 
                                                              from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                              where 
                                                                gfsurveys__SObjectApiName__c='Maize_Farmer_GAPs_Selection__c'];
        System.assertEquals(2, scas.size());
        Test.stopTest();
    }
}