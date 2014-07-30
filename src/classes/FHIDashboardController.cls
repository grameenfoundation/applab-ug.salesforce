/**
 * Controller for the non-generic UI of FHI dashboard
 */

public with sharing class FHIDashboardController {

    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;    
    private List<SelectOption> subregionsList;
    private static String dashboardSection = 'DS0000000812';
    private List<IGDashboardHelpers.Data> regionsData;
    private Boolean isEditMode = false;
    private List<Metric_Section__c> metricSections;
    private List<M_E_Metric__c> metrics;

    public String subregion { get; set; }
    public District__c district { get; set; }
    public Subcounty__c subcounty { get; set; }
    public Date_Picker__c dummyObject { get; set; }
    public Person__c cbt { get; set; }
    public String dateFrom { get; set; }
    public String dateTo { get; set; }
    public String tabName { get; set; }

    public FHIDashboardController(){
        setUp(ApexPages.currentPage());
    }

    //TODO: make this class's parent page a component
    public virtual void setDashboardSection(String sectionId){
        dashboardSection = sectionId;
    }

    /**
     * returna all metric sections in this dashboard section
     * @return List of Metric sections
     */
    public List<Metric_Section__c> getMetricSections(){
        if(metricSections == null) {
            metricSections = [SELECT Id, Name, Default_Show__c, Title__c, Allow_Update__c FROM Metric_Section__c WHERE Is_Active__c = true AND Dashboard_Section__r.Name = :dashboardSection ORDER BY Default_Show__c];
        }
        return metricSections;
    }

    /**
     * returns metrics of a given metric section
     * @param  sectionId    the Id of the metric section
     */
    public List<M_E_Metric__c> getMetrics(Id section){
        if(metrics == null) {
            metrics = [SELECT Id, Name, Order__c, Label__c, Is_Header__c, On_The_Fly_Calculation_Type__c FROM M_E_Metric__c WHERE Not_For_Public__c = false AND Metric_Section__c = :section];
        }
        return metrics;
    }
    
    public void setUp(PageReference pageRef){
        dummyObject = new Date_Picker__c();
        district = new District__c();
        subcounty = new Subcounty__c();
        subregion = '';
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
            dummyObject.Start_Date__c = String.isNotEmpty(dateFrom) ? Date.valueOf(dateFrom) : null;
        }
        if(pageRef.getParameters().get('dateTo') != null){
            this.dateTo = pageRef.getParameters().get('dateTo');
            dummyObject.End_Date__c = String.isNotEmpty(dateTo) ? Date.valueOf(dateTo) : null;
        }
        if(pageRef.getParameters().get('editMode') != null){
            this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');
        }
    }

   /*
    * returns all district regions. gets them from the region__c piclist field on
    * the district__c sObject 
    */
    public List<SelectOption> getSubregionsList(){
        if(subregionsList == null) {
            List<FHI_District_Region__c> districtRegions = [SELECT Id, Name, FHI_Region__c FROM FHI_District_Region__c];
            Map<String, String> uniqueRegions = new Map<String, String>();
            for(FHI_District_Region__c region : districtRegions){
                uniqueRegions.put(region.FHI_Region__c, region.FHI_Region__c);	
            }
            subregionsList = new List<SelectOption>();
            subregionsList.add(new SelectOption('','-- In All Regions --'));
            for (String entry : uniqueRegions.keySet()) {
                subregionsList.add(new SelectOption(entry, entry));
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
            District__c[] districts = null;
            List<String> districtNames = null;
            if(String.isNotEmpty(this.subregion)){
                districtNames = FHISurveysHelpers.getDistrictsInRegion(this.subregion);
            }
            else{
                districtNames = FHISurveysHelpers.getDistrictsInRegion(null);
            }
            districts = [SELECT Id, Name FROM District__c WHERE Name IN  :districtNames ORDER BY Name];
            districtList.add(new SelectOption('','-- In All Districts --'));
            for (District__c district : districts) {
                districtList.add(new SelectOption(district.Id, district.Name));
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
            Subcounty__c[] subcounties = null;
            if(this.district != null && this.district.Id != null){
                subcounties = [SELECT Id, Name, Display_Name__c, District__c FROM Subcounty__c WHERE District__c = :this.district.Id ORDER BY Display_Name__c];
            }
            else{
                subcounties = [SELECT Id, Name, Display_Name__c FROM Subcounty__c ORDER BY Display_Name__c];
            }   
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

    /**
     * event fired when region changes on the dashboard
     */
    public PageReference onRegionChanged(){
        //filter districts
        districtList = new List<SelectOption>();
        District__c[] districts = null;
        List<String> districtNames = FHISurveysHelpers.getDistrictsInRegion(this.subregion);
        districts = [SELECT Id, Name FROM District__c WHERE Name IN  :districtNames ORDER BY Name];
        districtList.add(new SelectOption('','-- In All Districts --'));
        for (District__c district : districts) {
            districtList.add(new SelectOption(district.Id, district.Name));
        } 
        return null;
    }

    /**
     * event fired when district changes on the dashboard
     */
    public PageReference onDistrictChanged(){
        //filter subcounties
        subcountiesList = new List<SelectOption>();
        Subcounty__c[] subcounties = null;
        subcounties = [SELECT Id, Name, Display_Name__c FROM Subcounty__c WHERE District__c = :this.district.Id ORDER BY Display_Name__c];
        subcountiesList.add(new SelectOption('','-- In All Subcounties --'));
        for (Subcounty__c subcounty : subcounties) {
           subcountiesList.add(new SelectOption(subcounty.Id, subcounty.Display_Name__c));
        } 
        return null;
    }

    /**
     * tells us if metrics are currently being updated manually
     * @return <code>true</code> if in edit mode, <code>false</code> otherwise
     */
    public String getIsEditMode() {
        if(this.isEditMode) {
            return 'true';
        }
        return 'false';
    }  

    /*
    * An event for the change filters button on the dashboard
    * initialises the process of filtering displayed data
    */
    public PageReference changeFilters(){ 
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('subregion', subregion);
        resultPage.getParameters().put('district', district.Id);
        resultPage.getParameters().put('subcounty', subcounty.Id);
        resultPage.getParameters().put('dateFrom', dummyObject.Start_Date__c == null? '': 
            Datetime.newInstance(dummyObject.Start_Date__c.year(), dummyObject.Start_Date__c.month(), dummyObject.Start_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('dateTo', dummyObject.End_Date__c == null? '': 
            Datetime.newInstance(dummyObject.End_Date__c.year(), dummyObject.End_Date__c.month(), dummyObject.End_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;      
    }
}
