public with sharing class MbugoHelpers {

	public static final String ORG_NAME = 'MBUGO';

    //Define metric names for mbugo
    public static final String FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_micro_insurance_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_savings_financial_services_through_vslas';
    public static final String FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_loaning_financial_services_through_vslas';
    public static final String NUMBER_OF_VSLAS_REGISTERED = 'MBUGO_farmers_number_of_vslas_registered';
    public static final String TOTAL_NUMBER_OF_FARMERS_IN_VSLAS = 'MBUGO_total_number_of_farmers_in_vslas';
    public static final String TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS = 'MBUGO_total_number_male_of_farmers_in_vslas';
    public static final String TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS = 'MBUGO_total_number_of_female_farmers_in_vslas';
    public static final String NUMBER_OF_COOPERATIVES_REGISTERED = 'MBUGO_number_of_cooperatives_registered';
    public static final String PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE = 'MBUGO_percentage_of_farmers_purchasing_inputs_from_mbugo_ace';
    


    //A List of the Metric Names used on the Mbugo Dashboard
    public static List<String> getMetricNames(){
        List<String> gumutindoMetricNames = new List<String> {
            
            FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS,
            FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS,
            FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS,
            NUMBER_OF_VSLAS_REGISTERED,
            TOTAL_NUMBER_OF_FARMERS_IN_VSLAS,
            TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS,
            TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS,
            NUMBER_OF_COOPERATIVES_REGISTERED,
            PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE
        };

        return gumutindoMetricNames;
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
                            'Organisation__r.Name = \'MBUGO\''       +
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


    public static List<MetricDataWrapper> getFarmerGroupsData()
    {
        List<MetricDataWrapper> farmerGroupsData = new List<MetricDataWrapper>();
        M_E_Metric_Data__c metricData;

        MetricDataWrapper vslaMetricWrapper = new MetricDataWrapper();
        vslaMetricWrapper.setLabel('Number of farmer learning groups/VSLA registered');
        metricData = getMetricData(NUMBER_OF_VSLAS_REGISTERED);
        vslaMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        vslaMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        vslaMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);



        MetricDataWrapper totalVslaFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaFarmerMetricWrapper.setLabel('Number of members registered in the farmer learning groups/VSLA ');
        metricData = getMetricData(TOTAL_NUMBER_OF_FARMERS_IN_VSLAS);
        totalVslaFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        totalVslaFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        totalVslaFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);


        MetricDataWrapper totalVslaMaleFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaMaleFarmerMetricWrapper.setLabel('Number of male members registered in the farmer learning groups');
        metricData = getMetricData(TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS);
        totalVslaMaleFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        totalVslaMaleFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        totalVslaMaleFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);



        MetricDataWrapper totalVslaFemaleFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaFemaleFarmerMetricWrapper.setLabel('Number of female members registered in the farmer learning groups');
        metricData = getMetricData(TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS);
        totalVslaFemaleFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        totalVslaFemaleFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        totalVslaFemaleFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);




        List<MetricDataWrapper> wrapper = new List<MetricDataWrapper> {vslaMetricWrapper, totalVslaFarmerMetricWrapper, 
            totalVslaMaleFarmerMetricWrapper, totalVslaFemaleFarmerMetricWrapper};
    
        return wrapper;
    }







    public static List<MetricDataWrapper> getCooperativeGroupsData()
    {
        
        M_E_Metric_Data__c metricData;

        MetricDataWrapper cooperativesMetricWrapper = new MetricDataWrapper();
        cooperativesMetricWrapper.setLabel('Number of cooperatives registered');
        metricData = getMetricData(NUMBER_OF_COOPERATIVES_REGISTERED);
        cooperativesMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        cooperativesMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        cooperativesMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        //TODO: Get these from db


        MetricDataWrapper coopPurchasingFarmerMetricWrapper = new MetricDataWrapper();
        coopPurchasingFarmerMetricWrapper.setLabel('Percent of targeted farmers purchasing inputs from Mbugo Ace through their cooperatives');
        metricData = getMetricData(PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE);
        coopPurchasingFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        coopPurchasingFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        coopPurchasingFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        //TODO: Get these from db

        


        List<MetricDataWrapper> wrapper = new List<MetricDataWrapper> {cooperativesMetricWrapper, coopPurchasingFarmerMetricWrapper};
    
        return wrapper;
    }




    public static List<MetricDataWrapper> getVslaServicesData()
    {
        
        M_E_Metric_Data__c metricData;

        MetricDataWrapper loaningWrapper = new MetricDataWrapper();
        loaningWrapper.setLabel('Percentage of target farmers with access to Loaning Financial Services');
        metricData = getMetricData(FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS);
        loaningWrapper.setMetricId(String.valueOf(metricData.Id));
        loaningWrapper.setCurrentTarget(metricData.Projected_Value__c);
        loaningWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        //TODO: Get these from db


        MetricDataWrapper savingsWrapper = new MetricDataWrapper();
        savingsWrapper.setLabel('Percentage of target farmers with access to Savings Financial Services');
         metricData = getMetricData(FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS);
        savingsWrapper.setMetricId(String.valueOf(metricData.Id));
        savingsWrapper.setCurrentTarget(metricData.Projected_Value__c);
        savingsWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);


        MetricDataWrapper insuranceWrapper = new MetricDataWrapper();
        insuranceWrapper.setLabel('Percentage of target farmers with access to Micro Insurance Financial Services');
        metricData = getMetricData(FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS);
        insuranceWrapper.setMetricId(String.valueOf(metricData.Id));
        insuranceWrapper.setCurrentTarget(metricData.Projected_Value__c);
        insuranceWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        
        List<MetricDataWrapper> wrapper = new List<MetricDataWrapper> {loaningWrapper, savingsWrapper, insuranceWrapper};
    
        return wrapper;
    }


    public static List<FinancialServicesUsageData> getFinancialServicesChartData()
    {

        
        List<FinancialServicesUsageData> data = new List<FinancialServicesUsageData>();
        M_E_Metric_Data__c metricData = getMetricData(FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS);
        data.add(new FinancialServicesUsageData('MicroInsurance', metricData.Manual_Value__c));

        metricData = getMetricData(FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS);
        data.add(new FinancialServicesUsageData('Savings', metricData.Manual_Value__c));

        metricData = getMetricData(FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS);
        data.add(new FinancialServicesUsageData('Loaning', metricData.Manual_Value__c));
        
        return data;
    }


    public static List<MetricDataWrapper> getFarmersReachedData()
    {
        List<MetricDataWrapper> farmersReachedData = new List<MetricDataWrapper>();

        M_E_Metric_Data__c metricData;
       
        
        Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'Mbugo CKWs\' and Person__r.Type__c=\'CKW\'');

        List<String> personIds = new List<String>();
        for(Person_Group_Association__c p : associations) {
            personIds.add(p.Person__r.Id);
        }

        //These are the ckw person ids

    List<Farmer__c> farmersRegisteredByMbugoCkws = [select Registered_by__C, Person__r.id, Person__r.Gender__c, Person__r.First_Name__c, Person__r.Last_Name__c from Farmer__c where Registered_by__C in :personIds and Person__r.First_Name__c<>'Not Registered'  limit 10000];

    MetricDataWrapper farmersReachedMetricWrapper = new MetricDataWrapper();
    farmersReachedMetricWrapper.setLabel('Total Farmers Reached');
    farmersReachedMetricWrapper.setCurrentRealValue(0);


    MetricDataWrapper maleFarmersReachedMetricWrapper = new MetricDataWrapper();
    maleFarmersReachedMetricWrapper.setLabel('Total Male Farmers Reached');
    maleFarmersReachedMetricWrapper.setCurrentRealValue(0);


    MetricDataWrapper femaleFarmersReachedMetricWrapper = new MetricDataWrapper();
    femaleFarmersReachedMetricWrapper.setLabel('Total Female Farmers Reached');
    femaleFarmersReachedMetricWrapper.setCurrentRealValue(0);

    Decimal totalFarmerCount = 0;
    Decimal totalMaleFarmerCount = 0;
    Decimal totalFemaleFarmerCount = 0;

    for(Farmer__c farmer : farmersRegisteredByMbugoCkws)
    {
        totalFarmerCount += 1;

        if('male'.equalsIgnoreCase(farmer.Person__r.Gender__c))
        {
            totalMaleFarmerCount += 1;
        }
        else {
            totalFemaleFarmerCount += 1;
        }
    }

    farmersReachedMetricWrapper.setCurrentRealValue(totalFarmerCount);
    maleFarmersReachedMetricWrapper.setCurrentRealValue(totalMaleFarmerCount);
    femaleFarmersReachedMetricWrapper.setCurrentRealValue(totalFemaleFarmerCount);

    List<MetricDataWrapper> wrapper = new List<MetricDataWrapper> {farmersReachedMetricWrapper, maleFarmersReachedMetricWrapper, femaleFarmersReachedMetricWrapper};
    
    return wrapper;
    }


    //Attempts to create missing metic datas
public void getAllMetricDatas()
{
    for(String metricName : getMetricNames())
    {
     getMetricData(metricName);   
    }
}


    public static M_E_Metric_Data__c getMetricData(String metricName) {
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
    
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
                  
        ];


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




    public enum SubmissionType { MBUGO_ACE_SURVEY, MBUGO_VSLA_ASSESSMENT_SURVEY, NONE }



    /**
    *  Post-processing method for MBUGO surveys that affect dashboard indicators
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
        System.debug('Survey is '+survey);
        if(survey.Survey_Name__c.containsIgnoreCase('Mbugo ACE')) {
            type = SubmissionType.MBUGO_ACE_SURVEY;
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('Mbugo VSLA')){
            type = SubmissionType.MBUGO_VSLA_ASSESSMENT_SURVEY;
        }
        else {
            type = SubmissionType.NONE;
            // someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '0', 'MBUGO post-processing irrelevant for submission from IMEI: ' 
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
            if(type == SubmissionType.MBUGO_ACE_SURVEY){
                
                metricNames = new List<String> { 
                    NUMBER_OF_COOPERATIVES_REGISTERED,
                    PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE
                };
                
                String agroInputsUsage = answers.get('q12_0').Answer__c;
                
                // Loop through the list of metrics and check that they all exist and then update them
                for (String key : metricNames) {
                    M_E_Metric_Data__c totalNewData = getMetricData(key);
                    // Update the metric based on the key
                    if (key.equals(NUMBER_OF_COOPERATIVES_REGISTERED)) {
                        //Increament this metric data
                        totalNewData.Manual_Value__c += 1;
                    }
                    else if (key.equals(PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE)) {
                        //If the Agro inputs section is selected
                        if(agroInputsUsage.contains('4'))
                        {
                            totalNewData.Manual_Value__c += 1;    
                        }
                        
                    }
            
                    dataMap.put(key, totalNewData);
                }
            }
            else if(type == SubmissionType.MBUGO_VSLA_ASSESSMENT_SURVEY){
                
                metricNames = new List<String> { 
                    NUMBER_OF_VSLAS_REGISTERED,
                    TOTAL_NUMBER_OF_FARMERS_IN_VSLAS,
                    TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS,
                    TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS
                };
                
                String totalFarmersInVslas = answers.get('q24_0').Answer__c;
                String totalMaleFarmersInVslas = answers.get('q22_0').Answer__c;
                String totalFemaleFarmersInVslas = answers.get('q23_0').Answer__c;
                
                // Loop through the list of metrics and check that they all exist and then update them
                for (String key : metricNames) {
                    M_E_Metric_Data__c totalNewData = getMetricData(key);
                    // Update the metric based on the key
                    if (key.equals(NUMBER_OF_VSLAS_REGISTERED)) {
                        //Increament this metric data
                        totalNewData.Manual_Value__c += 1;
                    }
                    else if (key.equals(TOTAL_NUMBER_OF_FARMERS_IN_VSLAS)) {
                        
                            totalNewData.Manual_Value__c += Integer.valueOf(totalFarmersInVslas);    
                    }
                    else if (key.equals(TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS)) {
                        
                            totalNewData.Manual_Value__c += Integer.valueOf(totalMaleFarmersInVslas);    
                    }
                    else if (key.equals(TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS)) {
                        
                            totalNewData.Manual_Value__c += Integer.valueOf(totalFemaleFarmersInVslas);    
                    }
            
                    dataMap.put(key, totalNewData);
                }
            }
            
            List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
            for(Database.upsertResult result : uResults) {
                system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
            }
        }
        catch(Exception ex) {
            return new String[]{ '0', 'MBUGO submission FAILED due to: ' + ex.getMessage() 
                + '. Please correct your information and try again. IMEI: ' + submission.imei, 'PULSE' };
        }
        return new String[]{ '1', 'MBUGO submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }





    public static List<CkwPerformanceWrapper> getCkwPerfomanceData()
    {
        //Get mbugo ckw ids
        List<CkwPerformanceWrapper> wrapper = new List<CkwPerformanceWrapper>();

        Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'Mbugo CKWs\' and Person__r.Type__c=\'CKW\'');

        List<String> personIds = new List<String>();
        for(Person_Group_Association__c p : associations) {
            personIds.add(p.Person__r.Id);
        }

        AggregateResult[] mbugoCkwPerfomance = [
        select 
        CKW_c__r.Person__r.Id personId, 
        CKW_c__r.Person__r.First_Name__c fname, 
        CKW_c__r.Person__r.Last_Name__c lname, 
        sum(Farmers_Registered__c) farmersRegistered, 
        sum(Total_Searches__c) searches, 
        sum(Total_Surveys_Submitted__c) surveys 
        from 
        CKW_Performance_Review__c
        where CKW_c__r.Person__r.Id in: personIds 
        group by CKW_c__r.Person__r.Id, CKW_c__r.Person__r.First_Name__c, CKW_c__r.Person__r.Last_Name__c
        ];

        for(AggregateResult aggResult : mbugoCkwPerfomance)
        {
            CkwPerformanceWrapper thisWrapper = new CkwPerformanceWrapper();
            thisWrapper.name = aggResult.get('fname') + ' ' + aggResult.get('lname');
            thisWrapper.farmerRegistrations = (Decimal) aggResult.get('farmersRegistered');
            thisWrapper.searches = (Decimal) aggResult.get('searches');
            thisWrapper.surveys = (Decimal) aggResult.get('surveys');
            wrapper.add(thisWrapper);
        }
        return wrapper;
    }



    public static MetricMapWrapper[] getFOMapMarkers()
    {
    	//Field officers
    	Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
            Mbugo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Mbugo_Field_Officer__C];
            for (Mbugo_Field_Officer__c fo : fieldOfficers) {

                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('CKW', '00FF11', fo.Person__r.Id, true);
                marker.gpsLatitude = fo.Person__r.GPS_Location_N__c;
                marker.gpsLongitude = fo.Person__r.GPS_Location_E__c;
                
                
                String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: '+fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c+'<br/>';
                    //Show CKWs under this field officer
                    Mbugo_CKW__c[] mbugoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Mbugo_CKW__c where Mbugo_Field_Officer__r.Person__r.Id =:fo.Person__r.Id];
                    if(mbugoCkws.size() == 0) {
                        profile += 'Field officer has no CKWs attached';
                    }
                    else {
                        profile += '<hr><b>Ckws attached to FO</b><br/>';
                        for (Mbugo_CKW__c gckw : mbugoCkws) {
                            profile += gckw.Person__r.First_Name__c + ' '+ gckw.Person__r.Last_Name__c +'<br/>';

                        }
                    }
                    profile += '</div>';
                
                marker.addName(profile);
                marker.markerTitle = fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c;
                markers.put(fo.Person__r.Id, marker);
            }

            return markers.values();
    }



    public static MetricMapWrapper[] getCKWMapMarkers()
    {
      Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
      Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c,  Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'Mbugo Ckws\' and Person__r.Type__c=\'CKW\'');
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


            
            System.debug(markers.size()+' map markers found'); 
            return markers.values();
    }

    public class CkwPerformanceWrapper
    {
        public String name { get; set; }
        public Decimal  farmerRegistrations { get; set; }
        public Decimal  searches { get; set; }
        public Decimal  surveys { get; set; }
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