/*
* Test class - GumutindoDashboardTests
*/
public class GumutindoHelpers {
	public GumutindoHelpers() {
		
	}
  
    public static final String ORG_NAME = 'Gumutindo Project';
    public static final String FARMERS_REGISTERED = 'GUMUTINDO_farmers_registered';
    public static final String FARMERS_USING_ATLEAST_3_AGROC_PRACTICES = 'GUMUTINDO_target_farmers_using_at_least_three_of_recommended_agroc_practices';
    public static final String FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK = 'GUMUTINDO_farmers_who_receive_advisory_services_from_ckw_network';
   
    public static final String FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_quality_of_extension_support';
    public static final String FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE = 'GUMUTINDO_farmers_who_purchase_organic_fertilizer_through_gcce';
    public static final String FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE = 'GUMUTINDO_farmers_who_purchase_organic_seedlings_through_gcce';

    public static final String FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE = 'GUMUTINDO_farmers_who_deliver_50_percent_of_hi_qual_coffee';
    public static final String FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS = 'GUMUTINDO_FARMERS_Who_access_agro_input_loans_through_ps';
    public static final String FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES = 'GUMUTINDO_farmers_who_use_atleast_one_kind_of_financial_services';

    public static final String FARMERS_WHO_ACCESS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_AVAILABLE_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_available_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_PS = 'GUMUTINDO_farmers_who_access_loaning_financial_services_through_PS';
    public static final String FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_with_gcce_services';
    public static final String FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_with_ps_services';

    public static final String ADHERENCE_TO_GCCE_POLICIES = 'GUMUTINDO_adherence_to_gcce_policies';
    public static final String PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES = 'GUMUTINDO_percentage_of_ps_with_established_policied_and_procedures';
    public static final String PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES = 'GUMUTINDO_percentage_of_ps_compliant_to_established_policied_and_procedures';

    public static final String PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS = 'GUMUTINDO_percentage_of_ps_who_collectively_procure_inputs';
    public static final String PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS = 'GUMUTINDO_percentage_of_ps_who_collectively_pay_for_inputs';
    
    public static final String FARMERS_USING_ATLEAST_3_CLIMATE_SMART_AGRIC_PRACTICES = 'Gumutindo_target_farmers_using_atleast_3_recommended_climate_smart_agric_practices';
    public static final String PS_ARE_FAIR_TRADE_AND_ORGANIC_CERTIFIED = 'Gumutindo_ps_are_fair_trade_and_organic_certified';
    public static final String FARMERS_PURCHACE_INPUTS_THROUGH_ELECTRONIC_TRANSACTIONS = 'Gumutindo_farmers_who_purchase_inputs_through_electronic_transactions';
    
    public static final String FARMERS_RECEIVE_PAYMENT_THROUGH_ELECTRONIC_TRANSACTIONS = 'Gumutindo_farmers_who_receive_payment_through_electronic_transactions';
    public static final String FARMERS_PREPARED_TO_MANAGE_EFFECTS_OF_WEATHER_RELATED_SHOCKS = 'Gumutindo_farmers_prepared_to_manage_effects_of_weather_related_schocks';
    public static final String FARMERS_WHO_CAN_CITE_ONE_CAUSE_OF_CLIMATE_CHANGE = 'Gumutindo_farmers_who_can_cite_one_cause_of_climate_change';
    
    public static final String FARMERS_WHO_USE_ATLEAST_2_OF_RECOMMENDED_WATER_CONSERVATION_MEASURES = 'Gumutindo_farmers_who_use_atleast_2_of_recommended_soil_and_water_conservation_measures';
    public static final String FARMERS_USING_ATLEAST_1_RECOMMEDED_AGROFORESTRY_PRACTICE = 'Gumutindo_farmers_using_atleast_1_recommended_agroforestry_practice_in_their_plantation';
    public static final String FARMERS_GROW_ATLEAST_1_OF_THE_ADAPTED_AND_IMPROVED_CROP_VARIATIES = 'Gumutindo_farmers_grow_atleast_1_of_the_adapted_and_improved_crop_variaties';
    
    public static final String FARMERS_WHO_USE_ENERGY_SAVING_COOKING_STOVES = 'Gumutindo_farmers_who_use_energy_saving_cooking_stoves';
   
    public static List<String> getDashboardSections(){
    	List<String> dashboardSections = new List<String>();
    	dashboardSections.add('Scale');
    	dashboardSections.add('Quality');
    	dashboardSections.add('Impact');
    	dashboardSections.add('Sustainability');
    	return dashboardSections;
    }
    
    /**
     *  Crops selection list
     *
     *  @param practiceIndex - a practice position
     *
     *  @return - List of Practices
     */
    public static String translatePractices(String practiceIndex) {

        String practices = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Planting trees within the homestead',
            '2' => 'Boundary planting/fence',
            '3' => 'Intercropping trees with crops',
            '4' => 'Mixed forests',
            '5' => 'Woodlots'
        };
        for(String index : practiceIndex.split(' ')) {
            practices += translationMap.get(index) + ';';
        }
        return practices;
    }
    
    public static String translateFinancialServices(String finacialIndex) {
    	String financialServices = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Bank',
            '2' => 'Mobile Money',
            '3' => 'SACCO',
            '4' => 'VSLA',
            '5' => 'Else where'
        };
        for(String index : finacialIndex.split(' ')) {
            financialServices += translationMap.get(index) + ';';
        }
        return financialServices;
    }
    
    public static String translateServicesReceived(String serviceIndex) {
    	String servicesReceived = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Extension services on coffee farming',
            '2' => 'Provision of market information',
            '3' => 'Provision of weather information',
            '4' => 'Payment for coffee',
            '5' => 'Provision of coffee seedlings',
            '6' => 'Access to credit facilities',
            '7' => 'Extension services on agroforestry',
            '8' => 'Provision of farm inputs',
            '9' => 'None'
        };
        for(String index : serviceIndex.split(' ')) {
            servicesReceived += translationMap.get(index) + ';';
        }
        return servicesReceived;
    }
    //Practices_that_Address_Climate_Change__c
    public static String translateChange(String changeIndex) {
    	String changes = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Mulching',
            '2' => 'Cover crops',
            '3' => 'Tied ridges',
            '4' => 'Tree planting',
            '5' => 'Other plant cover',
            '6' => 'Irrigate',
            '7' => 'Adapted/drought tolerant varieties',
            '8' => 'Diversity crops',
            '9' => 'Crop rotation',
            '10' => 'Terracing',
            '11' => 'Agro-forestry',
            '12' => 'Minimal tillage'
        };
        for(String index : changeIndex.split(' ')) {
            changes += translationMap.get(index) + ';';
        }
        return changes;
    }
    //Reasons_for_Climate_Change__c
    public static String translateReasons(String reasonIndex) {
    	String reasons = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Cutting down of trees',
            '2' => 'Excessive use of fertilizer',
            '3' => 'Burning of trees, fuel, etc',
            '4' => 'Don’t Know'
        };
        for(String index : reasonIndex.split(' ')) {
            reasons += translationMap.get(index) + ';';
        }
        return reasons;
    }
    //Methods_of_Soil_and_Water_Conservation_U__c
    public static String translateMethods(String methodIndex) {
    	String methods = '';
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Strip cropping',
            '2' => 'Mulching',
            '3' => 'Crop rotation',
            '4' => 'Contour cultivation',
            '5' => 'Planting of grasses for stability',
            '6' => 'Planting of trees and a forestation',
            '7' => 'Terracing',
            '8' => 'Control of stream and river banks'
        };
        for(String index : methodIndex.split(' ')) {
            methods += translationMap.get(index) + ';';
        }
        return methods;
    }
                
	/*
	* Populates Wrapper with data, categorizes metric names into the various metric sections
	*  @param quarter - The quarter for which data is collected 
	*/
	public static GumutindoHelpers.Wrapper getData(String quarter) {
		Map<String, Double> actualMap = getDataInQuarter(quarter);
        Map<String, Map<String, GumutindoHelpers.DataWrapper>> metricWrappers = new Map<String, Map<String, 
            GumutindoHelpers.DataWrapper>>();
        Map<String, List<String>> metricWrapperOrder = new Map<String, List<String>>();
        String query = 'SELECT ' +
        'Id,' +
        'Metric_Name__c, ' +
        'Section__c, ' +
        'Label__c, ' +
        'Target__c ' +
        'FROM '  +
        'Gumutindo_Targets__c ';
        
        //ID batchInstanceId = Database.executeBatch(new GumutindoRecords());
        
        Map<String, GumutindoHelpers.DataWrapper> areaMap = null;// = new Map<String, GumutindoHelpers.DataWrapper>();
        GumutindoHelpers.DataWrapper metricDataWrapper = null;// = new GumutindoHelpers.DataWrapper();
        List<String> metricOrder = null;//new List<String>();
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(quarter);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
        String metricName = '';
        String metricKey = '';
        String areaName = '';
        
        //Initialize a map of metric names 
        
        Map<String, Double> cummulativeMap = getPreviousDataSum(quarterLastDay);
        Map<String, Double> quarterlyMap = quarterTargets(quarter);
     
        System.debug(LoggingLevel.INFO, query);
        List<Gumutindo_Targets__c> targets = database.query(query);
        for (Gumutindo_Targets__c metric : targets) {
            // See if we have a valid metric name and that it is not the same as the next metric in the list.
            // If it isn't then we need to save the metric from the last loop and move on to a new metric
            if (!metricName.equals(metric.Metric_Name__c)) {
                // Save the previous object to the list
                if (metricDataWrapper != null) {
                    areaMap = metricWrappers.get(areaName);
                    if (areaMap == null) {
                        areaMap = new Map<String, GumutindoHelpers.DataWrapper>();
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
                metricDataWrapper = new GumutindoHelpers.DataWrapper();
                metricName = metric.Metric_Name__c;
            }

            // See if we have moved on to a new area and that the area exists
            areaName = metric.Section__c;
            if (areaName == null || areaName.equals('')) {
                metricDataWrapper = null;
                continue;
            }
            metricDataWrapper.name = metricName;
            metricDataWrapper.label = metric.Label__c;
            //metricDataWrapper.order = metric.M_E_Metric__r.Order__c;
            metricDataWrapper.metric_id = metric.Id;
            metricDataWrapper.metric_data_id = metric.Id;
            //Formular field. It displays Manual_Value__c
            metricDataWrapper.project_target = metric.Target__c == null ? 0 : (Integer)metric.Target__c;
            // calculating cummulative value. For manual indicators just display value
            //Decimal cummulativeResult = cummulativeMap.get(metricName);
            
            metricDataWrapper.cummulative_actual_reached = cummulativeMap.get(metricName) == null ? 0.0 : (Decimal)cummulativeMap.get(metricName);
            
            metricDataWrapper.percent_cummulative_actual_reached = metricDataWrapper.project_target != 0 ?
                        (metricDataWrapper.cummulative_actual_reached / metricDataWrapper.project_target) * 100 : 0.0;
            
            //metricDataWrapper.cummulative_actual_reached = getPreviousDataSum(quarterLastDay, metricName)[0];
  
            metricDataWrapper.quarter_actual_reached = actualMap.get(metricName) == null ? 0.0 : actualMap.get(metricName);
            //metricDataWrapper.quarter_target = getQuarterlyTargets(metricName) == null ? 0 : (Integer)getQuarterlyTargets(metricName).Target__c;//to be shifted
            metricDataWrapper.quarter_target = (Integer)quarterlyMap.get(metricName) == null ? 0 : (Integer)quarterlyMap.get(metricName);

            // calculate the % actual for this quarter: skip if quarter projected value is not provided
            //Decimal percentQuarter = (metricDataWrapper.percent_quarter_actual_reached != 0.0 &&
            Decimal percentQuarter = (metricDataWrapper.quarter_actual_reached  != null && metricDataWrapper.quarter_target != 0.0) ?
                    (metricDataWrapper.quarter_actual_reached /  metricDataWrapper.quarter_target) * 100 : 0.0;
                    
            metricDataWrapper.percent_quarter_actual_reached = percentQuarter;
            metricDataWrapper.setSparkUrl(String.valueOf(metric.Id));
        }

        // Add the last object
        metricKey = metricName;
        /*if (districtName != null) {
            metricKey = MetricHelpers.createMetricLabelString(metricName, districtName);
        }*/
        areaMap = metricWrappers.get(areaName);
        if (areaMap == null) {
            areaMap = new Map<String, GumutindoHelpers.DataWrapper>();
        }

        metricOrder = metricWrapperOrder.get(areaName);
        if (metricOrder == null) {
            metricOrder = new List<String>();
        }
        areaMap.put(metricKey, metricDataWrapper);
        metricWrappers.put(areaName, areaMap);
        metricOrder.add(metricKey);
        metricWrapperOrder.put(areaName, metricOrder);      
        
        return new GumutindoHelpers.Wrapper(metricWrappers, metricWrapperOrder);
    }
	

    /**
     *  Processes the Gumutindo GCCE Internal Inspection survey submission
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processGCCEInternalInspectionSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('GCCE Internal inspection')) {
            type = SubmissionType.FARMER_REGISTRATION;
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'Gumutindo post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, Gumutindo_Farmer__c> dataMap = new Map<String, Gumutindo_Farmer__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
            if(type == SubmissionType.FARMER_REGISTRATION){
	                        
	            String farmerName = answers.get('q2_0').Answer__c;
	            String village = answers.get('q3_0').Answer__c;
	            Integer numberOftrees = answers.get('q5_0').Answer__c !=null ? Integer.valueOf(answers.get('q5_0').Answer__c) : 0;
	            Integer yieldEstimate = answers.get('q6_0').Answer__c !=null ? Integer.valueOf(answers.get('q6_0').Answer__c) : 0;
                Integer numberOfCoffeePlots = answers.get('q7_0').Answer__c !=null ? Integer.valueOf(answers.get('q7_0').Answer__c) : 0;
                String contract = answers.get('q8_0').Answer__c == '1' ? 'Yes' : 'No';
                String weeding, pruning, shadeTrees, erosionControl, coverCrops;
                if(answers.get('q22_0').Answer__c == '1'){
                	weeding = 'Good';
                }
                else if (answers.get('q22_0').Answer__c == '2'){
                	weeding = 'Fair';
                }
                else {
                	weeding = 'Poor';
                }                
                if(answers.get('q24_0').Answer__c == '1') {
                	pruning = 'Good';
                }
                else if(answers.get('q24_0').Answer__c == '2') {
                	pruning = 'Fair';
                }
                else {
                	pruning = 'Poor';
                }                
                if(answers.get('q25_0').Answer__c == '1'){
                	shadeTrees = 'Good';
                }
                else if(answers.get('q25_0').Answer__c == '2') {
                	shadeTrees = 'Fair';
                }
                else {
                	shadeTrees = 'Poor';
                }
                if(answers.get('q26_0').Answer__c == '1') {
                	erosionControl = 'Good';
                }
                else if(answers.get('q26_0').Answer__c == '2'){
                	erosionControl = 'Fair';
                }
                else {
                	erosionControl = 'Poor';
                }
                if(answers.get('q27_0').Answer__c == '1') {
                	coverCrops = 'Good';
                }
                else if(answers.get('q27_0').Answer__c == '2') {
                	coverCrops = 'Fair';
                }
                else {
                	coverCrops = 'Poor';
                }
                String manureApplied = answers.get('q23_0').Answer__c == '1' ? 'Yes' : 'No';
                String comment = answers.get('q9_0').Answer__c == '1' ? 'Under conversion' : 'Certified fair trade organic';
                String advice = answers.get('q44_0').Answer__c;
                
                Gumutindo_Farmer__c gFarmer = new Gumutindo_Farmer__c();
                gFarmer.Name_of_Respondent__c = farmerName;
                gFarmer.Village__c = village;
                gFarmer.Number_of_Trees__c = numberOftrees;
                gFarmer.Yield_Estimates__c = yieldEstimate;
                gFarmer.Number_of_Coffee_Plots__c = numberOfCoffeePlots;
                gFarmer.Have_Contract_with_Gumutindo__c = contract;
                gFarmer.Weeding__c = weeding;
                gFarmer.Manure_Applied__c = manureApplied;
                gFarmer.Pruning__c = pruning;
                gFarmer.Shade_Trees__c = shadeTrees;
                gFarmer.Erosion_Control__c = erosionControl;
                gFarmer.Cover_crops__c = coverCrops;
                gFarmer.Comment_on_contract__c = comment;
                gFarmer.New_advice_given__c = advice;
                gFarmer.Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
   
                insert gFarmer;
                
	        }
	    List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	    for(Database.upsertResult result : uResults) {
            system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	    }
	        	
        }
        catch(Exception ex) {
            return new String[]{ '0', 'Gumutindo submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }

        return new String[] { '1', 'GCCE Internal inspection Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    /**
     *  Processes the Gumutindo Impacts 2015 survey submission
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processImpacts2015Survey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('Impacts 2015')) {
            type = SubmissionType.CKW_MONITORING;
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'Gumutindo post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, Gumutindo_Impacts__c> dataMap = new Map<String, Gumutindo_Impacts__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
	        if(type == SubmissionType.CKW_MONITORING){
	        	
	        	String psName;
                if(answers.get('q3_0').Answer__c == '1') {
	                psName = 'Buginyanya';
	            }
	            else if(answers.get('q3_0').Answer__c == '2') {
	                psName = 'Kikuyu';
	            }
	            else if(answers.get('q3_0').Answer__c == '3') {
	                psName = 'Bunabudde';
	            }
	            else if(answers.get('q3_0').Answer__c == '4') {
	                psName = 'Nasufwa';
	            }
	            else if(answers.get('q3_0').Answer__c == '5') {
	                psName = 'Masira';
	            }
	            else if(answers.get('q3_0').Answer__c == '6') {
	                psName = 'Demukata';
	            }
	            else if(answers.get('q3_0').Answer__c == '7') {
	                psName = 'Busamaga';
	            }
	            else if(answers.get('q3_0').Answer__c == '8') {
	                psName = 'Nagudi Bwira';
	            }
	            else if(answers.get('q3_0').Answer__c == '9') {
	                psName = 'Lwambogo';
	            }
	            else if(answers.get('q3_0').Answer__c == '10') {
	                psName = 'Konokoyi';
	            }
	            else if(answers.get('q3_0').Answer__c == '11') {
	                psName = 'Bumayoga';
	            }
	            else if(answers.get('q3_0').Answer__c == '12') {
	                psName = 'Buweswa';
	            }
	            else if(answers.get('q3_0').Answer__c == '13') {
	                psName = 'Bumatanda';
	            }
	            else if(answers.get('q3_0').Answer__c == '14') {
	                psName = 'Sipi';
	            }
	            else if(answers.get('q3_0').Answer__c == '15') {
	                psName = 'Bukalasi';
	            }
	            else if(answers.get('q3_0').Answer__c == '16') {
	                psName = 'Buteteya';
	            }
	            else if(answers.get('q3_0').Answer__c == '17') {
	                psName = 'Buwambigwa';
	            }
	            else psName = '';
	            	            
	            String purchaseThruGcce = answers.get('q28_0').Answer__c == '1' ? 'Yes' : 'No';
	            String purchaseSeedlings = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
	            String hiQuality = answers.get('q12_0').Answer__c == '1' ? 'Yes' : 'No';
                String loanThruPs = answers.get('q26_0').Answer__c == '1' ? 'Yes' : 'No';
                String financialService = answers.get('q30_0').Answer__c;                
                String satisfaction = answers.get('q8_0').Answer__c;                
                String electronicTransaction = answers.get('q16_0').Answer__c == '1' ? 'Yes' : 'No';                
                String electronicPayment = answers.get('q15_0').Answer__c == '1' ? 'Yes' : 'No';                
                String manageWhether = answers.get('q22_0').Answer__c;
                String citeCause = answers.get('q21_0').Answer__c;
                String soilConservation = answers.get('q23_0').Answer__c;
                String agroPractice = answers.get('q24_0').Answer__c;
                String adaptedVariety = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
                String energySaving = answers.get('q25_0').Answer__c == '1' ? 'Yes' : 'No';
                String farmInputs = answers.get('q16_0').Answer__c == '1' ? 'Yes' : 'No';
                String organicSeedlings = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
                
                Integer marks;
                if(answers.get('q9_0').Answer__c == '1'){
                	marks = 1;
                }
                else if(answers.get('q9_0').Answer__c == '2'){
                	marks = 2;
                }
                else if(answers.get('q9_0').Answer__c == '3'){
                	marks = 3;
                }
                else if(answers.get('q9_0').Answer__c == '4'){
                	marks = 4;
                }
                else if(answers.get('q9_0').Answer__c == '5'){
                	marks = 5;
                }
                
                List<Gumutindo_Primary_Society__c> primarySocieties = [
	               SELECT
	                   Id
	               FROM 
	                   Gumutindo_Primary_Society__c
	               WHERE
	                   Name = :psName  
	            ];
	            if(primarySocieties.size() > 0){
                    Gumutindo_Impacts__c gImpact = new Gumutindo_Impacts__c();
                    gImpact.Gumutindo_Primary_Society__c = primarySocieties[0].Id;
                    gImpact.Purchased_Organic_fertilizer_through_GCC__c = purchaseThruGcce;
                    gImpact.Ever_purchased_organic_seedlings_at_PS__c = purchaseSeedlings;
                    gImpact.Sold_all_your_coffee_to_the_PS__c = hiQuality;
                    gImpact.Ever_acquired_an_Agro_input_loan_through__c = loanThruPs;
                
                    gImpact.Ps_Mark__c = marks;
                    gImpact.Any_Farm_inputs_from_the_PS__c = farmInputs;
                    gImpact.Received_Organic_Seedlings_at_PS__c = organicSeedlings;
                
                    gImpact.Financial_service_for_the_business__c = translateFinancialServices(financialService);
                    gImpact.Services_received_from_PS__c = translateServicesReceived(satisfaction);
                    gImpact.Practices_that_Address_Climate_Change__c = translateChange(manageWhether);
                    gImpact.Reasons_for_Climate_Change__c = translateReasons(citeCause);
                    gImpact.Methods_of_Soil_and_Water_Conservation_U__c = translateMethods(soilConservation);
                    gImpact.Agro_forestry_Practices_Used__c = translatePractices(agroPractice);
                                
                    gImpact.Purchase_Inputs_thru_Elec_Transactions__c = electronicTransaction;
                    gImpact.Sold_all_your_coffee_to_the_PS__c = electronicPayment;
                    gImpact.Ever_purchased_organic_seedlings_at_PS__c = adaptedVariety;
                    gImpact.Using_Energy_Saving_Cooking_Stove__c = energySaving;
                    gImpact.Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
   
                    insert gImpact;
	            }
                
	        }
	        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	        for(Database.upsertResult result : uResults) {
                system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	        }
	        	
        }
        catch(Exception ex) {
            return new String[]{ '0', 'Gumutindo submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }

        return new String[] { '1', 'GCCE Internal inspection Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    /**
     *  Processes the Gumutindo Activity survey submission
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processActivitySurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('Activity Survey')) {
            type = SubmissionType.VSLA_REGISTRATION;
            
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'Gumutindo post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, Gumutindo_Vsla__c> dataMap = new Map<String, Gumutindo_Vsla__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
	        if(type == SubmissionType.VSLA_REGISTRATION){
	            	            
	            Integer total = answers.get('q13_0').Answer__c !=null ? Integer.valueOf(answers.get('q13_0').Answer__c) : 0;
                
                Gumutindo_Vsla__c gVlsa = new Gumutindo_Vsla__c();
                gVlsa.Total_Number_of_VSLA_Members__c = total;
                gVlsa.Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
   
                insert gVlsa;
                
	        }
	    List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	    for(Database.upsertResult result : uResults) {
            system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	    }
	        	
        }
        catch(Exception ex) {
            return new String[]{ '0', 'Gumutindo submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }

        return new String[] { '1', 'Activity Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    /**
     *  Processes the Gumutindo Society GPS survey submission
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processSocietyGPSSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        /*List<String> returnValues = new List<String>();
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('Society GPS')) {
            type = SubmissionType.PS_REGISTRATION;
            
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'Gumutindo post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, Gumutindo_Primary_Society__c> dataMap = new Map<String, Gumutindo_Primary_Society__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
	        if(type == SubmissionType.PS_REGISTRATION){
	            	            
	            Integer total = answers.get('q13_0').Answer__c !=null ? Integer.valueOf(answers.get('q13_0').Answer__c) : 0;
                
                Gumutindo_Primary_Society__c gSociety = new Gumutindo_Primary_Society__c();
                gSociety.Total_Number_of_VSLA_Members__c = total;
                gSociety.Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
   
                insert gSociety;
                
	        }
	    List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	    for(Database.upsertResult result : uResults) {
            system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	    }
	        	
        }
        catch(Exception ex) {
            return new String[]{ '0', 'Gumutindo submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }*/

        return new String[] { '1', 'Activity Survey processed IMEI: SUPRESSMSG' };
    }

    /**
     *  Processes the Gumutindo GCCE PS survey submission
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
   
    public static List<String> processGCCEPSSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        SubmissionType type;
        String failures = '';
        if(survey.Survey_Name__c.containsIgnoreCase('GCCE PS')) {
            type = SubmissionType.GCCE_REGISTRATION;
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'Gumutindo post-processing irrelevant for submission from IMEI: ' 
                + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }
        
        try {
	        // use handset submissin time
	        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
	        handsetSubmitTime = handsetSubmitTime == null ? DateTime.now() : handsetSubmitTime;
	        
	        Map<String, Gumutindo_Primary_Society__c> dataMap = new Map<String, Gumutindo_Primary_Society__c>();
	        Date currentDate = MetricHelpers.getQuarterFirstDay(handsetSubmitTime.date());
	        List<String> metricNames = null;
	        
	        // get information from farmer registration
	        if(type == SubmissionType.GCCE_REGISTRATION){
	            	            
	           String psName;
	           if(answers.get('q1_0').Answer__c == '1') {
	               psName = 'Buginyanya';
	           }
	           else if(answers.get('q1_0').Answer__c == '2') {
	               psName = 'Kikuyu';
	           }
	           else if(answers.get('q1_0').Answer__c == '3') {
	               psName = 'Bunabudde';
	           }
	           else if(answers.get('q1_0').Answer__c == '4') {
	               psName = 'Nasufwa';
	           }
	           else if(answers.get('q1_0').Answer__c == '5') {
	               psName = 'Masira';
	           }
	           else if(answers.get('q1_0').Answer__c == '6') {
	               psName = 'Demukata';
	           }
	           else if(answers.get('q1_0').Answer__c == '7') {
	               psName = 'Busamaga';
	           }
	           else if(answers.get('q1_0').Answer__c == '8') {
	               psName = 'Nagudi Bwira';
	           }
	           else if(answers.get('q1_0').Answer__c == '9') {
	               psName = 'Lwambogo';
	           }
	           else if(answers.get('q1_0').Answer__c == '10') {
	               psName = 'Konokoyi';
	           }
	           else if(answers.get('q1_0').Answer__c == '11') {
	               psName = 'Bumayoga';
	           }
	           else if(answers.get('q1_0').Answer__c == '12') {
	               psName = 'Buweswa';
	           }
	           else if(answers.get('q1_0').Answer__c == '13') {
	               psName = 'Bumatanda';
	           }
	           else if(answers.get('q1_0').Answer__c == '14') {
	               psName = 'Sipi';
	           }
	           else if(answers.get('q1_0').Answer__c == '15') {
	               psName = 'Bukalasi';
	           }
	           else if(answers.get('q1_0').Answer__c == '16') {
	               psName = 'Buteteya';
	           }
	           else if(answers.get('q1_0').Answer__c == '17') {
	               psName = 'Buwambigwa';
	           } 
	           
	           List<Gumutindo_Primary_Society__c> subcounty = [
	               SELECT
	                   Subcounty__r.Id
	               FROM 
	                   Gumutindo_Primary_Society__c
	               WHERE
	                   Name = :psName  
	            ];
	            
	            String establishedPolicy = answers.get('q3_0').Answer__c == '1' ? 'Yes' : 'No';
	            String procureInputs = answers.get('q4_0').Answer__c == '1' ? 'Yes' : 'No';
	            String payForInputs = answers.get('q5_0').Answer__c == '1' ? 'Yes' : 'No';
                
                Gumutindo_Primary_Society__c gPrimarySocieity = new Gumutindo_Primary_Society__c();
                gPrimarySocieity.Adhere_to_Established_Policies__c = establishedPolicy;
                gPrimarySocieity.Farmers_Procure_Farm_Inputs_Collectively__c = procureInputs;
                gPrimarySocieity.Pay_for_Inputs_Upon_Delivery__c = payForInputs;
                gPrimarySocieity.Subcounty__c = subcounty[0].Subcounty__r.Id;
                gPrimarySocieity.Date__c = submission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
                List<Gumutindo_Primary_Society__c> Ids = [SELECT Id FROM Gumutindo_Primary_Society__c WHERE Name = :psName LIMIT 1];
                if(Ids.size() > 0) {
                    gPrimarySocieity.Id = Ids[0].Id;
                    update gPrimarySocieity;
                }
                else {   
                    insert gPrimarySocieity;
                }
                
	        }
	    List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
	    for(Database.upsertResult result : uResults) {
            system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
	    }
	        	
        }
        catch(Exception ex) {
            return new String[]{ '0', 'Gumutindo submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }

        return new String[] { '1', 'GCCE PS Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    
    public static Map<String, Double> getDataInQuarter(String quarter){
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(quarter);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
        Map<String, Double> quarterData = new Map<String, Double>();
        //FARMERS_REGISTERED
    	    Decimal farmersReached = [
    	        SELECT 
    	            COUNT()
    	        FROM 
    	            Gumutindo_Farmer__c
    	        WHERE
                    Date__c >=:quarterFirstDay    
                AND
                    Date__c <=:quarterLastDay 
    	];
    	quarterData.put(FARMERS_REGISTERED, (Double)farmersReached);
    	
        //FARMERS_USING_ATLEAST_3_AGROC_PRACTICES || FARMERS_USING_ATLEAST_3_CLIMATE_SMART_AGRIC_PRACTICES
    	Decimal recommendedPractices = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Farmer__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
               Recommended_Practices__c = 'true' 
    	];
    	quarterData.put(FARMERS_USING_ATLEAST_3_AGROC_PRACTICES, (Double)recommendedPractices);
    	quarterData.put(FARMERS_USING_ATLEAST_3_CLIMATE_SMART_AGRIC_PRACTICES, (Double)recommendedPractices);
    	    
    	//PS_ARE_FAIR_TRADE_AND_ORGANIC_CERTIFIED
    	Decimal contractComment = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Farmer__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
               Comment_on_contract__c = 'Certified fair trade organic' 
    	];
    	quarterData.put(PS_ARE_FAIR_TRADE_AND_ORGANIC_CERTIFIED, (Double)contractComment);
    	
    	//FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK
    	Decimal adviceGiven = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Farmer__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                New_advice_given__c != null 
    	];
    	quarterData.put(FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK, (Double)adviceGiven);
    	    
    	//FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES || FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE
    	Decimal organicFertilizer = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Purchased_Organic_fertilizer_through_GCC__c = 'Yes' 
    	];
    	quarterData.put(FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES, (Double)organicFertilizer);
    	quarterData.put(FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE, (Double)organicFertilizer);
    	    
    	//FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE
    	Decimal purchasedSeedlings = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes' 
        ];
    	quarterData.put(FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE, (Double)purchasedSeedlings);
    	
    	//FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE
    	Decimal hiQuality = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Sold_all_your_coffee_to_the_PS__c = 'Yes' 
    	];
    	quarterData.put(FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE, (Double)hiQuality);
    	    
    	//FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS
    	Decimal accessLoans = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Ever_acquired_an_Agro_input_loan_through__c = 'Yes' 
        ];
    	quarterData.put(FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS, (Double)accessLoans);
    	    
    	//FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES
    	Decimal financialServices = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                (Financial_service_for_the_business__c = 'Bank' 
            OR 
                Financial_service_for_the_business__c = 'Mobile Money') 
    	];
    	quarterData.put(FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES, (Double)financialServices);
    	
    	//FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES
    	Decimal satisfactionWithServices = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Services_received_from_PS__c != 'None'
    	];
    	quarterData.put(FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES, (Double)satisfactionWithServices);
    	    
    	//FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES
    	Decimal psMark = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Ps_Mark__c > 3
    	];
    	quarterData.put(FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES, (Double)psMark);
    	   
    	//FARMERS_PURCHACE_INPUTS_THROUGH_ELECTRONIC_TRANSACTIONS
    	Decimal purchasedInputs = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Purchase_Inputs_thru_Elec_Transactions__c = 'Yes'
    	];
    	quarterData.put(FARMERS_PURCHACE_INPUTS_THROUGH_ELECTRONIC_TRANSACTIONS, (Double)purchasedInputs);
    	   
    	//FARMERS_RECEIVE_PAYMENT_THROUGH_ELECTRONIC_TRANSACTIONS
    	Decimal electronicPayment = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Total_Number_of_Coffee_Trees_on_Farm__c != null
    	];
    	quarterData.put(FARMERS_RECEIVE_PAYMENT_THROUGH_ELECTRONIC_TRANSACTIONS, (Double)electronicPayment);
    	   
    	//FARMERS_PREPARED_TO_MANAGE_EFFECTS_OF_WEATHER_RELATED_SHOCKS
    	Decimal famersPrepaed = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Practices_that_Address_Climate_Change__c != null
    	];
    	quarterData.put(FARMERS_PREPARED_TO_MANAGE_EFFECTS_OF_WEATHER_RELATED_SHOCKS, (Double)famersPrepaed);

    	//FARMERS_WHO_CAN_CITE_ONE_CAUSE_OF_CLIMATE_CHANGE
    	Decimal citeCause = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Reasons_for_Climate_Change__c != 'Don’t Know'
    	];
    	quarterData.put(FARMERS_WHO_CAN_CITE_ONE_CAUSE_OF_CLIMATE_CHANGE, (Double)citeCause);
    	    
    	//FARMERS_WHO_USE_ATLEAST_2_OF_RECOMMENDED_WATER_CONSERVATION_MEASURES
    	Decimal recommendedWater = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                At_least_2_water_conservation_measures__c = 'true'
    	];
    	quarterData.put(FARMERS_WHO_USE_ATLEAST_2_OF_RECOMMENDED_WATER_CONSERVATION_MEASURES, (Double)recommendedWater);

    	//FARMERS_USING_ATLEAST_1_RECOMMEDED_AGROFORESTRY_PRACTICE
    	Decimal agroforestryPractices = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Agro_forestry_Practices_Used__c != null
    	];
    	quarterData.put(FARMERS_USING_ATLEAST_1_RECOMMEDED_AGROFORESTRY_PRACTICE, (Double)agroforestryPractices);
    	
    	//FARMERS_GROW_ATLEAST_1_OF_THE_ADAPTED_AND_IMPROVED_CROP_VARIATIES
    	Decimal purchasedSeedlingsFromPs = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes'
    	];
    	quarterData.put(FARMERS_GROW_ATLEAST_1_OF_THE_ADAPTED_AND_IMPROVED_CROP_VARIATIES, (Double)purchasedSeedlingsFromPs);
    	
    	//FARMERS_WHO_USE_ENERGY_SAVING_COOKING_STOVES
    	Decimal cookingStoves = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Using_Energy_Saving_Cooking_Stove__c = 'Yes'
    	];
    	quarterData.put(FARMERS_WHO_USE_ENERGY_SAVING_COOKING_STOVES, (Double)cookingStoves);
    	    
    	//FARMERS_WHO_ACCESS_AVAILABLE_FINANCIAL_SERVICES_THROUGH_VSLAS
    	Decimal finacialServicesThruVsla = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Vsla__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Total_Number_of_VSLA_Members__c != null
    	];
    	quarterData.put(FARMERS_WHO_ACCESS_AVAILABLE_FINANCIAL_SERVICES_THROUGH_VSLAS, (Double)finacialServicesThruVsla);
    	    
    	//ADHERENCE_TO_GCCE_POLICIES || PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES ||PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES
    	Decimal establishedPolicies = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Primary_Society__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Adhere_to_Established_Policies__c = 'Yes'
    	];
    	quarterData.put(ADHERENCE_TO_GCCE_POLICIES, (Double)establishedPolicies);
    	quarterData.put(PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES, (Double)establishedPolicies);
    	quarterData.put(PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES, (Double)establishedPolicies);
    	
    	//PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS
    	Decimal procureInputs = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Primary_Society__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Farmers_Procure_Farm_Inputs_Collectively__c = 'Yes'
    	];
    	quarterData.put(PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS, (Double)procureInputs);
    	   
    	//PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS
    	Decimal payForInputs = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Primary_Society__c
    	    WHERE
                Date__c >=:quarterFirstDay    
            AND
                Date__c <=:quarterLastDay 
            AND 
                Pay_for_Inputs_Upon_Delivery__c = 'Yes'
    	];
    	quarterData.put(PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS, (Double)payForInputs);
    	   
    	return quarterData;
    }
    
    public static Map<String, Decimal> getPreviousDataSum(Date quarterLastDay) {
    	Map<String, Decimal> dataSum = new Map<String, Decimal>();
    	//FARMERS_REGISTERED
    	Decimal farmersReached =  [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Farmer__c 
            WHERE 
                Date__c <= :quarterLastDay ];  
        dataSum.put(FARMERS_REGISTERED, farmersReached);
    	
        //FARMERS_USING_ATLEAST_3_AGROC_PRACTICES) || FARMERS_USING_ATLEAST_3_CLIMATE_SMART_AGRIC_PRACTICES    
        Decimal recommendedPractices = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Farmer__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Recommended_Practices__c = 'true'
        ];
        dataSum.put(FARMERS_USING_ATLEAST_3_AGROC_PRACTICES, recommendedPractices);
        dataSum.put(FARMERS_USING_ATLEAST_3_AGROC_PRACTICES, recommendedPractices);
    	
        //PS_ARE_FAIR_TRADE_AND_ORGANIC_CERTIFIED
        Decimal contractComment = [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Farmer__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Comment_on_contract__c = 'Certified fair trade organic'
         ];
         dataSum.put(PS_ARE_FAIR_TRADE_AND_ORGANIC_CERTIFIED, contractComment);
          
        //FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK
        Decimal adviceGiven = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Farmer__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                New_advice_given__c != null
            ];
            dataSum.put(FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK, adviceGiven);
       
        //FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES || FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE
        Decimal farmersSatisfied = [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes'
           ];
           dataSum.put(FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES, farmersSatisfied);
           dataSum.put(FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE, farmersSatisfied);
       
        //FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE
        Decimal purchasedOrganicSeedlings = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes'
            ];
            dataSum.put(FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE, purchasedOrganicSeedlings);
       
        //FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE
        Decimal hiQuality = [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes'
            ];
            dataSum.put(FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE, hiQuality);
       
        //FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS
        Decimal accessLoans = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                (Financial_service_for_the_business__c = 'Bank' 
            OR 
                Financial_service_for_the_business__c = 'Mobile Money')
            ];
            dataSum.put(FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS, accessLoans);
               
        //FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES
    	Decimal oneKindFinancialServices = [
    	    SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c <=:quarterLastDay 
            AND 
               (Financial_service_for_the_business__c = 'Bank' 
            OR 
                Financial_service_for_the_business__c = 'Mobile Money') 
            ];
    	    dataSum.put(FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES, oneKindFinancialServices);
       
        //FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES
        Decimal satisfiedWithServices = [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Services_received_from_PS__c != 'None'
            ];
            dataSum.put(FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES, satisfiedWithServices);
       
        //FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES
        Decimal psMark = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Ps_Mark__c > 3
            ];
            dataSum.put(FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES, psMark);
       
        //FARMERS_PURCHACE_INPUTS_THROUGH_ELECTRONIC_TRANSACTIONS
        Decimal purchaseInputs = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Purchase_Inputs_thru_Elec_Transactions__c = 'Yes'
            ];
            dataSum.put(FARMERS_PURCHACE_INPUTS_THROUGH_ELECTRONIC_TRANSACTIONS, purchaseInputs);
              
        //FARMERS_RECEIVE_PAYMENT_THROUGH_ELECTRONIC_TRANSACTIONS
        Decimal electronicPayment = [
            SELECT 
    	        COUNT()
    	    FROM 
    	        Gumutindo_Impacts__c
    	    WHERE
                Date__c <=:quarterLastDay 
            AND 
                Total_Number_of_Coffee_Trees_on_Farm__c != null
    	];
    	dataSum.put(FARMERS_RECEIVE_PAYMENT_THROUGH_ELECTRONIC_TRANSACTIONS, electronicPayment);
       

        //FARMERS_PREPARED_TO_MANAGE_EFFECTS_OF_WEATHER_RELATED_SHOCKS
        Decimal farmersPrepared = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Practices_that_Address_Climate_Change__c != null
            ];
            dataSum.put(FARMERS_PREPARED_TO_MANAGE_EFFECTS_OF_WEATHER_RELATED_SHOCKS, farmersPrepared);
       
        //FARMERS_WHO_CAN_CITE_ONE_CAUSE_OF_CLIMATE_CHANGE
        Decimal citeCause = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Practices_that_Address_Climate_Change__c != 'Don’t Know'
            ];
            dataSum.put(FARMERS_WHO_CAN_CITE_ONE_CAUSE_OF_CLIMATE_CHANGE, citeCause);
       
        //FARMERS_WHO_USE_ATLEAST_2_OF_RECOMMENDED_WATER_CONSERVATION_MEASURES
        Decimal recommendedMeasures = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                At_least_2_water_conservation_measures__c = 'true'
            ];
            dataSum.put(FARMERS_WHO_USE_ATLEAST_2_OF_RECOMMENDED_WATER_CONSERVATION_MEASURES, recommendedMeasures);
       
        //FARMERS_USING_ATLEAST_1_RECOMMEDED_AGROFORESTRY_PRACTICE
        Decimal recommendedWaterConservMeasures = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Agro_forestry_Practices_Used__c != null
            ];
            dataSum.put(FARMERS_USING_ATLEAST_1_RECOMMEDED_AGROFORESTRY_PRACTICE, recommendedWaterConservMeasures);
        
        //FARMERS_GROW_ATLEAST_1_OF_THE_ADAPTED_AND_IMPROVED_CROP_VARIATIES
        Decimal purchasedSeedlings = [
            SELECT 
                COUNT() 
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Ever_purchased_organic_seedlings_at_PS__c = 'Yes'
            ];
            dataSum.put(FARMERS_GROW_ATLEAST_1_OF_THE_ADAPTED_AND_IMPROVED_CROP_VARIATIES, purchasedSeedlings);
        
        //FARMERS_WHO_USE_ENERGY_SAVING_COOKING_STOVES
        Decimal cookingStoves = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Impacts__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Using_Energy_Saving_Cooking_Stove__c = 'Yes'
            ];
            dataSum.put(FARMERS_WHO_USE_ENERGY_SAVING_COOKING_STOVES, cookingStoves);
       
        //FARMERS_WHO_ACCESS_AVAILABLE_FINANCIAL_SERVICES_THROUGH_VSLAS
        Decimal financialServices = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Vsla__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Total_Number_of_VSLA_Members__c != null
            ];
            dataSum.put(FARMERS_WHO_ACCESS_AVAILABLE_FINANCIAL_SERVICES_THROUGH_VSLAS, financialServices);
       
        //ADHERENCE_TO_GCCE_POLICIES || PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES || PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES
    	Decimal establishedPolicies = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Primary_Society__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Adhere_to_Established_Policies__c = 'Yes'
            ];
            dataSum.put(ADHERENCE_TO_GCCE_POLICIES, establishedPolicies);
            dataSum.put(PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES, establishedPolicies);
            dataSum.put(PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES, establishedPolicies);
       
        //PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS
    	Decimal procureInputs = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Primary_Society__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Farmers_Procure_Farm_Inputs_Collectively__c = 'Yes'
            ];
            dataSum.put(PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS, procureInputs);
              
        //PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS    
        Decimal payForInputs = [
            SELECT 
                COUNT()
            FROM 
                Gumutindo_Primary_Society__c 
            WHERE 
                Date__c <= :quarterLastDay
            AND
                Pay_for_Inputs_Upon_Delivery__c = 'Yes'
            ];
            dataSum.put(PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS, payForInputs);
       
        return dataSum;
    }

    /*public static CKW__c loadCkw(Person__c person) {
        CKW__c[] ckw = [
           SELECT
              Id,
              Name,
              Person__r.GPS_Location_E__c,
              Person__r.GPS_Location_N__c
           FROM
               CKW__c
           WHERE
               Person__c = :person.Id
           LIMIT 1 
        ];
        
        if (!ckw.isEmpty()) {
            return ckw[0];
        }      
        System.debug('Gumutindo CKW was not found in the database');

        return null; // CKW was not found
    }	*/
    
    public static Map<String, Double> quarterTargets(String quarter){
    	Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(quarter);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
        Map<String, Double> quarterMap = new Map<String, Double>();
        List<Gumutindo_Quarterly_Targets__c> results = [
    	    SELECT 
    	        Metric_Name__c, 
    	        Target__c 
    	    FROM 
    	        Gumutindo_Quarterly_Targets__c
    	    WHERE 
    	        Quarter_First_Date__c >= :quarterFirstDay 
    	    AND
    	        Quarter_First_Date__c <= :quarterLastDay];
    	        
        for (Gumutindo_Quarterly_Targets__c result : results) {
        	quarterMap.put(result.Metric_Name__c, result.Target__c);
        }
        return quarterMap;
    }
       
    public static Gumutindo_Targets__c getTargets(String metricName){
    	List<Gumutindo_Targets__c> targets = [
    	    SELECT 
    	        Target__c
    	    FROM 
    	        Gumutindo_Targets__c
    	    WHERE 
    	        Metric_Name__c  = : metricName
    	];
        if(targets.size() > 0) {
        	return targets[0];
        }
        else {
        	return null;
        }
    }
    
    /*public static Gumutindo_Quarterly_Targets__c getQuarterlyTargets(String metricName){
    	List<Gumutindo_Quarterly_Targets__c> targets = [
    	    SELECT 
    	        Target__c
    	    FROM 
    	        Gumutindo_Quarterly_Targets__c
    	    WHERE 
    	        Metric_Name__c  = : metricName
    	];
        if(targets.size() > 0) {
        	return targets[0];
        }
        else {
        	return null;
        }
    }*/

    //inner class to provide district map markers
    public static MetricMapWrapper[] getGumutindoPrimarySocietyMarkers() {
		
		Map < String, MetricMapWrapper > markers = new Map < String, MetricMapWrapper > ();
		Gumutindo_Primary_Society__c[] primarySocieties = [SELECT id, Name, Latitude__c, Longitude__c from Gumutindo_Primary_Society__c];
		for (Gumutindo_Primary_Society__c society: primarySocieties) {
			MetricMapWrapper marker = null;
			marker = new MetricMapWrapper('CKW', '0000FF', society.Id, false);
			marker.gpsLatitude = '' + society.Latitude__c;
			marker.gpsLongitude = '' + society.Longitude__c;
			
            String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Society Name: ' + society.Name + '<br/>';
            //profile += '<a href ="'+ ref.getUrl()+'" ></a><br />';
			//Show CKWs in this society
			Decimal totalFarmers = [SELECT COUNT() FROM Gumutindo_Impacts__c WHERE Gumutindo_Primary_Society__r.Id =:society.id];
		    profile += '<hr><b>Has ' + totalFarmers + ' farmers</b></hr><br/>';
		    
			Gumutindo_Field_Officer__c[] gumutindoFos = [
			    SELECT 
			        Id, Person__r.First_Name__c 
			    FROM 
			        Gumutindo_Field_Officer__c WHERE Id IN
			        (SELECT 
			            Gumutindo_Field_Officer__c 
			        FROM 
			            Gumutindo_CKW__c 
			        WHERE 
			            Gumutindo_Primary_Society__r.Id = :society.Id) ];
			//List<Id> ckws = new List<Id>();
			
			for(Gumutindo_Field_Officer__c fo : gumutindoFos) {
				//ckws.add(ckw.Gumutindo_Field_Officer__r.Id);
				PageReference ref = new PageReference('/'+fo.Id);
			    profile += '<div>';
                //profile += '<hr><b> ' + fo.Person__r.First_Name__c + ' </b></hr><a href ="'+ ref.getUrl()+'">person</a><br/>';
                profile += '<hr>Field Officer: <b><a href ="'+ ref.getUrl()+'"> ' + fo.Person__r.First_Name__c + ' </a></b></hr><br/>';
                profile += '</div>';
			    
                //marker.addName(profile);
			}
			//if (gumutindoCkws.size() == 0) {
				//profile += 'There are no CKWs in ' + society.Name;
			//} else {
				
				//profile += '<b>CKWs in ' + society.Name + ' (' + gumutindoCkws.size() + ')</b><br/>';
				/*for (Gumutindo_CKW__c gckw: gumutindoCkws) {
					profile += gckw.Person__r.First_Name__c + ' ' + gckw.Person__r.Last_Name__c + '<br/>';
				}*/
			//}
			profile += '</div>';
			marker.addName(profile);
			marker.markerTitle = society.Name;
			markers.put(society.Id, marker);
		}
		return markers.values();
	}

	public static MetricMapWrapper[] getCKWMapMarkers() {
		
		Map < String, MetricMapWrapper > markers = new Map < String, MetricMapWrapper > ();
		Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c,  Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'GCCE\' and Person__r.Type__c=\'CKW\'');
		List < String > personIds = new List < String > ();
		for (Person_Group_Association__c assoc: associations) {
			personIds.add(assoc.Person__r.Id);
		}

		CKW__c[] ckws = [SELECT id, Name, Person__r.First_Name__c, Person__r.Last_Name__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c from CKW__c where Person__r.Id in : personIds];
		/*for (CKW__c ckw: ckws) {
			MetricMapWrapper marker = null;
			marker = new MetricMapWrapper('CKW', '0000FF', ckw.Id, false);
			marker.gpsLatitude = ckw.Person__r.GPS_Location_N__c;
			marker.gpsLongitude = ckw.Person__r.GPS_Location_E__c;

			PageReference ref = new PageReference('/apex/CkwDetailMiniStarts?id=' + ckw.Id);
			String content = '<iframe src="' + ref.getUrl() + '" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';

			marker.addName(content);
			marker.markerTitle = ckw.Person__r.First_Name__c + ' ' + ckw.Person__r.Last_Name__c;
			markers.put(ckw.Id, marker);
		}*/

		//Field officers
		/*Gumutindo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_Field_Officer__c];
		for (Gumutindo_Field_Officer__c fo: fieldOfficers) {

			MetricMapWrapper marker = null;
			marker = new MetricMapWrapper('FO', '00FF88', fo.Person__r.Id, false);
			marker.gpsLatitude = fo.Person__r.GPS_Location_N__c;
			marker.gpsLongitude = fo.Person__r.GPS_Location_E__c;

			String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: ' + fo.Person__r.First_Name__c + ' ' + fo.Person__r.Last_Name__c + '<br/>';
			//Show CKWs under this field officer
			Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Field_Officer__r.Person__r.Id = : fo.Person__r.Id];
			if (gumutindoCkws.size() == 0) {
				profile += 'Field officer has no CKWs attached';
			} else {
				profile += '<hr><b>Ckws attached to FO</b><br/>';
				for (Gumutindo_CKW__c gckw: gumutindoCkws) {
					profile += gckw.Person__r.First_Name__c + ' ' + gckw.Person__r.Last_Name__c + '<br/>';
				}
			}
			profile += '</div>';
			marker.addName(profile);
			marker.markerTitle = fo.Person__r.First_Name__c + ' ' + fo.Person__r.Last_Name__c;
			markers.put(fo.Person__r.Id, marker);
		}*/
		System.debug(markers.size() + ' map markers found');
		return markers.values();
	}

	//inner class to provide district map markers
	/*public with sharing class GumutindoDistrictCoordinatesProvider implements MapComponentController.IMapMarkerSource {
		
		public List < MapMarkers > loadMapMarkers(Map < String, String > parameters) {
			List < MapMarkers > mapMarkers = new List < MapMarkers > ();

			//For Live, select from group
			Gumutindo_Primary_Society__c[] associations = Database.query('select Id, Name, Subcounty__r.District__r.ID, Subcounty__r.District__r.Name, Subcounty__r.District__r.Longitude__C, Subcounty__r.District__r.Latitude__c from Gumutindo_Primary_Society__C');
			for (Gumutindo_Primary_Society__c assoc: associations) {
				District__c tempDistrict = new District__c();
				tempDistrict.Name = assoc.Subcounty__r.District__r.Name;
				tempDistrict.Latitude__c = assoc.Subcounty__r.District__r.Latitude__c;
				tempDistrict.Longitude__c = assoc.Subcounty__r.District__r.Longitude__c;
				mapMarkers.add(new GumutindoDistrictMarker(tempDistrict));
				//System.debug('got district marker for district '+tempDistrict);
			}
			//System.debug(mapMarkers.size()+' district map markers created');
			return mapMarkers;
		}
	}*/

	//inner class to provide primaty society map markers
	public with sharing class GumutindoPrimarySocietyCoordinatesProvider implements MapComponentController.IMapMarkerSource {
		
		public List < MapMarkers > loadMapMarkers(Map < String, String > parameters) {
			List < MapMarkers > mapMarkers = new List < MapMarkers > ();			
			//For Live, select from group
			Gumutindo_Primary_Society__c[] associations = Database.query('select Id, Name, Subcounty__r.District__r.ID, Subcounty__r.District__r.Name, Subcounty__r.District__r.Longitude__C, Subcounty__r.District__r.Latitude__c from Gumutindo_Primary_Society__C');
			for (Gumutindo_Primary_Society__c assoc: associations) {
				mapMarkers.add(new GumutindoPrimarySocietyMarker(assoc));
				//System.debug('got district marker for district '+tempDistrict);
			}
			//System.debug(mapMarkers.size()+' district map markers created');
			return mapMarkers;
		}
	}

	//inner class to provide ckw map markers
	/*public with sharing class GumutindoCkwCoordinatesProvider implements MapComponentController.IMapMarkerSource {
		
		public List < MapMarkers > loadMapMarkers(Map < String, String > parameters) {
			List < MapMarkers > mapMarkers = new List < MapMarkers > ();

			//For Live, select from group
			Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'GCCE\' and Person__r.Type__c=\'CKW\'');
			List < String > personIds = new List < String > ();
			for (Person_Group_Association__c assoc: associations) {
				personIds.add(assoc.Person__r.Id);
			}

			Gumutindo_Field_Officer__c[] fos = [SELECT Id, Name, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c FROM Gumutindo_Field_Officer__c WHERE Person__r.Id in : personIds];
			for (Gumutindo_Field_Officer__c fo: fos) {
				//mapMarkers.add(new GumutindoCkwMarker(fo));
			}
			System.debug(mapMarkers.size() + ' map markers found');

			//Get Fo Markers
			Gumutindo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_Field_Officer__c];
			for (Gumutindo_Field_Officer__c fo: fieldOfficers) {
				Person__c p = new Person__c();
				p.Id = fo.Person__r.Id;
				p.GPS_Location_E__c = fo.Person__r.GPS_Location_E__c;
				p.GPS_Location_N__c = fo.Person__r.GPS_Location_N__c;
				p.First_Name__c = fo.Person__r.First_Name__c;
				p.Last_Name__c = fo.Person__r.Last_Name__c;
				mapMarkers.add(new GumutindoFieldOfficerMarker(p));
			}
			return mapMarkers;
		}
	}*/

	/*public with sharing class GumutindoDistrictMarker extends MapMarkers {
		
		private District__c district;

		private String parentRegistered;
		public Integer numberOfCkws;
		public String getParentRegistered() {
			return this.parentRegistered;
		}

		public void setParentRegistered(String value) {
			this.parentRegistered = value;
		}

		public GumutindoDistrictMarker(District__c district) {
			this.district = district;
			this.setLatitude('' + district.Latitude__c);
			this.setLongitude('' + district.Longitude__c);
			this.setMarkerColour('00FF00'); // Blue
		}

		//Show district summary for Gumutindo
		public override String getMarkerInfoContentString() {
			// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
			//PageReference ref = new PageReference('/apex/CkwDetailMini?id=this.ckw.Id');
			//String profile = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';
			String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">District Name: ' + district.Name + '</div>';
			return profile;
		}
	}*/

	// Gumutindo Map Marker
	/*public with sharing class GumutindoCkwMarker extends MapMarkers {
		
		private Gumutindo_Field_Officer__c fo;

		private String parentRegistered;
		public String getParentRegistered() {
			return this.parentRegistered;
		}

		public void setParentRegistered(String value) {
			this.parentRegistered = value;
		}

		public GumutindoCkwMarker(Gumutindo_Field_Officer__c fo) {
			this.fo = fo;
			this.setLatitude(fo.Person__r.GPS_Location_N__c);
			this.setLongitude(fo.Person__r.GPS_Location_E__c);
			this.setMarkerColour('0000FF'); // Blue
		}

		public override String getMarkerInfoContentString() {
			// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
			PageReference ref = new PageReference('/apex/FoDetailMini?id=' + this.fo.Id);
			String profile = '<iframe src="' + ref.getUrl() + '" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';
			return profile;
		}

		// Create the location string
		public override String getLocation() {

			String location = '';
			if (this.fo.Person__r.Parish__c != null) {
				location = 'Parish: ' + this.fo.Person__r.Parish__c + '<br />';
			}
			if (this.fo.Person__r.Village__c != null) {
				location = location + 'Village: ' + this.fo.Person__r.Village__c + '<br />';
			}
			if (this.fo.Person__r.Subcounty__r.Display_Name__c != null) {
				location = location + 'Sub-county: ' + this.fo.Person__r.Subcounty__r.Display_Name__c + '<br />';
			}
			location = location + 'District: ' + this.fo.Person__r.District__r.Name + '<br />';

			return location;
		}

		public override void generateMarkerName(String splitter) {

			String fieldValue = '';
			setColour(getDefaultColour());

			// Set the colours for a gender split
			if (splitter.equals('Gender')) {
				fieldValue = this.fo.Person__r.Gender__c;
				setColour('Pink');
				if (fieldValue == null) {
					setColour('Black');
					fieldValue = 'Missing';
				} else if (fieldValue.equals('Male')) {
					setColour('Blue');
				}
			}
			setMarkerName(joinMarkerName('', '', fieldValue));
		}
	}*/

	/*public with sharing class GumutindoFieldOfficerMarker extends MapMarkers {
		private Person__c person;

		private String parentRegistered;
		public String getParentRegistered() {
			return this.parentRegistered; 
		}

		public void setParentRegistered(String value) {
			this.parentRegistered = value;
		}

		public GumutindoFieldOfficerMarker(Person__c person) {
			this.person = person;
			this.setLatitude(person.GPS_Location_N__c);
			this.setLongitude(person.GPS_Location_E__c);
			this.setMarkerColour('00FF88');
		}

		public override String getMarkerInfoContentString() {
			
			// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
			String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: ' + person.First_Name__c + ' ' + person.Last_Name__c + '<br/>';
			//Show CKWs under this field officer
			Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Field_Officer__r.Person__r.Id = : person.Id];
			if (gumutindoCkws.size() == 0) {
				profile += 'Field officer has no CKWs attached';
			} else {
				profile += '<hr><b>Ckws attached to FO</b><br/>';
				for (Gumutindo_CKW__c gckw: gumutindoCkws) {
					profile += gckw.Person__r.First_Name__c + ' ' + gckw.Person__r.Last_Name__c + '<br/>';

				}
			}
			profile += '</div>';
			return profile;
		}
	}*/

	// Gumutindo Primary Societies Map Marker
	public with sharing class GumutindoPrimarySocietyMarker extends MapMarkers {
		
		private Gumutindo_Primary_Society__c society;

		private String parentRegistered;
		public String getParentRegistered() {
			return this.parentRegistered;
		}

		public void setParentRegistered(String value) {
			this.parentRegistered = value;
		}

		public GumutindoPrimarySocietyMarker(Gumutindo_Primary_Society__c society) {
			this.society = society;
			this.setLatitude('' + society.Subcounty__r.District__r.Latitude__c);
			this.setLongitude('' + society.Subcounty__r.District__r.Longitude__C);
			this.setMarkerColour('FF8800');
		}

		public override String getMarkerInfoContentString() {
			
			// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
			String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Primary Society Name: ' + society.Name + '<br/>';
			//Show CKWs under this field officer
			Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Primary_Society__r.Id = : society.Id];
			if (gumutindoCkws.size() == 0) {
				profile += 'Primary Society has no CKWs';
			} else {
				profile += '<hr><b>Ckws in Society</b><br/>';
				for (Gumutindo_CKW__c gckw: gumutindoCkws) {
					profile += gckw.Person__r.First_Name__c + ' ' + gckw.Person__r.Last_Name__c + '<br/>';
				}
			}
			profile += '</div>';
			return profile;
		}
	}

    public static String getSubcounties(){
        String inclause =
                ' AND '                                             +
                    'District__c IN ('                              +
                        'SELECT '                                   +
                            'District__c '                          +
                        'FROM '                                     +
                            'Organisation_District_Association__c ' +
                        'WHERE '                                    +
                            'Organisation__r.Name = \'GCCE\''       +
                    ') ';
        return 'SELECT Id, '                    +
                    'Display_Name__c, '         +
                    'District__c '              +
                'FROM Subcounty__c '            +
                'WHERE District__c != NULL '    +
                '   AND  District__c != \'\' '  +
                    inclause                    +
                'ORDER BY Display_Name__c ';
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
	        String query = 
	            'SELECT ' +
                    'Id,' +
                    'Metric_Name__c, ' +
                    'Section__c, ' +
                    'Label__c, ' +
                    'Target__c ' +
                'FROM '  +
                    'Gumutindo_Targets__c '+
                'WHERE '+
                    'Id =: metricId';
	        Gumutindo_Targets__c[] data1 = database.query(query);
	
	        String chdActual = ''; // Actual values
	        String chdProjected = ''; // Projected values
	
	        // Because we show one less coordinate for the actual graph, we have to do xy graphs, 
	        // so we need to track the xpoint
	        Integer xCount = 0;
	        Integer total = data1.size();
	        String xProjected = '';
	        String xActual = ''; 
	
	        for(Gumutindo_Targets__c item : data1) {
	            
	            chdProjected += item.Target__c  != null ? item.Target__c + ',' : '0,';
	            xProjected += (xCount * 100 / Math.max(1, total - 1)) + ',';
	            
	           // chdActual = getDataInQuarter(quarter, metricName)[0];
	            

                /*if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Sum' || 
                        item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Count') {
                    chdActual += item.Numerator__c != null ? item.Numerator__c + ',' : '0,';
                }
                else if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Percentage'){
                    chdActual += (item.Numerator__c != null && item.Denumerator__c != null && item.Denumerator__c != 0) ?
                            ((item.Numerator__c / item.Denumerator__c) * 100).setScale(2) + ',' : '0,';
                }*/
                xActual += (xCount * 100 / Math.max(1,total - 1)) + ',';
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

        public Wrapper(Map<String, Map<String, GumutindoHelpers.DataWrapper>> dataWrapper, Map<String, 
            List<String>> orderWrapper) {
            
            this.dataWrapper = dataWrapper;
            this.dataWrapperOrder = orderWrapper;
        }

        public Map<String, Map<String, GumutindoHelpers.DataWrapper>> dataWrapper { get; set; }
        public Map<String, List<String>> dataWrapperOrder { get; set; }
    }

     // Wrapper class for financial services chart data
    public class FinancialServicesUsageData {
        public String name { get; set; }
        public Decimal data1 { get; set; }
        
        public FinancialServicesUsageData(String name, Decimal data1) {
            this.name = name;
            this.data1 = data1;
        }
    }
    
    public enum SubmissionType { FARMER_REGISTRATION, VSLA_REGISTRATION, GCCE_REGISTRATION, CKW_MONITORING, PS_REGISTRATION,  NONE }
}