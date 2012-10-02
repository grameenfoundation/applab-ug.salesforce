public with sharing class ProcessSubmissionHelpers {
    /*
     * Data types
     */
    public static final Integer DATE_TYPE = 0;
    public static final Integer DECIMAL_TYPE = 1;
    public static final Integer STRING_TYPE = 2;
    public static final Integer SET_STRING_TYPE = 3;
    
    /**
     * Get an optional String answer from a field
     *
     * @param answer - The answer object that we are looking at. May be null
     *
     * return - The answer. null if the answer is blank
     */
    public static String getAnswerString(Submission_Answer__c answer) {
        return getAnswerString(answer, null);
    }

    /**
     * Get an optional String answer from a field. Return a default value if no value is found
     * @param String answer - The answer object that we are looking at
     * @param String defaultValue - this is returned if we do not find a suitable value to return
     * @return String|null
     */
    public static String getAnswerString(Submission_Answer__c answer, String defaultValue) {
        if (answer == null || answer.Answer__c == null) {
            return defaultValue;
        }
        else  {
            return answer.Answer__c;
        }
    }

    /**
     * Get an optional Date answer from a field. Return a default value if no value is found
     * @param String answer - The answer object that we are looking at
     * @param String defaultValue - this is returned if we do not find a suitable value to return
     * @return Date|null
     */
    public static Date getAnswerDate(Submission_Answer__c answer, Date defaultValue) {
        if (answer != null && answer.Answer__c != null) {
            String dateString = answer.Answer__c;

            // Dates comes in with the format YYYY-MM-dd (2011-09-30)
            String[] dateParts = dateString.split('-');
            if (dateParts.size() == 3) {
                dateString = dateParts[1] + '/' + dateParts[2] + '/' + dateParts[0];

                return Date.parse(dateString);
            }
        }
        return defaultValue;
    }

    /**
     * Get an optional number answer from a field
     *
     * @param answer  - The answer object that we are looking at. May be null
     * @param binding - The key for the answer. So an error can be identified
     *
     * return - The answer. null if the answer is blank
     */
    public static Decimal getAnswerNumber(Submission_Answer__c answer, String binding, Boolean disallowNull) {    
        if(disallowNull) {
            return getAnswerNumber(answer, binding, 0.0);
        } else {
            return getAnswerNumber(answer, binding, (Decimal) null);
        }
    }

    /**
     * Get an optional number answer from a field. Return defaultValue if no suitable value is found
     * @param Submission_Answer__c answer
     * @param String binding
     * @param Boolean disallowNull
     * @param Decimal default
     */
    public static Decimal getAnswerNumber(Submission_Answer__c answer, String binding, Decimal defaultValue) {
        if (answer == null || answer.Answer__c == null) {
            return defaultValue;
        }
        else {
            Decimal returnValue;
            try {
                returnValue = Decimal.valueOf(answer.Answer__c);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Number passed in for answer with binding ' + binding + ' caused an error: ' + e.getMessage());
                return defaultValue;
            }
            return returnValue;
        }
    }

    /**
     * Convert an answer into a Set. Useful for multiSelect questions
     *
     * @param answer - The answer being turned to a set
     *
     * @return - A set with all the answer bindings in
     */
    public static Set<String> getAnswerSet(Submission_Answer__c answer) {
        return getAnswerSet(answer, null);
    }

    /**
     * Convert an answer into a Set. Useful for multiSelect questions. Returns defaultValue if it cannot find a suitable value
     * @param Submission_Answer__c answer - The answer being turned to a set
     * @param Set<String> defaultValue - The default value to return
     * @return Set<String>
     */
    public static Set<String> getAnswerSet(Submission_Answer__c answer, Set<String> defaultValue) {
        Set<String> returnValue = new Set<String>();
        if (answer != null) {
            String answerValue = getAnswerString(answer, '');
            returnValue.addAll(answer.Answer__c.split(' '));
            return returnValue;
        }
        return defaultValue;
    }

    /**
     * Parse a date field from the survey
     *
     * @param answer - The answer being turned to a date
     *
     * @return - The date
     */
    public static Date parseDate(String value) {
        return Date.today();
    }

    public static DateTime getTimestamp(String timeString) {

        Long timeStamp = null;
        if (timeString != null && !timeString.equals('')) {
            timeStamp = Long.valueOf(timeString);
        }
        if (timeStamp == null || timeStamp == 0) {
            return null;
        }
        else {
            return datetime.newInstance(timeStamp);
        }
    }

    /**
     * Get answer from an answerMap
     * 
     * @param Map<String, Submission_Answer__c> answerMap - the map that contains the answers we want to extract
     * @param String answerKey - the index of the answer we want
     * @param Integer type - the type of response we expect. Currently supports Decimal, String, Date and Set<String> (see type constants above) 
     * @param Object defaultValue - the defaultValue (should match the expected return type)
     * 
     * @return Object - you will need to cast back to the type you want. 
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue, Integer type) {
        Submission_Answer__c answer = null;

        if(answerMap.containsKey(answerKey))    {
            answer = answerMap.get(answerKey);

            if(type == SET_STRING_TYPE) {
                return (Set<String>) getAnswerSet(answer, (Set<String>) defaultValue);
            } else if(type == DECIMAL_TYPE) {
                return (Decimal) getAnswerNumber(answer, answerKey, (Decimal) defaultValue);
            } else if(type == DATE_TYPE) {
                return (Date) getAnswerDate(answer, (Date) defaultValue);
            } else if(type == STRING_TYPE){
                return (String) getAnswerString(answer, (String) defaultValue);
            }
        }
        return defaultValue;
    }

    /**
     * This allows optional Type, defaulting it to String
     * @see extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue) 
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue) {
        return extractAnswer(answerMap, answerKey, defaultValue, STRING_TYPE);
    }

    /**
     * This further allows defaultValue to be left out
     * @see extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey, Object defaultValue)
     */
    public static Object extractAnswer(Map<String, Submission_Answer__c> answerMap, String answerKey) {
        return extractAnswer(answerMap, answerKey, null);
    }

    static testMethod void testAnswers() {        
        Submission_Answer__c answer = new Submission_Answer__c();
        answer.Answer__c = '1';
        System.assertEquals(getAnswerString(null), null);
        System.assertEquals(getAnswerString(answer), '1');
        System.assertEquals(getAnswerString(null, 'test'), 'test');
        answer.Answer__c = null;
        System.assertEquals(getAnswerString(answer, 'test2'), 'test2');
        System.assertEquals(getAnswerNumber(null, '1', true), 0.0);
        System.assertEquals(getAnswerNumber(null, '1', false), null);
        answer.Answer__c = '1';
        System.assertEquals(getAnswerNumber(answer, '1', true), 1.0);
        System.assertEquals(getAnswerNumber(null, '1', 1), 1);
        answer.Answer__c = null;
        System.assertEquals(getAnswerNumber(answer, '1', 2), 2);
        answer.Answer__c = '1 2 3';
        System.assertEquals(getAnswerSet(answer).size(), 3);
    }

    static testMethod void testTimestamp() {
        DateTime test = getTimeStamp(null);
        System.assertEquals(test, null);
        DateTime control = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        test = getTimestamp(String.valueOf(control.getTime()));
        System.assertEquals(test, control);
    }
}