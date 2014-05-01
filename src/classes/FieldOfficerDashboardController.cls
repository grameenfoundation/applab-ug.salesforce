/**
 * Class for the controller of the field officer dashboard
 */
public with sharing class FieldOfficerDashboardController extends ParentComponentBase {

    public FieldOfficerDashboardController() {
        loadSelector();
        setDates();
        loadData();
    }

    private Boolean selectorLoaded = false;

    // The selector object that controls the display
    private Dashboard_Selector__c selector;
    private void loadSelector() {
        this.selector = [
            SELECT
                Name,
                Id,
                Show_Dates__c,
                Show_Metric_Date_Selector__c,
                Show_Country__c,
                Show_Region__c,
                Show_District__c,
                Show_Subcounty__c,
                Show_Person__c,
                Show_Data_Validator__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_Field_Officer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Show_Submit_Button__c,
                Show_Brac_Area__c,
                Show_Brac_PA__c,
                Start_Date__c
            FROM
                Dashboard_Selector__c
            WHERE
                Name 
                  IN 
                ('DSC0000000004', 'DSC0000000103')
        ];
        this.selectorLoaded = true;
    }
    public Dashboard_Selector__c getSelector() {

        if (!this.selectorLoaded) {
            loadSelector();
        }
        return this.selector;
    }

    public String getSelectorId() {

        if (!this.selectorLoaded) {
            loadSelector();
        }
        return String.valueOf(this.selector.Id);
    }

    // Get the parameters out from the selector on the page
    public override void rebuildParameters() {

        // As this is called from the constructor the selector will not be set up at this point so no
        // selector in the parent map
        if (this.getParentMap() != null && this.getParentMap().containsKey('DashboardSelectorKey')) {
            this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
            this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
        }
    }


    // Define the basic data free layout of the dashboard
    private Map<String, Map<String, RowWrapper>> rowWrappers;
    public List<RowWrapper> getOne() {
        List<RowWrapper> oneList = new List<RowWrapper>();
        oneList.add(rowWrappers.get('one').get('oneSurvey'));
        oneList.add(rowWrappers.get('one').get('oneIssues'));
        oneList.add(rowWrappers.get('one').get('oneLevel'));
        oneList.add(rowWrappers.get('one').get('oneComment'));
        return oneList;
    }

    public List<RowWrapper> getPeer() {
        List<RowWrapper> peerList = new List<RowWrapper>();
        peerList.add(rowWrappers.get('peer').get('peerSurvey'));
        peerList.add(rowWrappers.get('peer').get('peerComment'));
        return peerList;
    }

    public List<RowWrapper> getHigh() {
        List<RowWrapper> highList = new List<RowWrapper>();
        highList.add(rowWrappers.get('high').get('highSurvey'));
        highList.add(rowWrappers.get('high').get('highComment'));
        return highList;
    }

    public List<RowWrapper> getFarmer() {
        List<RowWrapper> farmerList = new List<RowWrapper>();
        farmerList.add(rowWrappers.get('farmer').get('farmerSurvey'));
        farmerList.add(rowWrappers.get('farmer').get('farmerAttend'));
        farmerList.add(rowWrappers.get('farmer').get('farmerConcern'));
        farmerList.add(rowWrappers.get('farmer').get('farmerRating'));
        farmerList.add(rowWrappers.get('farmer').get('farmerUsed'));
        farmerList.add(rowWrappers.get('farmer').get('farmerAdopted'));
        farmerList.add(rowWrappers.get('farmer').get('farmerComment'));
        return farmerList;
    }

    /**
     * Generates the rows for each of the surveys
     */
    private void loadData() {

        initRowMap();

        // Get the quantity of surveys carried out
        getSurveySubmissions();

        // Get the totals for the farmer group
        getFarmerTotals();
    }

    /**
     * Set up the row map
     */
    private void initRowMap() {

        // Init one on one map
        this.rowWrappers = new Map<String, Map<String, RowWrapper>>();
        Map<String, RowWrapper> oneMap = new Map<String, RowWrapper> {
            'oneSurvey' => new RowWrapper('Total number of submissions', 'graph', 'TotalSubmission', 'Show Graph'),
            'oneIssues' => new RowWrapper('Total Number Of Issues Facing CKWs', 'graph', 'CkwMajorIssue', 'Show Graph'),
            'oneLevel' => new RowWrapper('CKW Level of Engagement', 'graph', 'CkwLevelOfEngagement', 'Show Graph'),
            'oneComment' => new RowWrapper('Additional Comments', 'comment', 'one', 'Show Comments')
        };
        this.rowWrappers.put('one', oneMap);

        // Init peer group map
        Map<String, RowWrapper> peerMap = new Map<String, RowWrapper> {
            'peerSurvey' => new RowWrapper('Total number of submissions', 'graph', 'TotalSubmission', 'Show Graph'),
            'peerComment' => new RowWrapper('Aditional Comments', 'comment', 'peer', 'Show Comments')
        };
        this.rowWrappers.put('peer', peerMap);

        // Init high performer map
        Map<String, RowWrapper> highMap = new Map<String, RowWrapper> {
            'highSurvey' => new RowWrapper('Total number of submissions', 'graph', 'TotalSubmission', 'Show Graph'),
            'highComment' => new RowWrapper('Aditional Comments', 'comment', 'high', 'Show Comments')
        };
        this.rowWrappers.put('high', highMap);

        // Init farmer group map
        Map<String, RowWrapper> farmerMap = new Map<String, RowWrapper> {
            'farmerSurvey' => new RowWrapper('Total number of submissions', 'graph', 'TotalSubmission', 'Show Graph'),
            'farmerAttend' => new RowWrapper('Total number of farmers attending', 'graph', 'FarmersAttending', 'Show Graph'),
            'farmerConcern' => new RowWrapper('Issues faced by farmers', 'graph', 'FarmerConcerns', 'Show Graph'),
            'farmerRating' => new RowWrapper('Farmer\'s opinion of the CKW project', 'graph', 'FarmerRating', 'Show Graph'),
            'farmerUsed' => new RowWrapper('Have used service atleast twice', 'graph', 'FarmerUsed', 'Show Graph'),
            'farmerAdopted' => new RowWrapper('Have adopted 1 technique in past month', 'graph', 'FarmerAdopted', 'Show Graph'),
            'farmerComment' => new RowWrapper('Aditional Comments', 'comment', 'farmer', 'Show Comments')
        };
        this.rowWrappers.put('farmer', farmerMap);
    }

    /**
     * Get the submissions and their targets for the 
     */
    private void getSurveySubmissions() {

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
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                if (String.valueOf(res.get('type')).equals('FO/CKW 1:1')) {
                    this.rowWrappers.get('one').get('oneSurvey').setActual((Decimal)res.get('total'));
                }
                else if (String.valueOf(res.get('type')).equals('PEER GROUP SESSION')) {
                    this.rowWrappers.get('peer').get('peerSurvey').setActual((Decimal)res.get('total'));
                }
                else if (String.valueOf(res.get('type')).equals('HIGH PERFORMER CALLS')) {
                    this.rowWrappers.get('high').get('highSurvey').setActual((Decimal)res.get('total'));
                }
                else {
                    this.rowWrappers.get('farmer').get('farmerSurvey').setActual((Decimal)res.get('total'));
                }
            }
        }

        // Get the targets
        getTargets();
    }

    /**
     * Get the target month for this month
     */
    private void getTargets() {

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
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] targets : database.query(query)) {
            for (AggregateResult target : targets) {
                this.rowWrappers.get('one').get('oneSurvey').setTarget(String.valueOf(target.get('o')));
                this.rowWrappers.get('peer').get('peerSurvey').setTarget(String.valueOf(target.get('p')));
                this.rowWrappers.get('high').get('highSurvey').setTarget(String.valueOf(target.get('h')));
                this.rowWrappers.get('farmer').get('farmerSurvey').setTarget(String.valueOf(target.get('f')));
            }
        }
    }

    private void getFarmerTotals() {

        String query =
            'SELECT ' +
                'SUM(Farmers_Present__c) attendance, ' +
                'SUM(Adoption__c) adoption, ' +
                'SUM(Used_Ckw__c) use ' +
                getSelectClause() +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
                generateWhereClause(true, false) +
                getGroupClause('');
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {
                this.rowWrappers.get('farmer').get('farmerAttend').setActual((Decimal)res.get('attendance'));
                this.rowWrappers.get('farmer').get('farmerUsed').setActual((Decimal)res.get('use'));
                this.rowWrappers.get('farmer').get('farmerComment').setActual((Decimal)res.get('adoption'));
            }
        }
    }

    /**
     * Set the dates
     */
    private void setDates() {

        List<Date> dates = MetricHelpers.getStartEndDates(getDateString(), this.selector.Date_Period__c);
        this.startDate = dates[0];
        this.endDate = dates[1];
    }
    private Date startDate;
    private Date endDate;

    /**
     * Get the Field Officer Id from the selector. Default to All
     */
    public String getFoId() {

        String id = getParameter('Person__ckey');
        if (id == null || id.equals('')) {
            id = 'All';
        }
        return id;
    }

    /**
     * Get the date string from the selector. Default to the current date period
     */
    public String getDateString() {

        String dateString = getParameter('metricDatePickerkey');
        if (dateString == null || dateString.equals('')) {
            dateString = MetricHelpers.createDispRollOverString(Date.today(), this.selector.Date_Period__c);
        }
        return dateString;
    }


    /**
     * Refresh the dashboard
     */
    public PageReference refreshAll() {

        rebuildParameters();
        setDates();
        loadData();
        return null;
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
        if (!getParameter('Person__ckey').equals('') && !getParameter('Person__ckey').equals('All')) {
            clauses.add('Field_Officer__c = \'' + getParameter('Person__ckey') + '\'');
        }
        if (this.startDate != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(this.startDate), true), false));
        }
        if (this.endDate != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(this.endDate), true), false));
        }
        return FieldOfficeHelpers.joinWhereClause(clauses, addWhere, startWithAnd) + ' ';
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
        return (getParameter('Person__ckey').equals('All') || getParameter('Person__ckey').equals(''));
    }

    // Test methods
    static testMethod void testController() {

        FieldOfficerDashboardController controller = new FieldOfficerDashboardController();
        controller.selectorLoaded = false;
        controller.getSelector();
        controller.selectorLoaded = false;
        controller.getSelectorId();
        controller.getOne();
        controller.getPeer();
        controller.getHigh();
        controller.getFarmer();
    }

    /**
     * Wrapper class for the row data used on the dashboard
     */
    public class RowWrapper {

        private String indicator;
        private String target;
        private Decimal actual;
        private String expandedType;
        private String expandedId;
        private String expandedText;

        public RowWrapper(
                String indicator,
                String expandedType,
                String expandedId,
                String expandedText
        ) {
            this.indicator = indicator;
            this.target = 'N/A';
            this.expandedType = expandedType;
            this.expandedId = expandedId;
            this.expandedText = expandedText;
        }

        public String getIndicator() {
            return this.indicator;
        }

        public String getTarget() {
            return this.target;
        }
        public void setTarget(String value) {
            if (value == null) {
                return;
            }
            this.target = value;
        }

        public String getColour() {

            if (this.actual == null || this.target.equals('N/A')) {
                return '#CCCCFF';
            }
            Decimal target;
            try {
                target = Decimal.valueOf(this.target);
            }
            catch (Exception e) {
                return '#CCCCFF';
            }
            Decimal difference = (target - getActual()) / target;
            String colour = '#CCCCFF';
            if (difference <= 0.1) {
                colour = '#00CC00';
            }
            else if (difference <= 0.2) {
                colour = '#FFFF33';
            }
            else if (difference > 0.2) {
                colour = '#FF0000';
            }
            return colour;
        }

        public Decimal getActual() {
            return this.actual;
        }
        public void setActual(Decimal value) {
            this.actual = value;
        }

        public String getExpandedType() {
            return this.expandedType;
        }
        public void setExpandedType(String value) {
            this.expandedType = value;
        }

        public String getExpandedId() {
            return this.expandedId;
        }
        public void setExpandedId(String value) {
            this.expandedId = value;
        }

        public String getExpandedText() {
            return this.expandedText;
        }
        public void setExpandedText(String value) {
            this.expandedText = value;
        }
    }

    static testMethod void testRowWrapper() {

        RowWrapper wrapper = new RowWrapper('When', 'the', 'big', 'one');
        System.assertEquals('When', wrapper.getIndicator());
        System.assertEquals('N/A', wrapper.getTarget());
        wrapper.setTarget('comes');
        System.assertEquals('comes', wrapper.getTarget());
        System.assertEquals('the', wrapper.getExpandedType());
        System.assertEquals('big', wrapper.getExpandedId());
        System.assertEquals('one', wrapper.getExpandedText());
        System.assertEquals(wrapper.getColour(), '#CCCCFF');
        wrapper.setTarget('k');
        System.assertEquals(wrapper.getColour(), '#CCCCFF');
        wrapper.setTarget('10');
        wrapper.setActual(1);
        System.assertEquals(wrapper.getColour(), '#FF0000');
        wrapper.setActual(8);
        System.assertEquals(wrapper.getColour(), '#FFFF33');
        wrapper.setActual(9);
        System.assertEquals(wrapper.getColour(), '#00CC00');
        wrapper.setExpandedType('comes');
        wrapper.setExpandedId('better');
        wrapper.setExpandedText('hope');
    }
}