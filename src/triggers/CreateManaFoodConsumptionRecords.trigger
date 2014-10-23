trigger CreateManaFoodConsumptionRecords on Mana_Food_Consumption_Submission__c (after insert) {
	Mana_Food_Consumption_Submission__c[] submissions = Trigger.new; 
	for (Mana_Food_Consumption_Submission__c submission: submissions) {
		ManaFoodConsumptionSubmissionHandler handler = new ManaFoodConsumptionSubmissionHandler(submission);
		handler.handle();
	}
}