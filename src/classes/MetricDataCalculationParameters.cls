global class MetricDataCalculationParameters {

    private String metricGeneralName;
    private String questionType;
    private String function;
    private String binding;
    private String selectBindings;
    private Survey__c survey;
    private List<String> groupList;

    global MetricDataCalculationParameters(
            String metricGeneralName,
            String questionType,
            String function,
            String binding,
            Survey__c survey,
            List<String> groupList
    ) {
        this.metricGeneralName = metricGeneralName;
        this.questionType = questionType;
        this.function = function;
        this.binding = binding;
        this.survey = survey;
        this.groupList = groupList;
        this.selectBindings = null;
    }

    public String getMetricGeneralName() {
        return this.metricGeneralName;
    }

    public String getQuestionType() {
        return this.questionType;
    }

    public String getFunction() {
        return this.function;
    }

    public String getBinding() {
        return this.binding;
    }

    public Survey__c getSurvey() {
        return this.survey;
    }

    public List<String> getGroupList() {
        return this.groupList;
    }

    public String getSelectOptions() {
        return this.selectBindings;
    }

    public void setSelectOptions(String options) {
        this.selectBindings = options;
    }

    static testMethod void testConstruction() {

        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'hello';
        database.insert(survey);
        List<String> groupList = new List<String>();
        groupList.add('District__r.Name');

        MetricDataCalculationParameters param = new MetricDataCalculationParameters('Me', 'You', 'Them', 'Someone', survey, groupList);
        System.assert(param.getMetricGeneralName().equals('Me'));
        System.assert(param.getQuestionType().equals('You'));
        System.assert(param.getFunction().equals('Them'));
        System.assert(param.getBinding().equals('Someone'));
        System.assert(param.getSurvey().Survey_Name__c.equals('hello'));
        System.assert(param.getGroupList().get(0).equals('District__r.Name'));
    }
}