/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class contains tests for IG/NUSAF Dashboard
 **/
@isTest
private class FHITests {
    
    static testMethod void testDashboardComponents() {    	
        
        //no metric map markers
        List<MetricMapWrapper> fieldVisits = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
        System.assert(fieldVisits.size() == 0);
        
        FHIDashboardController controller = new FHIDashboardController();
        
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        database.SaveResult accSaveResult = database.insert(testOrg);

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        database.SaveResult countrySaveResult = database.insert(country);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accSaveResult.getId();
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        Database.insert(section);

        Dashboard_Section__c sec = [SELECT Name FROM Dashboard_Section__c WHERE Id = :section.Id];
        controller.setDashboardSection(sec.Name);
        List<Metric_Section__c> secs = controller.getMetricSections();
        System.assert(secs.size() == 0);

        Metric_Section__c metricsection = new Metric_Section__c();
        metricsection.Dashboard_Section__c = section.Id;
        metricsection.Description__c='Farmers Reached by Year';
        metricsection.Is_Active__c=true;
        metricsection.RollOver_Time__c='Quarterly';
        metricsection.Title__c='Farmers  by Year';
        metricsection.Start_Date__c=Date.today();
        metricsection.Default_Show__c=1;
        metricsection.Show_Spark_Line__c = true;
        metricsection.View_Mode__c='Disaggregated';
        insert metricsection;

        secs = controller.getMetricSections();
        System.assert(secs.size() == 1);

        M_E_Metric__c metric = new M_E_Metric__c();
        metric.Label__c='% of';
        metric.Is_On_Fly__c=true;
        metric.On_The_Fly_Calculation_Type__c='Percentage';
        metric.Order__c=0;
        metric.Name='FHI_target_farmers_reached_in_year_1';
        metric.Metric_Section__c = metricsection.Id;
        insert metric;

        List<M_E_Metric__c> metrics = controller.getMetrics(metricsection.Id);
        System.assert(metrics.size() == 1);
        
        //test regions listbox		
        Region__c region = new Region__c();
        region.Display_Name__c = 'Central';
        region.Country__c = countrySaveResult.getId();
        insert region;
        
        List<SelectOption> regions = controller.getSubregionsList();
        System.assert(regions.size() == 2);	//including the default --select all		
        controller.setSubregionsList(null);
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = region.Display_Name__c;
        database.SaveResult districtSaveResult = database.insert(testDistrict);
        
        List<SelectOption> districts = controller.getDistrictList();
        System.assert(districts.size() == 2);//including the default --select all		
        controller.setDistrictList(null);
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = districtSaveResult.getId();
        insert testSubcounty;      

        List<SelectOption> subs = controller.getSubcountiesList();
        System.assert(subs.size() == 2);//including the default --select all	
        controller.setSubcountiesList(null);
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.SaveResult phoneSaveResult = database.insert(testHandset);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = districtSaveResult.getId();
        testPerson.Handset__c = phoneSaveResult.getId();
        testPerson.Type__c = 'CKW';
        insert testPerson;

        //test setup
        PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('subregion', String.valueOf(region.Display_Name__c));
        resultPage.getParameters().put('district', String.valueOf(testDistrict.Id));
        resultPage.getParameters().put('subcounty', String.valueOf(testSubcounty.Id));
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('editMode', 'true');
        resultPage.getParameters().put('sfdc.tabName', '/a00/e');
        System.assert(controller.getIsEditMode() == 'false');

        controller.setUp(resultPage);
        System.assert(controller.subregion != '');
        System.assert(controller.district != null);
        System.assert(controller.subcounty != null);
        System.assert(controller.dummyObject != null);
        System.assert(controller.getIsEditMode() == 'true');

        //retest after region is set
        districts = controller.getDistrictList();
        System.assert(districts.size() == 2);//including the default --select all    

        //retest after district is set
        subs = controller.getSubcountiesList();
        System.assert(subs.size() == 2);//including the default --select all       
        
        controller.subcounty = testSubcounty;
        controller.district = testDistrict;
        controller.subregion = region.Id;
        controller.cbt = testPerson;

        //changeFilters
        PageReference page = controller.changeFilters();
        System.assert(page != null);

        //listbox events
        PageReference pageRegion = controller.onRegionChanged();
        System.assert(pageRegion == null);
        PageReference pageDistrict = controller.onDistrictChanged();
        System.assert(pageDistrict == null);
        PageReference pageSubc = controller.onSubcountyChanged();
        System.assert(pageSubc == null);
    }
}