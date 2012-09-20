/**
 * Helper class to deal with Field Officers
 */
public with sharing class FieldOfficeHelpers {

    /**
     *  Fill in the Field_Officer_Productivity__c objects for this F/O
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the F/O who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processFoSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission for FO with IMEI: ' + submission.imei, 'SUPRESSMSG' };
        }

        Field_Officer_Productivity__c fop = new Field_Officer_Productivity__c();
        fop.Field_Officer__c = person.Id;

        // Sort out the GPS for the submission. Look for the one in the survey. If that does not exist then use the background gps for the survey
        String[] gps = getAnswerString(answers.get('q86_0')).split(' ');
        String latitude = submission.interviewLatitude;
        String longitude = submission.interviewLongitude;
        if (gps.size() > 2) {
            latitude = gps[0];
            longitude = gps[1];
        }
        fop.Latitude__c = latitude;
        fop.Longitude__c = longitude;
        fop.Start_Time__c = handsetSubmitTime;
        fop.End_Time__c = ProcessSurveySubmission.getTimestamp(submission.submissionStartTime);

        // Decide the type of the survey and process appropriately
        String typeOfSurvey = getAnswerString(answers.get('q1_0'));
        if (typeOfSurvey.equals('1')) {
            String name = getCkw(getAnswerString(answers.get('q8_0')));
            if (name.equals('FAIL')) {
                System.debug(LoggingLevel.INFO, 'FO with IMEI: ' + submission.imei + ' has submitted a survey for a ckw that does not exist. Name submitted: ' + getAnswerString(answers.get('q58_0')));
            }
            else {
                fop.Interviewee__c = (Id)name;
            }
            fop = processOneOnOne(submission, answers, fop);
            fop.Submission_Type__c = 'FO/CKW 1:1';
        }
        else if (typeOfSurvey.equals('2')) {
            fop.Additional_Comments__c = getAnswerString(answers.get('q51_0'));
            fop.Submission_Type__c = 'PEER GROUP SESSION';
        }
        else if (typeOfSurvey.equals('3')) {
            String name = getCkw(getAnswerString(answers.get('q58_0')));
            if (name.equals('FAIL')) {
                System.debug(LoggingLevel.INFO, 'FO with IMEI: ' + submission.imei + ' has submitted a survey for a ckw that does not exist. Name submitted: ' + getAnswerString(answers.get('q58_0')));
            }
            else {
                fop.Interviewee__c = (Id)name;
            }
            fop.Additional_Comments__c = getAnswerString(answers.get('q63_0'));
            fop.Submission_Type__c = 'HIGH PERFORMER CALLS';
        }
        else if (typeOfSurvey.equals('4')) {
            fop = processFarmerGroup(fop, answers);
            fop.Submission_Type__c = 'FARMER GROUP SESSION';
        }
        else {
            return new String[] { '0', 'FO with IMEI: ' + submission.imei + ' has submitted a survey that is not supported with the binding: ' + typeOfSurvey, 'SUPRESSMSG' };
        }

        initTargets(handsetSubmitTime.date(), person);
        Database.insert(fop);

        // Return success
        return new String[] { '1', 'One On One survey processed for FO with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    /**
     * Add the CKW to the Field_Officer_Productivity__c so it can be linked back
     */
    private static String getCkw(String ckwName) {

        CKW__c[] ckw = [
            SELECT
                Name,
                Id,
                Person__r.Id
            FROM
                CKW__c
            WHERE
                Name = :ckwName
        ];
        if (ckw.size() != 1) {
            return 'FAIL';
        }
        return String.valueOf(ckw[0].Person__r.Id);
    }

    /**
     * Process a One on One survey from a Field Officer
     */
    private static Field_Officer_Productivity__c processOneOnOne(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Field_Officer_Productivity__c fop) {

        fop = parseMajorComplaints(getAnswerSet(answers.get('q12_0')), fop);
        fop.CKW_Motivation__c = translateMotivation(getAnswerString(answers.get('q24_0')));
        fop.Additional_Comments__c = getAnswerString(answers.get('q25_0'));
        return fop;
    }

    private static String translateMotivation(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Highly Motivated',
            '2' => 'Neutral',
            '3' => 'Demotivated/ Frustrated'
        };
        return translationMap.get(optionNumber);
    }

    private static Field_Officer_Productivity__c parseMajorComplaints(Set<String> answer, Field_Officer_Productivity__c fop) {

        for (String major : answer) {
            String xlatedAnswer = translateMajorConcern(major);
            fop.put('Major_' + xlatedAnswer + '__c', 1.0);
        }
        return fop;
    }

    private static String translateMajorConcern(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Retrain',
            '2' => 'Charge',
            '3' => 'Payment',
            '4' => 'Phone',
            '5' => 'Network',
            '6' => 'Personal',
            '7' => 'Other'
        };
        return translationMap.get(optionNumber);
    }

    /**
     * Process a Farmer Group survey from a Field Officer
     */
    private static Field_Officer_Productivity__c processFarmerGroup(Field_Officer_Productivity__c fop, Map<String, Submission_Answer__c> answers) {

        fop.Adoption__c = getAnswerNumber(answers.get('q72_0'), 'q72');
        fop.Farmers_Present__c = getAnswerNumber(answers.get('q80_0'), 'q80');
        fop.Used_Ckw__c = getAnswerNumber(answers.get('q79_0'), 'q79');
        fop.Farmers_Opinion__c = translateFarmerOpinion(getAnswerString(answers.get('q78_0')));
        fop = parseFarmerMajorComplaints(getAnswerSet(answers.get('q75_0')), fop);
        fop.Additional_Comments__c = getAnswerString(answers.get('q82_0'));
        return fop;
    }

    private static Field_Officer_Productivity__c parseFarmerMajorComplaints(Set<String> answer, Field_Officer_Productivity__c fop) {

        for (String major : answer) {
            String xlatedAnswer = translateMajorFarmerConcern(major);
            fop.put('Major_Farmer_' + xlatedAnswer + '__c', 1.0);
        }
        return fop;
    }

    private static String translateMajorFarmerConcern(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Content',
            '2' => 'Project',
            '3' => 'Access',
            '4' => 'Regional',
            '5' => 'Other'
        };
        return translationMap.get(optionNumber);
    }

    private static String translateFarmerOpinion(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Excellent/Helpful',
            '2' => 'Neutral',
            '3' => 'Poor/ Not revelant'
        };
        return translationMap.get(optionNumber);
    }

    /**
     * Init the targets for the month
     */
    private static void initTargets(Date startDate, Person__c person) {

        // Check that the target has been initialised
        Field_Officer_Productivity_Targets__c target = getTarget(startDate.toStartOfMonth(), person, 'Person', false);
        if (target != null) {
            return;
        }

        // Get the targets for this F/O
        target = getTarget(startDate, person, 'Person', true);
        if (target != null) {
            initFoTarget(startDate.toStartOfMonth(), person, target);
            return;
        }

        // Get the targets for the district
        target = getTarget(startDate, person, 'District', true);
        if (target != null) {
            initFoTarget(startDate.toStartOfMonth(), person, target);
            return;
        }

        // Get the targets for the country
        target = getTarget(startDate, person, '', true);
        if (target != null) {
            initFoTarget(startDate.toStartOfMonth(), person, target);
        }
        return;
    }

    /**
     * Load a target
     */
    private static Field_Officer_Productivity_Targets__c getTarget(Date startDate, Person__c person, String targetType, Boolean defaultTarget) {

        String whereClause = '';
        if (defaultTarget) {
            whereClause += ' AND Live_Target__c = false ';
        }
        else {
            whereClause += ' AND Live_Target__c = true ';
        }

        if (targetType.equals('Person')) {
            whereClause += ' AND District__c = null ' +
                ' AND Field_Officer__c = \'' + person.Id + '\' ';
        }
        else if (targetType.equals('District')) {
            if (person.District__c == null) {
                System.debug(LoggingLevel.INFO, 'Field Officer does not have their district set');
            }
            whereClause += ' AND District__c = \'' + person.District__c + '\' ' + 
                ' AND Field_Officer__c = null';
        }
        else {
            whereClause += ' AND District__c = null ' +
                ' AND Field_Officer__c = null ';
        }
        String query =
            'SELECT ' +
                'Farmer_Group_Target__c, ' +
                'High_Performer_Target__c, ' +
                'One_On_One_Target__c, ' +
                'Peer_Group_Target__c ' +
            'FROM ' +
                'Field_Officer_Productivity_Targets__c ' +
            'WHERE ' +
                'Start_Date__c <= :startDate' +
                whereClause +
            ' ORDER BY ' +
                'Start_Date__c ASC';
        System.debug(LoggingLevel.INFO, query);
        Field_Officer_Productivity_Targets__c[] targets = Database.query(query);
        if (targets.size() == 0) {
            return null;
        }
        return targets[0];
    }

    /**
     * Create a new target object for the given F/O for a given month
     */
     private static void initFoTarget(Date startDate, Person__c person, Field_Officer_Productivity_Targets__c target) {

        Field_Officer_Productivity_Targets__c newTarget = target.clone(false, true, false, false);
        newTarget.Start_Date__c = startDate;
        newTarget.District__c = null;
        newTarget.Field_Officer__c = person.Id;
        newTarget.Live_Target__c = true;
        Database.insert(newTarget);
     }

    /**
     * Get an optional String answer from a field
     *
     * @param answer - The answer object that we are looking at. May be null
     *
     * return - The answer. null if the answer is blank
     */
    private static String getAnswerString(Submission_Answer__c answer) {

        if (answer == null) {
            return null;
        }
        else {
            return answer.Answer__c;
        }
    }

    /**
     * Get an optional number answer from a field
     *
     * @param answer  - The answer object that we are looking at. May be null
     * @param binding - The key for the answer. So an error can be identified
     *
     * return - The answer. null if the answer is blank
     */
    private static Decimal getAnswerNumber(Submission_Answer__c answer, String binding) {

        if (answer == null) {
            return null;
        }
        else {
            Decimal returnValue;
            try {
                returnValue = Decimal.valueOf(answer.Answer__c);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Number passed in for answer with binding ' + binding + ' caused an error: ' + e.getMessage());
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
    private static Set<String> getAnswerSet(Submission_Answer__c answer) {

        Set<String> returnValue = new Set<String>();
        if (answer != null) {
            String answerValue = answer.Answer__c;
            if (answerValue != null) {
                returnValue.addAll(answer.Answer__c.split(' '));
            }
        }
        return returnValue;
    }

    /**
     * Join together a bunch of where clauses
     */
    public static String joinWhereClause(List<String> clauses, Boolean includeWhere, Boolean startWithAnd) {

        // Build the where clause
        String whereString = '';
        if (clauses.size() == 0) {
            return whereString;
        }
        if (includeWhere) {
            whereString = ' WHERE ';
        }
        else if (startWithAnd) {
            whereString = 'AND ';
        }
        Integer length = clauses.size();
        for (Integer i = 0; i < length; i ++) {
            whereString = whereString + clauses.get(i);
            if (i < length -1) {
                whereString = whereString + ' AND ';
            }
        }
        return whereString;
    }

    static testMethod void testProcessSubmissions() {

        // Create a test CKW
        Person__c person = Utils.createTestPerson(null, 'TestingCKW', true, null, 'Female');
        person.Type__c = 'CKW';
        database.insert(person);
        CKW__c ckw = Utils.createTestCkw(person.Id, 'TestCKW', false, null, null);
        Database.insert(ckw);
        CKW__c ckw1 = [SELECT Name FROM CKW__c WHERE Id = :ckw.Id];

        // Create a test Test Field Officer
        Person__c person1 = Utils.createTestPerson(null, 'TestingFo', true, null, 'Female');
        person1.Type__c = 'Field Officer';
        database.insert(person1);

        // Add a target for this person
        List<Field_Officer_Productivity_Targets__c> targets = new List<Field_Officer_Productivity_Targets__c>();
        Field_Officer_Productivity_Targets__c target = new Field_Officer_Productivity_Targets__c();
        target.Start_Date__c = Date.today().addMonths(-1);
        target.Farmer_Group_Target__c = 10;
        target.Field_Officer__c = person1.Id;
        target.High_Performer_Target__c = 10;
        target.Live_Target__c = false;
        target.One_On_One_Target__c = 10;
        target.Peer_Group_Target__c = 10;
        targets.add(target);

        Field_Officer_Productivity_Targets__c target1 = new Field_Officer_Productivity_Targets__c();
        target1.Start_Date__c = Date.today().addMonths(-2);
        target1.Farmer_Group_Target__c = 20;
        target1.Field_Officer__c = person1.Id;
        target1.High_Performer_Target__c = 20;
        target1.Live_Target__c = false;
        target1.One_On_One_Target__c = 20;
        target1.Peer_Group_Target__c = 20;
        targets.add(target1);
        Database.insert(targets);

        // Create the submission
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';

        List<String> returnValues = new List<String>();
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q86_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));

        // Test a 1:1 survey
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, '', '1', null, null, null));
        answers.put('q86_0', Utils.createTestSubmissionAnswer(null, '', '1 1 1 1 1', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, '', ckw1.Name, null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, '', '1 3', null, null, null));
        answers.put('q24_0', Utils.createTestSubmissionAnswer(null, '', '2', null, null, null));
        answers.put('q25_0', Utils.createTestSubmissionAnswer(null, '', 'You\'ll find a life on the outside', null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.assert(returnValues.get(0).equals('1'));

        // Test with a failing CKW
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, '', 'absg', null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.assert(returnValues.get(0).equals('0'));

        answers.clear();

        // Test Peer Group session
        answers.put('q86_0', Utils.createTestSubmissionAnswer(null, '', '1 1 1 1 1', null, null, null));
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, '', '2', null, null, null));
        answers.put('q51_0', Utils.createTestSubmissionAnswer(null, '', 'You can\'t deny the walks too long, you\'ll get there in half the time', null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.assert(returnValues.get(0).equals('1'));

        answers.clear();

        // Test High Performer
        answers.put('q86_0', Utils.createTestSubmissionAnswer(null, '', '1 1 1 1 1', null, null, null));
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, '', '3', null, null, null));
        answers.put('q63_0', Utils.createTestSubmissionAnswer(null, '', 'If you take a seat ion the shotgun side', null, null, null));
        answers.put('q58_0', Utils.createTestSubmissionAnswer(null, '', ckw1.Name, null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.debug(LoggingLevel.INFO, returnValues.get(1));
        System.assert(returnValues.get(0).equals('1'));

        // Test with a failing CKW
        answers.put('q58_0', Utils.createTestSubmissionAnswer(null, '', 'absg', null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.assert(returnValues.get(0).equals('0'));

        answers.clear();

        // Test farmer group
        answers.put('q86_0', Utils.createTestSubmissionAnswer(null, '', '1 1 1 1 1', null, null, null));
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, '', '4', null, null, null));
        answers.put('q82_0', Utils.createTestSubmissionAnswer(null, '', 'Tahoma calls. It\'s waiting there to get rid of us all', null, null, null));
        answers.put('q72_0', Utils.createTestSubmissionAnswer(null, '', '11', null, null, null));
        answers.put('q80_0', Utils.createTestSubmissionAnswer(null, '', '1', null, null, null));
        answers.put('q79_0', Utils.createTestSubmissionAnswer(null, '', '1', null, null, null));
        answers.put('q78_0', Utils.createTestSubmissionAnswer(null, '', '1 2', null, null, null));
        answers.put('q75_0', Utils.createTestSubmissionAnswer(null, '', '1 2', null, null, null));
        returnValues = processFoSurvey(submission, answers, person1);
        System.assert(returnValues.get(0).equals('1'));

        Field_Officer_Productivity_Targets__c[] foTargets = [
            SELECT
                Farmer_Group_Target__c,
                High_Performer_Target__c,
                One_On_One_Target__c,
                Peer_Group_Target__c
            FROM
                Field_Officer_Productivity_Targets__c
            WHERE
                Field_Officer__c = :person1.Id
                AND Live_Target__c = true];
        System.assertEquals(1, foTargets.size());
        System.assertEquals(foTargets[0].Farmer_Group_Target__c, 10);
        System.assertEquals(foTargets[0].High_Performer_Target__c, 10);
        System.assertEquals(foTargets[0].One_On_One_Target__c, 10);
        System.assertEquals(foTargets[0].Peer_Group_Target__c, 10);
    }
}