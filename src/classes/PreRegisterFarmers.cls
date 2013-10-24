global class PreRegisterFarmers {

    global class BulkRegisterFarmers {

        webservice String imei;

        // This is a comma seperated list of farmers ids that have been generated for this user to have for future registrations
        webservice String newFarmerIds;

        // A comma seperated list of all the farmer ids that have been successfully created for this request
        webservice String savedIds;
        webservice Integer numberOfFarmersCreated;
        webservice Boolean success;
        webservice String errorMessage;
    }

    webservice static BulkRegisterFarmers preRegisterFarmers(BulkRegisterFarmers bulkRegisterFarmers) {

        bulkRegisterFarmers.numberOfFarmersCreated = 0;
        bulkRegisterFarmers.savedIds = '';

        // Load the person object for the submitter
        Person__c submitter = Utils.loadPersonImei(bulkRegisterFarmers.imei);
        if (submitter == null) {
            bulkRegisterFarmers.success = false;
            bulkRegisterFarmers.errorMessage = 'Person with the imei: ' + bulkRegisterFarmers.imei + ' does not exist on our system';
            return bulkRegisterFarmers;
        }

        // Check the farmer ids are all unique
        String[] farmerIds = bulkRegisterFarmers.newFarmerIds.split(',');
        Set<String> allowedFarmerIds = new Set<String>();
        for (String id : farmerIds) {
            allowedFarmerIds.add(id);
        }

        if (allowedFarmerIds.size() == 0) {
            bulkRegisterFarmers.success = false;
            bulkRegisterFarmers.errorMessage = 'No farmer ids were provided for imei: ' + bulkRegisterFarmers.imei;
            return bulkRegisterFarmers;
        }
        farmerIds.clear();
        farmerIds.addAll(allowedFarmerIds);

        // Loop through the farmer ids an create a new farmer for each of them
        List<Person__c> persons = new List<Person__c>();
        for (Integer i = 0; i < farmerIds.size(); i++) {
            Person__c person = new Person__c();
            person.First_Name__c = 'Not Registered';
            persons.add(person);
        }
        List<String> savedFarmerIds = new List<String>();
        List<Person__c> savedPersons = new List<Person__c>();
        Integer counter = 0;
        Database.SaveResult[] personResults = Database.insert(persons);
        for (Database.SaveResult personResult : personResults) {
            if (personResult.isSuccess()) {
                savedFarmerIds.add(farmerIds.get(counter));
                savedPersons.add(persons.get(counter));
            }
            counter++;
        }

        // Create the new placeholder farmers for this submitter
        List<Farmer__c> farmers = new List<Farmer__c>();
        counter = 0;
        for (String id : savedFarmerIds) {
            Farmer__c farmer = new Farmer__c();
            farmer.Name = id;
            farmer.Registered_By__c = submitter.Id;
            farmer.Person__c = savedPersons.get(counter).Id;
            farmers.add(farmer);
            counter++;
        }

        // Save the farmers. Create the savedIds string for all the farmers that were created.
        Database.SaveResult[] farmerResults = Database.insert(farmers);
        counter = 0;
        for (Database.SaveResult farmerResult : farmerResults) {
            if (farmerResult.isSuccess()) {
                bulkRegisterFarmers.numberOfFarmersCreated++;
                bulkRegisterFarmers.savedIds += farmers.get(counter).Name + ',';
            }
            counter++;
        }

        // Take of the last ,
        if (!bulkRegisterFarmers.savedIds.equals('')) {
            bulkRegisterFarmers.savedIds = bulkRegisterFarmers.savedIds.subString(0, bulkRegisterFarmers.savedIds.length() - 1);
        }
        bulkRegisterFarmers.success = true;
        return bulkRegisterFarmers;
    }

    static testMethod void testPreReg() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        BulkRegisterFarmers bulkRegisterFarmers = new BulkRegisterFarmers();
        bulkRegisterFarmers.imei = 'TestCKW1';
        bulkRegisterFarmers.newFarmerIds = 'OD1111,OD2222,OD3333,OD4444,OD4444';

        BulkRegisterFarmers registered = preRegisterFarmers(bulkRegisterFarmers);
        System.debug(LoggingLevel.INFO, registered.savedIds);
        System.assert(registered.success);
        System.assertEquals(registered.numberOfFarmersCreated, 4);
    }
}