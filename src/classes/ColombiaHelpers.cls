public with sharing class ColombiaHelpers {

    public static Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();

    public static List<String> processDailyRainGauge(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter, Person__c interviewee) {

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }

         Submission_Answer__c premAnswer = answers.get('q64_0');
         Integer premQty = 0;
         if (premAnswer != null) {
             premQty = Integer.valueOf(premAnswer.Answer__c);
         }

         Submission_Answer__c medAnswer = answers.get('q65_0');
         Integer medQty = 0;
         if (medAnswer != null) {
             medQty = Integer.valueOf(medAnswer.Answer__c);
         }

         Submission_Answer__c badAnswer = answers.get('q66_0');
         Integer badQty = 0;
         if (badAnswer != null) {
             badQty = Integer.valueOf(badAnswer.Answer__c);
         }

        Integer totalGrain = premQty + medQty + badQty;

        // Get the metric data for this interviewee
        List<String> metricNames = new List<String> { 'CO1_percent_good_qual_grain', 'CO1_percent_med_qual_grain', 'CO1_percent_bad_qual_grain' };

        // Change to use handset submit not current date
        String dateString = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(dateString);
        Date endDate = MetricHelpers.getQuarterLastDay(dateString);

        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Person__c,
                Numerator__c,
                Denumerator__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                (
                    (District__c = null AND Person__c = null)
                    OR Person__c = :interviewee.Id
                )
                AND Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN ('CO1_percent_good_qual_grain', 'CO1_percent_med_qual_grain', 'CO1_percent_bad_qual_grain')
        ];

        // Loop through the datas and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {

            // Check to see if it is the person, district or country wide metric
            if (mData.Person__c == null && mData.District__c == null) {
                dataMap.put(mData.M_E_Metric__r.Name, mData);
            }
            else {
                dataMap.put(mData.M_E_Metric__r.Name + '_#@#@#_' + interviewee.Id, mData);
            }
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            M_E_Metric_Data__c personNewData = dataMap.get(key + '_#@#@#_' + submitter.Id);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, startDate, submitter, 'none');
            }
            if (personNewData == null) {
                personNewData = createNewMetric(key, startDate, submitter, 'person');
            }

            totalNewData.Denumerator__c += totalGrain;
            personNewData.Denumerator__c += totalGrain;

            // Update the metric based on the key
            if (key.equals('CO1_percent_good_qual_grain')) {
                    totalNewData.Numerator__c += premQty;
                    personNewData.Numerator__c += premQty;
            }
            else if (key.equals('CO1_percent_med_qual_grain')) {
                    totalNewData.Numerator__c += medQty;
                    personNewData.Numerator__c += medQty;
            }
            else if (key.equals('CO1_percent_bad_qual_grain')) {
                    totalNewData.Numerator__c += badQty;
                    personNewData.Numerator__c += badQty;
            }
            dataMap.put(key, totalNewData);
            dataMap.put(key + '_#@#@#_' + submitter.Id, personNewData);
        }

        Database.upsert(dataMap.values());
        return new String[] { '1', 'All metric datas updated for farmer with id: ' + interviewee.id, 'SUPRESSMSG' };
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
}