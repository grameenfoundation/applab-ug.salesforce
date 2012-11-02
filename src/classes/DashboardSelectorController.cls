public class DashboardSelectorController {

    // Select list options
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
    public void setDistrictList(List<SelectOption> option) {
        this.districtList = option;
    }

    public String organisations { get; set; }
    public List<SelectOption> organisationList;
    public List<SelectOption> getOrganisationList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- In All Organisation --'));
        Account[] orgs = database.query(SoqlHelpers.getOrganisations());
        for (Account org : orgs) {
            options.add(new SelectOption(org.Id, org.Name));
        }
        return options;
    }
    public void setOrganisationList(List<SelectOption> options) {
        this.organisationList = options;
    }

    public String projects { get; set; }
    public List<SelectOption> projectList;
    public List<SelectOption> getProjectList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- For All Projects --'));
        Project__c[] projs = database.query(SoqlHelpers.getProjects(organisations));
        for (Project__c proj : projs) {
            options.add(new SelectOption(proj.Id, proj.Name));
        }
        return options;
    }
    public void setProjectList(List<SelectOption> options) {
        this.projectList = options;
    }

    public List<String> selectedCkws;
    public List<String> getSelectedCkws() {
        return this.selectedCkws;
    }
    public void setSelectedCkws(List<String> newValue) {

        if (newValue != null) {
            this.selectedCkws = newValue;
            setShowFarmers(generatePersonParams('ckws', MetricHelpers.generateCommaSeperatedString(newValue, false)));
        }
    }

    public List<SelectOption> ckwList;
    public List<SelectOption> getCkwList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','All CKWs'));
        options.add(new SelectOption('male', 'All Male CKWs'));
        options.add(new SelectOption('woman', 'All Female CKWs'));
        options.add(new SelectOption('non', 'All Poor CKWs'));
        options.add(new SelectOption('poor', 'All Very Poor CKWs'));
        buildLists();
        CKW__c[] ckws = database.query(SoqlHelpers.getCkws(variableMap, true));
        for (CKW__c ckw : ckws) {
            if (UserInfo.getUserType() != 'GUEST') {
                options.add(new SelectOption(ckw.Person__r.Id, ckw.Name + ' ' + ckw.Person__r.Last_Name__c + ' ' + ckw.Person__r.First_Name__c));
            }
            else {
                options.add(new SelectOption(ckw.Person__r.Id, ckw.Name));
            }
        }
        return options;
    }
    public void setCkwList(List<SelectOption> options) {
        this.ckwList = options;
    }

    public String[] farmers { get; set; }
    public List<SelectOption> farmerList;
    public List<SelectOption> getFarmerList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','All Farmers'));
        options.add(new SelectOption('male', 'All Male Farmers'));
        options.add(new SelectOption('woman', 'All Female Farmers'));
        options.add(new SelectOption('non', 'All Poor Farmers'));
        options.add(new SelectOption('poor', 'All Very Poor Farmers'));
        buildLists();
        if (this.showFarmers) {
            String query = SoqlHelpers.getFarmers(variableMap, true);
            if (!query.equals('')) {
                Farmer__c[] farmers = database.query(query);
                for (Farmer__c farmer : farmers) {
                    if (UserInfo.getUserType() != 'GUEST') {
                        options.add(new SelectOption(farmer.Person__r.Id, farmer.Name + ' ' + farmer.Person__r.Last_Name__c + ' ' + farmer.Person__r.First_Name__c));
                    }
                    else {
                        options.add(new SelectOption(farmer.Person__r.Id, farmer.Name));
                    }
                }
            }
        }
        return options;
    }
    public void setFarmerList(List<SelectOption> options) {
        this.farmerList = options;
    }

    public FormDetails[] formDetails;
    public FormDetails[] getFormDetails() {

        List<FormDetails> formDetails = new List<FormDetails>();
        FormDetails all = new FormDetails('ALL', 'detailType,district,organisations,projects,ckws,farmers,farmerDateStart,farmerDateEnd,searchDateStart,searchDateEnd,incSearchSubLoc,incFarmers,incSearches,ckwDateStart,ckwDateStart,ckwDateEnd,keyword,tagCloud,hideMap,hideTagCloud,hideGraph');
        formDetails.add(all);
        FormDetails ckw = new FormDetails('CKW', 'detailType,district,organisations,projects,ckws,incFarmers,incSearches,incSearchSubLoc,ckwDateStart,ckwDateEnd,keyword,searchDateStart,searchDateEnd,hideMap,hideTagCloud,hideGraph');
        formDetails.add(ckw);
        FormDetails farmers = new FormDetails('FARMER', 'detailType,district,organisations,projects,ckws,farmers,farmerDateStart,farmerDateEnd,incSearches,incSearchSubLoc,hideMap,hideTagCloud,hideGraph');
        formDetails.add(farmers);
        FormDetails searches = new FormDetails('SEARCHES', 'detailType,district,organisations,projects,ckws,farmers,incSearchSubLoc,searchDateStart,searchDateEnd,keyword,tagCloud,hideMap,hideTagCloud,hideGraph');
        formDetails.add(searches);
        FormDetails surveys = new FormDetails('SURVEYS', 'detailType,district,organisations,projects,ckws,farmers,surveys,surveyDateStart,surveyDateEnd,hideMap,hideTagCloud,hideGraph');
        formDetails.add(surveys);
        return formDetails;
    }
    public void setFormDetails(List<FormDetails> options) {
        this.formDetails = options;
    }

    public String[] keyword { get; set; }
    public List<SelectOption> keywords;
    public List<SelectOption> getKeywords() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AllCat', 'All Top Level Categories'));
        options.add(new SelectOption('AllCrops', 'All Crops'));
        options.add(new SelectOption('AllLivestock', 'All Livestock'));
        Tag_Cloud_Word__c[] words = database.query(SoqlHelpers.getKeywords(variableMap, 0));
        for (Tag_Cloud_Word__c word : words) {
            options.add(new SelectOption(word.Name, word.Name));
        }
        return options;
    }
    public void setKeywords(List<SelectOption> options) {
        this.keywords = options;
    }

    public String survey { get; set; }
    public List<SelectOption> surveyList;
    public List<SelectOption> getSurveyList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'All Surveys'));
        if (this.salesforceSurveysOnly) {
            addVariable('SalesForceOnly', 'true');
        }
        for (Survey__c survey : database.query(SoqlHelpers.getSurveys(variableMap))) {
            options.add(new SelectOption(survey.Name, survey.Name + ' ' + survey.Survey_Name__c));
        }
        return options;
    }
    public void setSurveyList(List<SelectOption> options) {
        this.keywords = options;
    }

    public String detailType { get; set; }
    public String incFarmers { get; set; }
    public String incSearches { get; set; }
    public String incSeachSubLoc { get; set; }
    public String incSurveys { get; set; }
    public Date_Picker__c ckwDatePicker { get; set; }
    public Date_Picker__c farmerDatePicker { get; set; }
    public Date_Picker__c searchDatePicker { get; set; }
    public Date_Picker__c surveyDatePicker { get; set; }
    public Boolean showSurveys { get; set; }
    public Boolean showSearches { get; set; }


    // Map the variables passed in from the url
    private Map<String, String> variableMap = new Map<String, String>();
    private Boolean showDetail;
    private Boolean showFarmers;
    private Boolean showMap;
    private Boolean showTagCloud;
    private Boolean showGraphs;
    private String pageName;
    private String url;
    private Boolean salesforceSurveysOnly;

    // Constructor for this controller
    public DashboardSelectorController() {

        setUp();
    }

    private void setUp() {

        this.organisations = '';
        this.projects = '';
        this.selectedCkws = new List<String>();
        this.farmers = new List<String>();
        this.keyword = new List<String>();
        this.survey = '';
        this.incFarmers = 'false';
        this.incSearches = 'false';
        this.incSeachSubLoc = 'false';
        this.incSurveys = 'false';
        setShowFarmers(false);
        setShowDetail(true);
        setUrl('');
        Date now = Date.today();
        this.ckwDatePicker = new Date_Picker__c();
        this.ckwDatePicker.Start_Date__c = Date.parse('06/01/2010');
        this.ckwDatePicker.End_Date__c = now;
        this.farmerDatePicker = new Date_Picker__c();
        this.farmerDatePicker.End_Date__c = now;

        // Want to default these to the search dates to be the start and end of a full week
        this.searchDatePicker = new Date_Picker__c();
        this.searchDatePicker.Start_Date__c = now.toStartOfWeek().addDays(-14);
        this.searchDatePicker.End_Date__c = now.toStartOfWeek().addDays(-1);
        this.surveyDatePicker = new Date_Picker__c();
        this.surveyDatePicker.Start_Date__c = now.addDays(-14);
        this.surveyDatePicker.End_Date__c = now;

        // Decide based on the url which page this is and show the relevant widgets
        this.showSurveys = false;
        this.showSearches  = false;
        this.salesforceSurveysOnly = false;
        setShowMap(true);
        if (Utils.getPageName(ApexPages.currentPage().getUrl()).equals('SurveyMapSelector')) {
            this.detailType = 'SURVEYS';
            this.salesforceSurveysOnly = true;
            this.showSurveys = true;
            setShowGraphs(false);
            setShowTagCloud(false);
        }
        else {
            this.detailType = 'CKW';
            this.showSearches = true;
            setShowGraphs(true);
            setShowTagCloud(true);
        }
    }

    public Boolean getShowFarmers() {
        return this.showFarmers;
    }

    public void setShowFarmers(Boolean show) {
        this.showFarmers = show;
    }

    public List<SelectOption> getDetailTypes() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CKW', 'Show CKWs'));
        options.add(new SelectOption('FARMER', 'Show Farmers'));
        if (Utils.getPageName(ApexPages.currentPage().getUrl()).equals('SurveyMapSelector')) {
            options.add(new SelectOption('SURVEYS', 'Show Surveys'));
        }
        else {
            options.add(new SelectOption('SEARCHES', 'Show Searches'));
        }
        return options;
    }

    public void setShowDetail(Boolean detail) {
        this.showDetail = detail;
    }

    public Boolean getShowDetail() {
        return this.showDetail;
    }

    public void setShowGraphs(Boolean bool) {
        this.showGraphs = bool;
    }

    public Boolean getShowGraphs() {
        return showGraphs;
    }

    public void setShowMap(Boolean bool) {
        this.showMap = bool;
    }

    public Boolean getShowMap() {
        if (this.detailType.equals('SEARCHES')) {
            return false;
        }
        return this.showMap;
    }

    public void setShowTagCloud(Boolean bool) {
        this.showTagCloud = bool;
    }

    public Boolean getShowTagCloud() {
        return this.showTagCloud;
    }

    public String generateUrl() {

        String url = '';
        Integer count = 1;
        for (String key : variableMap.keySet()) {
            url = url + key + '=' + variableMap.get(key);
            if (count != variableMap.size()) {
                url = url + '&';
            }
        }
        return url;
    }

    public void setUrl(String newUrl) {
        this.url = newUrl;
    }

    public String getUrl() {
        return this.url;
    }

    public PageReference resetFarmerLists() {

        this.district = Apexpages.currentPage().getParameters().get('districtParam');
        this.organisations = Apexpages.currentPage().getParameters().get('organisationParam');
        this.projects = Apexpages.currentPage().getParameters().get('projectParam');
        setSelectedCkws(Apexpages.currentPage().getParameters().get('ckwsParam').split(','));
        return null;
    }

    public PageReference loadPage() {

        this.detailType = Apexpages.currentPage().getParameters().get('detailTypeParam');
        this.district = Apexpages.currentPage().getParameters().get('districtParam');
        this.organisations = Apexpages.currentPage().getParameters().get('organisationParam');
        this.projects = Apexpages.currentPage().getParameters().get('projectParam');
        this.selectedCkws = Apexpages.currentPage().getParameters().get('ckwsParam').split(',');
        this.farmers = Apexpages.currentPage().getParameters().get('farmersParam').split(',');
        this.survey = Apexpages.currentPage().getParameters().get('surveysParam');
        this.incFarmers = Apexpages.currentPage().getParameters().get('incFarmersParam');
        this.incSearches = Apexpages.currentPage().getParameters().get('incSearchesParam');
        this.incSeachSubLoc = Apexpages.currentPage().getParameters().get('incSeachSubLocParam');
        this.incSurveys = Apexpages.currentPage().getParameters().get('incSurveysParam');
        setShowMap(Apexpages.currentPage().getParameters().get('hideMapParam').equals('true'));
        setShowGraphs(Apexpages.currentPage().getParameters().get('hideGraphParam').equals('true'));
        setShowTagCloud(Apexpages.currentPage().getParameters().get('hideTagCloudParam').equals('true'));

        addVariable('startDate', Apexpages.currentPage().getParameters().get('ckwDateStartParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('ckwDateStartParam'));
        addVariable('endDate', Apexpages.currentPage().getParameters().get('ckwDateEndParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('ckwDateEndParam'));
        addVariable('farmerStartDate', Apexpages.currentPage().getParameters().get('farmerDateStartParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('farmerDateStartParam'));
        addVariable('farmerEndDate', Apexpages.currentPage().getParameters().get('farmerDateEndParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('farmerDateEndParam'));
        addVariable('searchStartDate', Apexpages.currentPage().getParameters().get('searchDateStartParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('searchDateStartParam'));
        addVariable('searchEndDate', Apexpages.currentPage().getParameters().get('searchDateEndParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('searchDateEndParam'));
        addVariable('submissionStartDate', Apexpages.currentPage().getParameters().get('surveyDateStartParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('surveyDateStartParam'));
        addVariable('submissionEndDate', Apexpages.currentPage().getParameters().get('surveyDateEndParam').equals('') ? '' : Apexpages.currentPage().getParameters().get('surveyDateEndParam'));
        setShowDetail(true);
        buildLists();
        setUrl(generateUrl());
        return null;
    }

     public void reset() {

        organisations = '';
        projects = '';
        selectedCkws.clear();
     }

    /**
     *  Add a variable to the map
     */
    public void addVariable(String name, String value) {
        variableMap.put(name, value);
    }

    public Map<String, String> getVariableMap() {
        return variableMap;
    }

    /**
     *  Build the lists to pass back to the page
     */
    private void buildLists() {

        if (this.district == null) {
            this.district = '';
        }
        addVariable('district', this.district);
        if (this.detailType == null || this.detailType.equals('')) {
            addVariable('mapObject' , 'CKW');
        }
        else {
            addVariable('mapObject' , this.detailType);
        }
        if (this.organisations == null) {
           this.organisations = '';
        }
        addVariable('org', this.organisations);
        if (this.projects == null) {
           this.projects = '';
        }
        addVariable('project', this.projects);
        addVariable('incFarmers', this.incFarmers);
        addVariable('incSearches', this.incSearches);
        addVariable('incSeachSubLoc', this.incSeachSubLoc);
        addVariable('incSurveys', this.incSurveys);

        // As we use the internal SF id and they dont contain ' we should be able to check if the string contains them to see if we
        // need to add the quotes around the ids
        if (this.selectedCkws == null) {
            this.selectedCkws = new List<String>();
        }
        Boolean useCkwIds = generatePersonParams('ckws', MetricHelpers.generateCommaSeperatedString(this.selectedCkws, MetricHelpers.checkListNeedsQuotes(this.selectedCkws)));
        if (this.farmers == null) {
            this.farmers = new List<String>();
        }
        Boolean useFarmerIds = generatePersonParams('farmers', MetricHelpers.generateCommaSeperatedString(this.farmers, MetricHelpers.checkListNeedsQuotes(this.farmers)));

        // Check if we should allow farmers or searches to show up on the maps
        if (!useCkwIds) {
            addVariable('incFarmers', 'false');
            addVariable('incSearches', 'false');
            addVariable('incSeachSubLoc', 'false');
            addVariable('incSurveys', 'false');
        }
        else if (useCkwIds && this.selectedCkws != null && this.selectedCkws.size() > 0){
            setShowFarmers(true);
        }
        if (farmers.size() > 1 && !useFarmerIds) {
            addVariable('incSearches', 'false');
            addVariable('incSeachSubLoc', 'false');
            addVariable('incSurveys', 'false');
        }
        String words = '';
        Integer i = 1;
        for (String k : keyword) {
            words = words + k;
            if (keyword.size() != i) {
                words = words + ';';
            }
        }
        addVariable('keyword', words);
        addVariable('surveyName', this.survey);
    }

    private Boolean generatePersonParams(String paramType, String param) {

        Boolean useIds = true;
        if ((param.contains('woman') && param.contains('male')) || (param.contains('non') && param.contains('poor'))) {
            useIds = false;
        }
        else if (param.contains('male')) {
            addVariable('gender' + paramType, 'Male');
            useIds = false;
        }
        else if (param.contains('woman')) {
            addVariable('gender' + paramType, 'Female');
            useIds = false;
        }
        else if (param.contains('poor')) {
            addVariable('poverty' + paramType, 'veryPoor');
            useIds = false;
        }
        else if (param.contains('non')) {
            addVariable('poverty' + paramType, 'poor');
            useIds = false;
        }
        if (useIds) {
            addVariable(paramType, param);
        }
        return useIds;
    }

    private static void generateTestVarMap() {

        Map<String, String> variableMap = new Map<String, String>();
        String quarterString = MetricHelpers.getCurrentQuarterAsString(0);
        variableMap.put('quarter' , quarterString);
    }

    static testMethod void testGeneratePersonParams() {

        DashboardSelectorController dashboardSelectorController = new DashboardSelectorController();
        System.assertEquals(false, dashboardSelectorController.generatePersonParams('ckw', 'male,women'));
        System.assertEquals(false, dashboardSelectorController.generatePersonParams('ckw', 'male'));
        System.assertEquals(false, dashboardSelectorController.generatePersonParams('ckw', 'woman'));
        System.assertEquals(false, dashboardSelectorController.generatePersonParams('ckw', 'poor'));
        System.assertEquals(false, dashboardSelectorController.generatePersonParams('ckw', 'non'));
        System.assertEquals(true, dashboardSelectorController.generatePersonParams('ckw', 'Jimmy'));
    }

    static testMethod void testController() {

        PageReference pageRef = Page.DashboardSelector;
        Test.setCurrentPageReference(pageRef);
        DashboardSelectorController dashboardSelectorController = new DashboardSelectorController();
        dashboardSelectorController.setDistrictList(dashboardSelectorController.getDistrictList());
        dashboardSelectorController.setOrganisationList(dashboardSelectorController.getOrganisationList());
        dashboardSelectorController.setProjectList(dashboardSelectorController.getProjectList());
        dashboardSelectorController.setCkwList(dashboardSelectorController.getCkwList());
        dashboardSelectorController.district = 'Gulu';
        Date now = Date.today();
        dashboardSelectorController.searchDatePicker.Start_Date__c = now.addDays(-14);
        dashboardSelectorController.searchDatePicker.End_Date__c = now;
        dashboardSelectorController.setFarmerList(dashboardSelectorController.getFarmerList());
        dashboardSelectorController.setFormDetails(dashboardSelectorController.getFormDetails());
        dashboardSelectorController.setKeywords(dashboardSelectorController.getKeywords());
        dashboardSelectorController.buildLists();
    }
}