public with sharing class QualitySurveysMonthlyMetricCalculator {

    @future(callout=true)
    public static void updateQualitySurveyMetric() {
        Date startDate = date.today().addMonths(-1);
        Date endDate = startDate.addMonths(1);
        M_E_Metric_Data__c[] metricDatas = [Select Numerator__c,
                                                    Denumerator__c,
                                                    Actual_Value__c
                                            from 
                                                M_E_Metric_Data__c 
                                            where 
                                                Date__c=THIS_MONTH
                                            AND 
                                                M_E_Metric__r.Name ='% of quality surveys conducted' 
                                            order by date__c desc];
        M_E_Metric_Data__c metricData = null;   
        if (metricDatas.size() > 0) {
            metricData = metricDatas[0];
        }
        else {
            M_E_Metric__c metric = [Select id from M_E_Metric__c where Name ='% of quality surveys conducted'];
            metricData = new M_E_Metric_Data__c();
            metricData.M_E_Metric__c = metric.Id;
            metricData.Date__c = date.today();
        }
        String surveyQuery =
            'SELECT ' +
                'sum(case when submissions.survey_status=\'Approved\' then 1 else 0 end) as Approved, ' +
                'sum(case when submissions.survey_status=\'Pending\' then 1 else 0 end) as Pending, ' +
                'sum(case when submissions.survey_status=\'Rejected\' then 1 else 0 end) as Rejected, ' +
                'sum(case when submissions.survey_status=\'Not Reviewed\' then 1 else 0 end) as NotReviewed, ' +
                'sum(case when submissions.survey_status=\'Duplicate\' then 1 else 0 end) as Duplicates ' +
            'FROM ' + 
                'zebra.zebrasurveysubmissions submissions INNER JOIN ' +
                'zebra.zebrasurvey surveys ' + 
                'ON submissions.survey_id = surveys.id ' +
            'WHERE ' +
                'submissions.handset_submit_time &gt;= \'' + SqlHelpers.formatDate(startDate) + '\' ' + 
                'AND submissions.handset_submit_time &lt; \'' + SqlHelpers.formatDate(endDate) + '\' ';

        String requestBody = constructRequestXml('Surveys', surveyQuery);
        System.debug(requestBody);
        String queryResult = SqlHelpers.postServletRequest('http://ckwapps.applab.org:8888/services/', 'select', requestBody);
        System.debug(queryResult);
        parseSurveyResults(queryResult, metricData);
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
            Integer rejectedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer notReviewedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer duplicateSurveys = Integer.valueOf(parseElement(surveyResultReader));
            
            System.debug('approved surveys='+approvedSurveys + ' Not Reviewed='+notReviewedSurveys);
            metricData.Numerator__c = approvedSurveys + pendingSurveys + notReviewedSurveys;
            metricData.Denumerator__c = approvedSurveys + pendingSurveys + notReviewedSurveys + rejectedSurveys;
            Decimal percentageNonRejected = 100*(metricData.Numerator__c/metricData.Denumerator__c);
            metricData.Actual_Value__c = percentageNonRejected;
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