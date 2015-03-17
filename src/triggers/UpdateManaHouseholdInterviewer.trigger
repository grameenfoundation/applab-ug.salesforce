trigger UpdateManaHouseholdInterviewer on Mana_Household__c (before update, before insert) {
	Integer counter = 0;
	for (Mana_Household__c household: trigger.new) {
		if(household.Interviewer__c == null && household.Registration_Submission_Record__c != null) {
			gfsurveys__Submission__c submission = [SELECT gfsurveys__Surveyor__c from gfsurveys__Submission__c where Id =: household.Registration_Submission_Record__c];
			trigger.new[counter].Interviewer__c = submission.gfsurveys__Surveyor__c;
		}
		counter++;
	}
}