public class CkwRegistration {

    /**
     *  Static class to deal with the auto registration of a CKW from the surveys submitted by
     *  the recruitment team and the CKW themselves.
     */

    /**
     *  Process the initial registration form submitted by the recruitment team.
     *  Will create the Person__c and CKW__c object for this new potential CKW.
     *  For the moment the handset will need to be manually registered to the CKW
     *
     *  @param answers   - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param recruiter - The Person__c object for the recruiter who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
    public static List<String> processCkwRegistration(Map<String, Submission_Answer__c> answers, Person__c recruiter) {

        List<String> returnValues = new List<String>();

        Person__c person = new Person__c();
        CKW__c ckw = new CKW__c();

        // For this all the instance numbers will be 0
        // Add the values that are just plain text
        person.First_Name__c = answers.get('first_name_0').Answer__c;
        person.Middle_Name__c = answers.get('middle_name_0').Answer__c;
        person.Last_Name__c = answers.get('last_name_0').Answer__c;
        person.Fathers_Name__c = answers.get('fathers_name_0').Answer__c;
        person.Parish__c = answers.get('parish_0').Answer__c;
        person.Village__c = answers.get('village_0').Answer__c;

        // Translate the single/multiple selects
        // Gender
        person.Gender__c = translateGender(answers.get('gender_0').Answer__c);

        District__c district = getDistrict(answers.get('district_0').Answer__c);
        Subcounty__c subcounty = getSubCounty(answers.get('subcounty_0').Answer__c, district.Id);
        if (subcounty == null) {
            returnValues.add('0');
            returnValues.add('Subcounty with name ' + answers.get('subcounty_0').Answer__c + ' not in the system');
            returnValues.add('Subcounty name is not recognised. Please check spelling. Report to tech team if spelling is correct and this message appears');
           return returnValues;
        }
        person.Subcounty__c = subcounty.Id;
        person.District__c = subcounty.District__c;
        String[] locationArray = answers.get('locationCkw_0').Answer__c.split(' ');
        if (locationArray != null && locationArray.size() >= 2) {
            person.GPS_Location_E__c = locationArray[0];
            person.GPS_Location_N__c = locationArray[1];
        }

        // Calculate the age of the person. Should this be a formula on Person
        // DOB comes in with the format YYYY-MM-dd (2011-09-30)
        Date dob = calculateDob(answers.get('dob_0').Answer__c);
        if (dob != null) {
            person.Date_of_Birth__c = dob;
            person.Age__c = calculateAge(dob);
        }

        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save the person and get the id back
        String errorMessage;
        Database.SaveResult personSaveResult = database.insert(person);
        Id personId;
        if (!personSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : personSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CKW recruitment survey had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(sp);
            return returnValues;
        }
        personId = personSaveResult.getId();

        // Populate and save the CKW
        ckw.Person__c = personId;
        Database.SaveResult ckwSaveResult = database.insert(ckw);
        if (!ckwSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : ckwSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CKW recruitment survey had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(sp);
            return returnValues;
        }

        // Create the links to any organisations that the CKW is to work for
        String[] organisations = answers.get('partner_0').Answer__c.split(' ');
        if (organisations != null && organisations.size() > 0) {
            List<Person_Organisation_Association__c> partnerLinks = new List<Person_Organisation_Association__c>();
            for (String orgName : organisations) {

                // Load the organistaion
                Account org = Utils.loadOrganisationFromName(orgName);
                if (org == null) {
                    continue;
                }
                Person_Organisation_Association__c link = new Person_Organisation_Association__c();
                link.Person__c = personId;
                link.Organisation__c = org.Id;
                partnerLinks.add(link);
            }

            // Save all the links
            if (partnerLinks.size() > 0) {
                Database.SaveResult[] orgLinkSaveResults = database.insert(partnerLinks);
                Boolean fail = false;
                for (Database.SaveResult orgLinkSaveResult : orgLinkSaveResults) {
                    if (!orgLinkSaveResult.isSuccess()) {
                        returnValues.add('0');
                        fail = true;
                        for (Database.Error error : orgLinkSaveResult.getErrors()) {

                            // Build up the error message
                            errorMessage = errorMessage + error.getMessage() + ' ';
                        }
                    }
                }
                if (fail) {
                    returnValues.add(errorMessage);
                    returnValues.add('Your submission of the CKW recruitment survey had an error in it please check the form. If you repeatedly get this message contact support');
                    Database.rollback(sp);
                    return returnValues;
                }
            }
        }

        returnValues.add('1');
        returnValues.add('Successfully saved the CKW registration');
        returnValues.add('Successfully saved the CKW registration');
        return returnValues;
    }

    /**
     *  Process the CKW baseline form submitted by the CKW during training
     *  Will create the Poverty_Scorecard__c for the CKW when the baseline survey is submitted.
     *  Will only allow the Poverty_Scorecard__c to be updated if there is more than 45 days between submission.
     *  This will mean that the CKW can fill in the baseline as many times as they like but will only the first
     *  submission will be registered.
     *
     *  @param answers - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param ckw     - The Person__c object for the ckw who submitted the form
     *
     *  @return - A tuple list of Strings with the following format
     *              element 1 - Indicator of success (0 = fail, 1 = success, 2 = success but provide feedback message)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
    public static List<String> processCkwBaseline(Map<String, Submission_Answer__c> answers, Person__c ckw) {

        List<String> returnValues = new List<String>();

        // Check to see that this CKW has a poverty scorecard and that it is more that 45 days old
        Poverty_Scorecard__c currentScorecard = Utils.loadCurrentPovertyScorecard(String.valueOf(ckw.Id));
        if (currentScorecard != null) {
            if (date.today().daysBetween(currentScorecard.CreatedDate.date()) < 45) {
                returnValues.add('2');
                returnValues.add('You have already submitted your baseline details');
                returnValues.add('You have already submitted your baseline details');
                return returnValues;
            }
        }

        Poverty_Scorecard__c newScorecard = new Poverty_Scorecard__c();
        newScorecard.Children_Under_Eleven__c = translateChildren(answers.get('q11_0').Answer__c);

        // Translate the single select options
        newScorecard.Roof_Material__c = translateRoofMaterial(answers.get('q9_0').Answer__c);
        newScorecard.Wall_Material__c = answers.get('q10_0').Answer__c;
        newScorecard.Education_Level__c = answers.get('q12_0').Answer__c;
        newScorecard.Cooking_Fuel__c = answers.get('q13_0').Answer__c;

        // Get the boolean values
        newScorecard.Owns_TV_Radio_Cassette__c = answers.get('q14_0').Answer__c.equals('1') ? false : true;
        newScorecard.Owns_Mosquito_Net__c = answers.get('q15_0').Answer__c.equals('1') ? false : true;
        newScorecard.Household_Members_Have_Clothes__c = answers.get('q16_0').Answer__c.equals('1') ? false : true;
        newScorecard.Household_Members_Have_Shoes__c = answers.get('q17_0').Answer__c.equals('1') ? false : true;
        newScorecard.Owns_Jewelry_Watch__c = answers.get('q18_0').Answer__c.equals('1') ? false : true;
        newScorecard.Person__c = ckw.Id;

        // Save the poverty scorecard
        Database.SaveResult scorecardSaveResult = database.insert(newScorecard);
        String errorMessage = '';
        if (!scorecardSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : scorecardSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CKW Baseline survey had an error in it please check the form. If you repeatedly get this message contact support');
            return returnValues;
        }

        // Activate the CKW if not done so already. The active date should be the friday of the
        // week that this form was submitted in as that is the end of training.
        CKW__c ckwSObject = Utils.loadCkwFromPersonSalesforceId(ckw.Id);
        if (ckwSObject != null && ckwSObject.Status__c != 'Active') {
            Date activeDate = date.today().toStartOfWeek().addDays(5);
            ckwSObject.Status__c = 'Active';
            ckwSObject.Active_Date__c = activeDate;
            database.update(ckwSObject);
        }

        returnValues.add('1');
        returnValues.add('Successfully processed the CKW Baseline');
        returnValues.add('Successfully processed your CKW Baseline');
        return returnValues;
    }

    /**
     *  Process the form that updates the CKW details. This form is used when a CKW has failed to submit a baseline
     *  or a staff memeber wishes to make lots of changes to a CKWs details in the field
     *
     *  @param answers - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param ckw     - The Person__c object for the ckw/staff member who submitted the form
     *
     *  @return - A tuple list of Strings with the following format
     *              element 1 - Indicator of success (0 = fail, 1 = success, 2 = success but provide feedback message)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
    public static List<String> processCkwUpdate(Map<String, Submission_Answer__c> answers, Person__c ckw) {

        List<String> returnValues = new List<String>();

        // Check that the ID submitted in the form actually matches someone in our system
        String id = null;
        if (!answers.containsKey('id_0')) {
            returnValues.add('0');
            returnValues.add('The submitted survey does not contain an ID for the person being updated');
            returnValues.add('The submitted survey does not contain an ID for the person being updated');
            return returnValues;
        }
        id = answers.get('id_0').Answer__c;
        if (id == null || id.equals('null')) {
            returnValues.add('0');
            returnValues.add('The submitted survey does not contain an ID for the person being updated');
            returnValues.add('The submitted survey does not contain an ID for the person being updated');
            return returnValues;
        }

        // The id can be a Person__c.Name or a CKW__c.Name
        Person__c personToUpdate = null;
        CKW__c ckwToUpdate = null;
        Boolean isCkwId = id.toUpperCase().startsWith('CKW');

        if (isCkwId) {
            ckwToUpdate = Utils.loadCkwFromSalesforceName(id);
            if (ckwToUpdate == null) {
                returnValues.add('0');
                returnValues.add('The CKW ID - ' + id + ' does not exist on our system');
                returnValues.add('The CKW ID - ' + id + ' does not exist on our system');
                return returnValues;
            }
            personToUpdate = Utils.loadPersonName(ckwToUpdate.Person__r.Name);
        }
        else {
            personToUpdate = Utils.loadPersonName(id);
        }
        if (personToUpdate == null) {
            returnValues.add('0');
            returnValues.add('The ID ' + id + ' does not have a person object associated with it');
            returnValues.add('The ID ' + id + ' does not have a person object associated with it');
            return returnValues;
        }

        // As all of the questions on this form are optional we need to go through a rather dull process now.
        if (answers.containsKey('first_name_0') && !answers.get('first_name_0').Answer__c.equals('null')) {
            personToUpdate.First_Name__c = answers.get('first_name_0').Answer__c;
        }
        if (answers.containsKey('middle_name_0') && !answers.get('middle_name_0').Answer__c.equals('null')) {
            personToUpdate.Middle_Name__c = answers.get('middle_name_0').Answer__c;
        }
        if (answers.containsKey('last_name_0') && !answers.get('last_name_0').Answer__c.equals('null')) {
            personToUpdate.Last_Name__c = answers.get('last_name_0').Answer__c;
        }
        if (answers.containsKey('fathers_name_0') && !answers.get('fathers_name_0').Answer__c.equals('null')) {
            personToUpdate.Fathers_Name__c = answers.get('fathers_name_0').Answer__c;
        }

        // Update the location for the Person. If one has beed updated then the other must be changed
        if ((answers.containsKey('subcounty_0') && !answers.get('subcounty_0').Answer__c.equals('null'))
                && (answers.containsKey('district_0') && !answers.get('district_0').Answer__c.equals('null'))
        ) {
            District__c district = getDistrict(answers.get('district_0').Answer__c);
            Subcounty__c subcounty = getSubCounty(answers.get('subcounty_0').Answer__c, district.Id);
            if (subcounty == null) {
                returnValues.add('0');
                returnValues.add('Subcounty with name ' + answers.get('subcounty_0').Answer__c + ' not in the system');
                returnValues.add('Subcounty name is not recognised. Please check spelling. Report to tech team if spelling is correct and this message appears');
            return returnValues;
            }
            personToUpdate.Subcounty__c = subcounty.Id;
            personToUpdate.District__c = subcounty.District__c;
        }
        if (answers.containsKey('parish_0') && !answers.get('parish_0').Answer__c.equals('null')) {
            personToUpdate.Parish__c = answers.get('parish_0').Answer__c;
        }
        if (answers.containsKey('village_0') && !answers.get('village_0').Answer__c.equals('null')) {
            personToUpdate.Village__c = answers.get('village_0').Answer__c;
        }
        if (answers.containsKey('dob_0') && !answers.get('dob_0').Answer__c.equals('null')) {
            Date dob = calculateDob(answers.get('dob_0').Answer__c);
            if (dob != null) {
                personToUpdate.Date_of_Birth__c = dob;
                personToUpdate.Age__c = calculateAge(dob);
            }
        }
        if (answers.containsKey('gps_0') && !answers.get('gps_0').Answer__c.equals('null')) {
            String[] locationArray = answers.get('gps_0').Answer__c.split(' ');
            if (locationArray != null && locationArray.size() >= 2) {
                personToUpdate.GPS_Location_E__c = locationArray[0];
                personToUpdate.GPS_Location_N__c = locationArray[1];
            }
        }
        if (answers.containsKey('gender_0') && !answers.get('gender_0').Answer__c.equals('null')) {
            personToUpdate.Gender__c = translateGender(answers.get('gender_0').Answer__c);
        }

        // For CKW only
        if (isCkwId) {
            if (answers.containsKey('status_0') && !answers.get('status_0').Answer__c.equals('null')) {
                ckwToUpdate.Status__c = answers.get('status_0').Answer__c;
            }
            if (answers.containsKey('active_date_0') && !answers.get('active_date_0').Answer__c.equals('null')) {
                Date activeDate = calculateDob(answers.get('active_date_0').Answer__c);
                if (activeDate != null) {
                    ckwToUpdate.Active_Date__c = activeDate;
                }
            }
        }

        database.update(personToUpdate);
        if (isCkwId) {
            database.update(ckwToUpdate);
        }
        returnValues.add('1');
        returnValues.add('Successfully updated Person details for id ' + id);
        returnValues.add('Successfully updated Person details for id ' + id);
        return returnValues;
    }

    public static List<String> processSubcounties(Map<String, Submission_Answer__c> answers, Person__c ckw) {

        List<String> returnValues = new List<String>();

        // Pull out and load the district
        District__c district = getDistrict(answers.get('district_0').Answer__c);
        if (district == null) {

            // District does not exist so return an error
            returnValues.add('0');
            returnValues.add('The District ' + answers.get('district_0').Answer__c + ': Does not exist in our System. Contact tech team');
            returnValues.add('The District ' + answers.get('district_0').Answer__c + ': Does not exist in our System. Contact tech team');
            return returnValues;
        }

        // Remove district from answers
        //answers.remove('district_0');

        // Get all the existing subcounties for this district
        Map<String, Subcounty__c> existingCountiesMap = getExistingSubcounties(answers.get('district_0').Answer__c);

        // Loop through the remaining answers and pull out the subcounties
        List<Subcounty__c> subcounties = new List<Subcounty__c>();
        for (String key : answers.keySet()) {

            // Check it is a subcounty question
            if (key.contains('subcounty')) {

                // Check that the subcounty has not already been added to the district
                if (existingCountiesMap == null || !existingCountiesMap.containsKey(answers.get(key).Answer__c)) {

                    // Create the new subcounty
                    Subcounty__c newSubcounty = new Subcounty__c();
                    newSubcounty.Display_Name__c = answers.get(key).Answer__c;
                    newSubcounty.District__c = district.Id;
                    subcounties.add(newSubcounty);
                }
            }
        }

        // Insert the new subcounties into the db
        if (subcounties.size() > 0) {
            database.insert(subcounties);
        }
        returnValues.add('1');
        returnValues.add('All submitted subcounties are now in Salesforce for District: ' + answers.get('district_0').Answer__c);
        returnValues.add('All submitted subcounties are now in Salesforce for District: ' + answers.get('district_0').Answer__c);
        return returnValues;
    }

    private static Map<String, Subcounty__c> getExistingSubcounties(String districtName) {

        Map<String, Subcounty__c> subcountyMap = new Map<String, Subcounty__c>();
        Subcounty__c[] subcounties = [
            SELECT
                Id,
                Name,
                Display_Name__c
            FROM
                Subcounty__c
            WHERE
                District__r.Name = :districtName];

        if (subcounties.size() == 0) {
            return null;
        }
        for (Subcounty__c subcounty : subcounties) {
            subcountyMap.put(subcounty.Display_Name__c, subcounty);
        }
        return subcountyMap;
    }

    private static Date calculateDob(String dobString) {

        Date dob = null;

        // DOB comes in with the format YYYY-MM-dd (2011-09-30)
        String[] dobParts = dobString.split('-');
        if (dobParts.size() == 3) {
            dobString = dobParts[1] + '/' + dobParts[2] + '/' + dobParts[0];

            dob = Date.parse(dobString);
        }
        return dob;
    }

    private static Integer calculateAge(Date dob) {

        Date now = date.today();
        Integer yearsBetween = now.year() - dob.year();
        Integer monthDifference = now.month() - dob.month();
        if (monthDifference == 0) {
            Integer dayOfMonth = now.day() - dob.day();
            if (dayOfMonth <= 0) {
                yearsBetween--;
            }
        }
        else if (monthDifference < 0) {
            yearsBetween++;
        }
        return yearsBetween;
    }

    private static String translateGender(String optionNumber) {

        if (optionNumber.equals('1')) {
            return 'Male';
        }
        return 'Female';
    }

    private static Decimal translateChildren(String optionNumber) {
        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            '1' => 4.0,
            '2' => 3.0,
            '3' => 2.0,
            '4' => 1.0,
            '5' => 0.0
        };
        return translationMap.get(optionNumber);
    }

    private static String translateRoofMaterial(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Thatch/straw',
            '2' => 'Iron sheet/tin',
            '3' => 'Cement/other'
        };
        return translationMap.get(optionNumber);
    }

    private static String translateWallMaterial(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Unburnt bricks',
            '2' => 'Burnt bricks with mud/mud poles',
            '3' => 'Burnt bricks with cement'
        };
        return translationMap.get(optionNumber);
    }

    private static String translateEducation(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'No grade completed',
            '2' => 'Primary education',
            '3' => 'O level',
            '4' => 'A level',
            '5' => 'Certificate',
            '6' => 'Graduate'
        };
        return translationMap.get(optionNumber);
    }

    private static String translateFuel(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Firewood',
            '2' => 'Charcoal/paraffin/other'
        };
        return translationMap.get(optionNumber);
    }

    private static District__c getDistrict(String districtName) {

        District__c[] district = database.query(SoqlHelpers.getDistrict(districtName));
        if (district.isEmpty() || district.size() == 0) {
            return null;
        }
        else {
            return district[0];
        }
    }

    private static Subcounty__c getSubCounty(String subcountyName, Id districtId) {

        Subcounty__c[] subcounty = database.query(SoqlHelpers.getSubcounty(subcountyName, districtId));
        if (subcounty.isEmpty() || subcounty.size() == 0) {
            return null;
        }
        else {
            return subcounty[0];
        }
    }

    static testMethod void testGetLocation() {

        // Create test district.
        District__c district = Utils.createTestDistrict('Here');
        database.insert(district);
        District__c districtId = getDistrict(district.Name);
        System.assertEquals(districtId.Id, district.Id);

        Subcounty__c subcounty = Utils.createTestSubCounty('HERE', district.Id);
        database.insert(subcounty);
        Subcounty__c subcountyId = getSubcounty(subcounty.Display_Name__c, district.Id);
        System.assertEquals(subcountyId.Id, subcounty.Id);
    }

    static testMethod void testProcessCkwReg() {

        // Create the test person
        Person__c person = Utils.createTestPerson(null, 'TestRegBE2SF', true, null, 'Female');

        // Create a test Organisation
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);

        // Create a test Organisation
        Account org2 = Utils.createTestOrganisation('TestOrg2');
        database.insert(org2);

        District__c district = [SELECT Name FROM District__c WHERE Name = 'Gulu'];

        Subcounty__c subcounty = Utils.createTestSubcounty('There', district.Id);
        database.insert(subcounty);

        // Test successful registration
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('first_name_0', Utils.createTestSubmissionAnswer(null, 'first_name', 'Simon', '', '', 0));
        answers.put('middle_name_0', Utils.createTestSubmissionAnswer(null, 'middle_name', 'George', '', '', 0));
        answers.put('last_name_0', Utils.createTestSubmissionAnswer(null, 'last_name', 'Bob', '', '', 0));
        answers.put('fathers_name_0', Utils.createTestSubmissionAnswer(null, 'fathers_name', 'Mike', '', '', 0));
        answers.put('parish_0', Utils.createTestSubmissionAnswer(null, 'parish', 'There', '', '', 0));
        answers.put('village_0', Utils.createTestSubmissionAnswer(null, 'village', 'Here', '', '', 0));
        answers.put('gender_0', Utils.createTestSubmissionAnswer(null, 'gender', '1', '', '', 0));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'Gulu', '', '', 0));
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', subcounty.Display_Name__c, '', '', 0));
        answers.put('locationCkw_0', Utils.createTestSubmissionAnswer(null, 'locationCkw', '32.5 2.0', '', '', 0));
        answers.put('dob_0', Utils.createTestSubmissionAnswer(null, 'dob', '2011-09-30', '', '', 0));
        answers.put('partner_0', Utils.createTestSubmissionAnswer(null, 'partner', org.Name + ' ' + org2.Name, '', '', 0));
        List<String> result = processCkwRegistration(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));
        System.assert(result.get(2).equals('Successfully saved the CKW registration'));

        // Test subcounty fail
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'NOPE', '', '', '', 0));
        result = processCkwRegistration(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('0'));
        System.assert(result.get(2).equals('Subcounty name is not recognised. Please check spelling. Report to tech team if spelling is correct and this message appears'));
    }

    static testMethod void testCkwBaselineProcessing() {

        CKW__c ckw = Utils.createTestCkw(null, 'TestCkwBase1', true, null, 'Female');
        database.insert(ckw);

        Person__c person = [SELECT Id FROM Person__c WHERE id IN (SELECT Person__c FROM CKW__c WHERE id = :ckw.Id)];

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11_0', '3', '', '', 0));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9_0', '1', '', '', 0));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10_0', '2', '', '', 0));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12_0', '5', '', '', 0));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13_0', '3', '', '', 0));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14_0', '1', '', '', 0));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15_0', '2', '', '', 0));
        answers.put('q16_0', Utils.createTestSubmissionAnswer(null, 'q16_0', '1', '', '', 0));
        answers.put('q17_0', Utils.createTestSubmissionAnswer(null, 'q17_0', '2', '', '', 0));
        answers.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18_0', '1', '', '', 0));

        // Test success
        List<String> result = processCkwBaseline(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));
        System.assert(result.get(2).equals('Successfully processed your CKW Baseline'));

        // Test failure due to recent Poverty Scorecard
        result = processCkwBaseline(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('2'));
        System.assert(result.get(2).equals('You have already submitted your baseline details'));
    }

    static testMethod void testStaffUpdate() {

        CKW__c ckw = Utils.createTestCkw(null, 'TestCkwBase1', true, null, 'Female');
        database.insert(ckw);
        CKW__c ckw1 = [SELECT Name FROM CKW__c WHERE Id = :ckw.id];

        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, null, 'Male');
        database.insert(person);
        Person__c person1 = [SELECT Name FROM Person__c WHERE Id = :person.Id];

        District__c district = [SELECT Name FROM District__c WHERE Name = 'Gulu'];

        Subcounty__c subcounty = Utils.createTestSubcounty('There', district.Id);
        database.insert(subcounty);

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('id_0', Utils.createTestSubmissionAnswer(null, 'id_0', ckw1.Name, '', '', 0));
        answers.put('first_name_0', Utils.createTestSubmissionAnswer(null, 'first_name', 'Me', '', '', 0));
        answers.put('middle_name_0', Utils.createTestSubmissionAnswer(null, 'middle_name', '2', '', '', 0));
        answers.put('last_name_0', Utils.createTestSubmissionAnswer(null, 'last_name', '5', '', '', 0));
        answers.put('fathers_name_0', Utils.createTestSubmissionAnswer(null, 'fathers_name', '3', '', '', 0));
        answers.put('parish_0', Utils.createTestSubmissionAnswer(null, 'parish', 'There', '', '', 0));
        answers.put('village_0', Utils.createTestSubmissionAnswer(null, 'village', 'Here', '', '', 0));
        answers.put('gender_0', Utils.createTestSubmissionAnswer(null, 'gender', '1', '', '', 0));
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', subcounty.Display_Name__c, '', '', 0));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'Gulu', '', '', 0));
        answers.put('gps_0', Utils.createTestSubmissionAnswer(null, 'locationCkw', '32.5 2.0', '', '', 0));
        answers.put('dob_0', Utils.createTestSubmissionAnswer(null, 'dob', '2011-09-30', '', '', 0));
        answers.put('status_0', Utils.createTestSubmissionAnswer(null, 'status', 'Active', '', '', 0));
        answers.put('active_date_0', Utils.createTestSubmissionAnswer(null, 'active_date', '2011-09-30', '', '', 0));

        // Test success
        List<String> result = processCkwUpdate(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));

        answers.put('id_0', Utils.createTestSubmissionAnswer(null, 'id_0', person1.Name, '', '', 0));
        List<String> result1 = processCkwUpdate(answers, person);
        System.debug(LoggingLevel.INFO, result1.get(0) + ' ' + result1.get(1));
        System.assert(result1.get(0).equals('1'));
    }

    static testMethod void testSubcounties() {

        CKW__c ckw = Utils.createTestCkw(null, 'TestCkwBase1', true, null, 'Female');
        database.insert(ckw);
        CKW__c ckw1 = [SELECT Name FROM CKW__c WHERE Id = :ckw.id];

        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, null, 'Male');
        database.insert(person);
        Person__c person1 = [SELECT Name FROM Person__c WHERE Id = :person.Id];

        District__c district = [SELECT Name FROM District__c WHERE Name = 'Gulu'];

        Subcounty__c subcounty = Utils.createTestSubcounty('There', district.Id);
        database.insert(subcounty);

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', 'q', '', '', 0));
        answers.put('subcounty_1', Utils.createTestSubmissionAnswer(null, 'subcounty', 'w', '', '', 0));
        answers.put('subcounty_2', Utils.createTestSubmissionAnswer(null, 'subcounty', 'e', '', '', 0));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'Gulu', '', '', 0));

        // Test success
        List<String> result = processSubcounties(answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));
    }

    static testMethod void testTranslations() {

        System.assertEquals('Thatch/straw', translateRoofMaterial('1'));
        System.assertEquals('Unburnt bricks', translateWallMaterial('1'));
        System.assertEquals('No grade completed', translateEducation('1'));
        System.assertEquals('Firewood', translateFuel('1'));
    }
}