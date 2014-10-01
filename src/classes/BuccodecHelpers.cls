/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Helpers class for Buccodeg Dashboard's related classes
 *  Look at the BUCCODEG dashboard implementation documentation in confluence
 *  in order to understand how the object M_E_Metric_Data__c actually stores the 
 *  metric data
 *
 *  This class's test methods are in the BuccodecTests class 
 **/
public class BuccodecHelpers {
	
    public static final String ORG_NAME = 'BUCCODEG CAFE Project';
    public static final String USER_NAME = 'BUCCODEG';
    public static String query =
        'SELECT ' +
            'Id, ' +
            'M_E_Metric__c, ' +
            'Actual_Value__c, ' +
            'Manual_Value__c, ' +
            'Real_Value__c, ' +
            'Projected_Value__c, ' +
            'Numerator__c, ' +
            'Denumerator__c, ' +
            'Comment__c, ' +
            'Date__c, ' +
            'M_E_Metric__r.Name, ' +
            'M_E_Metric__r.M_E_Area__c, ' +
            'M_E_Metric__r.Update_Period__c, ' +
            'M_E_Metric__r.Label__c, '  +
            'M_E_Metric__r.Sub_Area__c, '  +
            'M_E_Metric__r.Order__c, '  +
            'M_E_Metric__r.Projected_Value__c, '  +
            'M_E_Metric__r.Calculation_Type__c, '  +
            'M_E_Metric__r.Is_On_Fly__c, '  +
            'M_E_Metric__r.Automated__c, '  +
            'M_E_Metric__r.On_The_Fly_Calculation_Type__c, '  +
            'M_E_Metric__r.Metric_Section__r.Is_Active__c, '  +
            'M_E_Metric__r.Is_Header__c ';
    
    public static Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();
    
    public static BuccodecHelpers.Wrapper getData(String quarter) {

        Map<String, Map<String, BuccodecHelpers.DataWrapper>> metricWrappers = new Map<String, Map<String, 
            BuccodecHelpers.DataWrapper>>();
        Map<String, List<String>> metricWrapperOrder = new Map<String, List<String>>();

        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(quarter);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);

        // Check if this is for public consumption or not
        String notForPublicString = '';
        notForPublicString = UserInfo.getUserType() == 'GUEST' ? 
                'AND M_E_Metric__r.Not_For_Public__c != true ' : notForPublicString;

        // Check to see which organisations this page is for.
        String organisationName = ORG_NAME;
        if (organisationName != null && !organisationName.equals('null')) {
            organisationName = '\'' + organisationName + '\'';
        }

        String organisationString = 'AND M_E_Metric__r.Organisation__r.Name = ' + organisationName + ' ';

        String query1 = query +
            'FROM ' +
                'M_E_Metric_Data__c ' +
            'WHERE ' +
                'Date__c >= :quarterFirstDay ' +
                'AND Date__c <= :quarterLastDay ' +
                'AND Is_Cumulative__c = false ' +
                notForPublicString +
                organisationString +
            'ORDER BY '                                 +
                'M_E_Metric__r.Order__c ASC, '          +
                'Date__c ASC ';

        String metricName = '';
        String metricKey = '';
        String districtName = '';
        String areaName = '';
        BuccodecHelpers.DataWrapper metricDataWrapper = null;
        List<String> metricOrder = null;
        Map<String, BuccodecHelpers.DataWrapper> areaMap = null;
        System.debug(LoggingLevel.INFO, query1);
        for (M_E_Metric_Data__c metric : database.query(query1)) {
            // See if we have a valid metric name and that it is not the same as the next metric in the list.
            // If it isn't then we need to save the metric from the last loop and move on to a new metric
            if (!metricName.equals(metric.M_E_Metric__r.Name)) {
                // Save the previous object to the list
                if (metricDataWrapper != null) {
                    areaMap = metricWrappers.get(areaName);
                    if (areaMap == null) {
                        areaMap = new Map<String, BuccodecHelpers.DataWrapper>();
                    }
                    metricOrder = metricWrapperOrder.get(areaName);
                    if (metricOrder == null) {
                        metricOrder = new List<String>();
                    }

                    metricKey = metricName;

                    areaMap.put(metricKey, metricDataWrapper);
                    metricOrder.add(metricKey);
                    metricWrappers.put(areaName, areaMap);
                    metricWrapperOrder.put(areaName, metricOrder);
                }

                // Create the new object and update the name if the new name is valid
                metricDataWrapper = new BuccodecHelpers.DataWrapper();
                metricName = metric.M_E_Metric__r.Name;
            }

            // See if we have moved on to a new area and that the area exists
            areaName = metric.M_E_Metric__r.M_E_Area__c;
            if (areaName == null || areaName.equals('')) {
                metricDataWrapper = null;
                continue;
            }
            metricDataWrapper.name = metricName;
            metricDataWrapper.label = metric.M_E_Metric__r.Label__c;
            metricDataWrapper.order = metric.M_E_Metric__r.Order__c;
            metricDataWrapper.metric_id = metric.M_E_Metric__r.Id;
            metricDataWrapper.metric_data_id = metric.Id;
            metricDataWrapper.quarter_target = metric.Projected_Value__c;
            metricDataWrapper.quarter_actual_reached = (Integer)metric.Numerator__c;
            //Formular field. It displays Manual_Value__c
            metricDataWrapper.project_target = metric.Real_Value__c == null ? 0 : (Integer)metric.Real_Value__c;
            // calculating cummulative value. For manual indicators just display value
            if(metric.M_E_Metric__r.Automated__c == 'True') {
                if(metricDataWrapper.project_target != 0 && (metric.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Sum' || 
                        metric.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Count')) {
                    metricDataWrapper.quarter_actual_reached = (Integer)metric.Numerator__c;
                    // calculate the cummulative value up to and including current quarter
	                AggregateResult cummulativeResult = [
	                        SELECT 
	                            SUM(Numerator__c) numerator
	                        FROM 
	                            M_E_Metric_Data__c 
	                        WHERE 
                                M_E_Metric__r.Name = :metricName
	                            AND Date__c <= :quarterLastDay];
	                metricDataWrapper.cummulative_actual_reached = cummulativeResult.get('numerator') == null ? 
	                       0.0 : (Decimal)cummulativeResult.get('numerator');
	                system.debug(metricName + ' value is ' + metricDataWrapper.cummulative_actual_reached);
	                metricDataWrapper.percent_cummulative_actual_reached = 
	                        (metricDataWrapper.cummulative_actual_reached / metricDataWrapper.project_target) * 100;
                }
                else if(metric.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Percentage'){
                    metricDataWrapper.quarter_actual_reached = 
                            ((metric.Numerator__c / metric.Denumerator__c) * 100);
                    // calculate the % cummulative value up to and including current quarter
                    AggregateResult cummulativeResult = [
                            SELECT 
                                SUM(Numerator__c) numerator,
                                SUM(Denumerator__c) denumerator 
                            FROM 
                                M_E_Metric_Data__c 
                            WHERE 
                                M_E_Metric__r.Name = :metricName
                                AND Date__c <= :quarterLastDay];
                    metricDataWrapper.cummulative_actual_reached = ((Decimal)cummulativeResult.get('numerator') / 
                            (Decimal)cummulativeResult.get('denumerator')) * 100;
                    metricDataWrapper.percent_cummulative_actual_reached = 
                            (metricDataWrapper.cummulative_actual_reached / metricDataWrapper.project_target) * 100;
                }
            }
            else {
                // if project target is not set, skip
                metricDataWrapper.cummulative_actual_reached = metric.Actual_Value__c;
                Decimal percent = (metric.Actual_Value__c != null && metric.Real_Value__c != null &&
                        metric.Real_Value__c != Decimal.valueOf(0)) ? (metric.Actual_Value__c / metric.Real_Value__c) * 100 : null;
                metricDataWrapper.percent_cummulative_actual_reached = percent;
            }
            // calculate the % actual for this quarter: skip if quarter projected value is not provided
            Decimal percentQuarter = (metricDataWrapper.percent_quarter_actual_reached != null &&
                    metric.Projected_Value__c != null && metric.Projected_Value__c != Decimal.valueOf(0)) ?
                    (metricDataWrapper.quarter_actual_reached / metric.Projected_Value__c) * 100 : null;
            metricDataWrapper.percent_quarter_actual_reached = percentQuarter;
            metricDataWrapper.setSparkUrl(String.valueOf(metric.M_E_Metric__r.Id));
        }

        // Add the last object
        metricKey = metricName;
        if (districtName != null) {
            metricKey = MetricHelpers.createMetricLabelString(metricName, districtName);
        }
        areaMap = metricWrappers.get(areaName);
        if (areaMap == null) {
            areaMap = new Map<String, BuccodecHelpers.DataWrapper>();
        }

        metricOrder = metricWrapperOrder.get(areaName);
        if (metricOrder == null) {
            metricOrder = new List<String>();
        }
        areaMap.put(metricKey, metricDataWrapper);
        metricWrappers.put(areaName, areaMap);
        metricOrder.add(metricKey);
        metricWrapperOrder.put(areaName, metricOrder);

        return new BuccodecHelpers.Wrapper(metricWrappers, metricWrapperOrder);
    }
    
    /**
    *  Post-processing method for BUCCODEG surveys that affect dashboard indicators
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object of the CKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team.
    *                          This message will be displayed to the user if element 1 is "fail".
    *              element 3 - Determines if Pulse message will be sent:
    *                          SUPRESSMSG   - No pulse message is sent
    *                          PULSE        - Pulse message is sent
    */    
    public static List<String> surveysPostProcessing(ProcessSurveySubmission.SurveySubmission submission, 
            Map<String, Submission_Answer__c> answers, Person__c interviewer) {
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('Farmer Reg')) {
            type = SubmissionType.FARMER_REGISTRATION;
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('CKW Monitoring')){
            type = SubmissionType.CKW_MONITORING;
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'BUCCODEG post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
	        if(type == SubmissionType.FARMER_REGISTRATION){
	            
	            User[] owner = [SELECT Id FROM User WHERE LastName = :USER_NAME];
	            metricNames = new List<String> { 
	                'BUCCODEC_total_farmers_reached',
	                'BUCCODEC_percent_male_farmers_reached',
	                'BUCCODEC_percent_female_farmers_reached'
	            };
	            
	            String farmerId = answers.get('q1_0').Answer__c;
	            String farmerName = answers.get('q2_0').Answer__c;
	            String location = answers.get('q3_0').Answer__c;
	            String subLocation = answers.get('q4_0').Answer__c;
                String gender = answers.get('q5_0').Answer__c == '1' ? 'Male' : 'Female';
	            boolean isFemale = answers.get('q5_0').Answer__c.equals('2');
                String landAcres = answers.get('q6_0').Answer__c;
                String crops = translateCrops(answers.get('q7_0').Answer__c);
                String animals = translateAnimals(answers.get('q21_0').Answer__c);
                
                // we shouldnt proceed if the farmer is already registered
                // one anticipated issue here is if the earlier farmer was not created by a BUCCODEG CKW
                List<Farmer__c> farmer = [SELECT Id FROM Farmer__c WHERE Name = :farmerId];
                if(!farmer.isEmpty()){
                    throw new BuccodegException('Farmer ID ' + farmerId.toUpperCase() + ' is already used');
                }
                
                // person object for the farmer
                Person__c farmerPerson = new Person__c();
                farmerPerson.First_Name__c = farmerName.trim().contains(' ') ? farmerName.trim().split(' ')[0] : farmerName;
                farmerPerson.Last_Name__c = farmerName.trim().contains(' ') ? farmerName.trim().split(' ')[1] : farmerName;
                farmerPerson.Village__c = location;
                farmerPerson.Parish__c = subLocation;
                farmerPerson.Gender__c = gender;
                farmerPerson.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Kenya'].get(0).Id;
                farmerPerson.Type__c = 'Farmer';
                farmerPerson.OwnerId = owner[0].Id;
                farmerPerson.GPS_Location_E__c = submission.interviewLongitude != null ? submission.interviewLongitude : '';
                farmerPerson.GPS_Location_N__c = submission.interviewLatitude != null ? submission.interviewLatitude : '';
                insert farmerPerson;
                // farmer object with reference to the person created
                Farmer__c farmerObject = new Farmer__c();
                //farmerObject.OwnerId = owner[0].Id;
                farmerObject.Person__c = farmerPerson.Id;
                farmerObject.Name = farmerId;
                farmerObject.Registered_By__c = interviewer.Id;
                farmerObject.Land_Size__c = Decimal.valueOf(landAcres);
                farmerObject.Registered_Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
                farmerObject.Crops__c = crops;
                farmerObject.Livestock__c = animals;
                insert farmerObject;
	            
	            M_E_Metric_Data__c[] datas = [
	                SELECT
	                    Id,
	                    Name,
	                    Actual_Value__c,
	                    Manual_Value__c,
	                    District__c,
	                    Denumerator__c,
	                    Numerator__c,
	                    Subcounty__c,
	                    M_E_Metric__r.Name
	                FROM
	                    M_E_Metric_Data__c
	                WHERE
	                    Date__c = :currentDate //TODO: what if there is already an indicator for next quarter?
	                    AND M_E_Metric__r.Name IN :metricNames
	            ];
	            // Loop through the data and see which ones we have already got. 
	            // If they are not there already create them
	            for (M_E_Metric_Data__c mData : datas) {
	                 dataMap.put(mData.M_E_Metric__r.Name, mData);
	            }
	            // Loop through the list of metrics and check that they all exist and then update them
	            for (String key : metricNames) {
	                // Check that the three metrics for each metric name exists
	                M_E_Metric_Data__c totalNewData = dataMap.get(key);
	                totalNewData = totalNewData == null ? createNewMetric(key, currentDate) : totalNewData;
	                
	                // Update the metric based on the key
	                if (key.equals('BUCCODEC_total_farmers_reached')) {
	                    totalNewData.Numerator__c = totalNewData.Numerator__c == null ? 1 : totalNewData.Numerator__c + 1;
	                    totalNewData.Actual_Value__c = totalNewData.Actual_Value__c == null ? 1 : 
	                           totalNewData.Actual_Value__c + 1;
	                }
	                else if (key.equals('BUCCODEC_percent_male_farmers_reached')) {
	                    if(!isFemale) {
                            totalNewData.Numerator__c = totalNewData.Numerator__c == null ? 1 : totalNewData.Numerator__c + 1;
	                        totalNewData.Actual_Value__c = totalNewData.Actual_Value__c == null ? 1 : 
	                               totalNewData.Actual_Value__c + 1;
	                    }
	                    totalNewData.Denumerator__c += 1;
	                }
	                else if (key.equals('BUCCODEC_percent_female_farmers_reached')) {
	                    if(isFemale) {
                            totalNewData.Numerator__c = totalNewData.Numerator__c == null ? 1 : totalNewData.Numerator__c + 1;
                            totalNewData.Actual_Value__c = totalNewData.Actual_Value__c == null ? 1 : 
                                   totalNewData.Actual_Value__c + 1;
	                    }
	                    totalNewData.Denumerator__c += 1;
	                }
	                dataMap.put(key, totalNewData);
	            }
	        }
	        else if(type == SubmissionType.CKW_MONITORING) {
	            
	            metricNames = new List<String> { 
	                'BUCCODEC_total_FFS_held',
	                'BUCCODEC_total_VSLA_held'
	            };
	            // get the type of encounter
	            // '1' => 'VSLA session',
	            // '2' => 'Extension visits to individual farmers',
	            // '3' => 'Farmer Field School sessions'
	            String encounterIndex = answers.get('q7_0').Answer__c;
	            M_E_Metric_Data__c[] datas = [
	                SELECT
	                    Id,
	                    Name,
	                    Actual_Value__c,
	                    Manual_Value__c,
	                    District__c,
	                    Denumerator__c,
	                    Numerator__c,
	                    Subcounty__c,
	                    M_E_Metric__r.Name
	                FROM
	                    M_E_Metric_Data__c
	                WHERE
	                    Date__c = :currentDate//TODO: what if there is already an indicator for next quarter?
	                    AND M_E_Metric__r.Name IN :metricNames
	            ];
	            // Loop through the data and see which ones we have already got. 
	            // If they are not there already create them
	            for (M_E_Metric_Data__c mData : datas) {
	                 dataMap.put(mData.M_E_Metric__r.Name, mData);
	            }
	            // Loop through the list of metrics and check that they all exist and then update them
	            for (String key : metricNames) {
	                // Check that the three metrics for each metric name exists
	                M_E_Metric_Data__c totalNewData = dataMap.get(key);
	                totalNewData = totalNewData == null ? createNewMetric(key, currentDate) : totalNewData;
	                
	                // Update the metric based on the key
	                if (key.equals('BUCCODEC_total_FFS_held')) {
	                    if(encounterIndex == '3') {
                            totalNewData.Numerator__c = totalNewData.Numerator__c == null ? 1 : totalNewData.Numerator__c + 1;
                            totalNewData.Actual_Value__c = totalNewData.Actual_Value__c == null ? 1 : 
                                   totalNewData.Actual_Value__c + 1;
	                    }
	                    dataMap.put(key, totalNewData);
	                }
	                else if (key.equals('BUCCODEC_total_VSLA_held')) {
	                    if(encounterIndex == '1') {
                            totalNewData.Numerator__c = totalNewData.Numerator__c == null ? 1 : totalNewData.Numerator__c + 1;
                            totalNewData.Actual_Value__c = totalNewData.Actual_Value__c == null ? 1 : 
                                   totalNewData.Actual_Value__c + 1;
	                    }
	                    dataMap.put(key, totalNewData);
	                }
	            }            
	        }
	        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	        for(Database.upsertResult result : uResults) {
                system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	        }
        }
        catch(Exception ex) {
            return new String[]{ '0', 'BUCCODEG submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }
        return new String[]{ '1', 'BUCCODEG submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    /**
     *  Create a new metric data for a given person, start date and metric. 
     *  Assume that the metric is created on the box
     *
     *  @param key       - The M_E_Metric.Name value that is being created
     *  @param startDate - The date that the metric period starts or quarter start date
     *
     *  @return - The newly created M_E_Metric_Data object
     */
    public static M_E_Metric_Data__c createNewMetric(String key, Date startDate) {

        M_E_Metric__c metric = metricMap.get(key);
        
        if (metric == null) {
            M_E_Metric__c[] metrics = MetricHelpers.getMetrics(key, null);
            metric = metrics[0];
            metricMap.put(key, metric);
        }

        M_E_Metric_Data__c mData = new M_E_Metric_Data__c();
        mData.M_E_Metric__c = metric.Id;
        mData.Numerator__c = 0.0;
        mData.Denumerator__c = 0.0;
        mData.Manual_Value__c = 0.0;
        mData.Date__c = startDate;
        mData.Is_Cumulative__c = false;
        // get previous data to pass on some values
        Date previousQuaterDate = MetricHelpers.getQuarterFirstDay(startDate.addMonths(-1));
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                District__c,
                Denumerator__c,
                Numerator__c,
                Subcounty__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c = :previousQuaterDate
                AND M_E_Metric__r.Name = :key
        ];
        if(!datas.isEmpty()) {
            M_E_Metric_Data__c pData = datas[0];
            mData.Projected_Value__c = pData.Projected_Value__c;    // quartely target, use previous as default
            mData.Actual_Value__c = pData.Actual_Value__c;          // cummulative value
            mData.Manual_Value__c = pData.Manual_Value__c;          // project target (will display in Real_Value__c)
        }
        return mData;
    }
    
    /**
     *  Crops selection list
     *
     *  @param cropIndex - a crop position
     *
     *  @return - List Crop names
     */
    private static String translateCrops(String cropIndex) {

        String crops = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Maize',
            '2' => 'Coffee',
            '3' => 'Beans',
            '4' => 'Rice',
            '5' => 'Sugarcane',
            '6' => 'Millet',
            '7' => 'Sorghum',
            '8' => 'Vegetables',
            '9' => 'Bananas',
            '10' => 'Sweetpotatoes',
            '11' => 'Irish Potatoes',
            '12' => 'Cabbages',
            '13' => 'Cotton',
            '14' => 'Avocado',
            '15' => 'Mongoes',
            '16' => 'Pigeon Peas',
            '17' => 'Pumpkin',
            '18' => 'Soya',
            '20' => 'Other'
        };
        for(String index : cropIndex.split(' ')) {
            crops += translationMap.get(index) + ';';
        }
        return crops;
    }
    
    /**
     *  animal selection list
     *
     *  @param cropIndex - an animal select position
     *
     *  @return - List Animal names
     */
    private static String translateAnimals(String animalIndex) {

        String animals = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Cattle',
            '2' => 'Goats',
            '3' => 'Sheep',
            '4' => 'Chickens',
            '5' => 'Pigs',
            '6' => 'Rabbits',
            '7' => 'Fish',
            '8' => 'Bees',
            '9' => 'Guinea Fowl',
            '10' => 'Turkeys'
        };
        for(String index : animalIndex.split(' ')) {
            animals += translationMap.get(index) + ';';
        }
        return animals;
    }

    /**
     *  Get the group type from the new surveys
     *
     *  @param groupValue - A map containing the values for the the outlet visit
     *
     *  @return - Name of the group type
     */
    public static void getRawDataStats(){
        
        Date currentDate = MetricHelpers.getQuarterFirstDay(date.today());
        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];

        String query1 = 'CALL CountBuccodegSurveysApproved(\'' + currentDate + '\')';
        String requestBody = String.format(
            '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="{0}">{1}</SelectRequest>',
            new List<String>{ 'Surveys', query1 } );
        
        String testResult = '<?xml version="1.0"?><SelectResponse xmlns="http://schemas.applab.org/2010/07"><row><approved>123</approved><total_reviewed>456</total_reviewed></row></SelectResponse>';
        String queryResult = Test.isRunningTest() ? testResult : SqlHelpers.postServletRequest(configuration.URL__c, 'select', requestBody);
        System.debug(requestBody);
        System.debug(queryResult);
        
        String metricName = 'BUCCODEC_percent_quality_surveys';
        //create a xml doc for reading data
        DOM.Document doc = new DOM.Document();
        doc.load(queryResult);
        Dom.XmlNode envelope = doc.getRootElement();
        Dom.XmlNode row = envelope.getChildElement('row', 'http://schemas.applab.org/2010/07');
        Dom.XmlNode column = row.getChildElement('approved', 'http://schemas.applab.org/2010/07');
        Dom.XmlNode column2 = row.getChildElement('total_reviewed', 'http://schemas.applab.org/2010/07');

        Decimal approved = Decimal.valueOf(column.getText());
        Decimal totalReviewed = Decimal.valueOf(column2.getText());

        List<M_E_Metric_Data__c> datas = [
                SELECT
                    Id,
                    Name,
                    Projected_Value__c,
                    Actual_Value__c,
                    Manual_Value__c,
                    District__c,
                    Denumerator__c,
                    Numerator__c,
                    Subcounty__c,
                    M_E_Metric__r.Name
                FROM
                    M_E_Metric_Data__c
                WHERE
                    Date__c = :currentDate
                    AND M_E_Metric__r.Name = :metricName
        ];
        if(datas.isEmpty()){
            datas.add(createNewMetric(metricName, currentDate));
        }
        M_E_Metric_Data__c datum = datas[0];
        datum.Numerator__c = approved;
        datum.Denumerator__c = totalReviewed;
        update datum;      
    }

    /*
    * A Wrapper class that carries dashboard metrics data to VF page
    */
    public class DataWrapper {

        public String name { get; set; }
        public String label { get; set; }
        public Decimal quarter_target { get; set; }
        public Decimal quarter_actual_reached { get; set; }
        public Double percent_quarter_actual_reached { get; set; }
        public Integer project_target { get; set; }
        public Decimal cummulative_actual_reached { get; set; }
        public Double percent_cummulative_actual_reached { get; set; }
        public Decimal order { get; set; }
        public Id metric_id { get; set; }
        public Id metric_data_id { get; set; }
        public String spark_url { get; set; }

        public DataWrapper() {
        }
        
	    public void setSparkUrl(String metricId) {
	
	        spark_url = 'http://chart.apis.google.com/chart?chs=55x20&cht=lxy:nda' +
	                       '&chco=00FF00,0000FF&chf=bg,s,00000000&chls=2|2';
	        String query1 = query +
	            'FROM ' +
	                'M_E_Metric_Data__c ' +
	            'WHERE ' +
	                'M_E_Metric__r.Id = :metricId ';
	        M_E_Metric_Data__c[] data = database.query(query1);
	
	        String chdActual = ''; // Actual values
	        String chdProjected = ''; // Projected values
	
	        // Because we show one less coordinate for the actual graph, we have to do xy graphs, 
	        // so we need to track the xpoint
	        Integer xCount = 0;
	        Integer total = data.size();
	        String xProjected = '';
	        String xActual = ''; 
	
	        for(M_E_Metric_Data__c item : data) {
	            
	            chdProjected += item.Projected_Value__c  != null ? item.Projected_Value__c + ',' : '0,';
	            xProjected += (xCount * 100 / Math.max(1, total - 1)) + ',';
	
	            // Only show the actual value for the previous quarters
	            if(!MetricHelpers.getCurrentQuarterAsString(0).equals(
	                   MetricHelpers.getQuarterAsString(item.Date__c))) {

		            if(item.M_E_Metric__r.Automated__c == 'True') {
                        //automated indicator
		                if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Sum' || 
		                        item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Count') {

		                    chdActual += item.Numerator__c != null ? item.Numerator__c + ',' : '0,';
		                }
		                else if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Percentage'){
		                    chdActual += (item.Numerator__c != null && item.Denumerator__c != null && item.Denumerator__c != 0) ?
                                    ((item.Numerator__c / item.Denumerator__c) * 100).setScale(1) + ',' : '0,';
		                }
		            }
		            else {
                        // manual indicator
                        chdActual += item.Numerator__c != null ? item.Numerator__c + ',' : '0,';
		            }
	                xActual += (xCount * 100 / Math.max(1,total - 1)) + ',';
	            }
	            xCount++;
	        }
	
	        // Remove the last comma or pipe
	        if(chdActual.length() > 1) {
	            chdActual = chdActual.substring(0, chdActual.length() -1);
	            xActual = xActual.substring(0, xActual.length() - 1);
	        }
	
	        if(chdProjected.length() > 1) {
	            chdProjected = chdProjected.substring(0, chdProjected.length() -1);
	            xProjected = xProjected.substring(0, xProjected.length() -1 );
	        }
	 
	        spark_url += '&chd=t:' + xProjected + '|' + chdProjected + '|' + xActual + '|' + chdActual;
	        System.debug(spark_url);
	    }
    }
    
    /**
    * a wrapper class to hold wrappers i.e order wrapper and data wrapper
    */
    public class Wrapper {

        public Wrapper(Map<String, Map<String, BuccodecHelpers.DataWrapper>> dataWrapper, Map<String, 
            List<String>> orderWrapper) {
            
            this.dataWrapper = dataWrapper;
            this.dataWrapperOrder = orderWrapper;
        }

        public Map<String, Map<String, BuccodecHelpers.DataWrapper>> dataWrapper { get; set; }
        public Map<String, List<String>> dataWrapperOrder { get; set; }
    }
    
    public class BuccodegException extends Exception {
    }
    
    /**
    * Each BUCCODEG survey is of a particular submission type
    */
    public enum SubmissionType { FARMER_REGISTRATION, CKW_MONITORING, NONE }
}