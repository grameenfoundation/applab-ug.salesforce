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
    private String orgName = 'CKW';
    private String country = 'Uganda';
    private List<MetricDataWrapper> metricsData = new List<MetricDataWrapper>();
    private List<List<IGDashboardHelpers.Data>> barChartData;

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
            this.district.Name = pageRef.getParameters().get('district');
        }
        if(pageRef.getParameters().get('subcounty') != null){
            this.subcounty.Display_Name__c = pageRef.getParameters().get('subcounty');
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
    }

    /*
    * Fetches all IG/NUSAF subregions in uganda and avails them for 
    * the dropdown list on the dashboard as list-options
    */
    public List<SelectOption> getSubregionsList(){
        List<SelectOption> options = new List<SelectOption>();
        String[] subregions = ProcessNUSAFSurveys.northernUgandaSubregions.values();
        options.add(new SelectOption('','-- In All Sub-Regions --'));
        for (String a_region : subregions) {
           options.add(new SelectOption(a_region, a_region));
        } 
        return options;
    }
    public void setSubregionsList(List<SelectOption> option) {
        this.subregionsList = option;
    }
    
    /*
    * Fetch all districs and avail them to the dropdown list
    * on the dashboard as list-options
    */
    public List<SelectOption> getDistrictList() {
        List<SelectOption> options = new List<SelectOption>();
        District__c[] districts = database.query(SoqlHelpers.getDistricts(''));
        options.add(new SelectOption('','-- In All Districts --'));
        for (District__c district : districts) {
               options.add(new SelectOption(district.Name, district.Name));
        } 
        return options;
    }
    public void setDistrictList(List<SelectOption> option) {
        this.districtList = option;
    }

    /*
    * Fetch all districs and avail them to the dropdown list
    * on the dashboard as list-options
    */
    public List<SelectOption> getSubcountiesList() {
        List<SelectOption> options = new List<SelectOption>();
        Subcounty__c[] subcounties = database.query(IGDashboardHelpers.getSubcounties(orgName));
        options.add(new SelectOption('','-- In All Subcounties --'));
        for (Subcounty__c subcounty : subcounties) {
           options.add(new SelectOption(subcounty.Display_Name__c, subcounty.Display_Name__c));
        } 
        return options;
    }
    public void setSubcountiesList(List<SelectOption> option) {
        this.districtList = option;
    }

    /*
    * Fetches all Person__c objects of type IG/NUSAF - these are the Field Staff 
    * and avails then to the dropdown list on the dashboard as list-options
    */
    public List<SelectOption> getCommunityBasedTrainers(){
        List<SelectOption> options = new List<SelectOption>();
        Person__c[] trainers = database.query(IGDashboardHelpers.getCommunityBasedTrainers());
        options.add(new SelectOption('','-- In All Community Based Trainers --'));
        for (Person__c trainer : trainers) {
           options.add(new SelectOption(string.valueOf(trainer.Id), trainer.First_Name__c + ' ' + trainer.Last_Name__c));
        } 
        return options;
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

    /*
    * aggregates metrics into MetricDataWrapper\'s for display  
    * any other new metrics will be added herein upon computation
    */
    public List<MetricDataWrapper> getMetricsData(){		
        List<MetricDataWrapper> metrics = new List<MetricDataWrapper>();
        metrics.add(IGDashboardHelpers.getTotalNumberOfFieldVisitsMetric(subregion, district.Name, subcounty.Display_Name__c, dateFrom, dateTo, cbt.Id));
        return metrics;
    }

    /*
    * An event for the change filters button on the dashboard
    * initialises the process of filtering displayed data
    */
    public PageReference changeFilters(){ 
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('subregion', subregion);
        resultPage.getParameters().put('subcounty', subcounty.Display_Name__c);
        resultPage.getParameters().put('district', district.Name);
        resultPage.getParameters().put('cbt', cbt.Id);
        resultPage.getParameters().put('dateFrom', dummyObject.Start_Date__c == null? '': 
            Datetime.newInstance(dummyObject.Start_Date__c.year(), dummyObject.Start_Date__c.month(), dummyObject.Start_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('dateTo', dummyObject.End_Date__c == null? '': 
            Datetime.newInstance(dummyObject.End_Date__c.year(), dummyObject.End_Date__c.month(), dummyObject.End_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;		
    }

    public List<List<IGDashboardHelpers.Data>> getBarChartData(){
        barChartData = new List<List<IGDashboardHelpers.Data>>();
        Survey__c[] surveys = database.query(IGDashboardHelpers.getActivities());
        for(Survey__c activity : surveys){
            List<IGDashboardHelpers.Data> barGraphData = IGDashboardHelpers.getBarGraphFieldVisitsMetrics(activity, subregion, district.Name, subcounty.Display_Name__c, dateFrom, dateTo, cbt.Id);
            if(!barGraphData.isEmpty()){
                barChartData.add(barGraphData);
            }
        }
        return barChartData;
    }
}