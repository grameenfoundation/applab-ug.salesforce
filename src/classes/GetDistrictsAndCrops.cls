global class GetDistrictsAndCrops {
        
    webservice static List<String> getDistrictsAndCrops() {
        
        List<String> districts = getDistricts();
        List<String> crops = getCrops();
        
        //Json serialize records
        List<String> districtsAndCrops = new List<String>();
        districtsAndCrops.add(JSON.serialize(districts));
        districtsAndCrops.add(JSON.serialize(crops));
        return districtsAndCrops;
    }
    
    private static List<String> getDistricts() {
        List<String> allDistricts = new List<String>();
        
        for (District__c district : [SELECT Name FROM District__c]) {
        	allDistricts.add(district.Name);
        }
        allDistricts.sort();
        return allDistricts;
    }
    
    private static List<String> getCrops() {
    	List<String> allCrops = new List<String>();
    	
    	Schema.DescribeFieldResult fieldResult = Farmer__c.Crops__c.getDescribe();
		List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry crop: picklistEntry) {
			String cropName = crop.getValue();
			if (!((crop.getValue().equalsIgnoreCase('None')) || (crop.getValue().equalsIgnoreCase('Other')))) {
				allCrops.add(crop.getValue());
			}
		}
		allCrops.sort();
    	return allCrops;
    }             
   
    static testMethod void canGetDistrictsAndCrops() {

        District__c district = new District__c();
        district.Name = 'TestDistrict_Bunyaruguru';
        database.insert(district);
        
        Commodities__c commodities = new Commodities__c();
        commodities.Name = 'TestCommodities_Cabbage';
       
        List<String> cropsAndDistricts = GetDistrictsAndCrops.getDistrictsAndCrops();
        for (String s: cropsAndDistricts) {
        	System.assertNotEquals(s, '');
        }
    } 
}