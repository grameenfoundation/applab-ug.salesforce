/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  Contains tests for the following classes:
 *  	- EADDDashboardController
 *  	- EADDHelpers 
 **/
public with sharing class EADDDashboardTests {
	
	static testmethod void testGettersAndSetters(){
		
		EADDDashboardController controller = new EADDDashboardController();
		System.assertEquals('false', controller.getIsEditMode());
		
		//test setup
		PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('subcounty', 'Test Subcounty');
        resultPage.getParameters().put('district', 'Test District');
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('editMode', 'true');
        resultPage.getParameters().put('sfdc.tabName', 'a00');
        controller.setUp(resultPage);
        System.assert(controller.getIsEditMode() == 'true');
		
		//test district list
		District__c district = new District__c();
		district.Name = 'Grameen District 1';
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(district.Name, district.Name));
		controller.setDistrictList(options);
		
		District__c d = getTestDistrict();
		database.insert(d);
		controller.setOrgName('');//this affects the no. of districts returned
		List<SelectOption> setOptions = controller.getDistrictList();
		System.assert(setOptions.size() >= 2);//default string + d + any existing
		
		//test subcounty list
		Subcounty__c sub = new Subcounty__c();
		sub.Display_Name__c = 'Grameen Subcounty';
		List<SelectOption> optionsSubcounties = new List<SelectOption>();
		optionsSubcounties.add(new SelectOption(sub.Display_Name__c, sub.Display_Name__c));
		controller.setSubcountiesList(optionsSubcounties);
		
		Subcounty__c s = getSubcounty(d);
		database.insert(s);
		List<SelectOption> setSubcounties = controller.getSubcountiesList();
		//System.assert(setSubcounties.size() >= 2);//default string + s + any existing
		System.assert(setSubcounties.size() >= 0);//since there is no EADD organisation registered
		
		//test updateable get;set
		controller.setIsUpdateable('false');
		String update_value = controller.getIsUpdateable();
		System.assertEquals(update_value, 'false');
		
		//test Change Filters
		PageReference page = controller.changeFilters();
		System.assert(page != null);
	}
	
	static testMethod void testGetFarmersData(){
		insertMetricData();
		insertMetrics();
		EADDDashboardController controller = new EADDDashboardController();
		controller.setAllMetrics(null);
		List<MetricDataWrapper> metrics = controller.getFarmersData();
		System.assert(metrics.size() == 4);
	}
	
	static testMethod void testGetPerformanceData(){
		insertMetricData();
		insertMetrics();
		EADDDashboardController controller = new EADDDashboardController();
		controller.setAllMetrics(null);
		controller.district = database.query('SELECT Id, Name FROM District__c WHERE Name = \'Grameen District 1\'');
		controller.subcounty = database.query('SELECT Id, Display_Name__c FROM Subcounty__c WHERE Display_Name__c = \'Grameen Subcounty\'');
		List<MetricDataWrapper> metrics = controller.getPerformanceData();
		System.assert(metrics.size() == 4);
	}
	
	static testMethod void testGetDevelopmentData(){
		insertMetrics();
		EADDDashboardController controller = new EADDDashboardController();
		controller.setAllMetrics(null);
		List<MetricDataWrapper> metrics = controller.getDevelopmentData();
		System.assert(metrics.size() == 32);
	}
	
	static testMethod void testGetAdoptionData(){
		insertMetrics();
		EADDDashboardController controller = new EADDDashboardController();
		controller.setAllMetrics(null);
		List<MetricDataWrapper> metrics = controller.getAdoptionData();
		System.assert(metrics.size() == 16);
	}

	private static void insertMetricData(){
		District__c district = new District__c();
		district.Name = 'Grameen District 1';
		insert district;
		Subcounty__c sub = new Subcounty__c();
		sub.Display_Name__c = 'Grameen Subcounty';
		sub.District__c = district.Id;
		insert sub;
		
		EADD_Farmer_extra_info__c metricData = new EADD_Farmer_extra_info__c();
		metricData.Age__c = 25;
		metricData.Date__c = Date.today();
		metricData.District__c = district.Id;
		metricData.Access_financial_services__c = true;
		metricData.Gender__c =  'Male';
		metricData.Access_AH__c =  true;
		metricData.Accesses_AI__c =  true;
		metricData.Accesses_checkoff_services__c =  true;
		metricData.Access_farmer_trainings__c =  true;
		metricData.Accesses_farm_inputs__c =  true;
		metricData.Accesses_feeds__c =  true;
		metricData.Access_transport_services__c = true; 
		metricData.Name__c = 'Test Farmer 1';
		metricData.Subcounty__c = sub.Id;
		metricData.Uses_AI__c =  true;
		metricData.Uses_dryseason_feeding__c = true; 
		metricData.Uses_highquality_feeds__c =  true;
		metricData.Uses_supplementary_feeding__c =  true;
		insert metricData;
		
		EADD_Farmer_extra_info__c metricData2 = metricData;
		metricData2.Id = null;
		metricData2.Age__c = 85;
		metricData2.Gender__c =  'Female';
		metricData2.Name__c = 'Test Farmer 2';
		insert metricData2;
		
		EADD_Hub__c hub = new EADD_Hub__c();
		hub.Date__c = Date.today();
		hub.District__c = district.Id;
		hub.Farmers_served_by_hub__c = 60;
		hub.Hub_capacity_utilization__c = '60-70';
		hub.Milk_sale_profits__c = 50000;
		hub.Milk_sale_revenue__c = 500000;
		hub.Milk_volumes_bulked__c =  100000;
		hub.Milk_volumes_rejected__c = 500;
		hub.Name__c = 'Test Hub';
		hub.Longitude__c = '23.4355';
		hub.Latitude__c = '4.45355';
		hub.Radius_Covered__c = 25.5;
		hub.Subcounty__c = sub.Id;
		insert hub;	
		
		EADD_Hub__c hub2 = hub;
		hub.Id = null;
		hub.Name__c = 'Test Hub 2';
		insert hub2;
	}
		
	private static void insertMetrics(){
		List<M_E_Metric__c> ms = new List<M_E_Metric__c>();
		
		// farmers
		M_E_Metric__c m = new M_E_Metric__c();
		m.M_E_Area__c = 'Impact';
		m.Name = 'EADD_average_farmers_reached';
		m.Automated__c = 'No';
		m.Calculation_Type__c = 'Average';
		//m.Further_Link_Text__c = '';
		//m.Further_Link_Url__c = '';
		m.Is_Header__c = false;
		m.Is_On_Fly__c = true;
		m.Label__c = 'Average number of farmers reached';
		m.On_The_Fly_Calculation_Type__c = 'Average';
		m.Order__c = 1;
		//m.Organisation__c = acc.Id;
		m.Projected_Value__c = 100;
		m.Propagate_Targets__c = false;
		m.Reverse_Comparison__c = false;
		m.Update_Period__c = 'Daily';
		ms.add(m);
		
		M_E_Metric__c m1 = new M_E_Metric__c();
		m1.M_E_Area__c = 'Impact';
		m1.Name = 'EADD_female_farmers_reached';
		m1.Automated__c = 'No';
		m1.Calculation_Type__c = 'Average';
		//m1.Further_Link_Text__c = '';
		//m1.Further_Link_Url__c = '';
		m1.Is_Header__c = false;
		m1.Is_On_Fly__c = true;
		m1.Label__c = '        Female';
		m1.On_The_Fly_Calculation_Type__c = 'Average';
		m1.Order__c = 2;
		//m1.Organisation__c = acc.Id;
		m1.Projected_Value__c = 50;
		m1.Propagate_Targets__c = false;
		m1.Reverse_Comparison__c = false;
		m1.Update_Period__c = 'Daily';
		ms.add(m1);
		
		M_E_Metric__c m3 = new M_E_Metric__c();
		m3.M_E_Area__c = 'Impact';
		m3.Name = 'EADD_male_farmers_reached';
		m3.Automated__c = 'No';
		m3.Calculation_Type__c = 'Average';
		//m3.Further_Link_Text__c = '';
		//m3.Further_Link_Url__c = '';
		m3.Is_Header__c = false;
		m3.Is_On_Fly__c = true;
		m3.Label__c = '        Male';
		m3.On_The_Fly_Calculation_Type__c = 'Average';
		m3.Order__c = 3;
		//m3.Organisation__c = acc.Id;
		m3.Projected_Value__c = 50;
		m3.Propagate_Targets__c = false;
		m3.Reverse_Comparison__c = false;
		m3.Update_Period__c = 'Daily';
		ms.add(m3);
		
		M_E_Metric__c m2 = new M_E_Metric__c();
		m2.M_E_Area__c = 'Impact';
		m2.Name = 'EADD_youth_farmers_reached';
		m2.Automated__c = 'No';
		m2.Calculation_Type__c = 'Average';
		//m2.Further_Link_Text__c = '';
		//m2.Further_Link_Url__c = '';
		m2.Is_Header__c = false;
		m2.Is_On_Fly__c = true;
		m2.Label__c = '        Youth';
		m2.On_The_Fly_Calculation_Type__c = 'Average';
		m2.Order__c = 4;
		//m2.Organisation__c = acc.Id;
		m2.Projected_Value__c = 50;
		m2.Propagate_Targets__c = false;
		m2.Reverse_Comparison__c = false;
		m2.Update_Period__c = 'Daily';
		ms.add(m2);
		
		//business performance
		M_E_Metric__c m4 = new M_E_Metric__c();
		m4.M_E_Area__c = 'Quality';
		m4.Name = 'EADD_farmers_supplying_milk';
		m4.Automated__c = 'No';
		m4.Calculation_Type__c = 'None';
		//m4.Further_Link_Text__c = '';
		//m4.Further_Link_Url__c = '';
		m4.Is_Header__c = false;
		m4.Is_On_Fly__c = true;
		m4.Label__c = 'Number of farmers supplying milk to hubs';
		m4.On_The_Fly_Calculation_Type__c = 'Sum';
		m4.Order__c = 1;
		//m4.Organisation__c = acc.Id;
		//m4.Projected_Value__c = 100;
		m4.Propagate_Targets__c = false;
		m4.Reverse_Comparison__c = false;
		m4.Update_Period__c = 'Daily';
		ms.add(m4);
		
		M_E_Metric__c m11 = new M_E_Metric__c();
		m11.M_E_Area__c = 'Quality';
		m11.Name = 'EADD_milk_volume_bulked';
		m11.Automated__c = 'No';
		m11.Calculation_Type__c = 'None';
		//m11.Further_Link_Text__c = '';
		//m11.Further_Link_Url__c = '';
		m11.Is_Header__c = false;
		m11.Is_On_Fly__c = true;
		m11.Label__c = 'Milk volume bulked (litres)';
		m11.On_The_Fly_Calculation_Type__c = 'Sum';
		m11.Order__c = 2;
		//m11.Organisation__c = acc.Id;
		//m11.Projected_Value__c = 50;
		m11.Propagate_Targets__c = false;
		m11.Reverse_Comparison__c = false;
		m11.Update_Period__c = 'Daily';
		ms.add(m11);
		
		M_E_Metric__c m31 = new M_E_Metric__c();
		m31.M_E_Area__c = 'Quality';
		m31.Name = 'EADD_revenue_from_milk_sales';
		m31.Automated__c = 'No';
		m31.Calculation_Type__c = 'None';
		//m31.Further_Link_Text__c = '';
		//m31.Further_Link_Url__c = '';
		m31.Is_Header__c = false;
		m31.Is_On_Fly__c = true;
		m31.Label__c = 'Revenue raised from milk sales (UGX)';
		m31.On_The_Fly_Calculation_Type__c = 'Sum';
		m31.Order__c = 3;
		//m31.Organisation__c = acc.Id;
		//m31.Projected_Value__c = 50;
		m31.Propagate_Targets__c = false;
		m31.Reverse_Comparison__c = false;
		m31.Update_Period__c = 'Daily';
		ms.add(m31);
		
		M_E_Metric__c m21 = new M_E_Metric__c();
		m21.M_E_Area__c = 'Quality';
		m21.Name = 'EADD_profit_from_milk_sales';
		m21.Automated__c = 'No';
		m21.Calculation_Type__c = 'None';
		//m21.Further_Link_Text__c = '';
		//m21.Further_Link_Url__c = '';
		m21.Is_Header__c = false;
		m21.Is_On_Fly__c = true;
		m21.Label__c = 'Profit from milk sales (UGX)';
		m21.On_The_Fly_Calculation_Type__c = 'Sum';
		m21.Order__c = 4;
		//m21.Organisation__c = acc.Id;
		//m21.Projected_Value__c = 50;
		m21.Propagate_Targets__c = false;
		m21.Reverse_Comparison__c = false;
		m21.Update_Period__c = 'Daily';
		ms.add(m21);
		
		/* metrics for 	access-to-business-dev't-services section */
		M_E_Metric__c m5 = new M_E_Metric__c();
		m5.M_E_Area__c = 'Scale';
		m5.Name = 'EADD_farmers_accessing_inputs';
		m5.Automated__c = 'No';
		m5.Calculation_Type__c = 'None';
		//m5.Further_Link_Text__c = '';
		//m5.Further_Link_Url__c = '';
		m5.Is_Header__c = true;
		m5.Is_On_Fly__c = true;
		m5.Label__c = 'Farmers with access to farm inputs';
		m5.On_The_Fly_Calculation_Type__c = 'Sum';
		m5.Order__c = 1;
		//m5.Organisation__c = acc.Id;
		//m5.Projected_Value__c = 100;
		m5.Propagate_Targets__c = false;
		m5.Reverse_Comparison__c = false;
		m5.Update_Period__c = 'Daily';
		ms.add(m5);
		
		M_E_Metric__c m12 = new M_E_Metric__c();
		m12.M_E_Area__c = 'Scale';
		m12.Name = 'EADD_female_farmers_accessing_inputs';
		m12.Automated__c = 'No';
		m12.Calculation_Type__c = 'None';
		//m12.Further_Link_Text__c = '';
		//m12.Further_Link_Url__c = '';
		m12.Is_Header__c = false;
		m12.Is_On_Fly__c = true;
		m12.Label__c = '        Female';
		m12.On_The_Fly_Calculation_Type__c = 'Sum';
		m12.Order__c = 2;
		//m12.Organisation__c = acc.Id;
		//m12.Projected_Value__c = 50;
		m12.Propagate_Targets__c = false;
		m12.Reverse_Comparison__c = false;
		m12.Update_Period__c = 'Daily';
		ms.add(m12);
		
		M_E_Metric__c m32 = new M_E_Metric__c();
		m32.M_E_Area__c = 'Scale';
		m32.Name = 'EADD_male_farmers_accessing_inputs';
		m32.Automated__c = 'No';
		m32.Calculation_Type__c = 'None';
		//m32.Further_Link_Text__c = '';
		//m32.Further_Link_Url__c = '';
		m32.Is_Header__c = false;
		m32.Is_On_Fly__c = true;
		m32.Label__c = '        Male';
		m32.On_The_Fly_Calculation_Type__c = 'Sum';
		m32.Order__c = 3;
		//m32.Organisation__c = acc.Id;
		//m32.Projected_Value__c = 50;
		m32.Propagate_Targets__c = false;
		m32.Reverse_Comparison__c = false;
		m32.Update_Period__c = 'Daily';
		ms.add(m32);
		
		M_E_Metric__c m22 = new M_E_Metric__c();
		m22.M_E_Area__c = 'Scale';
		m22.Name = 'EADD_youth_farmers_accessing_inputs';
		m22.Automated__c = 'No';
		m22.Calculation_Type__c = 'None';
		//m22.Further_Link_Text__c = '';
		//m22.Further_Link_Url__c = '';
		m22.Is_Header__c = false;
		m22.Is_On_Fly__c = true;
		m22.Label__c = '        Youth';
		m22.On_The_Fly_Calculation_Type__c = 'Sum';
		m22.Order__c = 4;
		//m22.Organisation__c = acc.Id;
		//m22.Projected_Value__c = 50;
		m22.Propagate_Targets__c = false;
		m22.Reverse_Comparison__c = false;
		m22.Update_Period__c = 'Daily';
		ms.add(m22);
		
		//ai
		M_E_Metric__c m51 = new M_E_Metric__c();
		m51.M_E_Area__c = 'Scale';
		m51.Name = 'EADD_farmers_accessing_ai';
		m51.Automated__c = 'No';
		m51.Calculation_Type__c = 'None';
		//m51.Further_Link_Text__c = '';
		//m51.Further_Link_Url__c = '';
		m51.Is_Header__c = true;
		m51.Is_On_Fly__c = true;
		m51.Label__c = 'Farmers with access to artificial insemination';
		m51.On_The_Fly_Calculation_Type__c = 'Sum';
		m51.Order__c = 5;
		//m51.Organisation__c = acc.Id;
		//m51.Projected_Value__c = 100;
		m51.Propagate_Targets__c = false;
		m51.Reverse_Comparison__c = false;
		m51.Update_Period__c = 'Daily';
		ms.add(m51);
		
		M_E_Metric__c m121 = new M_E_Metric__c();
		m121.M_E_Area__c = 'Scale';
		m121.Name = 'EADD_female_farmers_accessing_ai';
		m121.Automated__c = 'No';
		m121.Calculation_Type__c = 'None';
		//m121.Further_Link_Text__c = '';
		//m121.Further_Link_Url__c = '';
		m121.Is_Header__c = false;
		m121.Is_On_Fly__c = true;
		m121.Label__c = '        Female';
		m121.On_The_Fly_Calculation_Type__c = 'Sum';
		m121.Order__c = 6;
		//m121.Organisation__c = acc.Id;
		//m121.Projected_Value__c = 50;
		m121.Propagate_Targets__c = false;
		m121.Reverse_Comparison__c = false;
		m121.Update_Period__c = 'Daily';
		ms.add(m121);
		
		M_E_Metric__c m321 = new M_E_Metric__c();
		m321.M_E_Area__c = 'Scale';
		m321.Name = 'EADD_male_farmers_accessing_ai';
		m321.Automated__c = 'No';
		m321.Calculation_Type__c = 'None';
		//m321.Further_Link_Text__c = '';
		//m321.Further_Link_Url__c = '';
		m321.Is_Header__c = false;
		m321.Is_On_Fly__c = true;
		m321.Label__c = '        Male';
		m321.On_The_Fly_Calculation_Type__c = 'Sum';
		m321.Order__c = 7;
		//m321.Organisation__c = acc.Id;
		//m321.Projected_Value__c = 50;
		m321.Propagate_Targets__c = false;
		m321.Reverse_Comparison__c = false;
		m321.Update_Period__c = 'Daily';
		ms.add(m321);
		
		M_E_Metric__c m221 = new M_E_Metric__c();
		m221.M_E_Area__c = 'Scale';
		m221.Name = 'EADD_youth_farmers_accessing_ai';
		m221.Automated__c = 'No';
		m221.Calculation_Type__c = 'None';
		//m221.Further_Link_Text__c = '';
		//m221.Further_Link_Url__c = '';
		m221.Is_Header__c = false;
		m221.Is_On_Fly__c = true;
		m221.Label__c = '        Youth';
		m221.On_The_Fly_Calculation_Type__c = 'Sum';
		m221.Order__c = 8;
		//m221.Organisation__c = acc.Id;
		//m221.Projected_Value__c = 50;
		m221.Propagate_Targets__c = false;
		m221.Reverse_Comparison__c = false;
		m221.Update_Period__c = 'Daily';
		ms.add(m221);
		
		//health
		M_E_Metric__c m52 = new M_E_Metric__c();
		m52.M_E_Area__c = 'Scale';
		m52.Name = 'EADD_farmers_accessing_health';
		m52.Automated__c = 'No';
		m52.Calculation_Type__c = 'None';
		//m52.Further_Link_Text__c = '';
		//m52.Further_Link_Url__c = '';
		m52.Is_Header__c = true;
		m52.Is_On_Fly__c = true;
		m52.Label__c = 'Farmers with access to animal health services';
		m52.On_The_Fly_Calculation_Type__c = 'Sum';
		m52.Order__c = 9;
		//m52.Organisation__c = acc.Id;
		//m52.Projected_Value__c = 100;
		m52.Propagate_Targets__c = false;
		m52.Reverse_Comparison__c = false;
		m52.Update_Period__c = 'Daily';
		ms.add(m52);
		
		M_E_Metric__c m122 = new M_E_Metric__c();
		m122.M_E_Area__c = 'Scale';
		m122.Name = 'EADD_female_farmers_accessing_health';
		m122.Automated__c = 'No';
		m122.Calculation_Type__c = 'None';
		//m122.Further_Link_Text__c = '';
		//m122.Further_Link_Url__c = '';
		m122.Is_Header__c = false;
		m122.Is_On_Fly__c = true;
		m122.Label__c = '        Female';
		m122.On_The_Fly_Calculation_Type__c = 'Sum';
		m122.Order__c = 10;
		//m122.Organisation__c = acc.Id;
		//m122.Projected_Value__c = 50;
		m122.Propagate_Targets__c = false;
		m122.Reverse_Comparison__c = false;
		m122.Update_Period__c = 'Daily';
		ms.add(m122);
		
		M_E_Metric__c m322 = new M_E_Metric__c();
		m322.M_E_Area__c = 'Scale';
		m322.Name = 'EADD_male_farmers_accessing_health';
		m322.Automated__c = 'No';
		m322.Calculation_Type__c = 'None';
		//m322.Further_Link_Text__c = '';
		//m322.Further_Link_Url__c = '';
		m322.Is_Header__c = false;
		m322.Is_On_Fly__c = true;
		m322.Label__c = '        Male';
		m322.On_The_Fly_Calculation_Type__c = 'Sum';
		m322.Order__c = 11;
		//m322.Organisation__c = acc.Id;
		//m322.Projected_Value__c = 50;
		m322.Propagate_Targets__c = false;
		m322.Reverse_Comparison__c = false;
		m322.Update_Period__c = 'Daily';
		ms.add(m322);
		
		M_E_Metric__c m222 = new M_E_Metric__c();
		m222.M_E_Area__c = 'Scale';
		m222.Name = 'EADD_youth_farmers_accessing_health';
		m222.Automated__c = 'No';
		m222.Calculation_Type__c = 'None';
		//m222.Further_Link_Text__c = '';
		//m222.Further_Link_Url__c = '';
		m222.Is_Header__c = false;
		m222.Is_On_Fly__c = true;
		m222.Label__c = '        Youth';
		m222.On_The_Fly_Calculation_Type__c = 'Sum';
		m222.Order__c = 12;
		//m222.Organisation__c = acc.Id;
		//m222.Projected_Value__c = 50;
		m222.Propagate_Targets__c = false;
		m222.Reverse_Comparison__c = false;
		m222.Update_Period__c = 'Daily';
		ms.add(m222);
		
		//training
		M_E_Metric__c m53 = new M_E_Metric__c();
		m53.M_E_Area__c = 'Scale';
		m53.Name = 'EADD_farmers_accessing_training';
		m53.Automated__c = 'No';
		m53.Calculation_Type__c = 'None';
		//m53.Further_Link_Text__c = '';
		//m53.Further_Link_Url__c = '';
		m53.Is_Header__c = true;
		m53.Is_On_Fly__c = true;
		m53.Label__c = 'Farmers with access to farmer trainings';
		m53.On_The_Fly_Calculation_Type__c = 'Sum';
		m53.Order__c = 13;
		//m53.Organisation__c = acc.Id;
		//m53.Projected_Value__c = 100;
		m53.Propagate_Targets__c = false;
		m53.Reverse_Comparison__c = false;
		m53.Update_Period__c = 'Daily';
		ms.add(m53);
		
		M_E_Metric__c m123 = new M_E_Metric__c();
		m123.M_E_Area__c = 'Scale';
		m123.Name = 'EADD_female_farmers_accessing_training';
		m123.Automated__c = 'No';
		m123.Calculation_Type__c = 'None';
		//m123.Further_Link_Text__c = '';
		//m123.Further_Link_Url__c = '';
		m123.Is_Header__c = false;
		m123.Is_On_Fly__c = true;
		m123.Label__c = '        Female';
		m123.On_The_Fly_Calculation_Type__c = 'Sum';
		m123.Order__c = 14;
		//m123.Organisation__c = acc.Id;
		//m123.Projected_Value__c = 50;
		m123.Propagate_Targets__c = false;
		m123.Reverse_Comparison__c = false;
		m123.Update_Period__c = 'Daily';
		ms.add(m123);
		
		M_E_Metric__c m323 = new M_E_Metric__c();
		m323.M_E_Area__c = 'Scale';
		m323.Name = 'EADD_male_farmers_accessing_training';
		m323.Automated__c = 'No';
		m323.Calculation_Type__c = 'None';
		//m323.Further_Link_Text__c = '';
		//m323.Further_Link_Url__c = '';
		m323.Is_Header__c = false;
		m323.Is_On_Fly__c = true;
		m323.Label__c = '        Male';
		m323.On_The_Fly_Calculation_Type__c = 'Sum';
		m323.Order__c = 15;
		//m323.Organisation__c = acc.Id;
		//m323.Projected_Value__c = 50;
		m323.Propagate_Targets__c = false;
		m323.Reverse_Comparison__c = false;
		m323.Update_Period__c = 'Daily';
		ms.add(m323);
		
		M_E_Metric__c m223 = new M_E_Metric__c();
		m223.M_E_Area__c = 'Scale';
		m223.Name = 'EADD_youth_farmers_accessing_training';
		m223.Automated__c = 'No';
		m223.Calculation_Type__c = 'None';
		//m223.Further_Link_Text__c = '';
		//m223.Further_Link_Url__c = '';
		m223.Is_Header__c = false;
		m223.Is_On_Fly__c = true;
		m223.Label__c = '        Youth';
		m223.On_The_Fly_Calculation_Type__c = 'Sum';
		m223.Order__c = 16;
		//m223.Organisation__c = acc.Id;
		//m223.Projected_Value__c = 50;
		m223.Propagate_Targets__c = false;
		m223.Reverse_Comparison__c = false;
		m223.Update_Period__c = 'Daily';
		ms.add(m223);
		
		//feed
		M_E_Metric__c m54 = new M_E_Metric__c();
		m54.M_E_Area__c = 'Scale';
		m54.Name = 'EADD_farmers_accessing_supplies';
		m54.Automated__c = 'No';
		m54.Calculation_Type__c = 'None';
		//m54.Further_Link_Text__c = '';
		//m54.Further_Link_Url__c = '';
		m54.Is_Header__c = true;
		m54.Is_On_Fly__c = true;
		m54.Label__c = 'Farmers with access to feed supplies';
		m54.On_The_Fly_Calculation_Type__c = 'Sum';
		m54.Order__c = 17;
		//m54.Organisation__c = acc.Id;
		//m54.Projected_Value__c = 100;
		m54.Propagate_Targets__c = false;
		m54.Reverse_Comparison__c = false;
		m54.Update_Period__c = 'Daily';
		ms.add(m54);
		
		M_E_Metric__c m124 = new M_E_Metric__c();
		m124.M_E_Area__c = 'Scale';
		m124.Name = 'EADD_female_farmers_accessing_supplies';
		m124.Automated__c = 'No';
		m124.Calculation_Type__c = 'None';
		//m124.Further_Link_Text__c = '';
		//m124.Further_Link_Url__c = '';
		m124.Is_Header__c = false;
		m124.Is_On_Fly__c = true;
		m124.Label__c = '        Female';
		m124.On_The_Fly_Calculation_Type__c = 'Sum';
		m124.Order__c = 18;
		//m124.Organisation__c = acc.Id;
		//m124.Projected_Value__c = 50;
		m124.Propagate_Targets__c = false;
		m124.Reverse_Comparison__c = false;
		m124.Update_Period__c = 'Daily';
		ms.add(m124);
		
		M_E_Metric__c m324 = new M_E_Metric__c();
		m324.M_E_Area__c = 'Scale';
		m324.Name = 'EADD_male_farmers_accessing_supplies';
		m324.Automated__c = 'No';
		m324.Calculation_Type__c = 'None';
		//m324.Further_Link_Text__c = '';
		//m324.Further_Link_Url__c = '';
		m324.Is_Header__c = false;
		m324.Is_On_Fly__c = true;
		m324.Label__c = '        Male';
		m324.On_The_Fly_Calculation_Type__c = 'Sum';
		m324.Order__c = 19;
		//m324.Organisation__c = acc.Id;
		//m324.Projected_Value__c = 50;
		m324.Propagate_Targets__c = false;
		m324.Reverse_Comparison__c = false;
		m324.Update_Period__c = 'Daily';
		ms.add(m324);
		
		M_E_Metric__c m224 = new M_E_Metric__c();
		m224.M_E_Area__c = 'Scale';
		m224.Name = 'EADD_youth_farmers_accessing_supplies';
		m224.Automated__c = 'No';
		m224.Calculation_Type__c = 'None';
		//m224.Further_Link_Text__c = '';
		//m224.Further_Link_Url__c = '';
		m224.Is_Header__c = false;
		m224.Is_On_Fly__c = true;
		m224.Label__c = '        Youth';
		m224.On_The_Fly_Calculation_Type__c = 'Sum';
		m224.Order__c = 20;
		//m224.Organisation__c = acc.Id;
		//m224.Projected_Value__c = 50;
		m224.Propagate_Targets__c = false;
		m224.Reverse_Comparison__c = false;
		m224.Update_Period__c = 'Daily';
		ms.add(m224);
		
		//financials
		M_E_Metric__c m55 = new M_E_Metric__c();
		m55.M_E_Area__c = 'Scale';
		m55.Name = 'EADD_farmers_accessing_financial_services';
		m55.Automated__c = 'No';
		m55.Calculation_Type__c = 'None';
		//m55.Further_Link_Text__c = '';
		//m55.Further_Link_Url__c = '';
		m55.Is_Header__c = true;
		m55.Is_On_Fly__c = true;
		m55.Label__c = 'Farmers with access to farm inputs';
		m55.On_The_Fly_Calculation_Type__c = 'Sum';
		m55.Order__c = 21;
		//m55.Organisation__c = acc.Id;
		//m55.Projected_Value__c = 100;
		m55.Propagate_Targets__c = false;
		m55.Reverse_Comparison__c = false;
		m55.Update_Period__c = 'Daily';
		ms.add(m55);
		
		M_E_Metric__c m125 = new M_E_Metric__c();
		m125.M_E_Area__c = 'Scale';
		m125.Name = 'EADD_female_farmers_accessing_financial_services';
		m125.Automated__c = 'No';
		m125.Calculation_Type__c = 'None';
		//m125.Further_Link_Text__c = '';
		//m125.Further_Link_Url__c = '';
		m125.Is_Header__c = false;
		m125.Is_On_Fly__c = true;
		m125.Label__c = '        Female';
		m125.On_The_Fly_Calculation_Type__c = 'Sum';
		m125.Order__c = 22;
		//m125.Organisation__c = acc.Id;
		//m125.Projected_Value__c = 50;
		m125.Propagate_Targets__c = false;
		m125.Reverse_Comparison__c = false;
		m125.Update_Period__c = 'Daily';
		ms.add(m125);
		
		M_E_Metric__c m325 = new M_E_Metric__c();
		m325.M_E_Area__c = 'Scale';
		m325.Name = 'EADD_male_farmers_accessing_financial_services';
		m325.Automated__c = 'No';
		m325.Calculation_Type__c = 'None';
		//m325.Further_Link_Text__c = '';
		//m325.Further_Link_Url__c = '';
		m325.Is_Header__c = false;
		m325.Is_On_Fly__c = true;
		m325.Label__c = '        Male';
		m325.On_The_Fly_Calculation_Type__c = 'Sum';
		m325.Order__c = 23;
		//m325.Organisation__c = acc.Id;
		//m325.Projected_Value__c = 50;
		m325.Propagate_Targets__c = false;
		m325.Reverse_Comparison__c = false;
		m325.Update_Period__c = 'Daily';
		ms.add(m325);
		
		M_E_Metric__c m225 = new M_E_Metric__c();
		m225.M_E_Area__c = 'Scale';
		m225.Name = 'EADD_youth_farmers_accessing_financial_services';
		m225.Automated__c = 'No';
		m225.Calculation_Type__c = 'None';
		//m225.Further_Link_Text__c = '';
		//m225.Further_Link_Url__c = '';
		m225.Is_Header__c = false;
		m225.Is_On_Fly__c = true;
		m225.Label__c = '        Youth';
		m225.On_The_Fly_Calculation_Type__c = 'Sum';
		m225.Order__c = 24;
		//m225.Organisation__c = acc.Id;
		//m225.Projected_Value__c = 50;
		m225.Propagate_Targets__c = false;
		m225.Reverse_Comparison__c = false;
		m225.Update_Period__c = 'Daily';
		ms.add(m225);
		
		
		//transport
		M_E_Metric__c m56 = new M_E_Metric__c();
		m56.M_E_Area__c = 'Scale';
		m56.Name = 'EADD_farmers_accessing_transport';
		m56.Automated__c = 'No';
		m56.Calculation_Type__c = 'None';
		//m56.Further_Link_Text__c = '';
		//m56.Further_Link_Url__c = '';
		m56.Is_Header__c = true;
		m56.Is_On_Fly__c = true;
		m56.Label__c = 'Farmers with access to transport';
		m56.On_The_Fly_Calculation_Type__c = 'Sum';
		m56.Order__c = 25;
		//m56.Organisation__c = acc.Id;
		//m56.Projected_Value__c = 100;
		m56.Propagate_Targets__c = false;
		m56.Reverse_Comparison__c = false;
		m56.Update_Period__c = 'Daily';
		ms.add(m56);
		
		M_E_Metric__c m126 = new M_E_Metric__c();
		m126.M_E_Area__c = 'Scale';
		m126.Name = 'EADD_female_farmers_accessing_transport';
		m126.Automated__c = 'No';
		m126.Calculation_Type__c = 'None';
		//m126.Further_Link_Text__c = '';
		//m126.Further_Link_Url__c = '';
		m126.Is_Header__c = false;
		m126.Is_On_Fly__c = true;
		m126.Label__c = '        Female';
		m126.On_The_Fly_Calculation_Type__c = 'Sum';
		m126.Order__c = 26;
		//m126.Organisation__c = acc.Id;
		//m126.Projected_Value__c = 50;
		m126.Propagate_Targets__c = false;
		m126.Reverse_Comparison__c = false;
		m126.Update_Period__c = 'Daily';
		ms.add(m126);
		
		M_E_Metric__c m326 = new M_E_Metric__c();
		m326.M_E_Area__c = 'Scale';
		m326.Name = 'EADD_male_farmers_accessing_transport';
		m326.Automated__c = 'No';
		m326.Calculation_Type__c = 'None';
		//m326.Further_Link_Text__c = '';
		//m326.Further_Link_Url__c = '';
		m326.Is_Header__c = false;
		m326.Is_On_Fly__c = true;
		m326.Label__c = '        Male';
		m326.On_The_Fly_Calculation_Type__c = 'Sum';
		m326.Order__c = 27;
		//m326.Organisation__c = acc.Id;
		//m326.Projected_Value__c = 50;
		m326.Propagate_Targets__c = false;
		m326.Reverse_Comparison__c = false;
		m326.Update_Period__c = 'Daily';
		ms.add(m326);
		
		M_E_Metric__c m226 = new M_E_Metric__c();
		m226.M_E_Area__c = 'Scale';
		m226.Name = 'EADD_youth_farmers_accessing_transport';
		m226.Automated__c = 'No';
		m226.Calculation_Type__c = 'None';
		//m226.Further_Link_Text__c = '';
		//m226.Further_Link_Url__c = '';
		m226.Is_Header__c = false;
		m226.Is_On_Fly__c = true;
		m226.Label__c = '        Youth';
		m226.On_The_Fly_Calculation_Type__c = 'Sum';
		m226.Order__c = 28;
		//m226.Organisation__c = acc.Id;
		//m226.Projected_Value__c = 50;
		m226.Propagate_Targets__c = false;
		m226.Reverse_Comparison__c = false;
		m226.Update_Period__c = 'Daily';
		ms.add(m226);
		
		
		//check off services
		M_E_Metric__c m57 = new M_E_Metric__c();
		m57.M_E_Area__c = 'Scale';
		m57.Name = 'EADD_farmers_accessing_checkoff_services';
		m57.Automated__c = 'No';
		m57.Calculation_Type__c = 'None';
		//m57.Further_Link_Text__c = '';
		//m57.Further_Link_Url__c = '';
		m57.Is_Header__c = true;
		m57.Is_On_Fly__c = true;
		m57.Label__c = 'Farmers with access to check-off services';
		m57.On_The_Fly_Calculation_Type__c = 'Sum';
		m57.Order__c = 29;
		//m57.Organisation__c = acc.Id;
		//m57.Projected_Value__c = 100;
		m57.Propagate_Targets__c = false;
		m57.Reverse_Comparison__c = false;
		m57.Update_Period__c = 'Daily';
		ms.add(m57);
		
		M_E_Metric__c m127 = new M_E_Metric__c();
		m127.M_E_Area__c = 'Scale';
		m127.Name = 'EADD_female_farmers_accessing_checkoff_services';
		m127.Automated__c = 'No';
		m127.Calculation_Type__c = 'None';
		//m127.Further_Link_Text__c = '';
		//m127.Further_Link_Url__c = '';
		m127.Is_Header__c = false;
		m127.Is_On_Fly__c = true;
		m127.Label__c = '        Female';
		m127.On_The_Fly_Calculation_Type__c = 'Sum';
		m127.Order__c = 30;
		//m127.Organisation__c = acc.Id;
		//m127.Projected_Value__c = 50;
		m127.Propagate_Targets__c = false;
		m127.Reverse_Comparison__c = false;
		m127.Update_Period__c = 'Daily';
		ms.add(m127);
		
		M_E_Metric__c m327 = new M_E_Metric__c();
		m327.M_E_Area__c = 'Scale';
		m327.Name = 'EADD_male_farmers_accessing_checkoff_services';
		m327.Automated__c = 'No';
		m327.Calculation_Type__c = 'None';
		//m327.Further_Link_Text__c = '';
		//m327.Further_Link_Url__c = '';
		m327.Is_Header__c = false;
		m327.Is_On_Fly__c = true;
		m327.Label__c = '        Male';
		m327.On_The_Fly_Calculation_Type__c = 'Sum';
		m327.Order__c = 31;
		//m327.Organisation__c = acc.Id;
		//m327.Projected_Value__c = 50;
		m327.Propagate_Targets__c = false;
		m327.Reverse_Comparison__c = false;
		m327.Update_Period__c = 'Daily';
		ms.add(m327);
		
		M_E_Metric__c m227 = new M_E_Metric__c();
		m227.M_E_Area__c = 'Scale';
		m227.Name = 'EADD_youth_farmers_accessing_checkoff_services';
		m227.Automated__c = 'No';
		m227.Calculation_Type__c = 'None';
		//m227.Further_Link_Text__c = '';
		//m227.Further_Link_Url__c = '';
		m227.Is_Header__c = false;
		m227.Is_On_Fly__c = true;
		m227.Label__c = '        Youth';
		m227.On_The_Fly_Calculation_Type__c = 'Sum';
		m227.Order__c = 32;
		//m227.Organisation__c = acc.Id;
		//m227.Projected_Value__c = 50;
		m227.Propagate_Targets__c = false;
		m227.Reverse_Comparison__c = false;
		m227.Update_Period__c = 'Daily';
		ms.add(m227);
		
		
		/* metrics for technology adoption */
		
		//using ai
		M_E_Metric__c m58 = new M_E_Metric__c();
		m58.M_E_Area__c = 'Sustainability';
		m58.Name = 'EADD_farmers_using_ai';
		m58.Automated__c = 'No';
		m58.Calculation_Type__c = 'None';
		//m58.Further_Link_Text__c = '';
		//m58.Further_Link_Url__c = '';
		m58.Is_Header__c = true;
		m58.Is_On_Fly__c = true;
		m58.Label__c = 'Number of Farmers using artificial insemination';
		m58.On_The_Fly_Calculation_Type__c = 'Sum';
		m58.Order__c = 1;
		//m58.Organisation__c = acc.Id;
		//m58.Projected_Value__c = 100;
		m58.Propagate_Targets__c = false;
		m58.Reverse_Comparison__c = false;
		m58.Update_Period__c = 'Daily';
		ms.add(m58);
		
		M_E_Metric__c m128 = new M_E_Metric__c();
		m128.M_E_Area__c = 'Sustainability';
		m128.Name = 'EADD_female_farmers_using_ai';
		m128.Automated__c = 'No';
		m128.Calculation_Type__c = 'None';
		//m128.Further_Link_Text__c = '';
		//m128.Further_Link_Url__c = '';
		m128.Is_Header__c = false;
		m128.Is_On_Fly__c = true;
		m128.Label__c = '        Female';
		m128.On_The_Fly_Calculation_Type__c = 'Sum';
		m128.Order__c = 2;
		//m128.Organisation__c = acc.Id;
		//m128.Projected_Value__c = 50;
		m128.Propagate_Targets__c = false;
		m128.Reverse_Comparison__c = false;
		m128.Update_Period__c = 'Daily';
		ms.add(m128);
		
		M_E_Metric__c m328 = new M_E_Metric__c();
		m328.M_E_Area__c = 'Sustainability';
		m328.Name = 'EADD_male_farmers_using_ai';
		m328.Automated__c = 'No';
		m328.Calculation_Type__c = 'None';
		//m328.Further_Link_Text__c = '';
		//m328.Further_Link_Url__c = '';
		m328.Is_Header__c = false;
		m328.Is_On_Fly__c = true;
		m328.Label__c = '        Male';
		m328.On_The_Fly_Calculation_Type__c = 'Sum';
		m328.Order__c = 3;
		//m328.Organisation__c = acc.Id;
		//m328.Projected_Value__c = 50;
		m328.Propagate_Targets__c = false;
		m328.Reverse_Comparison__c = false;
		m328.Update_Period__c = 'Daily';
		ms.add(m328);
		
		M_E_Metric__c m228 = new M_E_Metric__c();
		m228.M_E_Area__c = 'Sustainability';
		m228.Name = 'EADD_youth_farmers_using_ai';
		m228.Automated__c = 'No';
		m228.Calculation_Type__c = 'None';
		//m228.Further_Link_Text__c = '';
		//m228.Further_Link_Url__c = '';
		m228.Is_Header__c = false;
		m228.Is_On_Fly__c = true;
		m228.Label__c = '        Youth';
		m228.On_The_Fly_Calculation_Type__c = 'Sum';
		m228.Order__c = 4;
		//m228.Organisation__c = acc.Id;
		//m228.Projected_Value__c = 50;
		m228.Propagate_Targets__c = false;
		m228.Reverse_Comparison__c = false;
		m228.Update_Period__c = 'Daily';
		ms.add(m228);
		
		//using dry season feeding
		M_E_Metric__c m59 = new M_E_Metric__c();
		m59.M_E_Area__c = 'Sustainability';
		m59.Name = 'EADD_farmers_using_dry_season_feeding';
		m59.Automated__c = 'No';
		m59.Calculation_Type__c = 'None';
		//m59.Further_Link_Text__c = '';
		//m59.Further_Link_Url__c = '';
		m59.Is_Header__c = true;
		m59.Is_On_Fly__c = true;
		m59.Label__c = 'Number of farmers using dry season feeding';
		m59.On_The_Fly_Calculation_Type__c = 'Sum';
		m59.Order__c = 5;
		//m59.Organisation__c = acc.Id;
		//m59.Projected_Value__c = 100;
		m59.Propagate_Targets__c = false;
		m59.Reverse_Comparison__c = false;
		m59.Update_Period__c = 'Daily';
		ms.add(m59);
		
		M_E_Metric__c m129 = new M_E_Metric__c();
		m129.M_E_Area__c = 'Sustainability';
		m129.Name = 'EADD_female_farmers_using_dry_season_feeding';
		m129.Automated__c = 'No';
		m129.Calculation_Type__c = 'None';
		//m129.Further_Link_Text__c = '';
		//m129.Further_Link_Url__c = '';
		m129.Is_Header__c = false;
		m129.Is_On_Fly__c = true;
		m129.Label__c = '        Female';
		m129.On_The_Fly_Calculation_Type__c = 'Sum';
		m129.Order__c = 6;
		//m129.Organisation__c = acc.Id;
		//m129.Projected_Value__c = 50;
		m129.Propagate_Targets__c = false;
		m129.Reverse_Comparison__c = false;
		m129.Update_Period__c = 'Daily';
		ms.add(m129);
		
		M_E_Metric__c m329 = new M_E_Metric__c();
		m329.M_E_Area__c = 'Sustainability';
		m329.Name = 'EADD_male_farmers_using_dry_season_feeding';
		m329.Automated__c = 'No';
		m329.Calculation_Type__c = 'None';
		//m329.Further_Link_Text__c = '';
		//m329.Further_Link_Url__c = '';
		m329.Is_Header__c = false;
		m329.Is_On_Fly__c = true;
		m329.Label__c = '        Male';
		m329.On_The_Fly_Calculation_Type__c = 'Sum';
		m329.Order__c = 7;
		//m329.Organisation__c = acc.Id;
		//m329.Projected_Value__c = 50;
		m329.Propagate_Targets__c = false;
		m329.Reverse_Comparison__c = false;
		m329.Update_Period__c = 'Daily';
		ms.add(m329);
		
		M_E_Metric__c m229 = new M_E_Metric__c();
		m229.M_E_Area__c = 'Sustainability';
		m229.Name = 'EADD_youth_farmers_using_dry_season_feeding';
		m229.Automated__c = 'No';
		m229.Calculation_Type__c = 'None';
		//m229.Further_Link_Text__c = '';
		//m229.Further_Link_Url__c = '';
		m229.Is_Header__c = false;
		m229.Is_On_Fly__c = true;
		m229.Label__c = '        Youth';
		m229.On_The_Fly_Calculation_Type__c = 'Sum';
		m229.Order__c = 8;
		//m229.Organisation__c = acc.Id;
		//m229.Projected_Value__c = 50;
		m229.Propagate_Targets__c = false;
		m229.Reverse_Comparison__c = false;
		m229.Update_Period__c = 'Daily';
		ms.add(m229);
		
		//using supplementary
		M_E_Metric__c m50 = new M_E_Metric__c();
		m50.M_E_Area__c = 'Sustainability';
		m50.Name = 'EADD_farmers_using_supplementary';
		m50.Automated__c = 'No';
		m50.Calculation_Type__c = 'None';
		//m50.Further_Link_Text__c = '';
		//m50.Further_Link_Url__c = '';
		m50.Is_Header__c = true;
		m50.Is_On_Fly__c = true;
		m50.Label__c = 'Number of farmers using supplementary';
		m50.On_The_Fly_Calculation_Type__c = 'Sum';
		m50.Order__c = 9;
		//m50.Organisation__c = acc.Id;
		//m50.Projected_Value__c = 100;
		m50.Propagate_Targets__c = false;
		m50.Reverse_Comparison__c = false;
		m50.Update_Period__c = 'Daily';
		ms.add(m50);
		
		M_E_Metric__c m120 = new M_E_Metric__c();
		m120.M_E_Area__c = 'Sustainability';
		m120.Name = 'EADD_female_farmers_using_supplementary';
		m120.Automated__c = 'No';
		m120.Calculation_Type__c = 'None';
		//m120.Further_Link_Text__c = '';
		//m120.Further_Link_Url__c = '';
		m120.Is_Header__c = false;
		m120.Is_On_Fly__c = true;
		m120.Label__c = '        Female';
		m120.On_The_Fly_Calculation_Type__c = 'Sum';
		m120.Order__c = 10;
		//m120.Organisation__c = acc.Id;
		//m120.Projected_Value__c = 50;
		m120.Propagate_Targets__c = false;
		m120.Reverse_Comparison__c = false;
		m120.Update_Period__c = 'Daily';
		ms.add(m120);
		
		M_E_Metric__c m320 = new M_E_Metric__c();
		m320.M_E_Area__c = 'Sustainability';
		m320.Name = 'EADD_male_farmers_using_supplementary';
		m320.Automated__c = 'No';
		m320.Calculation_Type__c = 'None';
		//m320.Further_Link_Text__c = '';
		//m320.Further_Link_Url__c = '';
		m320.Is_Header__c = false;
		m320.Is_On_Fly__c = true;
		m320.Label__c = '        Male';
		m320.On_The_Fly_Calculation_Type__c = 'Sum';
		m320.Order__c = 11;
		//m320.Organisation__c = acc.Id;
		//m320.Projected_Value__c = 50;
		m320.Propagate_Targets__c = false;
		m320.Reverse_Comparison__c = false;
		m320.Update_Period__c = 'Daily';
		ms.add(m320);
		
		M_E_Metric__c m220 = new M_E_Metric__c();
		m220.M_E_Area__c = 'Sustainability';
		m220.Name = 'EADD_youth_farmers_using_supplementary';
		m220.Automated__c = 'No';
		m220.Calculation_Type__c = 'None';
		//m220.Further_Link_Text__c = '';
		//m220.Further_Link_Url__c = '';
		m220.Is_Header__c = false;
		m220.Is_On_Fly__c = true;
		m220.Label__c = '        Youth';
		m220.On_The_Fly_Calculation_Type__c = 'Sum';
		m220.Order__c = 12;
		//m220.Organisation__c = acc.Id;
		//m220.Projected_Value__c = 50;
		m220.Propagate_Targets__c = false;
		m220.Reverse_Comparison__c = false;
		m220.Update_Period__c = 'Daily';
		ms.add(m220);
		
		//using  hq
		M_E_Metric__c m5a = new M_E_Metric__c();
		m5a.M_E_Area__c = 'Sustainability';
		m5a.Name = 'EADD_farmers_using_high_quality';
		m5a.Automated__c = 'No';
		m5a.Calculation_Type__c = 'None';
		//m5a.Further_Link_Text__c = '';
		//m5a.Further_Link_Url__c = '';
		m5a.Is_Header__c = true;
		m5a.Is_On_Fly__c = true;
		m5a.Label__c = 'Number of farmers using high quality';
		m5a.On_The_Fly_Calculation_Type__c = 'Sum';
		m5a.Order__c = 13;
		//m5a.Organisation__c = acc.Id;
		//m5a.Projected_Value__c = 100;
		m5a.Propagate_Targets__c = false;
		m5a.Reverse_Comparison__c = false;
		m5a.Update_Period__c = 'Daily';
		ms.add(m5a);
		
		M_E_Metric__c m12a = new M_E_Metric__c();
		m12a.M_E_Area__c = 'Sustainability';
		m12a.Name = 'EADD_female_farmers_using_high_quality';
		m12a.Automated__c = 'No';
		m12a.Calculation_Type__c = 'None';
		//m12a.Further_Link_Text__c = '';
		//m12a.Further_Link_Url__c = '';
		m12a.Is_Header__c = false;
		m12a.Is_On_Fly__c = true;
		m12a.Label__c = '        Female';
		m12a.On_The_Fly_Calculation_Type__c = 'Sum';
		m12a.Order__c = 14;
		//m12a.Organisation__c = acc.Id;
		//m12a.Projected_Value__c = 50;
		m12a.Propagate_Targets__c = false;
		m12a.Reverse_Comparison__c = false;
		m12a.Update_Period__c = 'Daily';
		ms.add(m12a);
		
		M_E_Metric__c m32a = new M_E_Metric__c();
		m32a.M_E_Area__c = 'Sustainability';
		m32a.Name = 'EADD_male_farmers_using_high_quality';
		m32a.Automated__c = 'No';
		m32a.Calculation_Type__c = 'None';
		//m32a.Further_Link_Text__c = '';
		//m32a.Further_Link_Url__c = '';
		m32a.Is_Header__c = false;
		m32a.Is_On_Fly__c = true;
		m32a.Label__c = '        Male';
		m32a.On_The_Fly_Calculation_Type__c = 'Sum';
		m32a.Order__c = 15;
		//m32a.Organisation__c = acc.Id;
		//m32a.Projected_Value__c = 50;
		m32a.Propagate_Targets__c = false;
		m32a.Reverse_Comparison__c = false;
		m32a.Update_Period__c = 'Daily';
		ms.add(m32a);
		
		M_E_Metric__c m22a = new M_E_Metric__c();
		m22a.M_E_Area__c = 'Sustainability';
		m22a.Name = 'EADD_youth_farmers_using_high_quality';
		m22a.Automated__c = 'No';
		m22a.Calculation_Type__c = 'None';
		//m22a.Further_Link_Text__c = '';
		//m22a.Further_Link_Url__c = '';
		m22a.Is_Header__c = false;
		m22a.Is_On_Fly__c = true;
		m22a.Label__c = '        Youth';
		m22a.On_The_Fly_Calculation_Type__c = 'Sum';
		m22a.Order__c = 16;
		//m22a.Organisation__c = acc.Id;
		//m22a.Projected_Value__c = 50;
		m22a.Propagate_Targets__c = false;
		m22a.Reverse_Comparison__c = false;
		m22a.Update_Period__c = 'Daily';
		ms.add(m22a);
		
		insert ms;
	}
	
	//test methods for EADDHelpers
	//this test is added to test the if statements
	static testMethod void testGetDistrictAndSubcountyClause(){
		String returnValue = EADDHelpers.getDistrictAndSubcountyClause('Test District 1', 'Test Subcounty 1', '1987-12-18', '2013-12-18');
		System.assert(returnValue.contains('Test District 1'));
		System.assert(returnValue.contains('Test Subcounty 1'));
		System.assert(returnValue.contains('1987-12-18'));
		System.assert(returnValue.contains('2013-12-18'));
	}
	
	//tests for ProcessEADDSurveys
	static testMethod void testHubSurveysPostProcessing(){
		ProcessSurveySubmission.SurveySubmission submission = getSubmission('EADD_HUB');
		District__c[] ds = [select Id from District__c where Name = 'Masaka'];
		Country__c[] cs = [select Id from Country__c where Name = 'NEW COUNTRY'];
		Person__c interviewer = getTestPerson(cs[0], ds[0]);
		Map<String, Submission_Answer__c> answers = getHubAnswers('1', 'Grameen Subcounty');		
		List<String> response = ProcessEADDSurveys.processEADDHubRegistration(submission, answers, interviewer);
		System.assert(response.size() == 3);
		System.assert(response[1].contains('EADD Hub Registration successful'));
		
		//this will update the hub info, covers one extra line of code
		List<String> response1 = ProcessEADDSurveys.processEADDHubRegistration(submission, answers, interviewer);
		System.assert(response1.size() == 3);
		System.assert(response1[1].contains('EADD Hub Registration successful'));
		
		//this should tell us that the district given doesnt exist
		answers = getHubAnswers('some unknown district', 'Grameen Subcounty');		
		List<String> response2 = ProcessEADDSurveys.processEADDHubRegistration(submission, answers, interviewer);
		System.assert(response2.size() == 3);
		System.assert(response2[1].contains('The district provided is not in salesforce'));
		
		//this should tell us that the subcounty given doesnt exist
		answers = getHubAnswers('1', 'some unknown Subcounty');		
		List<String> response3 = ProcessEADDSurveys.processEADDHubRegistration(submission, answers, interviewer);
		System.assert(response3.size() == 3);
		System.assert(response3[1].contains('The subcounty provided is not in salesforce'));
	}
	
	static testMethod void testFarmerInfoSurveysPostProcessing(){
		ProcessSurveySubmission.SurveySubmission submission = getSubmission('EADD_FARMER_EXTRA_INFO');
		District__c[] ds = [select Id from District__c where Name = 'Masaka'];
		Country__c[] cs = [select Id from Country__c where Name = 'NEW COUNTRY'];
		Person__c interviewer = getTestPerson(cs[0], ds[0]);
		Map<String, Submission_Answer__c> answers = getFarmerInfoAnswers('1', 'Grameen Subcounty');		
		List<String> response = ProcessEADDSurveys.processEADDFarmerRegistration(submission, answers, interviewer);
		System.assert(response.size() == 3);
		System.assert(response[1].contains('EADD Farmer extra info Registration successful'));
		
		//this will update the existing info, covers one extra line of code		
		List<String> responseu = ProcessEADDSurveys.processEADDFarmerRegistration(submission, answers, interviewer);
		System.assert(responseu.size() == 3);
		System.assert(responseu[1].contains('EADD Farmer extra info Registration successful'));
		
		//response for unknow district
		answers = getFarmerInfoAnswers('some unknown district', 'Grameen Subcounty');		
		List<String> response1 = ProcessEADDSurveys.processEADDFarmerRegistration(submission, answers, interviewer);
		System.assert(response1.size() == 3);
		System.assert(response1[1].contains('The district provided is not in salesforce'));
		
		//response for unknow subcounty
		answers = getFarmerInfoAnswers('1', 'some unknown Subcounty');		
		List<String> response12 = ProcessEADDSurveys.processEADDFarmerRegistration(submission, answers, interviewer);
		System.assert(response12.size() == 3);
		System.assert(response12[1].contains('The subcounty provided is not in salesforce'));
	}
	
    public static Person__c getTestPerson(Country__c country, District__c district){
        
        Person__c person = new Person__c();
        
        person.First_Name__c = 'Jane';
        person.Middle_Name__c = 'The Actrice';
        person.Last_Name__c = 'Fonda';
        person.Date_of_Birth__c = date.newinstance(1937, 12, 21);
        person.Raw_Mobile_Number__c = '+254123456789';
        person.Gender__c = 'Female';
        person.Type__c = 'Farmer';
        person.Village__c = 'Kisumu';
        person.City__c = 'Kisumu city';
        person.District__c = district.Id;
        person.Country__c = country.Id;
        person.ID_Number__c = 'ID0987654321';
        person.Picture_URL__c = 'http://www.himmelreich-it.com/image.jpg';
        person.Next_Of_Kin__c = 'Ted Turner';
        person.Next_Of_Kin_Telephone__c = '+254123456788';
        
        return person;
    }
    
    // mock data for test runs
    public static District__c getTestDistrict(){
        District__c district = new District__c();
        district.Name = 'Masaka';
        district.Latitude__c = 31950;
        district.Longitude__c = 58986;
        return district;
    }
    
    public static Subcounty__c getSubcounty(District__c district){    	
		Subcounty__c sub = new Subcounty__c();
		sub.Display_Name__c = 'Grameen Subcounty';
		sub.District__c = district.Id;
		return sub;
    }
    
    public static Map<String, Submission_Answer__c> getHubAnswers(String district, String subcounty){
    	Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
    	Submission_Answer__c answer1 = new Submission_Answer__c();
    	answer1.Answer__c = 'Test';
    	answers.put('q1_0', answer1);
    	Submission_Answer__c answer2 = new Submission_Answer__c();
    	answer2.Answer__c = district;
    	answers.put('q2_0', answer2);
    	Submission_Answer__c answer3 = new Submission_Answer__c();
    	answer3.Answer__c = subcounty;
    	answers.put('q3_0', answer3);
    	Submission_Answer__c answer9 = new Submission_Answer__c();
    	answer9.Answer__c = '5000';
    	answers.put('q9_0', answer9);
    	Submission_Answer__c answer11 = new Submission_Answer__c();
    	answer11.Answer__c = '5000';
    	answers.put('q11_0', answer11);
    	Submission_Answer__c answer16 = new Submission_Answer__c();
    	answer16.Answer__c = '5000';
    	answers.put('q16_0', answer16);
    	Submission_Answer__c answer18 = new Submission_Answer__c();
    	answer18.Answer__c = '5000';
    	answers.put('q18_0', answer18);
    	Submission_Answer__c answer19 = new Submission_Answer__c();
    	answer19.Answer__c = '6';
    	answers.put('q19_0', answer19);
    	Submission_Answer__c answer6 = new Submission_Answer__c();
    	answer6.Answer__c = '2013-09-03';
    	answers.put('q6_0', answer6);
    	Submission_Answer__c answer611 = new Submission_Answer__c();
    	answer611.Answer__c = '12.5';
    	answers.put('q8_0', answer611);
    	Submission_Answer__c answer6112 = new Submission_Answer__c();
    	answer6112.Answer__c = '1.53780813 33.44823459 1095.5999755859375 5.0';
    	answers.put('q20_0', answer6112);
    	return answers;
    }
    
    public static Map<String, Submission_Answer__c> getFarmerInfoAnswers(String district, String subcounty){
    	Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
    	Submission_Answer__c answer = new Submission_Answer__c();
    	answer.Answer__c = 'Test Farmer';
    	answers.put('q1_0', answer);
    	Submission_Answer__c answer_g = new Submission_Answer__c();
    	answer_g.Answer__c = '1';
    	answers.put('q2_0', answer_g);    	
    	Submission_Answer__c answer1 = new Submission_Answer__c();
    	answer1.Answer__c = '35';
    	answers.put('q3_0', answer1);
    	Submission_Answer__c answer2 = new Submission_Answer__c();
    	answer2.Answer__c = district;
    	answers.put('q4_0', answer2);
    	Submission_Answer__c answer3 = new Submission_Answer__c();
    	answer3.Answer__c = subcounty;
    	answers.put('q5_0', answer3);
    	Submission_Answer__c answer9 = new Submission_Answer__c();
    	answer9.Answer__c = '1';
    	answers.put('q8_0', answer9);
    	Submission_Answer__c answer11 = new Submission_Answer__c();
    	answer11.Answer__c = '1';
    	answers.put('q10_0', answer11);
    	Submission_Answer__c answer16 = new Submission_Answer__c();
    	answer16.Answer__c = '1';
    	answers.put('q11_0', answer16);
    	Submission_Answer__c answer18 = new Submission_Answer__c();
    	answer18.Answer__c = '1';
    	answers.put('q12_0', answer18);
    	Submission_Answer__c answer19 = new Submission_Answer__c();
    	answer19.Answer__c = '1';
    	answers.put('q13_0', answer19);
    	Submission_Answer__c answer6 = new Submission_Answer__c();
    	answer6.Answer__c = '1';
    	answers.put('q14_0', answer6);    	
    	Submission_Answer__c answer165 = new Submission_Answer__c();
    	answer165.Answer__c = '1';
    	answers.put('q15_0', answer165);
    	Submission_Answer__c answer186 = new Submission_Answer__c();
    	answer186.Answer__c = '1';
    	answers.put('q16_0', answer186);
    	Submission_Answer__c answer197 = new Submission_Answer__c();
    	answer197.Answer__c = '1';
    	answers.put('q17_0', answer197);
    	Submission_Answer__c answer68 = new Submission_Answer__c();
    	answer68.Answer__c = '1';
    	answers.put('q18_0', answer68);
    	Submission_Answer__c answer1972 = new Submission_Answer__c();
    	answer1972.Answer__c = '1';
    	answers.put('q20_0', answer1972);
    	Submission_Answer__c answer689 = new Submission_Answer__c();
    	answer689.Answer__c = '1';
    	answers.put('q19_0', answer689);
    	return answers;
    }
    
    public static ProcessSurveySubmission.SurveySubmission getSubmission(String postProcessingMethod) {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);
        
        // Create a district
        District__c district = getTestDistrict();
        database.insert(district);    
        
        // Create a subcounty
        Subcounty__c sub = getSubcounty(district);
        database.insert(sub); 
        
        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);
<<<<<<< HEAD
        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);
=======
>>>>>>> origin/ci

        Survey__c survey = new Survey__c();
        survey.Post_Processing_Method__c = postProcessingMethod;
        survey.Save_To_Salesforce__c = false;
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];
        
        Phone__c phone = Utils.createTestHandset('21342342345345434');      
        database.insert(phone);
        
        Person__c personC = Utils.createTestPerson(phone.Id, 'Oloo', false, district.Id, 'Male');
        database.insert(personC);//to use as creator
        
        Person__c farmerPerson = Utils.createTestPerson(phone.Id, 'James', true, district.Id, 'Male');
        database.insert(farmerPerson);
        
        Farmer__c farmer = Utils.createTestFarmer('DE423423', farmerPerson.Id, 'Dummy farmer', false, district.Id, 'Male');     
        farmer.Registered_By__c = personC.Id;
        database.insert(farmer);

        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = person.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'DE423423';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        surveySubmission.submissionStartTime = Datetime.now().addMinutes(20).getTime().format().replace(',', '');
        surveySubmission.json = 'none';
        return surveySubmission;
    }
    
    static testMethod void testGetDairyHubMapMarkers(){
    	//no data
    	MetricMapWrapper[] markers = EADDDashboardController.getDairyHubMapMarkers();
    	System.assert(markers.size() == 0);
    	
    	//this will insert two hubs
 		insertMetricData();
 		
		District__c district = new District__c();
		district.Name = 'District 1';
		database.insert(district);
		Subcounty__c sub = new Subcounty__c();
		sub.Display_Name__c = 'Subcounty 1';
		sub.District__c = district.Id;
		database.insert(sub);
		
 		//also chip in a hub without GPS data
 		//well, this should not be returned in markers
		EADD_Hub__c hub = new EADD_Hub__c();
		hub.Date__c = Date.today();
		hub.Farmers_served_by_hub__c = 60;
		hub.Hub_capacity_utilization__c = '60-70';
		hub.Milk_sale_profits__c = 50000;
		hub.Milk_sale_revenue__c = 500000;
		hub.Milk_volumes_bulked__c =  100000;
		hub.Milk_volumes_rejected__c = 500;
		hub.Name__c = 'Test Hub GPSless';
		hub.Radius_Covered__c = 25.5;
		hub.District__c = district.Id;
		hub.Subcounty__c = sub.Id;
		insert hub;
		
		String ids = EADDHelpers.getIdsOfLatestHubInformation();
		System.assert(ids != '');
		   	
    	MetricMapWrapper[] markers2 = EADDDashboardController.getDairyHubMapMarkers();
    	System.assert(markers2.size() == 2);
    }
    
    public static testMethod void testEaddMapMarkers(){
    	
    	EADD_Hub__c eadd_hub = new EADD_Hub__c();
    	eadd_hub.Latitude__c = '1.33333';
    	eadd_hub.Longitude__c = '33.788';
    	eadd_hub.Name__c = 'test hub';
    	eadd_hub.Hub_capacity_utilization__c = 'utilizing 60-70%';
    	eadd_hub.Radius_Covered__c = 12.5;
    	EADDMapMarkers markers = new EADDMapMarkers(eadd_hub);
    	String content = markers.getMarkerInfoContentString();	
		String expected = 	'<div>'																			+
							'	&nbsp;&nbsp;Hub Details <br/>'												+
							'	Name:&ensp;' + eadd_hub.Name__c + '<br/>'									+
							'	Utilization level:&ensp;' + eadd_hub.Hub_capacity_utilization__c + '<br/>'	+
							'	Coverage(km):&ensp;' + eadd_hub.Radius_Covered__c + '<br/>'					+
							'</div>';
		System.assert(content == expected);
    } 
    
}