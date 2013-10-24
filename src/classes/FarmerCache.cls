global class FarmerCache {

    /**
    * This returns a string of the farmer cache
    */    
    webservice static String getFarmerCache(String imei, String lastUpdateDate) {        
        // Get Farmers registered by CKW with specified IMEI
        List<FarmerCacheObject> farmers = getFarmersByCkwImei(imei, lastUpdateDate);
        
        if (farmers == null) {
            farmers = new List<FarmerCacheObject>();
        }
        //Json serialize and return records
        return JSON.serialize(farmers);
    }
    
    private static List<FarmerCacheObject> getFarmersByCkwImei(String imei, String lastUpdateDate) {
        
        List<FarmerCacheObject> farmerCacheObjects = new List<FarmerCacheObject>();
        
        List<Person__c> persons = [
            SELECT
                p.Id,
                p.District__r.Name
            FROM
                Person__c p
            WHERE
                p.Handset__r.IMEI__c = :imei];
        
        if (persons == null || persons.size() == 0) {
            return farmerCacheObjects;
        }
        
        //Do not return anything if this person has no district set
        //Otherwise all the USSD farmers will be returned
        if (null == persons.get(0).District__r.Name) {
            return farmerCacheObjects;
        }
        
        for (Farmer__c farmer : [
            SELECT
                Id,
                Name,
                Person__r.First_Name__c,
                Person__r.Last_Name__c,
                Person__r.Middle_Name__c,
                Person__r.Fathers_Name__c,
                Person__r.Age__c
            FROM 
                Farmer__c
            WHERE
                LastModifiedDate > :datetime.valueOf(lastUpdateDate)
            AND
            	Person__r.First_Name__c != 'Not Registered'
            AND
            //old code that was for other sections
               Registered_By__c = :persons.get(0).Id ]) {  
               // Person__r.District__r.Name = :persons.get(0).District__r.Name ]) {       
                
            farmerCacheObjects.add(new FarmerCacheObject(farmer.Id, farmer.Name, farmer.Person__r.First_Name__c,
                                                       farmer.Person__r.Middle_Name__c, farmer.Person__r.Last_Name__c,
                                                       farmer.Person__r.Fathers_Name__c, farmer.Person__r.Age__c));       
            
        }
        return farmerCacheObjects;
    }

    global class FarmerCacheObject {
        String sfId;
        String fId;
        String fName;
        String mName;
        String lName;
        String pName;
        Decimal age;
        
        FarmerCacheObject(String sfId, String fId, String fName, 
            String mName, String lName, String pName, Decimal age) {
            
            this.sfId = sfId;
            this.fId = fId;
            this.fName = fName;
            this.mName = mName;
            this.lName = lName;
            this.pName = pName;
            this.age = age;
        }
    }
    
    static testMethod void canGetFarmerCache() {
        
        District__c district = Utils.createTestDistrict('Kakamega');
        database.insert(district);
        
        Phone__c phone = Utils.createTestHandset('21342342345345434');      
        database.insert(phone);
        
        Person__c person = Utils.createTestPerson(phone.Id, 'Oloo', false, district.Id, 'Male');
        database.insert(person);
        
        Person__c farmerPerson = Utils.createTestPerson(phone.Id, 'James', true, district.Id, 'Male');
        database.insert(farmerPerson);
        
        Farmer__c farmer = Utils.createTestFarmer('DE423423', farmerPerson.Id, 'Dummy farmer', false, district.Id, 'Male');     
        farmer.Registered_By__c = person.Id;
        database.insert(farmer);
        
        String cache = FarmerCache.getFarmerCache('21342342345345434', '2011-04-03 00:00:00');
        System.assertNotEquals(cache, '');
    } 
}