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

    public static Person__c getFarmerPersonObject(SearchLogEntry searchLogEntry) {
        Person__c person = new Person__c();
        if(searchLogEntry.isUssd == true) {

            //Check if person exists: Get Id corresponding to msisdn
            Person__c[] people = [
	            SELECT 
	                Id 
	            FROM 
	                Person__c 
	            WHERE
	                Raw_Mobile_Number__c =:searchLogEntry.msisdn 
	            LIMIT 1]; 
	        if(people.isEmpty()) {
	            person = createFarmerPersonObject(searchLogEntry);
	            createfarmerobject(person);
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
                    Id
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
                Id
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
                Id 
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

    public static Person__c createFarmerPersonObject(SearchLogEntry searchLogEntry) {

        // Create the new person
        Person__c person = new Person__c();
        person.First_Name__c = 'Unknown USSD';
        person.Last_Name__c = 'User';
        person.Raw_Mobile_Number__c = searchLogEntry.msisdn;
        insert person;
        return person;
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
                Id,
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

    static testMethod void testCreateSearchLogEntry() {
        SearchLogEntry entry = new SearchLogEntry();
        entry.handsetId = 'MyTestHandsetId';
        entry.serverEntryTime = '2010-01-01 00:00:00';
        entry.submissionTime = '2010-01-01 00:00:00';
        entry.farmerId = 'MyTestFarmerId';
        entry.latitude = '0.00';
        entry.longitude = '0.00';
        entry.altitude = '0.00';
        entry.accuracy = '0.00';
        entry.submissionLatitude = '0.00';
        entry.submissionLongitude = '0.00';
        entry.submissionAltitude = '0.00';
        entry.submissionAccuracy = '0.00';
        entry.submissionGPSTime = '0';
        entry.category = 'Category';
        entry.query = 'Query';
        entry.content = 'Content';
        entry.msisdn = 'MyMsisdn';

        SearchLogEntry createdEntry = createNewSearchLogEntry(entry);
        System.assert(createdEntry.inserted);
        loadTestPerson();

        getInterviewer(entry);
        createFarmerPersonObject(entry);

        getFarmerPersonObject(entry);
        testcreateFarmerObject();

    }
}