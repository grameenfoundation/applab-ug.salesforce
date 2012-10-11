global class GetFarmersAndMarketPrices {
    
    webservice static String[] getFarmersAndMarketPrices (String selectedDistrict, String selectedCrop) {
        selectedDistrict = selectedDistrict.trim();
        selectedCrop = selectedCrop.trim();
        List<SelectedFarmerObject> farmers = getFarmers(selectedDistrict, selectedCrop);
        List<MarketPricesObject> marketPrices = getMarketPrices(selectedDistrict, selectedCrop);
        
        String[] farmersAndMarketPrices = new String[] {JSON.serialize(farmers), JSON.serialize(marketPrices)} ;

        return farmersAndMarketPrices;
    }
    
    private static List<SelectedFarmerObject> getFarmers (String selectedDistrict, String selectedCrop) {
    	
        Map<String, SelectedFarmerObject> selectedFarmers = new Map<String, SelectedFarmerObject>();
        
        for (Farmer__c farmers: [
            SELECT
            	Id,
                Farmer__c.Name, 
                Person__r.First_Name__c, 
                Person__r.Last_Name__c,
                Person__r.Mobile_Number__c 
            FROM 
                Farmer__c 
            WHERE 
                Farmer__c.Crops__c INCLUDES (:selectedCrop)
            AND 
                Person__r.District__r.Name = :selectedDistrict ]) {
                    
            selectedFarmers.put(farmers.Id, new SelectedFarmerObject(farmers.Name, farmers.Person__r.First_Name__c,
                                farmers.Person__r.Last_Name__c, farmers.Person__r.Mobile_Number__c));
        }
        for (Market_Link_Farmer__c mFarmer : [
        	SELECT
        		Id,
        		Crop_Grown_1__c,
        		Crop_Grown_2__c,
        		Crop_Grown_3__c,
        		Amount_Crop_Grown_1__c,
        		Amount_Crop_Grown_2__c,
        		Amount_Crop_Grown_3__c,
        		Farmer__c,
        		Phone_Number__c
        	FROM 
        		Market_Link_Farmer__c
        	WHERE
        		Farmer__c != NULL
        	  AND
        	  (
        		Crop_Grown_1__c like :selectedCrop
        	  OR
        	    Crop_Grown_2__c like :selectedCrop
        	  OR
        	  	Crop_Grown_3__c like :selectedCrop)]) {
        
        	SelectedFarmerObject selectedFarmer = selectedFarmers.get(mFarmer.Farmer__c);
        	if (null != selectedFarmer) {
        		selectedFarmer.setCropGrownDetails(mFarmer.Phone_Number__c, mFarmer.Crop_Grown_1__c, mFarmer.Crop_Grown_2__c, mFarmer.Crop_Grown_3__c,
        								mFarmer.Amount_Crop_Grown_1__c, mFarmer.Amount_Crop_Grown_2__c, mFarmer.Amount_Crop_Grown_3__c);
        	}        	
        }
        return selectedFarmers.values();
    }
    
    private static List<MarketPricesObject> getMarketPrices (String selectedDistrict, String selectedCrop) {
        List<MarketPricesObject> selectedMarketPrices = new List<MarketPricesObject>();


        String pricePattern = 'Retail price:\\s*(\\d{1,}\\,{0,1}\\d{1,}).*Wholesale Price:\\s*(\\d{1,}\\,{0,1}\\d{1,})';
        Pattern searchPrice = Pattern.compile(pricePattern);

        for (Menu_Item__c menuItems: [
            SELECT 
                Content__c,
                Label__c
            
            FROM
                Menu_Item__c 
            WHERE 
                (Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Subcounty Market Prices')// OR Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Subcounty Market Prices')
            AND 
                Parent_Item__r.Parent_Item__r.Label__c = :selectedDistrict 
            AND 
                Menu__r.Label__c='CKW Search']) {
                    for (Menu_Item__c marketMenuItems: [
                        SELECT 
                            Content__c, 
                            Label__c
                        FROM
                            Menu_Item__c 
                        WHERE 
                        Parent_Item__r.Label__c =: menuItems.Label__c
                    AND
                        Label__c =: selectedCrop]) {
                            if (null != marketMenuItems.Content__c) {
                                    Matcher matchPrice = searchPrice.matcher(marketMenuItems.Content__c);
                                if(matchPrice.find()) {
                                        selectedMarketPrices.add(new MarketPricesObject(menuItems.Label__c, matchPrice.group(1).replace(',',''),
                                    matchPrice.group(2).replace(',','')));
                                }
                                                 
                            }
                        }
        }
        
        return selectedMarketPrices;
    }
    
    global class SelectedFarmerObject {
        String Id;
        String Name;
        String MobileNumber;
        String CropGrown1;
        String CropGrown2;
        String CropGrown3;
        decimal AmountCropGrown1;
        decimal AmountCropGrown2;
        decimal AmountCropGrown3;
        
        SelectedFarmerObject (String farmerId, String firstName, String lastName, String mobileNumber) {
            this.Id = farmerId;
            this.Name = firstName +' '+ lastName;
            this.MobileNumber = mobileNumber;
        }
        
        public void setCropGrownDetails(String mobileNumber, String cropGrown1, String cropGrown2, String cropGrown3, 
        				decimal amountCropGrown1, decimal amountCropGrown2, decimal amountCropGrown3) {
        	this.CropGrown1 = cropGrown1;
            this.CropGrown2 = cropGrown2;
            this.CropGrown3 = cropGrown3;
            this.AmountCropGrown1 = amountCropGrown1;
            this.AmountCropGrown2 = amountCropGrown2;
            this.AmountCropGrown3 = amountCropGrown3;
            this.MobileNumber = mobileNumber;
        }
        
    }
    
    global class MarketPricesObject {
        String MarketName;
        String RetailPrice;
        String WholesalePrice;
        
        MarketPricesObject (String marketName, String lowestRetailPrice, String lowestWholesalePrice) {
            this.MarketName = marketName;
            this.RetailPrice = lowestRetailPrice;
            this.WholesalePrice = lowestWholesalePrice;
        }
    }
    
    static testMethod void canCreateMarketPricesObject(){
        MarketPricesObject testMarketPrices = new MarketPricesObject('TestMarket', '1500', '1000');
        system.assertEquals('TestMarket', testMarketPrices.MarketName);
        system.assertEquals('1500', testMarketPrices.RetailPrice);
        system.assertEquals('1000', testMarketPrices.WholesalePrice);
    }
    
    static testMethod void canCreateSelectedFarmerObject() {
        SelectedFarmerObject testFarmer = new SelectedFarmerObject('UA12345', 'Testing', 'Farmer', '0770123456');
        system.assertEquals('UA12345', testFarmer.Id);
        system.assertEquals('Testing Farmer', testFarmer.Name);
        system.assertEquals('0770123456', testFarmer.MobileNumber);
    }
    
    static testMethod void canGetFarmersAndMarketPrices() {
        District__c district = Utils.createTestDistrict('Nakapiripit');
        database.SaveResult districtResult = database.insert(district);
        
        Markets__c market = new Markets__c();
        market.Name = 'TestMarket';
        market.District__c = districtResult.getId();
        database.SaveResult marketResult = database.insert(market);
        
        Commodities__c commodity = new Commodities__c();
        commodity.Name = 'TestCommodity';
        commodity.Lowest_Retail_Price__c = 2000;
        commodity.Lowest_Wholesale_Price__c = 1500;
        commodity.Market__c = marketResult.getId();
        database.insert(commodity);
        
        Person__c person = new Person__c();
        person.First_Name__c = 'Testing';
        person.Last_Name__c = 'Farmer';
        person.Raw_Mobile_Number__c = '0770123456';
        person.District__c = districtResult.getId();
        database.SaveResult personResult = database.insert(person);
        
        Farmer__c farmer = new Farmer__c();
        farmer.Name = 'UA12345';
        farmer.Person__c = personResult.getId();
        farmer.Crops__c = 'TestCommodity';
        database.SaveResult farmerResult = database.insert(farmer);
        
        Market_Link_Farmer__c mFarmer = new Market_Link_Farmer__c();
        mFarmer.Farmer__c =  farmerResult.getId();
        mFarmer.Farmer_Name__c = 'James';
        mFarmer.Crop_Grown_1__c = 'TestCommodity';
        mFarmer.Amount_Crop_Grown_1__c = 2000;
        database.insert(mFarmer);    
        
        String[] testJson = GetFarmersAndMarketPrices.getFarmersAndMarketPrices('TestDistrict_Nakapiripit', 'TestCommodity');
        for (String s: testJson) {
        	system.debug(s);
            system.assertNotEquals(s, '');
        }
    } 
    
}