public with sharing class Submission {

    private Map<String, SubmissionAnswer> answers;

    private String submissionId;
    private String interviewerName;
    private String interviewerFirstName;
    private String interviewerLastName;
    private String interviewerGender;
    private String interviewerDistrict;
    private String interviewerSubCounty;

    private String intervieweeName;
    private String intervieweeFirstName;
    private String intervieweeLastName;
    private String intervieweeGender;
    private String intervieweeParish;

    private String surveyName;
    private String handsetSubmitTime;
    private String latitude;
    private String longitude;
    private String serverEntryTime;

    private String dataCollectionStatus;
    private String customerCareStatus;

    private Boolean omitInterviewee;
    private Boolean translateOptions;

    public Submission (
        String submissionId,
        String interviewerName,
        String interviewerFirstName,
        String interviewerLastName,
        String interviewerGender,
        String interviewerDistrict,
        String interviewerSubCounty,
        String intervieweeName,
        String intervieweeFirstName,
        String intervieweeLastName,
        String intervieweeGender,
        String intervieweeParish,
        String surveyName,
        String handsetSubmitTime,
        String latitude,
        String longitude,
        String serverEntryTime,
        String dataCollectionStatus,
        String customerCareStatus,
        Boolean omitInterviewee,
        Boolean translateOptions
    ) {
        this.answers = new Map<String, SubmissionAnswer>();
        this.submissionId = submissionId;
        this.interviewerName = interviewerName;
        this.interviewerFirstName = interviewerFirstName;
        this.interviewerLastName = interviewerLastName;
        this.interviewerGender = interviewerGender;
        this.interviewerDistrict = interviewerDistrict;
        this.interviewerSubCounty = interviewerSubCounty;
        this.intervieweeName = intervieweeName;
        this.intervieweeFirstName = intervieweeFirstName;
        this.intervieweeLastName = intervieweeLastName;
        this.intervieweeGender = intervieweeGender;
        this.intervieweeParish = intervieweeParish;
        this.surveyName = surveyName;
        this.handsetSubmitTime = handsetSubmitTime;
        this.latitude = latitude;
        this.longitude = longitude;
        this.serverEntryTime = serverEntryTime;
        this.dataCollectionStatus = dataCollectionStatus;
        this.customerCareStatus = customerCareStatus;
        this.omitInterviewee = omitInterviewee;
        this.translateOptions = translateOptions;
    }

    public void addAnswer(
            String answer,
            String binding,
            String questionText,
            Decimal instance
    ) {

        this.answers.put(createAnswerKey(binding, String.valueOf(instance)), new SubmissionAnswer(answer, binding, questionText, instance));
    }

    private String createAnswerKey(String binding, String instance) {
        return binding + '@#@' + instance;
    }

    private SubmissionAnswer getAnswer(String binding, String instance) {
        return this.answers.get(createAnswerKey(binding, instance));
    }

    public String generateHtmlTableRow(ParseSurveyXml survey) {

        // Add the standard field first
        String data = '<tr><td>' + this.surveyName + '</td>'
            + '<td>' + this.submissionId + '</td>'
            + '<td>' + this.serverEntryTime + '</td>'
            + '<td>' + this.handsetSubmitTime + '</td>'
            + '<td>' + this.latitude + '</td>'
            + '<td>' + this.longitude + '</td>'
            + '<td>' + this.interviewerName + '</td>'
            + '<td>' + this.interviewerFirstName + '</td>'
            + '<td>' + this.interviewerLastName + '</td>'
            + '<td>' + this.interviewerGender + '</td>'
            + '<td>' + this.interviewerDistrict + '</td>'
            + '<td>' + this.interviewerSubCounty + '</td>'
            + '<td>' + this.dataCollectionStatus + '</td>'
            + '<td>' + this.customerCareStatus + '</td>';
        if (!this.omitInterviewee) {
            data = data + '<td>' + this.intervieweeName + '</td>'
                + '<td>' + this.intervieweeFirstName + '</td>'
                + '<td>' + this.intervieweeLastName + '</td>'
                + '<td>' + this.intervieweeGender + '</td>'
                + '<td>' + this.intervieweeParish + '</td>';
        }

        // Loop through the questions on the survey
        for (String questionName : survey.getQuestionOrder()) {
            SurveyQuestion question = survey.getQuestion(questionName);
            Integer instanceNumber = question.getTotalInstances().intValue();
            for (Integer i = 0; i <= instanceNumber; i++) {

                // See if this submission has an answer for this question instance
                SubmissionAnswer answer = getAnswer(questionName, String.valueOf(i));
                if (answer == null) {
                    if (question.getQuestionType().equals('Select')) {
                        Integer numberOfOptions = question.getNumberOfOptions();
                        for (Integer j = 0; j < numberOfOptions; j++) {
                            data = data + '<td>' + '[No Answer]</td>';
                        }
                    }
                    else {
                        data = data + '<td>' + '[No Answer]</td>';
                    }
                }
                else {
                    if (question.getQuestionType().equals('Select')) {
                        Integer numberOfOptions = question.getNumberOfOptions();
                        for (Integer j = 1; j <= numberOfOptions; j++) {
                            if (answer.checkHasSelectOption(String.valueOf(j))) {
                                data = data + '<td>' + DocumentHelpers.escapeAnswerText(String.valueOf(j)) + '</td>';
                            }
                            else {
                                data = data + '<td>' + '[No Answer]</td>';
                            }
                        }
                    }
                    else {
                        data = data + '<td>' + DocumentHelpers.escapeAnswerText(answer.getAnswerText()) + '</td>';
                    }
                }
            } 
        }
        data += '</tr>';
        return data;
    }

    public String generateCsvString(ParseSurveyXml survey) {

        // Add the standard field first
        String csv = this.surveyName + ','
            + this.submissionId + ','
            + this.serverEntryTime + ','
            + this.handsetSubmitTime + ','
            + this.latitude + ','
            + this.longitude + ','
            + this.interviewerName + ','
            + this.interviewerFirstName + ','
            + this.interviewerLastName + ','
            + this.interviewerGender + ','
            + this.interviewerDistrict + ','
            + this.interviewerSubCounty + ','
            + this.dataCollectionStatus + ','
            + this.customerCareStatus + ',';
        if (!this.omitInterviewee) {
            csv = csv + this.intervieweeName + ','
                + this.intervieweeFirstName + ','
                + this.intervieweeLastName + ','
                + this.intervieweeGender + ','
                + this.intervieweeParish + ',';
        }

        // Loop through the questions on the survey
        for (String questionName : survey.getQuestionOrder()) {
            SurveyQuestion question = survey.getQuestion(questionName);
            Integer instanceNumber = question.getTotalInstances().intValue();
            for (Integer i = 0; i <= instanceNumber; i++) {

                // See if this submission has an answer for this question instance
                SubmissionAnswer answer = getAnswer(questionName, String.valueOf(i));
                Integer numberOfOptions = question.getNumberOfOptions();
                if (answer == null) {
                    if (question.getQuestionType().equals('Select')) {
                        for (Integer j = 0; j < numberOfOptions; j++) {
                            csv = csv + '[No Answer],';
                        }
                    }
                    else {
                        csv = csv + '[No Answer],';
                    }
                }
                else {
                    if (question.getQuestionType().equals('Select')) {
                        for (Integer j = 1; j <= numberOfOptions; j++) {
                            if (answer.checkHasSelectOption(String.valueOf(j))) {
                                csv = csv + DocumentHelpers.escapeAnswerText(String.valueOf(j)) + ',';
                            }
                            else {
                                csv = csv + '[No Answer],';
                            }
                        }
                    }
                    else {
                        csv = csv + DocumentHelpers.escapeAnswerText(answer.getAnswerText()) + ',';
                    }
                }
            } 
        }
        return csv;
    }

    class SubmissionAnswer {
        private String answer;
        private String binding;
        private String questionText;
        private Decimal instance;
        private Set<String> selectSet;

        public SubmissionAnswer(
            String answer,
            String binding,
            String questionText,
            Decimal instance
        ) {
            this.answer = answer;
            this.binding = binding;
            this.questionText = questionText;
            this.instance = instance;
            this.selectSet = null;
        }

        public Boolean checkHasSelectOption(String option) {
            if (this.selectSet == null) {
                this.selectSet = new Set<String>();
                this.selectSet.addAll(this.answer.split(' '));
            }
            return selectSet.contains(option);
        }

        public String getAnswerText() {
            return this.answer;
        }
    }

    public static testMethod void testSubmission() {

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        String content = '<h:html xmlns:h="http://www.w3.org/1999/xhtml" xmlns:jr="http://openrosa.org/javarosa" xmlns="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><h:head><h:title ref="jr:itext(\'test_salesforce_parsing\')">Test Salesforce Parsing</h:title><model><instance id="test_salesforce_parsing"><test_salesforce_parsing name="Test Salesforce Parsing" id="2011070138"><q1/><q2/><q3/><q4><q5/><q6/></q4></test_salesforce_parsing></instance><bind id="q1" nodeset="/test_salesforce_parsing/q1" type="xsd:string"/><bind id="q2" nodeset="/test_salesforce_parsing/q2" type="xsd:string"/><bind id="q3" nodeset="/test_salesforce_parsing/q3" type="xsd:string"/><bind id="q4" nodeset="/test_salesforce_parsing/q4"/><bind id="q5" nodeset="/test_salesforce_parsing/q4/q5" type="xsd:string"/><bind id="q6" nodeset="/test_salesforce_parsing/q4/q6" type="xsd:string"/><itext><translation lang="en" lang-name="English"><text id="test_salesforce_parsing"><value>Test Salesforce Parsing</value></text><text id="page1"><value>Page1</value></text><text id="name"><value>Name</value></text><text id="gender"><value>Gender</value></text><text id="male"><value>Male</value></text><text id="female"><value>Female</value></text><text id="crops"><value>Crops</value></text><text id="beans"><value>Beans</value></text><text id="more_beans"><value>More Beans</value></text><text id="ha_bang_not_beans"><value>Ha! Not Beans</value></text><text id="some_details"><value>Some details</value></text><text id="what_is_your_best_option"><value>What is your best option?</value></text><text id="option1"><value>Option1</value></text><text id="option2"><value>Option2</value></text><text id="option3"><value>Option3</value></text><text id="tell_me_something"><value>Tell me something</value></text></translation></itext></model></h:head><h:body><group id="1"><label ref="jr:itext(\'page1\')"/><input bind="q1"><label ref="jr:itext(\'name\')"/></input><select1 bind="q2"><label ref="jr:itext(\'gender\')"/><item id="1"><label ref="jr:itext(\'male\')"/><value>1</value></item><item id="2"><label ref="jr:itext(\'female\')"/><value>2</value></item></select1><select bind="q3"><label ref="jr:itext(\'crops\')"/><item id="1"><label ref="jr:itext(\'beans\')"/><value>1</value></item><item id="2"><label ref="jr:itext(\'more_beans\')"/><value>2</value></item><item id="3"><label ref="jr:itext(\'ha_bang_not_beans\')"/><value>3</value></item></select><group id="q4"><label ref="jr:itext(\'some_details\')"/><repeat bind="q4"><select1 bind="q5"><label ref="jr:itext(\'what_is_your_best_option\')"/><item id="1"><label ref="jr:itext(\'option1\')"/><value>1</value></item><item id="2"><label ref="jr:itext(\'option2\')"/><value>2</value></item><item id="3"><label ref="jr:itext(\'option3\')"/><value>3</value></item></select1><input bind="q6"><label ref="jr:itext(\'tell_me_something\')"/></input></repeat></group></group></h:body></h:html>';
        String attachmentName = DocumentHelpers.createSurveyFileName(survey2.Name);
        List<String> createResults = DocumentHelpers.createNewAttachment(content, (String)survey.Id, attachmentName, null);
        System.assert(createResults.get(0).equals('1'));

        Submission submission = new Submission('submissionId',
            'Test',
            'Test First Name',
            'Test Last Name',
            'Male',
            'Kampala',
            'Kawempe',
            'Test Interviewee',
            'Test First Name Interviewee',
            'Test Last Name Interviewee',
            'intervieweeGender',
            'intervieweeParish',
            survey2.Name,
            '2011-07-01 00:00:00',
            '32.0',
            '1.0',
            '2011-07-01 00:00:00',
            'False',
            'False',
            true,
            false
        );

        submission.addAnswer( 'test',
            'test',
            'test',
            1);

        String csv = submission.generateCsvString(new ParseSurveyXml(survey2.Name));
        String htmlTableRow = submission.generateHtmlTableRow(new ParseSurveyXml(survey2.Name));
    }
}