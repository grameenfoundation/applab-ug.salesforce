public class GumutindoHelpers {
	public GumutindoHelpers() {
		
	}


    //Metrics
    public static final String MALE_FARMERS_REGISTERED = 'GUMUTINDO_male_farmers_registered';
    public static final String FEMALE_FARMERS_REGISTERED = 'GUMUTINDO_female_farmers_registered';

    public static final String TARGET_FARMERS_REACHED_IN_YEAR_1 = 'GUMUTINDO_target_farmers_reached_in_year_1';
    public static final String TARGET_FARMERS_REACHED_IN_YEAR_2 = 'GUMUTINDO_target_farmers_reached_in_year_2';
    public static final String TARGET_FARMERS_REACHED_IN_YEAR_3 = 'GUMUTINDO_target_farmers_reached_in_year_3';

    public static final String FARMERS_USING_ATLEAST_3_AGROC_PRACTICES = 'GUMUTINDO_target_farmers_using_at_least_three_of_recommended_agroc_practices';
    public static final String FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK = 'GUMUTINDO_farmers_who_receive_advisory_services_from_ckw_network';
    public static final String FARMER_GROUPS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK = 'GUMUTINDO_farmer_groups_who_receive_support_from_ckw_network';

    public static final String FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_quality_of_extension_support';
    public static final String FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE = 'GUMUTINDO_farmers_who_purchase_organic_fertilizer_through_gcce';
    public static final String FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE = 'GUMUTINDO_farmers_who_purchase_organic_seedlings_through_gcce';

    public static final String FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE = 'GUMUTINDO_farmers_who_deliver_50_percent_of_hi_qual_coffee';
    public static final String FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS = 'GUMUTINDO_FARMERS_Who_access_agro_input_loans_through_ps';
    public static final String FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES = 'GUMUTINDO_farmers_who_use_atleast_one_kind_of_financial_services';

    public static final String FARMERS_WHO_ACCESS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_micro_insurance_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_savings_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS = 'GUMUTINDO_farmers_who_access_loaning_financial_services_through_vslas';
    public static final String FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_with_gcce_services';
    public static final String FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES = 'GUMUTINDO_farmers_who_report_satisfaction_with_ps_services';


    public static final String ADHERENCE_TO_GCCE_POLICIES = 'GUMUTINDO_adherence_to_gcce_policies';
    public static final String PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES = 'GUMUTINDO_percentage_of_ps_with_established_policied_and_procedures';
    public static final String PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES = 'GUMUTINDO_percentage_of_ps_compliant_to_established_policied_and_procedures';


    public static final String PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS = 'GUMUTINDO_percentage_of_ps_who_collectively_procure_inputs';
    public static final String PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS = 'GUMUTINDO_percentage_of_ps_who_collectively_pay_for_inputs';
    public static final String NUMBER_OF_REGISTERED_VSLAS = 'GUMUTINDO_number_of_registered_vslas';




    public static Dashboard_Section__C getGumutindoDashboardSection() {
        //Get the gumutindo dashboard section
        List<Dashboard_Section__c> dashboardSection = [select Id, Dashboard__c from Dashboard_Section__c where Title__C='Gumutindo Dashboard'];
        return dashboardSection[0];
    }


	//A List of the Metric Names used on the Gumutindo Dashboard
	public static List<String> getMetricNames(){
		List<String> gumutindoMetricNames = new List<String> {
            MALE_FARMERS_REGISTERED,
            FEMALE_FARMERS_REGISTERED ,
            TARGET_FARMERS_REACHED_IN_YEAR_1,
            TARGET_FARMERS_REACHED_IN_YEAR_2,
            TARGET_FARMERS_REACHED_IN_YEAR_3 ,
            FARMERS_USING_ATLEAST_3_AGROC_PRACTICES,
            FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK,
            FARMER_GROUPS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK,
            FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES,
            FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE,
            FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE,
            FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE,
            FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS,
            FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES,
            FARMERS_WHO_ACCESS_FINANCIAL_SERVICES_THROUGH_VSLAS,
            FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES,
            FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES,
            ADHERENCE_TO_GCCE_POLICIES,
            PERCENTAGE_OF_PS_WITH_ESTABLISHED_POLICIED_AND_PROCEDURES,
            PERCENTAGE_OF_PS_COMPLIANT_TO_ESTABLISHED_POLICIED_AND_PROCEDURES,
            PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS,
            PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS,
            FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS,
            FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS,
            FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS,
            NUMBER_OF_REGISTERED_VSLAS
        };

        return gumutindoMetricNames;
	}
	

    //Returns a map of Metric Datas
	public static Map<String, M_E_Metric_Data__c> getMetricDataMap() {
		Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (String metricName : getMetricNames()) {
                M_E_Metric_Data__c metricData = getMetricData(metricName);
                if(metricData == null)
                {
                	System.debug('Metric  '+metricName+' could not be loaded from database');
                	continue;
                }

                //Add this metric data to our metric data map
                dataMap.put(metricName.toLowerCase(), metricData);
            }
            //System.debug(dataMap);
            return dataMap;
	}



    


/**
     *  Processes the Gumutindo GCCE Farm entrance survey submission
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



    public static List<String> processGCCEFarmEntranceSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        
        //Load the details of the CIW who is carrying out the registration
        CKW__c ckw = loadCkw(person);
        if(ckw == null) {
        	return new String[] { '0', 'Submitter CKW was not found in System', 'SUPRESSMSG' };
        }

        
        //Load Metric Datas from DB to a HashMap of Metric Datas

        //Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

         //Depending on which year.. increment the appropriate metric for farmer reached
         M_E_Metric_Data__c mData = null;
         String projectYear = getMumutindoProjectYear(Date.valueOf(handsetSubmitTime));
         String farmerReachedMetric = null;

         if('1'.equals(projectYear)) {
         	farmerReachedMetric = TARGET_FARMERS_REACHED_IN_YEAR_1;
         	
         }  
         else if('2'.equals(projectYear)) {
         	farmerReachedMetric =  TARGET_FARMERS_REACHED_IN_YEAR_2;
         	
         }
         else {
         	farmerReachedMetric = TARGET_FARMERS_REACHED_IN_YEAR_3;
         	
         }

         //Increment metric for reached farmer in first year
         //mData = dataMap.get(farmerReachedMetric.toLowerCase());
         mData = getMetricData(farmerReachedMetric.toLowerCase());
         

         if(mData == null) {
         	//Metric data was not found
         	return new String[] { '0', 'Metric data : '+farmerReachedMetric+' was not found and can not be updated', 'SUPRESSMSG' };
         }

         //increment the metric data
         mData.Numerator__c+=1;
         database.upsert(mData);
        // Set a rollback point
        //Savepoint sp = Database.setSavepoint();



        return new String[] { '1', 'GCCE Farm Entrance Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }



    /**
     *  Processes the Gumutindo Group survey submission
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
    public static List<String> processGumutindoGroupSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        
        //Load the details of the CIW who is carrying out the registration
        CKW__c ckw = loadCkw(person);
        if(ckw == null) {
        	return new String[] { '0', 'Submitter CKW was not found in System', 'SUPRESSMSG' };
        }

        
        //Load Metric Datas from DB to a HashMap of Metric Datas

        //Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

       


         //Increment metric for reached farmer in first year
         //M_E_Metric_Data__c mData = dataMap.get(FARMER_GROUPS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK.toLowerCase());
         M_E_Metric_Data__c mData = getMetricData(FARMER_GROUPS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK.toLowerCase());
         

         if(mData == null) {
         	//Metric data was not found
         	return new String[] { '0', 'Metric data : Gumutindo_farmer_groups_who_receive_support_from_ckw_network was not found and can not be updated', 'SUPRESSMSG' };
         }
         mData.Denumerator__c += 1;
         //Metric of Gumutindo_farmer_groups_who_receive_support_from_ckw_network
         System.debug('My map is '+answers);
         Set<String> supportReceived = ProcessSubmissionHelpers.getAnswerSet(answers.get('q11_0'));
         //if atleast one service is received, increase the numerator
         if(! supportReceived.isEmpty()) {
         	//increment the metric data numerator
         mData.Numerator__c+=1;
         }


         
         database.upsert(mData);
         String[] result = new String[] { '1', 'Gumutindo Group Survey processed IMEI: ' + submission.imei, 'SUPRESSMSG' };
         System.debug(result);
         return result;
    }










    /**
     *  Processes the Gumutindo Group Farmer Member Assessment survey submission
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
   public static List<String> processGroupFarmerMemberAssessmentSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        
        //Load the details of the CIW who is carrying out the registration
        CKW__c ckw = loadCkw(person);
        if(ckw == null) {
            return new String[] { '0', 'Submitter CKW was not found in System', 'SUPRESSMSG' };
        }

        
        //Load Metric Datas from DB to a HashMap of Metric Datas

        //Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

       


         //Increment metric for reached farmer in first year
         //M_E_Metric_Data__c mData = dataMap.get(FARMERS_USING_ATLEAST_3_AGROC_PRACTICES.toLowerCase());
         M_E_Metric_Data__c mData = getMetricData(FARMERS_USING_ATLEAST_3_AGROC_PRACTICES.toLowerCase());
         

         if(mData == null) {
            //Metric data was not found
            return new String[] { '0', 'Metric data : Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices was not found and can not be updated', 'SUPRESSMSG' };
         }
         mData.Denumerator__c += 1;
         //Metric of Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices
         
         Set<String> practices = ProcessSubmissionHelpers.getAnswerSet(answers.get('q13_0'));
         //if atleast three practices are used, increase the numerator
         if(practices.size() >= 3) {
            //increment the metric data numerator
         mData.Numerator__c+=1;
         }


         
         database.upsert(mData);


         //Metric for services received from cooperate services
         mData = getMetricData(FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK.toLowerCase());
         

         if(mData == null) {
            //Metric data was not found
            return new String[] { '0', 'Metric data : Gumutindo_farmers_who_receive_advisory_services_from_ckw_network was not found and can not be updated', 'SUPRESSMSG' };
         }
         mData.Denumerator__c += 1;
         //Metric of Gumutindo_farmers_who_receive_advisory_services_from_ckw_network
         
         Set<String> advisoryServices = ProcessSubmissionHelpers.getAnswerSet(answers.get('q11_0'));
         //if atleast one advisory service is selcted, then increment denumerator
         if(! advisoryServices.isEmpty()) {
            //increment the metric data numerator
         mData.Numerator__c+=1;
         }


         
         database.upsert(mData);


         String[] result = new String[] { '1', 'Gumutindo Group Farmer Member Assessment Survey processed for IMEI: ' + submission.imei, 'SUPRESSMSG' };
         System.debug(result);
         return result;
    }









/**
     *  Returns the year of operation given the date
     *
     *  @param inputDate - The date for which the operation year is to be determined     
     *  @return - A string showing the year of operation
     */
public static String getMumutindoProjectYear(Date inputDate) {
	if(inputDate < Date.valueOf('2015-01-01')) {
		return '1';
	}
	else if(inputDate >= Date.valueOf('2015-01-01') && inputDate < Date.valueOf('2016-01-01')) {
		return '2';
	}
	else {
		return '3';
	}
}

//Attempts to create missing metic datas
public void getAllMetricDatas()
{
    for(String metricName : getMetricNames())
    {
     GumutindoHelpers.getMetricData(metricName);   
    }
}

public static M_E_Metric_Data__c getMetricData(String metricName) {
    //Gets the metric datas, for the current quarter
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
        //System.debug('Dates are '+quarterFirstDay +' and '+quarterLastDay);
        M_E_Metric_Data__c[] metric = [
            SELECT 
                Name,
                Id,
                Date__c,
                Actual_Value__c,
                Projected_Value__c,
                Manual_Value__c,
                Real_Value__c,
                Is_Cumulative__c,
                Numerator__c,
                Denumerator__c,
                Comment__c,
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Id
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :metricName
                and Date__c >=:quarterFirstDay    
                and Date__c <=:quarterLastDay  
        ];

        //for(M_E_Metric_Data__c m : metric) {
        //	//System.debug('Got metric '+m.Name);
        //}

        if(metric.size() == 0) {
            //Metric data was not found, create it with quarter first day as the date
            System.debug('Gumutindo metric data '+metricName+' not found, going to create it');
            M_E_Metric_Data__c metricdata = new M_E_Metric_Data__C();
            List<M_E_Metric__C> metr = [select Id,Label__c from M_E_Metric__C where Name = :metricName];
            M_E_Metric__C tempMetric;
            if(metr.size() == 0)
            {
                //If parent metric is not found, attempt to a create it
                System.debug('Gumutindo metric '+metricName+' not found, create metric');
                tempMetric = new M_E_Metric__C();
                tempMetric.Name = metricName;
                tempMetric.Label__c = metricName.replace('_', ' ');
                insert(tempMetric);
                
            }
            else
            {
              tempMetric = metr[0];  
            }
            metricdata.M_E_Metric__c=tempMetric.Id;
            metricdata.Comment__c = tempMetric.Label__c;
            metricdata.Date__c = quarterFirstDay;
            metricdata.Numerator__c=0;
            metricdata.Denumerator__c=0;
            metricdata.Projected_Value__c=0;
            metricdata.Manual_Value__c=0;
            Database.saveResult saveResult = database.insert(metricdata);
            String newMetricId = saveResult.getId();
            metric = [
            SELECT 
                Name,
                Id,
                Date__c,
                Actual_Value__c,
                Comment__c,
                Projected_Value__c,
                Manual_Value__c,
                Real_Value__c,
                Is_Cumulative__c,
                Numerator__c,
                Denumerator__c,
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Id
            FROM
                M_E_Metric_Data__c
            WHERE
                Id = :newMetricId
        ];

        }
        if (metric.size() != 1) {

            // Found more than one of the metric. Error that calling procedure should handle.
            return null;
        }
        return metric[0];
    }


public static Map<String, M_E_Metric__c> getAllMetrics(){
        String query = 'SELECT '                                        +
                            'Id, '                                      +
                            'Name, '                                    +
                            'Label__c, '                                +
                            'Projected_Value__c, '                      +
                            'Further_Link_Text__c, '                    +
                            'Further_Link_Url__c '                      +
                        'FROM '                                         +
                            'M_E_Metric__c '                            +
                        'WHERE '                                        +
                            'Name LIKE \'GUMUTINDO_%\' ';
        Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();
        for(M_E_Metric__c metric : database.query(query)){
            metricMap.put(metric.Name.toLowerCase(), metric);
        }
        return metricMap;
    }


private static CKW__c loadCkw(Person__c person) {
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
    }
    
	public static MetricMapWrapper[] getGumutindoPrimarySocietyMarkers()
	{
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
		Gumutindo_Primary_Society__c[] primarySocieties = [SELECT id, Name, Latitude__c, Longitude__c from Gumutindo_Primary_Society__c];
        for(Gumutindo_Primary_Society__c society : primarySocieties)
        {
            MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('District', '0000FF', society.Id, true);
                marker.gpsLatitude = ''+society.Latitude__c;
                marker.gpsLongitude = ''+society.Longitude__c;
                
                //PageReference ref = new PageReference('/apex/CkwDetailMini?id='+ckw.Id);
                //String content = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';

                
                //marker.addName(content);
                marker.markerTitle = society.Name;
                markers.put(society.Id, marker); 
        }
        return markers.values();
	}
	

    public static MetricMapWrapper[] getCKWMapMarkers()
    {
      Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
      Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c,  Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'GCCE\' and Person__r.Type__c=\'CKW\'');
        List<String> personIds = new List<String>();
        for(Person_Group_Association__c assoc : associations) {
            personIds.add(assoc.Person__r.Id);
        }

        
        CKW__c[] ckws = [SELECT id, Name, Person__r.First_Name__c, Person__r.Last_Name__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c from CKW__c where Person__r.Id in :personIds];
            for (CKW__c ckw : ckws) {
                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('CKW', '0000FF', ckw.Id, true);
                marker.gpsLatitude = ckw.Person__r.GPS_Location_N__c;
                marker.gpsLongitude = ckw.Person__r.GPS_Location_E__c;
                
                PageReference ref = new PageReference('/apex/CkwDetailMini?id='+ckw.Id);
                String content = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';

                
                marker.addName(content);
                marker.markerTitle = ckw.Person__r.First_Name__c+' '+ckw.Person__r.Last_Name__c;
                markers.put(ckw.Id, marker);

            }


            //Field officers
            Gumutindo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_Field_Officer__c];
            for (Gumutindo_Field_Officer__c fo : fieldOfficers) {

                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('CKW', '00FF88', fo.Person__r.Id, true);
                marker.gpsLatitude = fo.Person__r.GPS_Location_N__c;
                marker.gpsLongitude = fo.Person__r.GPS_Location_E__c;
                
                
                String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: '+fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c+'<br/>';
                    //Show CKWs under this field officer
                    Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Field_Officer__r.Person__r.Id =:fo.Person__r.Id];
                    if(gumutindoCkws.size() == 0) {
                        profile += 'Field officer has no CKWs attached';
                    }
                    else {
                        profile += '<hr><b>Ckws attached to FO</b><br/>';
                        for (Gumutindo_CKW__c gckw : gumutindoCkws) {
                            profile += gckw.Person__r.First_Name__c + ' '+ gckw.Person__r.Last_Name__c +'<br/>';

                        }
                    }
                    profile += '</div>';
                
                marker.addName(profile);
                marker.markerTitle = fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c;
                markers.put(fo.Person__r.Id, marker);
            }
            System.debug(markers.size()+' map markers found'); 
            return markers.values();
    }



    //inner class to provide district map markers
    public with sharing class GumutindoDistrictCoordinatesProvider implements MapComponentController.IMapMarkerSource
    {
            public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
        List<MapMarkers> mapMarkers = new List<MapMarkers>();


        //For Live, select from group
        Gumutindo_Primary_Society__c[] associations = Database.query('select Id, Name, Subcounty__r.District__r.ID, Subcounty__r.District__r.Name, Subcounty__r.District__r.Longitude__C, Subcounty__r.District__r.Latitude__c from Gumutindo_Primary_Society__C');
           for (Gumutindo_Primary_Society__c assoc : associations) {
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
    }




    //inner class to provide primaty society map markers
    public with sharing class GumutindoPrimarySocietyCoordinatesProvider implements MapComponentController.IMapMarkerSource
    {
            public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
        List<MapMarkers> mapMarkers = new List<MapMarkers>();


        //For Live, select from group
        Gumutindo_Primary_Society__c[] associations = Database.query('select Id, Name, Subcounty__r.District__r.ID, Subcounty__r.District__r.Name, Subcounty__r.District__r.Longitude__C, Subcounty__r.District__r.Latitude__c from Gumutindo_Primary_Society__C');
           for (Gumutindo_Primary_Society__c assoc : associations) {
                
                mapMarkers.add(new GumutindoPrimarySocietyMarker(assoc));
                //System.debug('got district marker for district '+tempDistrict);
            }
            //System.debug(mapMarkers.size()+' district map markers created');
            return mapMarkers;  
        
        }
    }


	//inner class to provide ckw map markers
	public with sharing class GumutindoCkwCoordinatesProvider implements MapComponentController.IMapMarkerSource
	{
		public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
		List<MapMarkers> mapMarkers = new List<MapMarkers>();


		//For Live, select from group
		Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'GCCE\' and Person__r.Type__c=\'CKW\'');
        List<String> personIds = new List<String>();
        for(Person_Group_Association__c assoc : associations) {
            personIds.add(assoc.Person__r.Id);
        }

		
        CKW__c[] ckws = [SELECT id, Name, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c from CKW__c where Person__r.Id in :personIds];
			for (CKW__c ckw : ckws) {
    			mapMarkers.add(new GumutindoCkwMarker(ckw));
			}
			System.debug(mapMarkers.size()+' map markers found');


            //Get Fo Markers
            Gumutindo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_Field_Officer__c];
            for (Gumutindo_Field_Officer__c fo : fieldOfficers) {
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
	}



        public with sharing class GumutindoDistrictMarker extends MapMarkers {
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
            this.setLatitude(''+district.Latitude__c);
            this.setLongitude(''+district.Longitude__c);
            this.setMarkerColour('00FF00'); // Blue
        }
        
        //Show district summary for Gumutindo
        public override String getMarkerInfoContentString() {
            // Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
            //PageReference ref = new PageReference('/apex/CkwDetailMini?id=this.ckw.Id');
            //String profile = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';
            String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">District Name: '+district.Name+'</div>';
            return profile;
           
        }
        
        
       }




	// Gumutindo Map Marker
	public with sharing class GumutindoCkwMarker extends MapMarkers {
		private CKW__c ckw;
		 
		private String parentRegistered;
	    public String getParentRegistered() {
	        return this.parentRegistered;
	    }
	    
	    public void setParentRegistered(String value) {
	        this.parentRegistered = value;
	    }
	    
		public GumutindoCkwMarker(CKW__c ckw) {
	        this.ckw = ckw;
	        this.setLatitude(ckw.Person__r.GPS_Location_N__c);
	        this.setLongitude(ckw.Person__r.GPS_Location_E__c);
	        this.setMarkerColour('0000FF'); // Blue
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
	    	PageReference ref = new PageReference('/apex/CkwDetailMini?id='+this.ckw.Id);
	    	String profile = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';
	    	return profile;
           
	    }



        // Create the location string
    public override String getLocation() {

        String location = '';
        if (this.ckw.Person__r.Parish__c != null) {
            location = 'Parish: ' + this.ckw.Person__r.Parish__c + '<br />';
        }
        if (this.ckw.Person__r.Village__c != null) {
            location = location + 'Village: ' + this.ckw.Person__r.Village__c + '<br />';
        }
        if (this.ckw.Person__r.Subcounty__r.Display_Name__c != null) {
            location = location + 'Sub-county: ' + this.ckw.Person__r.Subcounty__r.Display_Name__c + '<br />';
        }
            location = location + 'District: ' + this.ckw.Person__r.District__r.Name + '<br />';
        
        return location;
    }


        public override void generateMarkerName(String splitter) {

            String fieldValue = '';
        setColour(getDefaultColour());

        // Set the colours for a gender split
        if (splitter.equals('Gender')) {
            fieldValue = this.ckw.Person__r.Gender__c;
            setColour('Pink');
            if (fieldValue == null) {
                setColour('Black');
                fieldValue = 'Missing';
            }
            else if (fieldValue.equals('Male')) {
                setColour('Blue');
            }
        }
        setMarkerName(joinMarkerName('', '', fieldValue));
        }


}








    // Gumutindo FO Map Marker
    public with sharing class GumutindoFieldOfficerMarker extends MapMarkers {
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
            
            String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: '+person.First_Name__c+' '+person.Last_Name__c+'<br/>';
            //Show CKWs under this field officer
            Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Field_Officer__r.Person__r.Id =:person.Id];
            if(gumutindoCkws.size() == 0) {
                profile += 'Field officer has no CKWs attached';
            }
            else {
                profile += '<hr><b>Ckws attached to FO</b><br/>';
                for (Gumutindo_CKW__c gckw : gumutindoCkws) {
                    profile += gckw.Person__r.First_Name__c + ' '+ gckw.Person__r.Last_Name__c +'<br/>';

                }
            }
            profile += '</div>';
            return profile;
           
        }



       


}








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
            this.setLatitude(''+society.Subcounty__r.District__r.Latitude__c);
            this.setLongitude(''+society.Subcounty__r.District__r.Longitude__C);
            this.setMarkerColour('FF8800'); 
        }
        
        public override String getMarkerInfoContentString() {
            // Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
            
            String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Primary Society Name: '+society.Name+'<br/>';
            //Show CKWs under this field officer
            Gumutindo_CKW__c[] gumutindoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Gumutindo_CKW__c where Gumutindo_Primary_Society__r.Id =:society.Id];
            if(gumutindoCkws.size() == 0) {
                profile += 'Primary Society has no CKWs';
            }
            else {
                profile += '<hr><b>Ckws in Society</b><br/>';
                for (Gumutindo_CKW__c gckw : gumutindoCkws) {
                    profile += gckw.Person__r.First_Name__c + ' '+ gckw.Person__r.Last_Name__c +'<br/>';

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


     // Wrapper class for financial services chart data
    public class FinancialServicesUsageData {
        public String name { get; set; }
        public Decimal data1 { get; set; }
        
        public FinancialServicesUsageData(String name, Decimal data1) {
            this.name = name;
            this.data1 = data1;
        }
    }







	}