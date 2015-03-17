/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This is the controller class for IG/NUSAF Dashboard page
 *  Its test methods are in the IGDashboardTests class 
 **/
public class IGDashboardController {

    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;    
    private List<SelectOption> subregionsList;
    private List<SelectOption> communityBasedTrainers;
    private String isUpdateable = 'false';
    private String orgName = 'IG NUSAF';
    private String country = 'Uganda';
    private List<IGDashboardHelpers.Data> regionsData;
    private List<IGDashboardHelpers.Data> cTData;
    private Boolean isRegionalManager = false;
    private Boolean isOversight = false;

    public IGDashboardController(){
        setUp(ApexPages.currentPage());
    }

    public String subregion { get; set; }
    public District__c district { get; set; }
    public Subcounty__c subcounty { get; set; }
    public Date_Picker__c dummyObject { get; set; }
    public Person__c cbt { get; set; }
    public String dateFrom { get; set; }
    public String dateTo { get; set; }
    public String tabName { get; set; }
    
    public void setUp(PageReference pageRef){
        dummyObject = new Date_Picker__c();
        district = new District__c();
        subcounty = new Subcounty__c();
        subregion = '';
        cbt = new Person__c();
        // Try to keep the tab we're on
        String tabName = pageRef.getParameters().get('sfdc.tabName');
        if(tabName != null) {
            this.tabName = tabName;
        }
        if(pageRef.getParameters().get('subregion') != null){
            this.subregion = pageRef.getParameters().get('subregion');
        }
        if(pageRef.getParameters().get('district') != null){
            this.district.Id = pageRef.getParameters().get('district');
        }
        if(pageRef.getParameters().get('subcounty') != null){
            this.subcounty.Id = pageRef.getParameters().get('subcounty');
        }
        if(pageRef.getParameters().get('dateFrom') != null){
            this.dateFrom = pageRef.getParameters().get('dateFrom');
        }
        if(pageRef.getParameters().get('dateTo') != null){
            this.dateTo = pageRef.getParameters().get('dateTo');
        }
        if(pageRef.getParameters().get('cbt') != null){
            this.cbt.Id = Id.valueOf(pageRef.getParameters().get('cbt'));
        }

        //we check the profile so as to filter what is shown on the dashboard
        Profile profile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        if(profile.name.toLowerCase().contains('regional manager')){
            isRegionalManager = true;
            isOversight = false;          
        }
        else{
            //other profiles default to oversight
            isRegionalManager = false;
            isOversight = true;            
        }
    }

    //getters for acquiring category of current user
    public Boolean getIsRegionalManager(){
        return this.isRegionalManager;
    }
    public void setIsRegionalManager(Boolean val){
        this.isRegionalManager = val;
    }
    public Boolean getIsOversight(){
        return this.isOversight;
    }

    /*
    * Fetches all IG/NUSAF subregions in uganda and avails them for 
    * the dropdown list on the dashboard as list-options
    */
    public List<SelectOption> getSubregionsList(){
        if(subregionsList == null) {
            subregionsList = new List<SelectOption>();
            IG_Region__c[] subregions = database.query(IGDashboardHelpers.getIGRegions());
            subregions.sort();
            subregionsList.add(new SelectOption('','-- In All Sub-Regions --'));
            for (IG_Region__c a_region : subregions) {
               subregionsList.add(new SelectOption(a_region.Id, a_region.Name));
            } 
        }
        return subregionsList;
    }
    public void setSubregionsList(List<SelectOption> option) {
        this.subregionsList = option;
    }
    
    /*
    * Fetch all districs and avail them to the dropdown list
    * on the dashboard as list-options
    */
    public List<SelectOption> getDistrictList() {
        if(districtList == null) {
            districtList = new List<SelectOption>();
            IG_Region_District_Association__c[] districts = database.query(IGDashboardHelpers.getDistricts(''));
            districtList.add(new SelectOption('','-- In All Districts --'));
            for (IG_Region_District_Association__c district : districts) {
                   districtList.add(new SelectOption(district.District__r.Id, district.District__r.Name));
            } 
        }
        return districtList;
    }
    public void setDistrictList(List<SelectOption> option) {
        this.districtList = option;
    }

    /*
    * Fetch all districs and avail them to the dropdown list
    * on the dashboard as list-options
    */
    public List<SelectOption> getSubcountiesList() {
        if(subcountiesList == null) {
            subcountiesList = new List<SelectOption>();
            Subcounty__c[] subcounties = database.query(IGDashboardHelpers.getSubcounties(''));
            subcountiesList.add(new SelectOption('','-- In All Subcounties --'));
            for (Subcounty__c subcounty : subcounties) {
               subcountiesList.add(new SelectOption(subcounty.Id, subcounty.Display_Name__c));
            } 
        }
        return subcountiesList;
    }
    public void setSubcountiesList(List<SelectOption> option) {
        this.districtList = option;
    }

    /*
    * Fetches all Person__c objects of type IG/NUSAF - these are the Field Staff 
    * and avails them to the dropdown list on the dashboard as list-options
    */
    public List<SelectOption> getCommunityBasedTrainers(){
        if(communityBasedTrainers == null) {
            communityBasedTrainers = new List<SelectOption>();
            IG_Subproject_Target__c[] targets = database.query(IGDashboardHelpers.getCommunityBasedTrainers('', ''));
            Map<String, IG_Subproject_Target__c> mapTargets = new Map<String, IG_Subproject_Target__c>();
            for(IG_Subproject_Target__c target: targets){
                mapTargets.put(target.Person__r.Id, target);//This is map and hence it will always have unique values 
            }
            targets = mapTargets.values();
            communityBasedTrainers.add(new SelectOption('','-- In All Community Based Trainers --'));
            for (IG_Subproject_Target__c target : targets) {
               communityBasedTrainers.add(new SelectOption(string.valueOf(target.Person__r.Id), target.Person__r.First_Name__c + ' ' + target.Person__r.Last_Name__c));
            } 
        }
        return communityBasedTrainers;
    }
    public void setCommunityBasedTrainers(List<SelectOption> option) {
        this.communityBasedTrainers = option;
    }
    
    public String getSubregion(){
        return this.subregion;
    }

    public void setCountry(String country){
        this.country = country;
    }

    public void setOrgName(String org){
        this.orgName = org;
    }

    /**
     * event fired when region changes on the dashboard
     * filters districts to displya only those in the selected region
     */
    public PageReference onRegionChanged(){
        districtList = new List<SelectOption>();
        IG_Region_District_Association__c[] districts = database.query(IGDashboardHelpers.getDistricts(this.subregion));
        districtList.add(new SelectOption('','-- In All Districts --'));
        for (IG_Region_District_Association__c district : districts) {
               districtList.add(new SelectOption(district.District__r.Id, district.District__r.Name));
        } 
        return null;
    }

    /**
     * event fired when district changes on the dashboard
     * filters subounties to display only those in the selected district
     */
    public PageReference onDistrictChanged(){
        subcountiesList = new List<SelectOption>();
        Subcounty__c[] subcounties = database.query(IGDashboardHelpers.getSubcounties(this.district.Id));
        subcountiesList.add(new SelectOption('','-- In All Subcounties --'));
        for (Subcounty__c subcounty : subcounties) {
           subcountiesList.add(new SelectOption(subcounty.Id, subcounty.Display_Name__c));
        } 
        return null;
    }

    /**
     * event fired when subcounty changes on the dashboard
     * filters subprojects assigned to the selected subcounty and 
     * lists unique names of CTs they are assigned to
     */
    public PageReference onSubcountyChanged(){
        communityBasedTrainers = new List<SelectOption>();
        IG_Subproject_Target__c[] targets = database.query(IGDashboardHelpers.getCommunityBasedTrainers(this.district.Id, this.subcounty.Id));
        Map<String, IG_Subproject_Target__c> mapTargets = new Map<String, IG_Subproject_Target__c>();
        for(IG_Subproject_Target__c target: targets){
            mapTargets.put(target.Person__r.Id, target);//This is map and hence it will always have unique values 
        }
        targets = mapTargets.values();
        communityBasedTrainers.add(new SelectOption('','-- In All Community Based Trainers --'));
        for (IG_Subproject_Target__c target : targets) {
           communityBasedTrainers.add(new SelectOption(string.valueOf(target.Person__r.Id), target.Person__r.First_Name__c + ' ' + target.Person__r.Last_Name__c));
        } 
        return null;
    }

    /*
    * An event for the change filters button on the dashboard
    * initialises the process of filtering displayed data
    */
    public PageReference changeFilters(){ 
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('subregion', subregion);
        resultPage.getParameters().put('subcounty', subcounty.Id);
        resultPage.getParameters().put('district', district.Id);
        resultPage.getParameters().put('cbt', cbt.Id);
        resultPage.getParameters().put('dateFrom', dummyObject.Start_Date__c == null? '': 
            Datetime.newInstance(dummyObject.Start_Date__c.year(), dummyObject.Start_Date__c.month(), dummyObject.Start_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('dateTo', dummyObject.End_Date__c == null? '': 
            Datetime.newInstance(dummyObject.End_Date__c.year(), dummyObject.End_Date__c.month(), dummyObject.End_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;		
    }

    /*
    * Returns aggregated metrics by region  
    * @return List of IGDashboardHelpers.Data each of which is for a Region
    */
    public List<IGDashboardHelpers.Data> getRegionalMetricsData(){        
        regionsData = new List<IGDashboardHelpers.Data>();
        regionsData = IGDashboardHelpers.getMetricsForRegion(subregion, district.Id, subcounty.Id, dateFrom, dateTo, cbt.Id);
        return regionsData;
    }

    /**
     * Returns metric datas for Community Trainers in a given IG region
     * This is only possible for users of profile IG Regional Manager which resolves to a fair number of records
     * @return List of IGDashboardHelpers.Data each of which is for a CT
     */
    public List<IGDashboardHelpers.Data> getCTMetricsData(){
        cTData = new List<IGDashboardHelpers.Data>();
        if(isRegionalManager){
            IG_Region__c regionthis = IGDashboardHelpers.getUserRegion();
            cTData = IGDashboardHelpers.getIndividualMetrics(isRegionalManager, regionthis == null ? null : regionthis.Id, district.Id, subcounty.Id, dateFrom, dateTo, cbt.Id);
        }
        else {
            cTData = IGDashboardHelpers.getIndividualMetrics(isRegionalManager, subregion, district.Id, subcounty.Id, dateFrom, dateTo, cbt.Id);
        }
        return cTData;
    }
}