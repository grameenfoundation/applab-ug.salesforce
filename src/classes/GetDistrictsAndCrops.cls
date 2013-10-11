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
        
        allDistricts.add('Kitgum');
        allDistricts.add('Agago');
        allDistricts.add('Pader');
        allDistricts.add('Gulu');
        allDistricts.add('Lira');
        allDistricts.add('Oyam');

        allDistricts.sort();
        return allDistricts;
    }
    
    private static List<String> getCrops() {
    	List<String> allCrops = new List<String>();
    	
    	allCrops.add('cotton');
		allCrops.add('maize');
		allCrops.add('agwedde beans');
		allCrops.add('rice');
		allCrops.add('simsim');
		allCrops.add('dry groundnuts');
		allCrops.add('green grams');
		allCrops.add('sorghum');
		allCrops.add('sunflower');
		allCrops.add('millet');

		allCrops.sort();
    	return allCrops;
    }             
   
    static testMethod void canGetDistrictsAndCrops() {
        List<String> cropsAndDistricts = GetDistrictsAndCrops.getDistrictsAndCrops();        
        System.assert(cropsAndDistricts.size() == 2);
    } 
}