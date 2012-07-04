public class SurveyQuestion {

    private String binding;
    private String questionText;
    private String questionDisplayText;
    private String questionType;
    private Integer questionNumber;
    private Integer numberOfOptions;
    private Decimal totalInstances;

    // Only used for selects
    private Map<String, String> optionMap;

    public SurveyQuestion(String binding, String questionType, Integer questionNumber, String questionText) {

        this.binding = binding;
        this.questionType = questionType;
        this.questionText = questionText;
        this.questionNumber = questionNumber;
        this.totalInstances = 0.0;

        generateDisplayText();
    }

    public String getQuestionDisplayText() {
        return this.questionDisplayText;
    }

    public Integer getNumberOfOptions() {
        return this.numberOfOptions;
    }

    public String getBinding() {
        return this.binding;
    }

    public String getQuestionType() {
        return this.questionType;
    }

    public Integer getQuestionNumber() {
        return this.questionNumber;
    }

    public Decimal getTotalInstances() {
        return this.totalInstances;
    }

    public void setTotalInstance(Decimal instance) {
        this.totalInstances = instance;
    }

    public void incrementInstances() {
        this.totalInstances++;
    }

    public String getOptionText(String key) {

        if (this.optionMap == null || !this.optionMap.containsKey(key)) {
            return null;
        }
        return this.optionMap.get(key);
    }

    private void generateDisplayText() {

        // Selects questionText follows a strict pattern
        // <questionDisplayText> -- [<optionBinding>#@#<optionDisplayText>@#@]*
        // Should not hit the second part of this if statement as it implies a select question with no options 
        // in it but cant take the risk that sensible people are using this system. Damn self serve
        Integer index = this.questionText.indexOf(' -- ');
        if (!this.questionType.contains('select') || index == -1) {
            this.questionDisplayText = this.questionText;
            return;
        }

        this.questionDisplayText = this.questionText.substring(0, index);

        // Now build the optionMap and calculate the number of options
        // Skip past the ' -- '
        this.optionMap = new Map<String, String>();
        String optionString = this.questionText.substring(index + 4);
        String[] options = optionString.split('@#@');
        this.numberOfOptions = options.size();
        for (Integer i = 0; i < options.size(); i++) {
            String[] option = options[i].split('#@#');
            if (option[0] == null || option.size() < 1) {
                continue;
            }
            String optionDisplayText = 'N/A';
            if (option.size() >= 2 && option[1] !=  null) {
                optionDisplayText = option[1].trim();
            }
            optionMap.put(option[0], optionDisplayText);
        }
    }

    static testMethod void testSelectQuestion() {

        SurveyQuestion selectQuestion = new SurveyQuestion('q1', 'select', 6, 'Whats up? -- 1#@#Nothing@#@2#@#Some@#@3#@#All');
        System.assert(selectQuestion.getQuestionDisplayText().equals('Whats up?'));
        System.assert(selectQuestion.getNumberOfOptions() == 3);
        System.assert(selectQuestion.getBinding().equals('q1'));
        System.assert(selectQuestion.getTotalInstances() == 0);
        selectQuestion.incrementInstances();
        System.assert(selectQuestion.getTotalInstances() == 1);
        System.assert(selectQuestion.getQuestionNumber() == 6);
        System.assert(selectQuestion.getOptionText('1').equals('Nothing'));
        System.assert(selectQuestion.getOptionText('4') == null);
    }

    static testMethod void testQuestion() {

        SurveyQuestion selectQuestion = new SurveyQuestion('q1', 'input', 6, 'Whats up?');
        System.assert(selectQuestion.getOptionText('4') == null);
        System.assert(selectQuestion.getQuestionDisplayText().equals('Whats up?'));
    }

}