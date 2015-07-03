@isTest
public class TestCreateSpecificBananaAdoptions {

    @isTest static void testCreateSpecificBananaAdoptions() {

        // Create the Country record for Uganda
        Country__c uganda = new Country__c();
        uganda.Name = 'Uganda';
        uganda.ISO_Standard_Code__c = 'UG';
        uganda.Language__c = 'English';
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
        
        // Create a Banana farmer object
        Banana_Farmer__c BananaFarmer = new Banana_Farmer__c();
        BananaFarmer.Focus_Farmer__c = focusFarmer.Id;
        BananaFarmer.Registered_By__c = ckw.Id;
        insert BananaFarmer;
        
        // Create a Banana Farmer GAPs Selection object
        Banana_Farmer_GAPs_Selection__c gap = new Banana_Farmer_GAPs_Selection__c();
        gap.CKW_Contact__c = ckw.Id;
        gap.Banana_Farmer__c = BananaFarmer.Id;
        gap.Location__latitude__s = 30.117334;
        gap.Location__longitude__s = 0.396258;
        gap.Top_5_Preferred_GAPs_for_Support__c = 'Soil fertility management;Pruning, desuckering, removal of stems;Providing support for banana;Record keeping on production & marketing;Soil and water conservation';
        insert gap;
        
        // Create a Banana GAPs Adoption Object
        Banana_GAPs_Adoption__c gapsAdoption = new Banana_GAPs_Adoption__c();
        gapsAdoption.Banana_Farmer_GAPs_Selection__c = gap.Id;
        // GAP 1
        gapsAdoption.Soil_Fertility_Mgt_Discussed__c = 'Yes';
        gapsAdoption.Means_of_Soil_Fertilization__c = 'Manure';
        gapsAdoption.Amount_of_Manure_per_Tree__c = 'Two basins';
        gapsAdoption.Stage_of_Fertilizer_Application__c = 'At planting;At flowering';
        // GAP 2 desuckering
        gapsAdoption.Desuckering_Pruning_Discussed__c = 'Yes';
        gapsAdoption.Number_of_Plants_per_Mat__c = 'Two suckers and a mature plant';
        // GAP 2 Pruning
        gapsAdoption.Corm_Removal__c = 'Leave half the corm attached with bunch';
        gapsAdoption.Removal_of_Pseudo_Stems__c = 'Cut stem at ground level & cover stump';
        // GAP 3 Soil and Water Conservation
        gapsAdoption.Soil_Water_Conservation_Discussed__c = 'Yes';
        gapsAdoption.Soil_Water_Conservation_Measures__c = 'Digging trenches or terraces';
        // GAP 4 Propping
        gapsAdoption.Propping_Discussed__c = 'Yes';
        gapsAdoption.Providing_Support_for_Banana__c = 'During the rainy season';
        // GAP 5 Record Keeping
        gapsAdoption.Proper_Record_Keeping_Discussed__c = 'Yes';
        gapsAdoption.Method_of_Record_Storage__c = 'Computer';
        gapsAdoption.Kind_of_Records_Kept__c = 'Production records;Sales records';
        insert gapsAdoption;
        test.startTest();
        List<Banana_GAP_Adoption__c> specificAdoptions = [Select Id from Banana_GAP_Adoption__c where Banana_GAPs_Adoption__c =:gapsAdoption.Id];
        System.assert(specificAdoptions.size() > 0);
        test.stopTest();
        
    }
}