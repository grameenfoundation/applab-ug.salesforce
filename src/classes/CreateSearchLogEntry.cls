/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  API calls to create search logs. Called by devices
 *  Tests are in TestCreateSearchLogEntry
 **/
global class CreateSearchLogEntry {

    // Define an object in apex that is exposed in apex web service
    global class SearchLogEntry {
        webservice String handsetId;
        webservice String serverEntryTime;
        webservice String submissionTime;
        webservice String farmerId;
        webservice String latitude;
        webservice String longitude;
        webservice String altitude;
        webservice String accuracy;
        webservice String category;
        webservice String query;
        webservice String content;
        webservice String submissionLatitude;
        webservice String submissionLongitude;
        webservice String submissionAltitude;
        webservice String submissionAccuracy;
        webservice String submissionGPSTime;
        webservice String msisdn;
        webservice Boolean isCompleted = false; 
        webservice Boolean isUssd = false;
        webservice Boolean inserted = false;
    }

    // Only works for USSD batching
    webservice static Boolean createNewSearchLogEntries(List<SearchLogEntry> searchLogEntries) {

        List<Search_Log__c> searchLogs = new List<Search_Log__c>();
        Map<String, Person__c> personMsisdnMap = getFarmerPersonObjects(searchLogEntries);
        Decimal totalCompleteUssdSearches = 0.0;
        Decimal totalIncompleteUssdSearches = 0.0;
        Decimal totalInfoServices = 0.0;
        String currentQuarterIndicator = MetricHelpers.getCurrentQuarterAsString(0);

        for (SearchLogEntry searchLogEntry : searchLogEntries) {
            Search_Log__c searchLog = new Search_Log__c();
            searchLog.Server_Entry_Time__c = getDateFromString(searchLogEntry.serverEntryTime);
            searchLog.Handset_Submit_Time__c =  getDateFromString(searchLogEntry.submissionTime);
            searchLog.Category__c = searchLogEntry.category;
            searchLog.Query__c = searchLogEntry.query;
            searchLog.Response__c = searchLogEntry.content;
            currentQuarterIndicator = getQuarterIndicator(searchLogEntry.submissionTime);

            Long timeStamp = null;
            if (searchLogEntry.submissionGPSTime != null) {
                timeStamp = Long.valueOf(searchLogEntry.submissionGPSTime);
            }
            if (timeStamp == null || timeStamp == 0) {
                searchLog.Submission_GPS_Timestamp__c = null;
            }
            else {
                searchLog.Submission_GPS_Timestamp__c = datetime.newInstance(timeStamp);
            }

            searchLog.Latitude__c = 0.0;
            searchLog.Longitude__c = 0.0;
            searchLog.Altitude__c = 0.0;
            searchLog.Accuracy__c = 0.0;
            searchLog.Submission_Latitude__c = 0.0;
            searchLog.Submission_Longitude__c = 0.0;
            searchLog.Submission_Altitude__c = 0.0;
            searchLog.Submission_Accuracy__c = 0.0;
            searchLog.From_Ussd__c = true;

            // Get interviewee: all ussd seaches assumed to be 'interviewee originated' and the interviewer is the same as the interviewee 
            // Get farmer: interviewee assumed to be farmer
            Person__c interviewee = personMsisdnMap.get(searchLogEntry.msisdn);
            if(interviewee != null) {
                searchLog.Interviewee__c = interviewee.Id;
                searchLog.Interviewer__c = interviewee.Id;
<<<<<<< HEAD
             	searchLog.OwnerId = interviewee.OwnerId;   
=======
                searchLog.OwnerId = interviewee.OwnerId;   
>>>>>>> origin/ci
            }

            searchLogs.add(searchLog);

            if (searchLogEntry.isCompleted == true) {

                // For all ussd completed search attempts update total_complete_interactions_ussd_searches
                totalCompleteUssdSearches += 1;
                totalInfoServices += 1;
            }
            else{

                // For all ussd search attempts update total_interactions_ussd_searches
                totalIncompleteUssdSearches += 1;
            }

    }
        insert searchLogs;
        MetricHelpers.updateMetric('total_complete_interactions_ussd_searches', totalCompleteUssdSearches, null, null, MetricHelpers.getQuarterFirstDay(currentQuarterIndicator), MetricHelpers.getQuarterLastDay(currentQuarterIndicator), false);
        MetricHelpers.updateMetric('total_info_services_offered', totalInfoServices, null, null, MetricHelpers.getQuarterFirstDay(currentQuarterIndicator), MetricHelpers.getQuarterLastDay(currentQuarterIndicator), false);
        MetricHelpers.updateMetric('total_incomplete_interactions_ussd_searches', totalIncompleteUssdSearches, null, null, MetricHelpers.getQuarterFirstDay(currentQuarterIndicator), MetricHelpers.getQuarterLastDay(currentQuarterIndicator), false);
        return true;
    }

    webservice static SearchLogEntry createNewSearchLogEntry(SearchLogEntry searchLogEntry) {

        Search_Log__c searchLog = new Search_Log__c();
        searchLog.Server_Entry_Time__c = getDateFromString(searchLogEntry.serverEntryTime);
        searchLog.Handset_Submit_Time__c =  getDateFromString(searchLogEntry.submissionTime);
        searchLog.Category__c = searchLogEntry.category;
        searchLog.Query__c = searchLogEntry.query;
        searchLog.Response__c = searchLogEntry.content;
        
        Long timeStamp = null;
        if (searchLogEntry.submissionGPSTime != null) {
            timeStamp = Long.valueOf(searchLogEntry.submissionGPSTime);
        }
        if (timeStamp == null || timeStamp == 0) {
            searchLog.Submission_GPS_Timestamp__c = null;
        }
        else {
            searchLog.Submission_GPS_Timestamp__c = datetime.newInstance(timeStamp);
        }

        if (searchLogEntry.isUssd == true) {

            searchLog.Latitude__c = 0.0;
            searchLog.Longitude__c = 0.0;
            searchLog.Altitude__c = 0.0;
            searchLog.Accuracy__c = 0.0;
            searchLog.Submission_Latitude__c = 0.0;
            searchLog.Submission_Longitude__c = 0.0;
            searchLog.Submission_Altitude__c = 0.0;
            searchLog.Submission_Accuracy__c = 0.0;
            searchLog.From_Ussd__c = true;

             // Get interviewee: all ussd seaches assumed to be 'interviewee originated' and the interviewer is the same as the interviewee 
            // Get farmer: interviewee assumed to be farmer
            Person__c interviewee = getFarmerPersonObject(searchLogEntry);
            if(interviewee != null) {
                searchLog.Interviewee__c = interviewee.Id;
                searchLog.Interviewer__c = interviewee.Id;
            }

            // Save searchLog entry
            insert searchLog;

            if (searchLogEntry.isCompleted == true) {

                // For all ussd completed search attempts update total_complete_interactions_ussd_searches
                MetricHelpers.updateMetric('total_complete_interactions_ussd_searches', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            }
            else{

                // For all ussd search attempts update total_interactions_ussd_searches
                MetricHelpers.updateMetric('total_incomplete_interactions_ussd_searches', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            }
        }
        else {
            searchLog.Latitude__c = decimal.valueOf(searchLogEntry.latitude);
            searchLog.Longitude__c = decimal.valueOf(searchLogEntry.longitude);
            searchLog.Altitude__c = decimal.valueOf(searchLogEntry.altitude);
            searchLog.Accuracy__c = decimal.valueOf(searchLogEntry.accuracy);
            searchLog.Submission_Latitude__c = decimal.valueOf(searchLogEntry.submissionLatitude);
            searchLog.Submission_Longitude__c = decimal.valueOf(searchLogEntry.submissionLongitude);
            searchLog.Submission_Altitude__c = decimal.valueOf(searchLogEntry.submissionAltitude);
            searchLog.Submission_Accuracy__c = decimal.valueOf(searchLogEntry.submissionAccuracy);

            // Get farmer
            Person__c interviewee = getFarmerPersonObject(searchLogEntry);
            if(interviewee != null) {
                searchLog.Interviewee__c = interviewee.Id;
            }
            else {

                // Add this is the farmer is an invalid farmer
                searchLog.Invalid_Farmer_Id__c = searchLogEntry.farmerId.trim().toUpperCase();
            }

            // Get interviewer 
            Person__c interviewer = getInterviewer(searchLogEntry);
            if(interviewer != null) {
                searchLog.Interviewer__c = interviewer.Id; 
                searchLog.OwnerId = interviewer.OwnerId;
            }

            // Save searchLog entry
            insert searchLog;

            if (interviewee != null) {
                MetricHelpers.updateMetric('total_interactions_searches', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            }

            // If the submitter is a CKW the update their performance record
            CKW__c ckw = null;
            if (interviewer != null) {
                ckw = Utils.loadCkwFromPersonSalesforceId((String)interviewer.id);
            }
            if (ckw != null) {

                // Work out what type of search it is and update the performance record
                String field = 'Number_Of_Searches_Running_Total__c';
                if (interviewee == null) {
                    field = 'Number_Of_Invalid_Searches_Running_Total__c';
                }
                else if (searchLogEntry.farmerId != null && searchLogEntry.farmerId.trim().toUpperCase().equalsIgnoreCase('TEST')) {
                    field = 'Number_Of_Test_Searches_Running_Total__c';
                }
                PerformanceReviewHelpers.updatePerformanceRecord(ckw, getDateFromString(searchLogEntry.submissionTime).date().toStartOfMonth(), field, 1.0, false);
            }
        }
        searchLogEntry.inserted = true;
        return searchLogEntry;
    }

    public static Datetime getDateFromString(String dateString) {
        Datetime dateValue = datetime.valueOf(dateString);
        return dateValue;
    }
    
    public static String getQuarterIndicator(String submissionTime) {

        String[] submissionDate = submissionTime.split(' ');
        String[] dateParts = submissionDate[0].split('-');
        String year = dateParts[0];
        Integer month = Integer.valueOf(dateParts[1]);
        String quarterIndicator;

        if (month <= 3) {
            quarterIndicator = 'Jan - Mar ' + year;
        }
        else if (month <= 6) {
            quarterIndicator = 'Apr - Jun ' + year;
        }
        else if (month <= 9) {
            quarterIndicator = 'Jul - Sep ' + year;
        }
        else if (month <= 12) {
            quarterIndicator = 'Oct - Dec ' + year;
        }

        return quarterIndicator;
    }

    public static Map<String, Person__c> getFarmerPersonObjects(List<SearchLogEntry> searchLogEntries) {

        Map<String, Person__c> personMsisdnMap = new Map<String, Person__c>();
        Map<String, Boolean> msisdnMap = new Map<String, Boolean>();

        for (SearchLogEntry searchLogEntry : searchLogEntries) {
            personMsisdnMap.put(searchLogEntry.msisdn, null);
            msisdnMap.put(searchLogEntry.msisdn, false);
        }

        //Check if person exists: Get Id corresponding to msisdn
        for (Person__c person : [
            SELECT 
                Id, Raw_Mobile_Number__c, OwnerId
            FROM 
                Person__c 
            WHERE
                Raw_Mobile_Number__c IN :(personMsisdnMap.keySet())
         ]){
                personMsisdnMap.put(person.Raw_Mobile_Number__c, person);
         }

        List<String> missingPersonMsisdns = new List<String>();
        List<Person__c> missingPersons = new List<Person__c>();

        for (String msisdn : personMsisdnMap.keySet()) {
            if (null == personMsisdnMap.get(msisdn)) {
                missingPersonMsisdns.add(msisdn);
            }
        }

        missingPersons = createFarmerPersonObjects(missingPersonMsisdns);
        createNewFarmerObjects(missingPersons);

        for (Person__c person : missingPersons) {
            personMsisdnMap.put(person.Raw_Mobile_Number__c, person);
        }

        createFarmerObjects(personMsisdnMap, msisdnMap);
<<<<<<< HEAD
        return personMsisdnMap;	          
=======
        return personMsisdnMap;           
>>>>>>> origin/ci
    }

    public static Person__c getFarmerPersonObject(SearchLogEntry searchLogEntry) {
        Person__c person = new Person__c();
        if(searchLogEntry.isUssd == true) {

            //Check if person exists: Get Id corresponding to msisdn
            Person__c[] people = [
<<<<<<< HEAD
	            SELECT 
	                Id, OwnerId 
	            FROM 
	                Person__c 
	            WHERE
	                Raw_Mobile_Number__c =:searchLogEntry.msisdn 
	            LIMIT 1]; 
	        if(people.isEmpty()) {
	            person = createFarmerPersonObject(searchLogEntry);
	            createfarmerobject(person);
=======
                SELECT 
                    Id, OwnerId 
                FROM 
                    Person__c 
                WHERE
                    Raw_Mobile_Number__c =:searchLogEntry.msisdn 
                LIMIT 1]; 
            if(people.isEmpty()) {
                person = createFarmerPersonObject(searchLogEntry);
                createfarmerobject(person);
>>>>>>> origin/ci
            }
            else {
                person = people[0];

                //If farmer is non existent create
                if (farmerExists(person) == null){
                    createFarmerObject(person);
                }
            }
            return person;
        }
        else {

            // Try to get farmer from Id
            String farmerId = searchLogEntry.farmerId.trim().toUpperCase();
            if (farmerId == null || farmerId.length() == 0) {
                return null;
            }
            if(farmerId.toLowerCase() == 'test') {
                return loadTestPerson();
            } 

            Person__c[] people = [
                SELECT
                    Id, OwnerId
                FROM 
                    Person__c
                WHERE
                    Id IN (
                        SELECT
                            Person__c
                        FROM
                            Farmer__c
                        WHERE
                            Name = :farmerId
                    )
                LIMIT 1];

            if(people.isEmpty()) {
                return null;
            }
            else {
                person = people[0];
            }
        }
        return person;
    }

    public static Person__c loadTestPerson() {
        Person__c person = new Person__c();
        Person__c[] people = [
            SELECT
                Id, OwnerId
            FROM
                Person__c
            WHERE
                First_Name__c = 'Test'
                AND Last_Name__c ='Test'
            LIMIT 1];
        if(people.isEmpty()) {
            person = new Person__c();
            person.First_Name__c = 'Test';
            person.Last_Name__c = 'Test';
            insert person;
        }
        else {
            person = people[0];
        }
        return person;
    }

    public static Farmer__c farmerExists(Person__c person) {
        Farmer__c farmer = new Farmer__c();

        //Check for existence of farmer with person.Id
        Farmer__c[] farmers = [
            SELECT 
                Id, Person__r.OwnerId
            FROM 
                Farmer__c 
            WHERE
                Person__c =: person.Id 
            LIMIT 1]; 
        if(farmers.isEmpty()) {
            return null;
        }
        else { 
        return farmer;
        }
    }

    public static List<Person__c> createFarmerPersonObjects(List<String> missingPersonsMsisdns) {

        List<Person__c> persons = new List<Person__c>();
        for (String msisdn : missingPersonsMsisdns) {
            Person__c person = new Person__c();
            person.First_Name__c = 'Unknown USSD';
            person.Last_Name__c = 'User';
            person.Raw_Mobile_Number__c = msisdn;
            persons.add(person);
        }
        insert persons;
        return persons;
    }

    public static void createFarmerObjects(Map<String, Person__c> personMsisdnMap, Map<String, Boolean> personFarmerMap) {

        List<Farmer__c> newFarmers = new List<Farmer__c>();
        List<Farmer__c> farmers = new List<Farmer__c>();

        for (Farmer__c farmer : [
            SELECT 
                Id,
                Person__c, Person__r.OwnerId,
                Person__r.Raw_Mobile_Number__c
            FROM 
                Farmer__c 
            WHERE
                Person__r.Raw_Mobile_Number__c IN :(personMsisdnMap.keySet()) 
            ]) {

                farmers.add(farmer);
                personFarmerMap.put(farmer.Person__r.Raw_Mobile_Number__c, true);
            } 

        for (String msisdn : personMsisdnMap.keySet()) {
            if (!personFarmerMap.get(msisdn)) {
                Farmer__c farmer = new Farmer__c();
                farmer.Person__c = personMsisdnMap.get(msisdn).Id;
                newFarmers.add(farmer);
            } 
        } 
        insert newFarmers;
    }

    public static Person__c createFarmerPersonObject(SearchLogEntry searchLogEntry) {

        // Create the new person
        Person__c person = new Person__c();
        person.First_Name__c = 'Unknown USSD';
        person.Last_Name__c = 'User';
        person.Raw_Mobile_Number__c = searchLogEntry.msisdn;
        insert person;
        return person;
    }
    
    public static void createNewFarmerObjects(List<Person__c> persons) {

        List<Farmer__c> farmers = new List<Farmer__c>();
        for (Person__c person : persons) {
<<<<<<< HEAD
        	Farmer__c farmer = new Farmer__c();
        	farmer.Person__c = person.Id;
        	farmers.add(farmer);
=======
            Farmer__c farmer = new Farmer__c();
            farmer.Person__c = person.Id;
            farmers.add(farmer);
>>>>>>> origin/ci
        }
        insert farmers;
    }
    

    public static void createFarmerObject(Person__c person) {

        // Create the new farmer
        Farmer__c farmer = new Farmer__c();
        farmer.Person__c = person.Id;
        insert farmer;
    }

    public static Person__c getInterviewer(SearchLogEntry searchLogEntry) {
        Person__c person = new Person__c();
        Person__c[] people = [
            SELECT
                Id, OwnerId,
                GPS_Location_E__c,
                GPS_Location_N__c
            FROM
                Person__c
            WHERE
                Handset__r.IMEI__c = :searchLogEntry.handsetId
            LIMIT 1];
        if(people.isEmpty()) {

            // Send mail to tech. This implies that a handset not on our system is using search
            String[] toAddress = new String[]{};
            toAddress.add(EmailHelpers.getTechEmailAddress());
            String subject = 'Search Log Attempt with Unknown/Unlinked Handset ID: ' + searchLogEntry.handsetId;
            String message = 'HandsetId: ' + searchLogEntry.handsetId + ', query: ' + searchLogEntry.query + ', content: ' + searchLogEntry.content;
            Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[] { EmailHelpers.createEmail(toAddress, subject, message) };
            EmailHelpers.sendEmails(mail);
            return null;
        }
        else {
            person = people[0];
        }
        return person;
    }
<<<<<<< HEAD

    static testMethod void testcreateFarmerObject() {

        // Create the new person
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'testfname';
        testPerson.Last_Name__c = 'testlname';
        testPerson.Raw_Mobile_Number__c = 'testmsisdn';
        insert testPerson;
        FarmerExists(testPerson);
        createFarmerObject(testPerson);
    }

    static testMethod void testGetQuarterIndicator(){
        String testTime1 = '2010-01-01 00:00:00';
        getQuarterIndicator(testTime1);
        String testTime2 = '2010-04-01 00:00:00';
        getQuarterIndicator(testTime2);
        String testTime3 = '2010-07-01 00:00:00';
        getQuarterIndicator(testTime3);
        String testTime4 = '2010-11-01 00:00:00';
        getQuarterIndicator(testTime4);
    }

    static testMethod void testCreateSearchLogEntry() {
        SearchLogEntry entry1 = new SearchLogEntry();
        entry1.handsetId = 'MyTestHandsetId1';
        entry1.serverEntryTime = '2010-01-01 00:00:00';
        entry1.submissionTime = '2010-01-01 00:00:00';
        entry1.farmerId = 'MyTestFarmerId1';
        entry1.latitude = '0.00';
        entry1.longitude = '0.00';
        entry1.altitude = '0.00';
        entry1.accuracy = '0.00';
        entry1.submissionLatitude = '0.00';
        entry1.submissionLongitude = '0.00';
        entry1.submissionAltitude = '0.00';
        entry1.submissionAccuracy = '0.00';
        entry1.submissionGPSTime = '0';
        entry1.category = 'Category1';
        entry1.query = 'Query1';
        entry1.content = 'Content1';
        entry1.msisdn = 'MyMsisdn1';

        SearchLogEntry createdEntry1 = createNewSearchLogEntry(entry1);
        System.assert(createdEntry1.inserted);
        loadTestPerson();

        getInterviewer(entry1);
        createFarmerPersonObject(entry1);

        getFarmerPersonObject(entry1);
        testcreateFarmerObject();

        SearchLogEntry entry2 = new SearchLogEntry();
        entry2.handsetId = 'MyTestHandsetId2';
        entry2.serverEntryTime = '2010-01-01 00:00:00';
        entry2.submissionTime = '2010-01-01 00:00:00';
        entry2.farmerId = 'MyTestFarmerId2';
        entry2.latitude = '0.00';
        entry2.longitude = '0.00';
        entry2.altitude = '0.00';
        entry2.accuracy = '0.00';
        entry2.submissionLatitude = '0.00';
        entry2.submissionLongitude = '0.00';
        entry2.submissionAltitude = '0.00';
        entry2.submissionAccuracy = '0.00';
        entry2.submissionGPSTime = '0';
        entry2.category = 'Category2';
        entry2.query = 'Query2';
        entry2.content = 'Content2';
        entry2.msisdn = 'MyMsisdn2';
        entry2.isUssd = true;
        entry2.isCompleted = true;

        SearchLogEntry createdEntry2 = createNewSearchLogEntry(entry2);
        System.assert(createdEntry2.inserted);
        loadTestPerson();

        getInterviewer(entry2);
        createFarmerPersonObject(entry2);

        getFarmerPersonObject(entry2);
        testcreateFarmerObject();

    }

    static testMethod void testCreateSearchLogEntries() {

        List<SearchLogEntry> searchLogs = new List<SearchLogEntry>();

        SearchLogEntry entry1 = new SearchLogEntry();
        entry1.handsetId = 'MyTestHandsetId1';
        entry1.serverEntryTime = '2010-01-01 00:00:00';
        entry1.submissionTime = '2010-01-01 00:00:00';
        entry1.farmerId = 'MyTestFarmerId1';
        entry1.latitude = '0.00';
        entry1.longitude = '0.00';
        entry1.altitude = '0.00';
        entry1.accuracy = '0.00';
        entry1.submissionLatitude = '0.00';
        entry1.submissionLongitude = '0.00';
        entry1.submissionAltitude = '0.00';
        entry1.submissionAccuracy = '0.00';
        entry1.submissionGPSTime = '0';
        entry1.category = 'Category';
        entry1.query = 'Query';
        entry1.content = 'Content';
        entry1.msisdn = 'MyMsisdn1';
        searchLogs.add(entry1);

        SearchLogEntry entry2 = new SearchLogEntry();
        entry2.handsetId = 'MyTestHandsetId2';
        entry2.serverEntryTime = '2010-01-01 00:00:00';
        entry2.submissionTime = '2010-01-01 00:00:00';
        entry2.farmerId = 'MyTestFarmerId2';
        entry2.latitude = '0.00';
        entry2.longitude = '0.00';
        entry2.altitude = '0.00';
        entry2.accuracy = '0.00';
        entry2.submissionLatitude = '0.00';
        entry2.submissionLongitude = '0.00';
        entry2.submissionAltitude = '0.00';
        entry2.submissionAccuracy = '0.00';
        entry2.submissionGPSTime = '0';
        entry2.category = 'Category';
        entry2.query = 'Query';
        entry2.content = 'Content';
        entry2.msisdn = 'MyMsisdn2';
        searchLogs.add(entry2);

		getFarmerPersonObjects(searchLogs);
        System.assert(createNewSearchLogEntries(searchLogs));

    }
=======
>>>>>>> origin/ci
}