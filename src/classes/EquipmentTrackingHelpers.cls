public with sharing class EquipmentTrackingHelpers {

    public static List<String> processFieldOfficerSubmission(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        DateTime handsetSubmitTime = ProcessSubmissionHelpers.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }

        // Check which direction the equipment is going in
        String typeOfSubmission = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        if (typeOfSubmission.equals('1')) {
            return processIncomingEquipment(submission, answers, submitter);
        }
        else if (typeOfSubmission.equals('2')) {
            return processOutgoingEquipment(submission, answers, submitter);
        }
        else {
            return new String[] { '0', 'The type of submission ' + typeOfSubmission + ' does not exist. Was submitted by IMEI: ' + submission.IMEI, 'You have submitted a type that does not exist. Please contact support' };
        }
    }

    /**
     * Process the incoming equipment submissions from the Field Officers
     */
    private static List<String> processIncomingEquipment(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        String assetType = translateAssetType(ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')));
        String id = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));

        // Check that the asset does not have an open tracking item.
        Equipment_Return__c[] returns = loadEquipmentReturn(
            id,
            assetType,
            'Open'
        );

        // Send the email to people who need to know that an asset with an open return is 
        // coming back from the field
        if (returns.size() > 0) {
            
        }

        // Create a new open return.
        Equipment_Return__c newReturn = new Equipment_Return__c();

        // Load the asset
        if (assetType.equals('Phone')) {
            Phone__c phone = loadPhone(id);
            if (phone == null) {
                return new String[] {
                    '0',
                    'FO with IMEI: ' + submission.imei + ' has tried to start a return for phone with imei: ' + id + ' that does not exist on our system',
                    'The IMEI you have submitted was invalid. Please check and re-submit. If you are sure it is correct please contact support'
                };
            }
            newReturn.Handset__c = phone.Id;
        }
        else {
            Asset__c asset = loadAsset(id);
            if (asset == null) {
                return new String[] {
                    '0',
                    'FO with IMEI: ' + submission.imei + ' has tried to start a return for asset with serial number: ' + id + ' that does not exist on our system',
                    'The Serial Number you have submitted was invalid. Please check and re-submit. If you are sure it is correct please contact support'
                };
            }
            newReturn.Asset__c = asset.Id;
        }

        newReturn.Field_Officer__c = submitter.Id;
        newReturn.Equipment_Type__c = assetType;
        newReturn.Field_Officer_Assement__c = buildAssetFaults(ProcessSubmissionHelpers.getAnswerSet(answers.get('q5_0')));
        newReturn.Field_Officer_Comments__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q6_0')) + ' ' + ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0'));
        newReturn.Location__c = 'Incoming - with FO';
        newReturn.Open_Date__c = DateTime.newInstance(ProcessSubmissionHelpers.parseDate(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0'))), Time.newInstance(0, 0, 0, 0));
System.debug(LoggingLevel.INFO, ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));
        newReturn.Status__c = 'Open';
        Database.insert(newReturn);

        // Create the initial returnLine
        Equipment_Return_Line__c newLine = new Equipment_Return_Line__c();
        newLine.Location__c = 'Incoming - with FO';
        newLine.Equipment_Return__c = newReturn.Id;
        newLine.Start_Date__c = DateTime.newInstance(ProcessSubmissionHelpers.parseDate(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0'))), Time.newInstance(0, 0, 0, 0));
        Database.insert(newLine);
        return new String[] {
            '1',
            'FO with IMEI: ' + submission.imei + ' has submitted a new return for asset with id: ' + id,
            'SUPRESSMSG'
        };
    }

    /**
     * Process a submission from a field office that indicates that a piece of equipment has gone back to the CKW
     */
    private static List<String> processOutgoingEquipment(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        String assetType = translateAssetType(ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')));
        String id = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));

        // Load the Equipment_Return__c for the id that is going back to the CKW
        Equipment_Return__c[] returns = loadEquipmentReturn(
            id,
            assetType,
            'Open'
        );

        // If there is no return open then inform the correct people and cancel the submission. This will need following up.
        if (returns.size() == 0) {
            
            return new String[] {
                '0',
                'FO with IMEI: ' + submission.imei + ' has tried to close a return for asset with id: ' + id + '. This asset was not in for return',
                'The IMEI/Serial No you have submitted was not in for return. Please check and re-submit. If you are sure it is correct please contact support'
            };
        }

        // If there is more than one return tracking open then inform the correct people. Then assume that the latest one is the one in use
        if (returns.size() > 1) {
            
        }
        Equipment_Return_Line__c newLine = new Equipment_Return_Line__c();
        newLine.Location__c = 'With CKW';
        newLine.Equipment_Return__c = returns[0].Id;
        returns.clear();
        newLine.Start_Date__c = DateTime.newInstance(ProcessSubmissionHelpers.parseDate(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0'))), Time.newInstance(0, 0, 0, 0));
        Database.insert(newLine);
        return new String[] {
            '1',
            'FO with IMEI: ' + submission.imei + ' has close a return for asset with id: ' + id,
            'SUPRESSMSG'
        };
    }

    /**
     * Translate the asset type
     */
    private static String translateAssetType(String optionNumber) {

            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Phone',
                '2' => 'Ready Set',
                '3' => 'Other'
            };
            return translationMap.get(optionNumber);
    }

    /**
     * Build up the asset faults string
     */
    private static String buildAssetFaults(Set<String> faults) {

        String returnValue = '';
        Integer i = 0;
        for (String fault : faults) {
            returnValue += fault;
            if (i <= faults.size() - 1) {
                returnValue += ';';
            }
        }
        return returnValue;
    }

    /**
     * Translate asset faults
     */
    private static Map<String, String> assetIssueTranslationMap = new Map<String, String> {
                '1' => 'Dead Battery',
                '2' => 'Broken Screen',
                '3' => 'Loss of Screen Sensitivity',
                '4' => 'Does Not Charge',
                '5' => 'CKW Pulse broken',
                '6' => 'CKW Search Broken',
                '7' => 'CKW Surveys Broken',
                '8' => 'MM Issues',
                '9' => 'Network Issues',
                '10' => 'Other'
            };
    private static String translateAssetIssue(String optionNumber) {
        return assetIssueTranslationMap.get(optionNumber);
    }

    /**
     * Load the equipment returns for an asset
     *
     * @param id              - The identifier for the asset (IMEI or serial number usually)
     * @param typeOfEquipment - The type of equipment, query changes if it is a phone
     * @param status          - The status of the equipment returns. Look for all if null is passed in here
     *
     * @return - A list of returns that match the params
     */
    private static Equipment_Return__c[] loadEquipmentReturn(String id, String typeOfEquipment, String status) {

        String query = 'SELECT ' +
                    'Name, ' +
                    'Open_Date__c, ' +
                    'Status__c, ' +
                    'Location__c, ' +
                    'Field_Officer__r.Last_Name__c, ' +
                    'Field_Officer__r.First_Name__c, ' +
                    'Field_Officer__r.Mobile_Number__c, ' +
                    'Person__r.Last_Name__c, ' +
                    'Person__r.First_Name__c, ' +
                    'Person__r.Mobile_Number__c ' +
                'FROM ' +
                    'Equipment_Return__c ' +
                'WHERE ';
                    
        if (typeOfEquipment.equals('Phone')) {
            query += 'Handset__r.IMEI__c = \'' + id + '\' ';
        }
        else {
            query += 'Asset__r.Serial_Number__c = \'' + id + '\' ';
        }
        if (status != null) {
            query += 'AND Status__c = \'' + status + '\' ';
        }
        System.debug(LoggingLevel.INFO, query);
        Equipment_Return__c[] returns = Database.query(query);
        return returns;
    }

    /**
     * Load an asset from the serial number
     */
    private static Asset__c loadAsset(String id) {

        Asset__c[] assets = [SELECT Id FROM Asset__c WHERE Serial_Number__c = :id];
        if (assets.size() != 1) {
            return null;
        }
        return assets[0];
    }

    /**
     * Load a phone from the IMEI
     */
    private static Phone__c loadPhone(String id) {

        Phone__c[] phones = [SELECT Id FROM Phone__c WHERE IMEI__c = :id];
        if (phones.size() != 1) {
            return null;
        }
        return phones[0];
    }

    /**
     * Update the equipment when a line is changed. This will break on a mass edit due to SOQL limit but as these should never really
     * be mass edited I going to choose to not care about this as life really can be too short sometimes
     */
    public static void updateReturnLineStatus(List<Equipment_Return_Line__c> returnLines) {

        // Loop through the return lines and get the unique ids
        Set<String> returnIdsSet = new Set<String>();
        for (Equipment_Return_Line__c returnLine : returnLines) {
            returnIdsSet.add(returnLine.Equipment_Return__c);
        }

        // Load all the Equipment_Return__c objects and add them to a map
        Map<String, Equipment_Return__c> returns = new Map<String, Equipment_Return__c>();
        for (Equipment_Return__c[] allReturns : Database.query(getAllReturnsQuery(returnIdsSet))) {
            for (Equipment_Return__c  aReturn : allReturns ) {
                returns.put((String)aReturn.Id, aReturn);
            }
        }

        // Load all the Equipment_Return_Line__c for the returns. Order by date so we can get the most recent. Loop through and find the latest one.
        // Update the corresponding Equipment_Return__c to match the location
        String returnId = '';
        Equipment_Return_Line__c previousLine;
        for (Equipment_Return_Line__c[] allReturnLines : Database.query(getAllReturnLinesQuery(returnIdsSet))) {
            for (Equipment_Return_Line__c returnLine : allReturnLines) {
                if (!returnId.equals('') && !returnId.equals(returnLine.Equipment_Return__c)) {
                    returns.get(returnId).Location__c = previousLine.Location__c;
                }
                previousLine = returnLine;
                returnId = returnLine.Equipment_Return__c;
            }
        }

        // Add the last one
        returns.get(returnId).Location__c = previousLine.Location__c;
        Database.update(returns.values());
    }

    /**
     * Returns query to get all the Equipment_Return_Line__c for a given set of Equipment_Return__c ids
     */
    private static String getAllReturnLinesQuery(Set<String> returnIdsSet) {

        List<String> ids = new List<String>();
        ids.addAll(returnIdsSet);
        String query =
            'SELECT ' +
                'Location__c, ' +
                'Equipment_Return__c ' +
            'FROM ' +
                'Equipment_Return_Line__c ' +
            'WHERE ' +
                'Equipment_Return__c IN (' + MetricHelpers.generateCommaSeperatedString(ids, true) + ') ' +
            'ORDER BY ' +
                'Start_Date__c ASC';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     * Returns query to get all the Equipment_Return__c for a given set ids
     */
    private static String getAllReturnsQuery(Set<String> returnIdsSet) {

        List<String> ids = new List<String>();
        ids.addAll(returnIdsSet);
        String query =
            'SELECT ' +
                'Location__c ' +
            'FROM ' +
                'Equipment_Return__c ' +
            'WHERE ' +
                'Id IN (' + MetricHelpers.generateCommaSeperatedString(ids, true) + ')';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    static testMethod void testIncomingValidSubmission() {

        // Create a test Field Officer
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Type__c = 'Field Officer';
        database.insert(person);

        Person__c person2 = [SELECT
                Id,
                Name 
            FROM
                Person__c
            WHERE
            Id = :person.Id];

        // Create test phone
        Phone__c phone = Utils.createTestHandset('RockLobster');
        Database.insert(phone);
        Phone__c phone2 = Utils.createTestHandset('GreatWhiteNorth');
        Database.insert(phone2);

        // Create test asset
        Asset__c asset = new Asset__c();
        asset.Serial_Number__c = 'RockLobster';
        asset.Date_of_purchase__c = Date.today();
        asset.Reference_document_number__c = 'iewo';
        Database.insert(asset);

        // Test with a phone first
        List<String> returnValues = new List<String>();
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '1', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'RockLobster', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '1 2', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Some stuff went wrong', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '12/12/2012', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '12/12/2012', null, null, null));
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';

        returnValues = processFieldOfficerSubmission(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));

        // Test with an asset
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '2', null, null, null));
        returnValues = processFieldOfficerSubmission(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));

        // Test the outgoing
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '2', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, null));
        returnValues = processFieldOfficerSubmission(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));

        // Test outgoing that will fail due to no incoming sent before
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'GreatWhiteNorth', null, null, null));
        returnValues = processFieldOfficerSubmission(submission, answers, person);
        System.assert(returnValues.get(0).equals('0'));
    }
}