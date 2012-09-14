/**
 * Controller to generate the graphs for the field officer dashboard(extended page)
 */
public with sharing class FieldOfficerGraphController extends ChildComponentBase {

    // Columns on the graph
    private List<GraphColumnWrapper> graphColumns;

    // Order that the rows will be displayed on the graph in
    Transient Set<String> rowOrder;

    // Map of the rows. Uses a private row wrapper class. Transient as this will change
    // on each page load
    Transient Map<String, FieldOfficerGraphController.GraphRowWrapper> rowMap;

    private Boolean isLoaded = false;

    // As this is a special case of the generic graph controller.
    // Will use the value in the xAxis title as that will not be used in the graph.
    // The xAxis title is generated on the fly
    private String graphIdentifier;
    public String getGraphIdentifier() {
        return this.graphIdentifier;
    }
    public void setGraphIdentifier(String value) {
        this.graphIdentifier = value;
    }

    /**
     * Initialise the graph. This will load the graph parameter object.
     */
    private Boolean init() {

        if (!getShowData()) {
            return false;
        }

        // Load the graph parameter
        if (!isLoaded) {
            isLoaded = loadGraphParameter();
        }

        // Reload the parents parameters
        this.getParentComponentController().rebuildParameters();

        // Rebuild the dates
        setDates();

        this.rowMap = new Map<String, FieldOfficerGraphController.GraphRowWrapper>();
        this.rowOrder = new Set<String>();
        this.graphColumns = new List<GraphColumnWrapper>();

        // Decide the graph that is to be loaded. The value here needs to match
        // what is passed in from the componenet and the value of an xAxis Title for a Graph_Parameter__c
        if (getGraphIdentifier().equals('TotalSubmission')) {
            return loadTotalSubmissions();
        }
        else if (getGraphIdentifier().equals('CkwMajorIssue')) {
            return loadCkwMajorIssue();
        }
        else if (getGraphIdentifier().equals('CkwLevelOfEngagement')) {
            return loadCkwLevelOfEngagement();
        }
        else if (getGraphIdentifier().equals('FarmerConcerns')) {
            return loadFarmerConcerns();
        }
        else if (getGraphIdentifier().equals('FarmerRating')) {
            return loadFarmerRating();
        }
        else if (getGraphIdentifier().equals('FarmersAttending')) {
            return loadAttendance();
        }
        else if (getGraphIdentifier().equals('FarmerUsed')) {
            return loadFarmerConcerns();
        }
        else if (getGraphIdentifier().equals('FarmerAdopted')) {
            return loadFarmerRating();
        }
        else {

            // Unrecognised graph so mention that and throw an error
            System.debug(LoggingLevel.INFO, 'Graph with identifier: ' + getGraphIdentifier() + ' does not exist in SFDC check set up');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The graph type you are trying to load does not exist. Please contact support'));
            return false;
        }
        return true;
    }

    // Getter methods for the graph settings
    public String getTypeOfGraph() {
        return getFieldValue('type_of_graph__c');
    }

    public String getXAxisTitle() {
        return 'Field Officers';
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

        String title = translateGraphType(getGraphIdentifier());
        title += ' between ' + getStartDate().format() + ' and ' + getEndDate().format(); 
        return title;
    }

    // Allows a sensible name to be displayed as the graph title
    private String translateGraphType(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            'TotalSubmission' => 'Total Submissions',
            'CkwMajorIssue' => 'CKW Major Issues',
            'CkwLevelOfEngagement' => 'CKW Level of Engagement',
            'FarmerConcerns' => 'Farmer Major Concerns',
            'FarmerRating' => 'Farmer Rating',
            'FarmersAttending' => 'Farmers Attending',
            'FarmerUsed' => 'Farmer Used',
            'FarmerAdopted' => 'Farmer Adoption'
        };
        return translationMap.get(optionNumber);
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

    /**
     * Load the Graph_Parameter__c for this graph
     */
    private boolean loadGraphParameter() {

        if (this.graphIdentifier == null) {
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
                xAxis_Title__c = :this.graphIdentifier
                AND Is_Active__c = true
        ];
        if (param.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No active graph definition found for identifier ' + this.graphIdentifier + '. Please check your set up.'));
            return false;
        }
        setsObjectRecord((sObject)param[0]);
        this.sObjectName = 'Graph_Parameter__c';
        return true;
    }

    /**
     * Method to override the standard setDate method. Uses the quarter selector.
     */
    private void setDates() {

        List<Date> dates = MetricHelpers.getStartEndDates(getParentValue('metricDatePicker'), getParentValue('DatePeriod'));
        setStartDate(dates[0]);
        setEndDate(dates[1]);
    }

    /**
     * Getter and Setter for the Json string the represents the graph.
     */
    public String json;
    public String getJson() {
        setJson(loadJson());
        this.isLoaded = true;
        return this.json;
    }
    public void setJson(String newJson) {
        this.json = newJson;
    }

    private String loadJson() {

        // Set width and the height for the graphs
        setWidth('860');
        setHeight('600');

        String json = 'FAIL';
        init();

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
        i = 0;
        for (String key : this.rowOrder) {
            jsonString += this.rowMap.get(key).toJsonString();
            if (i < numberOfRows - 1) {
                jsonString += ', ';
            }
            i++;
        }
        jsonString += ']}';
        System.debug(LoggingLevel.INFO, jsonString);

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
       return jsonString;
    }

    /**
     * Get data for the total submission graph
     */
    private Boolean loadTotalSubmissions() {

        String query =
            'SELECT ' +
                'COUNT(id) total ' +
                getSelectClause() +
                ', Submission_Type__c type ' +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('Submission_Type__c');
        System.debug(LoggingLevel.INFO, query);
        Map<String, SubmissionWrapper> submissionMap = new Map<String,SubmissionWrapper>();
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }

                this.rowOrder.add(identifier);

                SubmissionWrapper submission = submissionMap.get(identifier);
                if (submission == null) {
                    submission = new SubmissionWrapper(header);
                }
                if (String.valueOf(res.get('type')).equals('FO/CKW 1:1')) {
                    submission.setOneOnOne(String.valueOf(res.get('total')));
                }
                else if (String.valueOf(res.get('type')).equals('PEER GROUP SESSION')) {
                    submission.setPeerGroup(String.valueOf(res.get('total')));
                }
                else if (String.valueOf(res.get('type')).equals('HIGH PERFORMER CALLS')) {
                    submission.setHighPerformer(String.valueOf(res.get('total')));
                }
                else {
                    submission.setFarmerGroup(String.valueOf(res.get('total')));
                }
                submissionMap.put(identifier, submission);
            }
        }

        // Get the targets
        submissionMap = getTargets(submissionMap);

        // Loop through the map and create the row wrappers
        for (String key : submissionMap.keySet()) {
            FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(submissionMap.get(key).getHeader());
            wrapper.addValue(submissionMap.get(key).getOneOnOne());
            wrapper.addValue(submissionMap.get(key).getOneOnOneTarget());
            wrapper.addValue(submissionMap.get(key).getPeerGroup());
            wrapper.addValue(submissionMap.get(key).getPeerGroupTarget());
            wrapper.addValue(submissionMap.get(key).getHighPerformer());
            wrapper.addValue(submissionMap.get(key).getHighPerformerTarget());
            wrapper.addValue(submissionMap.get(key).getFarmerGroup());
            wrapper.addValue(submissionMap.get(key).getFarmerGroupTarget());
            this.rowMap.put(key, wrapper);
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'One On One'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'One On One Target'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Peer Group'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Peer Group Target'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'High Performer'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'High Performer Target'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Farmer Group'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Farmer Group Target'));
        return true;

    }

    /**
     * Get the target month for this month
     */
    private Map<String, SubmissionWrapper> getTargets(Map<String, SubmissionWrapper> submissionMap) {

        String query =
            'SELECT ' +
                'SUM(One_On_One_Target__c) o, ' +
                'SUM(Peer_Group_Target__c) p, ' +
                'SUM(High_Performer_Target__c) h, ' +
                'SUM(Farmer_Group_Target__c) f ' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity_Targets__c ' +
                generateWhereClause(true, false) +
                ' AND Live_Target__c = true ' +
                getGroupClause('');

        for (AggregateResult[] targets : database.query(query)) {
            for (AggregateResult target : targets) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(target.get('lastName')) + ' ' + String.valueOf(target.get('firstName'));
                    identifier = String.valueOf(target.get('id'));
                }
                SubmissionWrapper submission = submissionMap.get(identifier);
                if (submission == null) {
                    continue;
                }
                submission.setOneOnOneTarget(String.valueOf(target.get('o')));
                submission.setPeerGroupTarget(String.valueOf(target.get('p')));
                submission.setHighPerformerTarget(String.valueOf(target.get('h')));
                submission.setFarmerGroupTarget(String.valueOf(target.get('f')));
                submissionMap.put(identifier, submission);
            }
        }
        return submissionMap;
    }

    /**
     * Get data for the total submission graph
     */
    private Boolean loadCkwMajorIssue() {

        String query =
            'SELECT ' +
                'SUM(Major_Retrain__c) retrain, ' +
                'SUM(Major_Phone__c) phone, ' +
                'SUM(Major_Personal__c) personal, ' +
                'SUM(Major_Payment__c) payment, ' +
                'SUM(Major_Other__c) other, ' +
                'SUM(Major_Network__c) network, ' +
                'SUM(Major_Charge__c) charge' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }

                this.rowOrder.add(identifier);

                FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('retrain')));
                wrapper.addValue(String.valueOf(res.get('charge')));
                wrapper.addValue(String.valueOf(res.get('payment')));
                wrapper.addValue(String.valueOf(res.get('phone')));
                wrapper.addValue(String.valueOf(res.get('network')));
                wrapper.addValue(String.valueOf(res.get('personal')));
                wrapper.addValue(String.valueOf(res.get('other')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Needs Retraining')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Charging solution'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Payment'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Phone/technical issue'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Network/data access'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Personal'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Other'));
        return true;
    }

    /**
     * Get data for the total submission graph
     */
    private Boolean loadCkwLevelOfEngagement() {

        String query =
            'SELECT ' +
                'COUNT(id) total ' +
                getSelectClause() +
                ', CKW_Motivation__c motivation ' +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                ' AND CKW_Motivation__c != null ' +
                getGroupClause('CKW_Motivation__c');
        System.debug(LoggingLevel.INFO, query);
        Map<String, CkwLevelEngagement> ckwMap = new Map<String, CkwLevelEngagement>();
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }

                this.rowOrder.add(identifier);

                CkwLevelEngagement ckw = ckwMap.get(identifier);
                if (ckw == null) {
                    ckw = new CkwLevelEngagement(header);
                }
                if (String.valueOf(res.get('motivation')).equals('Highly Motivated')) {
                    ckw.setHigh(String.valueOf(res.get('total')));
                }
                else if (String.valueOf(res.get('motivation')).equals('Neutral')) {
                    ckw.setMed(String.valueOf(res.get('total')));
                }
                else {
                    ckw.setLow(String.valueOf(res.get('total')));
                }
                ckwMap.put(identifier, ckw);
            }
        }

        // Loop through the map and create the row wrappers
        for (String key : ckwMap.keySet()) {
            FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(ckwMap.get(key).getHeader());
            wrapper.addValue(ckwMap.get(key).getHigh());
            wrapper.addValue(ckwMap.get(key).getMed());
            wrapper.addValue(ckwMap.get(key).getLow());
            this.rowMap.put(key, wrapper);
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Highly Motivated'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Neutral'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Demotivated'));
        return true;
    }

    /**
     * Get data for the total submission graph
     */
    private Boolean loadFarmerConcerns() {

        String query =
            'SELECT ' +
                'SUM(Major_Farmer_Access__c) access, ' +
                'SUM(Major_Farmer_Content__c) content, ' +
                'SUM(Major_Farmer_Project__c) project, ' +
                'SUM(Major_Farmer_Regional__c) regional, ' +
                'SUM(Major_Farmer_Other__c) other ' +
                getSelectClause()+
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }

                this.rowOrder.add(identifier);

                FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('project')));
                wrapper.addValue(String.valueOf(res.get('content')));
                wrapper.addValue(String.valueOf(res.get('access')));
                wrapper.addValue(String.valueOf(res.get('regional')));
                wrapper.addValue(String.valueOf(res.get('other')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Content requests')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Additional support'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Access to local CKW'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Regional/environmental issues'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Other'));
        return true;
    }

    /**
     * Get data for the total submission graph
     */
    private Boolean loadFarmerRating() {

        String query =
            'SELECT ' +
                'COUNT(id) total ' +
                getSelectClause() +
                ', Farmers_Opinion__c motivation ' +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                ' AND Farmers_Opinion__c != null ' +
                getGroupClause('Farmers_Opinion__c');
        System.debug(LoggingLevel.INFO, query);
        Map<String, CkwLevelEngagement> ckwMap = new Map<String, CkwLevelEngagement>();
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }
                this.rowOrder.add(identifier);

                CkwLevelEngagement ckw = ckwMap.get(identifier);
                if (ckw == null) {
                    ckw = new CkwLevelEngagement(header);
                }
                if (String.valueOf(res.get('motivation')).equals('Excellent/Helpful')) {
                    ckw.setHigh(String.valueOf(res.get('total')));
                }
                else if (String.valueOf(res.get('motivation')).equals('Neutral')) {
                    ckw.setMed(String.valueOf(res.get('total')));
                }
                else {
                    ckw.setLow(String.valueOf(res.get('total')));
                }
                ckwMap.put(identifier, ckw);
            }
        }

        // Loop through the map and create the row wrappers
        for (String key : ckwMap.keySet()) {
            FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(ckwMap.get(key).getHeader());
            wrapper.addValue(ckwMap.get(key).getHigh());
            wrapper.addValue(ckwMap.get(key).getMed());
            wrapper.addValue(ckwMap.get(key).getLow());
            this.rowMap.put(key, wrapper);
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Excellent/Helpful'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Neutral'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Poor/ Not revelant'));
        return true;
    }

    /**
     * Total number of farmers that went to group
     */
    private Boolean loadAttendance() {

        String query =
            'SELECT ' +
                'SUM(Farmers_Present__c) attendance ' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }

                this.rowOrder.add(identifier);

                FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('attendance')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Farmer Attendance')); 
        return true;
    }

    /**
     * Total number of farmers that went to group
     */
    private Boolean loadAdoption() {

        String query =
            'SELECT ' +
                'SUM(Adoption__c) adoption ' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }
                this.rowOrder.add(identifier);

                FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('adoption')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Adopt Techniques')); 
        return true;
    }

    /**
     * Total number of farmers who use CKWs
     */
    private Boolean loadUseCkws() {

        String query =
            'SELECT ' +
                'SUM(Used_Ckw__c) use ' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                String header = 'All Field Officers';
                String identifier = 'all';
                if (!showRegion()) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('id'));
                }
                this.rowOrder.add(identifier);

                FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('use')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Use CKWs')); 
        return true;
    }


    /**
     * Generate the where clause from the selectors
     *
     * @param addWhere             - Boolean to indicate that a WHERE should start the returned query.
     *                                  If true ignores startWithAnd as both cannot happen
     * @param startWithAnd         - Boolean to indicate that an AND should start the returned query
     *
     * @return - The where clause
     */
    private String generateWhereClause(Boolean addWhere, Boolean startWithAnd) {

        List<String> clauses = new List<String>();
        if (!getParentValue('Person__c').equals('') && !getParentValue('Person__c').equals('All')) {
            clauses.add('Field_Officer__c/ = \'' + getParentValue('Person__c') + '\'');
        }
        if (getStartDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate()), true), false));
        }
        if (getEndDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate()), true), false));
        }
        return FieldOfficeHelpers.joinWhereClause(clauses, addWhere, startWithAnd) + ' ';
    }

    /**
     * Gets the select clause. This depends on if we are seeing total or by region
     */
    private String getSelectClause() {

        String clause = '';
        if (!showRegion()) {
            clause = ', ' +
                'Field_Officer__c id, ' +
                'Field_Officer__r.Last_Name__c lastName, ' +
                'Field_Officer__r.First_Name__c firstName ';
        }
        return clause;
    }

    /**
     * Gets the select clause. This depends on if we are seeing total or by region
     */
    private String getGroupClause(String startGroup) {

        String clause = '';
        if (!showRegion()) {
            if (!startGroup.equals('')) {
                startGroup += ', ';
            }
            clause = ' GROUP BY ' +
                startGroup + 
                'Field_Officer__c, ' +
                'Field_Officer__r.Last_Name__c, ' +
                'Field_Officer__r.First_Name__c ' +
            ' ORDER BY ' +
                'Field_Officer__r.Last_Name__c, ' +
                'Field_Officer__r.First_Name__c';
        }
        else if (!startGroup.equals('')) {
            clause = ' GROUP BY ' + startGroup + ' ';
        }
        return clause;
    }

    private String getColumnName() {
        if (showRegion()) {
            return 'All F/Os';
        }
        return 'Field Officer';
    }

    private Boolean showRegion() {
        return getParentValue('Person__c').equals('All');
    }

    /**
     * Refresh the graph individually
     */
    public override PageReference refreshData() {
        return null;
    }

    // Test methods for the controller
    static testMethod void testController() {

        PageReference pageRef = Page.FieldOfficerBreakDown;
        pageRef.getParameters().put('type', 'graph');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        FieldOfficerBreakDownController parent = new FieldOfficerBreakDownController();
        parent.setParentMap('DashboardSelectorKey', new ParentComponentBase());
        parent.getParentMap().get('DashboardSelectorKey').addParameter('metricDatePickerkey', MetricHelpers.createDispRollOverString(Date.today(), 'Monthly'));
        parent.getParentMap().get('DashboardSelectorKey').addParameter('DatePeriodkey', 'Monthly');

        FieldOfficerGraphController controller = new FieldOfficerGraphController();
        controller.setKey('graph');
        controller.setSectionKey('key');
        controller.setParentComponentController(parent);
        controller.setShowData(true);
        controller.setExpanded(false);

        controller.setGraphIdentifier('TotalSubmission');
        controller.init();

        // Test general getters
        controller.getTypeOfGraph();
        controller.getXAxisTitle();
        controller.getXAxisColor();
        controller.getYAxisTitle();
        controller.getYAxisColor();

        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('CkwMajorIssue');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('CkwLevelOfEngagement');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('FarmerConcerns');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('FarmerRating');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('FarmersAttending');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('FarmerUsed');
        controller.init();
        controller.loadJson();
        controller.isLoaded = false;
        controller.rowMap.clear();
        controller.rowOrder.clear();
        controller.setGraphIdentifier('FarmerAdopted');
        controller.init();
        controller.loadJson();
    }

    /**
     * Wrapper class for a row in the data table
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

    static testMethod void testGraphRowWrapper() {

        FieldOfficerGraphController.GraphRowWrapper wrapper = new FieldOfficerGraphController.GraphRowWrapper('It was a');
        wrapper.addValue('Rock');
        wrapper.addValue('Lobster');
        System.assertEquals(wrapper.toJsonString(), '{c:[{v:\'It was a\'}, {v: Rock }, {v: Lobster }]}');
    }

    /**
     * Private class that stores the submission details
     */
    private class SubmissionWrapper {
        private String oneOnOne;
        private String oneOnOneTarget;
        private String peerGroup;
        private String peerGroupTarget;
        private String highPerformer;
        private String highPerformerTarget;
        private String farmerGroup;
        private String farmerGroupTarget;
        private String header;

        public SubmissionWrapper(String header) {
            this.header = header;
            this.oneOnOne = '0';
            this.oneOnOneTarget = '0';
            this.peerGroup = '0';
            this.peerGroupTarget = '0';
            this.highPerformer = '0';
            this.highPerformerTarget = '0';
            this.farmerGroup = '0';
            this.farmerGroupTarget = '0';
        }

        public String getHeader() {
            return this.header;
        }

        public String getOneOnOne() {
            return this.oneOnOne;
        }
        public void setOneOnOne(String value) {
            this.oneOnOne = value;
        }

        public String getOneOnOneTarget() {
            return this.oneOnOneTarget;
        }
        public void setOneOnOneTarget(String value) {
            this.oneOnOneTarget = value;
        }

        public String getPeerGroup() {
            return this.peerGroup;
        }
        public void setPeerGroup(String value) {
            this.peerGroup = value;
        }

        public String getPeerGroupTarget() {
            return this.peerGroupTarget;
        }
        public void setPeerGroupTarget(String value) {
            this.peerGroupTarget = value;
        }

        public String getHighPerformer() {
            return this.highPerformer;
        }
        public void setHighPerformer(String value) {
            this.highPerformer = value;
        }

        public String getHighPerformerTarget() {
            return this.highPerformerTarget;
        }
        public void setHighPerformerTarget(String value) {
            this.highPerformerTarget = value;
        }

        public String getFarmerGroup() {
            return this.farmerGroup;
        }
        public void setFarmerGroup(String value) {
            this.farmerGroup = value;
        }

        public String getFarmerGroupTarget() {
            return this.farmerGroupTarget;
        }
        public void setFarmerGroupTarget(String value) {
            this.farmerGroupTarget = value;
        }
    }

    static testMethod void testSubmissionWrapper() {

        FieldOfficerGraphController.SubmissionWrapper wrapper = new FieldOfficerGraphController.SubmissionWrapper('You\'ll');
        System.assertEquals(wrapper.getHeader(), 'You\'ll');
        wrapper.setOneOnOne('take');
        System.assertEquals(wrapper.getOneOnOne(), 'take');
        wrapper.setOneOnOneTarget('the');
        System.assertEquals(wrapper.getOneOnOneTarget(), 'the');
        wrapper.setPeerGroup('ride');
        System.assertEquals(wrapper.getPeerGroup(), 'ride');
        wrapper.setPeerGroupTarget('to');
        System.assertEquals(wrapper.getPeerGroupTarget(), 'to');
        wrapper.setHighPerformer('leave');
        System.assertEquals(wrapper.getHighPerformer(), 'leave');
        wrapper.setHighPerformerTarget('this');
        System.assertEquals(wrapper.getHighPerformerTarget(), 'this');
        wrapper.setFarmerGroup('town');
        System.assertEquals(wrapper.getFarmerGroup(), 'town');
        wrapper.setFarmerGroupTarget('along');
        System.assertEquals(wrapper.getFarmerGroupTarget(), 'along');
    }

    /**
     * Private class for the ckw level of engagement
     */
    private class CkwLevelEngagement {
        private String high;
        private String med;
        private String low;
        private String header;

        public CkwLevelEngagement(String header) {
            this.header = header;
            this.high = '0';
            this.med = '0';
            this.low = '0';
        }

        public String getHeader() {
            return this.header;
        }

        public String getHigh() {
            return this.high;
        }
        public void setHigh(String value) {
            this.high = value;
        }

        public String getMed() {
            return this.med;
        }
        public void setMed(String value) {
            this.med = value;
        }

        public String getLow() {
            return this.low;
        }
        public void setLow(String value) {
            this.low = value;
        }
    }

    static testMethod void testCkwLevelEngagementWrapper() {

        FieldOfficerGraphController.CkwLevelEngagement wrapper = new FieldOfficerGraphController.CkwLevelEngagement('AFGAMISTAM');
        System.assertEquals(wrapper.getHeader(), 'AFGAMISTAM');
        wrapper.setHigh('that');
        System.assertEquals(wrapper.getHigh(), 'that');
        wrapper.setMed('yellow');
        System.assertEquals(wrapper.getMed(), 'yellow');
        wrapper.setLow('line');
        System.assertEquals(wrapper.getLow(), 'line');
    }
}