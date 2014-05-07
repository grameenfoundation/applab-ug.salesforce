/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class contains tests for IG/NUSAF Dashboard
 **/
@isTest
private class IGDashboardTests {

    static testMethod void testIGDashboardController() {    	
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'Test';
        testPerson.Last_Name__c = 'Person' ;
        testPerson.Gender__c = 'Male';
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        IGDashboardController controller = new IGDashboardController();
        
        //test setup
        PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('subregion', 'Bunyoro');
        resultPage.getParameters().put('district', 'TestDistrict');
        resultPage.getParameters().put('subcounty', 'TestSubcounty');
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('cbt', String.valueOf(testPerson.Id));
        resultPage.getParameters().put('sfdc.tabName', 'a00');
        controller.setUp(resultPage);
        System.assert(controller.getSubregion() != '');
        System.assert(controller.district != null);
        System.assert(controller.subcounty != null);
        System.assert(controller.dummyObject != null);
    }
    
    static testMethod void testSelectListsAndMetrics() {    	
        
        //no metric map markers
        List<MetricMapWrapper> fieldVisits = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
        System.assert(fieldVisits.size() == 0);
        
        IGDashboardController controller = new IGDashboardController();
        
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        insert testOrg;
        controller.setOrgName(testOrg.Name);

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        insert country;
        controller.setCountry(country.Name);
        
        //test regions listbox		
        IG_Region__c region = new IG_Region__c();
        region.Name = 'acholi';
        insert region;
        
        List<SelectOption> regions = controller.getSubregionsList();
        System.assert(regions.size() == 2);	//including the default --select all		
        controller.setSubregionsList(null);
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Organisation_District_Association__c o = new Organisation_District_Association__c();
        o.Organisation__c = ([select Id from Account where Name = :testOrg.Name])[0].Id;
        o.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        insert o;

        IG_Region_District_Association__c rda = new IG_Region_District_Association__c();
        rda.District__c = testDistrict.Id;
        rda.IG_Region__c = region.Id;
        insert rda;
        
        List<SelectOption> districts = controller.getDistrictList();
        System.assert(districts.size() == 2);//including the default --select all		
        controller.setDistrictList(null);
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya';
        testSubcounty.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        insert testSubcounty;      

        List<SelectOption> subs = controller.getSubcountiesList();
        System.assert(subs.size() == 2);//including the default --select all	
        controller.setSubcountiesList(null);
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        Phone__c phone = ([select Id from Phone__c where IMEI__c = '123456789101112'])[0];
        testPerson.Handset__c = phone.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = ([select Id from Account where Name = :testOrg.Name])[0].Id;
        survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
        survey.Survey_Name__c = 'IG/NUSAF Test';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.valueOf('2015-01-01');
        insert survey;

        IG_Subproject_Target__c v = new IG_Subproject_Target__c();
        v.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        v.LocationMobilization__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay1__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay2__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay3__c = '0.32332 34.445566';
        v.LocationFollowupVisit1__c = '0.32332 34.445566';
        v.LocationFollowupVisit2__c = '0.32332 34.445566';
        v.LocationFollowupVisit3__c = '0.32332 34.445566';           
        v.DateMobilization__c = Date.today();                      
        v.DateFollowupVisit1__c= Date.today();                  
        v.DateFollowupVisit2__c= Date.today();               
        v.DateFollowupVisit3__c= Date.today();                 
        v.DatePreliminaryTrainingDay1__c= Date.today();         
        v.DatePreliminaryTrainingDay2__c= Date.today();         
        v.DatePreliminaryTrainingDay3__c= Date.today(); 
        v.Name = 'Some project name';
        v.Person__c = ([select Id from Person__c where First_Name__c = :testPerson.First_Name__c])[0].Id;
        v.Subcounty__c = ((Subcounty__c)[select Id from Subcounty__c where Display_Name__c = :testSubcounty.Display_Name__c]).Id;
        v.IG_Region__c = region.Id;
        insert v;
        
        controller.subcounty = testSubcounty;
        List<SelectOption> cbts = controller.getCommunityBasedTrainers();
        System.assert(cbts.size() == 2);//including the default --select all        
        controller.setCommunityBasedTrainers(null);

        controller.district = testDistrict;
        controller.subregion = region.Name;
        controller.cbt = testPerson;
        //getMetricsData
        //we expect one metric row (for the total of all data)
        List<IGDashboardHelpers.Data> metrics = controller.getRegionalMetricsData();
        System.assert(metrics.size() == 1);

        //changeFilters
        PageReference page = controller.changeFilters();
        System.assert(page != null);

        //getBarChartData
        //we expect metrics for one activity since we registered one survey
        controller.setIsRegionalManager(true);
        List<IGDashboardHelpers.Data> barChartMetrics = controller.getCTMetricsData();
        System.assert(barChartMetrics.size() == 1);

        //metric map markers
        List<MetricMapWrapper> fieldVisits2 = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
        System.assert(fieldVisits2.size() == 1);		
    }
}