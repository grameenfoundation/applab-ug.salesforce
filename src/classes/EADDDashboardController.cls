/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This is the controller class for EADD Dashboard page
 *  It does the usual thing of servicing any interaction made on the dashboard
 *  Its test methods are in the EADDDashboardTests class 
 **/
public class EADDDashboardController {
    
    private Transient Map<String, Map<String, MetricDataWrapper>> metricWrappers;
    private Transient Map<String, Map<String, M_E_Metric_Data__c>> cumulativeMetrics;
    private Transient Map<String, List<String>> metricWrapperOrder;
    private Transient Map<String, M_E_Metric__c> allMetrics;

    private List<MetricDataWrapper> farmersData = new List<MetricDataWrapper>();
    private List<MetricDataWrapper> performanceData = new List<MetricDataWrapper>();
    private List<MetricDataWrapper> developmentData = new List<MetricDataWrapper>();
    private List<MetricDataWrapper> adoptionData = new List<MetricDataWrapper>();
    
    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;

    private Boolean isEditMode = false;
    private String isUpdateable = 'true';
    private String orgName = 'null';
  
    public EADDDashboardController() {
      dummyObject = new Date_Picker__c();
      district = new District__c();
      subcounty = new Subcounty__c();
      setUp(ApexPages.currentPage());
    }
    
    public District__c district { get; set; }
    public Subcounty__c subcounty { get; set; }
    public String dateFrom { get; set; }
    public String dateTo { get; set; }
    public String tabName { get; set; }
    public Date_Picker__c dummyObject { get; set; }
    
    public void setUp(PageReference pageRef){
      	//cache all metrics
      	allMetrics = EADDHelpers.getAllMetrics(); 
      	//set the organisation for this dashboard
		setOrgName('EADD');      
		// Try to keep the tab we're on
		String tabName = pageRef.getParameters().get('sfdc.tabName');
		if(tabName != null) {
		    this.tabName = tabName;
		}
		if(pageRef.getParameters().get('subcounty') != null){
		  this.subcounty.Display_Name__c = pageRef.getParameters().get('subcounty');
		}
		if(pageRef.getParameters().get('district') != null){
		  this.district.Name = pageRef.getParameters().get('district');
		}
		if(pageRef.getParameters().get('dateFrom') != null){
		  this.dateFrom = pageRef.getParameters().get('dateFrom');
		}
		if(pageRef.getParameters().get('dateTo') != null){
		  this.dateTo = pageRef.getParameters().get('dateTo');
		}
		this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');      
    }
    
    public void setAllMetrics(Map<String, M_E_Metric__c> metrics){
    	allMetrics = metrics;
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

        Subcounty__c[] subcounties = database.query(EADDHelpers.getSubcounties());
        options.add(new SelectOption('','-- In All Subcounties --'));

        //Add all subcounties to list
        for (Subcounty__c subcounty : subcounties) {
           options.add(new SelectOption(subcounty.Display_Name__c, subcounty.Display_Name__c));
        } 
        return options;
    }
    
    // For the moment we always want to return true here as we are updating targets manually
    public String getIsUpdateable() {
        return this.isUpdateable;
    }
    public void setIsUpdateable(String value) {
        this.isUpdateable = value;
    }
    
    public String getIsEditMode() {
        if(this.isEditMode) {
            return 'true';
        }
        return 'false';
    }  
    
    public void setOrgName(String orgName) {
        this.orgName = orgName;
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
  
	public List<MetricDataWrapper> getFarmersData(){
	    
	    if(allMetrics == null){
	      allMetrics = EADDHelpers.getAllMetrics(); 
	    }    
	    List<MetricDataWrapper> metrics = new List<MetricDataWrapper>();
	    MetricDataWrapper metric = new MetricDataWrapper();
	    M_E_Metric__c metricResult;
	    
	    //get total farmers reached
	    //get the actual value
	    List<AggregateResult> result = database.query(EADDHelpers.getFarmersActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    //get the target
	    metricResult = allMetrics.get(EADDHelpers.AVERAGE_NUMBER_OF_FARMERS_REACHED);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);    
	    
	    //get gender based metrics
	    //female target
	    metric = new MetricDataWrapper();
	    metricResult = allMetrics.get(EADDHelpers.FEMALE_NUMBER_OF_FARMERS_REACHED);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);  
	    
	    //female
	    result = database.query(EADDHelpers.getGenderFarmersQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    if(result.size() > 0 && result[0].get('Gender__c') == 'Female'){
	      metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    }
	    metrics.add(metric);
	    
	    //male
	    metric = new MetricDataWrapper();
	    if(result.size() > 1 && result[1].get('Gender__c') == 'Male'){
	      metric.setCurrentRealValue((Decimal)result[1].get('expr0'));
	    }
	    metricResult = allMetrics.get(EADDHelpers.MALE_NUMBER_OF_FARMERS_REACHED);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);
	    
	    //youth
	    //what defines a youth is the age, so modify as required
	    metric = new MetricDataWrapper();
	    result = database.query(EADDHelpers.getYouthFarmersQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    metricResult = allMetrics.get(EADDHelpers.YOUTH_NUMBER_OF_FARMERS_REACHED);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);
	    
	    return metrics;
	}
  
	public List<MetricDataWrapper> getPerformanceData(){
    
	    if(allMetrics == null){
	      allMetrics = EADDHelpers.getAllMetrics(); 
	    }
	    List<MetricDataWrapper> metrics = new List<MetricDataWrapper>();
	    MetricDataWrapper metric = new MetricDataWrapper();
	    M_E_Metric__c metricResult;
	    
	    //get suppliers
	    List<AggregateResult> result = database.query(EADDHelpers.getSuppliersActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    //target
	    metricResult = allMetrics.get(EADDHelpers.NUMBER_OF_FARMERS_SUPPLYING_MILK);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);    
	    
	    //milk volumes bulked
	    metric = new MetricDataWrapper();
	    result = database.query(EADDHelpers.getVolumesBulkedActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    metricResult = allMetrics.get(EADDHelpers.MILK_VOLUME_BULKED);
	    metric.setCurrentTarget((metricResult.Projected_Value__c == 0.0 || metricResult.Projected_Value__c == null)? 'N/A': String.valueOf(metricResult.Projected_Value__c));
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);  
	    metrics.add(metric);    
	    
	    //revenue raised
	    metric = new MetricDataWrapper();
	    result = database.query(EADDHelpers.getRevenueActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    metricResult = allMetrics.get(EADDHelpers.REVENUE_RAISED_FROM_MILK_SALES);
	    
	    //the reason i use ternary operators is that if statements are tight when it comes to tests
	    metric.setCurrentTarget((metricResult.Projected_Value__c == 0.0 || metricResult.Projected_Value__c == null)? 'N/A': String.valueOf(metricResult.Projected_Value__c));
	    metric.setMetricId(String.valueOf(metricResult.Id));    
	    metric.setLabel(metricResult.Label__c);  
	    metrics.add(metric);    
	    
	    //profit
	    metric = new MetricDataWrapper();
	    result = database.query(EADDHelpers.getProfitActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    metricResult = allMetrics.get(EADDHelpers.PROFIT_RAISED_FROM_MILK_SALES);
	    metric.setCurrentTarget((metricResult.Projected_Value__c == 0.0 || metricResult.Projected_Value__c == null)? 'N/A': String.valueOf(metricResult.Projected_Value__c));
	    metric.setMetricId(String.valueOf(metricResult.Id));
	    metric.setLabel(metricResult.Label__c);  
	    metrics.add(metric);    
	    
	    return metrics;
	}
  
	public List<MetricDataWrapper> getDevelopmentData(){
  
	    List<MetricDataWrapper> combinedMetrics = new List<MetricDataWrapper>();
	    
	    //with access to farm inputs
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_INPUTS, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_INPUTS, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_INPUTS, 
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_INPUTS,
	                  'Accesses_farm_inputs__c'
	                ), 
	                combinedMetrics);
	    
	    //access to AI
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_AI, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_AI, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_AI,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_AI,
	                  'Accesses_AI__c'
	                ), 
	                combinedMetrics);
	    
	    //accessing health services
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_HEALTH, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_HEALTH, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_HEALTH,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_HEALTH,
	                  'Access_AH__c'
	                ), 
	                combinedMetrics);
	
	    //accessing trainings
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_TRAINING, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_TRAINING, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_TRAINING,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_TRAINING,
	                  'Access_farmer_trainings__c'
	                ), 
	                combinedMetrics);
	
	    //accessing feed
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_SUPPLIES, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_SUPPLIES, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_SUPPLIES,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_SUPPLIES,
	                  'Accesses_feeds__c'
	                ), 
	                combinedMetrics);
	
	    //accessing financial services
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_FINANCIAL_SERVICES, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_FINANCIAL_SERVICES, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_FINANCIAL_SERVICES,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_FINANCIAL_SERVICES,
	                  'Access_financial_services__c'
	                ), 
	                combinedMetrics);
	
	    //accessing transport
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_TRANSPORT, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_TRANSPORT, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_TRANSPORT,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_TRANSPORT,
	                  'Access_transport_services__c'
	                ), 
	                combinedMetrics);
	    
	    //accessing checkoff-services
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_ACCESSING_CHECKOFF_SERVICES, 
	                  EADDHelpers.FEMALE_FARMERS_ACCESSING_CHECKOFF_SERVICES, 
	                  EADDHelpers.MALE_FARMERS_ACCESSING_CHECKOFF_SERVICES,
	                  EADDHelpers.YOUTH_FARMERS_ACCESSING_CHECKOFF_SERVICES,
	                  'Accesses_checkoff_services__c'
	                ), 
	                combinedMetrics);
	                                                                                    
	    return combinedMetrics;
	}  
  
	public List<MetricDataWrapper> getAdoptionData(){
    
	    List<MetricDataWrapper> combinedMetrics = new List<MetricDataWrapper>();
	    
	    //use ai
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_USING_AI, 
	                  EADDHelpers.FEMALE_FARMERS_USING_AI, 
	                  EADDHelpers.MALE_FARMERS_USING_AI, 
	                  EADDHelpers.YOUTH_FARMERS_USING_AI,
	                  'Uses_AI__c'
	                ), 
	                combinedMetrics);
	    
	    //use dry season feeding
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_USING_DRY_SEASON_FEEDING, 
	                  EADDHelpers.FEMALE_FARMERS_USING_DRY_SEASON_FEEDING, 
	                  EADDHelpers.MALE_FARMERS_USING_DRY_SEASON_FEEDING,
	                  EADDHelpers.YOUTH_FARMERS_USING_DRY_SEASON_FEEDING,
	                  'Uses_dryseason_feeding__c'
	                ), 
	                combinedMetrics);
	    
	    //uses supplementaries
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_USING_SUPPLEMENTARY, 
	                  EADDHelpers.FEMALE_FARMERS_USING_SUPPLEMENTARY, 
	                  EADDHelpers.MALE_FARMERS_USING_SUPPLEMENTARY,
	                  EADDHelpers.YOUTH_FARMERS_USING_SUPPLEMENTARY,
	                  'Uses_supplementary_feeding__c'
	                ), 
	                combinedMetrics);
	
	    //uses high quality 
	    combinedMetrics = combineMetrics(
	                getSubSectionMetrics(
	                  EADDHelpers.FARMERS_USING_HIGH_QUALITY, 
	                  EADDHelpers.FEMALE_FARMERS_USING_HIGH_QUALITY, 
	                  EADDHelpers.MALE_FARMERS_USING_HIGH_QUALITY,
	                  EADDHelpers.YOUTH_FARMERS_USING_HIGH_QUALITY,
	                  'Uses_highquality_feeds__c'
	                ), 
	                combinedMetrics);
	                                                                                    
	    return combinedMetrics;
	}
  
  /*
   * this code piece repeats over six times, i had extract into separately method
   * for each subsection, we get the male, female and youth metrics
   */
	private List<MetricDataWrapper> getSubSectionMetrics(String subSectionMetricTitle, String femalesMetricName, String maleMetricName, String youthMetricName, String metricColumn){

	    if(allMetrics == null){
	      allMetrics = EADDHelpers.getAllMetrics(); 
	    }    
	    List<MetricDataWrapper> metrics = new List<MetricDataWrapper>();
	    MetricDataWrapper metric = new MetricDataWrapper();
	    M_E_Metric__c metricResult;
	
	    //get the title
	    metricResult = allMetrics.get(subSectionMetricTitle);
	    metric.setCurrentTarget('');
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);    
	    
	    //get gender based metrics
	    //female target
	    metric = new MetricDataWrapper();
	    metricResult = allMetrics.get(femalesMetricName);
	    metric.setCurrentTarget('N/A');
	    metric.setLabel(metricResult.Label__c);  
	    
	    //female
	    List<AggregateResult> result = database.query(EADDHelpers.getGenderActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo, metricColumn));
	    metric.setCurrentRealValue((result.size() > 0 && result[0].get('Gender__c') == 'Female')? (Decimal)result[0].get('expr0'): null);
	    //if(result.size() > 0 && result[0].get('Gender__c') == 'Female'){
	      //metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    //}
	    metrics.add(metric);
	    
	    //male
	    metric = new MetricDataWrapper();
	    metric.setCurrentRealValue((result.size() > 1 && result[1].get('Gender__c') == 'Male')? (Decimal)result[1].get('expr0'): null);
	    //if(result.size() > 1 && result[1].get('Gender__c') == 'Male'){
	      //metric.setCurrentRealValue((Decimal)result[1].get('expr0'));
	    //}
	    metricResult = allMetrics.get(maleMetricName);
	    metric.setCurrentTarget('N/A');
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);
	    
	    //youth
	    //what defines a youth is the age, so modify as required
	    metric = new MetricDataWrapper();
	    result = database.query(EADDHelpers.getYouthActualValueQuery(district.Name, subcounty.Display_Name__c, dateFrom, dateTo, metricColumn));
	    metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
	    metricResult = allMetrics.get(youthMetricName);
	    metric.setCurrentTarget(metricResult.Projected_Value__c);
	    metric.setLabel(metricResult.Label__c);
	    metrics.add(metric);
	    
	    return metrics;
	}
  
  /*
   * combines two Lists
   */
	private List<MetricDataWrapper> combineMetrics(List<MetricDataWrapper> newMetrics, List<MetricDataWrapper> combinedMetrics){
	    for(MetricDataWrapper metric : newMetrics){
	      combinedMetrics.add(metric);
	    }
	    return combinedMetrics;
	}
  
	public static MetricMapWrapper[] getDairyHubMapMarkers(){
	    String ids = EADDHelpers.getIdsOfLatestHubInformation();
	    String query = 'SELECT '              +
	              'Id, '              +
	              'Date__c, '            +
	              'District__c, '          +
	              'Farmers_served_by_hub__c, '  +
	              'Hub_capacity_utilization__c, '  +
	              'Latitude__c, '          +
	              'Longitude__c, '        +
	              'Milk_sale_profits__c, '    +
	              'Milk_sale_revenue__c, '    +
	              'Milk_volumes_bulked__c, '    +
	              'Milk_volumes_rejected__c, '  +
	              'Name__c, '            +
	              'Subcounty__c, '        +
	              'Radius_Covered__c '      +
	            'FROM '                +
	              'EADD_Hub__c ';
	    query += ids == ''? '' :
	            'WHERE '              +
	              'Id IN (' + ids + ')';

      	EADD_Hub__c[] hubs = database.query(query);      
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        if (hubs.size() == 0) {
            return markers.values();
        }

        for (EADD_Hub__c hub : hubs) {

            // Dont include if we are missing the location
            if (hub.Latitude__c == null || hub.Latitude__c == '' || hub.Longitude__c == null || hub.Longitude__c == '') {
                continue;
            }
            
          String name = hub.Name__c;
          
          MetricMapWrapper marker = null;
            marker = new MetricMapWrapper('DairyHub', 'FFD801', hub.Id, true);
            marker.gpsLatitude = hub.Latitude__c;
            marker.gpsLongitude = hub.Longitude__c;
             
            String content =   '<div>'                                    +
                '  &nbsp;&nbsp;Hub Details <br/>'                      +
                '  Name:&ensp;' + hub.Name__c + '<br/>'                  +
                '  Utilization level:&ensp;' + hub.Hub_capacity_utilization__c + '<br/>'  +
                '  Coverage(km):&ensp;' + hub.Radius_Covered__c + '<br/>';
            
            marker.addName(content);
            marker.markerTitle = name;
            markers.put(hub.Id, marker);
        }
        // Tidy up the created lists so to keep the heap size down.
        hubs.clear();
        return markers.values();
	}
}