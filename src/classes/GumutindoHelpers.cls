public /* with sharing */ class GumutindoHelpers {
	public GumutindoHelpers() {
		
	}


    

    public static Dashboard_Section__C getGumutindoDashboardSection() {
        //Get the gumutindo dashboard section
        List<Dashboard_Section__c> dashboardSection = [select Id, Dashboard__c from Dashboard_Section__c where Title__C='Gumutindo Dashboard'];
        return dashboardSection[0];
    }


	//A List of the Metric Names used on the Gumutindo Dashboard
	public static List<String> getMetricNames(){
		List<String> gumutindoMetricNames = new List<String> {
            'Gumutindo_target_farmers_reached_in_year_1',
			'Gumutindo_target_farmers_reached_in_year_2',
			'Gumutindo_target_farmers_reached_in_year_3',
			'Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices',
			'Gumutindo_farmers_who_receive_advisory_services_from_ckw_network',
			'Gumutindo_farmer_groups_who_receive_support_from_ckw_network',
			'Gumutindo_farmers_who_report_satisfaction_quality_of_extension_support',
			'Gumutindo_farmers_who_purchase_organic_fertilizer_through_gcce',
			'Gumutindo_farmers_who_purchase_organic_seedlings_through_gcce',
			'Gumutindo_farmers_who_deliver_50_percent_of_hi_qual_coffee',
			'Gumutindo_farmers_who_access_agro_input_loans_through_ps',
			'Gumutindo_farmers_who_use_atleast_one_kind_of_financial_services',
			'Gumutindo_farmers_who_access_financial_services_through_vslas',
			'Gumutindo_farmers_who_report_satisfaction_with_gcce_services',
			'Gumutindo_farmers_who_report_satisfaction_with_ps_services',
			'Gumutindo_adherence_to_gcce_policies',
			'Gumutindo_percentage_of_ps_with_established_policied_and_procedures',
			'Gumutindo_percentage_of_ps_compliant_to_established_policied_and_procedures',
			'Gumutindo_percentage_of_ps_who_collectively_procure_inputs',
			'Gumutindo_percentage_of_ps_who_collectively_pay_for_inputs'
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
                dataMap.put(metricName, metricData);
            }
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

        Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

         //Depending on which year.. increment the appropriate metric for farmer reached
         M_E_Metric_Data__c mData = null;
         String projectYear = getMumutindoProjectYear(Date.valueOf(handsetSubmitTime));
         String farmerReachedMetric = null;

         if('1'.equals(projectYear)) {
         	farmerReachedMetric = 'Gumutindo_target_farmers_reached_in_year_1';
         	
         }  
         else if('2'.equals(projectYear)) {
         	farmerReachedMetric = 'Gumutindo_target_farmers_reached_in_year_2';
         	
         }
         else {
         	farmerReachedMetric = 'Gumutindo_target_farmers_reached_in_year_3';
         	
         }

         //Increment metric for reached farmer in first year
         mData = dataMap.get(farmerReachedMetric);
         

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

        Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

       


         //Increment metric for reached farmer in first year
         M_E_Metric_Data__c mData = dataMap.get('Gumutindo_farmer_groups_who_receive_support_from_ckw_network');
         

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

        Map<String, M_E_Metric_Data__c> dataMap = getMetricDataMap();

       


         //Increment metric for reached farmer in first year
         M_E_Metric_Data__c mData = dataMap.get('Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices');
         

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
         mData = dataMap.get('Gumutindo_farmers_who_receive_advisory_services_from_ckw_network');
         

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


public static M_E_Metric_Data__c getMetricData(String metricName) {
    //Gets the metric datas, for the current quarter
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
        System.debug('Dates are '+quarterFirstDay +' and '+quarterLastDay);
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
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Id
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :metricName
                and Date__c >=:quarterFirstDay    
                and Date__c <=:quarterLastDay  
        ];

        for(M_E_Metric_Data__c m : metric) {
        	System.debug('Got metric '+m.Name);
        }

        if(metric.size() == 0) {
            //Metric data was not found, create it with quarter first day as the date
            System.debug('Gumutindo metric data '+metricName+' not found, going to create it');
            M_E_Metric_Data__c metricdata = new M_E_Metric_Data__C();
            List<M_E_Metric__C> metr = [select Id,Label__c from M_E_Metric__C where Name = :metricName];
            if(metr.size() == 0)
            {
                System.debug('Gumutindo metric '+metricName+' not found, what happened?');
            }
            metricdata.M_E_Metric__c=metr[0].Id;
            metricdata.Comment__c = metr[0].Label__c;
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
    
    






	//inner class to provide ckw map markers
	public with sharing class GumutindoCkwCoordinatesProvider implements MapComponentController.IMapMarkerSource
	{
			public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
		List<MapMarkers> mapMarkers = new List<MapMarkers>();


		
		//Select Gumutindo Ckws from db
		/*CKW__c[] ckws = Database.query('SELECT Id, Name, ' +
							'Person__r.GPS_Location_E__c,' + 
							'Person__r.GPS_Location_N__c ' +
							'from CKW__c'); */

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
    		return mapMarkers;	
		
		}
	}




	// G umutindo Ckw Map Marker
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
}