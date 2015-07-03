@isTest
private class BSS_SurveyPageControllerTest {
	
	@isTest static void test_method_SurveyPageController() {
		 //create contact1
		Contact contact1 = new Contact(LastName = 'Perez');
		insert contact1;
        
        //create contact2
		Contact contact2 = new Contact(LastName = 'Ramirez');
		insert contact2;
        
        //create contact3
		Contact contact3 = new Contact(LastName = 'Gutierrez');
		insert contact3;
        
        //create mobile user
        gfsurveys__Mobile_User__c mu = New gfsurveys__Mobile_User__c();
        mu.gfsurveys__Contact__c = contact3.Id;
        mu.gfsurveys__Username__c = 'test';
        mu.gfsurveys__Password__c = 'test';
        insert mu;
        
        Date todayDate = Date.today();
  		Date lastDate = todayDate.addMonths(12);
        
        //create project
        BSS_Project__c proj = new BSS_Project__c();
        proj.Name__c= 'Coocafisa';
        proj.Project_Manager__c = contact1.Id;
        proj.Grameen_Project_Manager__c = contact2.Id;
        proj.Start_Date__c = system.today();
        proj.End_Date__c = lastDate;
        insert proj;
        
        //create project ckw
		BSS_CKW_Project__c ckwpjt =  new BSS_CKW_Project__c();
        ckwpjt.Project__c = proj.Id;
        ckwpjt.CKW__c = mu.Id;
        ckwpjt.Start_Date__c = system.today();
        ckwpjt.End_Date__c = lastDate;
        ckwpjt.Monthly_Discount__c = 10000;
        insert ckwpjt;

         //create project ckw2
        BSS_CKW_Project__c ckwpjt2 =  new BSS_CKW_Project__c();
        ckwpjt2.Project__c = proj.Id;
        ckwpjt2.CKW__c = mu.Id;
        ckwpjt2.Start_Date__c = system.today();
        ckwpjt2.End_Date__c = lastDate;
        ckwpjt2.Monthly_Discount__c = 10000;
        insert ckwpjt2;

        //create survey
        gfsurveys__Survey__c survey = new gfsurveys__Survey__c();
        survey.Name = 'Survey prueba';
        insert survey;

        //create projet survey
        BSS_Survey_Value__c pjtsurvey = new BSS_Survey_Value__c();
        pjtsurvey.Project__c = proj.Id;
        pjtsurvey.Survey__c = survey .Id;
        pjtsurvey.Survey_value__c = 15000;
        insert pjtsurvey;        

        Date submisionDate = todayDate.addMonths(-1);
        
        //create submission
        gfsurveys__Submission__c submission = new gfsurveys__Submission__c ();
        submission.gfsurveys__Survey__c = survey.Id;
        submission.gfsurveys__Surveyor__c = contact3.Id;
        submission.gfsurveys__startDate__c = submisionDate;
        insert submission;

        Date submisionDate2 = todayDate.addMonths(-1);
        Date lastBillDate = date.newInstance(submisionDate2.year(), submisionDate2.month(), 1);

        //create header
        BSS_Monthly_Bill_Header__c header = new BSS_Monthly_Bill_Header__c();
        header.BSS_CKW_Project__c = ckwpjt2.Id;
        header.Month__c = lastBillDate;
        header.Total_discounts__c = 5000;
        insert header;

        BSS_SurveyPageController surveyPage = new BSS_SurveyPageController();

        List<SelectOption> options = surveyPage.getBSSProjects();
        System.assert(options != null);

        List<SelectOption> option = surveyPage.getProjectsCKW();
        System.assert(option != null);

        System.assert(surveyPage.project == null);

        System.assert(surveyPage.ckw == null);

        test.startTest();
        surveyPage.project = proj.Id;
        surveyPage.ckw = 'Todos los líderes';
        
        surveyPage.executeSearch();
        System.assert(surveyPage.details != null);
        surveyPage.save();

        test.stopTest();
	}
	
}