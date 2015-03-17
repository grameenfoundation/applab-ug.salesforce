public class MetricMapController {

    private MetricMapWrapper[] ckwMarkers;
    private String mapTitle;
    private String quarter;
    private String typeOfMap;
    private String startLatitude;
    private String startLongitude;
    private String keyText;
    private String disableControls;
    private String disableInfoWindows;
    private String zoom;
    private String disableKey;
    private String extendHeight;
    private String suppressFeedback;
    private String feedbackMessage;
    private String stats;

    private DashboardSelectorController dashboardSelectorController;
    private   Map<String, String> defaultColourMap;
    Transient Map<String, String> colourMap;
    Transient Map<String, String> usedColourMapTypes;
    Transient Map<String, String> usedColourMapNames;
    Transient Set<String> usedColours;
    Transient Map<String, String> variables;
    Transient Map<String, String> ckwNameMap;
    Transient Map<String, String> farmerNameMap;
    public Boolean defaultedSubmissionStartDate;
    public Boolean defaultedSubmissionEndDate;

    public MetricMapController() {
        setUpPage();
    }

    private void setUpPage() {
        PageReference pageRef = ApexPages.currentPage();
        this.variables = pageRef.getParameters();
        setQuarter(getNamedVariable('quarter'));
        setTypeOfMap(getNamedVariable('type'));
        String startLatitude = '';
        String startLongitude = '';
        String district = getNamedVariable('district');
        if (district != null && !district.equals('')) {
            District__c districtSObject = database.query(SoqlHelpers.getDistrict(district));
            if (districtSObject != null) {
                startLatitude = String.valueOf(districtSObject.Latitude__c);
                startLongitude = String.valueOf(districtSObject.Longitude__c);
            }
        }
        setStats('');
        setFeedbackMessage('');
        setSuppressFeedback();

        // Default the search range just in case. Should stop limit issues.
        Date now = date.today();
        Integer gap = -14;
        if ((this.variables.get('ckws')!= null && !this.variables.get('ckws').equals('')) || (this.variables.get('farmers') != null && !this.variables.get('farmers').equals(''))) {
            gap = -60;
        }
        if (getNamedVariable('searchStartDate').equals('')) {
            this.variables.put('searchStartDate', MetricHelpers.parseInstanceDateToString(now.addDays(gap)));
        }
        if (getNamedVariable('searchEndDate').equals('')) {
            this.variables.put('searchEndDate', MetricHelpers.parseInstanceDateToString(now));
        }

        this.defaultedSubmissionStartDate = false;
        this.defaultedSubmissionEndDate = false;
        if (getNamedVariable('submissionStartDate').equals('')) {
            this.defaultedSubmissionStartDate = true;
            this.variables.put('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(now.addDays(gap)), false));
        }
        if (getNamedVariable('submissionEndDate').equals('')) {
            this.defaultedSubmissionEndDate = true;
            this.variables.put('submissionEndDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(now), false));
        }

        setStartLatitude(startLatitude);
        setStartLongitude(startLongitude);
        setZoom(null);
        setDisableKey();
        setDisableInfoWindows();
        setDisableControls();
        setDefaultColourMap();

        // Ensure that the ids passed in are wrapped in quotes. Cant assume this.
        List<String> ids = getNamedVariable('farmers').split(',');
        if (!ids.isEmpty() && ids[0] != null && !ids[0].equals('')) {
            this.variables.put('farmers', MetricHelpers.generateCommaSeperatedString(ids, MetricHelpers.checkListNeedsQuotes(ids)));
        }
        ids.clear();
        ids = getNamedVariable('ckws').split(',');
        if (!ids.isEmpty() && ids[0] != null && !ids[0].equals('')) {
            this.variables.put('ckws', MetricHelpers.generateCommaSeperatedString(ids, MetricHelpers.checkListNeedsQuotes(ids)));
        }
        ids.clear();
        ids = getNamedVariable('surveyName').split(',');
        if (!ids.isEmpty() && ids[0] != null && !ids[0].equals('')) {
            this.variables.put('surveyName', MetricHelpers.generateCommaSeperatedString(ids, MetricHelpers.checkListNeedsQuotes(ids)));
        }
        ids.clear();

        try {
            setCkwMarkers();
        }
        catch (ListException lex) {
            setFeedbackMessage('Error: Your search hase returned too many items. Please narrow the search');
            System.debug(LoggingLevel.ERROR, lex.getMessage());
        }
        catch (QueryException qex) {
            setFeedbackMessage('Error: Your search hase returned too many items. Please narrow the search');
            System.debug(LoggingLevel.ERROR, qex.getMessage());
        }
        catch (Exception e) {
            setFeedbackMessage('Error: An error has occured. Please try again');
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        setKeyText();
        setMapTitle();
        setExtendHeight();
    }

    private String getNamedVariable(String name) {

        String var = variables.get(name);
        if (var == null || var.equals('')) {
            return '';
        }
        return var;
    }

    /**
     *  Get the markers that we want to go on to the map.
     *
     */
    private MetricMapWrapper[] getMapMarkers() {

        // Include some static data
        List<MetricMapWrapper> markers = getStaticMarkers();

        // Decide which object we are basing this map on
        String mapObject = getNamedVariable('mapObject');
        if (mapObject.equals('CKW') || mapObject.equals('')) {
            List<MetricMapWrapper> ckwMapMarkers = getCkwMapMarkers();
            setStats('There are ' + ckwMapMarkers.size() + ' CKWs who match your search<br/>');
            markers.addAll(ckwMapMarkers);
            ckwMapMarkers.clear();
        }
        if (mapObject.equals('FARMER') || getNamedVariable('incFarmers').equals('true')) {
            List<MetricMapWrapper> farmerMapMarkers = getFarmerMapMarkers();
            setStats('There are ' + farmerMapMarkers.size() + ' farmers who match your search<br/>');
            markers.addAll(farmerMapMarkers);
            farmerMapMarkers.clear();
        }
        if (mapObject.equals('SEARCHES') || (getNamedVariable('incSearches').equals('true') && (!getNamedVariable('ckws').equals('') || !getNamedVariable('farmers').equals('')))) {
            markers.addAll(getSearchesMapMarkers());
        }
        if (mapObject.equals('SURVEYS') || (getNamedVariable('incSurveys').equals('true') && (!getNamedVariable('ckws').equals('') || !getNamedVariable('farmers').equals('')))) {
            if (!this.defaultedSubmissionStartDate) {
                this.variables.put('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(MetricHelpers.convertStringToDate(getNamedVariable('submissionStartDate'))), false));
            }
            if (!this.defaultedSubmissionEndDate) {
                this.variables.put('submissionEndDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(MetricHelpers.convertStringToDate(getNamedVariable('submissionEndDate'))), false));
            }
            List<MetricMapWrapper> submissionMapMarkers = getSubmissionMapMarkers();
            setStats('There are ' + submissionMapMarkers.size() + ' submissions who match your search<br/>');
            markers.addAll(submissionMapMarkers);
            submissionMapMarkers.clear();
        }
        if (mapObject.equals('METRICS')) {
            List<MetricMapWrapper> metricMapMarkers = getMetricMapMarkers();
            setStats('There are ' + metricMapMarkers.size() + ' metrics who match your search<br/>');
            markers.addAll(metricMapMarkers);
            metricMapMarkers.clear();
        }
        if(mapObject.equals('HARVEST')){
            List<MetricMapWrapper> harvestMapMarkers = EWarehouseMEDashboardController.getHarvestMapMarkers();
            setStats('There are ' + harvestMapMarkers.size() + ' metrics who match your search<br/>');
            markers.addAll(harvestMapMarkers);
            harvestMapMarkers.clear();
        }
        if(mapObject.equals('HUB')){
            List<MetricMapWrapper> diaryHubsMapMarkers = EADDDashboardController.getDairyHubMapMarkers();
            setStats('There are ' + diaryHubsMapMarkers.size() + ' metrics who match your search<br/>');
            markers.addAll(diaryHubsMapMarkers);
            diaryHubsMapMarkers.clear();
        }
        if(mapObject.equals('IG')){
            List<MetricMapWrapper> fieldVisits = IGDashboardHelpers.getFieldVisitsMapMarkers(getNamedVariable('ig_region'), getNamedVariable('ig_district'), getNamedVariable('ig_subcounty'), getNamedVariable('ig_startdate'), getNamedVariable('ig_enddate'), getNamedVariable('ig_cbt'));
            setStats('There are ' + fieldVisits.size() + ' metrics which match your search<br/>');
            markers.addAll(fieldVisits);
            fieldVisits.clear();
        }
        if(mapObject.equals('GUMUTINDO_CKWS')){
            List<MetricMapWrapper> fieldVisits = GumutindoHelpers.getCKWMapMarkers();
            setStats('There are ' + fieldVisits.size() + ' metrics which match your search<br/>');
            markers.addAll(fieldVisits);
            fieldVisits.clear();
        }
        if(mapObject.equals('GUMUTINDO_PRIMARY_SOCIETIES')){
            List<MetricMapWrapper> fieldVisits = GumutindoHelpers.getGumutindoPrimarySocietyMarkers();
            setStats('There are ' + fieldVisits.size() + ' metrics which match your search<br/>');
            markers.addAll(fieldVisits);
            fieldVisits.clear();
        }
        if(mapObject.equals('MBUGO_CKWS')){
            List<MetricMapWrapper> fieldVisits = MbugoHelpers.getCKWMapMarkers();
            setStats('There are ' + fieldVisits.size() + ' metrics which match your search<br/>');
            markers.addAll(fieldVisits);
            fieldVisits.clear();
        }
        if(mapObject.equals('GUMUTINDO_FIELD_OFFICERS')){
            List<MetricMapWrapper> fieldVisits = MbugoHelpers.getFOMapMarkers();
            setStats('There are ' + fieldVisits.size() + ' metrics which match your search<br/>');
            markers.addAll(fieldVisits);
            fieldVisits.clear();
        }
        System.debug('Should show ' + markers.size() + ' map markers');
        if (markers.size() == 0) {
            setFeedbackMessage('No map markers match your selection. Please refine your search to see a map');
        }
        return markers;
    }

    private MetricMapWrapper[] getMetricMapMarkers() {

        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();

        // Get the date range. This can be from an actual date or from the quarter string. TODO - support actual dates
        Date startDate;
        Date endDate;
        if (!getNamedVariable('quarter').equals('')) {
            startDate = MetricHelpers.getQuarterFirstDay(getNamedVariable('quarter'));
            endDate = MetricHelpers.getQuarterLastDay(getNamedVariable('quarter'));
        }
        List<String> metricsRequired = new List<String>();
        for (String metricName : getNamedVariable('metrics').split(';')) {
            metricsRequired.add(metricName);
        }
        for (M_E_Metric_Data__c metricData : MetricHelpers.getMetricDatas(metricsRequired, startDate, endDate, null)) {

            // Check that we have a valid location for the district
            if (metricData.District__r.Latitude__c == null || metricData.District__r.Longitude__c == null) {
                continue;
            }
            String colour = 'Red';
            String fieldValue = '';
            String colourHex = getColour(colour, generateMarkerName('Metric', metricData.M_E_Metric__r.Label__c, fieldValue));
            MetricMapWrapper marker = generateMetricWrapper(metricData, colourHex);
            markers.put(metricData.District__r.Name, marker);
        }
        return markers.values();
    }

    private MetricMapWrapper generateMetricWrapper(M_E_Metric_Data__c metricData, String colourHex) {

        MetricMapWrapper marker = new MetricMapWrapper('Metric', colourHex, metricData.Id, false);
        marker.gpsLatitude = String.valueOf(metricData.District__r.Latitude__c);
        marker.gpsLongitude = String.valueOf(metricData.District__r.Longitude__c);
        marker.addName(metricData.M_E_Metric__r.Label__c);
        marker.addLocation(metricData.District__r.Name);
        marker.addThisMonthPerformance(String.valueOf(metricData.Real_Value__c));
        marker.addPerformanceLevel(String.valueOf(metricData.Projected_Value__c));
        return marker;
    }

    private MetricMapWrapper[] getSubmissionMapMarkers() {

        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        for (Submission_Meta_Data__c submission : database.query(SoqlHelpers.getSubmissions(variables))) {

            // Check that we have valid location data for this submission.
            if (submission.Survey__c == null || submission.Interviewer__c == null || submission.Interview_Latitude__c == null || submission.Interview_Longitude__c == null) {
                continue;
            }
            String colour = 'Red';
            String fieldValue = '';
            String colourHex = getColour(colour, generateMarkerName('Submission', submission.Survey_Name__c, fieldValue));
            MetricMapWrapper marker = generateSubmissionWrapper(submission, colourHex);
            markers.put(submission.Id, marker);
        }
        return markers.values();
    }

    private MetricMapWrapper generateSubmissionWrapper(Submission_Meta_Data__c submission, String colourHex) {

        MetricMapWrapper marker = null;
            marker = new MetricMapWrapper('SurveySubmission', colourHex, submission.Id, true);
            marker.gpsLatitude = String.valueOf(submission.Interview_Latitude__c);
            marker.gpsLongitude = String.valueOf(submission.Interview_Longitude__c);
            marker.addName(submission.Survey_Name__c);

            // Add the interviewer
            marker.addCkwParent(submission.Interviewer__r.Name);

            // Add the interviewee if possible
            marker.addFarmerParent(submission.Interviewee__r.Name);

            marker.addSurveyId(submission.Survey__c);
            marker.addInterviewerId(submission.Interviewer__c);
            if (submission.Interviewee__c != null) {
                marker.addIntervieweeId(submission.Interviewee__c);
            }
            marker.addSurveyId(submission.Survey__r.Name);
            return marker;
    }

    private MetricMapWrapper[] getSearchesMapMarkers() {

        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        List<String> words = new List<String>();
        Set<String> foundSearches = new Set<String>();
        Boolean incSeachSubLoc = Boolean.valueOf(getNamedVariable('incSeachSubLoc'));

        if (getNamedVariable('keywords').equals('')) {
            words.add('');
        }
        else {
            words = getNamedVariable('keywords').split(';');
        }
        Integer searchMarker = 0;
        Integer searchSubmissionMarker = 0;
        Integer label = 1;
        for (String word : words) {
            variables.put('keyword', word);
            for (Search_Log__c log : database.query(SoqlHelpers.getSearches(variables))) {

                // Create the marker for the place the search was carried out.
                if (foundSearches.contains(log.Record_ID__c) || log.Latitude__c == null || log.Longitude__c == null) {
                    continue;
                }
                foundSearches.add(log.Record_ID__c);
                String colourHex = null;
                String labelToShow = '';
                if (incSeachSubLoc) {
                    labelToShow = String.valueOf(label);
                }
                colourHex = getColour('Red', generateMarkerName('Search', 'Carried Out', word));
                MetricMapWrapper marker = generateSearchWrapper(log, colourHex, false, labelToShow, word);
                markers.put(log.Record_ID__c, marker);
                searchMarker++;

                // Create the marker for the place that the search was submitted if possible and required.
                if (incSeachSubLoc && log.Submission_Latitude__c != null && log.Submission_Longitude__c != null) {
                    colourHex = getColour('Blue', generateMarkerName('Search', 'Submitted', word));
                    marker = generateSearchWrapper(log, colourHex, true, labelToShow, word);
                    markers.put(log.Record_ID__c + '_Sub', marker);
                    searchSubmissionMarker++;
                }
                label++;
            }
        }
        if (searchMarker != 0) {
            setStats('There are ' + searchMarker + ' searches that match your search<br/>');
        }
        if (searchSubmissionMarker != 0) {
            setStats('There are ' + searchSubmissionMarker + ' search submissions that match your search<br/>');
        }
        words.clear();
        foundSearches.clear();
        return markers.values();
    }

    private MetricMapWrapper generateSearchWrapper(Search_Log__c log, String colourHex, Boolean isSubmission, String label, String keyword) {
        
        MetricMapWrapper marker;
        if (isSubmission) {
            marker = new MetricMapWrapper('SearchSub', colourHex, log.Record_ID__c, true);
            marker.gpsLatitude = String.valueOf(log.Submission_Latitude__c);
            marker.gpsLongitude = String.valueOf(log.Submission_Longitude__c);
        }
        else {
            marker = new MetricMapWrapper('Search', colourHex, log.Record_ID__c, true);
            marker.gpsLatitude = String.valueOf(log.Latitude__c);
            marker.gpsLongitude = String.valueOf(log.Longitude__c);
        }
        marker.addQuery(log.Query__c);
        marker.addFarmerParent(log.Interviewee__r.Name);
        marker.addCkwParent(log.Interviewer__r.Name);
        marker.addLabel(label);
        marker.addKeyword(keyword);
        marker.addSearchTime(String.valueOf(log.Handset_Submit_Time__c));
        marker.addSubmitTime(String.valueOf(log.Server_Entry_Time__c));
        return marker;
    }

    private MetricMapWrapper[] getFarmerMapMarkers() {

        Farmer__c[] farmers = database.query(SoqlHelpers.getFarmers(variables, false));

        List<String> personIds = new List<String>();
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();

        for (Farmer__c farmer : farmers) {

            // Dont include if we are missing the location
            if (farmer.Person__r.GPS_Location_N__c == null || farmer.Person__r.GPS_Location_E__c == null) {
                continue;
            }

            // Work out what sort of colour we are going to use
            String colourType = getNamedVariable('colourType');
            String fieldValue = '';
            String colour = '';

            if (colourType.equals('Gender')) {
                fieldValue = farmer.Person__r.Gender__c;
                colour = 'Pink';
                if (fieldValue == null) {
                    colour = 'Black';
                    fieldValue = 'Missing';
                }
                else if (fieldValue.equals('Male')) {
                    colour = 'Blue';
                }
            }
            else if (colourType.equals('')) {
                fieldValue = '';
                colour = 'Red';
            }

            String colourHex = getColour(colour, generateMarkerName('Farmer', colourType, fieldValue));
            MetricMapWrapper marker = generateFarmerWrapper(farmer, colourHex);
            markers.put(farmer.person__c, marker);
        }

        farmers.clear();
        return markers.values();
    }

    private MetricMapWrapper generateFarmerWrapper(Farmer__c farmer, String colourHex) {

            MetricMapWrapper marker = null;
            marker = new MetricMapWrapper('Farmer', colourHex, farmer.Person__c, true);
            marker.gpsLatitude = farmer.Person__r.GPS_Location_N__c;
            marker.gpsLongitude = farmer.Person__r.GPS_Location_E__c;
            marker.addGender(getGender(farmer.Person__r.Gender__c));
            marker.addName(farmer.Name);
            String location = getLocation(farmer.Person__r.Parish__c, farmer.Person__r.Village__c);
            marker.addLocation(location);
            marker.addCkwParent(farmer.Registered_By__r.Name);
            return marker;
    }

    // Going to have an issue here when we hit 50,000 CKWs. I am going to choose to live with it for awhile
    private MetricMapWrapper[] getCkwMapMarkers() {

        CKW__c[] ckws = database.query(SoqlHelpers.getCkws(this.variables, false));
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
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

            // Work out what sort of colour we are going to use
            String colourType = getNamedVariable('colourType');
            String fieldValue = '';
            String colour = '';
            if (colourType.equals('Gender')) {
                fieldValue = ckw.Person__r.Gender__c;
                colour = 'Pink';
                if (fieldValue == null) {
                    colour = 'Black';
                    fieldValue = 'Missing';
                }
                else if (fieldValue.equals('Male')) {
                    colour = 'Blue';
                }
            }
            else if (colourType.equals('Status')) {
                fieldValue = ckw.Status__c;
                colour = 'Yellow';
                if (fieldValue == null) {
                    colour = 'Black';
                    fieldValue = 'Missing';
                }
                else if (fieldValue.equals('Active')) {
                    colour = 'White';
                }
                else {
                    fieldValue = 'Inactive';
                }
            }
            else if (colourType.equals('Poverty')) {
                fieldValue = ckw.Poverty_Status__c;
                colour = 'Green';
                if (fieldValue == null) {
                    colour = 'Black';
                    fieldValue = 'Missing';
                }
                else if (fieldValue.equals('Not Poor')) {
                    colour = 'Yellow';
                    fieldValue = 'Poor';
                }
                else {
                    fieldValue = 'Very Poor';
                }
            }
            else if (colourType.equals('')) {
                fieldValue = '';
                colour = 'Red';
            }

            String colourHex = getColour(colour, generateMarkerName('CKW', colourType, fieldValue));
            MetricMapWrapper marker = generateCKWWrapper(ckw, colourHex);
            markers.put(ckw.person__c, marker);
        }
 
        // Get the organisation details for the Ckws
        if (personIds.size() > 0) {
            Person_Project_Association__c[] projects = getProjectList(personIds,'Person__c');
            Map<String, Project__c> projectDetails = getProjectDetails(getNamedVariable('project'));
            for (Person_Project_Association__c project : projects) {
                MetricMapWrapper marker = markers.get(project.Person__c);
                marker.addToProjectDesc(projectDetails.get(project.Project__c).Name, projectDetails.get(project.Project__c));
            }
            projects.clear();
            projectDetails.clear();
        }

        // If there is only one CKW the center the map around them and zoom to a better level
        if (markers.size() == 1 && ckws.size() == 1) {
            setZoom('10');
            setStartLatitude(ckws[0].Person__r.GPS_Location_N__c);
            setStartLongitude(ckws[0].Person__r.GPS_Location_E__c);
        }
 
        // Tidy up the created lists so to keep the heap size down.
        ckws.clear();
        return markers.values();
    }

    private MetricMapWrapper generateCKWWrapper(CKW__c ckw, String colourHex) {

            MetricMapWrapper marker = null;
            marker = new MetricMapWrapper('CKW', colourHex, ckw.Person__c, true);
            marker.gpsLatitude = ckw.Person__r.GPS_Location_N__c;
            marker.gpsLongitude = ckw.Person__r.GPS_Location_E__c;
            marker.addGender(getGender(ckw.Person__r.Gender__c));

            String name = ckw.Name;
            marker.addName(name);
            String location = getLocation(ckw.Person__r.Parish__c, ckw.Person__r.Village__c);
            marker.addLocation(location);

            String thisMonthPerformance = 'No performance record for this month<br />';
            if (ckw.Current_Performance_Review__c != null) {
               thisMonthPerformance = 'This months search target is: ' + ckw.Current_Performance_Review__r.Monthly_Target__r.Search_Target__c + '<br />' +
                                      'Searches performed this month: ' + ckw.Current_Performance_Review__r.Total_Searches__c + '<br />' +
                                      'This months surveys target is: ' + ckw.Current_Performance_Review__r.Monthly_Target__r.Survey_Target__c + '<br />' +
                                      'Surveys carried out this month: '+ ckw.Current_Performance_Review__r.Total_Surveys__c + '<br />';
            }
            marker.addThisMonthPerformance(thisMonthPerformance);
            String performance = 'Last months performance level is unavailable';
            if (ckw.Previous_Performance_Review__c != null) {
                performance = 'Last months performance level was: ' + ckw.Previous_Performance_Review__r.Performance_Level__c;
            }
            marker.addPerformanceLevel(performance);
            marker.markerTitle = name;
            return marker;
    }

    private String getGender(String gender) {

        String personGender = '';
        if (gender != null) {
            personGender = 'Gender: ' + gender;
        }
        return personGender;
    }
    private String getLocation(String parish, String village) {

        String location = '';
        if (parish != null) {
            location = 'Parish: ' + parish + '<br />';
        }
        if (village != null) {
            location = location + 'Village: ' + village + '<br />';
        }
        return location;
    }

    private List<MetricMapWrapper> getStaticMarkers() {

        List<MetricMapWrapper> markers = new List<MetricMapWrapper>();

        return markers;
    }

    private Person_Project_Association__c[] getProjectList(List<String> values, String name) {

        String query = 'SELECT '                 +
                'Person__c, '                    +
                'Project__c '                    +
            'FROM '                              +
                'Person_Project_Association__c ' +
            'WHERE '                             +
                name + ' IN ('                   + 
                    MetricHelpers.generateCommaSeperatedString(values, true) + 
                ')';
        System.debug(LoggingLevel.INFO, query);
        return database.query(query);
    }

    private Map<String, Project__c> getProjectDetails(String values) {

        String query = 'SELECT '        +
                'Description__c, '      +
                'Id, '                  +
                'Name, '                +
                'Organisation__r.Name ' +
            'FROM '                     +
                'Project__c';
        if (values.length() > 0) {
            query = query + ' WHERE Id IN (' + values + ')';
        }
        System.debug(LoggingLevel.INFO, query);
        Project__c[] projects = database.query(query);
        Map<String, Project__c> projectMap = new Map<String, Project__c>();
        for (Project__c project : projects) {
            projectMap.put(project.Id, project);
        }
        return projectMap;
    }

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

    private String generateMarkerName(String mapObject, String markerField, String markerFieldValue) {

        // Note that you should pass an empty string if one of the input values does not apply
        return mapObject + '#@#' + markerField + '#@#'+ markerFieldValue;
    }

    public void setKeyText() {
        String text = '';
        for (String key : this.usedColourMapNames.keySet()) {
            String[] items = key.split('#@#');
            text = text + this.usedColourMapNames.get(key).replace('_', ' ') + ': ';
            for (String item : items) {
                text = text + item + ' ';
            }
            text = text + '<br />';
        }
        this.keyText = text;
    }

    public String getKeyText() {
        return this.keyText;
    }

    public String getTypeOfMap() {
        return this.typeOfMap;
    } 

    public void setTypeOfMap(String input) {
        this.typeOfMap = input;
    }

    public String getStartLatitude() {
        return this.startLatitude;
    }

    public void setStartLatitude(String latitude) {

        if (latitude.equals('')) {
            String var = getNamedVariable('startLat');
            if (var.equals('')) {
                this.startLatitude = '0.625';
            }
            else {
                this.startLatitude = var;
            }
        }
        else {
            this.startLatitude = latitude;
        }
    }

    public String getStartLongitude() {
        return this.startLongitude;
    }

    public void setStartLongitude(String longitude) {

        if (longitude.equals('')) {
            String var = getNamedVariable('startLng');
            if (var.equals('')) {
                this.startLongitude = '32.351';
            }
            else {
                this.startLongitude = var;
            }
        }
        else {
            this.startLongitude = longitude;
        }
    }

    public MetricMapWrapper[] getCkwMarkers() {

        return ckwMarkers;
    }

    public void setCkwMarkers() {
        ckwMarkers = getMapMarkers();
    }

    public String getMapTitle() {
        return mapTitle;
    }

    public void setMapTitle() {

        // For the moment just set this to a basic string.
        mapTitle = 'CKW Distribution for Quarter ' + quarter;
    }

    public String getQuarter() {
        return quarter;
    }

    public void setQuarter(String quarterString) {

        if (quarterString != null && !quarterString.equals('')) {
            variables.put('endDate', MetricHelpers.getQuarterLastDayAsString(quarterString));
        }
        quarter = quarterString;
    }

    public String getDisableControls() {
        return disableControls;
    }

    public void setDisableControls() {

        String var = getNamedVariable('disableControls');
        if (var.equals('')) {
            disableControls = 'false';
        }
        else {
            disableControls = var;
        }
    }

    public String getDisableInfoWindows() {
        return disableInfoWindows;
    }

    public void setDisableInfoWindows() {

        String var = getNamedVariable('disableInfoWindows');
        if (var.equals('')) {
            disableInfoWindows = 'false';
        }
        else {
            disableInfoWindows = var;
        }
    }

    public String getDisableKey() {
        return disableKey;
    }

    public void setDisableKey() {

        String var = getNamedVariable('disableKey');
        if (var.equals('')) {
            disableKey = 'false';
        }
        else {
            disableKey = var;
        }
    }

    public String getZoom() {
        return zoom;
    }

    public void setZoom(String zoomValue) {

        String var = getNamedVariable('zoom');
        if (zoomValue != null) {
            var = zoomValue;
        }
        if (var.equals('')) {
            zoom = '7';
        }
        else {
            zoom = var;
        }
    }

    public String getExtendHeight() {
        return extendHeight;
    }

    public void setExtendHeight() {

        String var = getNamedVariable('extendHeight');
        if (var.equals('')) {
            extendHeight = 'false';
        }
        else {
            extendHeight = var;
        }
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

    public void setSuppressFeedback() {

        String var = getNamedVariable('suppressFeedback');
        if (var.equals('true')) {
            this.suppressFeedback = 'true';
        }
        else {
            this.suppressFeedback = 'false';
        }
    }

    public String getSuppressFeedback() {
        return this.suppressFeedback;
    }

    static testMethod void testCkwMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'CKW');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }

    static testMethod void testFarmerMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'FARMER');
        variableMap.put('colourType', 'Gender');
        variableMap.put('district', 'Gulu');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }

    static testMethod void testSearchesMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'SEARCHES');
        variableMap.put('colourType', 'Gender');
        variableMap.put('searchStartDate', '01/02/2011');
        variableMap.put('searchEndDate', '01/01/2011');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }

    static testMethod void testSubmissionMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'SURVEYS');
        variableMap.put('submissionStartDate', '01/08/2011');
        variableMap.put('submissionEndDate', '01/09/2011');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        mapController.defaultedSubmissionStartDate = false;
        mapController.defaultedSubmissionEndDate = false;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }

    static testMethod void testMetricsMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'METRICS');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }
    
    static testMethod void testHubsMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'HUB');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }
    
    static testMethod void testIGNUSAFMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'IG');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }
    
    static testMethod void testHarvestsMapController() {

        PageReference pageRef = Page.MetricMap;
        Test.setCurrentPageReference(pageRef);
        MetricMapController mapController = new MetricMapController();
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('mapObject', 'HARVEST');
        variableMap.put('colourType', 'Gender');
        mapController.variables = variableMap;
        Test.startTest();
        mapController.setCkwMarkers();
        Test.stopTest();
    }
}