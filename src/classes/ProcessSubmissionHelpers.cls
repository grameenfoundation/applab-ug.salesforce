public with sharing class ProcessSubmissionHelpers {
    /*
     * Data types
     */
    public static final Integer DATE_TYPE = 0;
    public static final Integer DECIMAL_TYPE = 1;
    public static final Integer STRING_TYPE = 2;
    public static final Integer SET_STRING_TYPE = 3;
    
    /**
     * Get an optional String answer from a field
     *
     * @param answer - The answer object that we are looking at. May be null
     *
     * return - The answer. null if the answer is blank
     */
    public static String getAnswerString(Submission_Answer__c answer) {
        return getAnswerString(answer, null);
    }

    /**
     * Get an optional String answer from a field. Return a default value if no value is found
     * @param String answer - The answer object that we are looking at
     * @param String defaultValue - this is returned if we do not find a suitable value to return
     * @return String|null
     */
    public static String getAnswerString(Submission_Answer__c answer, String defaultValue) {
        if (answer == null || answer.Answer__c == null) {
            return defaultValue;
        }
        else  {
            return answer.Answer__c;
        }
    }

    /**
     * Get an optional Date answer from a field. Return a default value if no value is found
     * @param String answer - The answer object that we are looking at
     * @param String defaultValue - this is returned if we do not find a suitable value to return
     * @return Date|null
     */
    public static Date getAnswerDate(Submission_Answer__c answer, Date defaultValue) {
        if (answer != null && answer.Answer__c != null) {
            String dateString = answer.Answer__c;

            // Dates comes in with the format YYYY-MM-dd (2011-09-30)
            String[] dateParts = dateString.split('-');
            if (dateParts.size() == 3) {
                dateString = dateParts[1] + '/' + dateParts[2] + '/' + dateParts[0];

                return Date.parse(dateString);
            }
        }
        return defaultValue;
    }

    /**
     * Get an optional number answer from a field
     *
     * @param answer  - The answer object that we are looking at. May be null
     * @param binding - The key for the answer. So an error can be identified
     *
     * return - The answer. null if the answer is blank
     */
    public static Decimal getAnswerNumber(Submission_Answer__c answer, String binding, Boolean disallowNull) {    
        if(disallowNull) {
            return getAnswerNumber(answer, binding, 0.0);
        } else {
            return getAnswerNumber(answer, binding, (Decimal) null);
        }
    }

    /**
     * Get an optional number answer from a field. Return defaultValue if no suitable value is found
     * @param Submission_Answer__c answer
     * @param String binding
     * @param Boolean disallowNull
     * @param Decimal default
     */
    public static Decimal getAnswerNumber(Submission_Answer__c answer, String binding, Decimal defaultValue) {
        if (answer == null || answer.Answer__c == null) {
            return defaultValue;
        }
        else {
            Decimal returnValue;
            try {
                returnValue = Decimal.valueOf(answer.Answer__c);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Number passed in for answer with binding ' + binding + ' caused an error: ' + e.getMessage());
                return defaultValue;
            }
            return returnValue;
        }
    }

    /**
     * Convert an answer into a Set. Useful for multiSelect questions
     *
     * @param answer - The answer being turned to a set
     *
     * @return - A set with all the answer bindings in
     */
    public static Set<String> getAnswerSet(Submission_Answer__c answer) {
        return getAnswerSet(answer, null);
    }

    /**
     * Convert an answer into a Set. Useful for multiSelect questions. Returns defaultValue if it cannot find a suitable value
     * @param Submission_Answer__c answer - The answer being turned to a set
     * @param Set<String> defaultValue - The default value to return
     * @return Set<String>
     */
    public static Set<String> getAnswerSet(Submission_Answer__c answer, Set<String> defaultValue) {
        Set<String> returnValue = new Set<String>();
        if (answer != null) {
            String answerValue = getAnswerString(answer, '');
            returnValue.addAll(answer.Answer__c.split(' '));
            return returnValue;
        }
        return defaultValue;
    }

    /**
     * Parse a date field from the survey
     *
     * @param answer - The answer being turned to a date
     *
     * @return - The date
     */
    public static Date parseDate(String value) {
        return Date.today();
    }

    public static DateTime getTimestamp(String timeString) {

        Long timeStamp = null;
        if (timeString != null && !timeString.equals('')) {
            timeStamp = Long.valueOf(timeString);
        }
        if (timeStamp == null || timeStamp == 0) {
            return null;
        }
        else {
            return datetime.newInstance(timeStamp);
        }
    }
    
    /**
    *  Check for count of expected value
    */
    public static Integer getCount(List<String> filledInValues, String expectedValue) {
        Integer runningTotal = 0;
        
        for (String filledInValue : filledInValues) {
            if (filledInValue.equals(expectedValue)) {
                runningTotal++;
            }
        }
        
        return runningTotal;
    }
    
    /**
    *  Get the answers for all bindings that start with passed parameter
    * 
    *   @param bindingPattern - A map containing the values for the the outlet visit
    *   @param answers - A map containing all submission answers
    *
    *   @return List of answers as String
    */
    public static List<String> getSingleSelectAnswersByMatchingBindings(String bindingPattern, Map<String, Submission_Answer__c> answers) {
        
        List<String> matchingAnswers = new List<String>();
        Set<String> keys = answers.keySet();
        for (String key : keys) {
            if (key.startsWith(bindingPattern)) {
                matchingAnswers.add(answers.get(key).Answer__c);
            }
        }       
        return matchingAnswers;
    }
    
    /**
    * Check if value passed in is a 'YES' persons from survey
    *
    */
    public static boolean checkIfYes(String answerValue) {
        if (answerValue == '1') {
            return true;
        }
        else {
            return false;
        }    
    }

    /**
     * Get answer from an answerMap
     * 
     * @param Map<String, Submission_Answer__c> answerMap - the map that contains the answers we want to extract
     * @param String answerKey - the index of the answer we want
     * @param Integer type - the type of response we expect. Currently supports Decimal, String, Date and Set<String> (see type constants above) 
     * @param Object defaultValue - the defaultValue (should match the expected return type)
     * 
     * @return Object - you will need to cast back to the type you want. 
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue, Integer type) {
        Submission_Answer__c answer = null;

        if(answerMap.containsKey(answerKey))    {
            answer = answerMap.get(answerKey);

            if(type == SET_STRING_TYPE) {
                return (Set<String>) getAnswerSet(answer, (Set<String>) defaultValue);
            } else if(type == DECIMAL_TYPE) {
                return (Decimal) getAnswerNumber(answer, answerKey, (Decimal) defaultValue);
            } else if(type == DATE_TYPE) {
                return (Date) getAnswerDate(answer, (Date) defaultValue);
            } else if(type == STRING_TYPE){
                return (String) getAnswerString(answer, (String) defaultValue);
            }
        }
        return defaultValue;
    }

    /**
     * This allows optional Type, defaulting it to String
     * @see extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue) 
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue) {
        return extractAnswer(answerMap, answerKey, defaultValue, STRING_TYPE);
    }

    /**
     * This further allows defaultValue to be left out
     * @see extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue)
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey) {
        return extractAnswer(answerMap, answerKey, null);
    }

    /** 
     * This is for the new IBT surveys
     */
    public static gfsurveys__Answer__c extractAnswer(Map<String, gfsurveys__Answer__c> answers, String key) {
        if(answers.containsKey(key)) {
            return answers.get(key);
        }
        return null;
    }
    
    /**
     *  Create a submission meta data object. This will allow the submissions to be mapped
     */
    public static Boolean createSubmissionMetaData(ProcessSurveySubmission.SurveySubmission surveySubmission, Person__c submitter) {

        // Load the survey
        Survey__c survey = Utils.loadSurvey(surveySubmission.surveyId);
        if (survey == null) {
            return false;
        }

        Submission_Meta_Data__c meta = new Submission_Meta_Data__c();
        meta.Interviewer__c = submitter.Id;
        meta.Survey__c = survey.Id;
        meta.Interview_Latitude__c = Decimal.valueOf(surveySubmission.interviewLatitude);
        meta.Interview_Longitude__c = Decimal.valueOf(surveySubmission.interviewLongitude);
        meta.Interview_Altitude__c = Decimal.valueOf(surveySubmission.interviewAltitude);
        meta.Interview_Accuracy__c = Decimal.valueOf(surveySubmission.interviewAccuracy);
        meta.Interview_GPS_Timestamp__c = ProcessSurveySubmission.getTimestamp(surveySubmission.interviewGPSTimestamp);
        meta.Handset_Submit_Time__c = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime);

        meta.Submission_Latitude__c = Decimal.valueOf(surveySubmission.submissionLatitude);
        meta.Submission_Longitude__c = Decimal.valueOf(surveySubmission.submissionLongitude);
        meta.Submission_Altitude__c = Decimal.valueOf(surveySubmission.submissionAltitude);
        meta.Submission_Accuracy__c = Decimal.valueOf(surveySubmission.submissionAccuracy);
        meta.Submission_GPS_Timestamp__c = ProcessSurveySubmission.getTimestamp(surveySubmission.submissionGPSTimestamp);

        meta.Submission_Size__c = Decimal.valueOf(surveySubmission.surveySize);
        meta.Result_Hash__c = surveySubmission.resultHash;

        Database.SaveResult submissionMetaDataResult = Database.insert(meta, false);
        if (!submissionMetaDataResult.isSuccess()) {
            System.debug(LoggingLevel.INFO, submissionMetaDataResult.getErrors()[0].getMessage());
            if (submissionMetaDataResult.getErrors()[0].getMessage().contains('Result_Hash__c duplicates')) {
                System.debug(LoggingLevel.INFO, 'Duplicate submission so allow to save: ' + submissionMetaDataResult.getErrors()[0].getMessage());
                return true;
            }
            else {
                System.debug(LoggingLevel.INFO, 'Failed to save submissionMetaData object: ' + submissionMetaDataResult.getErrors()[0].getMessage());
                return false;
            }
        }
        return true;
    }

    /**
     *  Get the District__c object using the districtName
     *
     *  @param districtName - A string of the districtname resolved from the survey submission
     *
     *  @return - District__c object
     */
    public static District__c getDistrict(String districtName) {
        District__c[] district = database.query(SoqlHelpers.getDistrict(districtName));
        if (district.isEmpty() || district.size() == 0) {
            return null;
        }
        else {
            return district[0];
        }
    }

    /**
     *  Translate the survey selection for the gender question
     *
     *  @param optionNumber - A string that represesnts the user'd selection for this question
     *
     *  @return - String representation pf the gender selected ('Male' or 'Female')
     */
    public static String translateGender(String optionNumber) {
        if (optionNumber.equals('1')) {
            return 'Male';
        }
        return 'Female';
    }

    /**
     *  Calculate the age translated date of birth
     *
     *  @param dob - The date of birth (format YYYY-MM-dd (2011-09-30))
     *
     *  @return - A number representing the age of the interviewee 
     */
    public static Integer calculateAge(Date dob) {
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

    /**
     *  Calculate date of birth from the translated submission
     *
     *  @param dobString - A String that represents the date of birth (format YYYY-MM-dd (2011-09-30))
     *
     *  @return - date of birth
     */
    public static Date calculateDob(String dobString) {
        Date dob = null;

        // DOB comes in with the format YYYY-MM-dd (2011-09-30)
        String[] dobParts = dobString.split('-');
        if (dobParts.size() == 3) {
            dobString = dobParts[1] + '/' + dobParts[2] + '/' + dobParts[0];
            dob = Date.parse(dobString);
        }
        return dob;
    }

    static testMethod void testAnswers() {        
        Submission_Answer__c answer = new Submission_Answer__c();
        answer.Answer__c = '1';
        System.assertEquals(getAnswerString(null), null);
        System.assertEquals(getAnswerString(answer), '1');
        System.assertEquals(getAnswerString(null, 'test'), 'test');
        answer.Answer__c = null;
        System.assertEquals(getAnswerString(answer, 'test2'), 'test2');
        System.assertEquals(getAnswerNumber(null, '1', true), 0.0);
        System.assertEquals(getAnswerNumber(null, '1', false), null);
        answer.Answer__c = '1';
        System.assertEquals(getAnswerNumber(answer, '1', true), 1.0);
        System.assertEquals(getAnswerNumber(null, '1', 1), 1);
        answer.Answer__c = null;
        System.assertEquals(getAnswerNumber(answer, '1', 2), 2);
        answer.Answer__c = '1 2 3';
        System.assertEquals(getAnswerSet(answer).size(), 3);
    }

    static testMethod void testTimestamp() {
        DateTime test = getTimeStamp(null);
        System.assertEquals(test, null);
        DateTime control = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        test = getTimestamp(String.valueOf(control.getTime()));
        System.assertEquals(test, control);
    }

    /**
     * Test method for calculateDob method
     */
    static testMethod void testCalculateDob() {
        String testDobString = '2011-09-30';
        Date testDob = calculateDob(testDobString);
    }

    /**
     * Test method for translateGender method
     */
    static testMethod void testTranslateGender() {
        System.assertEquals(translateGender('1'), 'Male');
        System.assertEquals(translateGender('2'), 'Female');
    }

    /**
     * Test method for calculateAge method
     */
    static testMethod void testCalculateAge() {
        Date testDob = calculateDob('2001-09-30');
        System.assertNotEquals(calculateAge(testDob), 1);
    }
    
    static testMethod void testGetAnswerDate() {
        Submission_Answer__c answer = Utils.createTestSubmissionAnswer(null, 'q2', '2001-09-30', null, null, null);
        Date todayDate = Date.today();
        Date testDate = getAnswerDate(answer, todayDate);
        System.assertNotEquals(todayDate, testDate);
        Date testDate2 = getAnswerDate(null, todayDate);
        System.assertEquals(testDate2, todayDate);
    }
    
    static testMethod void testCheckIfYes() {
        boolean yesTest = checkIfYes('1');
        boolean noTest = checkIfYes('2');
        System.assertEquals(yesTest, true);
        System.assertEquals(noTest, false);
    }
    
    static testMethod void testGetDistrict() {
        District__c testDistrict = new District__c();
        testDistrict.Name = 'testDistrict';
        database.insert(testDistrict);
        District__c testDistrict2 = getDistrict('testDistrict');
        System.assertEquals(testDistrict2.Name, 'testDistrict');
    }
    
    static testMethod void testGetSingleSelectAnswersByMatchingBindings() {
        String expectedPattern = 'q2';
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, 0));
        answers.put('q2_1', Utils.createTestSubmissionAnswer(null, 'q2', '30', null, null, 1));
        answers.put('q2_2', Utils.createTestSubmissionAnswer(null, 'q2', '2', null, null, 2));
        System.assertEquals(getSingleSelectAnswersByMatchingBindings(expectedPattern, answers).size(), 3);
    }

    /**
     * Test method for parseDate method, an idiotic method
     */  
    static testMethod void testParseDate() {
        System.assertEquals(parseDate('2001-09-30'), Date.today());
    }
    
    static testMethod void testGetCount() {
        List<String> filledInValues = new List<String>();
        filledInValues.add('a1');
        filledInValues.add('a2');
        filledInValues.add('a3');
        filledInValues.add('a3');
        String expectedValue = 'a3';
        System.assertEquals(getCount(filledInValues, expectedValue), 2);
    }
    
    static testMethod void testExtractAnswer() {
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, 0));
        answers.put('q2_1', Utils.createTestSubmissionAnswer(null, 'q2', '30', null, null, 1));
        answers.put('q2_2', Utils.createTestSubmissionAnswer(null, 'q2', '2', null, null, 2));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '2 4 5', null, null, 2));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '2.4', null, null, 2));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '2001-09-30', null, null, 2));
        System.assertNotEquals(null, extractAnswer(answers, 'q2_0', null, STRING_TYPE ));
        System.assertNotEquals(null, extractAnswer(answers, 'q4_0', null, DECIMAL_TYPE ));
        System.assertNotEquals(null, extractAnswer(answers, 'q5_0', null, DATE_TYPE ));
        System.assertNotEquals(null, extractAnswer(answers, 'q3_0', null, SET_STRING_TYPE));
        System.assertNotEquals(null, extractAnswer(answers, 'q2_0', 'testing'));
        System.assertNotEquals(null, extractAnswer(answers, 'q2_0'));
        System.assertNotEquals(null, extractAnswer(answers, 'q7', 'testing'));
    }
    
    static testMethod void testCreateSubmissionMetaData() {
        Person__c person = Utils.createTestPerson(null, 'E-FARMER22', true, null, 'Male');
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        System.assertEquals(false, createSubmissionMetaData(submission, person));
        submission.interviewLatitude = '122';
        submission.interviewLongitude = '345';
        submission.interviewAltitude = '4';
        submission.interviewAccuracy = '3.3';
        submission.interviewGPSTimestamp = '46545775926';
        submission.submissionLatitude = '231';
        submission.submissionLongitude = '234';
        submission.submissionAltitude = '4';
        submission.submissionAccuracy = '3.3';
        submission.submissionGPSTimestamp = '46545775926';
        submission.surveySize = '2.2';
        String surveyName = 'USAID Farmer Registration';
        Survey__c survey = [Select Id, Name from Survey__c where Survey_Name__c=:surveyName];
        submission.surveyId = survey.Name;
        System.assertEquals(true, createSubmissionMetaData(submission, person));
    }
    
    static testMethod void testGetAnswerSet() {
        Set<String> defaultValues = new Set<String>();
        defaultValues.add('hello');
        defaultValues.add('hey');
        System.assertNotEquals(null, getAnswerSet(null, defaultValues));
    }
}