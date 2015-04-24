/**
 *  Controller to load the settings for the Gumutindo Dashboard
 */

public with sharing class GumutindoDashboardController {

    private Boolean isEditMode = false;
    private String currentQuarter = null;
    private String showPreviousQuarter = 'true';
    private List<GumutindoHelpers.DataWrapper> scaleData = new List<GumutindoHelpers.DataWrapper>();
    private List<GumutindoHelpers.DataWrapper> impactData = new List<GumutindoHelpers.DataWrapper>();
    private List<GumutindoHelpers.DataWrapper> qualityData = new List<GumutindoHelpers.DataWrapper>();
    private List<GumutindoHelpers.DataWrapper> sustainabilityData = new List<GumutindoHelpers.DataWrapper>();
    private Transient Map<String, Map<String, GumutindoHelpers.DataWrapper>> metricWrappers;
    private Transient Map<String, List<String>> metricWrapperOrder;
    private Map<String, Boolean> viewSectionsMap = new Map<String, Boolean>();

    private Dashboard_Section__c districtMapSection;
    public List<District__c> gumutindoDistricts;
    public List<Subcounty__c> gumutindoSubCounties;
    private String isUpdateable = 'true';
    private String orgName = 'null';
    private Transient Map<String, M_E_Metric_Data__c> allMetricDatas;

    private List<SelectOption> districtList;  
    private List<SelectOption> subcountiesList;
    private Transient Map<String, M_E_Metric__c> allMetrics;

    //Maps list
    private List<Map_Parameter__c> maps;
    public String quarter = null;

    public GumutindoDashboardController() {
      dummyObject = new Date_Picker__c();
      district = new District__c();
      subcounty = new Subcounty__c();
      setUpQuarter(ApexPages.currentPage().getParameters().get('quarter'));
      setUp(ApexPages.currentPage());
    }


    public District__c district { get; set; }
    public Subcounty__c subcounty { get; set; }
    public String tabName { get; set; }
    public Date_Picker__c dummyObject { get; set; }


    public void setOrgName(String orgName) {
        this.orgName = orgName;
    }

    public void setUp(PageReference pageRef){
        //cache all metrics
        //allMetrics = GumutindoHelpers.getMetricDataMap();
        //set the organisation for this dashboard
        setOrgName('GCCE');      
        // Try to keep the tab we're on
        String tabName = pageRef.getParameters().get('sfdc.tabName');
        this.tabName = tabName != null ? tabName : tabName;
        this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');    
        
        List<String> sectionTitles = GumutindoHelpers.getDashboardSections();
        for(String section : sectionTitles) {
            viewSectionsMap.put(section, true);
        }  
    }
    
    public List<SelectOption> getQuarters() {

        List<SelectOption> options = new List<SelectOption>();
        Integer currentYear = Date.today().year();
        Integer currentQuarter = MetricHelpers.getQuarter(Date.today());
        Integer quarter;
        Integer startYear;

        // Data starts in Q3-2014 (using calendar quarters, not fiscal) for grameen.
        startYear = 2014;
        quarter = 3;
        for (Integer year = startYear; year <= currentYear; year++) {
            quarter = year != startYear ? 1 : quarter;
            while (quarter <= 4) {
                String quarterString = MetricHelpers.getQuarterStartMonth(quarter) + ' - ' + MetricHelpers.getQuarterEndMonth(quarter) + ' ' + String.valueOf(year);
                SelectOption option = new SelectOption(quarterString, quarterString);
                if (year == currentYear && quarter == currentQuarter && (this.quarter == null || this.quarter.length() == 0)) {
                    this.setQuarter(quarterString);
                }
                options.add(option);
                quarter++;
            }
        }
        return options;
    }
    
    public String getQuarter() {
        return quarter;
    }

    public void setQuarter(String quarter) {
        this.quarter = quarter;
    }
    
    private void setUpQuarter(String quarter) {

        this.currentQuarter = MetricHelpers.getCurrentQuarterAsString(0);
        if (quarter == null || quarter.length() == 0) {
            setQuarter(this.currentQuarter);
        } else {
            setQuarter(quarter);
        }
    }

    public String getCurrentQuarter() {
        return currentQuarter;
    }
    
    public void setCurrentQuarter(String quarter) {
        this.currentQuarter = quarter;
    }
    
    public PageReference changeQuarter() {
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('quarter', this.quarter);
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
    
    public PageReference changeFilters() {    
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('quarter', this.quarter);
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
    public String getIsCurrentQuarter() {
        String isCurrent = 'false';
        isCurrent = (null != this.quarter && this.quarter.equals(this.currentQuarter)) ? 'true' : 'false';
        return isCurrent;
    }

    public Dashboard_Section__c getDistrictMapSection() {
        Dashboard_Section__c dashboardsection = new Dashboard_Section__C();
        dashboardsection.Display_Order__c=0;
        dashboardsection.Has_Graphs__c=false;

        dashboardsection.Has_Maps__c=true;
        dashboardsection.Is_Active__c=true;
        dashboardsection.Title__c='Gumutindo Districts Of Operation';
        //dashboardsection.Dashboard__c = dashboardName;
        

        //Create map parameter for this section
        Map_Parameter__C mapparameter = new Map_Parameter__C();
        mapparameter.Keyword__c='Gumutindo Districts Of Operation';
        mapparameter.Dashboard_Section__c=dashboardsection.Id;
        mapparameter.Type_Of_sObject__c='Custom Class';
        mapparameter.Map_Marker_Source_Class__c='GumutindoHelpers.GumutindoDistrictCoordinatesProvider';
        mapparameter.Zoom__c=6;
        mapparameter.Latitude__c='0.5167';
        mapparameter.Longitude__c='32.5833';
        mapparameter.Title__c='Gumutindo Districts Of Operation';

        return dashboardsection;
    }

    //Loads primary societies
    public List<Gumutindo_Primary_Society__c> loadGumutindoPrimarySocieties() {
        List<Gumutindo_Primary_Society__c> primarySocieties = database.query('SELECT '               +
                'Id, '              +
                'Name, Subcounty__r.Id, Subcounty__r.District__r.Id '             +
            'FROM '                 +
                'Gumutindo_Primary_Society__c '     +
            'ORDER BY '             +
                'Name');

                List<String> districtIds = new List<String>();
                List<String> subcountyIds = new List<String>();

                for(Gumutindo_Primary_Society__c society : primarySocieties) {
                    districtIds.add(society.Subcounty__r.District__r.Id);
                    subcountyIds.add(society.Subcounty__r.Id);
                }

                
                //select districts by Ids
                //gumutindoDistricts = database.query('SELECT Id, Name, Latitude__c, Longitude__c from District__c where Id in:'+districtIds);

               //gumutindoSubCounties = database.query('SELECT Id, Name, Latitude__c, Longitude__c from Subcounty__c where Id in:'+subcountyIds);

                return primarySocieties;
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

        Subcounty__c[] subcounties = database.query(GumutindoHelpers.getSubcounties());
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
    
    public GumutindoHelpers.DataWrapper[] getScaleData() {
        return getAreaData('Scale');
    }
    
    public GumutindoHelpers.DataWrapper[] getImpactData() {
        return getAreaData('Impact');
    }

    public GumutindoHelpers.DataWrapper[] getQualityData() {
        return getAreaData('Quality');
    }

    public GumutindoHelpers.DataWrapper[] getSustainabilityData() {
        return getAreaData('Sustainability');
    }

    private GumutindoHelpers.DataWrapper[] getAreaData(String area) {

        List<GumutindoHelpers.DataWrapper> areaData = new List<GumutindoHelpers.DataWrapper>();
        if (this.metricWrappers == null) {
            GumutindoHelpers.Wrapper wrapper = GumutindoHelpers.getData(this.quarter);
            this.metricWrappers = wrapper.dataWrapper;
            this.metricWrapperOrder = wrapper.dataWrapperOrder;
        }
        Map<String, GumutindoHelpers.DataWrapper> wrappers = this.metricWrappers.get(area);
        List<String> metricOrder = this.metricWrapperOrder.get(area);
        if (wrappers != null && metricOrder != null) {
            for (String key : metricOrder) {
                GumutindoHelpers.DataWrapper wrapper = wrappers.get(key);
                if (wrapper != null) {
                    areaData.add(wrapper);
                }
            }
        }
        return areaData;
    }

    public List<Map_Parameter__c> getMaps()
    {
        List<Map_Parameter__c> mapList = new List<Map_Parameter__c>();
        Map_Parameter__C mapparameter = new Map_Parameter__C();
        mapparameter.Keyword__c='Location of Gumutindo CKWs';
        mapparameter.Type_Of_sObject__c='Custom Class';
        mapparameter.Map_Marker_Source_Class__c='GumutindoHelpers.GumutindoCkwCoordinatesProvider';
        mapparameter.Zoom__c=6;
        mapparameter.Latitude__c='0.5167';
        mapparameter.Longitude__c='32.5833';
        mapparameter.Title__c='Location of Gumutindo CKWs';

        mapList.add(mapparameter);
        return mapList;
    }   
     
     public Boolean getViewQuality(){
        return viewSectionsMap.get('Quality');
    }
    public Boolean getViewScale(){
        return viewSectionsMap.get('Scale');
    }
    public Boolean getViewImpact(){
        return viewSectionsMap.get('Impact');
    }
    public Boolean getViewSustainability(){
        return viewSectionsMap.get('Sustainability');
    }
                 
}