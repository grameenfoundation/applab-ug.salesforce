/**
 *  Controller to load the settings for the Gumutindo Dashboard
 */
public with sharing class GumutindoDashboardController {

	private Dashboard_Section__c districtMapSection;
	public List <District__c> gumutindoDistricts;
	public List <Subcounty__c> gumutindoSubCounties;
	private Boolean isEditMode = false;
	private String isUpdateable = 'true';
	private String orgName = 'null';
	private Transient Map <String, M_E_Metric_Data__c> allMetricDatas;

	private List <SelectOption> districtList;
	private List <SelectOption> subcountiesList;
	private Transient Map <String, M_E_Metric__c> allMetrics;

	//Maps list
	private List <Map_Parameter__c> maps;

	public GumutindoDashboardController() {
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

	public void setOrgName(String orgName) {
		this.orgName = orgName;
	}

	public void setUp(PageReference pageRef) {
	    
		//cache all metrics
		//allMetrics = GumutindoHelpers.getMetricDataMap();
		//set the organisation for this dashboard
		setOrgName('GCCE');
		// Try to keep the tab we're on
		String tabName = pageRef.getParameters().get('sfdc.tabName');
		if (tabName != null) {
			this.tabName = tabName;
		}
		if (pageRef.getParameters().get('subcounty') != null) {
			this.subcounty.Display_Name__c = pageRef.getParameters().get('subcounty');
		}
		if (pageRef.getParameters().get('district') != null) {
			this.district.Name = pageRef.getParameters().get('district');
		}
		if (pageRef.getParameters().get('dateFrom') != null) {
			this.dateFrom = pageRef.getParameters().get('dateFrom');
		}
		if (pageRef.getParameters().get('dateTo') != null) {
			this.dateTo = pageRef.getParameters().get('dateTo');
		}
		this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');
	}

	public Dashboard_Section__c getDistrictMapSection() {
	    
		Dashboard_Section__c dashboardsection = new Dashboard_Section__C();
		dashboardsection.Display_Order__c = 0;
		dashboardsection.Has_Graphs__c = false;

		dashboardsection.Has_Maps__c = true;
		dashboardsection.Is_Active__c = true;
		dashboardsection.Title__c = 'Gumutindo Districts Of Operation';
		//dashboardsection.Dashboard__c = dashboardName;

		//Create map parameter for this section
		Map_Parameter__C mapparameter = new Map_Parameter__C();
		mapparameter.Keyword__c = 'Gumutindo Districts Of Operation';
		mapparameter.Dashboard_Section__c = dashboardsection.Id;
		mapparameter.Type_Of_sObject__c = 'Custom Class';
		mapparameter.Map_Marker_Source_Class__c = 'GumutindoHelpers.GumutindoDistrictCoordinatesProvider';
		mapparameter.Zoom__c = 6;
		mapparameter.Latitude__c = '0.5167';
		mapparameter.Longitude__c = '32.5833';
		mapparameter.Title__c = 'Gumutindo Districts Of Operation';

		return dashboardsection;
	}


	public List <MetricDataWrapper> getFarmersReachedData() {
	    
		List <MetricDataWrapper> farmersReachedData = new List <MetricDataWrapper> ();

		if (allMetrics == null) {
			allMetrics = GumutindoHelpers.getAllMetrics();
		}
		String[] metricsInthisSection = new String[] {
			GumutindoHelpers.TARGET_FARMERS_REACHED_IN_YEAR_1,
			GumutindoHelpers.MALE_FARMERS_REGISTERED,
			GumutindoHelpers.FEMALE_FARMERS_REGISTERED
		};

		M_E_Metric__c metricResult;
		M_E_Metric_Data__c metricData;
		metricResult = allMetrics.get(GumutindoHelpers.TARGET_FARMERS_REACHED_IN_YEAR_1.toLowerCase());

		Person_Group_Association__c[] associations = [
			SELECT 
				id, 
				Person__c, 
				Group__c, 
				Person__r.GPS_Location_E__c, 
				Person__r.GPS_Location_N__c  
			FROM 
				Person_Group_Association__c 
			WHERE 
				Group__r.Name = 'GCCE' AND 
				Person__r.Type__c = 'CKW'
		];

		List <String> personIds = new List <String> ();
		for (Person_Group_Association__c p: associations) {
			personIds.add(p.Person__r.Id);
		}

		//These are the ckw person ids
		/*List <Farmer__c> farmersRegisteredByGumutindoCkws = [
			SELECT 
				Registered_by__c, 
				Person__r.id, 
				Person__r.Gender__c, 
				Person__r.First_Name__c, 
				Person__r.Last_Name__c 
			FROM 
				Farmer__c 
			WHERE 
				Registered_by__c IN: personIds AND 
				Person__r.First_Name__c <> 'Not Registered'
			LIMIT 10000
		];
		*/
		List<AggregateResult> totalFarmers = [
			SELECT
				Person__r.Gender__c sex, 
				COUNT(Id) total
			FROM
				Farmer__c 
			WHERE
				Registered_by__c IN: personIds AND 
				Person__r.First_Name__c <> 'Not Registered'
			GROUP BY
				Person__r.Gender__c
			ORDER BY 
				Person__r.Gender__c
		];

		MetricDataWrapper farmersReachedMetricWrapper = new MetricDataWrapper();
		farmersReachedMetricWrapper.setCurrentTarget(metricResult == null ? 0 : metricResult.Projected_Value__c);
		farmersReachedMetricWrapper.setLabel('Total Farmers Reached');
		farmersReachedMetricWrapper.setCurrentRealValue(0);

		MetricDataWrapper maleFarmersReachedMetricWrapper = new MetricDataWrapper();
		//maleFarmersReachedMetricWrapper.setCurrentTarget(8000);
		maleFarmersReachedMetricWrapper.setLabel('Total Male Farmers Reached');
		maleFarmersReachedMetricWrapper.setCurrentRealValue(0);

		MetricDataWrapper femaleFarmersReachedMetricWrapper = new MetricDataWrapper();
		//femaleFarmersReachedMetricWrapper.setCurrentTarget(8000);
		femaleFarmersReachedMetricWrapper.setLabel('Total Female Farmers Reached');
		femaleFarmersReachedMetricWrapper.setCurrentRealValue(0);

		Decimal totalFarmerCount = 0;
		Decimal totalMaleFarmerCount = 0;
		Decimal totalFemaleFarmerCount = 0;
		For(AggregateResult ar : totalFarmers) {
			if(String.valueOf(ar.get('sex')).equalsIgnoreCase('Male')) {
				totalMaleFarmerCount = (Decimal)ar.get('total');
			} 
			else if(String.valueOf(ar.get('sex')).equalsIgnoreCase('Female')) {
				totalFemaleFarmerCount = (Decimal)ar.get('total');
			}
		}
		totalFarmerCount = totalFemaleFarmerCount + totalMaleFarmerCount;
		/*
		for (Farmer__c farmer: farmersRegisteredByGumutindoCkws) {
			totalFarmerCount += 1;

			if ('male'.equalsIgnoreCase(farmer.Person__r.Gender__c)) {
				totalMaleFarmerCount += 1;
			} else {
				totalFemaleFarmerCount += 1;
			}
		}
		*/
		farmersReachedMetricWrapper.setCurrentRealValue(totalFarmerCount);
		maleFarmersReachedMetricWrapper.setCurrentRealValue(totalMaleFarmerCount);
		femaleFarmersReachedMetricWrapper.setCurrentRealValue(totalFemaleFarmerCount);

		List <MetricDataWrapper> wrapper = new List <MetricDataWrapper> {
			farmersReachedMetricWrapper, maleFarmersReachedMetricWrapper, femaleFarmersReachedMetricWrapper
		};

		return wrapper;
	}

	public List <MetricDataWrapper> getAdvisoryServicesData() {

		if (allMetrics == null) {
			allMetrics = GumutindoHelpers.getAllMetrics();
		}
		String[] metricsInthisSection = new String[] {
			GumutindoHelpers.FARMERS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK,
			GumutindoHelpers.FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES,
			GumutindoHelpers.FARMERS_WHO_REPORT_SATISFACTION_WITH_PS_SERVICES,
			GumutindoHelpers.FARMERS_SATISFIED_WITH_QUALITY_OF_EXTENSION_SERVICES
		};
		List <MetricDataWrapper> metrics = new List <MetricDataWrapper> ();

		M_E_Metric__c metricResult;
		M_E_Metric_Data__c metricData;

		//get total farmers reached
		//get the actual value
		//get the target
		for (String sectionMetric: metricsInthisSection) {
			MetricDataWrapper metric = new MetricDataWrapper();
			metricResult = allMetrics.get(sectionMetric.toLowerCase());
			System.debug('Metric result for ' + sectionMetric + ' is ' + metricResult);
			metric.setCurrentTarget(metricResult == null ? 0 : metricResult.Projected_Value__c);
			//metric.setMetricId(String.valueOf(metricResult.Id));
			metric.setLabel(metricResult == null ? 'n/a' : metricResult.Label__c);
			//Get Data
			metricData = GumutindoHelpers.getMetricData(sectionMetric.toLowerCase());
			if (metricData.Comment__c != null) {
				metric.setLabel(metricData.Comment__c);
			}
			metric.setMetricId(String.valueOf(metricData.Id));
			metric.setCurrentTarget(metricData.Projected_Value__c);
			metric.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
			metrics.add(metric);
		}
		return metrics;
	}

	public List <MetricDataWrapper> getGcceMetricsData() {

		if (allMetrics == null) {
			allMetrics = GumutindoHelpers.getAllMetrics();
		}
		String[] metricsInthisSection = new String[] {
			GumutindoHelpers.FARMERS_PURCHASING_SEEDLINGS_THROUGH_GCCE,
			GumutindoHelpers.FARMERS_PURCHASING_FERTILIZERS_THROUGH_GCCE,
			GumutindoHelpers.FARMERS_WHO_DELIVER_50_PERCENT_OF_HI_QUAL_COFFEE,
			GumutindoHelpers.FARMERS_WHO_ACCESS_AGRO_INPUT_LOANS_THROUGH_PS,
			GumutindoHelpers.PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PROCURE_INPUTS,
			GumutindoHelpers.PERCENTAGE_OF_PS_WHO_COLLECTIVELY_PAY_FOR_INPUTS,
			GumutindoHelpers.FARMERS_USING_ATLEAST_3_AGROC_PRACTICES,
			GumutindoHelpers.FARMERS_WHO_REPORT_SATISFACTION_WITH_GCCE_SERVICES
		};
		List <MetricDataWrapper> metrics = new List <MetricDataWrapper> ();

		M_E_Metric__c metricResult;
		M_E_Metric_Data__c metricData;

		//get total farmers reached
		//get the actual value
		//get the target
		for (String sectionMetric: metricsInthisSection) {
			MetricDataWrapper metric = new MetricDataWrapper();

			metricResult = allMetrics.get(sectionMetric.toLowerCase());
			System.debug('Metric result for ' + sectionMetric + ' is ' + metricResult);
			metric.setCurrentTarget(metricResult.Projected_Value__c);
			//metric.setMetricId(String.valueOf(metricResult.Id));
			metric.setLabel(metricResult.Label__c);
			//Get Data
			metricData = GumutindoHelpers.getMetricData(sectionMetric.toLowerCase());
			if (metricData.Comment__c != null) {
				metric.setLabel(metricData.Comment__c);
			}
			metric.setMetricId(String.valueOf(metricData.Id));
			metric.setCurrentTarget(metricData.Projected_Value__c);
			metric.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
			metrics.add(metric);
		}
		return metrics;
	}

	public List <MetricDataWrapper> getVslaServicesData() {

		if (allMetrics == null) {
			allMetrics = GumutindoHelpers.getAllMetrics();
		}
		String[] metricsInthisSection = new String[] {
			GumutindoHelpers.NUMBER_OF_REGISTERED_VSLAS,
			GumutindoHelpers.FARMERS_WHO_ACCESS_FINANCIAL_SERVICES_THROUGH_VSLAS,
			GumutindoHelpers.FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS,
			GumutindoHelpers.FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS,
			GumutindoHelpers.FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS
		};
		List <MetricDataWrapper> metrics = new List <MetricDataWrapper> ();

		M_E_Metric__c metricResult;
		M_E_Metric_Data__c metricData;

		//get total farmers reached
		//get the actual value
		//get the target
		for (String sectionMetric: metricsInthisSection) {
			MetricDataWrapper metric = new MetricDataWrapper();
			metricResult = allMetrics.get(sectionMetric.toLowerCase());
			System.debug('Metric result for ' + sectionMetric + ' is ' + metricResult);
			metric.setCurrentTarget(metricResult.Projected_Value__c);
			//metric.setMetricId(String.valueOf(metricResult.Id));
			metric.setLabel(metricResult.Label__c);

			//Get Data
			metricData = GumutindoHelpers.getMetricData(sectionMetric.toLowerCase());
			if (metricData.Comment__c != null) {
				metric.setLabel(metricData.Comment__c);
			}

			metric.setMetricId(String.valueOf(metricData.Id));
			metric.setCurrentTarget(metricData.Projected_Value__c);
			metric.setCurrentRealValue((Decimal) metricData.Manual_Value__c);
			metrics.add(metric);
		}
		return metrics;
	}

	public List <GumutindoHelpers.FinancialServicesUsageData> getFinancialServicesChartData() {
	    
		Map <String, M_E_Metric_Data__c> metricDataMap = getAllMetricDatas();
		List <GumutindoHelpers.FinancialServicesUsageData> data = new List <GumutindoHelpers.FinancialServicesUsageData> ();
		M_E_Metric_Data__c metricData = metricDataMap.get(
			GumutindoHelpers.FARMERS_WHO_ACCESS_MICRO_INSURANCE_FINANCIAL_SERVICES_THROUGH_VSLAS.toLowerCase());
		data.add(new GumutindoHelpers.FinancialServicesUsageData('MicroInsurance', metricData.Manual_Value__c));

		metricData = metricDataMap.get(GumutindoHelpers.FARMERS_WHO_ACCESS_SAVINGS_FINANCIAL_SERVICES_THROUGH_VSLAS.toLowerCase());
		data.add(new GumutindoHelpers.FinancialServicesUsageData('Savings', metricData.Manual_Value__c));

		metricData = metricDataMap.get(GumutindoHelpers.FARMERS_WHO_ACCESS_LOANING_FINANCIAL_SERVICES_THROUGH_VSLAS.toLowerCase());
		data.add(new GumutindoHelpers.FinancialServicesUsageData('Loaning', metricData.Manual_Value__c));

		return data;
	}

	//Loads primary societies
	public List <Gumutindo_Primary_Society__c> loadGumutindoPrimarySocieties() {
		List <Gumutindo_Primary_Society__c> primarySocieties = [
			SELECT 
				Id,
				Name, 
				Subcounty__r.Id, 
				Subcounty__r.District__r.Id
			FROM 
				Gumutindo_Primary_Society__c 
			ORDER BY 
				Name
		];

		List <String> districtIds = new List <String> ();
		List <String> subcountyIds = new List <String> ();

		for (Gumutindo_Primary_Society__c society: primarySocieties) {
			districtIds.add(society.Subcounty__r.District__r.Id);
			subcountyIds.add(society.Subcounty__r.Id);
		}
		//select districts by Ids
		//gumutindoDistricts = database.query('SELECT Id, Name, Latitude__c, Longitude__c from District__c where Id in:'+districtIds);
		//gumutindoSubCounties = database.query('SELECT Id, Name, Latitude__c, Longitude__c from Subcounty__c where Id in:'+subcountyIds);
		return primarySocieties;
	}

	public void setDistrictList(List <SelectOption> option) {
		this.districtList = option;
	}
	
	public List <SelectOption> getDistrictList() {
	    
		List <SelectOption> options = new List <SelectOption> ();
		District__c[] districts = database.query(SoqlHelpers.getDistricts(orgName));
		options.add(new SelectOption('', '-- In All Districts --'));

		//Add all districts to list
		for (District__c district: districts) {
			options.add(new SelectOption(district.Name, district.Name));
		}
		return options;
	}

	public void setSubcountiesList(List <SelectOption> option) {
		this.districtList = option;
	}
	
	public List <SelectOption> getSubcountiesList() {
	    
		List <SelectOption> options = new List <SelectOption> ();
		Subcounty__c[] subcounties = database.query(GumutindoHelpers.getSubcounties());
		options.add(new SelectOption('', '-- In All Subcounties --'));

		//Add all subcounties to list
		for (Subcounty__c subcounty: subcounties) {
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

	public Map <String, M_E_Metric_Data__c> getAllMetricDatas() {
		if (allMetricDatas == null) {
			allMetricDatas = GumutindoHelpers.getMetricDataMap();
		}
		return allMetricDatas;
	}

	public String getIsEditMode() {
		if (this.isEditMode) {
			return 'true';
		}
		return 'false';
	}

	public PageReference changeFilters() {
		PageReference resultPage = ApexPages.currentPage();
		resultPage.getParameters().put('subcounty', subcounty.Display_Name__c);
		resultPage.getParameters().put('district', district.Name);
		resultPage.getParameters().put('dateFrom', dummyObject.Start_Date__c == null ? '' : Datetime.newInstance(dummyObject.Start_Date__c.year(), 
			dummyObject.Start_Date__c.month(), dummyObject.Start_Date__c.day()).format('yyyy-MM-dd'));
		resultPage.getParameters().put('dateTo', dummyObject.End_Date__c == null ? '' : Datetime.newInstance(dummyObject.End_Date__c.year(), 
			dummyObject.End_Date__c.month(), dummyObject.End_Date__c.day()).format('yyyy-MM-dd'));
		resultPage.getParameters().put('sfdc.tabName', this.tabName);
		resultPage.setRedirect(true);
		return resultPage;
	}

	public List <Map_Parameter__c> getMaps() {
		List <Map_Parameter__c> mapList = new List <Map_Parameter__c> ();
		Map_Parameter__C mapparameter = new Map_Parameter__C();
		mapparameter.Keyword__c = 'Location of Gumutindo CKWs';
		mapparameter.Type_Of_sObject__c = 'Custom Class';
		mapparameter.Map_Marker_Source_Class__c = 'GumutindoHelpers.GumutindoCkwCoordinatesProvider';
		mapparameter.Zoom__c = 6;
		mapparameter.Latitude__c = '0.5167';
		mapparameter.Longitude__c = '32.5833';
		mapparameter.Title__c = 'Location of Gumutindo CKWs';

		mapList.add(mapparameter);
		return mapList;
	}
}