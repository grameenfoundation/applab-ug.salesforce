// Test for the trigger: UpdateManaHouseholdInterviewer
public with sharing class UpdateManaHouseholdInterviewerTest {
	@IsTest
	static void testTrigger() {
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
        question.Name = 'Test Name';
        question.gfsurveys__Parent__c = section.Id;
        insert question;
        
        // Set up a Survey version
        gfsurveys__SurveyVersion__c version = new gfsurveys__SurveyVersion__c();
        version.gfsurveys__Survey__c = survey.id;
        insert version;
        
        // Set up a contact
        Contact contact = new Contact();
        contact.FirstName = 'Luke';
        contact.LastName = 'Kyohere';
        insert contact;
        
        // Set up a submission
        gfsurveys__Submission__c submission = new gfsurveys__Submission__c();
        submission.gfsurveys__Surveyor__c = contact.Id;
        submission.gfsurveys__Survey__c = survey.Id;
        insert submission;
        
        // Set up a Household
        Mana_Household__c household = new Mana_Household__c();
        household.Registration_Submission_Record__c = submission.Id;
        insert household;
        
        // The trigger should be run and household.Interviewer__c should be set
        household = [SELECT Id, Interviewer__c from Mana_Household__c where Id =: household.Id];
        system.assertEquals(household.Interviewer__c, contact.Id);
	}
}