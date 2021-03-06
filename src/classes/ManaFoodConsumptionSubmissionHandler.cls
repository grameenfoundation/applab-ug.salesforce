public class ManaFoodConsumptionSubmissionHandler{
    // Question name prefix (for filtering question answers in soql)
    public String questionNamePrefix = 'prd_02_%';
    
    // Source types (one record is created per food, per source type)
	String barterType = ManaFoodConsumptionConfig.Source_Barter;
	String purchaseType = ManaFoodConsumptionConfig.Source_Purchase;
	String otherType = ManaFoodConsumptionConfig.Source_Other;
	String productionType = ManaFoodConsumptionConfig.Source_Production;
	
	// The configuration
	ManaFoodConsumptionConfig config = new ManaFoodConsumptionConfig();
	
	// Answer map to store all answers indexed by question name
    Map<String, String> answersMap = new Map<String, String>();
    
    // The submission to handle
    Mana_Food_Consumption_Submission__c submission = null;
    
    // The gfsurveys__Submission__r.gfsurveys__startDate__c
    DateTime submissionStartDate = null;
    
    // Records to save
    List<Mana_Food_Consumption_Record__c> recordsToSave = new List<Mana_Food_Consumption_Record__c>();
    
    // Food Map
    Map<String, Id> foodMap = ManaFoodConsumptionConfig.foodMap;
    
    // sourcePrefixMap
    Map<String, String> sourcePrefixMap = ManaFoodConsumptionConfig.sourcePrefixMap;
    
    // foodExceptions
    Map<String, Id> foodExceptions = ManaFoodConsumptionConfig.foodExceptions;
    
    public ManaFoodConsumptionSubmissionHandler(Mana_Food_Consumption_Submission__c submissionToHandle) {
    	submission = submissionToHandle;
    	
    	// Create the code Lookup Table
    }
    
    public void addFoodRecord(String foodName, String sourceType) {
		// Get source amount
		String sourcePrefix = sourcePrefixMap.get(sourceType);
		String amountQuestionName = config.getAmountBinding(sourcePrefix, foodName);
		
		if (answersMap.containsKey(amountQuestionName)) {
			Decimal amount = Decimal.valueof(answersMap.get(amountQuestionName));
			
			// Setup the record
    		Mana_Food_Consumption_Record__c record = new Mana_Food_Consumption_Record__c();
			record.Household__c = submission.Household__c;
			record.Submission__c = submission.Id;
			record.Food__c = foodMap.get(foodName);
			record.Source__c = sourceType;
			record.Number_Consumed__c = amount;
			record.Collection_Date__c = submissionStartDate;
			
			// See if there's a code, if this food isn't one of the exceptions
			if (!foodExceptions.containsKey(foodName)) {
				String codeQuestionName = config.getCodeBinding(sourcePrefix, foodName);
				if (answersMap.containsKey(codeQuestionName)) {
					String code = answersMap.get(codeQuestionName);
					
					// Get code id from lookup table
					Id foodId = foodMap.get(foodName);
					record.Quantity_Code__c = config.codeLookupTable.get(foodId).get(code);
				}
			}
			
			// Save record
			recordsToSave.add(record);				
		}
    }
    
    public void handle() {
    	for(gfsurveys__Answer__c[] answers: [SELECT gfsurveys__Submission__r.gfsurveys__startDate__c,
    											gfsurveys__Question__c, 
    											gfsurveys__Question__r.Name, 
    											gfsurveys__Value__c 
    										FROM gfsurveys__Answer__c 
    										WHERE gfsurveys__Submission__c =: submission.Submission__c 
    										AND gfsurveys__Question__r.Name like :questionNamePrefix]) {
    		for (gfsurveys__Answer__c answer: answers) {
    			// Index all answers by questionName
    			answersMap.put(answer.gfsurveys__Question__r.Name.toLowerCase(), answer.gfsurveys__Value__c);
    			
    			// If submissionStartDate is null, set it
    			if (submissionStartDate == null) {
    				submissionStartDate = answer.gfsurveys__Submission__r.gfsurveys__startDate__c;
    			}
    		}
    	}
    	
    	// Go through all the foods and find their answers
    	Set<String> foods = foodMap.keySet();
    	for (String foodName: foods) {
    		// Barter
    		addFoodRecord(foodName, barterType);
    		
    		// Purchase
    		addFoodRecord(foodName, purchaseType);
    		
    		// Other
    		addFoodRecord(foodName, otherType);
    		
    		// Production
    		addFoodRecord(foodName, productionType);	
    	}
    	
    	// Finally save the records
    	if (recordsToSave.size() > 0) {
    		insert recordsToSave;
    	}
    }
}