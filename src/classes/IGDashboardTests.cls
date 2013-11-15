/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
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
        resultPage.getParameters().put('region', 'TestRegion');
        resultPage.getParameters().put('district', 'TestDistrict');
        resultPage.getParameters().put('subcounty', 'TestSubcounty');
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('cbt', String.valueOf(testPerson.Id));
        resultPage.getParameters().put('sfdc.tabName', 'a00');
        controller.setUp(resultPage);
        System.assert(controller.getRegion() != '');
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
		Region__c region = new Region__c();
		region.Display_Name__c = 'TestWestNile';
		region.Country__c = ((Country__c)[select Id from Country__c where Name = :country.Name]).Id;
		insert region;
		
		List<SelectOption> regions = controller.getRegionsList();
		System.assert(regions.size() == 2);	//including the default --select all		
		controller.setRegionsList(null);
		
		//test districts list box
		District__c testDistrict = new District__c();
		testDistrict.Name = 'TestMasaka';
		testDistrict.Region__c = 'Central';
		insert testDistrict;
		
		Organisation_District_Association__c o = new Organisation_District_Association__c();
		o.Organisation__c = ([select Id from Account where Name = :testOrg.Name])[0].Id;
		o.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
		insert o;
		
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
		
		List<SelectOption> cbts = controller.getCommunityBasedTrainers();
		System.assert(cbts.size() == 2);//including the default --select all		
		controller.setCommunityBasedTrainers(null);
		
		//test metrics
		Survey__c survey = new Survey__c();
		survey.Account__c = ([select Id from Account where Name = :testOrg.Name])[0].Id;
		survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
		survey.Survey_Name__c = 'IG/NUSAF Test';
		survey.Survey_Status__c = 'Published';
		survey.Start_Date__c = Date.valueOf('2013-01-01');
		survey.End_Date__c = Date.valueOf('2015-01-01');
		insert survey;
		
		Community_Based_Trainer_Field_Visit__c v = new Community_Based_Trainer_Field_Visit__c();
		v.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
		v.Interview_Latitude__c = '0.32332';
		v.Interview_Longitude__c = '34.445566';
		v.Name_of_Trainer__c = 'David Mugume';
		v.Person__c = ([select Id from Person__c where First_Name__c = :testPerson.First_Name__c])[0].Id;
		v.Subcounty__c = ((Subcounty__c)[select Id from Subcounty__c where Display_Name__c = :testSubcounty.Display_Name__c]).Id;
		v.Survey__c = ((Survey__c)[select Id from Survey__c where Survey_Name__c = :survey.Survey_Name__c]).Id;
		v.Time__c = '4.30pm';
		v.Type_of_Visit__c = ((Survey__c)[select Id, Survey_Name__c from Survey__c where Survey_Name__c = :survey.Survey_Name__c]).Survey_Name__c;
		insert v;
		
		Community_Based_Trainer_Target__c target = new Community_Based_Trainer_Target__c();
		target.Survey__c = ((Survey__c)[select Id from Survey__c where Survey_Name__c = :survey.Survey_Name__c]).Id;
		target.Person__c = ([select Id from Person__c where First_Name__c = :testPerson.First_Name__c])[0].Id;
		target.Target_Value__c = 10;
		insert target;
		
		//getMetricsData
		//we expect one metric row (for the total of all data)
		List<MetricDataWrapper> metrics = controller.getMetricsData();
		System.assert(metrics.size() == 1);
		
		//changeFilters
		PageReference page = controller.changeFilters();
		System.assert(page != null);
		
		//getBarChartData
		//we expect metrics for one activity since we registered one survey
		List<List<IGDashboardHelpers.Data>> barChartMetrics = controller.getBarChartData();
		System.assert(barChartMetrics.size() == 1);
		System.assert(barChartMetrics[0].size() == 1);
		
		//metric map markers
		List<MetricMapWrapper> fieldVisits2 = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
		System.assert(fieldVisits2.size() == 1);		
		
		//metric map marker without co-ordinates
		Community_Based_Trainer_Field_Visit__c visit = new Community_Based_Trainer_Field_Visit__c();
		visit.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
		visit.Interview_Latitude__c = '';
		visit.Interview_Longitude__c = '';
		visit.Name_of_Trainer__c = 'David Mugume';
		visit.Person__c = ([select Id from Person__c where First_Name__c = :testPerson.First_Name__c])[0].Id;
		visit.Subcounty__c = ((Subcounty__c)[select Id from Subcounty__c where Display_Name__c = :testSubcounty.Display_Name__c]).Id;
		visit.Survey__c = ((Survey__c)[select Id from Survey__c where Survey_Name__c = :survey.Survey_Name__c]).Id;
		visit.Time__c = '4.30pm';
		visit.Type_of_Visit__c = ((Survey__c)[select Id, Survey_Name__c from Survey__c where Survey_Name__c = :survey.Survey_Name__c]).Survey_Name__c;
		insert visit;
		//we expect this not to return amongst the markers
		List<MetricMapWrapper> fieldVisits3 = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
		System.assert(fieldVisits3.size() == 1);
		
		/*
		* while the test data is available, test the CBT Targets Controller
		*/
    	IGDashboardTargetsController controller1 = new IGDashboardTargetsController();
		PageReference resultPage =  new PageReference('/a00/e');
		System.assert(controller1.getTarget() != null);
		System.assert(controller1.getTrainer() != null);
		System.assert(controller1.getSaved() == false);
		
		List<SelectOption> cbts1 = controller1.getCommunityBasedTrainers();
		System.assert(cbts1.size() == 2);//including the default --select all
		
		//activities		
		List<SelectOption> activities = controller1.getActivities();
		System.assert(activities.size() == 2);//including the default --select all
		
		//lets insert a trainer without a target	
		//this will help us cover one of those elusive if statements	
		Person__c testPerson2 = new Person__c();
		testPerson2.First_Name__c = 'Test';
		testPerson2.Last_Name__c = 'Trainer' ;
		testPerson2.Gender__c = 'Male';
		testPerson2.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
		testPerson2.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
		insert testPerson2;
		
		//test the save event
		//for one selected CBT's target
		controller1.setSaved(false);
		controller1.setTrainer(testPerson);
		controller1.setTarget(target);
		controller1.save();//update
		System.assert(controller1.getSaved());
		
		//for all CBTs' targets
		controller1.setSaved(false);
		Person__c p = new Person__c();		
		controller1.setTrainer(p);
		controller1.save();//update
		System.assert(controller1.getSaved());
		
		//clear targets
		database.delete([SELECT Id FROM Community_Based_Trainer_Target__c]);
		//test the save event
		//for one selected CBT's target
		controller1.setSaved(false);
		controller1.setTrainer(testPerson);
		controller1.setTarget(target);
		controller1.save();//new
		System.assert(controller1.getSaved());
		controller1.setSaved(false);
		controller1.save();//update		
		System.assert(controller1.getSaved());
		
		//clear targets
		database.delete([SELECT Id FROM Community_Based_Trainer_Target__c]);
		//for all CBTs' targets
		controller1.setSaved(false);
		Person__c per = new Person__c();		
		controller1.setTrainer(per);
		controller1.save();//new
		System.assert(controller1.getSaved());
		controller1.setSaved(false);
		controller1.save();//updates
		System.assert(controller1.getSaved());	
    }
}