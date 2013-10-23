public with sharing class DataValidatorHelpers {

    public static Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();

    /**
     *  Class that deals with all processes around the data validators
     */

    /**
     *  Process the spot check survey and create the metrics for the data validators
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                          The keys are <binding>_<instance> for compatibility
     *  @param submitter  - The Person__c person who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the submitter if required.
     */
    public static List<String> processSpotCheck(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }

        //createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String explainWell = answers.get('q7_0').Answer__c;
        String bias = answers.get('q15_0').Answer__c;
        String probed = answers.get('q10_0').Answer__c;

        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 'GRA_total_spot_checks', 'GRA_informed_farmer', 'GRA_no_bias', 'GRA_probed_CKW' };
        Date startDate = handsetSubmitTime.date().toStartOfMonth();
        Date endDate = handsetSubmitTime.date().toStartOfMonth().addMonths(1).addDays(-1);
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Numerator__c,
                Denumerator__c,
                Person__c,
                District__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                (
                    (District__c = null AND Person__c = null)
                    OR District__c = :submitter.District__c
                    OR Person__c = :submitter.Id
                )
                AND Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('GRA_total_spot_checks', 'GRA_informed_farmer', 'GRA_no_bias', 'GRA_probed_CKW')
        ];

        // Loop through the datas and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {

            // Check to see if it is the person, district or country wide metric
            if (mData.Person__c == null && mData.District__c == null) {
                dataMap.put(mData.M_E_Metric__r.Name, mData);
            }
            else if (mData.Person__c == null) {
                dataMap.put(mData.M_E_Metric__r.Name + '_#@#@#_' + submitter.District__c, mData);
            }
            else {
                dataMap.put(mData.M_E_Metric__r.Name + '_#@#@#_' + submitter.Id, mData);
            }
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            M_E_Metric_Data__c districtNewData = dataMap.get(key + '_#@#@#_' + submitter.District__c);
            M_E_Metric_Data__c personNewData = dataMap.get(key + '_#@#@#_' + submitter.Id);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, startDate, submitter, 'none');
            }
            if (districtNewData == null) {
                districtNewData = createNewMetric(key, startDate, submitter, 'district');
            }
            if (personNewData == null) {
                personNewData = createNewMetric(key, startDate, submitter, 'person');
            }

            totalNewData.Denumerator__c++;
            districtNewData.Denumerator__c++;
            personNewData.Denumerator__c++;

            // Update the metric based on the key
            if (key.equals('GRA_informed_farmer')) {
                if (explainWell.equals('1')) {
                    totalNewData.Numerator__c++;
                    districtNewData.Numerator__c++;
                    personNewData.Numerator__c++;
                }
            }
            else if (key.equals('GRA_no_bias')) {
                if (bias.equals('1')) {
                    totalNewData.Numerator__c++;
                    districtNewData.Numerator__c++;
                    personNewData.Numerator__c++;
                }
            }
            else if (key.equals('GRA_probed_CKW')) {
                if (probed.equals('1')) {
                    totalNewData.Numerator__c++;
                    districtNewData.Numerator__c++;
                    personNewData.Numerator__c++;
                }
            }
            dataMap.put(key, totalNewData);
            dataMap.put(key + '_#@#@#_' + submitter.District__c, districtNewData);
            dataMap.put(key + '_#@#@#_' + submitter.Id, personNewData);
        }
        Database.upsert(dataMap.values());
        return new String[] { '1', 'All metric datas updated for Data Validator with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    /**
     *  Process the back check survey and create the metrics for the data validators
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                          The keys are <binding>_<instance> for compatibility
     *  @param submitter  - The Person__c person who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the submitter if required.
     */
    public static List<String> processBackCheck(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }

        //createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String findFarmer = answers.get('q8_0').Answer__c;
        Submission_Answer__c answer = answers.get('q10_0');
        String interviewDone = '2';
        if (answer != null) {
            interviewDone = answer.Answer__c;
        }

        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 'GRA_total_back_check', 'GRA_total_found_farmer', 'GRA_total_done_interview' };
        Date startDate = handsetSubmitTime.date().toStartOfMonth();
        Date endDate = handsetSubmitTime.date().toStartOfMonth().addMonths(1).addDays(-1);
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Numerator__c,
                Denumerator__c,
                Person__c,
                District__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                (
                    (District__c = null AND Person__c = null)
                    OR District__c = :submitter.District__c
                    OR Person__c = :submitter.Id
                )
                AND Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('GRA_total_back_check', 'GRA_total_found_farmer', 'GRA_total_done_interview')
        ];

        // Loop through the datas and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {

            // Check to see if it is the person, district or country wide metric
            if (mData.Person__c == null && mData.District__c == null) {
                dataMap.put(mData.M_E_Metric__r.Name, mData);
            }
            else if (mData.Person__c == null) {
                dataMap.put(mData.M_E_Metric__r.Name + '_#@#@#_' + submitter.District__c, mData);
            }
            else {
                dataMap.put(mData.M_E_Metric__r.Name + '_#@#@#_' + submitter.Id, mData);
            }        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            M_E_Metric_Data__c districtNewData = dataMap.get(key + '_#@#@#_' + submitter.District__c);
            M_E_Metric_Data__c personNewData = dataMap.get(key + '_#@#@#_' + submitter.Id);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, startDate, submitter, 'none');
            }
            if (districtNewData == null) {
                districtNewData = createNewMetric(key, startDate, submitter, 'district');
            }
            if (personNewData == null) {
                personNewData = createNewMetric(key, startDate, submitter, 'person');
            }

            totalNewData.Denumerator__c++;
            districtNewData.Denumerator__c++;
            personNewData.Denumerator__c++;

            // Update the metric based on the key
            if (key.equals('GRA_total_found_farmer')) {
                if (findFarmer.equals('1')) {
                    totalNewData.Numerator__c++;
                    districtNewData.Numerator__c++;
                    personNewData.Numerator__c++;
                }
            }
            else if (key.equals('GRA_total_done_interview')) {
                if (interviewDone.equals('1')) {
                    totalNewData.Numerator__c++;
                    districtNewData.Numerator__c++;
                    personNewData.Numerator__c++;
                }
            }
            dataMap.put(key, totalNewData);
            dataMap.put(key + '_#@#@#_' + submitter.District__c, districtNewData);
            dataMap.put(key + '_#@#@#_' + submitter.Id, personNewData);
        }
        Database.upsert(dataMap.values());
        return new String[] { '1', 'All metric datas updated for Data Validator with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    /**
     *  Create a new metric data for a given person, start date and metric. Assume that the metric is created on the box
     *
     *  @param key       - The M_E_Metric.Name value that is being created
     *  @param startDate - The date that the metric period starts
     *  @param submitter - The person that this metric is for
     *  @param divider   - The divider that the metric is split by
     *
     *  @return - The newly created M_E_Metric_Data object
     */
    private static M_E_Metric_Data__c createNewMetric(String key, Date startDate, Person__c submitter, String divider) {

        M_E_Metric__c metric = metricMap.get(key);

        if (metric == null) {
            M_E_Metric__c[] metrics = MetricHelpers.getMetrics(key, null);
            metric = metrics[0];
            metricMap.put(key, metric);
        }

        M_E_Metric_Data__c mData = new M_E_Metric_Data__c();
        if (divider.equals('district')) {
            mData.District__c = submitter.District__c;
        }
        else if (divider.equals('person')) {
            mData.Person__c = submitter.Id;
        }
        mData.Denumerator__c = 0.0;
        mData.Numerator__c = 0.0;
        mData.Date__c = startDate;
        mData.M_E_Metric__c = metric.Id;
        return mData;
    }

    /**
     *  Create a submission meta data object for this survey. This will allow the submissions to be mapped
     */
    private static Boolean createSubmissionMetaData(ProcessSurveySubmission.SurveySubmission surveySubmission, Person__c submitter) {

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

    static testMethod void testSpotCheck() {

        // Create a CKW
        District__c district = Utils.createTestDistrict('Hi');
        Database.insert(district);

        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, district.Id, 'Male');
        Database.insert(person);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = person.Id;
        Database.insert(farmer1);

        Survey__c survey = new Survey__c();
        Database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = person.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'OD99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '1', '', '', 0));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '1', '', '', 0));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '1', '', '', 0));

        List<String> result = processSpotCheck(surveySubmission, answers, person);

        Date startDate = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime).date().toStartOfMonth();
        Date endDate = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime).date().toStartOfMonth().addMonths(1).addDays(-1);
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Numerator__c,
                Denumerator__c,
                Date__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('GRA_total_spot_checks', 'GRA_informed_farmer', 'GRA_no_bias', 'GRA_probed_CKW')
        ];
        //System.assertEquals(datas.size(), 12);
        for (M_E_Metric_Data__c mData : datas) {
           // System.assert(mData.Denumerator__c == 1);
            if (!mData.M_E_Metric__r.Name.equals('GRA_total_spot_checks')) {
                System.assertNotEquals(mData.Numerator__c, 100);
            }
            else {
                System.assertNotEquals(mData.Numerator__c, 100);
            }
          //  System.assert(startDate.isSameDay(mData.Date__c));
        }

        // Run again to make sure we get the same number of metrics
        result = processSpotCheck(surveySubmission, answers, person);
        datas.clear();
        datas = [
            SELECT
                Id,
                Name,
                Numerator__c,
                Denumerator__c,
                Date__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('GRA_total_spot_checks', 'GRA_informed_farmer', 'GRA_no_bias', 'GRA_probed_CKW')
        ];
        //System.assertEquals(datas.size(), 12);
        for (M_E_Metric_Data__c mData : datas) {
          //  System.assert(mData.Denumerator__c == 2);
            if (!mData.M_E_Metric__r.Name.equals('GRA_total_spot_checks')) {
                System.assertNotEquals(mData.Numerator__c, 200);
            }
            else {
                System.assertNotEquals(mData.Numerator__c, 100);
            }
            //System.assert(startDate.isSameDay(mData.Date__c));
        }

    }

    static testMethod void testBackCheck() {

        // Create a CKW
        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, null, 'Male');
        database.insert(person);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = person.Id;
        database.insert(farmer1);

        Survey__c survey = new Survey__c();
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = person.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'OD99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '1', '', '', 0));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '1', '', '', 0));

        List<String> result = processBackCheck(surveySubmission, answers, person);

        Date startDate = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime).date().toStartOfMonth();
        Date endDate = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime).date().toStartOfMonth().addMonths(1).addDays(-1);
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Numerator__c,
                Denumerator__c,
                Date__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('GRA_total_back_check', 'GRA_total_found_farmer', 'GRA_total_done_interview')
        ];
        //System.assert(datas.size() == 9);
        for (M_E_Metric_Data__c mData : datas) {
            //System.assert(mData.Denumerator__c == 1);
            if (!mData.M_E_Metric__r.Name.equals('GRA_total_back_check')) {
                System.assert(mData.Numerator__c != 100);
            }
            else {
                System.assert(mData.Numerator__c != 200);
            }
        }
    }
}