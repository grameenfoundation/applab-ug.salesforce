/**
* A class to handle post processing of 
* all the E-warehouse surveys
*/
public with sharing class ProcessEwarehouseSurveys {
    
    /**
    *  Fill in the objects for this Farmer Registration
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object VKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the VKW if required.
    */
    public static List<String> processEwarehouseFarmerRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {
       
       // Check that this is not an existing farmer id
       Farmer__c[] farmers = Utils.loadFarmerFromId(ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')));
	   
	   // Commenting out the lines below after having had a chat with Nathan Were
       /**if (!farmers.isEmpty()) {
           return new String[]{ '0', 'The farm concern id used already belongs to someone else', 'SUPRESSMSG' };
       } **/ 
       // Create a Contact object for this farmer
       Contact contact = new Contact();

       // Create a Person object for the farmer
       Person__c person = new Person__c();
       String name = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
       System.debug('Farmer Name ' + name);
       if (String.isEmpty(name) || name == null) {
           return new String[]{ '0', 'The name question has not been answered', 'SUPRESSMSG' };
       }
	   name = name.replaceAll('\\s+',' ');
       String[] names = name.split(' ');
       if (names.size() >= 3) {
           contact.FirstName = names[0];
           contact.LastName = names[2];
           person.First_Name__c = names[0];
           person.Middle_Name__c = names[1];
           person.Last_Name__c = names[2];
       }
       else if (names.size() == 2) {
           contact.FirstName = names[0];
           contact.LastName = names[1];
           person.First_Name__c = names[0];
           person.Last_Name__c = names[1];          
       }
       else if (names.size() == 1) {
           return new String[]{ '0', 'Enter atleast 1 more name', 'SUPRESSMSG' };
       }
       String accountName = 'USAID';
       Account account = [Select Id from Account where Name = :accountName];
       contact.AccountId = account.Id;
       database.SaveResult[] contactSaveResult = database.insert(new Contact[]{contact});

       person.Gender__c = genderMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q26_0')));
       person.Contact__c = contactSaveResult[0].getId();
       person.Type__c = 'Farmer';
       String countryName = 'Kenya';
       Country__c country = [SELECT Id from Country__c WHERE Name = :countryName];
       person.Country__c = country.Id;
       person.ID_Number__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q11_0'), 'q11', true).toPlainString();
       String maritalStatus = maritalStatusMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q17_0')));
       if (maritalStatus.equalsIgnoreCase('Single')) {
           person.Next_Of_Kin__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0'));
           person.Next_Of_Kin_Telephone__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q21_0'));
       }
       else if (maritalStatus.equalsIgnoreCase('Married')) {
           person.Next_Of_Kin__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0'));
           person.Next_Of_Kin_Telephone__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0'));
       }
       person.Picture_URL__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0'));
       Decimal phoneNumber = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q13_0'), 'q13', true);
       if (phoneNumber == 0) {
           phoneNumber = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q14_0'), 'q14', true);
       }
       person.Raw_Mobile_Number__c = phoneNumber.toPlainString();
       database.saveResult[] personSaveResult = database.insert(new Person__c[]{person});
       String groupName = farmerGroupMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));
       if (groupName.equalsIgnoreCase('Other')) {
           groupName = ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0'));
       }
       Group__c[] personGroup = [Select Id, Group_ID__c, Name From Group__c Where Name =:groupName];
       Group__c farmerGroup = new Group__c();
       if (personGroup.isEmpty()) {
           farmerGroup = new Group__c();
           farmerGroup.Name = groupName;
           String[] tokens = ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')).split('/');
           farmerGroup.Group_ID__c = tokens[2];
           database.insert(farmerGroup);
       }
       else {
           farmerGroup = personGroup[0];
       }
       Person_Group_Association__c pga = new Person_Group_Association__c();
       pga.Group__c = farmerGroup.Id;
       pga.Person__c = personSaveResult[0].getId();
       database.insert(pga);
       // Create the poverty score card for the farmer
       PPI_Data__c farmerPPI = new PPI_Data__c();
       farmerPPI.Country__c = 'Kenya';
       farmerPPI.Date__c = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date();
       farmerPPI.Version__c = 'Kenya';
       farmerPPI.Question_1__c = householdMemberCount.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q31_0')));
       farmerPPI.Question_2__c = schoolGradeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q32_0')));
       farmerPPI.Question_3__c = businessTypeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q33_0')));
       farmerPPI.Question_4__c = habitableRoomsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q34_0')));
       farmerPPI.Question_5__c = mainDwellingFloorMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q35_0')));
       farmerPPI.Question_6__c = lightingSourceFuelMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q36_0')));
       farmerPPI.Question_7__c = ownsIronBoxMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q37_0')));
       farmerPPI.Question_8__c = mosquitoNetsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q38_0')));
       farmerPPI.Question_9__c = towelsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q39_0')));
       farmerPPI.Question_10__c = fryingPanCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q40_0')));
       farmerPPI.Person__c = personSaveResult[0].getId();
       farmerPPI.Contact__c = contactSaveResult[0].getId();
       farmerPPI.Score__c = householdMemberPpiScore.get(farmerPPI.Question_1__c)        +
                   schoolGradePpiScoreMap.get(farmerPPI.Question_2__c)                  +
                   businessTypePpiScoreMap.get(farmerPPI.Question_3__c)                 +
                   habitableRoomsPpiScoreMap.get(farmerPPI.Question_4__c)               +
                   mainDwellingFloorPpiScoreMap.get(farmerPPI.Question_5__c)            +
                   lightingSourceFuelPpiScoreMap.get(farmerPPI.Question_6__c)           +
                   ownsIronBoxPpiScoreMap.get(farmerPPI.Question_7__c)                  +
                   mosquitoNetsPpiScoreMap.get(farmerPPI.Question_8__c)                 +
                   towelsPpiScoreMap.get(farmerPPI.Question_9__c)                       +
                   fryingPanPpiScoreMap.get(farmerPPI.Question_10__c);
       database.insert(farmerPPI);

       // Create the farmer object
       Farmer__c farmer = new Farmer__c();
       farmer.Registered_By__c = interviewer.Id;
       farmer.Land_Size__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q28_0'), 'q28', 0);
       farmer.Name = ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0'));
       Set<String> crops = ProcessSubmissionHelpers.getAnswerSet(answers.get('q29_0'));
       farmer.Had_Post_Harvest_Handling_Training__c = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q64_0')));
       farmer.Had_Credit_Access__c = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q56_0')));
       String cropString = '';
       for (String crop : crops) {
           if (String.isEmpty(cropString)) {
               cropString = cropMap.get(crop);
           }
           else {
               cropString = cropMap.get(crop) + ';' + cropString;
           } 
       }
       System.debug('farmer crops '+cropString);
       farmer.Crops__c = cropString;
       Set<String> interests = ProcessSubmissionHelpers.getAnswerSet(answers.get('q75_0'));
       String interestString = '';
       for (String interest : interests) {
           if (String.isEmpty(interestString)) {
               interestString = infoNeedsMap.get(interest);
           }
           else {
               interestString = infoNeedsMap.get(interest) + ';' + interestString;
           }
       }
       farmer.Topics_of_Interest__c = interestString;

       // Store the storage locations of the crops
       Set<String> storageLocations = ProcessSubmissionHelpers.getAnswerSet(answers.get('q62_0'));
       String storageLocationString = '';
       for (String storageLocation : storageLocations) {
           if (String.isEmpty(storageLocationString)) {
               storageLocationString = cropStorageLocationMap.get(storageLocation);
           }
           else {
               storageLocationString = cropStorageLocationMap.get(storageLocation) + ';' + storageLocationString;
           }
       }
       farmer.Crop_Storage_Location__c = storageLocationString;

       // Store the storage material of the crops
       Set<String> storageMaterials = ProcessSubmissionHelpers.getAnswerSet(answers.get('q63_0'));
       String storageMaterialString = '';
       for (String storageMaterial : storageMaterials) {
           if (String.isEmpty(storageMaterialString)) {
               storageMaterialString = cropStorageMaterialMap.get(storageMaterial);
           }
           else {
               storageMaterialString = cropStorageMaterialMap.get(storageMaterial) + ';' + storageMaterialString;
           }
       }
       farmer.Crop_Storage_Material__c = storageMaterialString;
       farmer.Person__c = personSaveResult[0].getId();
       farmer.Contact__c = contactSaveResult[0].getId();
       database.insert(farmer);
       System.debug('SUCCESS!!!');
       return new String[]{ '1', 'E-warehouse Farmer Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // A map of household status
    private static Map<String, String> householdStatusMap = new Map<String, String> {
        '1' => 'Man as head of household',
        '2' => 'Woman as head of household',
        '3' => 'Child as head of household',
        '4' => 'Other'
    };

    // A map of crop storage location
    private static Map<String, String> cropStorageLocationMap = new Map<String, String> {
        '1' => 'House on ground',
        '2' => 'House off ground',
        '3' => 'Granary on ground',
        '4' => 'Granary off ground'
    };

    // A map of crop storage material
    private static Map<String, String> cropStorageMaterialMap = new Map<String, String> {
        '1' => 'Gunney bags',
        '2' => 'Plastic bags',
        '3' => 'Jute bags',
        '4' => 'Dedicated room',
        '5' => 'Clay Pots'
    };

    // A map of the count of mosquito nets
    private static Map<String, String> mosquitoNetsCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    private static Map<String, Decimal> mosquitoNetsPpiScoreMap = new Map<String, Decimal> {
        'None' => 0,
        'One' => 2,
        'Two or more' => 4
    };

    // A map of the count of the towels
    private static Map<String, String> towelsCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    private static Map<String, Decimal> towelsPpiScoreMap = new Map<String, Decimal> {
        'None' => 0,
        'One'=> 6,
        'Two or more' => 10
    };

    // A map of the count of the frying pans
    private static Map<String, String> fryingPanCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    private static Map<String, Decimal> fryingPanPpiScoreMap = new Map<String, Decimal> {
        'None' => 0,
        'One' => 3,
        'Two or more' => 7
    };

    // A map of the count of habitable rooms
    private static Map<String, String> habitableRoomsCountMap = new Map<String, String> {
        '1' => 'One',
        '2' => 'Two',
        '3' => 'Three',
        '4' => 'Four or more'
    };

    private static Map<String, Decimal> habitableRoomsPpiScoreMap = new Map<String, Decimal> {
        'One' => 0,
        'Two' => 2,
        'Three' => 5,
        'Four or more' => 8
    };

    // A map of the household member count
    private static Map<String, String> householdMemberCount = new Map<String, String> {
        '1' => 'Nine or more',
        '2' => 'Seven or eight',
        '3' => 'Six',
        '4' => 'Five',
        '5' => 'Four',
        '6' => 'Three',
        '7' => 'One or two'
    };

    private static Map<String, Decimal> householdMemberPpiScore = new Map<String, Decimal> {
        'Nine or more' => 0,
        'Seven or eight' => 5,
        'Six' => 8,
        'Five' => 12,
        'Four' => 18,
        'Three' => 22,
        'One or two' => 32
    };
    // A map of the school grades attained
    private static Map<String, String> schoolGradeMap = new Map<String, String> {
        '1' => 'None or preschool',
        '2' => 'Primary standards 1 to 6',
        '3' => 'Primary standard 7',
        '4' => 'Primary standard 8, or secondary',
        '5' => 'No female head/spouse',
        '6' => 'Secondary form 4 or higher'
    };

    private static Map<String, Decimal> schoolGradePpiScoreMap = new Map<String, Decimal> {
        'None or preschool' => 0,
        'Primary standards 1 to 6' => 1,
        'Primary standard 7' => 2,
        'Primary standard 8, or secondary' => 6,
        'No female head/spouse' => 6,
        'Secondary form 4 or higher' => 11
    };

    // A map of the type of business done
    private static Map<String, String> businessTypeMap = new Map<String, String> {
        '1' => 'Does not work',
        '2' => 'No male head/spouse',
        '3' => 'Agriculture, hunting, forestry, fishing, mining, or quarrying',
        '4' => 'Any other'
    };

    private static Map<String, Decimal> businessTypePpiScoreMap = new Map<String, Decimal> {
        'Does not work' => 0,
        'No male head/spouse' => 3,
        'Agriculture, hunting, forestry, fishing, mining, or quarrying' => 7,
        'Any other' => 9
    };

    // A map of the main floor dwelling material
    private static Map<String, String> mainDwellingFloorMap = new Map<String, String> {
        '1' => 'Wood, earth, or other',
        '2' => 'Cement, or tiles'
    };
    
    private static Map<String, Decimal> mainDwellingFloorPpiScoreMap = new Map<String, Decimal> {
        'Wood, earth, or other' => 0,
        'Cement, or tiles' => 3
    };

    // A map of the lighting source fuel
    private static Map<String, String> lightingSourceFuelMap = new Map<String, String> {
        '1' => 'Collected firewood, purchased firewood, grass, or dry cell (torch)',
        '2' => 'Paraffin, candles, biogas, or other',
        '3' => 'Electricity, solar, or gas'
    };

    private static Map<String, Decimal> lightingSourceFuelPpiScoreMap = new Map<String, Decimal> {
        'Collected firewood, purchased firewood, grass, or dry cell (torch)'  => 0,
        'Paraffin, candles, biogas, or other' => 6,
        'Electricity, solar, or gas' => 12
    };

    // A map of whether the farmer owns an iron box
    private static Map<String, String> ownsIronBoxMap = new Map<String, String> {
        '1' => 'No',
        '2' => 'Yes'
    };

    private static Map<String, Decimal> ownsIronBoxPpiScoreMap = new Map<String, Decimal> {
        'No' => 0,
        'Yes' => 4
    };

    // A map of farmer information needs in the survey
    private static Map<String, String> infoNeedsMap = new Map<String, String> {
        '1' => 'Harvesting/PHH',
        '2' => 'Market Prices;Market Opportunities',
        '3' => 'Pest and Disease Management',
        '4' => 'Agronomic Practices',
        '5' => 'Use of inputs',
        '6' => 'Access to credit',
        '7' => 'Other'
    };

    // A map of gender
    private static Map<String, String> genderMap = new Map<String, String> {
        '1' => 'Male',
        '2' => 'Female'
    };

    // A map of marital status in farmer registration
    private static Map<String, String> maritalStatusMap = new Map<String, String> {
        '1' => 'Single',
        '2' => 'Married',
        '3' => 'Widowed',
        '4' => 'Divorced'
    };

    /**
    *  Fill in the objects for this Harvest Registration
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object VKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the VKW if required.
    */    
    public static List<String> processEwarehouseHarvestSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {

        Set<String> cropIndices = ProcessSubmissionHelpers.getAnswerSet(answers.get('q6_0'));
        if (cropIndices.isEmpty()) {
            return new String[]{'0', 'No crops selected', 'SUPPRESSMSG'};
        }
        String farmerId = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        Farmer__c[] farmers = Utils.loadFarmerFromId(farmerId);
        if (farmers.isEmpty()) {
            return new String[]{'0', 'A Farmer with that Id does not exist in our system ' + submission.imei, 'SUPRESSMSG' }; 
        }
        Farmer__c farmer = farmers[0];
		List<Harvest__c> harvests = new List<Harvest__c>();
        for (String cropIndex : cropIndices) {
            String crop = cropMap.get(cropIndex);
            Quality_Rating__c qualityRating = new Quality_Rating__c();
            Harvest__c harvest = new Harvest__c();
            harvest.Crop__c = crop;
            Set<String> keys = answers.keySet();

            // Helps us to determine whether Maize is one of the crops grown, this is 
            // because there are 2 different moisture content questions, 1 for Maize and 1 for the rest
            String maizeKey = '';
            for (String key : keys) {
                if (key.startsWith('q8') && cropMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get(key))).equalsIgnoreCase(crop)) {
                    harvest.Quantity_Harvested__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q9' + key.substring(2)), 'q9', 0);
                }
                if (key.startsWith('q11') && cropMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get(key))).equalsIgnoreCase(crop) && (crop.equalsIgnoreCase('Maize'))) {
                    maizeKey = key;
                    qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')));
                }
                else if (key.startsWith('q11') && cropMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get(key))).equalsIgnoreCase(crop) && (!crop.equalsIgnoreCase('Maize'))){
                    if (String.isEmpty(maizeKey)) {
                        qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q13' + key.substring(3))));
                        System.debug('crop ' + crop + ' key ' + key + ' and moisture content ' + qualityRating.Moisture_Content__c);
                    }
                    else {
                        Integer selectedCropIndex = Integer.valueOf(key.substring(4));
                        Integer moistureContentIndex = selectedCropIndex - 1;
                        qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q13_' + moistureContentIndex)));
                        System.debug('crop ' + crop + ' key ' + key + ' and moisture content ' + qualityRating.Moisture_Content__c);
                    }
                }
                if (key.startsWith('q19') && cropMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get(key))).equalsIgnoreCase(crop)) {
                    harvest.Quantity_Accepted__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q20' + key.substring(3)), 'q20', 0);
                }
                if (key.startsWith('q19') && cropMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get(key))).equalsIgnoreCase(crop)) {
                    harvest.Quantity_Rejected__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q21' + key.substring(3)), 'q21', 0);
                }
                harvest.Storage_Location__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q30_0'));
                harvest.Date_Harvested__c = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date();
                harvest.Farmer__c = farmer.Id;
            }
    
            // Save the quality rating object and return its Id as it is needed by the harvest object
            database.saveResult[] saveResult = database.insert(new Quality_Rating__c[]{ qualityRating });
            harvest.Current_Quality_Rating__c = saveResult[0].getId();
    
            // Save the harvest object
            database.SaveResult harvestSaveResult = database.insert(harvest);
			if (harvestSaveResult.isSuccess()) {
				harvests.add(harvest);
			}
        }
        if (ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q22_0')))) {
            Loan__c loan = new Loan__c();
            loan.Farmer__c = farmer.Id;
            loan.Amount_Applied_For__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q25_0'), 'q25', 0);
            loan.Application_Date__c = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date();
            loan.Currency__c = 'KSh';
            database.insert(loan);
        }
		String cropHarvestSms = farmer.Person__r.First_Name__c + ' ' + farmer.Name + ':';
		String loanEligibilitySms = 'You are eligible for up to Ksh ';
		Decimal harvestValue = 0;
		String eWarehouseMarket = 'e-warehouse';
		for (Harvest__c cropHarvest : harvests) {
			String crop = cropHarvest.Crop__c;
			Decimal quantity = cropHarvest.Quantity_Accepted__c;
			List<Commodities__c> comm = [SELECT Highest_Wholesale_Price__c FROM Commodities__c WHERE Name = :crop AND Market__r.Name =:eWarehouseMarket ORDER BY Effective_date__c DESC LIMIT 1];
			Decimal cropValue = ((Commodities__c)comm[0]).Highest_Wholesale_Price__c * quantity;
			String sms = quantity + ' bags ' + crop +' = Ksh' + cropValue.format() + '. ' ;
			harvestValue += cropValue;
			cropHarvestSms = cropHarvestSms + sms;
		}
		cropHarvestSms = cropHarvestSms + ' Total current value: Ksh ' + harvestValue;
		harvestValue = harvestValue/2;
		loanEligibilitySms = loanEligibilitySms + harvestValue.format() + ' in financing, pending review and approval of loan application.';
        User sender = [
                    SELECT
                        Id,
                        Name
                    FROM
                        User
                    WHERE
                        Name = 'ckw admin'
                ];

		//Schedule Harvest received SMS
		Scheduled_Message_Queue__c harvestMessage = new Scheduled_Message_Queue__c(
			Subject__c = 'Harvest Received',
			Message__c = cropHarvestSms,
			Sender__c = sender.Id,
			Expiration_Date__c = datetime.now().addDays(1),
			Send_Via_Pulse__c = false,
			Send_Via_SMS__c = true,
			Send_Date_Time__c = datetime.now(),
			Person__c = farmer.Person__c
		);

		// Schedule Loan eligibility SMS
		Scheduled_Message_Queue__c loanEligibilityMessage = new Scheduled_Message_Queue__c(
			Subject__c = 'Loan Eligibility',
			Message__c = loanEligibilitySms,
			Sender__c = sender.Id,
			Expiration_Date__c = datetime.now().addDays(1),
			Send_Via_Pulse__c = false,
			Send_Via_SMS__c = true,
			Send_Date_Time__c = datetime.now(),
			Person__c = farmer.Person__c
		);
		List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
		messageQueue.add(harvestMessage);
		messageQueue.add(loanEligibilityMessage);
		database.insert(messageQueue);
        return new String[]{ '1', 'E-warehouse Harvest Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // Map of the crops grown by the Kenya farmers
    private static Map<String, String> cropMap = new Map<String, String> {
        'Maize' => 'Maize',
        'Beans' => 'Beans',
        'Pigeonpeas' => 'Pigeon peas',
        'Blackbeans' => 'Black beans(Dolichos)',
        'Cowpeas' => 'Cow peas',
        'Greengrams' => 'Green grams'
    };

    // Map of the foreign matter variables in the survey
    private static Map<String, String> foreignMatterMap = new Map<String, String> {
        '1' => 'Grade 1',
        '2' => 'Grade 2'
    };

    // Map of the moisture content variables in the survey
    private static Map<String, String> moistureContentMap = new Map<String, String> {
        '1' => 'Less than 13.5%',
        '2' => 'Exactly 13.5%',
        '3' => 'Greater than 13.5%',
        '4' => 'Less than 15%',
        '5' => 'Greater than 15%'   
    };

    // Map of the aflatoxin rating variables in the survey
    private static Map<String, String> aflatoxinRatingMap = new Map<String, String> {
        '1' => 'Less than 10ppb',
        '2' => 'Greater than 10ppb'
    };

    public Static List<String> processSaleRegistration(Map<String, Submission_Answer__c> answers) {

        String farmerId = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        Farmer__c[] farmers = Utils.loadFarmerFromId(farmerId);
        if (farmers.isEmpty()) {
            return new String[]{'0', 'Farmer does not exist in our system' , 'SUPPRESSMSG'};    
        }
        Farmer__c farmer = farmers[0];

        // Check whether the bank ref number already exists, if true, then update 
        // the currently existing harvest
        //String bankReferenceNumber = ProcessSubmissionHelpers.getAnswerString(answers.get('q15_0'));
        List<String> bankReferenceNumbers = new List<String>();
        for (String answer : answers.keySet()) {
            if (answer.startsWith('q15')) {
                bankReferenceNumbers.add(ProcessSubmissionHelpers.getAnswerString(answers.get(answer)));
            }
        }
        Sale__c saleObject = getSaleByReferenceNumber(bankReferenceNumbers);
        Sale_Farmer_Association__c saleFarmer = new Sale_Farmer_Association__c();
        saleFarmer.Farmer__c = farmer.Id;
        Decimal quantity = 0;
        Decimal price = 0;
        for (String answer : answers.keySet()) {
            if (answer.startsWith('q5')) {
                String instance = answer.substring(3);
                String crop = ProcessSubmissionHelpers.getAnswerString(answers.get(answer));
                if (cropMap.get(crop).equalsIgnoreCase('Black beans(Dolichos)')) {
                    saleFarmer.Dolichos_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Dolichos_Number_of_90kg_Bags_Sold__c += saleFarmer.Dolichos_Number_of_90kg_Bags_Sold__c;
                    saleObject.Dolichos_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);
                }
                else if (cropMap.get(crop).equalsIgnoreCase('Maize')) {
                    saleFarmer.Maize_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Maize_Number_of_90kg_Bags_Sold__c += saleFarmer.Maize_Number_of_90kg_Bags_Sold__c;
                    saleObject.Maize_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);
                }
                else if (cropMap.get(crop).equalsIgnoreCase('Beans')) {
                    saleFarmer.Beans_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Beans_Number_of_90kg_Bags_Sold__c += saleFarmer.Beans_Number_of_90kg_Bags_Sold__c;
                    saleObject.Beans_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);                    
                }
                else if (cropMap.get(crop).equalsIgnoreCase('Pigeon peas')) {
                    saleFarmer.Pigeon_Peas_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Pigeon_Peas_Number_of_90kg_Bags_Sold__c += saleFarmer.Pigeon_Peas_Number_of_90kg_Bags_Sold__c;
                    saleObject.Pigeon_Peas_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);                  
                }
                else if (cropMap.get(crop).equalsIgnoreCase('Cow peas')) {
                    saleFarmer.Cow_Peas_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Cow_Peas_Number_of_90kg_Bags_Sold__c += saleFarmer.Cow_Peas_Number_of_90kg_Bags_Sold__c;
                    saleObject.Cow_Peas_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);                 
                }
                else if (cropMap.get(crop).equalsIgnoreCase('Green grams')) {
                    saleFarmer.Green_Grams_Number_of_90kg_Bags_Sold__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_' + instance), 'q6', 0.0);
                    saleObject.Green_Grams_Number_of_90kg_Bags_Sold__c += saleFarmer.Green_Grams_Number_of_90kg_Bags_Sold__c;
                    saleObject.Green_Grams_Price_Per_90kg_Bag__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_' + instance), 'q7', 0.0);                  
                }
            }
        }

        // Save the sale
        database.upsertResult[] saleSaveResult = database.upsert(new Sale__c[]{ saleObject });

        // Save the farmer involved in the sale
        saleFarmer.Sale__c = saleSaveResult[0].getId();
		database.insert(saleFarmer);
        return new String[]{'1', 'Sale Registration Processed Successfully' , 'SUPPRESSMSG'};
    }
    
    private static Sale__c getSaleByReferenceNumber(List<String> bankTransactionReferenceNumbers) {
        
        Sale__c sale = null;
        Sale_Bank_Reference__c[] saleBankReferences = [Select Id, Sale__c, Bank_Transaction_Reference_Number__c from Sale_Bank_Reference__c
                                                        Where Bank_Transaction_Reference_Number__c IN:bankTransactionReferenceNumbers];
        
        If (saleBankReferences.isEmpty()) {
            sale = new Sale__c(Beans_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Beans_Price_Per_90kg_Bag__c = 0.0,
                                    Cow_Peas_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Cow_Peas_Price_Per_90kg_Bag__c = 0.0,
                                    Dolichos_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Dolichos_Price_Per_90kg_Bag__c = 0.0,
                                    Green_Grams_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Green_Grams_Price_Per_90kg_Bag__c = 0.0,
                                    Maize_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Maize_Price_Per_90kg_Bag__c = 0.0,
                                    Pigeon_Peas_Number_of_90kg_Bags_Sold__c = 0.0,
                                    Pigeon_Peas_Price_Per_90kg_Bag__c = 0.0,
                                    
                                    Sale_Date__c = date.today());
            database.saveResult[] saleSaveResult = database.insert(new Sale__c[]{sale});
            for (String bankTransactionReferenceNumber : bankTransactionReferenceNumbers) {
                Sale_Bank_Reference__c saleBankReference = new Sale_Bank_Reference__c();
                saleBankReference.Sale__c = saleSaveResult[0].getId();
                saleBankReference.Bank_Transaction_Reference_Number__c = bankTransactionReferenceNumber;
                database.insert(saleBankReference);
            }
            return sale;
        }
        else {
            Sale__c[] sales = [Select 
                            Id,
                            Sale_Date__c,
                            Beans_Number_of_90kg_Bags_Sold__c,
                            Beans_Price_Per_90kg_Bag__c,
                            Cow_Peas_Number_of_90kg_Bags_Sold__c,
                            Cow_Peas_Price_Per_90kg_Bag__c,
                            Dolichos_Number_of_90kg_Bags_Sold__c,
                            Dolichos_Price_Per_90kg_Bag__c,
                            Green_Grams_Number_of_90kg_Bags_Sold__c,
                            Green_Grams_Price_Per_90kg_Bag__c,
                            Maize_Number_of_90kg_Bags_Sold__c,
                            Maize_Price_Per_90kg_Bag__c,
                            Pigeon_Peas_Number_of_90kg_Bags_Sold__c,
                            Pigeon_Peas_Price_Per_90kg_Bag__c
                        From
                            Sale__c
                        Where
                            Id =:saleBankReferences[0].Sale__c];
            return sales[0];
        }
    }
    
    // Map of the Farmer groups in eWarehouse
    private static Map<String, String> farmerGroupMap = new Map<String, String> {
        '1' => 'Mutwiri Farmers',
        '2' => 'Kanja Women Group',
        '3' => 'Marega Mutethia',
        '4' => 'Marega Weru',
        '5' => 'Gachiongo Mwichuiri',
        '6' => 'Ciamatha',
        '7' => 'Marega Borehole',
        '8' => 'Mutua Mbaya Farmers',
        '9' => 'Nazarene Women',
        '10' => 'King\'oo Disability',
        '11' => 'Mwiganda Shg',
        '12' => 'Kabaune 4k',
        '13' => 'King\'oo Youth',
        '14' => 'Kainda Women Group',
        '15' => 'Amatu Miringene',
        '16' => 'Kirwara',
        '17' => 'Amuthetu Mwichuiri',
        '18' => 'Ntetheria Mwari Na Kithomo',
        '19' => 'Amatu Maendeleo',
        '20' => 'Amuthetu Youth',
        '21' => 'Kiguru Shg',
        '22' => 'Baraka Mulika',
        '23' => 'Kabeti Kiguru',
        '24' => 'Pamoja Mulika',
        '25' => 'Athwana Clinic',
        '26' => 'Athwana Men Association',
        '27' => 'Mutewa Women Group',
        '28' => 'Mutewa Disability',
        '29' => 'Young Mothers',
        '30' => 'Mwende Ngwataniro',
        '31' => 'Mukono Mwangaza',
        '32' => 'Akaiga Giant',
        '33' => 'Mlango SHG',
        '34' => 'Nthangathi Murimi SHG',
        '35' => 'Kiau Muuti W/P',
        '36' => 'St Mary Small Christian Community',
        '37' => 'Thei Water Project',
        '38' => 'Ntanira Mwari na Kithomo',
        '39' => 'Makena Mwanika',
        '40' => 'Kamathi Turuka',
        '41' => 'Riiru Women Group',
        '42' => 'Weru Maurune',
        '43' => 'Kaguata Men SHG',
        '44' => 'Kamujine SHG',
        '45' => 'Igurune Farmers',
        '46' => 'Githu Hope',
        '47' => 'Tiwosa',
        '48' => 'Kunati Cereal Growers',
        '49' => 'Thuuti',
        '50' => 'Miira',
        '51' => 'Ngongoaka',
        '52' => 'Nkumburu',
        '53' => 'Muguna Murimi',
        '54' => 'Igarii Mutethia',
        '55' => 'Rurii Young turks B',
        '56' => 'Gituu East Agriculture Group',
        '57' => 'Kaguuru SHG',
        '58' => 'Thuuri Mukorone',
        '59' => 'Kamathi Turuka',
        '60' => 'Mwichuiri Turuka',
        '61' => 'Kanini Kega Women Group',
        '62' => 'Makandi Mungaano Women Group',
        '63' => 'Makandi Women Group',
        '64' => 'Kanja Women Group',
        '65' => 'Mwichiuri Women Group',
        '66' => 'Baraimo Youth Multi-Purpose',
        '67' => 'Kamungatha Women Group',
        '68' => 'Kathangari Vijana Pamoja',
        '69' => 'Kathima Women',
        '70' => 'Kariru Women',
        '71' => 'Makandi Dairy Goat',
        '72' => 'Mwanika Women Group',
        '73' => 'Widows SHG',
        '74' => 'Kunene Kithangari SHG',
        '75' => 'Karinga Women Group',
        '76' => 'Limaura Men SHG',
        '77' => 'Nchiru Disability',
        '78' => 'Karene Women Group',
        '79' => 'Akinyanga Women Group',
        '80' => 'Mwichiuri Women Group',
        '81' => 'Gaicugi Women Group',
        '82' => 'Mwangaza Women Group',
        '83' => 'Muthutira Women Group',
        '84' => 'Kimirii Ntiwa Women Group',
        '85' => 'Gatheria Women Group',
        '86' => 'Njia Women Group',
        '87' => 'Karathia Women Group',
        '88' => 'Mwichiuri Women Group',
        '89' => 'Kuane East Pioneer',
        '90' => 'Kiare 1',
        '91' => 'Kiare 2',
        '92' => 'Maitha Women Group',
        '93' => 'Mwicienderi SHG',
        '94' => 'Kieru SHG',
        '95' => 'Muriuki Kibuline',
        '96' => 'Kieru Mwinga Ukia',
        '97' => 'Kambogo Kathima',
        '98' => 'Kieru Umoja SHG',
        '99' => 'Kamburu SHG',
        '100' => 'Bairimu SHG', 
        '101' => 'Kaamuwendo',
        '102' => 'Kamburu Men SHG',
        '103' => 'Mbeu Ushindi SHG',
        '104' => 'Nkatha Ceera',
        '105' => 'Nkanja Kibuline',
        '106' => 'Gaceeri Ceera',
        '107' => 'Mwenda SHG',
        '108' => 'Kanja Women Group',
        '109' => 'Murithi SHG',
        '110' => 'Makena Mwili SHG',
        '111' => 'Gathimwe Women Group',
        '112' => 'Mutethia Women Group',
        '113' => 'Kaithuranairi Wg',
        '114' => 'Kulukie',
        '115' => 'Mbuya',
        '116' => 'Naithilii',
        '117' => 'Kalaene SHG',
        '118' => 'Jitegemee',
        '119' => 'Munanda Women Group',
        '120' => 'Mugana Women Group',
        '121' => 'Kiare 2',
        '122' => 'Joy Youth',
        '123' => 'Katamba Women',
        '124' => 'Kanjuri SHG',
        '125' => 'Kianjaru SHG',
        '126' => 'Ndiri SHG',
        '127' => 'Twara Men SHG',
        '128' => 'Mulele SHG',
        '129' => 'Kariru Child Welfare Group',
        '130' => 'Kiithiri Kamunga Karabati',
        '131' => 'Kithiiri Maendeleo',
        '132' => 'Kamungatha Multipurpose Women Group',
        '133' => 'Kariru Maendeleo Women Group',
        '134' => 'Machegene SHG',
        '135' => 'Kithangari SHG',
        '136' => 'Kiorimba SHG',
        '137' => 'Kuuru SHG',
        '138' => 'Twale SHG',
        '139' => 'Kalantina SHG',
        '140' => 'Mwangaza SHG',
        '141' => 'Lukuene Youth',
        '142' => 'Muungano Kalemi',
        '143' => 'Bonyange SHG',
        '144' => 'Baikinya SHG',
        '145' => 'Nkantha Women Group',
        '146' => 'Luthuri Women Group',
        '147' => 'Gakurine SHG',
        '148' => 'Amuka SHG',
        '149' => 'Mwithanga Traditional',
        '150' => 'Akinyanga SHG',
        '151' => 'Other'    
    };
}