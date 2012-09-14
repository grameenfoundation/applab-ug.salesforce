public with sharing class MtnChannelsGraphController extends ChildComponentBase {

    private List<GraphColumnWrapper> graphColumns;
    private List<MtnChannelsGraphController.GraphRowWrapper> graphRows;

    Transient Set<String> rowOrder;
    Transient Map<String, MtnChannelsGraphController.GraphRowWrapper> rowMap;

    private Boolean overrideParent = false;
    private Boolean isLoaded = false;
    private String isRefresh = 'false';
    public String getIsRefresh() {
        return this.isRefresh;
    }
    public void setIsRefresh(String value) {
        this.isRefresh = value;
    }

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

    private String xAxisType;
    public String getXAxisType() {
        return this.xAxisType;
    }
    public void setXAxisType(String value) {
        this.xAxisType = value;
    }

    // Handle errors
    private Boolean hasError = false;
    public Boolean getHasError() {
        return this.hasError;
    }
    public void setHasError(Boolean value) {
        this.hasError = value;
    }

    private String errorMsg;
    public String getErrorMsg() {
        return this.errorMsg;
    }
    public void setErrorMsg(String value) {
        this.errorMsg = value;
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
        if (this.overrideParent) {
            setXAxisType(Apexpages.currentPage().getParameters().get('xAxisType'));
            addGeneralParamter('outletType' + getSectionKey(), Apexpages.currentPage().getParameters().get('outletType'));
            addGeneralParamter('stockType' + getSectionKey(), Apexpages.currentPage().getParameters().get('stockType'));
            addGeneralParamter('merchandiseType' + getSectionKey(), Apexpages.currentPage().getParameters().get('merchandiseType'));
            this.overrideParent = false;
        }


        // Rebuild the dates
        setDates();

        this.rowMap = new Map<String, MtnChannelsGraphController.GraphRowWrapper>();
        this.rowOrder = new Set<String>();
        this.graphColumns = new List<GraphColumnWrapper>();

        // Decide the graph that is to be loaded
        if (getGraphIdentifier().equals('OutletsVisited')) {
            return loadOutletVisitedGraph();
        }
        else if (getGraphIdentifier().equals('PromotionType')) {
            return loadPromotionType();
        }
        else if (getGraphIdentifier().equals('StockGraph')) {
            return loadStockGraph();
        }
        else if (getGraphIdentifier().equals('DSDGraph')) {
            return loadDsdGraph();
        }
        else if (getGraphIdentifier().equals('SellMost')) {
            //return loadSellMostGraph();
        }
        else if (getGraphIdentifier().equals('CompetitorMerchGraph')) {
            return loadCompetitorMerchGraph();
        }
        else if (getGraphIdentifier().equals('CompetitorSellGraph')) {
            return loadSellCompetitor();
        }
        else {

            // Unrecognised graph so mention that and throw an error
            System.debug(LoggingLevel.INFO, 'Graph with identifier: ' + getGraphIdentifier() + ' does not exist in SFDC check set up');
            setErrorMsg('The graph type you are trying to load does not exist. Please contact support');
            setHasError(true);
            return false;
        }
        return true;
    }

    public String getTypeOfGraph() {
        return getFieldValue('type_of_graph__c');
    }

    public String getXAxisTitle() {
        return translatexAxis(getXAxisType());
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

    private String translateGraphType(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            'OutletsVisited' => 'Outlets visited',
            'PromotionType' => 'Promotional activities',
            'StockGraph' => 'Initial and available stock',
            'DSDGraph' => 'ReStocking Method',
            'SellMost' => 'Company sold 1st and 2nd most',
            'CompetitorMerchGraph' => 'Outlets with competitors merchandise on display',
            'CompetitorSellGraph' => 'Outlets selling competitor products'
        };
        return translationMap.get(optionNumber);
    }

    private String translatexAxis(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Region',
            '2' => 'Staff Member',
            '3' => 'Outlet Type'
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
            setErrorMsg('No active graph definition found for identifier ' + this.graphIdentifier + '. Please check your set up.');
            setHasError(true);
            return false;
        }
        setsObjectRecord((sObject)param[0]);
        this.sObjectName = 'Graph_Parameter__c';
        return true;
    }

    /**
     * Method to override the standard setDate method. Uses the quarter selector if no
     * date range is set
     */
    private void setDates() {

        // Check that the date picker has been set.
        Boolean startDateSet = false;
        Boolean endDateSet = false;

        String[] datesString = getParentValue('datePicker').split('_ext_');
        for (Integer i = 0; i < datesString.size(); i++) {
            String[] dateArray = datesString[i].split('_int_');
            if (dateArray.size() != 2) {
                continue;
            }
            if (dateArray[0].equals('start_date') && !dateArray[1].equals('NONE')) {
                startDateSet = true;
                setStartDate(DateTime.newInstance(Long.valueOf(dateArray[1])).date());
            }
            else if (dateArray[0].equals('end_date') && !dateArray[1].equals('NONE')) {
                endDateSet = true;
                setEndDate(DateTime.newInstance(Long.valueOf(dateArray[1])).date());
            }
        }

        // Check that the dates are set. If they are not set then fall back to the quarter
        // selector. If only one was set then assume that the same day is being looked at
        if (!startDateSet && !endDateSet) {
            List<Date> dates = MetricHelpers.getStartEndDates(getParentValue('metricDatePicker'), getParentValue('DatePeriod'));
            setStartDate(dates[0]);
            setEndDate(dates[1]);
        }
        else if (!startDateSet) {
            setStartDate(getEndDate());
        }
        else if (!endDateSet) {
            setEndDate(getStartDate());
        }
    }

    // Methods to generate the graphs are below
    private Boolean loadOutletVisitedGraph() {

        String query =
            'SELECT ' +
                'count(id) total, ' +
                'Activity_Type__c activityType, ' +
                groupBySelectClause() +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
            'WHERE ' +
                '(Activity_Type__c = \'Existing Outlet\' ' +
                'OR Activity_Type__c = \'New Outlet\') ' +
                generateWhereClause(false, true, false, '') +
            'GROUP BY ' +
                'Activity_Type__c' + 
                getGroupByClause(true) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        Map<String, OutletVisitWrapper> outletMap = new Map<String, OutletVisitWrapper>();
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);
                OutletVisitWrapper outlet = outletMap.get(identifier);
                if (outlet == null) {
                    outlet = new OutletVisitWrapper(header);
                }
                if (String.valueOf(res.get('activityType')).equals('Existing Outlet')) {
                    outlet.setExistingOutlet(String.valueOf(res.get('total')));
                }
                else {
                    outlet.setNewOutlet(String.valueOf(res.get('total')));
                }
                outletMap.put(identifier, outlet);
            }
        }

        // Get the targets
        Map<String, Decimal> targetMap = getOutletTargetMap();

        // Loop through the map and create the row wrappers
        for (String key : outletMap.keySet()) {
            MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(outletMap.get(key).getHeader());
            wrapper.addValue(outletMap.get(key).getNewOutlet());
            wrapper.addValue(outletMap.get(key).getExistingOutlet());
            wrapper.addValue(outletMap.get(key).getTotal());
            if (!getXAxisType().equals('3')) {
                wrapper.addValue(String.valueOf(targetMap.get(key)));
            }
            this.rowMap.put(key, wrapper);
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'New Outlet')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Existing Outlet'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Total'));
        if (!getXAxisType().equals('3')) {
            this.graphColumns.add(new GraphColumnWrapper('number', 'Target'));
        }
        return true;
    }

    /**
     * Load the graph for the promotion types
     */
    private Boolean loadPromotionType() {

        String query =
            'SELECT ' +
                'count(id) total, ' +
                'Promotion_Type__c promotionType, ' +
                groupBySelectClause() +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
            'WHERE ' +
                'Promotion_Type__c != null ' +
                generateWhereClause(false, true, false, '') +
            ' GROUP BY ' +
                'Promotion_Type__c' + 
                getGroupByClause(true) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        Map<String, PromotionWrapper> promotionMap = new Map<String, PromotionWrapper>();
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);
                PromotionWrapper promotion = promotionMap.get(identifier);
                if (promotion == null) {
                    promotion = new PromotionWrapper(header);
                }
                String promotionType = String.valueOf(res.get('promotionType'));
                if (promotionType.equals('Dealership Activities')) {
                    promotion.setDealerShip(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('Easy Load')) {
                    promotion.setEasyLoad(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('Landing Sites')) {
                    promotion.setLandingSites(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('Market Day Activation')) {
                    promotion.setMarket(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('Other')) {
                    promotion.setOther(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('SIM Registration')) {
                    promotion.setSim(String.valueOf(res.get('total')));
                }
                else if (promotionType.equals('War Room')) {
                    promotion.setWar(String.valueOf(res.get('total')));
                }
                promotionMap.put(identifier, promotion);
            }
        }

        // Loop through the map and create the row wrappers
        for (String key : promotionMap.keySet()) {
            MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(promotionMap.get(key).getHeader());
            wrapper.addValue(promotionMap.get(key).getDealerShip());
            wrapper.addValue(promotionMap.get(key).getEasyLoad());
            wrapper.addValue(promotionMap.get(key).getLandingSites());
            wrapper.addValue(promotionMap.get(key).getMarket());
            wrapper.addValue(promotionMap.get(key).getSim());
            wrapper.addValue(promotionMap.get(key).getWar());
            wrapper.addValue(promotionMap.get(key).getOther());
            this.rowMap.put(key, wrapper);
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Dealership Activities')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Easy Load'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Landing Sites'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Market Day Activation'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'SIM Registration'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'War Room'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Other'));
        return true;
    }

    /**
     *  Get the DSD Graph
     */
    private Boolean loadDsdGraph() {

        String query = 
            'SELECT ' +
                'SUM(Get_Stock_DSD__c) yes, ' +
                'SUM(Get_Stock_Self__c) no, ' +
                groupBySelectClause() +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
                generateWhereClause(true, false, true, '') +
            ' GROUP BY ' +
                getGroupByClause(false) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);

                MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('yes')));
                wrapper.addValue(String.valueOf(res.get('no')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'DSD')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Self'));
        return true;
    }

    /**
     * Load the graph for stock
     */
    private Boolean loadStockGraph() {

        String query =
            'SELECT ' +
                groupBySelectClause() + ', ' +
                getStockSelectClause() +
            ' FROM ' +
                'MTN_Channels_Activity__c ' +
                generateWhereClause(true, false, true, '') +
            ' GROUP BY ' +
                getGroupByClause(false) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);

                MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(header);
                if (!getParentValue('stockType').equals('')) {
                    wrapper.addValue(String.valueOf(res.get('Available')));
                    wrapper.addValue(String.valueOf(res.get('Initial')));
                }
                else {
                    wrapper.addValue(String.valueOf(res.get('EasyLoadInitial')));
                    wrapper.addValue(String.valueOf(res.get('EasyLoadAvailable')));
                    wrapper.addValue(String.valueOf(res.get('ModemsInitial')));
                    wrapper.addValue(String.valueOf(res.get('ModemsAvailable')));
                    wrapper.addValue(String.valueOf(res.get('PhonesInitial')));
                    wrapper.addValue(String.valueOf(res.get('PhonesAvailable')));
                    wrapper.addValue(String.valueOf(res.get('ScratchCardsInitial')));
                    wrapper.addValue(String.valueOf(res.get('ScratchCardsAvailable')));
                    wrapper.addValue(String.valueOf(res.get('SIMPacksInitial')));
                    wrapper.addValue(String.valueOf(res.get('SIMPacksAvailable')));
                }
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        if (!getParentValue('stockType').equals('')) {
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available'));
        }
        else {
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial Easy Load')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available Easy Load'));
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial Modems')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available Modems'));
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial Phones')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available Phones'));
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial Scratch Cards')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available Scratch Cards'));
            this.graphColumns.add(new GraphColumnWrapper('number', 'Initial SIM Packs')); 
            this.graphColumns.add(new GraphColumnWrapper('number', 'Available SIM Packs'));
        }
        return true;
    }

    /**
     * Load the sell most graph
     */
    private Boolean loadSellMostGraph() {

        String query =
            'SELECT ' +
                ', ' +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
                generateWhereClause(true, false, true, '') +
            ' GROUP BY ' +
                ', ' +
                getGroupByClause(false) +
            ' ORDER BY ' +
                groupByOrderClause();
        return true;

    }

    /**
     * Load the graph for competitors merch on display
     */
    private Boolean loadCompetitorMerchGraph() {

        String query =
            'SELECT ' +
                'SUM(Merch_Airtel__c) airtel, ' +
                'SUM(Merch_Orange__c) orange, ' +
                'SUM(Merch_Other__c) other, ' +
                'SUM(Merch_UTL__c) utl, ' +
                'SUM(Merch_Warid__c) warid, ' +
                groupBySelectClause() +
            ' FROM ' +
                'MTN_Channels_Activity__c ' +
                generateWhereClause(true, false, true, '') +
            ' GROUP BY ' +
                getGroupByClause(false) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);

                MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('airtel')));
                wrapper.addValue(String.valueOf(res.get('orange')));
                wrapper.addValue(String.valueOf(res.get('utl')));
                wrapper.addValue(String.valueOf(res.get('warid')));
                wrapper.addValue(String.valueOf(res.get('other')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Airtel'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Orange'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'UTL'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Warid'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Other'));
        return true;

    }

    /**
     * Load the graph for the competitors that are sold
     */
     private Boolean loadSellCompetitor() {

        String query =
            'SELECT ' +
                'SUM(Sell_Airtel__c) airtel, ' +
                'SUM(Sell_None__c) none, ' +
                'SUM(Sell_Orange__c) orange, ' +
                'SUM(Sell_Other__c) other, ' +
                'SUM(Sell_UTL__c) utl, ' +
                'SUM(Sell_Warid__c) warid, ' +
                groupBySelectClause() +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
                generateWhereClause(true, false, true, '') +
            ' GROUP BY ' +
                getGroupByClause(false) +
            ' ORDER BY ' +
                groupByOrderClause();
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult[] results : database.query(query)) {
            for (AggregateResult res : results) {

                String header = '';
                String identifier = '';
                if (getXAxisType().equals('2')) {
                    header = String.valueOf(res.get('lastName')) + ' ' + String.valueOf(res.get('firstName'));
                    identifier = String.valueOf(res.get('name'));
                }
                else if (getXAxisType().equals('3')) {
                    header = String.valueOf(res.get('outleType'));
                    identifier = header;
                }
                else {
                    header = String.valueOf(res.get('regionName'));
                    identifier = header;
                }
                this.rowOrder.add(identifier);

                MtnChannelsGraphController.GraphRowWrapper wrapper = new MtnChannelsGraphController.GraphRowWrapper(header);
                wrapper.addValue(String.valueOf(res.get('airtel')));
                wrapper.addValue(String.valueOf(res.get('orange')));
                wrapper.addValue(String.valueOf(res.get('utl')));
                wrapper.addValue(String.valueOf(res.get('warid')));
                wrapper.addValue(String.valueOf(res.get('other')));
                wrapper.addValue(String.valueOf(res.get('none')));
                this.rowMap.put(identifier, wrapper);
            }
        }
        this.graphColumns.add(new GraphColumnWrapper('string', getColumnName())); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Airtel')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Orange'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'UTL')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'Warid'));
        this.graphColumns.add(new GraphColumnWrapper('number', 'Other')); 
        this.graphColumns.add(new GraphColumnWrapper('number', 'None'));
        return true;
     }

    /**
     * Get the outlet visit targets. This will be by region or by person depending on the graph
     */
    private Map<String, Decimal> getOutletTargetMap() {

        Map<String, Decimal> targetMap = new Map<String, Decimal>();

        String query =
            'SELECT ' +
                'Person__c ,' +
                'Person__r.Region__r.Display_Name__c, ' +
                'Outlet_Visit_Target__c, ' +
                'Start_Date__c ' +
            'FROM ' +
                'MTN_Channels_Daily_Sumary__c ' +
                generateWhereClause(true, false, false, 'Person__r.') +
            ' ORDER BY ' +
                'Person__r.Name, ' +
                'Start_Date__c';

        System.debug(LoggingLevel.INFO, query);
        for (MTN_Channels_Daily_Sumary__c[] targets : Database.query(query)) {
            for (MTN_Channels_Daily_Sumary__c targetObj : targets) {
                String header = '';
                if (getXAxisType().equals('2')) {
                    header = targetObj.Person__c;
                }
                else {
                    header = targetObj.Person__r.Region__r.Display_Name__c;
                }
                Decimal target = targetMap.get(header);
                if (target == null) {
                    target = 0;
                }
                target += targetObj.Outlet_Visit_Target__c;
                targetMap.put(header, target);
            }
        }
        return targetMap;
    }

    /**
     * Generate the select clause depending on what xAxis is getting shown
     *
     * @return - The select clause
     */
    private String groupBySelectClause() {

        String clause = '';
        if (getXAxisType().equals('2')) {
            clause = 'Person__c name, ' +
                'Person__r.First_Name__c firstName, ' +
                'Person__r.Last_Name__c lastName ';
        }
        else if (getXAxisType().equals('3')) {
            clause = 'Outlet_Type__c outleType ';
        }
        else {

            // Use region as the default
            clause = 'Region__r.Display_Name__c regionName ';
        }
        return clause;
    }

    /**
     * Get the order by clause depending on the xAxis that is being shown
     */
    private String groupByOrderClause() {

        String clause = '';
        if (getXAxisType().equals('2')) {
            clause = 'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c ';
        }
        else if (getXAxisType().equals('3')) {
            clause = 'Outlet_Type__c ';
        }
        else {

            // Use region as the default
            clause = 'Region__r.Display_Name__c ';
        }
        return clause;
    }

    /**
     * Generate the group by clause depending on the xAxis shown
     *
     * @param startWithComma - 
     *
     * @return - The group by clause
     */
    private String getGroupByClause(Boolean startWithComma) {

        String clause = '';
        if (startWithComma) {
            clause = ', ';
        }
        if (getXAxisType().equals('2')) {
            clause += 'Person__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Last_Name__c ';
        }
        else if (getXAxisType().equals('3')) {
            clause += 'Outlet_Type__c ';
        }
        else {

            // Use region as the default
            clause += 'Region__r.Display_Name__c ';
        }
        return clause;
    }

    private String getColumnName() {

        String clause = '';
        if (getXAxisType().equals('2')) {
            clause = 'Staff Member';
        }
        else if (getXAxisType().equals('3')) {
            clause = 'Outlet Type';
        }
        else {

            // Use region as the default
            clause = 'Region';
        }
        return clause;
    }

    /**
     * Generate the where clause from the selectors
     *
     * @param addWhere             - Boolean to indicate that a WHERE should start the returned query.
     *                                  If true ignores startWithAnd as both cannot happen
     * @param startWithAnd         - Boolean to indicate that an AND should start the returned query
     * @param includeExtraSelector - Indicates if this graph cares about the extra selectors
     *
     * @return - The where clause
     */
    private String generateWhereClause(Boolean addWhere, Boolean startWithAnd, Boolean includeExtraSelector, String regionAddOn) {

        List<String> clauses = new List<String>();

        if (!getParentValue('Region__c').equals('')) {
            clauses.add(regionAddOn + 'Region__c = \'' + getParentValue('Region__c') + '\'');
        }
        if (!getParentValue('Person__c').equals('')) {
            clauses.add('Person__c = \'' + getParentValue('Person__c') + '\'');
        }
        if (getStartDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate()), true), false));
        }
        if (getEndDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate()), true), false));
        }
        if (!includeExtraSelector) {
            return MtnChannelsHelpers.joinWhereClause(clauses, addWhere, startWithAnd);
        }
        if (!getParentValue('outletType').equals('')) {
            clauses.add(getOutletWhereClause());
        }
        if (!getParentValue('stockType').equals('')) {
            clauses.add(getStockWhereClause());
        }
        if (!getParentValue('merchandiseType').equals('')) {
            clauses.add(getMerchandiseWhereClause());
        }
        return MtnChannelsHelpers.joinWhereClause(clauses, addWhere, startWithAnd) + ' ';
    }

    /**
     * Build the where clause for outlet type
     */
    private String getOutletWhereClause() {
        return 'Outlet_Type__c = \'' + getParentValue('outletType') + '\'';
    }

    /**
     * Build a select caluse based on the stock type.
     *
     * @return - The clause
     */
    private String getStockSelectClause() {

        String clause = '';
        if (!getParentValue('stockType').equals('')) {
            clause = 'SUM(AS_' + getParentValue('stockType') + '__c) Available, ' +
            'SUM(IS_' + getParentValue('stockType') + '__c) Initial ';
        }
        else {
            clause = 'SUM(AS_Easy_Load__c) EasyLoadAvailable, ' +
            'SUM(AS_Modems__c) ModemsAvailable, ' +
            'SUM(AS_Phones__c) PhonesAvailable, ' +
            'SUM(AS_Scratch_Cards__c) ScratchCardsAvailable, ' +
            'SUM(AS_Sim_Packs__c) SIMPacksAvailable, ' +
            'SUM(IS_Easy_Load__c) EasyLoadInitial, ' +
            'SUM(IS_Modems__c) ModemsInitial, ' +
            'SUM(IS_Phones__c) PhonesInitial, ' +
            'SUM(IS_Scratch_Cards__c) ScratchCardsInitial, ' +
            'SUM(IS_Sim_Packs__c) SIMPacksInitial ';
        }
        return clause;
    }

    /**
     * Build where clause based on the stock type. Based on initial stock
     */
    private String getStockWhereClause() {
        return 'IS_' + getParentValue('stockType') + '__c > 0';
    }

    /**
     * Build the select clause for merchandise
     */
    private String getMerchandiseSelectClause() {

        String fieldName = '';
        if (getGraphIdentifier().equals('CompetitorGraph')) {
            fieldName = 'Merch_Comp_';
        }
        else {
            fieldName = 'MTN_Merch_';
        }
        String clause = '';
        if (!getParentValue('merchandiseType').equals('')) {
            clause = 'SUM(' + fieldName + getParentValue('merchandiseType') + '__c) merchandiseType, ';
        }
        else {
            clause = 'SUM(' + fieldName + 'Co_Brand__c) coBrand, ' +
            'SUM(' + fieldName + 'Dangler__c) Dangler, ' +
            'SUM(' + fieldName + 'Light_Box__c) LightBox, ' +
            'SUM(' + fieldName + 'None__c) None, ' +
            'SUM(' + fieldName + 'Other__c) Other, ' +
            'SUM(' + fieldName + 'Placard__c) Placard, ' +
            'SUM(' + fieldName + 'Poster__c) Poster, ' +
            'SUM(' + fieldName + 'SIM__c) SIM, ' +
            'SUM(' + fieldName + 'Wall__c) Wall';
        }
        return clause;
    }

    /**
     * Build the where clause for the merchandise. This will depend on the type of
     * graph being built.
     */
    private String getMerchandiseWhereClause() {

        String clause = '';
        if (getGraphIdentifier().equals('CompetitorGraph')) {
            clause = 'Merch_Comp_' + getParentValue('merchandiseType') + '__c = 1';
        }
        else {
            clause = 'MTN_Merch_' + getParentValue('merchandiseType') + '__c = 1';
        }

        return clause;
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

        String json = 'FAIL';
        init();

        // Check that there is actually some data to show. Display a page error if there is not
        Integer numberOfColumns = this.graphColumns.size();
        Integer numberOfRows = this.rowOrder.size();
        if (numberOfColumns == 0 || numberOfRows == 0) {
            System.debug(LoggingLevel.INFO, 'Number of Columns = ' + numberOfColumns + '. Number of Rows = ' + numberOfRows);
            setErrorMsg('There is no valid data for the ' + translateGraphType(getGraphIdentifier()) + ' graph. Please ensure that some data has been submitted to the system');
            setHasError(true);
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
     * Create the literal string for the series colours if required
     */
    public String getSeries() {

        String series = 'FAIL';
        if (getGraphIdentifier().equals('CompetitorMerchGraph') || getGraphIdentifier().equals('CompetitorSellGraph')) {
            series = '{ ' +
                '0:{color: \'#FF0000\'},' +
                '1:{color: \'#FF3300\'},' +
                '2:{color: \'#0000CC\'},' +
                '3:{color: \'#CC0066\'},' +
                '4:{color: \'#666666\'},' +
                '5:{color: \'#000000\'}}';
        }
        return series;
    }

    /**
     * Refresh the graph individually
     */
    public override PageReference refreshData() {

        this.overrideParent = true;
        setHasError(false);
        return null;
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

    /**
     * Private class that stores the outlet visit details
     */
    private class OutletVisitWrapper {
        private String existingOutlet;
        private String newOutlet;
        private String header;

        public OutletVisitWrapper(String header) {
            this.header = header;
            this.existingOutlet = '0';
            this.newOutlet = '0';
        }

        public String getHeader() {
            return this.header;
        }

        public String getExistingOutlet() {
            return this.existingOutlet;
        }

        public void setExistingOutlet(String value) {
            this.existingOutlet = value;
        }

        public String getNewOutlet() {
            return this.newOutlet;
        }

        public void setNewOutlet(String value) {
            this.newOutlet = value;
        }

        public String getTotal() {
            return String.valueOf(Integer.valueOf(getNewOutlet()) + Integer.valueOf(getExistingOutlet()));
        }
    }

    /**
     * Private class that stores the promtional activities details
     */
    private class PromotionWrapper {
        private String dealerShip;
        private String easyLoad;
        private String landingSites;
        private String market;
        private String other;
        private String sim;
        private String war;
        private String header;

        public PromotionWrapper(String header) {
            this.header = header;
            this.dealerShip = '0';
            this.easyLoad = '0';
            this.landingSites = '0';
            this.market = '0';
            this.other = '0';
            this.sim = '0';
            this.war = '0';
        }

        public String getHeader() {
            return this.header;
        }

        public String getDealerShip() {
            return this.dealerShip;
        }

        public void setDealerShip(String value) {
            this.dealerShip = value;
        }

        public String getEasyLoad() {
            return this.easyLoad;
        }

        public void setEasyLoad(String value) {
            this.easyLoad = value;
        }

        public String getLandingSites() {
            return this.landingSites;
        }

        public void setLandingSites(String value) {
            this.landingSites = value;
        }

        public String getMarket() {
            return this.market;
        }

        public void setMarket(String value) {
            this.market = value;
        }

        public String getOther() {
            return this.other;
        }

        public void setOther(String value) {
            this.other = value;
        }

        public String getSim() {
            return this.sim;
        }

        public void setSim(String value) {
            this.sim = value;
        }

        public String getWar() {
            return this.war;
        }

        public void setWar(String value) {
            this.war = value;
        }
    }
}