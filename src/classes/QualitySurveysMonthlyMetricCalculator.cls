public with sharing class QualitySurveysMonthlyMetricCalculator {

	private static String surveyDatabase;
	private static String serverUrl;

	public QualitySurveysMonthlyMetricCalculator() {
		initializeServerConstants();
	}

	@future(callout=true)
	public static void updateQualitySurveyMetric() {
		Date startDate = date.today().toStartOfMonth();
		Date endDate = startDate.addMonths(1);
        String surveyQuery =
            'SELECT ' +
                'submissions.interviewer_id, ' +
                'surveys.survey_id, ' +
                'sum(case when submissions.survey_status=\'Approved\' then 1 else 0 end) as Approved, ' +
                'sum(case when submissions.survey_status=\'Rejected\' then 1 else 0 end) as Rejected, ' +
                'sum(case when submissions.survey_status=\'Pending\' then 1 else 0 end) as Pending, ' +
                'sum(case when submissions.survey_status=\'Not Reviewed\' then 1 else 0 end) as NotReviewed, ' +
                'sum(case when submissions.survey_status=\'Duplicate\' then 1 else 0 end) as Duplicates ' +
            'FROM ' + 
                surveyDatabase + '.zebrasurveysubmissions submissions INNER JOIN ' +
                'zebra.zebrasurvey surveys ' + 
                'ON submissions.survey_id = surveys.id ' +
            'WHERE ' +
                'submissions.handset_submit_time &gt;= \'' + SqlHelpers.formatDate(startDate) + '\' ' + 
                'AND submissions.handset_submit_time &lt; \'' + SqlHelpers.formatDate(endDate) + '\' ' +
                'AND submissions.interviewer_id != \'\' ';

        String requestBody = constructRequestXml('Surveys', surveyQuery); 
        String queryResult = SqlHelpers.postServletRequest(serverUrl, 'select', requestBody);
        System.debug(queryResult);
	}

    private static void initializeServerConstants() {

        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];
        serverUrl = configuration.URL__c;
        surveyDatabase = configuration.Survey_Database__c;
    }

	private static String constructRequestXml(String target, String query) {
        String requestBody = '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="' + target + '">' +
            query + '</SelectRequest>';
        return requestBody;
    }
}