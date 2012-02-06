public class Utils {

    /**
     *  Load a person__c object from a handset__r.IMEI__c
     *
     * @param imei - The handset imei of the person we are trying to load
     *
     * @return - The person sObject or null if they don't exist
     */
    public static Person__c loadPersonImei(String imei) {

        Person__c[] people =
            [SELECT
                Name,
                Id,
                District__r.Name,
                GPS_Location_E__c,
                GPS_Location_N__c
            FROM
                Person__c
            WHERE
                Handset__r.IMEI__c = :imei
            LIMIT 1];
        if (people.isEmpty()) {
            return null;
        }
        else {
            return people[0];
        }
    }

    /**
     *  Load a person__c object from an id
     *
     * @param id - The id of the person we are trying to load
     *
     * @return - The person sObject or null if they don't exist
     */
    public static Person__c loadPersonId(String id) {

        Person__c[] people =
            [SELECT
                Id,
                Village__c,
                Person_Household__c,
                GPS_Location_N__c,
                GPS_Location_E__c
            FROM
                Person__c
            WHERE
                Id = :id
            LIMIT 1];
        if (people.isEmpty()) {
            return null;
        }
        else {
            return people[0];
        }
    }

    /**
     *  Load a person__c object from the Person__c.Name
     *
     * @param name - The name of the person we are trying to load
     *
     * @return - The person sObject or null if they don't exist
     */
    public static Person__c loadPersonName(String name) {

        Person__c[] people =
            [SELECT
                Id,
                First_Name__c,
                Middle_Name__c,
                Last_Name__c,
                Fathers_Name__c,
                District__c,
                District__r.Name,
                Subcounty__c,
                Subcounty__r.Name,
                Parish__c,
                Village__c,
                GPS_Location_E__c,
                GPS_Location_N__c,
                Age__c,
                Date_of_Birth__c,
                Gender__c,
                Person_Household__c
            FROM
                Person__c
            WHERE
                Name = :name
            LIMIT 1];
        if (people.isEmpty()) {
            return null;
        }
        else {
            return people[0];
        }
    }

    /**
     * Load the test person. Used for test searches and surveys
     *
     * @return - The test perons
     */
    public static Person__c loadTestPerson() {
        Person__c person = new Person__c();
        Person__c[] people = [
            SELECT
                Id,
                GPS_Location_E__c ,
                GPS_Location_N__c
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

    /**
     *  Load a farmer from their unique Id number that is on the card they are given
     *
     * @param  id - The farmer id that we are trying to load 
     *
     * @return - List of farmers matching id. Should only be one
     */
    public static List<Farmer__c> loadFarmerFromId(String id) {

        Farmer__c[] farmer =
            [SELECT
                id,
                Name,
                Person__c,
                Person__r.GPS_Location_E__c,
                Person__r.GPS_Location_N__c,
                Crops__c,
                Land_Size__c,
                Livestock__c,
                Topics_of_Interest__c
            FROM
                Farmer__c
            WHERE
                Name = :id];
        return farmer;
    }

    /**
     *  Load a farmer from their unique Salesforce Id 
     *
     * @param  id - The farmer id that we are trying to load 
     *
     * @return - List of farmers matching id. Should only be one
     */
    public static List<Farmer__c> loadFarmerFromSalesforceId(String id) {

        Farmer__c[] farmer =
            [SELECT
                id,
                Name,
                Person__c,
                Person__r.GPS_Location_E__c,
                Person__r.GPS_Location_N__c,
                Crops__c,
                Land_Size__c,
                Livestock__c,
                Topics_of_Interest__c
            FROM
                Farmer__c
            WHERE
                Id = :id];
        return farmer;
    }

    /**
     * Get the unique farmer name from the salesforceId for that farmer
     *
     * @param farmerId - Salesforce Id for the farmer.
     *
     * @return - The farmers Name.
     */
    public static String getFarmerName(String farmerId) {

        Farmer__c[] farmers = loadFarmerFromSalesforceId(farmerId);
        if (farmers.size() == 0) {
            return 'Unavailable';
        }
        return farmers[0].Name;
    }

    /**
     *  Load a ckw from the ckw salesforce id
     *
     * @param  id - The ckw id that we are trying to load 
     *
     * @return - List of ckws matching id. Should only be one
     */
    public static List<CKW__c> loadCkwFromSalesforceId(String id) {

        CKW__c[] ckws =
            [SELECT
                id,
                Name
            FROM
                CKW__c
            WHERE
                Id = :id];
        return ckws;
    }

    /**
     *  Load a ckw from the CKW__c.Name
     *
     * @param  name - The CKW__c.Name that we are trying to load 
     *
     * @return - Ckw sObject or null
     */
    public static CKW__c loadCkwFromSalesforceName(String name) {

        CKW__c[] ckws =
            [SELECT
                id,
                Name,
                Active_Date__c,
                Status__c,
                Person__r.Name
            FROM
                CKW__c
            WHERE
                Name = :name];
        if (ckws.isEmpty()) {
            return null;
        }
        return ckws[0];
    }

    /**
     *  Load a ckw from the person salesforce id
     *
     * @param  id - The ckw id that we are trying to load 
     *
     * @return - List of ckws matching id. Should only be one
     */
    public static CKW__c loadCkwFromPersonSalesforceId(String id) {

        CKW__c[] ckws =
            [SELECT
                id,
                Name,
                Active_Date__c,
                Current_Performance_Review__c,
                Previous_Performance_Review__c,
                Status__c
            FROM
                CKW__c
            WHERE
                Person__c = :id];
        if (ckws.isEmpty()) {
            return null;
        }
        return ckws[0];
    }

    /**
     * Get the unique ckw name from the salesforceId for that ckw
     *
     * @param ckwId - Salesforce Id for the ckw.
     *
     * @return - The ckws Name.
     */
    public static String getCkwName(String ckwId) {

        CKW__c[] ckws = loadCkwFromSalesforceId(ckwId);
        if (ckws.size() == 0) {
            return 'Unavailable';
        }
        return ckws[0].Name;
    }

    /**
     *  Load a survey from the Salesforce Name 
     *
     *  @param surveyName - The Salesforce Name of the survey
     *
     *  @return - The survey
     */
    public static Survey__c loadSurvey(String surveyName) {

        Survey__c[] survey =
            [SELECT
                Id,
                Name,
                Survey_Name__c,
                Survey_Status__c,
                Start_Date__c,
                End_Date__c,
                Include_Poverty_Scorecard__c,
                Allow_No_Interviewee__c,
                Save_To_Salesforce__c,
                Post_Processing_Method__c,
                Account__r.Name
            FROM
                Survey__c
            WHERE
                Name = :surveyName
            ];
        if (survey.isEmpty()) {
            return null;
        }
        return survey[0];
    }

    /*
     *  Get all the surveys for a particular organisation
     *
     *  @param orgName - The organisation name
     *
     *  @return - A list of the surveys
     */
    public static Survey__c[] loadSurveysByOrgName(String orgName) {

        Survey__c[] surveys = [
            SELECT
                Id,
                Name
            FROM
                Survey__c
            WHERE
                Account__r.Name = :orgName];

        return surveys;
    }

    /**
     *  Load an organistaion from its Name
     *
     *  @param orgName - The name of the organisation
     *
     *  @return - The organisation
     */
    public static Account loadOrganisationFromName(String orgName) {

        Account[] org =
            [SELECT
                Id,
                Name
            FROM
                Account
            WHERE
                Name = :orgName
            ];
        if (org.isEmpty()) {
            return null;
        }
        return org[0];
    }

    /**
     *  Load the most recent poverty scorecard for a given person
     *
     *  @param personId - The is of the person we are looking for
     *
     *  @return - The persons most recent scorecard or null if there is not one.
     */
    public static Poverty_Scorecard__c loadCurrentPovertyScorecard(String personId) {

        // First see if this person has a current scorecard on their person object
        Person__c[] personScorecard =
            [SELECT
                Current_Poverty_Scorecard__c
            FROM
                Person__c
            WHERE
                id = :personId];
        if (!personScorecard.isEmpty()) {
            return loadPovertyScorecard(personScorecard[0].Current_Poverty_Scorecard__c);
        }

        // This person does not have a link on their person object so doe this the
        // old fashioned way
        Poverty_Scorecard__c[] allCards = loadPersonsPovertyScorecard(personId);
        if (allCards.isEmpty()) {
            return null;
        }
        return allCards[0];
    }

    /**
     *  Load a specific poverty scorecard.
     *
     *  @param id - The poverty scorecard id we are looking for
     *
     *  @return - Given poverty scorecard
     */
    public static Poverty_Scorecard__c loadPovertyScorecard(String id) {

        Poverty_Scorecard__c[] povertyScorecards =
            [SELECT
                CreatedDate,
                Children_Under_Eleven__c,
                Cooking_Fuel__c,
                Education_Level__c,
                Household_Members_Have_Clothes__c,
                Household_Members_Have_Shoes__c,
                Owns_Jewelry_Watch__c,
                Owns_Mosquito_Net__c,
                Owns_TV_Radio_Cassette__c,
                Roof_Material__c,
                Wall_Material__c
            FROM
                Poverty_Scorecard__c
            WHERE
                id = :id];

        if (povertyScorecards.isEmpty()) {
            return null;
        }
        else {
            return povertyScorecards[0];
        }
    }

    /**
     *  Load all the poverty scorecards for a person. Order by created date
     *
     *  @param id - The person id we are looking for
     *
     *  @return - A list of all the poverty scorecards
     */
     public static List<Poverty_Scorecard__c> loadPersonsPovertyScorecard(String id) {

        Poverty_Scorecard__c[] povertyScorecards =
            [SELECT
                CreatedDate,
                Children_Under_Eleven__c,
                Cooking_Fuel__c,
                Education_Level__c,
                Household_Members_Have_Clothes__c,
                Household_Members_Have_Shoes__c,
                Owns_Jewelry_Watch__c,
                Owns_Mosquito_Net__c,
                Owns_TV_Radio_Cassette__c,
                Roof_Material__c,
                Wall_Material__c
            FROM
                Poverty_Scorecard__c
            WHERE
                Person__c = :id
            ORDER BY
                Date__c DESC];

        if (povertyScorecards.isEmpty()) {
            return null;
        }
        else {
            return povertyScorecards;
        }
     }

    /**
     *
     *  @param personHouseholdId - The id of the house hold we arelooking for
     *
     *  @return - A list of the people in a household
     */
    public static List<Person__c> getHouseholdMembers(String personHouseholdId) {

        Person__c[] personList =
            [SELECT
                Id
            FROM
                Person__c
            WHERE
                Person_Household__c = :personHouseholdId];
        return personList;
    }

    /**
     *  Get the current organisation - person links for a given person
     *
     *  @param personId - The id of the person we are looking at
     */
     public static List<Person_Organisation_Association__c> getCurrentPersonOrganisationLinks(String personId) {

        Person_Organisation_Association__c[] currentLinks =
            [SELECT
                Person__c,
                Organisation__c,
                Organisation__r.Name
            FROM
                Person_Organisation_Association__c
            WHERE
                Person__c = :personId
                AND End_Date__c = null];
        return currentLinks;
     }

    /**
     *  Get the userId form the account Name that is attached to a user. Used when we are making api
     *  calls for other users and don't want ckwapi to be the owner of objects
     *
     *  @param accountName - The name of the account required
     *
     *  @return - The id for the owner or null
     */
    public static String getOwnerId(String accountName) {

        if (UserInfo.getUserType() == 'GUEST') {
            return null;
        }
        User[] user = [
            SELECT
                Id
            FROM
                User
            WHERE
                Contact.Account.Name = :accountName];

        if (user.size() == 0) {
            return null;
        }
        return (String)user[0].Id;
    }

    /**
     *  Get the organisation that is related to the user that is logged into our system. Or base it
     *  on the url of the page we are looking at.  Responsibility of the calling meethod to pass url.
     *  pass null if you want to look at the logged in user.
     *
     *  @return - The organisation name
     */
    public static String getOrgName(String url) {

        // Default to blank
        String orgName = 'null';
        System.debug(LoggingLevel.INFO, 'Url provided: ' + url);

        // If we are the guest user. Try to use the URL to get the page we are looking at. This will tell us
        // the organisation.
        if ((UserInfo.getUserType() == 'GUEST' && url != null) || url != null) {

            String pageName = getPageName(url);

            System.debug(LoggingLevel.INFO, 'Page Name: ' + pageName);
            if (pageName.equals('NaadsFarmerBaselineDashboard')) {
                orgName = 'NAADS';
            }
            if (pageName.equalsIgnoreCase('FvrDashboard')) {
                orgName = 'Farmer Voice Radio';
            }
        }
        else {

            // If we are logged on then get the account that the logged on user is attached to.
            User user = [
                SELECT
                    Contact.Account.Name
                FROM
                    User
                WHERE
                    Username = :UserInfo.getUserName()];
            if (user != null && user.Contact.Account.Name != null) {
                orgName = user.Contact.Account.Name;
            }
        }
        System.debug(LoggingLevel.INFO, 'The organisation name is ' + orgName);
        return orgName;
    }

    /**
     *  Parse a url to dig out the page name
     *
     *  @param url - the url that we are parsing
     *
     *  @return - The page name
     */
    public static String getPageName(String url) {

        System.debug(LoggingLevel.INFO, url);
        if (url == null) {
            return '';
        }

        // Find the second / The first char is the first /
        Integer startIndex = url.indexOf('/', 1);

        // Find the first ?
        Integer endIndex = url.indexOf('?', startIndex);
        if (endIndex < 0) {
            endIndex = url.length();
        }

        // Page name is inbetween these two
        String pageName = url.substring(startIndex + 1, endIndex);
        System.debug(LoggingLevel.INFO, pageName + ' ' + startIndex + ' ' + endIndex);
        return pageName;
    }

    /**
     *  Create a farmer for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param handsetId        - The Id of the handset to link to the person
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *  @param createAll        - Should the ckw be created from scratch i.e no existing person
     *  @param districtID       - The district for the CKW
     *  @param gender           - The gender for the CKW
     *
     *  @return - The test person object
     */
    public static Person__c createTestPerson(String handsetId, String appendCharacters, Boolean createAll, String districtId, String gender) {

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName_' + appendCharacters;
        testPerson.Last_Name__c = 'LastName_' + appendCharacters;
        if (gender == null) {
            gender = 'Female';
        }
        testPerson.Gender__c = gender;
        testPerson.District__c = districtId;
        if (createAll) {
            Phone__c phone = createTestHandset(appendCharacters);
            database.insert(phone);
            testPerson.Handset__c = phone.Id;
        }
        else {
            testPerson.Handset__c = handsetId;
        }
        return testPerson;
    }

    /**
     *  Create a farmer for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param farmerId - The id for the farmer
     *  @param personId - The Id of the person to link this farmer too
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *  @param createAll - Should the ckw be created from scratch i.e no existing person
     *
     *  @return - The test farmer object
     */
    public static Farmer__c createTestFarmer(String farmerId, String personId, String appendCharacters, Boolean createAll, String districtId, String gender) {

        Farmer__c testFarmer = new Farmer__c();
        testFarmer.Name = farmerId;
        if (createAll) {
            Person__c person = createTestPerson('', appendCharacters, createAll, districtId, gender);
            database.insert(person);
            testFarmer.Person__c = person.Id;
        }
        else {
            testFarmer.Person__c = personId;
        }
        return testFarmer;
    }

    /**
     *  Create a CKW for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param personId         - The Id of the person to link this CKW too
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *  @param createAll        - Should the ckw be created from scratch i.e no existing person
     *  @param districtID       - The district for the CKW
     *  @param gender           - The gender for the CKW
     *
     *  @return - The test CKW object
     */
    public static CKW__c createTestCkw(String personId, String appendCharacters, Boolean createAll, String districtId, String gender) {

        CKW__c testCkw = new CKW__c();
        if (createAll) {
            Person__c person = createTestPerson('', appendCharacters, createAll, districtId, gender);
            database.insert(person);
            testCkw.Person__c = person.Id;
        }
        else {
            testCkw.Person__c = personId;
        }
        return testCkw;
    }

    /**
     *  Create a Handset for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param serialNumber  - The serial number you want to use.
     *
     *  @return - The test handset object
     */
    public static Phone__c createTestHandset(String appendCharacters) {

        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = appendCharacters;
        testHandset.Serial_Number__c = appendCharacters;
        testHandset.Purchase_Value_USD__c = 100.00;
        return testHandset;
    }

    /**
     *  Create an Organisation for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *
     *  @return - The test account object
     */
    public static Account createTestOrganisation(String appendCharacters) {

        Account testOrg = new Account();
        testOrg.Name = 'TestOrg_' + appendCharacters;
        testOrg.BillingState = 'CA';
        return testOrg;
    }

    /**
     *  Create a test survey
     *
     *  @param org              - The organisation that this survey is for
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     */
    public static Survey__c createTestSurvey(Account org, String appendCharacters) {

        Survey__c survey = new Survey__c();
        survey.Account__c = org.Id;
        return survey;
    }

    /**
     *  Create a test submission.
     *
     *  @param interviewerId    - The person id of the interviewer
     *  @param intervieweeId    - The person id of the interviewee
     *  @param surveyId         - The survey id that this submission is for
     *  @param submissionTime   - The time that the submission was submitted
     *  @param appendCharacters - A string of characters to append to a result hash to make it unique
     */
    public static Submission_Meta_Data__c createTestSubmission(
            String interviewerId,
            String intervieweeId,
            String surveyId,
            Datetime submissionTime,
            String appendCharacters
    ) {

        Submission_Meta_Data__c submission = new Submission_Meta_Data__c();
        submission.Interviewer__c = interviewerId;
        submission.Interviewee__c = intervieweeId;
        submission.Survey__c = surveyId;
        submission.Handset_Submit_Time__c = submissionTime;
        submission.Result_Hash__c = 'ResultHash' + surveyId + appendCharacters;

        // The size of the submission. Hard coding this as we don't really care for tests
        submission.Submission_Size__c = 100;
        return submission;
    }

    /**
     *  Create a test submission answer
     *
     *  @param submissionId - The Id of the submission meta data that this answer is for
     *  @param binding      - The question binding
     *  @param answer       - The answer to the question
     *  @param answerType   - The type of question that this answer is for
     *  @param questionText - The text of the question. Allows for easier reading out at the end
     */
    public static Submission_Answer__c createTestSubmissionAnswer(
            String submissionId,
            String binding,
            String answer,
            String answerType,
            String questionText,
            Integer instance
    ) {

        Submission_Answer__c submissionAnswer = new Submission_Answer__c();
        submissionAnswer.Submission_Meta_Data__c = submissionId;
        submissionAnswer.Binding__c = binding;
        submissionAnswer.Answer__c = answer;
        if (answer.length() < 256) {
            submissionAnswer.Answer_Short_Text__c = answer;
        }
        if (answerType == null) {
            answerType = 'Input';
        }
        if (questionText == null) {
            questionText = 'TESTER';
        }
        if (instance != null) {
            submissionAnswer.Instance__c = instance;
        }
        submissionAnswer.Question_Text__c = questionText;
        submissionAnswer.Type__c = answerType;
        return submissionAnswer;
    }

    /**
     *  Create a country used in testing
     *  @param displayName - The display name for the country
     */
    public static Country__c createTestCountry(String displayName) {

        Country__c country = new Country__c();
        country.Name = displayName;
        return country;
    }

    /**
     *  Create a region used in testing
     *
     *  @param displayName - The display name for the region
     *  @param country     - The country that this region is in
     */
    public static Region__c createTestRegion(String displayName, Country__c country) {

        Region__c region = new Region__c();
        region.Display_Name__c = displayName;
        region.Country__c = country.Id;
        return region;
    }

    /**
     *  Create a District for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *
     *  @return - The test District__c object
     */
    public static District__c createTestDistrict(String appendCharacters) {

        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestDistrict_' + appendCharacters;
        return testDistrict;
    }

    /**
     *  Create a Subcounty for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *
     *  @return - The test Subcounty__c object
     */
    public static Subcounty__c createTestSubcounty(String appendCharacters, Id districtId) {

        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestSubcounty_' + appendCharacters;
        testSubcounty.District__c = districtId;
        return testSubcounty;
    }

    /**
     *  Create a metric for testing
     *
     *  @param orgId            - The Organisation this is for.
     *  @param calculationType  - The type of calculation that this is for. If passed null will set to none
     *  @param area             - The metric area this is for
     *  @param subDivide        - Should this metric be subdivided
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     */
    public static M_E_Metric__c createTestMetric(
            Account org,
            String calculationType,
            String area,
            Boolean subDivide,
            String appendCharacters
    ) {

        M_E_Metric__c metric = new M_E_Metric__c();
        metric.Name = org.Name + '_' + appendCharacters;
        metric.Organisation__c = org.Id;
        if (calculationType == null) {
            calculationType = 'None';
        }
        metric.Calculation_Type__c = calculationType;
        metric.M_E_Area__c = area;
        metric.Sub_Divide__c = subDivide;
        metric.Update_Period__c = 'Daily';
        return metric;
    }

    /**
     *  Create a test metric data object
     *
     *  @param district    - district for this metric. Can be null
     *  @param metric      - metric this data is linked to
     *  @param actualValue - Actual value for the metric
     *  @param manualValue - Manual value for the metric. Can be null
     *  @param startDate   - Start date for the metric
     */
    public static M_E_Metric_Data__c createTestMetricData(
            District__c district,
            M_E_Metric__c metric,
            Decimal actualValue,
            Decimal manualValue,
            Date startDate
    ) {

        M_E_Metric_Data__c metricData = new M_E_Metric_Data__c();
        metricData.District__c = district.Id;
        metricData.M_E_Metric__c = metric.Id;
        metricData.Actual_Value__c = actualValue;
        metricData.Manual_Value__c = manualValue;
        metricData.Date__c = startDate;
        return metricData;
    }

    public static Person_Organisation_Association__c creatTestPersonOrgLink(String personId, String orgId) {

        Person_Organisation_Association__c link = new Person_Organisation_Association__c();
        link.Person__c = personId;
        link.Organisation__c = orgId;
        return link;
    }

    /**
     *  Create a poverty scorecard for use in testing. Will just create the basic required details.
     *  Other details need to be added by calling test method.
     *
     *  @param level - How poor should the scorecard be.
     *                 Valid options are:-
     *                                   - VERYPOOR
     *                                   - POOR
     *                                   - RICH
     *  @param personId - The id of the person this scorecard is for
     *  @param createAll - Should the ckw be created from scratch i.e no existing person
     *  @param appendCharacters - A string of characters to append to a name to make it unique
     *
     *  @return - The test account object
     */

    public static Poverty_Scorecard__c createTestPovertyScorecard(String level, String personId, Boolean createAll, String appendCharacters) {

        Poverty_Scorecard__c testScorecard = new Poverty_Scorecard__c();
        if (createAll) {
            Person__c person = createTestPerson(null, appendCharacters, createAll, null, null);
            testScorecard.Person__c = person.Id;
        }
        else {
            testScorecard.Person__c = personId;
        }
        if (level.equalsIgnoreCase('RICH')) {
            testScorecard.Children_Under_Eleven__c = 2.0;
            testScorecard.Cooking_Fuel__c = 'Firewood';
            testScorecard.Education_Level__c = 'Graduate';
            testScorecard.Household_Members_Have_Clothes__c = true;
            testScorecard.Household_Members_Have_Shoes__c = true;
            testScorecard.Owns_Jewelry_Watch__c = true;
            testScorecard.Owns_Mosquito_Net__c = true;
            testScorecard.Owns_TV_Radio_Cassette__c = true;
            testScorecard.Roof_Material__c = 'Cement/other';
            testScorecard.Wall_Material__c = 'Burnt bricks with cement';
        }
        else if (level.equalsIgnoreCase('POOR')) {
            testScorecard.Children_Under_Eleven__c = 4.0;
            testScorecard.Cooking_Fuel__c = 'Firewood';
            testScorecard.Education_Level__c = 'O level';
            testScorecard.Household_Members_Have_Clothes__c = true;
            testScorecard.Household_Members_Have_Shoes__c = false;
            testScorecard.Owns_Jewelry_Watch__c = true;
            testScorecard.Owns_Mosquito_Net__c = false;
            testScorecard.Owns_TV_Radio_Cassette__c = true;
            testScorecard.Roof_Material__c = 'Iron sheet/tin';
            testScorecard.Wall_Material__c = 'Burnt bricks with mud/mud poles';
        }
        else {
            testScorecard.Children_Under_Eleven__c = 2.0;
            testScorecard.Cooking_Fuel__c = 'Firewood';
            testScorecard.Education_Level__c = 'No grade completed';
            testScorecard.Household_Members_Have_Clothes__c = false;
            testScorecard.Household_Members_Have_Shoes__c = false;
            testScorecard.Owns_Jewelry_Watch__c = false;
            testScorecard.Owns_Mosquito_Net__c = false;
            testScorecard.Owns_TV_Radio_Cassette__c = false;
            testScorecard.Roof_Material__c = 'Thatch/straw';
            testScorecard.Wall_Material__c = 'Unburnt bricks';
        }
        return testScorecard;
    }

	/**
	 * Returns the distance from this point to the supplied point, in km 
	 * (using Haversine formula)
	 *
	 * from: Haversine formula - R. W. Sinnott, "Virtues of the Haversine",
	 *       Sky and Telescope, vol 68, no 2, 1984
	 * */
	public static Decimal calcDistance(Decimal lat1, Decimal lng1, Decimal lat2, Decimal lng2) {
		if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
			return 0.0;
		}
		Decimal earthRadius = 6371;
		Decimal pi = 3.141592653589793238462643383279502884197;
		Decimal lat1Rad = lat1 * pi / 180;
		Decimal lat2Rad = lat2 * pi /180;
		Decimal lng1Rad = lng1 * pi / 180;
		Decimal lng2Rad = lng2 * pi /180;
		Decimal dLat = lat2Rad - lat1Rad;
		Decimal dLon = lng2Rad - lng1Rad;
	
	   	Decimal varA = math.sin(dLat/2) * math.sin(dLat/2) +
         		math.cos(lat1Rad) * math.cos(lat2Rad) * 
          		math.sin(dLon/2) * math.sin(dLon/2);
          		
	  	Decimal varC = 2 * math.atan2(math.sqrt(varA), math.sqrt(1-varA));
	  	Decimal varD = earthRadius * varC;
	  	
	  	return varD;
	}
	
    static testMethod void testAll() {

        // Create a CKW
        CKW__c ckw = createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Create povery scorecards
        Poverty_Scorecard__c  povertyScorecard1 = createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);
        Poverty_Scorecard__c  povertyScorecard2 = createTestPovertyScorecard('VERYPOOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard2);
        Poverty_Scorecard__c  povertyScorecard3 = createTestPovertyScorecard('RICH', farmer1.Person__c, false, '');
        database.insert(povertyScorecard3);
        Poverty_Scorecard__c  povertyScorecard4 = createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard4);

        // Create an organisation.
        Account org = createTestOrganisation('TestOrg1');
        database.insert(org);

        // Create a farmer group link
        database.insert(creatTestPersonOrgLink(farmer1.Person__c, org.Id));

        // Run tests.
        Person__c loadIMEI = loadPersonImei(ckw.Person__r.Handset__r.IMEI__c);
        System.assert(loadIMEI != null);

        Person__c loadID = loadPersonId(ckw.Person__c);
        System.assert(loadID != null);

        Farmer__c[] farmerName = loadFarmerFromId(farmer1.Name);
        System.assert(farmerName.size() == 1);

        Poverty_Scorecard__c currentPS = loadCurrentPovertyScorecard(farmer1.Person__c);
        System.assert(currentPS != null);

        loadPovertyScorecard(currentPS.Id);

        Poverty_Scorecard__c[] allPS = loadPersonsPovertyScorecard(farmer1.Person__c);
        System.assert(allPS.size() == 4);

        Person_Organisation_Association__c[] farmerGroups = getCurrentPersonOrganisationLinks(farmer1.Person__c);
        System.assert(farmerGroups.size() == 1);
        
        // Test calcDistance
        System.assert(Utils.calcDistance(0.0,0.0,0.0,0.0) == 0.0);
    }
}