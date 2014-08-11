public class AgrowaysFarmerGroupsReachedCalculator {
    @future(callout=true)
    public static void calculateFarmerGroupsReached() {
        Date startDate = MetricHelpers.getQuarterFirstDay(date.today());
        Date endDate = MetricHelpers.getQuarterLastDay(date.today());
        M_E_Metric_Data__c[] metricDatas = [Select Numerator__c,
                                                    Denumerator__c,
                                                    Actual_Value__c
                                            from 
                                                M_E_Metric_Data__c 
                                            where 
                                                Date__c =:startDate
                                            AND 
                                                M_E_Metric__r.Name ='Agroways Total Farmer Groups Reached' 
                                            order by date__c desc];
        M_E_Metric_Data__c metricData = null;   
        if (metricDatas.size() > 0) {
            metricData = metricDatas[0];
        }
        else {
            M_E_Metric__c metric = [Select id from M_E_Metric__c where Name ='Agroways Total Farmer Groups Reached'];
            metricData = new M_E_Metric_Data__c();
            metricData.M_E_Metric__c = metric.Id;
            metricData.Date__c = startDate;
        }
        String queryResult = '';
        if (Test.isRunningTest()) {
            queryResult = '<?xml version="1.0"?>' + 
                '<SelectResponse xmlns="http://schemas.applab.org/2010/07">' +
                '<row><Approved>0</Approved><Pending>0</Pending><NotReviewed>171</NotReviewed></row>' +
                '</SelectResponse>';
            parseSurveyResults(queryResult, metricData);
        }
        else {
            String surveyQuery =
                'SELECT ' +
                    'sum(case when submissions.survey_status=\'Approved\' then 1 else 0 end) as Approved, ' +
                    'sum(case when submissions.survey_status=\'Pending\' then 1 else 0 end) as Pending, ' +
                    'sum(case when submissions.survey_status=\'Not Reviewed\' then 1 else 0 end) as NotReviewed ' +
                'FROM ' + 
                    'zebra.zebrasurveysubmissions submissions ' +
                'WHERE ' +
                    'submissions.survey_id = ' + 1008 + ' AND ' +
                    'submissions.handset_submit_time &gt;= \'' + SqlHelpers.formatDate(startDate) + '\' ' + 
                    'AND submissions.handset_submit_time &lt; \'' + SqlHelpers.formatDate(endDate) + '\' ';

            String requestBody = constructRequestXml('Surveys', surveyQuery);
            System.debug(requestBody);
            queryResult = SqlHelpers.postServletRequest('http://ckwapps.applab.org:8888/services/', 'select', requestBody);
            System.debug(queryResult);
            parseSurveyResults(queryResult, metricData);
        }
    }

    private static String constructRequestXml(String target, String query) {
        String requestBody = '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="' + target + '">' +
            query + '</SelectRequest>';
        return requestBody;
    }
    
    private static void parseSurveyResults(String surveyResultXml, M_E_Metric_Data__c metricData) {
        XmlStreamReader surveyResultReader = new XmlStreamReader(surveyResultXml);
        surveyResultReader.next(); // skip the opening <results> tag
                
        while(surveyResultReader.hasNext()) {
            if(surveyResultReader.isStartElement()) {
                parseCkwSurveyRow(surveyResultReader, metricData);
            }
            surveyResultReader.next();
        }
    }

    private static void parseCkwSurveyRow(XmlStreamReader surveyResultReader, M_E_Metric_Data__c metricData) {
        if(surveyResultReader.getLocalName() == 'row') {
            surveyResultReader.next(); // skip the <row> tag

            Integer approvedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer pendingSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer notReviewedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            
            System.debug('approved surveys='+approvedSurveys + ' Not Reviewed='+notReviewedSurveys);
            metricData.Actual_Value__c = approvedSurveys + pendingSurveys + notReviewedSurveys;
            upsert(metricData); 
        }
    }
    
    private static String parseElement(XmlStreamReader reader) {
        reader.next(); // skip the opening <column> tag
        String result = reader.getText();
        reader.next(); // move on to the next element
        reader.next(); // skip the closing </column> tag
        return result;
    }
}