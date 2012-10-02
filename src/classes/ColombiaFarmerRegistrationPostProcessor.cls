public class ColombiaFarmerRegistrationPostProcessor {

	/**
	 *  Static class to deal with the auto registration of a Farmer from the surveys submitted by
	 *  the recruitment team and the Farmer themselves.
	 */

	/**
	 *  Process the initial registration form submitted by the recruitment team.
	 *  Will create the Person__c and Farmer__c object for this new potential Farmer.
	 *  For the moment the handset will need to be manually registered to the Farmer
	 *
	 *  @param answers   - A map containing the values for the registration
	 *                       The keys are <binding>_<instance> for compatibility
	 *  @param recruiter - The Person__c object for the recruiter who submitted the form
	 *
	 *  @return - A three element list of Strings with the following format
	 *              element 1 - Binary indicator of success (0 = fail, 1 = success)
	 *              element 2 - Error message if required for the logs and tech team
	 *              element 3 - Message body to the Farmer if required.
	 */
	public static List<String> processSubmission(ProcessSurveySubmission.SurveySubmission surveySubmission, Map<String, Submission_Answer__c> answers, Person__c recruiter) {

		List<String> returnValues = new List<String>();
		Person__c person = new Person__c();
		LAC_Farmer__c farmer = new LAC_Farmer__c();

		// Some farmer details
		String hasCedula = (String)ProcessSubmissionHelpers.extractAnswer(answers,'HasCedula_0','N');
		String farmerId = '';
		if(hasCedula.equalsIgnoreCase('Y')) {
			farmerId = (String)ProcessSubmissionHelpers.extractAnswer(answers,'Cedula_0','');
		} else {
			farmerId = (String)ProcessSubmissionHelpers.extractAnswer(answers,'AltIDNumber_0','');
		}

		Boolean isNewFarmer;

		// Try to load farmer
		farmer = loadLacFarmer(farmerId);
		if(null != farmer) {
			isNewFarmer = false;
			person = farmer.Person__r;
		} else {
			farmer = new LAC_Farmer__c();
			isNewFarmer = true;
		}

		// For this all the instance numbers will be 0
		person.First_Name__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'FirstName_0');
		person.Last_Name__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'LastName_0');
		person.Type__c = 'Farmer';

		// Gender
		person.Gender__c = translateGender((String)ProcessSubmissionHelpers.extractAnswer(answers,'Gender_0', 'M'));
		person.Ethnicity__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'Ethnicity_0');
		String employmentStatus = (String)ProcessSubmissionHelpers.extractAnswer(answers,'Employment_0', 'N/A');

		// Location where the survey was done (this is the automatic one, since there's no location question in this survey)
		String gpsResponse = (String)ProcessSubmissionHelpers.extractAnswer(answers,'GPS_0');
		if((null == gpsResponse) || gpsResponse.equals('')) {
			// Try to get the ones within the survey
			person.GPS_Location_E__c = surveySubmission.interviewLongitude;
			person.GPS_Location_N__c = surveySubmission.interviewLatitude;
		} else {
			// Parse the GPS string
			String[] locationArray = gpsResponse.split(' ');
			if (locationArray != null && locationArray.size() >= 2) {
				person.GPS_Location_E__c = locationArray[0];
				person.GPS_Location_N__c = locationArray[1];
			}
		}

		// DOB comes in with the format YYYY-MM-dd (2011-09-30)
		person.Date_of_Birth__c = (Date)ProcessSubmissionHelpers.extractAnswer(answers,'Birthdate_0', (Date) null, ProcessSubmissionHelpers.DATE_TYPE);

		// Some farmer details
		farmer.Name = farmerId;
		farmer.Health_Care_System__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'Health_0');
		farmer.Marginalized_Type__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'MarginalizedType_0');
		farmer.Household_Head__c = ((String)ProcessSubmissionHelpers.extractAnswer(answers,'HouseholdHead_0')=='S')?'Yes':'No';
		// Missing: Farmer.Population_Type__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'???');
		farmer.Registration_at_the_Farm__c = translateRegistrationAtFarm(((Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'FarmLocalYes_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE)).intValue());

		// Phone number
		if(((String)ProcessSubmissionHelpers.extractAnswer(answers,'PhoneOwnership_0', 'N')).equals('Y')) {
			person.Raw_Mobile_Number__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'MobileNumber_0');
			farmer.Phone_Brand__c = translatePhoneBrand(((Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'MobileBrand_0', null, ProcessSubmissionHelpers.DECIMAL_TYPE)).intValue());
			farmer.Phone_Model__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'MobileModel_0');
		}

		// Photo
		if(!((String)ProcessSubmissionHelpers.extractAnswer(answers,'Photo_0', '')).equals('')) {
			person.Photo__c = '<img src = "'+ (String)ProcessSubmissionHelpers.extractAnswer(answers,'Photo_0') +'" target="_blank" />';
		}

		// Set a rollback point
		Savepoint sp = Database.setSavepoint();

		// Save the person and get the id back
		String errorMessage;
		Database.SaveResult personSaveResult = database.insert(person);
		Id personId;
		if (!personSaveResult.isSuccess()) {
			returnValues.add('0');
			for (Database.Error error : personSaveResult.getErrors()) {

				// Build up the error message
				errorMessage = errorMessage + error.getMessage() + ' ';
			}
			returnValues.add(errorMessage);
			returnValues.add('Your submission of the farmer survey (for farmer with ID: ' + farmer.Name + ' had an error in it please check the form. If you repeatedly get this message contact support');
			Database.rollback(sp);
			return returnValues;
		}
		personId = personSaveResult.getId();

		// Populate and save the Farmer
		farmer.Person__c = personId;

		Database.SaveResult FarmerSaveResult = database.insert(Farmer);
		if (!FarmerSaveResult.isSuccess()) {
			returnValues.add('0');
			for (Database.Error error : FarmerSaveResult.getErrors()) {

				// Build up the error message
				errorMessage = errorMessage + error.getMessage() + ' ';
			}
			returnValues.add(errorMessage);
			returnValues.add('Your submission of the farmer survey (for farmer with ID: ' + farmer.Name + '  had an error in it please check the form. If you repeatedly get this message contact support');
			Database.rollback(sp);
			return returnValues;
		}

		// Household stuff
		// Check if they have included a household
		if((String)ProcessSubmissionHelpers.extractAnswer(answers,'PrevHHRegistration_0') == 'KnowCedula') {
			String linkedFarmerId = (String)ProcessSubmissionHelpers.extractAnswer(answers,'HHID_0');
			if((!linkedFarmerId.equals('')) && (!linkedFarmerId.equals(farmer.Name))) {
				// Try to load the linked farmer
				Lac_Farmer__c linkedFarmer = loadLacFarmer(linkedFarmerId);
				if((null != linkedFarmer) && (linkedFarmer.Person__r.Person_Household__c != null)) {
					person.Person_Household__c = linkedFarmer.Person__r.Person_Household__c;
					update person;
				} else {
					// Add error message but do not rollback. When (if) the new data comes in, we'll update the records
					returnValues.add('2');
					returnValues.add(errorMessage);
					returnValues.add('The farmer with ID: ' + farmer.Name + '  has to fill in the household questions.');
				}
			} else {
				// TODO: What do we do?
			}
		} else if((String)ProcessSubmissionHelpers.extractAnswer(answers,'PrevHHRegistration_0') == 'KnowName') {
			// Check if the name was used
			String linkedFarmerName = (String)ProcessSubmissionHelpers.extractAnswer(answers,'NameHHHead_0');
			if(!linkedFarmerName.equals('')) {
				// Try to find the person? The name's likely to be in-accurate
				// So, we just save the name on the farmer object
				farmer.Household_Head_Name__c = linkedFarmerName;
				update farmer;
			} else {
				// TODO: What do we do?
			}
		} else {
			// We need to create a new household
			Person_household__c household = null;
			Farm__c farm = null;
			if(isNewFarmer) {
				household = new Person_Household__c();
				farm = new Farm__c();
			} else {
				household = person.Person_Household__r;
				farm = loadFarm(household.Id);
				if(null == farm) {
					farm = new Farm__c();
					farm.Person_Household__c = household.Id;
				}
			}

			// Farm info
			household.Family_Size__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HHSize_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			household.PPI_Administered_at_Household__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'RegLocal_0');
			household.Utilities__c =  ((String)ProcessSubmissionHelpers.extractAnswer(answers,'PublicServicesHH_0')).replace(' ',';');

			// Farm info
			farm.Farm_Number__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'FarmNumber_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Type_of_Tenancy__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'Tenency_0');
			farm.Area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresFarm_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Crops__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CashCrops_0');
			farm.Cocoa_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresCacao_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Banana_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresBanana_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Plantain_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresPlatano_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Coffee_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresCafe_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Horticulture_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresHorticulture_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.Palm_area__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'HectaresPalm_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.ProcCertCacao__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'ProcCertCacao_0');
			farm.CertCacao__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertCacao_0');
			farm.OtherCertCacao__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertCacao_0');
			farm.ProcCertBananao__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'ProcCertBananao_0');
			farm.CertBanano__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertBanano_0');
			farm.OtherCertBanano__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertBanano_0');
			farm.ProcCertPlatano__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'ProcCertPlatano_0');
			farm.CertPlantano__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertPlantano_0');
			farm.OtherCertPlantano__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertPlatano_0');
			farm.ProcCertCafe__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'ProcCertCafe_0');
			farm.CertCafe__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertCafe_0');
			farm.OtherCertCafe__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertCafe_0');
			farm.ProcCertHoney__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'ProcCertHoney_0');
			farm.CertHoney__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertHoney_0');
			farm.OtherCertHoney__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertHoney_0');
			farm.CertProcHorticulture__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertProcHorticulture_0');
			farm.CertHorticulture__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'CertHorticulture_0');
			farm.OtherCertHorticulture__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'OtherCertHorticulture_0');
			farm.Other_Crops__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'TopThreeOtherCrops_c');
			farm.MainFruit__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'MainFruit_0');
			farm.LivestockType__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'LivestockType_0');
			farm.GeoCode__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'GeoCode_0');
			farm.LoanVendor__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'LoanVendor_0');
			farm.LoanUse__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'LoanUse_0');
			farm.LoanDisaster__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'LoanDisaster_0');
			farm.LoanAmount__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'LoanAmount_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);
			farm.LoanTerm__c = (Decimal)ProcessSubmissionHelpers.extractAnswer(answers,'LoanTerm_0', 0, ProcessSubmissionHelpers.DECIMAL_TYPE);

			if(isNewFarmer) {
				Database.SaveResult householdSaveResult = database.insert(household);
				person.Person_Household__c = householdSaveResult.Id;
				update person;

				farm.Person_Household__c = householdSaveResult.Id;
				insert farm;
			} else {
				update household;
				update farm;
			}
		}

		// PPI: Always create a new one
		PPI_Data__c ppi = new PPI_Data__c();
		
		// submissionStartTime is a milli-timestamp, so we convert it to a date
		ppi.Date__c = Utils.getDateFromMillisecondTimestamp(surveySubmission.submissionStartTime);

		ppi.Person__c = person.Id;
		ppi.Version__c = surveySubmission.submissionStartTime; // TODO: Figure out a better way to store this
		ppi.Country__c = 'Colombia';
		ppi.Question_1__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_1_0', '0');
		ppi.Question_2__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_2_0', '0');
		ppi.Question_3__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_3_0', '0');
		ppi.Question_4__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_4_0', '0');
		ppi.Question_5__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_5_0', '0');
		ppi.Question_6__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_6_0', '0');
		ppi.Question_7__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_7_0', '0');
		ppi.Question_8__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_8_0', '0');
		ppi.Question_9__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_9_0', '0');
		ppi.Question_10__c = (String)ProcessSubmissionHelpers.extractAnswer(answers,'PPI_10_0', '0');
		insert ppi;

		returnValues.add('1');
		returnValues.add('Successfully saved the Farmer registration');
		returnValues.add('SUPRESSMSG');
		return returnValues;
	}

	private static Lac_Farmer__c loadLacFarmer(String farmerId) {
		Lac_Farmer__c[] farmer = [Select Id, Person__r.Id, Person__r.Person_Household__c from Lac_Farmer__c where Name = :farmerId limit 1];
		if(farmer.size() > 0) {
			return farmer[0];
		}
		return null;
	}

	private static Farm__c loadFarm(String householdId) {
		Farm__c[] farm = [Select Id from Farm__c where Person_Household__c = :householdId limit 1];
		if(farm.size() > 0) {
			return farm[0];
		}
		return null;
	}

	private static String translateGender(String option) {
		if (option.equals('M')) {
			return 'Male';
		}
		return 'Female';
	}

	private static String translateRegistrationAtFarm(Integer optionNumber) {
		if(optionNumber == 1) {
			return 'Yes';
		}
		return 'No';
	}

	private static String translatePhoneBrand(Integer optionNumber) {
		Map<Integer, String> brands = new Map<Integer, String>();
		brands.put(1, 'Nokia');
		brands.put(2, 'Samsung');
		brands.put(3, 'Motorola');
		brands.put(4, 'Huawei');
		brands.put(5, 'Alvo');
		brands.put(6, 'Alcatel');
		brands.put(7, 'Lg');
		brands.put(8, 'Sony Ericsson');
		brands.put(9, ' Blackberry');
		brands.put(10, 'Apple');

		if(brands.containsKey(optionNumber)) {
			return brands.get(optionNumber);
		} 

		return 'Other';
	}

	static testMethod void testProcessFarmerReg() {

		// Create the test person
		Person__c person = Utils.createTestPerson(null, 'TestRegBE2SF', true, null, 'Female');

		// Create a test Organisation
		Account org = Utils.createTestOrganisation('TestOrg1');
		database.insert(org);

		// Create a test Organisation
		Account org2 = Utils.createTestOrganisation('TestOrg2');
		database.insert(org2);

		// Test successful registration
		ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
		surveySubmission.imei = person.Handset__r.IMEI__c;
		surveySubmission.farmerId = '';
		surveySubmission.surveySize = '2345';
		surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
		surveySubmission.interviewLatitude = '0.31950';
		surveySubmission.interviewLongitude = '32.58986';
		surveySubmission.interviewAltitude = '55.00000';
		surveySubmission.interviewAccuracy = '0.00000';
		surveySubmission.submissionLatitude = '0.31950';
		surveySubmission.submissionLongitude = '32.58986';
		surveySubmission.submissionAltitude = '55.00000';
		surveySubmission.submissionAccuracy = '0.00000';
		surveySubmission.submissionGPSTimestamp = '';
		surveySubmission.handsetSubmitTime = '1340627903000';
		surveySubmission.submissionStartTime = '1340627903000';

		Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
		answers.put('FirstName_0', Utils.createTestSubmissionAnswer(null, 'FirstName', 'Simon', '', '', 0));
		answers.put('LastName_0', Utils.createTestSubmissionAnswer(null, 'LastName', 'George', '', '', 0));
		answers.put('Gender_0', Utils.createTestSubmissionAnswer(null, 'Gender', 'M', '', '', 0));
		answers.put('Ethnicity_0', Utils.createTestSubmissionAnswer(null, 'Ethnicity', 'Mestizo', '', '', 0));
		answers.put('Employment_0', Utils.createTestSubmissionAnswer(null, 'Employment', 'WorksCompanyPT', '', '', 0));
		answers.put('Birthdate_0', Utils.createTestSubmissionAnswer(null, 'Birthdate', '2012-06-25', '', '', 0));
		answers.put('Health_0', Utils.createTestSubmissionAnswer(null, 'Health', 'Sisben', '', '', 0));
		answers.put('MarginalizedType_0', Utils.createTestSubmissionAnswer(null, 'MarginalizedType', 'Displaced', '', '', 0));
		answers.put('HouseholdHead_0', Utils.createTestSubmissionAnswer(null, 'HouseholdHead', 'S', '', '', 0));
		answers.put('FarmLocalYes_0', Utils.createTestSubmissionAnswer(null, 'FarmLocalYes', '1', '', '', 0));
		answers.put('PhoneOwnership_0', Utils.createTestSubmissionAnswer(null, 'PhoneOwnership', 'Y', '', '', 0));
		answers.put('MobileNumber_0', Utils.createTestSubmissionAnswer(null, 'MobileNumber', '6463212691', '', '', 0));
		answers.put('MobileBrand_0', Utils.createTestSubmissionAnswer(null, 'MobileBrand', '1', '', '', 0));
		answers.put('MobileModel_0', Utils.createTestSubmissionAnswer(null, 'MobileModel', '6110', '', '', 0));
		answers.put('FarmNumber_0', Utils.createTestSubmissionAnswer(null, 'FarmNumber', '1', '', '', 0));
		answers.put('Tenency_0', Utils.createTestSubmissionAnswer(null, '', 'Tenency', 'Own', '', 0));
		answers.put('HasCedula_0',Utils.createTestSubmissionAnswer(null, 'HasCedula', 'Y', '', '', 0));
		answers.put('Cedula_0',Utils.createTestSubmissionAnswer(null, 'Cedula', '12345', '', '', 0));
		answers.put('AltIDNumber_0',Utils.createTestSubmissionAnswer(null, 'AltIDNumber', '67890', '', '', 0));
		answers.put('Photo_0',Utils.createTestSubmissionAnswer(null, 'Photo', '', '', '', 0));
		answers.put('GPS_0',Utils.createTestSubmissionAnswer(null, 'GPS', '', '', '', 0));
		answers.put('PrevHHRegistration_0',Utils.createTestSubmissionAnswer(null, 'PrevHHRegistration', '', '', '', 0));
		answers.put('HHID_0',Utils.createTestSubmissionAnswer(null, 'HHID', '', '', '', 0));
		answers.put('HHSize_0',Utils.createTestSubmissionAnswer(null, 'HHSize', '3', '', '', 0));
		answers.put('RegLocal_0',Utils.createTestSubmissionAnswer(null, 'RegLocal', '3', '', '', 0));
		answers.put('PublicServicesHH_0',Utils.createTestSubmissionAnswer(null, 'PublicServicesHH', '3', '', '', 0));
		answers.put('FarmNumber_0',Utils.createTestSubmissionAnswer(null, 'FarmNumber', '3', '', '', 0));
		answers.put('Tenency_0',Utils.createTestSubmissionAnswer(null, 'Tenency', '3', '', '', 0));
		answers.put('HHSize_0',Utils.createTestSubmissionAnswer(null, 'HHSize', '3', '', '', 0));
		answers.put('HectaresFarm_0',Utils.createTestSubmissionAnswer(null, 'HectaresFarm', '3', '', '', 0));
		answers.put('CashCrops_0',Utils.createTestSubmissionAnswer(null, 'HHSize', '3', '', '', 0));
		answers.put('HectaresCacao_0',Utils.createTestSubmissionAnswer(null, 'HHSize', '3','', '', 0));
		answers.put('HectaresBanana_0',Utils.createTestSubmissionAnswer(null, 'HHSize', '3','', '', 0));

		List<String> result = processSubmission(surveySubmission, answers, person);
		System.debug(LoggingLevel.INFO, result.get(0) + ' ' + result.get(1));
	}
}