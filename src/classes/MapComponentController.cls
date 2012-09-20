/**
 *  Controller for a map component. This component will show a google map that contains markers for various sObject types
 */

public with sharing class MapComponentController extends ChildComponentBase {

    // Variables that deal with setting the colours of the map markers
    private   Map<String, String> defaultColourMap;
    Transient Map<String, String> colourMap;
    Transient Map<String, String> usedColourMapTypes;
    Transient Map<String, String> usedColourMapNames;
    Transient Set<String> usedColours;

    private void setUp() {
        if (isLoaded) {
            return;
        }
        if (getExpanded()) {
            setWidth('900px');
            setHeight('750px');
        }
        else {
            setWidth('300px');
            setHeight('250px');
        }
        this.stats = '';
        this.mapMarkers = new List<MapMarkers>();
        setDefaultColourMap();
        setMapMarkers(loadMapMarkers());
        setKeyText();
        isLoaded = true;
    }

    private Boolean isRefresh = false;
    public Boolean getIsRefresh() {
        return this.isRefresh;
    }

    public override PageReference refreshData() {
        isLoaded = false;
        isRefresh = true;

        try {
            if (this.getParentComponentController() != null) {
                this.getParentComponentController().rebuildParameters();

                // Rebuild the start times here so they are taken into account when rebuilding the axis
                if (!getParentValue('datePicker').equals('')) {
                    setDates(getParentValue('datePicker'));
                }
            }
            setUp();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured whilst refreshing the data. If the problem persists please contact support'));
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
        return null;
    }

    private Boolean isLoaded = false;

    // Stores the Map_Parameter__c object that contains the parameters for a given map
    public override void setsObjectRecord(sObject value) {
        this.sObjectRecord = value;
        this.sObjectName = 'Map_Parameter__c';
        setsObjectId(value.Id);
        setUp();
    }
    private Boolean loadMapParameter() {

        if (getsObjectId() == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No map id found. Cannot load map'));
            return false;
        }

        if (isLoaded) {
            return true;
        }
        Map_Parameter__c[] maps = [SELECT
                Id,
                Name,
                Title__c,
                Latitude__c,
                Longitude__c,
                Type_Of_sObject__c,
                Zoom__c,
                Splitter__c
            FROM
                Map_Parameter__c
            WHERE
                Id = :this.sObjectId];
        if (maps.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No map found that matches this Map id. Please check the map is in the system'));
            return false;
        }
        setsObjectRecord((sObject)maps[0]);
        isLoaded = true;
        return true;
    }

    // Disable the controls on a map. Makes the map static
    private Boolean disableControls = false;
    public Boolean getDisableControls() {
        if (!getExpanded()) {
            return true;
        }
        return this.disableControls;
    }
    public void initFieldMapsetDisableControls(Boolean value) {
        this.disableControls = value;
    }

    // Disable the pop up info windows on a map
    private Boolean disableInfoWindows = true;
    public Boolean getDisableInfoWindows() {
        if (getExpanded()) {
            return false;
        }
        return this.disableInfoWindows;
    }
    public void setDisableInfoWindows(Boolean value) {
        this.disableInfoWindows = value;
    }

    // Disable the the maps key
    private Boolean disableKey = true;
    public Boolean getDisableKey() {
        if (getExpanded()) {
            return false;
        }
        return this.disableKey;
    }
    public void setDisableKey(Boolean value) {
        this.disableKey = value;
    }

    public String getTitle() {
        return getFieldValue('Title__c');
    }
    private String latitude;
    public String getLatitude() {
        return getFieldValue('Latitude__c');
    }
    private String longitude;
    public String getLongitude() {
        return getFieldValue('Longitude__c');
    }
    public String getTypeOfsObject() {
        return getFieldValue('Type_Of_sObject__c');
    }
    private String zoom;
    public String getZoom() {
        return getFieldValue('Zoom__c');
    }

    private String stats;
    public String getStats() {
        return this.stats;
    }
    public void setStats(String addOn) {

        if (this.stats == null || this.stats.equals('')) {
            this.stats = addOn;
        }
        else {
            this.stats = this.stats + ' ' + addOn;
        }
    }

    // Build up the text that is used in the key of the map
    private String keyText;
    public String getKeyText() {
        return this.keyText;
    }
    public void setKeyText() {
        String text = '';
        for (String key : this.usedColourMapNames.keySet()) {
            String[] items = key.split('#@#');
            text = text + this.usedColourMapNames.get(key).replace('_', ' ') + ': ';
            for (Integer i = 0; i < items.size() -1; i++) {
                text = text + items[i] + ' ';
            }
            text = text + '<br />';
        }
        this.keyText = text;
    }

    private List<MapMarkers> mapMarkers;
    public List<MapMarkers> getMapMarkers() {
        return this.mapMarkers;
    }
    public void setMapMarkers(List<MapMarkers> values) {
        this.mapMarkers = values;
    }

    /**
     *  Load the map markers that are to be shown on the map. This can be based on the Map_Parameter__c object or on values passed into the controller
     */
    public List<MapMarkers> loadMapMarkers() {

        List<MapMarkers> markers = new List<MapMarkers>();

        // Decide which type of markers to show based on the default params and on params feed in
        // from selector
        String sObjectType = getFieldvalue('Type_Of_sObject__c');
        if (sObjectType.equalsIgnoreCase('CKW') || !getParentValue('ShowCKWMap').equals('')) {
            markers.addAll(getCkwMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Farmer') || !getParentValue('ShowFarmerMap').equals('')) {
            //markers.addAll(getFarmerMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Client Location') || !getParentValue('ShowClientLocation').equals('')) {
            markers.addAll(getClientLocationMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Submission') || !getParentValue('ShowSubmission').equals('')) {
            //markers.addAll(getSubmissionMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Search Log') || !getParentValue('Show SearchLog').equals('')) {
            //markers.addAll(getSearchMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Metric') || !getParentValue('ShowMetric').equals('')) {
            //markers.addAll(getMetricMarkers());
        }
        else if (sObjectType.equalsIgnoreCase('Person') || !getParentValue('ShowPerson').equals('')) {
            //markers.addAll(getPersonMarkers());
        }
        return markers;
    }

    /**
     *  Load CKW Markers for this map
     */
    private List<MapMarkers> getCkwMarkers() {

        Map<String, MapMarkers> markers = new Map<String, MapMarkers>();

        CKW__c[] ckws = database.query(getCkwMarkersQuery());
        if (ckws.size() == 0) {
            return markers.values();
        }

        List<String> personIds = new List<String>();
        for (CKW__c ckw : ckws) {

            // Dont include if we are missing the location
            if (ckw.Person__r.GPS_Location_N__c == null || ckw.Person__r.GPS_Location_E__c == null) {
                continue;
            }

            personIds.add(ckw.person__c);
            CkwMapMarker marker = new CkwMapMarker(ckw);
            marker.generateMarkerName(getFieldvalue('Splitter__c'));
            marker.setMarkerColour(getColour(marker.getColour(), marker.getMarkerName()));
            markers.put(ckw.Person__r.Name, marker);
        }

        // If there is only one CKW the center the map around them and zoom to a better level
        if (markers.size() == 1) {
            this.zoom = '10';
            this.latitude = ckws[0].Person__r.GPS_Location_N__c;
            this.longitude = ckws[0].Person__r.GPS_Location_E__c;
        }
 
        // Tidy up the created lists so to keep the heap size down.
        ckws.clear();
        setStats('There are ' + markers.size() + ' CKWs who match your search<br/>');
        return markers.values();
    }

    // Create the SOQL query that gets the CKW objects for the map markers
    private String getCkwMarkersQuery() {

        String baseQuery = 'SELECT ' +
                'Id, '   +
                'Name, ' +
                'Status__c, ' +
                'Person__r.Name, ' +
                'Person__c, ' +
                'Person__r.Gender__c,'    +
                'Person__r.Parish__c, '  +
                'Person__r.Village__c, ' +
                'Person__r.GPS_Location_N__c,' + 
                'Person__r.GPS_Location_E__c,' +
                'Current_Performance_Review__c,' +
                'Current_Performance_Review__r.Monthly_Target__r.Search_Target__c, ' +
                'Current_Performance_Review__r.Total_Searches__c, ' +
                'Current_Performance_Review__r.Monthly_Target__r.Survey_Target__c, ' +
                'Current_Performance_Review__r.Total_Surveys__c, ' +
                'Previous_Performance_Review__c, ' +
                'Previous_Performance_Review__r.Performance_Level__c ' +
            'FROM ' +
                'CKW__c';

        List<String> whereClauses = getCkwWhereClause();
        String whereClause = '';

        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        String query = baseQuery + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    // Build the where cluse for the query. Values are taken from the children of the parent if there is one. If not then everything is loaded.
    private List<String> getCkwWhereClause() {

        List<String> whereClauses = new List<String>();

        if (!getParentValue('District__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.District__c', getParentValue('District__c'), true));
        }
        if (!getParentValue('Subcounty__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.Subcounty__c', getParentValue('Subcounty__c'), true));
        }

        // Distinguish by dates
        if (getStartDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Active_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate(false)), false), false));
        }
        if (getEndDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Active_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate(false)), false), false));
        }
        return whereClauses;
    }

    // Methods for getting map markers from the Client_Location__c sObject
    private List<MapMarkers> getClientLocationMarkers() {

        List<MapMarkers> markers = new List<MapMarkers>();
        Map<String, Integer> locationTypes = new Map<String, Integer>();
        Client_Location__c[] locations = Database.query(getClientLocationMarkersQuery());
        for (Client_Location__c location : locations) {
            if (location.Latitude__c == null || location.Longitude__c == null) {
                continue;
            }
            ClientLocationMapMarker marker = new ClientLocationMapMarker(location);
            marker.generateMarkerName(location.Type__c);
            marker.setMarkerColour(getColour(marker.getColour(), marker.getMarkerName()));
            markers.add(marker);
            if (locationTypes.containsKey(location.Type__c)) {
                locationTypes.put(location.Type__c, locationTypes.get(location.Type__c) + 1);
            }
            else {
                locationTypes.put(location.Type__c, 1);
            }
        }
        for (String key : locationTypes.keySet()) {
            setStats('There are ' + locationTypes.get(key) + ' ' + key + ' matching your search<br/>');
        }
        return markers;
    }

    private String getClientLocationMarkersQuery() {

        String baseQuery = 'SELECT ' +
                'Name, '             +
                'Id, '               +
                'Display_Name__c, '  +
                'Description__c, '   +
                'Latitude__c, '      +
                'Longitude__c, '     +
                'Type__c, '          +
                'District__r.Name, ' +
                'Account__r.Name, '  +
                'Person__c, '        +
                'Person__r.First_Name__c, ' +
                'Person__r.Last_Name__c, ' +
                'Person__r.Subcounty__r.Display_Name__c ' +
            'FROM ' +
                'Client_Location__c ';

        List<String> whereClauses = getClientLocationWhereClause();
        String whereClause = '';

        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        String query = baseQuery + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private List<String> getClientLocationWhereClause() {

        List<String> whereClauses = new List<String>();
        if (!getParentValue('District__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.District__c', getParentValue('District__c'), true));
        }
        if (!getParentValue('Subcounty__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__r.Subcounty__c', getParentValue('Subcounty__c'), true));
        }

        // Distinguish by dates
        if (getStartDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Active_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate(false)), false), false));
        }
        if (getEndDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Active_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate(false)), false), false));
        }
        return whereClauses;
    }


    // Set the colours up that can be used for dynamic assignment of map markers. Will override the default colour if that colour is already in use
    // by another category of map marker
    private void setDefaultColourMap() {

        this.usedColourMapTypes = new Map<String, String>();
        this.usedColourMapNames = new Map<String, String>();
        this.defaultColourMap = new Map<String, String>();
        this.colourMap = new Map<String, String>();
        this.defaultColourMap.put('Black', '000000');
        this.defaultColourMap.put('Grey', '999999');
        this.defaultColourMap.put('Light_Grey', 'CCCCCC');
        this.defaultColourMap.put('White', 'FFFFFF');
        this.defaultColourMap.put('Pink', 'FF6699');
        this.defaultColourMap.put('Red', 'FF0000');
        this.defaultColourMap.put('Orange', 'FF6600');
        this.defaultColourMap.put('Yellow', 'FFFF00');
        this.defaultColourMap.put('Green', '00CC00');
        this.defaultColourMap.put('Blue', '000099');
        this.defaultColourMap.put('Purple', '990099');
        this.defaultColourMap.put('Light_Green', '00FF00');
        this.defaultColourMap.put('Light_Blue', '0000FF');
        this.defaultColourMap.put('Dark_Green', '009900');
        this.defaultColourMap.put('Dark_Blue', '000033');
    }

    /**
     *  Get the colour for a marker. If the marker doesn't have the colour set already then try to assign it
     *  the ideal colour or set it to the next available colour
     *
     *  @param colourType - The ideal colour
     *  @param markerName - The name of the marker
     *
     *  @return - The hex value for the colour that has been assigned
     */
    private String getColour(String colourType, String markerName) {

        if (colourMap.get(markerName) == null) {
            return setColour(colourType, markerName);
        }
        return colourMap.get(markerName);
    }

    /**
     *  Set a colour in the colour maps. Need to check that the desired colour isn't used already
     *  If it is then set it to the next available colour of set it to brown
     *
     *  @param colourType - The ideal colour
     *  @param markerName - The name of the marker
     *
     *  @return - The hex value for the colour that has been assigned
     */
    private String setColour(String colourType, String markerName) {

        // Desired colour has not been assigned so assign it
        String hexCode = '';
        Boolean isNonDefault = true;
        if (!this.usedColourMapTypes.keySet().contains(colourType)) {
            hexCode = this.defaultColourMap.get(colourType);
        }
        else {

            // If all the colours are used up the assign brown
            if (this.defaultColourMap.keySet().size() == 0) {
                hexCode = '663300';
                isNonDefault = false;
            }

            // Get an unassigned colour for the marker.
            Integer i = 0;
            for (String colour : this.defaultColourMap.keySet()) {
                if (i == 1) {
                    break;
                }
                hexCode = this.defaultColourMap.get(colour);
                colourType = colour;
            }
        }
        assignColour(colourType, markerName, hexCode, isNonDefault);
        return hexCode;
    }

    private void assignColour(String colourType, String markerName, String hexCode, Boolean isNonDefault) {

        if (isNonDefault) {
            this.defaultColourMap.remove(colourType);
        }
        this.usedColourMapTypes.put(colourType, markerName);
        this.usedColourMapNames.put(markerName, colourType);
        this.colourMap.put(markerName, hexCode);
    }

    static testMethod void testMap() {

        Account testOrg = Utils.createTestOrganisation('Rock');
        Database.insert(testOrg);

        Client_Location__c location = new Client_Location__c();
        location.Account__c = testOrg.Id;
        location.Latitude__c = '0';
        location.Longitude__c = '0';
        location.Type__c = 'Rain Gauge';
        location.Display_Name__c = 'Municiple';
        location.Description__c = 'Waste';
        Database.insert(location);

        Dashboard__c dashboard = new Dashboard__c();
        dashboard.Description__c = 'Lobster';
        dashboard.Title__c = 'Rock';
        dashboard.Account__c = testOrg.Id;
        Database.insert(dashboard);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dashboard.Id;
        section.Title__c = 'Lobster';
        section.Display_Order__c = 0;
        Database.insert(section);

        Map_Parameter__c testMap = new Map_Parameter__c();
        testMap.Dashboard_Section__c = section.Id;
        testMap.Keyword__c = 'Rain Gauge';
        testMap.Latitude__c = '1';
        testMap.Longitude__c = '2';
        testMap.Splitter__c = 'Gender';
        testMap.Title__c = 'We';
        testMap.Type_Of_sObject__c = 'Client Location';
        testMap.Zoom__c = 8;
        Database.insert(testMap);

        MapComponentController controller = new MapComponentController();
        controller.setExpanded(false);
        controller.setsObjectRecord(testMap);
        controller.getZoom();
        controller.getTypeOfsObject();
        controller.getTitle();
        controller.getStats();
        controller.getMapMarkers();
        controller.getLongitude();
        controller.getDisableControls();
        controller.getDisableInfoWindows();
        controller.getDisableKey();
        controller.getIsRefresh();
        controller.getKeyText();
        controller.getLatitude();
        controller.refreshData();
    }

}