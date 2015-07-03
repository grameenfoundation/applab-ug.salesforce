@isTest
public class TestCreateSpecificMaizeAdoptions {
    
    @isTest static void testCreateSpecificAdoptions() {

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
        Maize_Farmer__c maizeFarmer = new Maize_Farmer__c();
        maizeFarmer.Focus_Farmer__c = focusFarmer.Id;
        maizeFarmer.Registered_By__c = ckwContact.Id;
        insert maizeFarmer;

        // Create a Maize Farmer GAPs object
        Maize_Farmer_GAPs_Selection__c gap = new Maize_Farmer_GAPs_Selection__c();
        gap.Top_5_Preferred_GAPs_for_Support__c = 'Proper soil fertility management;Proper seed selection;Proper record keeping;Bulking and marketing (group marketing);Proper planting (spacing and seed rate)';
        gap.CKW_Contact__c = ckwContact.Id;
        gap.Maize_Farmer__c = maizeFarmer.Id;
        gap.Location__latitude__s = 30.117334;
        gap.Location__longitude__s = 0.396258;
        insert gap;

        // Create a Maize GAPs Adoption object
        Maize_GAPs_Adoption__c gapsAdoption = new Maize_GAPs_Adoption__c();
        gapsAdoption.Maize_Farmer_GAPs_Selection__c = gap.id;
        gapsAdoption.Date__c = date.today();
        gapsAdoption.Bulking_and_Marketing__c = 'Yes';
        gapsAdoption.Land_Preparation_Discussed__c = 'Yes';
        gapsAdoption.Time_of_Land_Preparation__c = '2-3 weeks before onset of rains';
        gapsAdoption.Proper_Seed_Selection_Discussed__c = 'Yes';
        gapsAdoption.Type_of_Seed_Used_for_Planting__c = 'Improved seed e.g. Longe 5';
        gapsAdoption.Selection_of_Improved_Seed_Type__c = 'Consider the variety most demanded on market';
        gapsAdoption.Proper_Record_Keeping_Discussed__c = 'Yes';
        gapsAdoption.Use_Records_to_Make_Decisions__c = 'Yes';
        gapsAdoption.Kind_of_Records_Kept__c = 'Production records;Sales records';
        gapsAdoption.Method_of_Record_Storage__c = 'Computer';
        gapsAdoption.Harvesting_PHH_Discussed__c = 'Yes';
        gapsAdoption.Method_of_Drying__c = 'Harvest and dry on tarpaulin';
        gapsAdoption.Method_of_Shelling__c = 'Use mechanical Sheller';
        gapsAdoption.Harvesting_and_PHH_Practices__c = 'Drying;Sorting;Cleaning;Branding';
        gapsAdoption.Storage_Practices__c= 'Pack maize in clean sacks;Treat maize seeds with insecticide;Stack bags with maize on raised platform';
        insert gapsAdoption;

        test.startTest();
        List<Maize_GAP_Adoption__c> maizeGapAdoptions = [Select Id from Maize_GAP_Adoption__c];
        System.assert(maizeGapAdoptions.size() > 0);
        test.stopTest();
    }
}