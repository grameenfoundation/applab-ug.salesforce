public class GraphController {

    public List<GraphColumnWrapper> graphPieColumns;
    public List<GraphRowWrapper> graphPieRows;
    public List<GraphColumnWrapper> graphTrendColumns;
    public List<GraphRowWrapper> graphTrendRows;
    private String feedbackMessage;

    Transient Map<String, Integer> searchCount;
    Transient Map<String, Map<String, Integer>> trendCount;
    Transient List<String> weekOrder;
    Transient Map<String, String> variables;
    Transient List<String> keywords;
    Transient Integer Total;

    public GraphController() {

        PageReference pageRef = ApexPages.currentPage();
        this.variables = pageRef.getParameters();

        // Need to default a couple of the params just in case they are not set
        // Decide how long the gap should be
        Integer gap = -14;
        if ((this.variables.get('ckws')!= null && !this.variables.get('ckws').equals('')) || (this.variables.get('farmers') != null && !this.variables.get('farmers').equals(''))) {
            gap = -60;
        }
        if ((this.variables.get('searchStartDate') == null || this.variables.get('searchStartDate').equals('')) || (this.variables.get('searchEndDate') == null || this.variables.get('searchEndDate').equals(''))) {
            Date now = Date.today().toStartOfWeek();
            this.variables.put('searchStartDate', MetricHelpers.parseDateToString(now.addDays(gap)));
            this.variables.put('searchEndDate', MetricHelpers.parseDateToString(now.addDays(-1)));
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

        keywords = new List<String>();
        this.graphPieColumns = new List<GraphColumnWrapper>();
        this.graphPieRows = new List<GraphRowWrapper>();
        this.graphTrendColumns = new List<GraphColumnWrapper>();
        this.graphTrendRows = new List<GraphRowWrapper>();
        this.trendCount = null;
        this.searchCount = null;
        this.weekOrder = new List<String>();
        this.feedbackMessage = '';

        try {
            getKeywords();
            setGraphPieColumns();
            setGraphPieRows();
            setGraphTrendColumns();
            setGraphTrendRows();
        }
        catch (Exception e) {
            setFeedbackMessage('Error: An error has occured. Please try again');
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }

    /**
     *  Generate the search count for the given params. Currently have to look through the query string
     *  as our search logging is just terrible.
     *  Would like to define by category and I hope that one day we will but not at the moment so it is a
     *  hacktastic time for a bit.
     */
    private void generateSearchCount() {

        searchCount = new Map<String, Integer>();

        // Check that the keywords have been set up
        if (this.keywords == null) {
            getKeywords();
        }

        // Set up the search count map
        this.total = 0;
        this.searchCount.put('Unknown', 0);
        for (String keyword : this.keywords) {
            this.searchCount.put(keyword, 0);
        }

        // Calcualte the start and end dates for the searches. Set up the map for the trend graph.
        this.trendCount = new Map<String, Map<String, Integer>>();
        Date startOfCurrentWeekDate;
        Date endOfCurrentWeekDate;

        // Create the first instance of the a trend map for the first week.
        String currentDateString;
        Map<String, Integer> currentWeekMap = setUpTrendMap();

        // Loop through the logs and count up the number of keyword matches. Also add in to the current date
        // of search for the trend graph. We will not include unknown searches as we are looking at the trend of
        // the choosen keywords or all the defaults. We hope that once the searches are stored in a sensible manner
        // there will be no unknown searches.
        Boolean unknownQuery = true;
        String queryDetailText = '';
        for (Search_Log__c[] logs : database.query(SoqlHelpers.getSearchesForGraph(this.variables))) {
            for (Search_Log__c log : logs) {

                // Stuff to do the first time through. Required to try and avoid heap limits
                if (this.total == 0) {

                    // Calcualte the start and end dates for the searches. Set up the map for the trend graph.
                    startOfCurrentWeekDate = log.Handset_Submit_Time__c.date().toStartOfWeek();
                    endOfCurrentWeekDate = startOfCurrentWeekDate.addDays(7);

                    // Create the first instance of the a trend map for the first week.
                    currentDateString = constructDateString(startOfCurrentWeekDate);
                    this.weekOrder.add(currentDateString);
                    this.trendCount.put(currentDateString, currentWeekMap.clone());
                }
                for (String keyword : this.keywords) {
                    if (log.Query__c != null && log.Query__c.contains(keyword)) {
                        this.searchCount.put(keyword, searchCount.get(keyword) + 1);
                        unknownQuery = false;

                        // Check that we have not moved into the next week for the trend graph
                        if (endOfCurrentWeekDate.daysBetween(log.Handset_Submit_Time__c.date()) > 0) {

                            this.trendCount.put(currentDateString, currentWeekMap.clone());
                            currentWeekMap.clear();
                            currentWeekMap = setUpTrendMap();

                            // Set up the new week
                            startOfCurrentWeekDate = log.Handset_Submit_Time__c.date().toStartOfWeek();
                            endOfCurrentWeekDate = startOfCurrentWeekDate.addDays(7);
                            currentDateString = constructDateString(startOfCurrentWeekDate);
                            this.weekOrder.add(currentDateString);
                        }

                        // Add the search to the trend graph.
                        currentWeekMap.put(keyword, currentWeekMap.get(keyword) + 1);
                        break;
                    }
                }
                if (unknownQuery) {
                    this.searchCount.put('Unknown', searchCount.get('Unknown') + 1);
                    unknownQuery = true;
                }
                this.total++;
                
            }
        }
        this.trendCount.put(currentDateString, currentWeekMap.clone());
    }

    private String constructDateString(Date dateToConvert) {

        return dateToConvert.format();
    }

    private Map<String, Integer> setUpTrendMap() {

        Map<String, Integer> defaultMap = new Map<String, Integer>();
        for (String keyword : this.keywords) {
            defaultMap.put(keyword, 0);
        }
        return defaultMap;
    }

    private void getKeywords() {

        // Get the keywords that we are looking for. This can come from SF or from selection by the user.
        String keyWordParam = SoqlHelpers.getNamedVariable(variables, 'keyword');
        if (keyWordParam.equals('')) {

            // Default to just look at the categories
            variables.put('AllCat', 'true');
            Tag_Cloud_Word__c[] words = database.query(SoqlHelpers.getKeywords(variables, 0));
            for (Tag_Cloud_Word__c word : words) {
                this.keywords.add(word.Name);
            }
        }
        else {
            Boolean useParam = true;
            if (keyWordParam.contains('AllCat')) {
                useParam = false;
                variables.put('AllCat', 'true');
                variables.put('keyword', '');
            }
            if (keyWordParam.contains('AllCrops')) {
                useParam = false;
                variables.put('AllCrops', 'true');
                variables.put('keyword', '');
            }
            if (keyWordParam.contains('AllLivestock')) {
                useParam = false;
                variables.put('AllLivestock', 'true');
                variables.put('keyword', '');
            }
            if (useParam) {
                this.keywords = SoqlHelpers.getNamedVariable(variables, 'keyword').split(';');
            }
            else {
                Tag_Cloud_Word__c[] words = database.query(SoqlHelpers.getKeywords(variables, 0));
                for (Tag_Cloud_Word__c word : words) {
                    this.keywords.add(word.Name);
                }
            }
        }
    }

    /**
     *  Set the columns that are to be used in the data table to draw the graph. At the moment we are
     *  just going to hard code these as the graphs are just for searches done. Will want to generalise in the
     *  future.
     */
    public void setGraphPieColumns() {
        this.graphPieColumns.add(new GraphColumnWrapper('string', 'Name'));
        this.graphPieColumns.add(new GraphColumnWrapper('number', 'Total Searches'));
    }

    public List<GraphColumnWrapper> getGraphPieColumns() {
        return this.graphPieColumns;
    }

    public void setGraphPieRows() {

        this.graphPieRows = new List<GraphRowWrapper>();
        if (this.searchCount == null) {
            generateSearchCount();
        }
        if (this.searchCount.size() > 0) {
            for (String key : keywords) {
                if (searchCount.get(key) > 0) {
                    this.graphPieRows.add(new GraphRowWrapper(String.valueOf(searchCount.get(key)), key));
                }
            }
            if (searchCount.get('Unknown') > 0) {
                this.graphPieRows.add(new GraphRowWrapper(String.valueOf(searchCount.get('Unknown')), 'Unknown'));
            }
        }
    }

    public List<GraphRowWrapper> getGraphPieRows() {
        return this.graphPieRows;
    }

    public void setGraphTrendColumns() {

        if (this.keywords == null) {
            getKeywords();
        }

        this.graphTrendColumns.add(new GraphColumnWrapper('string', 'Week'));
        for (String keyword : this.keywords) {
            this.graphTrendColumns.add(new GraphColumnWrapper('number', keyword));
        }
    }

    public List<GraphColumnWrapper> getGraphTrendColumns() {
        return this.graphTrendColumns;
    }

    public void setGraphTrendRows() {

        if (this.trendCount == null) {
            generateSearchCount();
        }

        // Loop through the week order list so that we get the dates out in the correct order.
        for (String week : this.weekOrder) {

            // Loop through the keywords list so that the words come out in the right order.
            String countString = '';
            Integer countInteger = 0;
            for (String keyword : this.keywords) {
                if (this.trendCount.get(week).get(keyword) != null) {
                    countInteger = this.trendCount.get(week).get(keyword);
                }
                countString = countString + String.valueOf(countInteger) + ':';
            }
            this.graphTrendRows.add(new GraphRowWrapper(countString.subString(0, countString.length() - 1), week));
        }
    }

    public List<GraphRowWrapper> getGraphTrendRows() {
        return this.graphTrendRows;
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

        PageReference pageRef = Page.MetricMap;
        Integer gap = -1;
        Date now = Date.today();
        pageRef.getParameters().put('searchStartDate', MetricHelpers.parseDateToString(now.addDays(gap)));
        pageRef.getParameters().put('searchEndDate', MetricHelpers.parseDateToString(now));
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        GraphController controller = new GraphController();
        Test.stopTest();
    }
}