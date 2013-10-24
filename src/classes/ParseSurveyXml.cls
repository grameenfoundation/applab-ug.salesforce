public class ParseSurveyXml {

    private String surveyName;
    private String formType;
    private String errorMessage;

    private Map<String, SurveyQuestion> questions;
    private List<String> questionOrder;
    private Integer questionCount;

    private Survey__c surveySObject;

    private Map<String, TranslationMap> languageMap;

    public ParseSurveyXml (String surveyName) {

        this.surveyName = surveyName;
        this.questions = new Map<String, SurveyQuestion>();
        this.questionOrder = new List<String>();
        this.languageMap = new Map<String, TranslationMap>();
        this.questionCount = 1;
        this.formType = null;
        this.surveySObject = Utils.loadSurvey(surveyName);
    }

    public Survey__c getSurvey() {
        return this.surveySObject;
    }

    public String getErrorMessage() {
        return this.errorMessage;
    }

    public List<String> getQuestionOrder() {

        if (this.questionOrder.size() == 0) {
            parseSurveyXml();
        }
        return this.questionOrder;
    }

    public SurveyQuestion getQuestion(String binding) {

        if (!this.questions.containsKey(binding)) {
            return null;
        }
        return this.questions.get(binding);
    }

    public void checkQuestionInstance(Decimal instance, String binding) {

        if (this.questions.containsKey(binding)) {
            if (this.questions.get(binding).getTotalInstances().intValue() < instance) {
                this.questions.get(binding).setTotalInstance(instance);
            }
        }
    }

    public String generateHtmlTableRow() {

        if(this.questions.size() == 0) {
            parseSurveyXml();
        }

        String data = '<tr><td>Survey Id</td>'
            + '<td>Submission Id</td>'
            + '<td>Server Entry Time</td>'
            + '<td>Handset Submit Time</td>'
            + '<td>Submission Latitude</td>'
            + '<td>Submission Longitude</td>'
            + '<td>Interviewer Id</td>'
            + '<td>Interviewer First Name</td>'
            + '<td>Interviewer Last Name</td>'
            + '<td>Interviewer Gender</td>'
            + '<td>Interviewer District</td>'
            + '<td>Interviewer Subcounty</td>'
            + '<td>Data Collection Status</td>'
            + '<td>Customer Care Status</td>';
        if (!this.surveySObject.Allow_No_Interviewee__c) {
            data = data + '<td>Interviewee Name</td>'
                + '<td>Interviewee First Name</td>'
                + '<td>Interviewee Last Name</td>'
                + '<td>Interviewee Gender</td>'
                + '<td>Interviewee Parish</td>';
        }

        // Add the questions
        for (String questionBinding : getQuestionOrder()) {
            SurveyQuestion question = this.questions.get(questionBinding);
            Integer totalInstance = question.getTotalInstances().intValue();

            for (Integer i = 0; i <= totalInstance; i++) {
                if (question.getQuestionType().equals('Select')) {
                    Integer numberOfOptions = question.getNumberOfOptions();
                    for (Integer j = 1; j <= numberOfOptions; j++) {
                        data = data + '<td>' + DocumentHelpers.escapeAnswerText(question.getBinding() + ': ' + question.getQuestionDisplayText() + '_' + String.valueOf(i + 1) + '_' + String.valueOf(j)) + '</td>';
                    }
                }
                else {
                    data = data + '<td>' + DocumentHelpers.escapeAnswerText(question.getBinding() + ': ' + question.getQuestionDisplayText() + '_' + String.valueOf(i)) + '</td>';
                }
            }
        }
        
        data += '</tr>';
        return data;
    }

    public String generateCsv() {

        if (this.questions.size() == 0) {
            parseSurveyXml();
        }
        String csv = 'Survey Id,'
            + 'Submission Id,'
            + 'Server Entry Time,'
            + 'Handset Submit Time,'
            + 'Submission Latitude,'
            + 'Submission Longitude,'
            + 'Interviewer Id,'
            + 'Interviewer First Name,'
            + 'Interviewer Last Name,'
            + 'Interviewer Gender,'
            + 'Interviewer District,'
            + 'Interviewer Subcounty,'
            + 'Data Collection Status,'
            + 'Customer Care Status,';
        if (!this.surveySObject.Allow_No_Interviewee__c) {
            csv = csv + 'Interviewee Name,'
                + 'Interviewee First Name,'
                + 'Interviewee Last Name,'
                + 'Interviewee Gender,'
                + 'Interviewee Parish,';
        }

        // Add the questions
        for (String questionBinding : getQuestionOrder()) {
            SurveyQuestion question = this.questions.get(questionBinding);
            Integer totalInstance = question.getTotalInstances().intValue();
            for (Integer i = 0; i <= totalInstance; i++) {
                if (question.getQuestionType().equals('Select')) {
                    Integer numberOfOptions = question.getNumberOfOptions();
                    for (Integer j = 1; j <= numberOfOptions; j++) {
                        csv = csv + DocumentHelpers.escapeAnswerText(question.getBinding() + ': ' + question.getQuestionDisplayText() + '_' + String.valueOf(i + 1) + '_' + String.valueOf(j)) + ',';
                    }
                }
                else {
                    csv = csv + DocumentHelpers.escapeAnswerText(question.getBinding() + ': ' + question.getQuestionDisplayText() + '_' + String.valueOf(i)) + ',';
                }
            }
        }
        return csv;
    }

    public void parseSurveyXml() {

        Attachment attachment = DocumentHelpers.getAttachment(DocumentHelpers.createSurveyFileName(this.surveyName));
        if (attachment == null) {
            this.errorMessage = '0';
            return;
        }
        String xml = DocumentHelpers.getContent(attachment);
        if (xml == null) {
            this.errorMessage = '1';
            return;
        }

        Dom.Document doc = new Dom.Document();
        doc.load(xml);

        Dom.Xmlnode rootNode = doc.getRootElement();
        String formType = rootNode.getName();
        if (formType.contains('html')) {
            this.formType = 'javaRosa';
            parseJavaRosaForm(rootNode);
        }
        else if (formType.contains('xform')) {
            this.formType = 'xForm';
            parseXform(rootNode);
        }
        else {
            this.errorMessage = '2';
            return;
        }
        this.errorMessage = 'Success';
    }

    private void parseXform(Dom.Xmlnode rootNode) {

        for (Dom.Xmlnode childNode : rootNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('group')) {
                    parseGroup(childNode);
                }
            }
        }
    }

    private void parseJavaRosaForm(Dom.Xmlnode rootNode) {

        for (Dom.Xmlnode childNode : rootNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {

                // See if this is one of the parts of the form that we are interested in.
                // The head of the form contains the translations.
                if (childNode.getName().equals('head')) {
                    parseJavaRosaHead(childNode);
                }
                else if (childNode.getName().equals('body')) {
                    parseJavaRosaBody(childNode);
                }
            }
        }
    }

    private void parseJavaRosaHead(Dom.Xmlnode headNode) {

        for (Dom.Xmlnode childNode : headNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {

                if (childNode.getName().equals('model')) {
                    parseModel(childNode);
                }
            }
        }
    }

    private void parseModel(Dom.Xmlnode modelNode) {

        for (Dom.Xmlnode childNode : modelNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('itext')) {
                    parseItext(childNode);
                }
            }
        }
    }

    private void parseItext(Dom.Xmlnode itextNode) {

        for (Dom.Xmlnode childNode : itextNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('translation')) {
                    parseTranslations(childNode);
                }
            }
        }
    }

    private void parseTranslations(Dom.Xmlnode translationsNode) {

        String languageCode = translationsNode.getAttributeValue('lang', '');
        TranslationMap translationMap = null;
        if (!this.languageMap.containsKey(languageCode)) {
            translationMap = new TranslationMap(languageCode);
        }
        else {
            translationMap = this.languageMap.get(languageCode);
        }
        for (Dom.Xmlnode childNode : translationsNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('text')) {
                    translationMap.addTranslation(childNode.getAttributeValue('id', ''), parseTranslation(childNode));
                }
            }
        }
        this.languageMap.put(languageCode, translationMap);
    }

    private String parseTranslation(Dom.Xmlnode translationNode) {

        String xlation = '';
        for (Dom.Xmlnode childNode : translationNode.getChildElements()) {
            if (childNode.getNodeType() == Dom.XmlNodeType.ELEMENT) {
                if (childNode.getName().equals('value')) {
                    xlation = childNode.getText().trim();
                    if (xlation.length() == 0) {
                        xlation = '?';
                    }
                }
            }
        }
        return xlation;
    }

    private void parseJavaRosaBody(Dom.Xmlnode bodyNode) {

        for (Dom.Xmlnode childNode : bodyNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('group')) {
                    parseGroup(childNode);
                }
            }
        }
    }

    private void parseGroup(Dom.Xmlnode groupNode) {

        String groupName = '';
        for (Dom.Xmlnode childNode : groupNode.getChildElements()) {
            if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                if (childNode.getName().equals('label')) {
                    groupName = getQuestionData(childNode);
                }
                else if (childNode.getName().equals('input') || childNode.getName().equals('upload')) {
                    parseInput(childNode);
                }
                else if (childNode.getName().contains('select')) {
                    parseSelect(childNode);
                }
                else if (childNode.getName().equals('group')) {
                    parseGroup(childNode);
                }
                else if (childNode.getName().equals('repeat')) {
                    parseRepeat(childNode, groupName);
                }
            }
        }
    }

    private void parseRepeat(Dom.Xmlnode repeatNode, String questionName) {

        String binding = getQuestionBinding(repeatNode);

        // Need to add this here so that the question is in the right place.
        this.questionOrder.add(binding);
        Integer questionNumber = this.questionCount;
        this.questionCount++;

        for (Dom.Xmlnode childNode : repeatNode.getChildElements()) {
            if (childNode.getName() == null) {
                continue;
            }
            if (childNode.getName().equals('input') || childNode.getName().equals('upload')) {
                parseInput(childNode);
            }
            else if (childNode.getName().contains('select')) {
                parseSelect(childNode);
            }

            // This will contain any sub repeats
            else if (childNode.getName().equals('group')) {
                parseGroup(childNode);
            }
        }
        this.questions.put(binding, new SurveyQuestion(binding, 'repeat', questionNumber, questionName));
    }

    private void parseInput(Dom.Xmlnode inputNode) {

        SurveyQuestion question = null;
        String binding = getQuestionBinding(inputNode);
        for (Dom.Xmlnode childNode : inputNode.getChildElements()) {
            if (childNode.getNodeType() == Dom.XmlNodeType.ELEMENT) {
                if (childNode.getName().equals('label')) {
                    question = new SurveyQuestion(binding, 'input', this.questionCount, getQuestionData(childNode));
                }
            }
        }
        if (question != null) {
            this.questions.put(binding, question);
            this.questionOrder.add(binding);
            this.questionCount++;
        }
    }

    private void parseSelect(Dom.Xmlnode selectNode) {

        String questionBinding = getQuestionBinding(selectNode);
        String questionText = '';
        String values = '';

        for (Dom.Xmlnode childNode : selectNode.getChildElements()) {
            if (childNode.getNodeType() == Dom.XmlNodeType.ELEMENT) {
                if (childNode.getName().equals('label')) {
                    getQuestionData(childNode);
                }
                else if (childNode.getName().equals('item')) {
                    String value = '';
                    String option = '';
                    for (Dom.Xmlnode itemNode : selectNode.getChildElements()) {
                        if (itemNode.getName() == null) {
                            continue;
                        }
                        if (itemNode.getName().equals('label')) {
                            option = getQuestionData(itemNode);
                        }
                        else if (itemNode.getName().equals('value')) {
                            value = itemNode.getText().trim();
                        }
                    }
                    values += option + '#@#' + value + '@#@';
                }
            }
        }
        String rawText = questionText + ' -- ' + values;

        // Create the question with the required type
        if (selectNode.getName().equals('select1')) {
            this.questions.put(questionBinding, new SurveyQuestion(questionBinding, 'select1', this.questionCount, rawText));
        }
        else {
            this.questions.put(questionBinding, new SurveyQuestion(questionBinding, 'select', this.questionCount, rawText));
        }
        this.questionOrder.add(questionBinding);
        this.questionCount++;
    }

    private String getQuestionBinding(Dom.Xmlnode questionNode) {

        String binding = questionNode.getAttributeValue('bind', '');
        if (binding == null || binding.length() == 0) {
            binding = questionNode.getAttributeValue('ref', '');
        }
        return binding;
    }

    private String getQuestionData(Dom.Xmlnode childNode) {

        String questionName = '';
        if (this.formType.equals('javaRosa')) {
            questionName = this.languageMap.get('en').getTranslation(setLanguageKey(childNode));
        }
        else if (this.formType.equals('xForm')) {
            questionName = childNode.getText().trim();
        }
        return questionName;
    }
 
    private String setLanguageKey(Dom.Xmlnode childNode) {

        // Parse the name from the ref value
        String refString = childNode.getAttributeValue('ref', '');
        Integer startIndex = refString.indexOf('(\'') + 2;
        Integer endIndex = refString.length() - 2;
        return refString.substring(startIndex, endIndex);
    }

    // Store the translations for this survey
    class TranslationMap {

        private Map<String, String> translations;
        private String languageCode;

        public TranslationMap(String languageCode) {
            this.translations = new Map<String, String>();
            this.languageCode = languageCode;
        }

        public String getTranslation(String key) {
            String translation = key;
            if (this.translations.containsKey(key)) {
                translation = this.translations.get(key);
            }
            return translation;
        }

        public void addTranslation(String key, String translation) {
            this.translations.put(key, translation);
        }
    }

    static testMethod void testParsing() {

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

        ParseSurveyXml parseSurveyXml = new ParseSurveyXml(survey2.Name);
        System.assert(parseSurveyXml.getQuestionOrder().size() == 6);
    }
}