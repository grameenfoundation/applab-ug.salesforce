/**
 *
 * Copyright (c) 2015 Grameen Foundation
 *
 *  Processes Search Logs by
 *	discovering the GAPs knowledge a farmer acquired
 *
 *  Tests are in SearchServerTests
 **/
global class SearchLogsGAPSKnowledgeMining implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global final String BANANA_FOCUS_FARMER_TYPE = 'Banana';
	global final String COFFEE_FOCUS_FARMER_TYPE = 'Coffee';
	global final String MAIZE_FOCUS_FARMER_TYPE = 'Maize';
	global final String KNOWLEDGE_PICKLIST_SOURCE = 'Search';
	global final String KNOWLEDGE_MENU_LABEL = 'CKW 3.0 Search';
	public static final String KNOWLEDGE_BANANA_MENUITEM = 'Banana Gaps';
	public static final String KNOWLEDGE_COFFEE_MENUITEM = 'Coffee Gaps';
	public static final String KNOWLEDGE_MAIZE_MENUITEM = 'Maize GAPs';
	
	global SearchLogsGAPSKnowledgeMining(String query) {
		this.query = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Search_Log__c> logs){

		List<Id> intervieweeIds = new List<Id>();
		//get person Ids from search logs
		for(Search_Log__c log : logs) {
			intervieweeIds.add(log.Interviewee__c);
		}
		
		//process banana logs
		List<Focus_Farmer__c> bananaFFs = getFocusFarmersByTypeAndPersonIds(intervieweeIds, BANANA_FOCUS_FARMER_TYPE);
		List<Banana_Farmer__c> bananaFarmers = getBananaFarmersByFFIds(bananaFFs);
		List<Banana_Farmer_GAPs_Selection__c> bananaGapsSelected = getTheirBananaGapsSelected(bananaFarmers);
		List<Banana_GAPs_Knowledge__c> bananaKnowledge = new List<Banana_GAPs_Knowledge__c>();
		for(Search_Log__c log : logs) {
			Banana_GAPs_Knowledge__c knowledge = new Banana_GAPs_Knowledge__c();
			knowledge.Knowledge_Discussion_Date__c = Date.valueOf(log.Submission_GPS_Timestamp__c);
			Banana_Farmer_GAPs_Selection__c selection = findBananaGapsSelection(log, bananaGapsSelected, bananaFarmers);
			knowledge.Banana_Farmer_GAPs_Selection__c = selection == null ? null : selection.Id;
			knowledge.Source__c = KNOWLEDGE_PICKLIST_SOURCE;
			knowledge = findBananaKnowledgeDiscussed(knowledge, log);
			//only if there exists a gaps selection. 
			//this skips logs from unprofiled farmers
			if(knowledge != null && selection != null) {
				bananaKnowledge.add(knowledge);
			}
		}
		insert bananaKnowledge;	
		
		//process coffee logs
		List<Focus_Farmer__c> coffeeFFs = getFocusFarmersByTypeAndPersonIds(intervieweeIds, COFFEE_FOCUS_FARMER_TYPE);
		List<Coffee_Farmer__c> coffeeFarmers = getCoffeeFarmersByFFIds(coffeeFFs);
		List<Coffee_Farmer_GAPs_Selection__c> coffeeGapsSelected = getTheirCoffeeGapsSelected(coffeeFarmers);
		List<Coffee_GAPs_Knowledge__c> coffeeKnowledge = new List<Coffee_GAPs_Knowledge__c>();
		for(Search_Log__c log : logs) {
			Coffee_GAPs_Knowledge__c knowledge = new Coffee_GAPs_Knowledge__c();
			knowledge.Knowledge_Discussion_Date__c = Date.valueOf(log.Submission_GPS_Timestamp__c);
			Coffee_Farmer_GAPs_Selection__c selection = findCoffeeGapsSelection(log, coffeeGapsSelected, coffeeFarmers);
			knowledge.Coffee_Farmer_GAPs_Selection__c = selection == null ? null : selection.Id;
			knowledge.Source__c = KNOWLEDGE_PICKLIST_SOURCE;
			knowledge = findCoffeeKnowledgeDiscussed(knowledge, log);
			if(knowledge != null && selection != null) {
				coffeeKnowledge.add(knowledge);
			}
		}
		insert coffeeKnowledge;
				
		//process maize logs
		List<Focus_Farmer__c> maizeFFs = getFocusFarmersByTypeAndPersonIds(intervieweeIds, MAIZE_FOCUS_FARMER_TYPE);
		List<Maize_Farmer__c> maizeFarmers = getMaizeFarmersByFFIds(maizeFFs);
		List<Maize_Farmer_GAPs_Selection__c> maizeGapsSelected = getTheirMaizeGapsSelected(maizeFarmers);
		List<Maize_GAPs_Knowledge__c> maizeKnowledge = new List<Maize_GAPs_Knowledge__c>();
		for(Search_Log__c log : logs) {
			Maize_GAPs_Knowledge__c knowledge = new Maize_GAPs_Knowledge__c();
			knowledge.Knowledge_Discussion_Datetime__c = Date.valueOf(log.Submission_GPS_Timestamp__c);
			Maize_Farmer_GAPs_Selection__c selection = findMaizeGapsSelection(log, maizeGapsSelected, maizeFarmers);
			knowledge.Maize_Farmer_GAPs_Selection__c = selection == null ? null : selection.Id;
			knowledge.Source__c = KNOWLEDGE_PICKLIST_SOURCE;
			knowledge = findMaizeKnowledgeDiscussed(knowledge, log);
			if(knowledge != null && selection != null) {
				maizeKnowledge.add(knowledge);
			}
		}		
		insert maizeKnowledge;
	}
	
	global void finish(Database.BatchableContext BC) {
		
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
      
		List<Banana_GAPs_Knowledge__c> banana = [SELECT Id FROM Banana_GAPs_Knowledge__c WHERE Source__c = 'Search' AND CreatedDate = TODAY];
		List<Coffee_GAPs_Knowledge__c> coffee = [SELECT Id FROM Coffee_GAPs_Knowledge__c WHERE Source__c = 'Search' AND CreatedDate = TODAY];
		List<Maize_GAPs_Knowledge__c> maize = [SELECT Id FROM Maize_GAPs_Knowledge__c WHERE Source__c = 'Search' AND CreatedDate = TODAY];
		List<Search_Log__c> logs = [SELECT Id FROM Search_Log__c WHERE Server_Entry_Time__c = YESTERDAY];
		//notify
		String[] toAddresses = new String[] {'uganda_tech@grameenfoundation.org'}; 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(toAddresses[0]);
		mail.setSenderDisplayName('CKW 3.0');
		mail.setSubject('Search Logs GAPS Knowledge Processed');
		mail.setHtmlBody('<p><b>' + logs.size() + '</b> Search Logs Processed. </p>'+
     		'<p><b>' + banana.size() + coffee.size() + maize.size() + '</b> Knowledge Records Created. </p>' +
     		'<p><b>' + a.NumberOfErrors + '</b> Errors</p>');
	}	
	
	private static List<Focus_Farmer__c> getFocusFarmersByTypeAndPersonIds(List<Id> personIds, String farmerType) {
		return [
			SELECT
				Id,
				Name,
				Farmer_Type__c
			FROM
				Focus_Farmer__c
			WHERE
				Person__c IN :personIds AND
				Farmer_Type__c = :farmerType
		];
	}
		
	// begin banana methods
	private static List<Banana_Farmer__c> getBananaFarmersByFFIds(List<Focus_Farmer__c> focusFarmers) {
		return [
			SELECT
				Id,
				Name,
				Person_ID__c,
				Registered_By__c
			FROM
				Banana_Farmer__c
			WHERE
				Focus_Farmer__c IN :focusFarmers
		];
	}
	
	private static List<Banana_Farmer_GAPs_Selection__c> getTheirBananaGapsSelected(List<Banana_Farmer__c> farmers) {
		return [
			SELECT
				Id,
				Name,
				Farmer_Identifier__c
			FROM
				Banana_Farmer_GAPs_Selection__c
			WHERE
				Banana_Farmer__c IN :farmers
		];
	}
	
	private static Banana_Farmer_GAPs_Selection__c findBananaGapsSelection(Search_Log__c log, List<Banana_Farmer_GAPs_Selection__c> gapsSelected, 
			List<Banana_Farmer__c> farmers) {
		
		for(Banana_Farmer_GAPs_Selection__c gap : gapsSelected) {
			for(Banana_Farmer__c farmer : farmers) {
				if(gap.Farmer_Identifier__c == farmer.Name && farmer.Person_ID__c == log.Interviewee__r.Name) {
					return gap;
				}
			}
		}
		return null;
	}
	
	private static Banana_GAPs_Knowledge__c findBananaKnowledgeDiscussed(Banana_GAPs_Knowledge__c a_knowledge, Search_Log__c log) {
		
		Banana_GAPs_Knowledge__c knowledge = null;
		//first check with crop we are dealing with
		if(log.Query__c.containsIgnoreCase(KNOWLEDGE_BANANA_MENUITEM)) {
			
			knowledge = a_knowledge;
			if(log.Query__c.containsIgnoreCase('GAP 1:')) {
				
				knowledge.Discussed_Soil_Fertility_Management__c = 'Yes';
				knowledge.Soil_Fertility_Management_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Soil_Fertility_Management_Topics__c.getDescribe(), 'Type of fertilizers used');
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 2')) {
				//needs matching
				knowledge.Discussed_Pruning_Desuckering__c = 'Yes';
				knowledge.Pruning_desuckering_deleafing_topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Pruning_desuckering_deleafing_topics__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 3')) {
				
				knowledge.Discussed_Soil_and_Water_Conservation__c = 'Yes';
				knowledge.Soil_and_Water_Conservation_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Soil_and_Water_Conservation_Topics__c.getDescribe(), 'Soil and water conservation measures');
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 4')) {
				
				knowledge.Discussed_Providing_Support_for_Plants__c = 'Yes';
				knowledge.Providing_support_for_banana_plants__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Providing_support_for_banana_plants__c.getDescribe(), 'Providing support for banana plants');
			}		
			else if(log.Query__c.containsIgnoreCase('GAP 5')) {
				//matching required
				knowledge.Discussed_Proper_Record_Keeping__c = 'Yes';
				knowledge.Proper_record_keeping_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Proper_record_keeping_Topics__c.getDescribe(), null);
			}	
			else if(log.Query__c.containsIgnoreCase('GAP 6')) {
				
				knowledge.Discussed_Group_Production_and_Marketing__c = 'Yes';
				knowledge.Group_production_and_marketing_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Group_production_and_marketing_Topics__c.getDescribe(), 'Group production and marketing');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 7')) {
				
				knowledge.Discussed_Proper_and_Timely_Weed_Control__c = 'Yes';
				knowledge.Proper_and_timely_weed_control_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Proper_and_timely_weed_control_Topics__c.getDescribe(), 'Frequency of weeding ; Time of weeding');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 8')) {
				
				knowledge.Discussed_Pests_and_Diseases_Control__c = 'Yes';
				knowledge.Banana_pests_and_disease_control_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Banana_pests_and_disease_control_Topics__c.getDescribe(), 'Pest and disease control measures');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 9')) {
				
				knowledge.Discussed_Banana_Value_Addition__c = 'Yes';
				knowledge.Banana_value_addition_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Banana_value_addition_Topics__c.getDescribe(), 'Value addition');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 10')) {
				
				knowledge.Discussed_Easy_Access_to_Agro_Inputs__c = 'Yes';
				knowledge.Easily_access_agro_inputs_Topics__c = getSelectablePicklistValue(log, 
					Banana_GAPs_Knowledge__c.Easily_access_agro_inputs_Topics__c.getDescribe(), 'Obtaining quality agro-chemicals');
			}
		}
		return knowledge;
	}
	// end banana methods
	
	// begin coffee methods
	private static List<Coffee_Farmer__c> getCoffeeFarmersByFFIds(List<Focus_Farmer__c> focusFarmers) {
		return [
			SELECT
				Id,
				Name,
				Person_ID__c,
				Registered_By__c
			FROM
				Coffee_Farmer__c
			WHERE
				Focus_Farmer__c IN :focusFarmers
		];
	}
	
	private static List<Coffee_Farmer_GAPs_Selection__c> getTheirCoffeeGapsSelected(List<Coffee_Farmer__c> farmers) {
		return [
			SELECT
				Id,
				Name,
				Farmer_Identifier__c
			FROM
				Coffee_Farmer_GAPs_Selection__c
			WHERE
				Coffee_Farmer__c IN :farmers
		];
	}
	
	private static Coffee_Farmer_GAPs_Selection__c findCoffeeGapsSelection(Search_Log__c log, List<Coffee_Farmer_GAPs_Selection__c> gapsSelected, 
			List<Coffee_Farmer__c> farmers) {
		
		for(Coffee_Farmer_GAPs_Selection__c gap : gapsSelected) {
			for(Coffee_Farmer__c farmer : farmers) {
				if(gap.Farmer_Identifier__c == farmer.Name && farmer.Person_ID__c == log.Interviewee__r.Name) {
					return gap;
				}
			}
		}
		return null;
	}
	
	private static Coffee_GAPs_Knowledge__c findCoffeeKnowledgeDiscussed(Coffee_GAPs_Knowledge__c a_knowledge, Search_Log__c log) {
		
		Coffee_GAPs_Knowledge__c knowledge = null;
		//first check with crop we are dealing with
		if(log.Query__c.containsIgnoreCase(KNOWLEDGE_COFFEE_MENUITEM)) {
			
			knowledge = a_knowledge;
			if(log.Query__c.containsIgnoreCase('GAP 1:')) {
				//needs matching
				knowledge.Discussed_Soil_Fertility_Management__c = 'Yes';
				knowledge.Soil_fertility_management_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Soil_fertility_management_Topics__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 2')) {
				//needs matching
				knowledge.Discussed_Desuckering__c = 'Yes';
				knowledge.Coffee_desuckering_pruning_and_stumping__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Coffee_desuckering_pruning_and_stumping__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 3')) {
				
				knowledge.Discussed_Soil_and_Water_Conservation__c = 'Yes';
				knowledge.Soil_and_Water_Conservation_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Soil_and_Water_Conservation_Topics__c.getDescribe(), 'Soil and water conservation measures');
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 4')) {
				//needs matching
				knowledge.Discussed_On_farm_Value_Addition__c = 'Yes';
				knowledge.On_farm_coffee_value_addition_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.On_farm_coffee_value_addition_Topics__c.getDescribe(), null);
			}		
			else if(log.Query__c.containsIgnoreCase('GAP 5')) {
				//needs matching
				knowledge.Discussed_Proper_Farm_Record_Keeping__c = 'Yes';
				knowledge.Proper_Coffee_farm_record_keeping_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Proper_Coffee_farm_record_keeping_Topics__c.getDescribe(), null);
			}	
			else if(log.Query__c.containsIgnoreCase('GAP 6')) {
				
				knowledge.Discussed_Group_Production_and_Marketing__c = 'Yes';
				knowledge.Group_production_marketing_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Group_production_marketing_Topics__c.getDescribe(), 'Group production and marketing');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 7')) {
				//needs matching
				knowledge.Discussed_Proper_and_Timely_Weed_Control__c = 'Yes';
				knowledge.Proper_and_timely_weed_control_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Proper_and_timely_weed_control_Topics__c.getDescribe(), null);
			}
			else if(log.Query__c.containsIgnoreCase('GAP 8')) {
				
				knowledge.Discussed_Pests_and_Diseases_Control__c = 'Yes';
				knowledge.Coffee_Pests_and_Disease_Control_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Coffee_Pests_and_Disease_Control_Topics__c.getDescribe(), 'Ability to detect pest & disease attack ; Pest and disease control measures');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 9')) {
				
				knowledge.Discussed_Coffee_Processing__c = 'Yes';
				knowledge.Coffee_processing_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Coffee_processing_Topics__c.getDescribe(), 'Value addition');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 10')) {
				
				knowledge.Discussed_Easy_Access_to_Agro_Inputs__c = 'Yes';
				knowledge.Easily_access_agro_inputs_Topics__c = getSelectablePicklistValue(log, 
					Coffee_GAPs_Knowledge__c.Easily_access_agro_inputs_Topics__c.getDescribe(), 'Obtaining quality agro-chemicals');
			}
		}
		return knowledge;
	}
	// end banana methods
	
	// begin maize methods
	private static List<Maize_Farmer__c> getMaizeFarmersByFFIds(List<Focus_Farmer__c> focusFarmers) {
		return [
			SELECT
				Id,
				Name,
				Person_ID__c,
				Registered_By__c
			FROM
				Maize_Farmer__c
			WHERE
				Focus_Farmer__c IN :focusFarmers
		];
	}
	
	private static List<Maize_Farmer_GAPs_Selection__c> getTheirMaizeGapsSelected(List<Maize_Farmer__c> farmers) {
		return [
			SELECT
				Id,
				Name,
				Farmer_Identifier__c
			FROM
				Maize_Farmer_GAPs_Selection__c
			WHERE
				Maize_Farmer__c IN :farmers
		];
	}
	
	private static Maize_Farmer_GAPs_Selection__c findMaizeGapsSelection(Search_Log__c log, List<Maize_Farmer_GAPs_Selection__c> maizeGapsSelected, 
			List<Maize_Farmer__c> maizeFarmers) {
		
		for(Maize_Farmer_GAPs_Selection__c gap : maizeGapsSelected) {
			for(Maize_Farmer__c farmer : maizeFarmers) {
				if(gap.Farmer_Identifier__c == farmer.Name && farmer.Person_ID__c == log.Interviewee__r.Name) {
					return gap;
				}
			}
		}
		return null;
	}
	
	private static Maize_GAPs_Knowledge__c findMaizeKnowledgeDiscussed(Maize_GAPs_Knowledge__c a_knowledge, Search_Log__c log) {
		
		Maize_GAPs_Knowledge__c knowledge = null;
		//first check with crop we are dealing with
		if(log.Query__c.containsIgnoreCase(KNOWLEDGE_MAIZE_MENUITEM)) {
			
			knowledge = a_knowledge;
			if(log.Query__c.containsIgnoreCase('GAP 1:')) {
				
				knowledge.Discussed_Land_Preparation__c = 'Yes';
				knowledge.Proper_and_timely_land_preparation_Topic__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Proper_and_timely_land_preparation_Topic__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 2')) {
				
				knowledge.Discussed_Proper_Planting__c = 'Yes';
				knowledge.Proper_planting_Topics__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Proper_planting_Topics__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 3')) {
				
				knowledge.Discussed_Seed_Selection__c = 'Yes';
				knowledge.Proper_seed_selection_Topics__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Proper_seed_selection_Topics__c.getDescribe(), null);
			}			
			else if(log.Query__c.containsIgnoreCase('GAP 4')) {
				
				knowledge.Discussed_Soil_Fertility_Management__c = 'Yes';
				knowledge.Proper_soil_fertility_management_Topics__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Proper_soil_fertility_management_Topics__c.getDescribe(), null);
			}		
			else if(log.Query__c.containsIgnoreCase('GAP 5')) {
				//matching required
				knowledge.Discussed_Pests_and_Diseases__c = 'Yes';
				knowledge.Pest_and_disease_identification__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Pest_and_disease_identification__c.getDescribe(), null);
			}	
			else if(log.Query__c.containsIgnoreCase('GAP 6')) {
				//matching required
				knowledge.Discussed_Harvesting_and_PHH__c = 'Yes';
				knowledge.Harvesting_and_PHH__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Harvesting_and_PHH__c.getDescribe(), 'Harvesting and PHH Practices');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 7')) {
				//matching required
				knowledge.Discussed_Bulk_Marketing__c = 'Yes';
				knowledge.Bulking_Marketing__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Bulking_Marketing__c.getDescribe(), 'Bulking and marketing');
			}
			else if(log.Query__c.containsIgnoreCase('GAP 8')) {
				//matching required
				knowledge.Discussed_Record_Keeping__c = 'Yes';
				knowledge.Proper_Record_Keeping_Topics__c = getSelectablePicklistValue(log, 
					Maize_GAPs_Knowledge__c.Proper_Record_Keeping_Topics__c.getDescribe(), 'Bulking and marketing');
			}
		}
		return knowledge;
	}
	//end maize methods
	
	private static String getSelectablePicklistValue(Search_Log__c log, Schema.DescribeFieldResult picklist, String defaultValue) {
		List<Schema.PicklistEntry> picklistValues = picklist.getPicklistValues();
		for(Schema.PicklistEntry item : picklistValues) {
			if(log.Query__c.containsIgnoreCase(item.getLabel())) {
				return item.getLabel();
			}
		}
		return 	defaultValue;
	}
}