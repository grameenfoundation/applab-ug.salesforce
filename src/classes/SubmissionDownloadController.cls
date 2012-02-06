public class SubmissionDownloadController {

    private ParseSurveyXml parsedSurvey;

    Transient List<Submission> submissions = new List<Submission>();

    private Integer notReviewedSurveys { get; set; }
    private Integer pendingSurveys { get; set; }
    private Integer rejectedSurveys { get; set; }
    private Integer approvedSurveys { get; set; }
    private Integer flaggedSurveys { get; set; }
    public String csvData { get; set; }
    public String excelData { get; set; }
    public String fileName { get; set; }

    public SubmissionDownloadController() {

        // Load the survey
        this.parsedSurvey = new ParseSurveyXml(ApexPages.currentPage().getParameters().get('surveyName').replace('\'','')); // The surveyName is quoted
        this.parsedSurvey.parseSurveyXml();
    }

    public PageReference getData() {

        // Check that the parsing went ok
        if (!this.parsedSurvey.getErrorMessage().equals('Success')) {

            // There is no survey here so redirect back to the controller
            return redirectPage(this.parsedSurvey.getErrorMessage());
        }

        // Get the submissions that match the search made. We are going to batch this so we can pull out the answers with out hitting limits
        List<String> submissionIds = new List<String>();
        for (Submission_Meta_Data__c[] dataObjects : database.query(SoqlHelpers.getSubmissions(ApexPages.currentPage().getParameters()))) {
            for(Submission_Meta_Data__c data : dataObjects) {
                submissionIds.add((String)data.Id);
            }
        }

        if (submissionIds.size() > 0) {

            // Do the last batch
            Map<String, String> var = new Map<String, String>{ 'submissionIds' => MetricHelpers.generateCommaSeperatedString(submissionIds, true) };
            createSubmissionsBatch(var);
            submissionIds.clear();

            if(ApexPages.currentPage().getParameters().get('dataType') == 'xls') {
                String data = generateHtmlTable();
                System.debug(LoggingLevel.DEBUG, data);
                this.excelData = data;
                this.fileName = this.parsedSurvey.getSurvey().Name;
            }
            else {
                String data = generateCsv();
                System.debug(LoggingLevel.DEBUG, data);
                this.csvData = data;
                this.fileName = this.parsedSurvey.getSurvey().Name;
            }
            return null;
        }
        else {
            return redirectPage('3');
        }
    }

    private void createSubmissionsBatch(Map<String, String> submissionIds) {

        Submission newSubmission = null;
        String submissionName = '';
        Boolean omitInterviewee = this.parsedSurvey.getSurvey().Allow_No_Interviewee__c;
        String surveyName = this.parsedSurvey.getSurvey().Name;
        List<String> orderByClause = new List<String> { 'Submission_Meta_Data__r.Name' };
        for (Submission_Answer__c[] answers : database.query(SoqlHelpers.getSubmissionAnswers(submissionIds, orderByClause))) {
            for (Submission_Answer__c answer : answers) {
                if (!answer.Submission_Meta_Data__r.Name.equals(submissionName)) {
                    if (newSubmission != null) {
                        submissions.add(newSubmission);
                    }
                    newSubmission = new Submission(
                        answer.Submission_Meta_Data__r.Name,
                        answer.Submission_Meta_Data__r.Interviewer__r.Name,
                        answer.Submission_Meta_Data__r.Interviewer__r.First_Name__c,
                        answer.Submission_Meta_Data__r.Interviewer__r.Last_Name__c,
                        answer.Submission_Meta_Data__r.Interviewer__r.Gender__c,
                        answer.Submission_Meta_Data__r.Interviewer__r.District__r.Name,
                        answer.Submission_Meta_Data__r.Interviewer__r.Subcounty__r.Name,
                        answer.Submission_Meta_Data__r.Interviewee__r.Name,
                        answer.Submission_Meta_Data__r.Interviewee__r.First_Name__c,
                        answer.Submission_Meta_Data__r.Interviewee__r.Last_Name__c,
                        answer.Submission_Meta_Data__r.Interviewee__r.Gender__c,
                        answer.Submission_Meta_Data__r.Interviewee__r.Parish__c,
                        surveyName,
                        answer.Submission_Meta_Data__r.Handset_Submit_Time__c.format(),
                        String.valueOf(answer.Submission_Meta_Data__r.Interview_Latitude__c),
                        String.valueOf(answer.Submission_Meta_Data__r.Interview_Longitude__c),
                        answer.Submission_Meta_Data__r.CreatedDate.format(),
                        answer.Submission_Meta_Data__r.Data_Collection_Review_Status__c,
                        answer.Submission_Meta_Data__r.Customer_Care_Review_Status__c,
                        omitInterviewee,
                        false
                    );

                    submissionName = answer.Submission_Meta_Data__r.Name;
                }
                newSubmission.addAnswer(
                    answer.Answer__c,
                    answer.Binding__c,
                    answer.Question_Text__c,
                    answer.Instance__c
                );

                // Check that the instance count for this question is not greater than an already recorded instance
                this.parsedSurvey.checkQuestionInstance(answer.Instance__c, answer.Binding__c);
            }
        }
        submissions.add(newSubmission);
    }

    private String generateHtmlTable() {

        String tableString = '<table>';
        tableString = tableString + this.parsedSurvey.generateHtmlTableRow();
        for (Submission submission : this.submissions) {
            tableString = tableString + submission.generateHtmlTableRow(this.parsedSurvey);
        }
        this.submissions.clear();
        tableString += '</table>';
        return tableString;
    }

    public PageReference redirectPage(String errorMessage) {

        PageReference newPage = Page.SubmissionSelector;
        newPage.getParameters().put('surveysParam', ApexPages.currentPage().getParameters().get('surveyName'));
        newPage.getParameters().put('errorCode', errorMessage);
        newPage.setRedirect(true);
        return newPage;
    }

    private String generateCsv() {

        String csvString = this.parsedSurvey.generateCsv() + '\r\n';
        for (Submission submission : this.submissions) {
            csvString += submission.generateCsvString(this.parsedSurvey) + '\r\n';
        }
        this.submissions.clear();
        return csvString;
    }

    public static testMethod void testCsvController() {

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

        // Create a CKW
        CKW__c ckw1 = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw1);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw1.Person__c;
        database.insert(farmer1);
        Poverty_Scorecard__c  povertyScorecard1 = Utils.createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);

        // Create some test submissions
        Date startDate = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Time startTime = time.newInstance(12, 30, 30, 0);
        DateTime submissionDateTime = datetime.newInstance(startDate.addDays(15), startTime);
        List<Submission_Meta_Data__c> submissions = new List<Submission_Meta_Data__c>();
        for (Integer i = 0; i < 10; i++) {
            Submission_Meta_Data__c sub = Utils.createTestSubmission(ckw1.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub' + i);
            submissions.add(sub);
        }
        database.insert(submissions);

        // Add some answers to submissions
        List<Submission_Answer__c> answers = new List<Submission_Answer__c>();
        for (Integer i = 0; i < 10; i++) {
            Submission_Answer__c answer1 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q1', 'yes', 'Input', 'qestion1', 0);
            answers.add(answer1);
            Submission_Answer__c answer2 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q2', '1 3', 'Select', 'qestion2', 0);
            answers.add(answer2);
            Submission_Answer__c answer3 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q3', 'yes', 'Input', 'qestion3', 0);
            answers.add(answer3);
            Submission_Answer__c answer4 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q5', 'yes', 'Input', 'qestion4', 0);
            answers.add(answer4);
            Submission_Answer__c answer5 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q6', 'yes', 'Input', 'qestion5', 0);
            answers.add(answer5);
        }
        database.insert(answers);

        PageReference pageRefCsv = Page.SubmissionCsvPage;
        pageRefCsv.getParameters().put('dataType', 'csv');
        pageRefCsv.getParameters().put('surveyName', '\'' + survey2.Name + '\'');
        pageRefCsv.getParameters().put('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate.addDays(-2)), false));
        pageRefCsv.getParameters().put('submissionEndDateDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate.addDays(2)), false));
        Test.setCurrentPageReference(pageRefCsv);
        Test.startTest();
        SubmissionDownloadController controller = new SubmissionDownloadController();
        controller.getData();
    }

    public static testMethod void testExcelController() {

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

        // Create a CKW
        CKW__c ckw1 = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw1);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw1.Person__c;
        database.insert(farmer1);
        Poverty_Scorecard__c  povertyScorecard1 = Utils.createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);

        // Create some test submissions
        Date startDate = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Time startTime = time.newInstance(12, 30, 30, 0);
        DateTime submissionDateTime = datetime.newInstance(startDate.addDays(15), startTime);
        List<Submission_Meta_Data__c> submissions = new List<Submission_Meta_Data__c>();
        for (Integer i = 0; i < 10; i++) {
            Submission_Meta_Data__c sub = Utils.createTestSubmission(ckw1.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub' + i);
            submissions.add(sub);
        }
        database.insert(submissions);

        // Add some answers to submissions
        List<Submission_Answer__c> answers = new List<Submission_Answer__c>();
        for (Integer i = 0; i < 10; i++) {
            Submission_Answer__c answer1 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q1', 'yes', 'Input', 'qestion1', 0);
            answers.add(answer1);
            Submission_Answer__c answer2 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q2', '1 3', 'Select', 'qestion2', 0);
            answers.add(answer2);
            Submission_Answer__c answer3 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q3', 'yes', 'Input', 'qestion3', 0);
            answers.add(answer3);
            Submission_Answer__c answer4 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q5', 'yes', 'Input', 'qestion4', 0);
            answers.add(answer4);
            Submission_Answer__c answer5 = Utils.createTestSubmissionAnswer(submissions.get(i).Id, 'q6', 'yes', 'Input', 'qestion5', 0);
            answers.add(answer5);
        }
        database.insert(answers);
        PageReference pageRefExcel = Page.SubmissionExcelExport;
        pageRefExcel.getParameters().put('dataType', 'xls');
        pageRefExcel.getParameters().put('surveyName', '\'' + survey2.Name + '\'');
        pageRefExcel.getParameters().put('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate.addDays(-2)), false));
        pageRefExcel.getParameters().put('submissionEndDateDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate.addDays(2)), false));
        Test.setCurrentPageReference(pageRefExcel);
        Test.startTest();
        SubmissionDownloadController controller = new SubmissionDownloadController();
        controller.getData();
    }
}