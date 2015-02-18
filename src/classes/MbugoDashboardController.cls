public with sharing class MbugoDashboardController {


    public List<District__c> mbugoDistricts;
    public List<Subcounty__c> mbugoSubCounties;
    private Boolean isEditMode = false;
    private String isUpdateable = 'true';
    private String orgName = 'null';
    private Transient Map<String, M_E_Metric_Data__c> allMetricDatas;

    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;
    private Transient Map<String, M_E_Metric__c> allMetrics;

    //Maps list
    private List<Map_Parameter__c> maps;


    public String tabName { get; set; }
    public District__c district { get; set; }
    public Subcounty__c subcounty { get; set; }
    public String dateFrom { get; set; }
    public String dateTo { get; set; }
    public Date_Picker__c dummyObject { get; set; }


    public MbugoDashboardController() {
      dummyObject = new Date_Picker__c();
      district = new District__c();
      subcounty = new Subcounty__c();
      setUp(ApexPages.currentPage());
     
    }


 	public void setUp(PageReference pageRef) {

        // Try to keep the tab we're on
        String tabName = pageRef.getParameters().get('sfdc.tabName');
        this.tabName = tabName != null ? tabName : tabName;
        this.isEditMode = (pageRef.getParameters().get('editMode') == 'true'); 

        //this.dateFrom = pageRef.getParameters().get('dateFrom');
        //this.dateTo = pageRef.getParameters().get('dateTo');
        
    } 
    

	public String getIsUpdateable() {
        return this.isUpdateable;
    }
    
    
    public void setIsUpdateable(String value) {
        this.isUpdateable = value;
    }
        
        
    public String getIsEditMode() {
        String isEditing = 'false';
        isEditing = this.isEditMode ? 'true' : 'false';
        return isEditing;
    }  
    

	public void setDistrictList(List<SelectOption> option) {
        this.districtList = option;
    }
    
    
    public List<SelectOption> getDistrictList() {
        List<SelectOption> options = new List<SelectOption>();
        District__c[] districts = database.query(SoqlHelpers.getDistricts(orgName));
        options.add(new SelectOption('','-- In All Districts --'));
        
        //Add all districts to list
        for (District__c district : districts) {
               options.add(new SelectOption(district.Name, district.Name));
               } 
        return options;
    }


    public void setSubcountiesList(List<SelectOption> option) {
        this.districtList = option;
    }


    public List<SelectOption> getSubcountiesList() {
        List<SelectOption> options = new List<SelectOption>();
        Subcounty__c[] subcounties = database.query(MbugoHelpers.getSubcounties());
        options.add(new SelectOption('','-- In All Subcounties --'));

        //Add all subcounties to list
        for (Subcounty__c subcounty : subcounties) {
           options.add(new SelectOption(subcounty.Display_Name__c, subcounty.Display_Name__c));
        } 
        return options;
    }


    public List<MetricDataWrapper> getFarmersReachedData(){
        return MbugoHelpers.getFarmersReachedData();
    }


    public List<MbugoHelpers.CkwPerformanceWrapper> getCkwPerfomanceData(){
        return MbugoHelpers.getCkwPerfomanceData();
    }


    public PageReference changeFilters() {    
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('subcounty', subcounty.Display_Name__c);
        resultPage.getParameters().put('district', district.Name);
        resultPage.getParameters().put('dateFrom', dummyObject.Start_Date__c == null? '': 
            Datetime.newInstance(dummyObject.Start_Date__c.year(), dummyObject.Start_Date__c.month(), dummyObject.Start_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('dateTo', dummyObject.End_Date__c == null? '': 
            Datetime.newInstance(dummyObject.End_Date__c.year(), dummyObject.End_Date__c.month(), dummyObject.End_Date__c.day()).format('yyyy-MM-dd'));
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;
    }


	public List<MetricDataWrapper> getVslaServicesData(){    
        return MbugoHelpers.getVslaServicesData();
    }
    
    
	public List<MbugoHelpers.FinancialServicesUsageData> getFinancialServicesChartData(){
            return MbugoHelpers.getFinancialServicesChartData();
    }
  

    public List<MetricDataWrapper> getFarmerGroupsData(){
    	return MbugoHelpers.getFarmerGroupsData();
    }
    
    
      public  List<MetricDataWrapper> getCooperativeGroupsData(){
      	return MbugoHelpers.getCooperativeGroupsData();
    }
    