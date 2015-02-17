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
               options.add(new SelectOption(district.Name, district.Name));} 
         
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

/*
    public List<MetricDataWrapper> getFarmerGroupsData(){
        return MbugoHelpers.getFarmerGroupsData();
    }
*/
         
  /*  public List<MetricDataWrapper> getCooperativeGroupsData(){
        return MbugoHelpers.getCooperativeGroupsData();
    }*/

    public List<MbugoHelpers.CkwPerformanceWrapper> getCkwPerfomanceData()
    {
        return MbugoHelpers.getCkwPerfomanceData();

    }



 /*   public List<MbugoHelpers.FinancialServicesUsageData> getFinancialServicesChartData() {
        return MbugoHelpers.getFinancialServicesChartData();
        
    }*/


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


    //Added
     public List<MetricDataWrapper> getVslaServicesData(){
        
        String FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_micro_insurance_financial_services_through_vslas';
        String FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_savings_financial_services_through_vslas';
        String FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_loaning_financial_services_through_vslas';
        
        List<MetricDataWrapper> vslaServicesData;
        M_E_Metric_Data__c metricData;

    

        MetricDataWrapper loaningWrapper = new MetricDataWrapper();
        loaningWrapper.setLabel('Percentage of target farmers with access to Loaning Financial Services');
        
        MetricDataWrapper insuranceWrapper = new MetricDataWrapper();
        insuranceWrapper.setLabel('Percentage of target farmers with access to Micro Insurance Financial Services');
        
         MetricDataWrapper savingsWrapper = new MetricDataWrapper();
        savingsWrapper.setLabel('Percentage of target farmers with access to Savings Financial Services');

    try{
        metricData = getMetricDataT(FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS);
        loaningWrapper.setMetricId(String.valueOf(metricData.Id));
        loaningWrapper.setCurrentTarget(metricData.Projected_Value__c);
        loaningWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
       // TODO: Get these from db
           
        metricData = getMetricDataT(FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS);
        savingsWrapper.setMetricId(String.valueOf(metricData.Id));
        savingsWrapper.setCurrentTarget(metricData.Projected_Value__c);
        savingsWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
       
        metricData = getMetricDataT(FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS);
        insuranceWrapper.setMetricId(String.valueOf(metricData.Id));
        insuranceWrapper.setCurrentTarget(metricData.Projected_Value__c);
        insuranceWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        
        }catch(Exception ex){}
            
        vslaServicesData = new List<MetricDataWrapper> {loaningWrapper, savingsWrapper, insuranceWrapper};
       
        
        return vslaServicesData;
    }
    
    //Added
   public  List<MbugoHelpers.FinancialServicesUsageData> getFinancialServicesChartData()
    {
            final String FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_micro_insurance_financial_services_through_vslas';
            final String FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_savings_financial_services_through_vslas';
            final String FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS = 'MBUGO_farmers_who_access_loaning_financial_services_through_vslas';
        
        List<MbugoHelpers.FinancialServicesUsageData> financialServicesChartData = new List<MbugoHelpers.FinancialServicesUsageData>();
         
           MbugoHelpers.FinancialServicesUsageData MicroInsurance;  
           MbugoHelpers.FinancialServicesUsageData Savings;
           MbugoHelpers.FinancialServicesUsageData Loaning;
     
    try{
       M_E_Metric_Data__c metricData = getMetricDataT(FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS);
       metricData = getMetricDataT(FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS);
       metricData = getMetricDataT(FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS);
         
        MicroInsurance =  new MbugoHelpers.FinancialServicesUsageData('MicroInsurance', metricData.Manual_Value__c);
        
        Savings = new MbugoHelpers.FinancialServicesUsageData('Savings', metricData.Manual_Value__c);
        
        Loaning = new MbugoHelpers.FinancialServicesUsageData('Loaning', metricData.Manual_Value__c);  
       
       
        }catch(Exception ex){} 
         
         financialServicesChartData.add(MicroInsurance);
         financialServicesChartData.add(Savings);
         financialServicesChartData.add(Loaning);
    /*      
        financialServicesChartData.add(new MbugoHelpers.FinancialServicesUsageData('MicroInsurance', metricData.Manual_Value__c));
        
        financialServicesChartData.add(new MbugoHelpers.FinancialServicesUsageData('Savings', metricData.Manual_Value__c));
        
        financialServicesChartData.add(new MbugoHelpers.FinancialServicesUsageData('Loaning', metricData.Manual_Value__c));  */
        
        return financialServicesChartData;
    }
  

   
    //added
    public List<MetricDataWrapper> getFarmerGroupsData(){
    String NUMBER_OF_VSLAS_REGISTERED = 'MBUGO_farmers_number_of_vslas_registered';
        String TOTAL_NUMBER_OF_FARMERS_IN_VSLAS = 'MBUGO_total_number_of_farmers_in_vslas';
        String TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS = 'MBUGO_total_number_male_of_farmers_in_vslas';
        String TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS = 'MBUGO_total_number_of_female_farmers_in_vslas';
       
        List<MetricDataWrapper> farmerGroupsData;// = new List<MetricDataWrapper>();
        M_E_Metric_Data__c metricData;
        
        
        MetricDataWrapper vslaMetricWrapper = new MetricDataWrapper();
        vslaMetricWrapper.setLabel('Number of farmer learning groups/VSLA registered');
        
        MetricDataWrapper totalVslaFemaleFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaFemaleFarmerMetricWrapper.setLabel('Number of female members registered in the farmer learning groups');
        
        MetricDataWrapper totalVslaFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaFarmerMetricWrapper.setLabel('Number of members registered in the farmer learning groups/VSLA ');
        
        MetricDataWrapper totalVslaMaleFarmerMetricWrapper = new MetricDataWrapper();
        totalVslaMaleFarmerMetricWrapper.setLabel('Number of male members registered in the farmer learning groups');
       
       try{
            metricData = getMetricDataT(NUMBER_OF_VSLAS_REGISTERED);
            vslaMetricWrapper.setMetricId(String.valueOf(metricData.Id));
            vslaMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
            vslaMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
             
            metricData = getMetricDataT(TOTAL_NUMBER_OF_FARMERS_IN_VSLAS);
            totalVslaFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
            totalVslaFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
            totalVslaFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
 
            metricData = getMetricDataT(TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS);
            totalVslaMaleFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
            totalVslaMaleFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
            totalVslaMaleFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
       
            metricData = getMetricDataT(TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS);
            totalVslaFemaleFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
            totalVslaFemaleFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
            totalVslaFemaleFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
         } catch(Exception ex){System.debug('Error'+ ex.getMessage());}
        
        farmerGroupsData = new List<MetricDataWrapper>{vslaMetricWrapper, totalVslaFarmerMetricWrapper, 
            totalVslaMaleFarmerMetricWrapper, totalVslaFemaleFarmerMetricWrapper};
          
        
        return farmerGroupsData; 
    }
    
    
    //Added
    
      public  List<MetricDataWrapper> getCooperativeGroupsData()
    {
    
      final String NUMBER_OF_COOPERATIVES_REGISTERED = 'MBUGO_number_of_cooperatives_registered';
      final String PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE = 'MBUGO_percentage_of_farmers_purchasing_inputs_from_mbugo_ace';
      List<MetricDataWrapper>  cooperativeGroupsData ;
        
        M_E_Metric_Data__c metricData;
    
  
        MetricDataWrapper cooperativesMetricWrapper = new MetricDataWrapper();
        cooperativesMetricWrapper.setLabel('Number of cooperatives registered');
        
        MetricDataWrapper coopPurchasingFarmerMetricWrapper = new MetricDataWrapper();
        coopPurchasingFarmerMetricWrapper.setLabel('Percent of targeted farmers purchasing inputs from Mbugo Ace through their cooperatives');
        
       
     try{  
        metricData = getMetricDataT(NUMBER_OF_COOPERATIVES_REGISTERED);
        cooperativesMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        cooperativesMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        cooperativesMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        //TODO: Get these from db
          
        metricData = getMetricDataT(PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE);
        coopPurchasingFarmerMetricWrapper.setMetricId(String.valueOf(metricData.Id));
        coopPurchasingFarmerMetricWrapper.setCurrentTarget(metricData.Projected_Value__c);
        coopPurchasingFarmerMetricWrapper.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
        //TODO: Get these from db
        }catch(Exception ex){System.debug('Error!'+ ex.getMessage());}

        cooperativeGroupsData = new List<MetricDataWrapper> {cooperativesMetricWrapper, coopPurchasingFarmerMetricWrapper};
        
    
        return cooperativeGroupsData;
    }
    
    //Added
    public static M_E_Metric_Data__c getMetricDataT(String metricName) {
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
    
        M_E_Metric_Data__c[] metricT = [
            SELECT 
                Name,
                Id,
                Date__c,
                Actual_Value__c,
                Projected_Value__c,
                Manual_Value__c,
                Real_Value__c,
                Is_Cumulative__c,
                Numerator__c,
                Denumerator__c,
                Comment__c,
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Id
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :metricName];
        
           return metricT[0];
    }
}