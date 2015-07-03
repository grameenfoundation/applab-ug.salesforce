@isTest
public class TestCreateSpecificCoffeeAdoptions {
    @isTest static void testCreateSpecificAdoptions() {
        Contact ckwContact = new Contact(FirstName='Bob', LastName='Zaabu');
        insert ckwContact;
        
        // Create a Coffee Farmer, along with its parent objects
        Country__c country = new Country__c(Name='Uganda', ISO_Standard_Code__c='UG');
        insert country;
        Person__c person = new Person__c();
        person.First_Name__c = 'Suubi';
        person.Last_Name__c = 'Ggoonya';
        insert person;
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = person.id;
        insert focusFarmer;
        Coffee_Farmer__c coffeeFarmer = new Coffee_Farmer__c();
        coffeeFarmer.Focus_Farmer__c = focusFarmer.Id;
        coffeeFarmer.Registered_By__c = ckwContact.Id;
        insert coffeeFarmer;

        // Create a Coffee Farmer GAPs object
        Coffee_Farmer_GAPs_Selection__c gap = new Coffee_Farmer_GAPs_Selection__c();
        gap.Top_5_Preferred_GAPs_for_Support__c = 'Soil fertility management;Coffee pests and disease control;Proper and timely weed control;Soil and water conservation;Coffee desuckering, pruning and stumping';
        gap.CKW_Contact__c = ckwContact.Id;
        gap.Coffee_Farmer__c = coffeeFarmer.Id;
        gap.Location__latitude__s = 30.117334;
        gap.Location__longitude__s = 0.396258;
        insert gap;

        // Create a Coffee GAPs Adoption object
        Coffee_GAPs_Adoption__c gapsAdoption = new Coffee_GAPs_Adoption__c();
        gapsAdoption.Coffee_Farmer_GAPs_Selection__c = gap.id;
        gapsAdoption.Date__c = date.today();
        gapsAdoption.Soil_Water_Conservation_Discussed__c = 'Yes';
        gapsAdoption.Soil_and_Water_Conservation__c = 'Mulching';
        gapsAdoption.Desuckering_Pruning_Stumping_Discussed__c = 'Yes';
        gapsAdoption.Frequency_of_Desuckering__c = 'Several times/as soon as shoots come';
        gapsAdoption.Time_of_Coffee_Stumping__c = '6 to 7 years old';
        gapsAdoption.Level_at_which_stumping_is_done__c = '1ft above ground level';
        gapsAdoption.Time_of_Pruning__c = 'After harvesting the main crop';
        gapsAdoption.No_of_Stems_per_Tree_after_Prune__c = '3-4 stems';
        gapsAdoption.Tool_used_for_Pruning__c = 'Pruning saw';
        gapsAdoption.Group_Production_Marketing_Discussed__c = 'Yes';
        gapsAdoption.Group_Production_and_Marketing__c = 'Yes';
        gapsAdoption.Value_Addition__c = 'Yes';
        gapsAdoption.Obtain_Quality_Agro_Chemicals__c = 'Buy from registered input dealers';
        // on farm value addition
        gapsAdoption.On_farm_Value_Addition_Discussed__c = 'Yes';
        gapsAdoption.Method_of_Drying_Coffee__c = 'Tarpaulins';
        gapsAdoption.Method_of_on_farm_processing__c = 'Wet processing';
        gapsAdoption.Harvesting_and_PHH_Practices__c = 'Drying;Sorting;Grading;Cleaning';
        gapsAdoption.Steps_in_Wet_Processing__c = 'Wash fermented beans';
        insert gapsAdoption;

        test.startTest();
        List<Coffee_GAP_Adoption__c> coffeeGapAdoptions = [Select Id from Coffee_GAP_Adoption__c];
        System.assert(coffeeGapAdoptions.size() > 0);
        test.stopTest();
    }
}