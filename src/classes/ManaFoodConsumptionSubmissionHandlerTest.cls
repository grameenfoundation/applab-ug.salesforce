@IsTest
public class ManaFoodConsumptionSubmissionHandlerTest{
<<<<<<< HEAD
    static Id setupSubmission() {
    	String foodName = 'ahuyama';
    	
=======
    static Mana_Food_Consumption_Submission__c setupSubmission() {
        String foodName = 'ahuyama';
        
>>>>>>> origin/ci
        // Set up a Survey
        gfsurveys__Survey__c survey = new gfsurveys__Survey__c();
        survey.name = 'Test Survey';
        insert survey;
        
        // Set up a question
        gfsurveys__Question__c section = new gfsurveys__Question__c();
        section.gfsurveys__Type__c = 'section';
        section.gfsurveys__Survey__c = survey.Id;
        insert section;
        
        gfsurveys__Question__c question = new gfsurveys__Question__c();
        question.gfsurveys__Survey__c = survey.Id;
        question.Name = ManaFoodConsumptionConfig.sourcePrefixMap.get(ManaFoodConsumptionConfig.Source_Barter) + 'a_' + foodName;
        question.gfsurveys__Parent__c = section.Id;
        insert question;
        
        // Set up a Survey version
        gfsurveys__SurveyVersion__c version = new gfsurveys__SurveyVersion__c();
        version.gfsurveys__Survey__c = survey.id;
        insert version;
        
        // Set up a submission
        gfsurveys__Submission__c submission = new gfsurveys__Submission__c();
        submission.gfsurveys__Survey__c = survey.Id;
        insert submission;
        
        // Set up and answer
        gfsurveys__Answer__c answer = new gfsurveys__Answer__c();
        answer.gfsurveys__Question__c = question.Id;
        answer.gfsurveys__Submission__c = submission.Id;
        answer.gfsurveys__Value__c = '3';
        insert answer;
<<<<<<< HEAD
       	
       	// Set up a Mana Food record
       	Mana_Food__c food = new Mana_Food__c();
       	food.name = foodName;
       	food.Units__c = 'Grams';
       	insert food;
       	
       	// Update config to have this food's id
       	ManaFoodConsumptionConfig.foodMap.put(food.name, food.Id);
       	
       	
=======
        
        // Set up a Mana Food record
        Mana_Food__c food = new Mana_Food__c();
        food.name = foodName;
        food.Units__c = 'Grams';
        insert food;
        
        // Update config to have this food's id
        ManaFoodConsumptionConfig.foodMap.put(food.name, food.Id);
        
        
>>>>>>> origin/ci
        // Set up a Mana Food Quantity Code record
        Mana_Food_Quantity_Code__c code = new Mana_Food_Quantity_Code__c();
        code.Code__c = '13x2';
        code.Food__c = food.Id;
        code.Quantity__c = 12.0;
        insert code;
       
        // Set up a Household
        Mana_Household__c household = new Mana_Household__c();
        insert household;
        
        // Set up a mana submission record that links to that. Saving it should trigger the handler
        Mana_Food_Consumption_Submission__c consumptionSubmission = new Mana_Food_Consumption_Submission__c();
        consumptionSubmission.Household__c = household.Id;
        consumptionSubmission.Submission__c = submission.Id;
        insert consumptionSubmission;
        
<<<<<<< HEAD
        return consumptionSubmission.Id;
=======
        return consumptionSubmission;
>>>>>>> origin/ci
    }
    
    @IsTest
    static void testHandler() {
<<<<<<< HEAD
        Id submissionId = setupSubmission(); // This should triggler ManaFoodConsumptionSubmissionHandler.handle()
        
        // This should create a Mana_Food_Consumption_Record__c object with this submission Id
        Mana_Food_Consumption_Record__c record = [Select Id from Mana_Food_Consumption_Record__c where Submission__c =: submissionId];
        
		// Run some checks
=======
        Mana_Food_Consumption_Submission__c submission = setupSubmission(); 
        
        // Trigger ManaFoodConsumptionSubmissionHandler.handle()
        ManaFoodConsumptionSubmissionHandler handler = new ManaFoodConsumptionSubmissionHandler(submission);
        handler.handle();
        
        // This should create a Mana_Food_Consumption_Record__c object with this submission Id
        Mana_Food_Consumption_Record__c record = [Select Id from Mana_Food_Consumption_Record__c where Submission__c =: submission.Id];
        
        // Run some checks
>>>>>>> origin/ci
        System.assert(record != null);
    }
}