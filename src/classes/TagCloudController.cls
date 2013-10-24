public with sharing class TagCloudController {

    private List<TagCloudElementWrapper> tagCloudElements;
    private String feedbackMessage;

    private List<String> tagCloudWords;
    Transient Map<String, String> variables;

    public TagCloudController() {

        setUp();
    }

    private void setUp() {

        PageReference pageRef = ApexPages.currentPage();
        this.variables = pageRef.getParameters();

        // Need to default a couple of the params just in case they are not set
        // Decide how long the gap should be
        Integer gap = -14;
        if ((this.variables.get('ckws')!= null && !this.variables.get('ckws').equals('')) || (this.variables.get('farmers') != null && !this.variables.get('farmers').equals(''))) {
            gap = -60;
        }
        if ((this.variables.get('searchStartDate') == null || this.variables.get('searchStartDate').equals('')) || (this.variables.get('searchEndDate') == null || this.variables.get('searchEndDate').equals(''))) {
            Date now = Date.today();
            this.variables.put('searchStartDate', MetricHelpers.parseDateToString(now.addDays(gap)));
            this.variables.put('searchEndDate', MetricHelpers.parseDateToString(now));
        }
 
        // Ensure that the ids passed in are wrapped in quotes. Cant assume this.
        List<String> ids;
        if (variables.get('farmers') != null) {
            ids = variables.get('farmers').split(',');
            if (!ids.isEmpty() && ids[0] != null && !ids[0].equals('')) {
                variables.put('farmers', MetricHelpers.generateCommaSeperatedString(ids, MetricHelpers.checkListNeedsQuotes(ids)));
            }
            ids.clear();
        }
        if (variables.get('ckws') != null) {
            ids = variables.get('ckws').split(',');
            if (!ids.isEmpty() && ids[0] != null && !ids[0].equals('')) {
                variables.put('ckws', MetricHelpers.generateCommaSeperatedString(ids, MetricHelpers.checkListNeedsQuotes(ids)));
            }
            ids.clear();
        }
        this.feedbackMessage = '';
    }

    public List<TagCloudElementWrapper> getTagCloudElements() {

        if  (this.tagCloudElements == null) {
            setTagCloudElements();
        }
        return tagCloudElements;
    }

    public void setTagCloudElements() {
        try {
            tagCloudElements = getElements();
        }
        catch (Exception e) {
            setFeedbackMessage('Error: An error has occured. Please try again');
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }

    private List<TagCloudElementWrapper> getElements() {

        List<TagCloudElementWrapper> tagCloudElementWrappers = new List<TagCloudElementWrapper>();
        List<String> tagCloudWords = getTagCloudWords();

        // Loop through each word and carry out the query to get the count for that word
        Integer total = 0;
        Integer min;
        Integer max;
        for (String tagCloudWord : tagCloudWords) {
            AggregateResult[] frequencyResults = database.query(SoqlHelpers.getTagCloudWordCount(tagCloudWord, variables));
            if (frequencyResults.size() == 0) {
                break;
            }
            Integer frequency = Integer.valueOf(frequencyResults[0].get('total'));

            // Add to the total
            total = total + frequency;

            // Check that this is the max
            if (max == null || max < frequency) {
                max = frequency;
            }

            // Check that this is the min
            if (min == null || min > frequency) {
                min = frequency;
            }

            // Create and add the wrapper
            tagCloudElementWrappers.add(new TagCloudElementWrapper(tagCloudWord, frequency));
        }

        if (max == null || min == null) {
            return tagCloudElementWrappers;
        }

        // Loop through the found words and calcualte the css class that they should be displayed with.
        // Have to do the next calculation in stages otherwise SF throws a fit
        Decimal classRange = (Decimal)(max - min) / 10;
        classRange = classRange + 0.1;

        for(TagCloudElementWrapper wrapper : tagCloudElementWrappers) {
            if(wrapper.frequency == 0) {
                wrapper.addClassName('tagcloud0');
            }
            else {
                if(wrapper.frequency > 0 && wrapper.frequency <= classRange) {
                    wrapper.addClassName('tagcloud1');
                }
                else if(wrapper.frequency > classRange && wrapper.frequency <= classRange * 2) {
                    wrapper.addClassName('tagcloud2');
                }
                else if(wrapper.frequency > classRange * 2 && wrapper.frequency <= classRange * 3) {
                    wrapper.addClassName('tagcloud3');
                }
                else if(wrapper.frequency > classRange * 3 && wrapper.frequency <= classRange * 4) {
                    wrapper.addClassName('tagcloud4');
                }
                else if(wrapper.frequency > classRange * 4 && wrapper.frequency <= classRange * 5) {
                    wrapper.addClassName('tagcloud5');
                }
                else if(wrapper.frequency > classRange * 5 && wrapper.frequency <= classRange * 6) {
                    wrapper.addClassName('tagcloud6');
                }
                else if(wrapper.frequency > classRange * 6 && wrapper.frequency <= classRange * 7) {
                    wrapper.addClassName('tagcloud7');
                }
                else if(wrapper.frequency > classRange * 7 && wrapper.frequency <= classRange * 8) {
                    wrapper.addClassName('tagcloud8');
                }
                else if(wrapper.frequency > classRange * 8 && wrapper.frequency <= classRange * 9) {
                    wrapper.addClassName('tagcloud9');
                }
                else if(wrapper.frequency > classRange * 9) {
                    wrapper.addClassName('tagcloud10');
                }
            }
        }
        return tagCloudElementWrappers;
    }

    private List<String> getTagCloudWords() {

        String tagCloudParam = SoqlHelpers.getNamedVariable(variables, 'keyword');
        if (!tagCloudParam.equals('')) {
            Boolean returnHere = true;
            if (tagCloudParam.contains('AllCat')) {
                returnHere = false;
                variables.put('AllCat', 'true');
                variables.put('keyword', '');
            }
            if (tagCloudParam.contains('AllCrops')) {
                returnHere = false;
                variables.put('AllCrops', 'true');
                variables.put('keyword', '');
            }
            if (tagCloudParam.contains('AllLivestock')) {
                returnHere = false;
                variables.put('AllLivestock', 'true');
                variables.put('keyword', '');
            }
            if (returnHere) {
                variables.put('keyword', '');
                return tagCloudParam.split(';');
            }
        }
        List<String> tagCloudWords = new List<String>();
        Tag_Cloud_Word__c[] tagCloudWordsSObject = database.query(SoqlHelpers.getTagCloudWords(variables, 0));
        for (Tag_Cloud_Word__c word : tagCloudWordsSObject) {
            tagCloudWords.add(word.Name);
        }
        return tagCloudWords;
    }

    public String getFeedbackMessage() {
        return this.feedbackMessage;
    }

    public void setFeedbackMessage(String addOn) {

        if (this.feedbackMessage == null || this.feedbackMessage.equals('')) {
            this.feedbackMessage = addOn;
        }
        else {
            this.feedbackMessage = this.feedbackMessage + ' ' + addOn;
        }
    }

    public static testMethod void testController() {

        District__c district = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Gulu'];

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPersonCkw = new Person__c();
        testPersonCkw.First_Name__c = 'FirstName';
        testPersonCkw.Last_Name__c = 'LastName';
        testPersonCkw.Handset__c = testHandset.Id;
        testPersonCkw.District__c = district.Id;
        testPersonCkw.Gender__c = 'Female';
        database.insert(testPersonCkw);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPersonCkw.id;
        testCkw.Status__c = 'Active';
        database.insert(testCkw);

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        TagCloudController controller = new TagCloudController();
        Date now = Date.today();
        controller.variables.put('searchStartDate', MetricHelpers.parseDateToString(now.addDays(-14)));
        controller.variables.put('searchEndDate', MetricHelpers.parseDateToString(now));
        controller.variables.put('ckws', '\'' + testPersonCkw.id + '\'');
        controller.getTagCloudElements();
    }
}