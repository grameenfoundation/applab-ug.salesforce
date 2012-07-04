public with sharing class GraphComponentController extends ChildComponentBase {

    private Boolean isLoaded = false;
    private String isRefresh = 'false';
    public String getIsRefresh() {
        return this.isRefresh;
    }
    public void setIsRefresh(String value) {
        this.isRefresh = value;
    }

    /**
     * Getter and Setter for the Json string the represents the graph.
     * Getter deals with the heavy lifting of initialising the graph and getting the data
     */
    public String json;
    public String getJson() {
        if (!this.isLoaded) {
            setJson(loadJson());
            this.isLoaded = true;
        }
        return this.json;
    }
    public void setJson(String newJson) {
        this.json = newJson;
    }

    public String loadJson() {

         this.graphColumns = null;
         this.graphRows = null;

        // Init the graph. Display error message if there was a failure
        if (!init()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to initialise graph. If this problem persists contact support'));
            System.debug(LoggingLevel.INFO, 'Failed to init the graph');
            return 'FAIL';
        }

        // Dig out the information to be displayed on the graph.
        // Display error message if there is a failure
        if (!initDataTable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to initialise graph data table. If this problem persists contact support'));
            System.debug(LoggingLevel.INFO, 'Failed to init the data table');
            return 'FAIL';
        }

        // Set the dimensions of the graph
        setHeight('300');
        setWidth('700');
        if (getShowDataInline()) {
            setWidth('450');
        }
        if (getExpanded()) {
            setHeight('600');
            setWidth('800');
        }

        // Check that there is actually some data to show. Display a page error if there is not
        Integer numberOfColumns = this.graphColumns.size();
        Integer numberOfRows = this.rowOrder.size();
        if (numberOfColumns == 0 || numberOfRows == 0) {
            System.debug(LoggingLevel.INFO, 'Number of Columns = ' + numberOfColumns + '. Number of Rows = ' + numberOfRows);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no valid data for your chosen graph. Please ensure that some data has been submitted to the system'));
            return 'FAIL';
        }

        // Generate the JSON string for the data table
        String jsonString = '{cols: [';
        Integer i;
        for (i = 0; i < numberOfColumns; i++) {
            jsonString += this.graphColumns.get(i).toJsonString();
            if (i < numberOfColumns - 1) {
                jsonString += ', ';
            }
        }
        jsonString += '], rows: [';
        for (i = 0; i < numberOfRows; i++) {
            jsonString += this.rowMap.get(this.rowOrder.get(i)).toJsonString();
            if (i < numberOfRows - 1) {
                jsonString += ', ';
            }
        }
        jsonString += ']}';
        System.debug(LoggingLevel.INFO, jsonString);
        return jsonString;
    }

    public override sObject getsObjectRecord() {
        if (this.isLoaded == false) {
            init();
        }
        return this.sObjectRecord;
    }
    public override void setsObjectRecord(sObject value) {
        this.sObjectId = value.Id;
        this.sObjectRecord = value;
        this.sObjectName = 'Graph_Parameter__c';
        if (this.isLoaded == false) {
            init();
        }
    }

    public String getTypeOfGraph() {
        return getFieldValue('type_of_graph__c');
    }

    public String getXAxisTitle() {
        return getFieldValue('xaxis_title__c');
    }

    public String getXAxisColor() {
        return getFieldValue('xaxis_color__c');
    }

    public String getYAxisTitle() {
        return getFieldValue('yaxis_title__c');
    }

    public String getYAxisColor() {
        return getFieldValue('yaxis_color__c');
    }

    public String getTitle() {
        return getFieldValue('title__c');
    }

    public String getTitleColor() {
        return getFieldValue('title_color__c');
    }

    public String getLegendColor() {
        return getFieldValue('legend_color__c');
    }

    public Boolean getShowDataInline() {
        if (getExpanded()) {
            return false;
        }
        return Boolean.valueOf(getFieldValue('show_data_inline__c'));
    }

    public override PageReference refreshData() {
 
        try {
            setIsRefresh('true');

            if (this.getParentComponentController() != null) {
                this.getParentComponentController().rebuildParameters();

                // Rebuild the start times here so they are taken into account when rebuilding the axis
                if (!getParentValue('datePicker').equals('')) {
                    setDates(getParentValue('datePicker'));
                }
            }

            initAxis();
            setJson(loadJson());
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured whilst refreshing the data. If the problem persists please contact support'));
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
        return null;
    }

    /**
     *  Private methods that are used by the getters and setters are below
     */

    private List<GraphColumnWrapper> graphColumns;
    private List<GraphComponentController.GraphRowWrapper> graphRows;

    Transient List<String> rowOrder;
    Transient Map<String, GraphComponentController.GraphRowWrapper> rowMap;

    // Map of the keywords. Used for pie charts from search logs
    Transient Map<String, Decimal> keywordOccurances;

    private Boolean init() {

        setDates(getParentValue('datePicker'));
        initAxis();
        return true;
    }

    /**
     *  Load the graph parameter. Will display an error message if the graph does not exist.
     */
    private boolean loadGraphParameter() {

        if (this.sObjectId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No graph identifier provided. Cannot load a graph'));
            return false;
        }
        Graph_Parameter__c[] param = [SELECT
                Id,
                Name,
                Title__c,
                Title_Color__c,
                Legend_Color__c,
                Type_Of_Graph__c,
                xAxis_Series__c,
                xAxis_Title__c,
                xAxis_Color__c,
                yAxis_Color__c,
                yAxis_Title__c,
                Date_Period__c,
                Default_Show__c,
                Show_Data_Inline__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name
            FROM
                Graph_Parameter__c
            WHERE
                Id = :this.sObjectId
                AND Is_Active__c = true
        ];
        if (param.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No active graph definition found for id ' + this.sObjectId + '. Please check your set up.'));
            return false;
        }
        setsObjectRecord((sObject)param[0]);
        return true;
    }

    /**
     *  Add the values for the xAxis. This will be the first value in each row.
     *  Need to make sure every row is initialised. Also do the yAxis
     */
    private void initAxis() {

        // The columns will be different depending on the xAxis
        String columnType = 'string';
        String columnName;

        // Init the map of rows
        this.rowMap = new Map<String, GraphComponentController.GraphRowWrapper>();
        this.rowOrder = new List<String>();
        if (getFieldValue('xAxis_Series__c').equalsIgnoreCase('Date')) {
             columnName = getFieldValue('Date_Period__c');
             this.initXAxisDate();
        }
        else {
            columnName = getFieldValue('xAxis_Title__c');
        }
        this.graphColumns = new List<GraphColumnWrapper>();
        this.graphColumns.add(new GraphColumnWrapper(columnType, columnName));

        // For the moment just having one other column for the trend graphs so will hard code.
        // TODO - Allow this to be generic based on selectors choosen to the most granular level (district -> subcounty -> person)
        if (getFieldValue('Type_Of_Graph__c').equals('PieChart')) {
            this.graphColumns.add(new GraphColumnWrapper('number', getFieldValue('yAxis_Title__c'))); 
        }
        else {
            this.graphColumns.add(new GraphColumnWrapper('number', 'Rain Fall MM')); 
       }
    }

    private void initXAxisDate() {

        // Get the start and end dates.
        Date dateToIncrement = getStartDate(true);
        getEndDate(true);

        while (dateToIncrement.daysBetween(getEndDate(true)) >= 0) {
            String displayDate = formatDateDisplay(dateToIncrement);
            rowMap.put(displayDate, new GraphComponentController.GraphRowWrapper(displayDate));
            rowOrder.add(displayDate);
            dateToIncrement = incrementDate(dateToIncrement);
        }
        String displayDate = formatDateDisplay(dateToIncrement);
        rowMap.put(displayDate, new GraphComponentController.GraphRowWrapper(displayDate));
    }

    /**
     * Generates a standard date display that can be used on the xAxis as well as the key to the row map
     */
    private String formatDateDisplay(Date dateToFormat) {

        if (getFieldValue('Date_Period__c').equalsIgnoreCase('Year')) {
            return String.valueOf(dateToFormat.year());
        }
        else {
            return dateToFormat.day() + '/' + dateToFormat.month() + '/' + dateToFormat.year();
        }
    }

    /**
     * Adds a given amount of time to a date
     */
    private Date incrementDate(Date dateToIncrement) {

        if (getFieldValue('Date_Period__c').equalsIgnoreCase('Day')) {
            return dateToIncrement.addDays(1);
        }
        else if (getFieldValue('Date_Period__c').equalsIgnoreCase('Week')) {
            return dateToIncrement.addDays(7);
        }
        else if (getFieldValue('Date_Period__c').equalsIgnoreCase('Month')) {
            return dateToIncrement.addMonths(1);
        }
        else if (getFieldValue('Date_Period__c').equalsIgnoreCase('Quarter')) {
            return dateToIncrement.addMonths(3);
        }
        else {
            return dateToIncrement.addYears(1);
        }
    }

    /**
     * Initialise the data table for this graph.
     * Will display and ApexPage error if a problem occurs
     */
    private Boolean initDataTable() {

        Boolean success = true;

        // Decide upon the type of graph that is required
        String typeOfGraph = getFieldValue('Type_Of_Graph__c');
        System.debug(LoggingLevel.INFO, typeOfGraph);
        if (typeOfGraph.equalsIgnoreCase('LineChart')) {
             success = initTrendDataTable();
        }
        else if (typeOfGraph.equalsIgnoreCase('ColumnChart')) {

            // Not implemented yet so this type should not have been selected so fail
            success = false;
        }
        else if (typeOfGraph.equalsIgnoreCase('BarChart')) {

            // Not implemented yet so this type should not have been selected so fail
            success = false;
        }
        else if (typeOfGraph.equalsIgnoreCase('PieChart')) {
            success = initPieDataTable();
        }
        else {
            success = false;
        }
        return success;
    }

    /**
     *  Each segment of pie is represented by a graph type
     */
    private Boolean initPieDataTable() {

        // Get all the segments of the pie
        Graph_Type__c[] segments = [
            SELECT
                Name,
                Id,
                Type_Of_sObject__c,
                Label__c,
                Keyword__c
            FROM
                Graph_Type__c
            WHERE
                Graph_Parameter__c = :getsObjectRecord().Id];

        for (Graph_Type__c segment : segments) {
            String sObjectName = segment.Type_Of_sObject__c;
            System.debug(LoggingLevel.INFO, sObjectName);
            if (sObjectName.equalsIgnoreCase('Search Log')) {
                this.rowOrder.add(segment.Keyword__c);
                getPieSearchLogValue(segment);
            }
            else if (sObjectName.equalsIgnoreCase('Single Graph Point')) {
                this.rowOrder.add(segment.Label__c);
                getPieSinglePointValue(segment);
            }
            else {
                return false;
            }
        }
        return true;
    }

    private void getPieSinglePointValue(Graph_Type__c segment) {

        String id = segment.Id;
        String queryBase = 'SELECT '             +
                'sum(Value__c) total, '          +
                'Graph_Type__c type '            +
            'FROM '                              +
                'Single_Graph_Point__c '         +
            'WHERE '                             +
                'Graph_Type__r.Id = :id ';
        List<String> whereClauses = generateSinglePointWhereClause();
        String whereClause = '';

        if (whereClauses.size() > 0) {
            whereClause = SoqlHelpers.joinWhereClause(whereClauses, true);
        }
        String query = queryBase + whereClause + 'Group By Graph_Type__c';
        System.debug(LoggingLevel.INFO, query);

        AggregateResult result = Database.query(query);
        GraphComponentController.GraphRowWrapper wrapper = new GraphComponentController.GraphRowWrapper(segment.Label__c);
        if (result != null) {
            wrapper.addValue(String.valueOf(result.get('total')));
        }
        else {
            wrapper.addValue('0');
        }
        this.rowMap.put(segment.Label__c, wrapper);
    }

    private void getPieSearchLogValue(Graph_Type__c segment) {

        AggregateResult result = Database.query(getSearchLogQuery(segment));
        GraphComponentController.GraphRowWrapper wrapper = new GraphComponentController.GraphRowWrapper(segment.Keyword__c);
        if (result != null) {
            wrapper.addValue(String.valueOf(result.get('total')));
        }
        else {
            wrapper.addValue('0');
        }
        this.rowMap.put(segment.Keyword__c, wrapper);
    }

    private String getSearchLogQuery(Graph_Type__c segment) {

        String queryBase = 'SELECT ' +
                'count(id) total '   +
            'FROM '                  +
                'Search_Log__c '     +
            'WHERE '                 +
                'Query__c LIKE \'%' + segment.Keyword__c.replaceAll('_', ' ').replaceAll(' ', '%') + '%\'';
        System.debug(LoggingLevel.INFO, queryBase);
        return queryBase;
    }

    private Boolean initTrendDataTable() {

        Boolean success = true;

        if (getFieldValue('xAxis_Series__c').equalsIgnoreCase('Date')) {
            getSinglePointDateTrendGraph(getSinglePointGraphDataString());
        }

        return success;
    }

    private void getSinglePointDateTrendGraph(String queryString) {

        Integer numberOfRows = this.rowOrder.size();
        Integer counter = 0;
        String currentString = '';

        // Have to include any variable substitution in the query here.
        String id = this.sObjectId;
        for (AggregateResult[] points : database.query(queryString)) {
            for(AggregateResult point : points) {
                String dateString = formatDateDisplay(Date.valueOf(point.get('Group_By_Date__c')));
                Boolean incrementCounter = true;
                while (counter < numberOfRows && !dateString.equals(this.rowOrder.get(counter))) {
                    this.rowMap.get(this.rowOrder.get(counter)).addValue('0');
                    incrementCounter = false;
                    counter++;
                }

                if (counter < numberOfRows) {
                    this.rowMap.get(dateString).addValue(String.valueOf(point.get('total')));
                    if (incrementCounter) {
                        counter++;
                    }
                }
            }
        }
    }

    /**
     *  Methods to generate the query strings that might be needed for the data tables
     */
    private String getSinglePointGraphDataString() {

        String baseString =
            'SELECT '                    +
                'Sum(Value__c) total, '  +
                'Group_By_Date__c '      +
            'FROM '                      +
                'Single_Graph_Point__c ' +
            'WHERE '                     +
                'Graph_Type__r.Graph_Parameter__r.Id = :id ';

        List<String> whereClauses = generateSinglePointWhereClause();
        String whereClause = '';

        if (whereClauses.size() > 0) {
            whereClause = SoqlHelpers.joinWhereClause(whereClauses, true);
        }
        String query = baseString + whereClause + getGroupByClause() + getOrderByClause();
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private List<String> generateSinglePointWhereClause() {

        List<String> whereClauses = new List<String>();

        // Get the parameters if there are any
        if (this.getParentComponentController() != null) {
            if (!this.getParentValue('District__c').equals('')) {
                whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.District__c', this.getParentValue('District__c'), true));
            }
            if (!this.getParentValue('Subcounty__c').equals('')) {
                whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.Subcounty__c', this.getParentValue('Subcounty__c'), true));
            }
        }

        // Distinguish by dates
        if (getStartDate(true) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate(true)), false), false));
        }
        if (getEndDate(true) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate(true)), false), false));
        }
        return whereClauses;
    }

    private String getGroupByClause() {

        return ' GROUP BY Group_By_Date__c';
    }

    private String getOrderByClause() {

        String clause = ' ORDER BY Group_By_Date__c';
        return clause;
    }

    /**
     *  Public class for the data table rows
     */
     public class GraphRowWrapper {

        private String header;
        private List<String> values;

        public GraphRowWrapper(
                String header
        ) {
            this.header = header;
            this.values = new List<String>();
        }

        public void addValue(String value) {
            this.values.add(value);
        }

        public String toJsonString() {

            String jsonString = '{c:[{v:\'' + this.header + '\'}';
            for (Integer i = 0; i < values.size(); i++) {
                jsonString += ', {v: ' + this.values.get(i) + ' }';
            }
            jsonString += ']}';
            return jsonString;
        }
     }

    static testMethod void testGetFieldValue() {

        Person__c person = Utils.createTestPerson('This_is_a_Test', '_of_the_emerg', true, null, 'Male');
        Database.insert(person);

        Account account = new Account();
        account.Name = 'Account';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        Database.insert(section);

        String title = 'New Graph';
        Graph_Parameter__c graph = new Graph_Parameter__c();
        graph.Dashboard_Section__c = section.Id;
        graph.Title__c = title;
        graph.Type_Of_Graph__c = 'LineChart';
        graph.Is_Active__c = true;
        graph.Date_Period__c = 'Day';
        graph.xAxis_Series__c = 'Date';
        graph.xAxis_Title__c = 'Hi';
        graph.Show_Data_Inline__c = true;
        Database.insert(graph);

        Graph_Type__c graphType = new Graph_Type__c();
        graphType.Graph_Parameter__c = graph.Id;
        Database.insert(graphType);


        List<Single_Graph_Point__c> sgps = new List<Single_Graph_Point__c>();
        Single_Graph_Point__c sgp1 = new Single_Graph_Point__c();
        sgp1.Person__c = person.Id;
        sgp1.Graph_Type__c = graphType.Id;
        sgp1.Date__c = Date.today();
        sgp1.Value__c = 5.0;
        sgps.add(sgp1);

        Single_Graph_Point__c sgp2 = new Single_Graph_Point__c();
        sgp2.Person__c = person.Id;
        sgp2.Graph_Type__c = graphType.Id;
        sgp2.Date__c = Date.today().addDays(-2);
        sgp2.Value__c = 2.0;
        sgps.add(sgp2);

        Single_Graph_Point__c sgp3 = new Single_Graph_Point__c();
        sgp3.Person__c = person.Id;
        sgp3.Graph_Type__c = graphType.Id;
        sgp3.Date__c = Date.today().addDays(-3);
        sgp3.Value__c = 10.0;
        sgps.add(sgp3);
        Database.insert(sgps);


        GraphComponentController controller = new GraphComponentController();
        controller.setExpanded(true);
        controller.setsObjectId(graph.Id);
        Boolean loaded = controller.loadGraphParameter();
        System.assert(loaded);
        System.assert(controller.getFieldValue('Title__c').equals(title));

        String json = controller.getJson();
        System.debug(LoggingLevel.INFO, json);

        Graph_Parameter__c graph2 = new Graph_Parameter__c();
        graph2.Dashboard_Section__c = section.Id;
        graph2.Title__c = title;
        graph2.Type_Of_Graph__c = 'PieChart';
        graph2.Is_Active__c = true;
        graph2.Date_Period__c = 'Day';
        graph2.xAxis_Series__c = 'Date';
        graph2.xAxis_Title__c = 'Hi';
        Database.insert(graph2);

        Graph_Type__c graphType2 = new Graph_Type__c();
        graphType2.Graph_Parameter__c = graph2.Id;
        Database.insert(graphType2);

        List<Single_Graph_Point__c> sgps2 = new List<Single_Graph_Point__c>();
        Single_Graph_Point__c sgp11 = new Single_Graph_Point__c();
        sgp11.Person__c = person.Id;
        sgp11.Graph_Type__c = graphType2.Id;
        sgp11.Date__c = Date.today();
        sgp11.Value__c = 5.0;
        sgps2.add(sgp11);

        Single_Graph_Point__c sgp21 = new Single_Graph_Point__c();
        sgp21.Person__c = person.Id;
        sgp21.Graph_Type__c = graphType2.Id;
        sgp21.Date__c = Date.today().addDays(-2);
        sgp21.Value__c = 2.0;
        sgps2.add(sgp21);

        Single_Graph_Point__c sgp31 = new Single_Graph_Point__c();
        sgp31.Person__c = person.Id;
        sgp31.Graph_Type__c = graphType2.Id;
        sgp31.Date__c = Date.today().addDays(-3);
        sgp31.Value__c = 10.0;
        sgps2.add(sgp31);
        Database.insert(sgps2);
        loaded = controller.loadGraphParameter();
        System.assert(loaded);
        System.assert(controller.getFieldValue('Title__c').equals(title));

        json = controller.getJson();
        controller.getIsRefresh();
        controller.getLegendColor();
        controller.getShowDataInline();
        controller.getTitle();
        controller.getTitleColor();
        controller.getTypeOfGraph();
        controller.getXAxisColor();
        controller.getHeight();
        controller.getWidth();
        controller.getXAxisTitle();
        controller.getYAxisColor();
        controller.getYAxisTitle();
        controller.refreshData();
    }

    static testMethod void testJson() {

        GraphComponentController controller = new GraphComponentController();
        GraphComponentController.GraphRowWrapper wrap = new GraphComponentController.GraphRowWrapper('ME');
        wrap.addValue('1');
        wrap.addValue('2');
        wrap.addValue('3');
        System.debug(LoggingLevel.INFO, wrap.toJsonString());//{c:[{v:'ME'}, {v: 1 }, {v: 2 }, {v: 3 }]}
        System.debug(LoggingLevel.INFO, JSON.serialize(wrap));//{"values":["1","2","3"],"header":"ME"}
    }
}