public class CkwManagementContoller {

    public String district { get; set; }
    public List<SelectOption> districtList;
    public List<SelectOption> getDistrictList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- In All District --'));
        District__c[] districts = database.query(SoqlHelpers.getDistricts(null));
        for (District__c district : districts) {
            options.add(new SelectOption(district.Name, district.Name));
        }
        return options;
    }
    public void setDistrictList(List<SelectOption> options) {
        this.districtList = options;
    }

    public List<SelectOption> ckwList;
    public List<SelectOption> getCkwList() {

        List<SelectOption> options = new List<SelectOption>();
        if (stopCkws()) {
            options.add(new SelectOption('', '---Please select a District or Group---'));
            return options;
        }

        getCkwDetails(getCkwParameters());
        options.add(new SelectOption('', '---Select a CKW if required--'));
        if (this.ckwDetails.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No CKWs match your parameters. Please try some others'));
            return options;
        }
        for (CKW__c ckw : this.ckwDetails) {
            options.add(new SelectOption(ckw.Person__r.Id, ckw.Name + ' ' + ckw.Person__r.Last_Name__c + ' ' + ckw.Person__r.First_Name__c));
        }
        return options;
    }
    public void setCkwList(List<SelectOption> options) {
        this.ckwList = options;
    }

    public String groups { get; set; }
    public List<SelectOption> groupList;
    public List<SelectOption> getGroupList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please select a Group---'));

        Group__c[] groups = [
            SELECT
                Name,
                Id
            FROM
                Group__c
            WHERE
                Id IN (
                        SELECT
                            Group__c
                        FROM
                            Person_Group_Association__c
                        WHERE
                            Person__r.Type__c = 'CKW'
                    )
        ];
        for (Group__c singleGroup : groups) {
            options.add(new SelectOption(singleGroup.Id, singleGroup.Name));
        }
        return options;
    }
    public void setGroupList(List<SelectOption> options) {
        this.groupList = options;
    }

    public String imei;
    public String getImei() {
       return this.imei;
    }
    public void setImei(String imei) {
        this.imei = imei;
    }

    public List<SelectOption> status;
    public List<SelectOption> getStatus() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a Status---'));
        Schema.DescribeFieldResult field = CKW__c.Status__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            options.add(new SelectOption(f.getLabel(), f.getLabel()));
        }
        return options;
    }
    public void setStatus(List<SelectOption> genders) {
        this.status = status;
    }

    // Date range selector
    public Date_Picker__c datePicker { get; set; }

    // Variables that control which sections of the page get rendered.
    public Boolean showCkwDetails { get; set; }
    public Boolean showBioDetails { get; set; }
    public Boolean showGroups { get; set; }
    public Boolean showSurveys { get; set; }
    public Boolean showPerformance { get; set; }
    public Boolean showCheckPerformance { get; set; }
    public Boolean hasUpdated { get; set; }

    public List<CKW__c> ckwDetails { get; set; }

    private Map<String, String> variableMap;

    /**
     *  Constructor for this controller
     */
    public CkwManagementContoller() {
        setUp();
    }

    /**
     *  Set the page back to the defaults
     */
    public void setUp() {

        // Default the date picker
        this.datePicker = new Date_Picker__c();
        this.datePicker.Start_Date__c = null;
        this.datePicker.End_Date__c = null;

        // Default the display controls
        this.showCkwDetails = false;
        this.showBioDetails = false;
        this.showGroups = false;
        this.showSurveys = false;
        this.showPerformance = false;
        this.showCheckPerformance = false;

        clearVariableMap();
    }

    public PageReference changeCkwStatus() {

        addParameter('group', Apexpages.currentPage().getParameters().get('groupListParam'));
        addParameter('ckws', Apexpages.currentPage().getParameters().get('ckwParam'));
        addParameter('imei', Apexpages.currentPage().getParameters().get('imeiParam'));
        addParameter('startDate', Apexpages.currentPage().getParameters().get('startDateParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('startDateParam'));
        addParameter('status', Apexpages.currentPage().getParameters().get('statusParam'));

        // If the imei is set then get the personId
        setPersonId(getParameter('imei'));

        // Update the status
        try {
            String result = updateCkwStatus();
            if (!result.equals('SUCCESS')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'CKW status updated'));

                // Show the CKWs to validate the status change
                this.showCkwDetails = true;
                getCkwDetails(null);
            }
        }
        catch (Exception e) {
            this.showCkwDetails = false;
            this.showBioDetails = false;
            this.showGroups = false;
            this.showSurveys = false;
            this.showPerformance = false;
            this.showCheckPerformance = false;
            this.hasUpdated = false;
            System.debug(LoggingLevel.INFO, e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. If this persists please contact support'));
        }

        return null;
    }

    private String updateCkwStatus() {

        // Get all the CKWs
        CKW__c[] ckws = database.query(SoqlHelpers.getCkws(this.variableMap, true));
        if (ckws.isEmpty()) {
            return 'No CKWs match your search criteria. Please try again';
        }
        for (CKW__c ckw : ckws) {
            ckw.Status__c = getParameter('status');
        }
        database.update(ckws);
        return 'SUCCESS';
    }

    public PageReference submitRequest() {

        addParameter('district', Apexpages.currentPage().getParameters().get('districtParam'));
        addParameter('group', Apexpages.currentPage().getParameters().get('groupListParam'));
        addParameter('ckws', Apexpages.currentPage().getParameters().get('ckwParam'));
        addParameter('imei', Apexpages.currentPage().getParameters().get('imeiParam'));
        addParameter('startDate', Apexpages.currentPage().getParameters().get('startDateParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('startDateParam'));
        addParameter('endDate', Apexpages.currentPage().getParameters().get('endDateParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('endDateParam'));
        addParameter('allowInactive', 'true');
        addParameter('updateReview', Apexpages.currentPage().getParameters().get('updateReviewParam'));
        String checkedDate = checkDates(30);
        if (!checkedDate.equals('SUCCESS')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, checkedDate));
            this.showCkwDetails = false;
            this.showBioDetails = false;
            this.showGroups = false;
            this.showSurveys = false;
            this.showPerformance = false;
            this.showCheckPerformance = false;
            this.hasUpdated = false;
            return null;
        }

        this.ckwListReview = '';
        this.imeiReview = '';
        this.startDateReview = '';
        this.endDateReview = '';

        // If the imei is set then get the personId
        setPersonId(getParameter('imei'));

        this.showCkwDetails = Boolean.valueOf(Apexpages.currentPage().getParameters().get('ckwDetailsParam'));
        this.showBioDetails = Boolean.valueOf(Apexpages.currentPage().getParameters().get('bioDetailsParam'));
        this.showGroups = Boolean.valueOf(Apexpages.currentPage().getParameters().get('groupsParam'));
        this.showSurveys = Boolean.valueOf(Apexpages.currentPage().getParameters().get('surveysParam'));
        this.showPerformance = Boolean.valueOf(Apexpages.currentPage().getParameters().get('performanceParam'));
        this.showCheckPerformance = Boolean.valueOf(Apexpages.currentPage().getParameters().get('checkPerformanceParam'));
        this.hasUpdated = false;

        // Generate the data that has been asked for
        try {

            // Always need to get the CKW details. Use the parameters passed in from the page.
            getCkwDetails(null);
            if (this.showGroups || this.showSurveys) {
                getGroupDetails();
            }
            if (this.showSurveys) {
                getSurveyDetails();
            }
            if (this.showPerformance) {
                getPerformanceDetails();
            }
            if (this.showCheckPerformance) {
                getCheckedPerformance();
            }

        }
        catch (Exception e) {
            this.showCkwDetails = false;
            this.showBioDetails = false;
            this.showGroups = false;
            this.showSurveys = false;
            this.showPerformance = false;
            this.showCheckPerformance = false;
            this.hasUpdated = false;
            System.debug(LoggingLevel.INFO, e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. If this persists please contact support'));
        }

        return null;
    }

    /**
     *  Check to see if we should load the CKWs or not.
     *  Must have an IMEI or a District of a group selected for this to return false
     */
    private Boolean stopCkws() {

        if ((this.district == null || this.district.equals('') )
                && (this.groups == null || this.groups.equals(''))
                && (this.getImei() == null || this.getImei().equals(''))
        ) {
            return true;
        }
        return false;
    }

    /**
     *  Check that two dates are not too far apart in number of days
     *
     *  @param gapAllowed - The number of days allowed between the dates
     *
     *  @return - Error message or 'SUCCESS' if ok
     */
    private String checkDates(Integer gapAllowed) {

        // Parse the parameters to dates
        String startString = getParameter('startDate');
        String endString = getParameter('endDate');

        // If the dates are not set then this check is irrelevant
        if (startString.equals('') || endString.equals('')) {
            return 'SUCCESS';
        }
        Date startDate = MetricHelpers.convertStringToDate(startString);
        Date endDate = MetricHelpers.convertStringToDate(endString);

        // Do the comparison
        Integer gap = startDate.daysBetween(endDate);
        if (gap > gapAllowed) {
         return 'Dates selected are to far apart. Maximum allowed is ' + gapAllowed + ' days aparts';
        }
        else if (gap < 0) {
            return 'End date is before start date. Please use different dates';
        }
        return 'SUCCESS';
    }

    public void setPersonId(String imei) {

        if (imei.equals('')) {
            return;
        }

        Person__c[] person = [
            SELECT
                Id
            FROM
                Person__c
            WHERE
                Handset__r.IMEI__c = :imei
        ];
        if (!person.isEmpty()) {
            addParameter('ckws', (String)person[0].Id);

            // If the imei is set and valid then remove the other params as this overides all
            addParameter('district', '');
            addParameter('group', '');
        }
    }

    /**
     *  Get the details of the CKWs that match the params passed in
     */
    private void getCkwDetails(Map<String, String> parameters) {

        if (parameters == null) {

            // Need a little switcheroo here to add '' around the ids
            String ckws = getParameter('ckws');
            if (!ckws.equals('')) {
                addParameter('ckws', MetricHelpers.generateCommaSeperatedString(ckws.split(','), true));
            }
            this.ckwDetails = database.query(SoqlHelpers.getCkws(this.variableMap, false));
            if (!ckws.equals('')) {
                addParameter('ckws', ckws);
            }
        }
        else {
            this.ckwDetails = database.query(SoqlHelpers.getCkws(parameters, true));
        }
    }

    /**
     *  Get the groups that a given person is in
     */
    public List<Group__c> personGroups{ get; set; }
    private void getGroupDetails() {

        // This is only supposed to be for people so check that some are available
        this.personGroups = new List<Group__c>();
        if (getParameter('ckws').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have not selected a CKW. Please try again'));
            this.showGroups = false;
            return;
        }

        String query =
            'SELECT '                                      +
                'Name, '                                   +
                'Id, '                                     +
                'Membership_Count__c '                     +
            'FROM '                                        +
                'Group__c '                                +
            'WHERE '                                       +
                'Id IN ('                                  +
                        'SELECT '                          +
                            'Group__c '                    +
                        'FROM '                            +
                            'Person_Group_Association__c ' +
                        'WHERE '                           +
                            SoqlHelpers.addInWhereClause('Person__c', false, getParameter('ckws'), null, true) + ' ' +
                    ')';
        System.debug(LoggingLevel.INFO, query);
        this.personGroups = database.query(query);
        if (this.personGroups.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no groups for your parameters. Please change your selection and try again'));
            this.showGroups = false;
            return;
        }
    }

    /**
     *  Get the surveys that are associated with the groups selected
     */
    public List<Survey__c> personSurveys { get; set; }
    private void getSurveyDetails() {

        // We must either have groups selected from the CKWs or from the UI
        if ((this.personGroups == null || this.personGroups.isEmpty()) && (this.groups == null || this.groups.equals(''))) {
            this.showSurveys = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have not chosen a group or a CKW with any groups. Please change your selection and try again'));
            return;
        }

        // Sort out the groupIds
        List<String> groupIds = new List<String>();
        if (this.groups == null || this.groups.equals('')) {
            for (Group__c g : this.personGroups) {
                groupIds.add((String)g.Id);
            }
        }
        else {
            groupIds.add(this.groups);
        }
        String query =
            'SELECT '                                  +
                'Name, '                               +
                'Id, '                                 +
                'Survey_Name__c, '                     +
                'Survey_Status__c, '                   +
                'Account__r.Name, '                    +
                'Start_Date__c, '                      +
                'End_Date__c '                         +
            'FROM '                                    +
                'Survey__c '                           +
            'WHERE '                                   +
                'Id IN ('                              +
                    'SELECT '                          +
                        'Survey__c '                   +
                    'FROM '                            +
                        'Survey_Group_Association__c ' +
                    'WHERE '                           +
                        SoqlHelpers.addInWhereClause('Group__c', false, null, groupIds, true) + ' ' +
                ')'     +
            'ORDER BY ' +
                'Survey_Name__c';
        System.debug(LoggingLevel.INFO, query);
        this.personSurveys = Database.query(query);
        if (this.personSurveys.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This CKW has no surveys attached to them'));
            this.showSurveys = false;
        }
        groupIds.clear();
    }

    /**
     *
     */
    public List<CKW_Performance_Review__c> personPerformances { get; set; }
    private void getPerformanceDetails() {

        if (getParameter('ckws').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have not selected a CKW. Please try again'));
            this.showPerformance = false;
            return;
        }

        // Default the dates if they are not there
        Boolean defaultStartDate = false;
        if (getParameter('startDate').equals('')) {
            defaultStartDate = true;
            addParameter('startDate', MetricHelpers.convertDateToNonSoqlString(Date.parse('06/01/2010')));
        }
        if (getParameter('endDate').equals('')) {
            addParameter('endDate', MetricHelpers.convertDateToNonSoqlString(Date.today()));
        }
        this.personPerformances = Database.query(PerformanceReviewHelpers.getPerformanceReviewQuery(getParameter('ckws').split(','),
            MetricHelpers.convertDateTimeToString(MetricHelpers.convertStringToDate(getParameter('startDate')), true),
            MetricHelpers.convertDateTimeToString(MetricHelpers.convertStringToDate(getParameter('endDate')), true))
        );
        if (this.personPerformances.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This CKW has no performance records'));
            this.showPerformance = false;
        }
        if (defaultStartDate) {
            addParameter('startDate', '');
        }
    }

    public CKW_Performance_Review__c currentReview { get; set; }
    public List<UpdatedReviewFigures> updatedReview { get; set; }
    public String imeiReview { get; set; }
    public String ckwListReview { get; set; }
    public String startDateReview { get; set; }
    public String endDateReview { get; set; }
    private void getCheckedPerformance() {

        this.updatedReview = new List<UpdatedReviewFigures>();

        // If no start date the use this month
        if (getParameter('startDate').equals('')) {
            addParameter('startDate', MetricHelpers.convertDateToNonSoqlString(Date.today().toStartOfMonth()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No dates set so showing this months record'));
        }
        if (getParameter('endDate').equals('')) {
            addParameter('endDate', MetricHelpers.convertDateToNonSoqlString(Date.today()));
        }

        // Set the parameters that will be passed back to this method for the update. This is done so that the user cannot chagne the params
        this.ckwListReview = getParameter('ckws');
        this.imeiReview = getParameter('imei');
        this.startDateReview = getParameter('startDate');
        this.endDateReview = getParameter('endDate');

        // Run the update. Note this may not actually update anything. Depends on the options selected by the user
        UpdatedReviewFigures updatedReviewData = PerformanceReviewHelpers.getUpdateReviewFigures(
            getParameter('ckws'),
            MetricHelpers.convertStringToDate(getParameter('startDate')),
            MetricHelpers.convertStringToDate(getParameter('endDate')),
            Boolean.valueOf(getParameter('updateReview'))
        );
        updatedReviewData.addType('Updated Figures');

        // Pull out the figures so they can be display
        UpdatedReviewFigures oldReview = new UpdatedReviewFigures(updatedReviewData.id, null);
        oldReview.addType('Existing Figures');
        if (updatedReviewData.currentReview != null) {
            oldReview.newFarmersRegistered = updatedReviewData.currentReview.Farmers_Registered__c.intValue();
            oldReview.newInvalidSearches = updatedReviewData.currentReview.Number_Of_Invalid_Searches_Running_Total__c.intValue();
            oldReview.newTestSearches = updatedReviewData.currentReview.Number_Of_Test_Searches_Running_Total__c.intValue();
            oldReview.newValidSearches = updatedReviewData.currentReview.Number_Of_Searches_Running_Total__c.intValue();
        }

        this.updatedReview.add(oldReview);
        this.updatedReview.add(updatedReviewData);
        if (Boolean.valueOf(getParameter('updateReview'))) {
            this.hasUpdated = false;
            if (this.showPerformance) {
                getPerformanceDetails();
            }
        }
    }

    /**
     *  Clear the variable map
     */
    private void clearVariableMap() {

        if (this.variableMap == null) {
            this.variableMap = new Map<String, String>();
        }
        else {
            this.variableMap.clear();
        }
    }

    /**
     *  Add a parameter to the parameter map
     */
    private void addParameter(String key, String value) {

        if (this.variableMap == null) {
            this.variableMap = new Map<String, String>();
        }
        this.variableMap.put(key, value);
    }

    /**
     *  Get a param from the variable map.
     *
     *  @param key - The key for the map
     *
     *  @return - The value or blank string if the param does not exist in the map
     */
    private String getParameter(String key) {

        if (this.variableMap == null || !this.variableMap.containsKey(key)) {
            return '';
        }
        return this.variableMap.get(key);
    }

    /**
     *  Get the parameters that might be needed for getting the CKW List
     */
    private Map<String, String> getCkwParameters() {

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('district', this.district);
        parameters.put('group', this.groups);
        parameters.put('allowInactive', 'true');
        return parameters;
    }

    static testMethod void testGettersAndSetters() {

        // Create a district
        District__c district = Utils.createTestDistrict('HELLO');
        Database.insert(district);

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, district.Id, null);
        Database.insert(ckw);

        // Create a group
        Group__c testGroup = new Group__c();
        testGroup.Name = 'TestGroupMan';
        Database.insert(testGroup);

        // Put CKW in the group
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Person__c = ckw.Person__c;
        pga.Group__c = testGroup.Id;
        Database.insert(pga);

        Date dateNow = Date.today();
        Time timeNow = Time.newInstance(9, 0, 0, 0);

        PageReference pageRef = Page.CkwManagement;
        pageRef.getParameters().put('districtParam', district.Id);
        pageRef.getParameters().put('groupListParam', testGroup.Id);
        pageRef.getParameters().put('ckwParam', ckw.Person__c);
        pageRef.getParameters().put('imeiParam', '');
        pageRef.getParameters().put('startDateParam', MetricHelpers.convertDateToNonSoqlString(DateTime.newInstance(dateNow, timeNow)));
        pageRef.getParameters().put('endDateParam', MetricHelpers.convertDateToNonSoqlString(DateTime.newInstance(dateNow.addDays(7), timeNow)));
        pageRef.getParameters().put('updateReviewParam', 'false');
        pageRef.getParameters().put('ckwDetailsParam', 'true');
        pageRef.getParameters().put('bioDetailsParam', 'true');
        pageRef.getParameters().put('groupsParam', 'true');
        pageRef.getParameters().put('surveysParam', 'true');
        pageRef.getParameters().put('performanceParam', 'true');
        pageRef.getParameters().put('checkPerformanceParam', 'true');
        Test.setCurrentPage(pageRef);
        CkwManagementContoller controller = new CkwManagementContoller();
        controller.district = district.Id;

        controller.setDistrictList(controller.getDistrictList());
        controller.setCkwList(controller.getCkwList());
        controller.setGroupList(controller.getGroupList());
        controller.setImei(controller.getImei());
    }

    static testMethod void testSubmission() {

        // Create a district
        District__c district = Utils.createTestDistrict('HELLO');
        Database.insert(district);

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, district.Id, null);
        Database.insert(ckw);

        // Create a group
        Group__c testGroup = new Group__c();
        testGroup.Name = 'TestGroupMan';
        Database.insert(testGroup);

        // Put CKW in the group
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Person__c = ckw.Person__c;
        pga.Group__c = testGroup.Id;
        Database.insert(pga);

        Date dateNow = Date.today();
        Time timeNow = Time.newInstance(9, 0, 0, 0);

        PageReference pageRef = Page.CkwManagement;
        pageRef.getParameters().put('districtParam', district.Id);
        pageRef.getParameters().put('groupListParam', testGroup.Id);
        pageRef.getParameters().put('ckwParam', ckw.Person__c);
        pageRef.getParameters().put('imeiParam', '');
        pageRef.getParameters().put('startDateParam', MetricHelpers.convertDateToNonSoqlString(DateTime.newInstance(dateNow, timeNow)));
        pageRef.getParameters().put('endDateParam', MetricHelpers.convertDateToNonSoqlString(DateTime.newInstance(dateNow.addDays(7), timeNow)));
        pageRef.getParameters().put('updateReviewParam', 'false');
        pageRef.getParameters().put('ckwDetailsParam', 'true');
        pageRef.getParameters().put('bioDetailsParam', 'true');
        pageRef.getParameters().put('groupsParam', 'true');
        pageRef.getParameters().put('surveysParam', 'true');
        pageRef.getParameters().put('performanceParam', 'true');
        pageRef.getParameters().put('checkPerformanceParam', 'true');
        Test.setCurrentPage(pageRef);
        CkwManagementContoller controller = new CkwManagementContoller();
        controller.submitRequest();
        pageRef.getParameters().put('startDateParam', '');
        pageRef.getParameters().put('endDateParam', '');
        controller.getCheckedPerformance();
        
    }
}