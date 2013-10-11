/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class carries out the EADD Surveys post-processing
 *  Its test methods are in the EADDDashboardTests class
 **/
public with sharing class ProcessEADDSurveys {

    /**
    *  Fill in the objects for this Hub Registration
    *  We expect one metric data for a hub in a month thus
    *  a need to check existance before creating a new metric
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object of the CKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the CKW if required.
    */	
	public static List<String> processEADDHubRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {
		
		String hubName = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0')).trim();
		System.debug('Registering Hub ' + hubName);
		String districtSelected = ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0'));
		String subcountyGiven = ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0'));
		Date dateOfCollection = Date.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q6_0')));
		decimal radiusCovered = decimal.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));		
		decimal suplliers = decimal.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0')));
		decimal volumes = decimal.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0')));
		decimal revenues = decimal.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q16_0')));
		decimal profits = decimal.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0')));
		String hubUtilization = ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0'));
		String location = ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0'));
		
		District__c[] district = database.query('SELECT Id, Name FROM District__c WHERE Name = :districtSelected');
		if(district.isEmpty()){
			return new String[]{ '0', 'The district provided is not in salesforce', 'SUPRESSMSG' };
		}
		Id districtId = district[0].Id;
		Subcounty__c[] subcounty = database.query(
									'SELECT '								+
										'Id, '								+
										'Display_Name__c '					+
									'FROM '									+
										'Subcounty__c '						+
									'WHERE '								+
										'Display_Name__c = :subcountyGiven '+	
										'AND District__c = :districtId'
									);
									
		if(subcounty.isEmpty()){
			return new String[]{ '0', 'The subcounty provided is not in salesforce or the district specified', 'SUPRESSMSG' };
		}
		Id subcountyId = subcounty[0].Id;
		
		//we need one record per month
		dateOfCollection = dateOfCollection.toStartOfMonth();
		EADD_Hub__c[] hubs = database.query(
								'SELECT '							+
									'Id, '							+
									'Name__c '						+
								'FROM '								+
									'EADD_Hub__c '					+
								'WHERE '							+
									'Date__c = :dateOfCollection '	+
									'AND Name__c = :hubName '		+
									'AND District__c = :districtId '+
									'AND Subcounty__c = :subcountyId'
								);
		
		EADD_Hub__c hub = hubs.isEmpty()? new EADD_Hub__c(): hubs[0];
		hub.Date__c = dateOfCollection;
		hub.District__c = districtId;
		hub.Farmers_served_by_hub__c = suplliers;
		hub.Hub_capacity_utilization__c = hubUtilization;
		hub.Milk_sale_profits__c = profits;
		hub.Milk_sale_revenue__c = revenues;
		hub.Milk_volumes_bulked__c =  volumes;
		hub.Name__c = hubName;
		hub.Subcounty__c = subcountyId;
		//we extract latitude and longitude from the GPS location
		hub.Longitude__c = location.split(' ')[1];
		hub.Latitude__c = location.split(' ')[0];
		hub.Radius_Covered__c = radiusCovered;
		if(hub.Id == null){
			insert hub;	
		} else {
			update hub;
		}
		return new String[]{ '1', 'EADD Hub Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
	}

    /**
    *  Fill in the objects for this Farmer Registration
    *  This farmer registration does not have Poverty Index data
    *  What is most important is verifying the District, Subcounty and then
    *  creating/updating metric datas to store info from the farmer
    *  Metric data is stored in the EADD_Farmer_extra_info__c object
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object of the CKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the CKW if required.
    */
	public static List<String> processEADDFarmerRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {
		
		String farmerName = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0')).trim();
		System.debug('Registering Hub ' + farmerName);
		integer age = integer.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')));
		String districtSelected = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));
		String subcountyGiven = ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0'));
		boolean accessesFinancialsServices = ProcessSubmissionHelpers.getAnswerString(answers.get('q14_0')) == 'Yes';
		boolean accessesAnimalHealth = ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0')) == 'Yes';
		boolean accessesAI = ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0')) == 'Yes';
		boolean accessesCheckoffServices = ProcessSubmissionHelpers.getAnswerString(answers.get('q16_0')) == 'Yes';
		boolean accessesTrainings = ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')) == 'Yes';
		boolean accessesFarmInputs = ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')) == 'Yes';
		boolean accessesFeeds = ProcessSubmissionHelpers.getAnswerString(answers.get('q13_0')) == 'Yes';
		boolean accessesTransportServices = ProcessSubmissionHelpers.getAnswerString(answers.get('q15_0')) == 'Yes';
		boolean usesAI = ProcessSubmissionHelpers.getAnswerString(answers.get('q17_0')) == 'Yes';
		boolean usesDrySeasonFeed = ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0')) == 'Yes';	
		boolean usesHQFeed = ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0')) == 'Yes';	
		boolean usesSupplementaries = ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0')) == 'Yes';	
		String gender = ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0'));
		
		DateTime submissionTime = ProcessSurveySubmission.getTimestamp(submission.submissionStartTime);
		Date submissionDate = submissionTime.date();
		//lets ensure one record per month
		submissionDate = submissionDate.toStartOfMonth();
		
		District__c[] district = database.query('SELECT Id, Name FROM District__c WHERE Name = :districtSelected');
		if(district.isEmpty()){
			return new String[]{ '0', 'The district provided is not in salesforce', 'SUPRESSMSG' };
		}
		Id districtId = district[0].Id;
		Subcounty__c[] subcounty = database.query(
									'SELECT '								+
										'Id, '								+
										'Display_Name__c '					+
									'FROM '									+
										'Subcounty__c '						+
									'WHERE '								+
										'Display_Name__c = :subcountyGiven '+
										'AND District__c = :districtId'
									);
		if(subcounty.isEmpty()){
			return new String[]{ '0', 'The subcounty provided is not in salesforce or the district specified', 'SUPRESSMSG' };
		}
		Id subcountyId = subcounty[0].Id;
		
		Farmer__c[] farmers = Utils.loadFarmerFromId(submission.farmerId);
		Farmer__c farmer = farmers[0];
		Id farmerId = farmer.Id;
		
		EADD_Farmer_extra_info__c[] infos = database.query(
											'SELECT '							+
												'Id, '							+
												'Farmer__c '					+
											'FROM '								+
												'EADD_Farmer_extra_info__c '	+
											'WHERE '							+
												'Date__c = :submissionDate '	+
												'AND Farmer__c = :farmerId'
											);
		
		EADD_Farmer_extra_info__c metricData = infos.isEmpty()? new EADD_Farmer_extra_info__c(): infos[0];
		metricData.Age__c = age;
		metricData.Date__c = submissionDate;
		metricData.District__c = districtId;
		metricData.Access_financial_services__c = accessesFinancialsServices;
		metricData.Gender__c =  gender;
		metricData.Access_AH__c =  accessesAnimalHealth;
		metricData.Accesses_AI__c =  accessesAI;
		metricData.Accesses_checkoff_services__c =  accessesCheckoffServices;
		metricData.Access_farmer_trainings__c =  accessesTrainings;
		metricData.Accesses_farm_inputs__c =  accessesFarmInputs;
		metricData.Accesses_feeds__c =  accessesFeeds;
		metricData.Access_transport_services__c = accessesTransportServices; 
		metricData.Name__c = farmerName;
		metricData.Subcounty__c = subcountyId;
		metricData.Uses_AI__c =  usesAI;
		metricData.Uses_dryseason_feeding__c = usesDrySeasonFeed; 
		metricData.Uses_highquality_feeds__c =  usesHQFeed;
		metricData.Uses_supplementary_feeding__c =  usesSupplementaries;
		metricData.Farmer__c = farmer.Id;
		if(metricData.Id == null){
			insert metricData;
		} else {
			update metricData;
		}
		
		return new String[]{ '1', 'EADD Farmer extra info Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
	}
}