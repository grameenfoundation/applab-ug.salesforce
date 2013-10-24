global class GetBuyers {

	webservice static String getBuyers(String selectedDistrict, String selectedCrop) {
		selectedDistrict = selectedDistrict.trim();
		selectedCrop = selectedCrop.trim();
		List<BuyerObject> buyers = findBuyers(selectedDistrict, selectedCrop);
		String buyersJSON = JSON.serialize(buyers);
		
		return buyersJSON;
	}
	
	private static List<BuyerObject> findBuyers(String selectedDistrict, String selectedCrop) {
		List<BuyerObject> foundBuyers = new List<BuyerObject>();
		
		String cropPattern = '(?i).+'+selectedCrop+'.*';
		Pattern searchCrop = Pattern.compile(cropPattern);
		
		String buyerPattern = '([a-zA-Z\\.\\, ]+)\\s*Location:\\s*([a-zA-Z \\.\\,]+)\\s*Contacts:\\s*(\\d{9}|\\d{12})\\s*';
		Pattern searchBuyer = Pattern.compile(buyerPattern);

		for (Menu_Item__c menuItems: [
			SELECT 
				Content__c 
			FROM
				Menu_Item__c 
			WHERE 
				(Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Buyers Directory' OR Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Buyers Directory') 
			AND 
				Parent_Item__r.Parent_Item__r.Label__c = :selectedDistrict 
			AND 
				Menu__r.Label__c='CKW Search']) {
					if (null != menuItems.Content__c) {
    			List<String> buyers = menuItems.Content__c.split('\n');
				for (String buyer: buyers) {
        			Matcher matchCrop = searchCrop.matcher(buyer);
        			if (matchCrop.matches()) {
            			Matcher matchBuyer = searchBuyer.matcher(buyer);
            			if(matchBuyer.find()) {
            				foundBuyers.add(new BuyerObject(matchBuyer.group(1), matchBuyer.group(2), matchBuyer.group(3)));
            			}
    				}
				}
					}
		}
		
		return foundBuyers;
	}
		
	global class BuyerObject {
		String Name;
		String Location;
		String Contact;
		
		BuyerObject (String Name, String Location, String Contact) {
			this.Name = Name;
			this.Location = Location;
			this.Contact = Contact;
		}
	}
	
	static testMethod void canGetBuyers (){
		
		Menu__c testMenu = new Menu__c();
		testMenu.Label__c = 'CKW Search';
		database.SaveResult menuResult = database.insert(testMenu);
		
		Menu_Item__c marketInformation = new Menu_Item__c();
		marketInformation.Label__c = 'Market Information';
		marketInformation.Menu__c = menuResult.getId();
		database.SaveResult marketInfoResult = database.insert(marketInformation);
		
		Menu_Item__c buyersDir = new Menu_Item__c();
		buyersDir.Label__c = 'Buyers Directory';
		buyersDir.Menu__c = menuResult.getId();
		buyersDir.Parent_Item__c = marketInfoResult.getId();
		database.SaveResult buyersResult = database.insert(buyersDir);
		
		Menu_Item__c region = new Menu_Item__c();
		region.Label__c = 'TestCentral';
		region.Menu__c = menuResult.getId();
		region.Parent_Item__c = buyersResult.getId();
		database.Saveresult regionResult = database.insert(region);
		
		Menu_Item__c district = new Menu_Item__c();
		district.Label__c = 'TestDistrict';
		district.Menu__c = menuResult.getId();
		district.Parent_Item__c = regionResult.getId();
		database.SaveResult districtResult = database.insert(district);
		
		Menu_Item__c subCounty = new Menu_Item__c();
		subCounty.Label__c = 'TestSubCounty';
		subCounty.Menu__c = menuResult.getId();
		subCounty.Parent_Item__c = districtResult.getId();
		database.SaveResult subCountyResult = database.insert(subCounty);
		
		Menu_Item__c location = new Menu_Item__c();
		location.Label__c = 'TestLocation';
		location.Content__c = 'Test Buyer Location:TestLocation Contacts: 777777777 Buys: TestCommodity';
		location.Menu__c = menuResult.getId();
		location.Parent_Item__c = subCountyResult.getId();
		database.insert(location);
		
		String buyers = GetBuyers.getBuyers('TestDistrict', 'TestCommodity');
		system.assertNotEquals(buyers, '');
		
	}
	
	static testMethod void canCreateBuyerObject() {
		BuyerObject testObject = new BuyerObject('TestName', 'TestLocation', 'TestContact');
		system.assertEquals('TestName', testObject.Name);
		system.assertEquals('TestLocation', testObject.Location);
		system.assertEquals('TestContact', testObject.Contact);
	}
}