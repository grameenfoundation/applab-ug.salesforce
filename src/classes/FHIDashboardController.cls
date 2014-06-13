/**
 * Controller for the non-generic UI of FHI dashboard
 */

public with sharing class FHIDashboardController {

    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;    
    private List<SelectOption> subregionsList;
    private static String dashboardSection = 'DS0000000051';
    private List<IGDashboardHelpers.Data> regionsData;
    private Boolean isEditMode = false;

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
        return [SELECT Id, Name, Default_Show__c, Title__c, Allow_Update__c FROM Metric_Section__c WHERE Dashboard_Section__r.Name = :dashboardSection ORDER BY Default_Show__c];
    }

    /**
     * returns metrics of a given metric section
     * @param  sectionId    the Id of the metric section
     */
    public List<M_E_Metric__c> getMetrics(Id section){
        return [SELECT Id, Name, Order__c, Label__c, Is_Header__c, On_The_Fly_Calculation_Type__c FROM M_E_Metric__c WHERE Metric_Section__c = :section];
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
    * Fetches all IG/NUSAF subregions in uganda and avails them for 
    * the dropdown list on the dashboard as list-options
    */
    public List<SelectOption> getSubregionsList(){
        List<SelectOption> options = new List<SelectOption>();
        Region__c[] subregions = [SELECT Id, Name, Display_Name__c FROM Region__c ORDER BY Display_Name__c];
        options.add(new SelectOption('','-- In All Regions --'));
        for (Region__c a_region : subregions) {
           options.add(new SelectOption(a_region.Display_Name__c, a_region.Display_Name__c));
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
        District__c[] districts = null;
        if(String.isNotEmpty(this.subregion)){
            districts = [SELECT Id, Region__c, Name FROM District__c WHERE Region__c = :this.subregion ORDER BY Name];
        }
        else {
            districts = [SELECT Id, Region__c, Name FROM District__c ORDER BY Name];   
        }
        options.add(new SelectOption('','-- In All Districts --'));
        for (District__c district : districts) {
               options.add(new SelectOption(district.Id, district.Name));
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
        Subcounty__c[] subcounties = null;
        if(this.district.Id != null){
            subcounties = [SELECT Id, Name, Display_Name__c FROM Subcounty__c WHERE District__c = :this.district.Id ORDER BY Display_Name__c];
        }
        else {
            subcounties = [SELECT Id, Name, Display_Name__c FROM Subcounty__c ORDER BY Display_Name__c];   
        }
        options.add(new SelectOption('','-- In All Subcounties --'));
        for (Subcounty__c subcounty : subcounties) {
           options.add(new SelectOption(subcounty.Id, subcounty.Display_Name__c));
        } 
        return options;
    }
    public void setSubcountiesList(List<SelectOption> option) {
        this.districtList = option;
    }

    /**
     * event fired when region changes on the dashboard
     */
    public PageReference onRegionChanged(){
        PageReference resultPage = ApexPages.currentPage(); 
        String subcountyId = resultPage.getParameters().get('subregion');
        return null;
    }

    /**
     * event fired when district changes on the dashboard
     */
    public PageReference onDistrictChanged(){
        PageReference resultPage = ApexPages.currentPage(); 
        String districtId = resultPage.getParameters().get('district');
        return null;
    }

    /**
     * event fired when subcounty changes on the dashboard
     */
    public PageReference onSubcountyChanged(){
        PageReference resultPage = ApexPages.currentPage(); 
        String districtId = resultPage.getParameters().get('subcounty');
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