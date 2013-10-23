public with sharing class UDoMSurveyProcessing {

    // Code to identify a single_graph_point__c for the rain gauge survey
    public static String GRAPH_TYPE_DAILY = 'UDoMDRGD';
    public static String GRAPH_TYPE_MONTHLY = 'UDoMDRGM';
    public static String GRAPH_TYPE_INACCURATE = 'UDOMINAC';
    public static String GRAPH_TYPE_MOD_ACC = 'UDOMMODAC';
    public static String GRAPH_TYPE_VER_ACC = 'UDOMVERAC';

    /**
     *  Class to deal with the post processing of surveys for the UDoM project
     */

    /**
     *  Take the data from a rain gauge survey and 
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
    public static List<String> processDailyRainGauge(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }

        Decimal value = Decimal.valueOf(answers.get('q1_0').Answer__c);

        // Sort out the GPS location that the activity was carried out. This will need to be split up
        String[] gps = answers.get('q3_0').Answer__c.split(' ');
        String latitude = 'N/A';
        String longitude = 'N/A';
        Decimal accuracy = -1;
        if (gps.size() >= 4) {
            latitude = gps[0];
            longitude = gps[1];
            accuracy = Decimal.valueOf(gps[3]);
        }

        // Check that the CKW submitted the survey from close enough to their rain gauge
        Client_Location__c rainGauge = getRainGauge(submitter);
        if (rainGauge == null) {
            return new String[] { '0', 'CKW with IMEI: ' + submission.imei + ' has not submitted their Rain Gauge Location Survey', 'SUPRESSMSG' };
        }
        if (!checkDistanceToRainGauge(
                Decimal.valueOf(rainGauge.Latitude__c),
                Decimal.valueOf(rainGauge.Longitude__c),
                Decimal.valueOf(latitude),
                Decimal.valueOf(longitude),
                accuracy
        )) {

            // This needs to be set to 3 when the code for the middle tier goes live
            return new String[] { '1', 'Distance between submission and Rain Gauge location too high for CKW with imei: ' + submission.imei, 'SUPRESSMSG' };
        }

        List<Single_Graph_Point__c> pointsToAdd = new List<Single_Graph_Point__c>();

        // Create a new Daily point
        Boolean repeat = false;
        Single_Graph_Point__c dailyPoint;
        Single_Graph_Point__c[] dailyPoints = [SELECT
                Id,
                Name,
                Value__c
            FROM
                Single_Graph_Point__c
            WHERE
                Person__c = :submitter.Id
                AND Date__c = :handsetSubmitTime.date()
                AND Graph_Type__r.Unique_Identifier__c = :GRAPH_TYPE_DAILY]; 
        if (dailyPoints.size() == 0) {
            dailyPoint = createNewGraphPoint(submitter, GRAPH_TYPE_DAILY, handsetSubmitTime.date(), value, latitude, longitude);
        }
        else {
            dailyPoint = dailyPoints[0];
            repeat = true;
        }
        if (repeat) {
            return new String[] { '1', 'Repeat Submission so ignore', 'SUPRESSMSG' };
        }

        if (dailyPoint == null) {
            return new String[] { '0', 'Failed to create a daily rain gauge point', 'SUPRESSMSG' };
        }
        pointsToAdd.add(dailyPoint);

        // Load the graph point for this month
        Date startOfMonth = handsetSubmitTime.date().toStartOfMonth();
        Single_Graph_Point__c monthlyPoint;
        Single_Graph_Point__c[] monthlyPoints = [SELECT
                Id,
                Name,
                Value__c
            FROM
                Single_Graph_Point__c
            WHERE
                Person__c = :submitter.Id
                AND Date__c = :startOfMonth
                AND Graph_Type__r.Unique_Identifier__c = :GRAPH_TYPE_MONTHLY];
        if (monthlyPoints.size() == 0) {
            monthlyPoint = createNewGraphPoint(submitter, GRAPH_TYPE_MONTHLY, startOfMonth, value, null, null);
            if (monthlyPoint == null) {
                return new String[] { '0', 'Failed to create a monthly rain gauge point', 'SUPRESSMSG' };
            }
        }
        else {
            monthlyPoint = monthlyPoints[0];
            monthlyPoint.Value__c += value;
        }
        pointsToAdd.add(monthlyPoint);
        monthlyPoints.clear();

        // Update the point for the accuracy. These are warehoused monthly so monthly tend can be seen
        Single_Graph_Point__c accuracyPoint;
        Single_Graph_Point__c[] accuracyPoints = [SELECT
                Id,
                Name,
                Value__c
            FROM
                Single_Graph_Point__c
            WHERE
                Person__c = :submitter.Id
                AND Date__c = :startOfMonth
                AND Graph_Type__r.Unique_Identifier__c = :translateAccuracy(answers.get('q2_0').Answer__c)];
        if (accuracyPoints.size() == 0) {
            accuracyPoint = createNewGraphPoint(submitter, translateAccuracy(answers.get('q2_0').Answer__c), startOfMonth, 1.0, null, null);
            if (accuracyPoint == null) {
                return new String[] { '0', 'Failed to create a accuracy point', 'SUPRESSMSG' };
            }
        }
        else {
            accuracyPoint = accuracyPoints[0];
            accuracyPoint.Value__c += 1.0;
        }
        pointsToAdd.add(accuracyPoint);
        Database.upsert(pointsToAdd);
        return new String[] { '1', 'All points saved successfully. Saved ' + pointsToAdd.size() + ' graph points', 'SUPRESSMSG' };
    }

    private static String translateAccuracy(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => GRAPH_TYPE_VER_ACC,
            '2' => GRAPH_TYPE_MOD_ACC,
            '3' => GRAPH_TYPE_INACCURATE
        };
        return translationMap.get(optionNumber);
    }

    private static Single_Graph_Point__c createNewGraphPoint(Person__c person, String identifier, Date startDate, Decimal value, String latitude, String longitude) {

        if (value == null) {
            value = 0.0;
        }
        Graph_Type__c graphType = loadGraphType(identifier);
        if (graphType == null) {
            return null;
        }
        Single_Graph_Point__c point = new Single_Graph_Point__c();
        point.Graph_Type__c = graphType.Id;
        point.Person__c = person.Id;
        point.Date__c = startDate;
        point.Value__c = value;
        point.Latitude__c = latitude;
        point.Longitude__c = longitude;
        return point;
    }

    private static Graph_Type__c loadGraphType(String identifier) {

        Graph_Type__c[] graphType = [SELECT
                Id
            FROM
                Graph_Type__c
            WHERE
                Unique_Identifier__c = :identifier];
        if (graphType.size() != 1) {
            System.debug(LoggingLevel.INFO, 'Cannot load Graph Type for identifier: ' + identifier);
            return null;
        }
        return graphType[0];
    }

    /**
     *  Load the rain gauge for the submitter
     */
    private static Client_Location__c getRainGauge(Person__c submitter) {

        // Client should only ever have one of these but just in case some fool has
        // added an extra one manually for a person we will assume that it is the first one
        // that is returned
        Client_Location__c[] rainGauges = [SELECT
                Id,
                Name,
                Latitude__c,
                Longitude__c
            FROM
                Client_Location__c
            WHERE
                Type__c = 'Rain Gauge'
                AND Person__c = :submitter.Id];

        if (rainGauges.size() == 0) {
            return null;
        }
        return rainGauges[0];
    }

    /**
     *  Check that the submission was less than 50m from the registered location of the rain gauge.
     */
    private static Boolean checkDistanceToRainGauge(Decimal rainGaugeLat, Decimal rainGaugeLng, Decimal submissionLat, Decimal submissionLng, Decimal accuracy) {

        if (rainGaugeLat == null || rainGaugeLng == null || submissionLat == null || submissionLng == null) {
            return false;
        }

        if (calcDistance(rainGaugeLat, rainGaugeLng, submissionLat, submissionLng) - accuracy < 50) {
            return true;
        }
        return false;
    }

    /**
     * Returns the distance from this point to the supplied point, in m 
     * (using Haversine formula)
     *
     * from: Haversine formula - R. W. Sinnott, "Virtues of the Haversine",
     *       Sky and Telescope, vol 68, no 2, 1984
     * */
    private static Decimal calcDistance(Decimal lat1, Decimal lng1, Decimal lat2, Decimal lng2) {

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
        
        return varD * 1000;
    }

    /**
     *  Take the data from a raingauge registration survey and create the rain gauge
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
    public static List<String> registerRainGauge(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter) {

        // Try to load a rain gauge to check the submitter has not done one already.
        Client_Location__c[] rainGauges = [SELECT
                Name,
                Id,
                Latitude__c,
                Longitude__c
            FROM
                Client_Location__c
            WHERE
                Type__c = 'Rain Gauge'
                AND Person__r.Id = :submitter.Id
                AND Account__r.Name = 'Uganda Department of Meteorology'];

        Client_Location__c rainGauge;
        if (rainGauges.size() > 0) {
            rainGauge = rainGauges[0];
        }
        else {

            // Create a new rain gauge
            rainGauge = new Client_Location__c();

            Account uDom = [SELECT
                    Id
                FROM
                    Account
                WHERE
                    Name = 'Uganda Department of Meteorology'];
            rainGauge.Account__c = uDom.Id;
            rainGauge.Description__c = 'Rain Gauge for UDoM';
            rainGauge.Type__c = 'Rain Gauge';
            rainGauge.Person__c = submitter.Id;
            rainGauge.District__c = submitter.District__c;
            rainGauge.Display_Name__c = 'UDoM Rain Gauge';
        }

        // Sort out the GPS location that the rain gauge was placed. This will need to be split up.
        String[] gps = answers.get('q1_0').Answer__c.split(' ');
        String latitude = 'N/A';
        String longitude = 'N/A';
        if (gps.size() >= 2) {
            latitude = gps[0];
            longitude = gps[1];
        }
        else {
            return new String[] { '0', 'Submission does not contain GPS coordinates', 'SUPRESSMSG' };
        }
        rainGauge.Latitude__c = latitude;
        rainGauge.Longitude__c = longitude;
        Database.upsert(rainGauge);
        return new String[] { '1', 'Rain Gauge saved successfully', 'SUPRESSMSG' };
    }

    static testMethod void testRegisterRainGauge() {

        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, null, 'Male');
        database.insert(person);

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '35.0 1.0', '', '', 0));

        // Test success
        List<String> result = registerRainGauge(submission, answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));

        // Submit again to check that the registration is just updated
        result = registerRainGauge(submission, answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));

        // Test that all the points got created
        Client_Location__c[] points = [SELECT id FROM Client_Location__c WHERE Person__c = :person.Id];
        System.assert(points.size() == 1);
    }

    static testMethod void testRainGaugeProcessing() {

        Person__c person = Utils.createTestPerson(null, 'TestPerson', true, null, 'Male');
        database.insert(person);

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '3', '', '', 0));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '2', '', '', 0));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '35.0 1.0 0 5.0 0', '', '', 0));

        // Test submission when the person has no rain gauge
        List<String> result = processDailyRainGauge(submission, answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('0'));
        System.assert(result.get(1).equals('CKW with IMEI: ' + submission.imei + ' has not submitted their Rain Gauge Location Survey'));

        Client_Location__c location = new Client_Location__c();
        location.Type__c = 'Rain Gauge';
        location.Latitude__c = '35.0';
        location.Longitude__c = '1.0';
        location.Person__c = person.Id;
        location.Display_Name__c = 'Name of something';
        Database.insert(location);

        // Test success
        result = processDailyRainGauge(submission, answers, person);
        System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
        System.assert(result.get(0).equals('1'));

        // Test resubmitting with the same date. should not change the number of sgps created
        result = processDailyRainGauge(submission, answers, person);
        System.assert(result.get(0).equals('1'));
        System.assert(result.get(1).equals('Repeat Submission so ignore'));

        // Test that the distance calc works
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'subcounty', '36.0 1.0 0 5.0 0', '', '', 0));
        result = processDailyRainGauge(submission, answers, person);

        // Set back to 3 when Surveys Server code goes live
        //System.assert(result.get(0).equals('3'));
        System.assert(result.get(0).equals('1'));
        System.assert(result.get(1).equals('Distance between submission and Rain Gauge location too high for CKW with imei: ' + submission.imei));

        // Test that all the points got created
        Single_Graph_Point__c[] points = [SELECT id FROM Single_Graph_Point__c WHERE Person__c = :person.Id];
        System.assert(points.size() == 3);
    }

    static testMethod void testDistance() {

        Decimal startLat = 0.32652019;
        Decimal startLong = 32.59782455;

        Decimal withinLat = 0.32651643;
        Decimal withinLong = 32.5980;

        Decimal withoutLat = 0.32640741;
        Decimal withoutLong = 32.59844715;

        Decimal accuracy = 5.0;

        // Check the difference is less than 50m
        System.assert(checkDistanceToRainGauge(startLat, startLong, withinLat, withinLong, accuracy));

        // Check that the distance is more than 50m
        System.assert(checkDistanceToRainGauge(startLat, startLong, withoutLat, withoutLong, accuracy) == false);
    }
}