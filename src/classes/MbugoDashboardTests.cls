@isTest
public with sharing class MbugoDashboardTests {
	public MbugoDashboardTests() {
	
	
	}

	static testMethod void testController()
    {
        
        
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      

       


        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Lu' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        //testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = 'CKW';
        insert testPerson;




        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.Id;
        insert(testCkw);




        Person__c testFOPerson = new Person__c();
        testFOPerson.First_Name__c = 'John FO';
        testFOPerson.Last_Name__c = 'Lu FO' ;
        testFOPerson.Gender__c = 'Male';
        testFOPerson.District__c = testDistrict.Id;
        //testPerson.Handset__c = testHandset.Id;
        testFOPerson.Type__c = 'CKW';
        insert testFOPerson;


        //Create FO
        Mbugo_Field_Officer__c mbugoFO = new Mbugo_Field_Officer__c();
        mbugoFO.Person__c = testFOPerson.Id;
        insert(mbugoFO);

        Mbugo_CKW__c mbugoCkw = new Mbugo_CKW__c();
        mbugoCkw.Mbugo_Field_Officer__c = mbugoFO.Id;
        mbugoCkw.Person__c = testPerson.Id;        
        insert(mbugoCkw);




        Group__c testGroup = new Group__c();
        testGroup.Name = 'Mbugo CKWs';
        insert(testGroup);

        Person_Group_Association__c testPersonGroupAssociation = new Person_Group_Association__c();
        testPersonGroupAssociation.Group__c = testGroup.Id;
        testPersonGroupAssociation.Person__c = testPerson.Id;
        insert(testPersonGroupAssociation);




         

        PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('district', String.valueOf(testDistrict.Id));
        resultPage.getParameters().put('subcounty', String.valueOf(testSubcounty.Id));
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('cbt', String.valueOf(testPerson.Id));
        resultPage.getParameters().put('sfdc.tabName', 'a00');


        Account testOrg = new Account();
        testOrg.Name = MbugoHelpers.ORG_NAME;
        testOrg.BillingState = 'CA';
        insert testOrg;

        Organisation_District_Association__c orgAssocTest = new Organisation_District_Association__c();
        orgAssocTest.District__c = testDistrict.Id;
         orgAssocTest.Organisation__c = testOrg.Id;
        insert(orgAssocTest);
        



        MbugoDashboardController controller = new MbugoDashboardController();
        //controller.setOrgName(testOrg.Name);
        controller.setUp(resultPage);
        controller.setIsUpdateable('true');


        
        Test.startTest();
        
        List<MetricDataWrapper> wrappers = controller.getFarmersReachedData();
        System.assert(wrappers != null);

        wrappers = controller.getFarmerGroupsData();
        System.assert(wrappers.size() == 4);

        wrappers = controller.getCooperativeGroupsData();
        System.assert(wrappers.size() == 2);
		System.assert(controller.getDistrictList() != null);

		System.assert(controller.getCkwPerfomanceData() != null);
		System.assert(controller.getIsUpdateable().equals('true'));
		System.assert(controller.getSubcountiesList() != null);
        System.assert(controller.changeFilters() != null);

        System.assert(MbugoHelpers.getCKWMapMarkers().size() == 1);
        System.assert(MbugoHelpers.getFOMapMarkers().size() == 1);



        Test.stopTest();


    }	
}