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
               
       // Create a Contact object for this farmer
       Contact contact = new Contact();
       String name = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
       if (String.isEmpty(name) || name == null) {
           return new String[]{ '0', 'The name question has not been answered', 'SUPRESSMSG' };
       }
       String[] names = name.split(',');
       if (null != names) {
           contact.FirstName = names[0];
           contact.LastName = names[1];
       }
       String accountName = 'USAID';
       Account account = [Select Id from Account where Name = :accountName];
       contact.AccountId = account.Id;
       database.SaveResult[] contactSaveResult = database.insert(new Contact[]{contact});
        
       // Create a Person object for the farmer
       Person__c person = new Person__c();
       person.First_Name__c = names[0];
       person.Last_Name__c = names[1];
       String countryName = 'Kenya';
       Country__c country = [SELECT Id from Country__c WHERE Name = :countryName];
       person.Country__c = country.Id;
       database.saveResult[] personSaveResult = database.insert(new Person__c[]{person});
       
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
       database.insert(farmerPPI);

       // Create the farmer object
       Farmer__c farmer = new Farmer__c();
       farmer.Name = ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0'));
       farmer.Crops__c = ProcessSubmissionHelpers.processAnswerSet(ProcessSubmissionHelpers.getAnswerSet(answers.get('q29_0')));
       farmer.Topics_of_Interest__c = ProcessSubmissionHelpers.processAnswerSet(ProcessSubmissionHelpers.getAnswerSet(answers.get('q75_0')));
       farmer.Person__c = personSaveResult[0].getId();
       farmer.Contact__c = contactSaveResult[0].getId();
       database.insert(farmer);
       return new String[]{ '1', 'E-warehouse Farmer Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // A map of household status
    private static Map<String, String> householdStatusMap = new Map<String, String> {
        '1' => 'Man as head of household',
        '2' => 'Woman as head of household',
        '3' => 'Child as head of household',
        '4' => 'Other'
    };

    // A map of the count of mosquito nets
    private static Map<String, String> mosquitoNetsCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    // A map of the count of the towels
    private static Map<String, String> towelsCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    // A map of the count of the frying pans
    private static Map<String, String> fryingPanCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '3' => 'Two or more'
    };

    // A map of the count of habitable rooms
    private static Map<String, String> habitableRoomsCountMap = new Map<String, String> {
        '1' => 'One',
        '2' => 'Two',
        '3' => 'Three',
        '4' => 'Four or more'
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

    // A map of the school grades attained
    private static Map<String, String> schoolGradeMap = new Map<String, String> {
        '1' => 'None or preschool',
        '2' => 'Primary standards 1 to 6',
        '3' => 'Primary standard 7',
        '4' => 'Primary standard 8, or seconary',
        '5' => 'No female head/spouse',
        '6' => 'Secondary form 4 or higher'
    };

    // A map of the type of business done
    private static Map<String, String> businessTypeMap = new Map<String, String> {
        '1' => 'Does not work',
        '2' => 'No male head/spouse',
        '3' => 'Agriculture, hunting, forestry, fishing, mining, or quarrying',
        '4' => 'Any other'
    };

    // A map of the main floor dwelling material
    private static Map<String, String> mainDwellingFloorMap = new Map<String, String> {
        '1' => 'Wood, earth, or other',
        '2' => 'Cement, or tiles'
    };

    // A map of the lighting source fuel
    private static Map<String, String> lightingSourceFuelMap = new Map<String, String> {
        '1' => 'Collected firewood, purchased firewood, grass, or dry cell (torch)',
        '2' => 'Paraffin, candles, biogas, or other',
        '3' => 'Electricity, solar, or gas'
    };

    // A map of whether the farmer owns an iron box
    private static Map<String, String> ownsIronBoxMap = new Map<String, String> {
        '1' => 'No',
        '2' => 'Yes'
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

        Set<String> cropIndices = ProcessSubmissionHelpers.getAnswerSet(answers.get('q2_0'));
        if (cropIndices.isEmpty()) {
            return new String[]{'0', 'No crops selected', 'SUPPRESSMSG'};
        }
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
                if (key.startsWith('q4') && answers.get(key).Answer__c.equals(crop)) {
                    harvest.Quantity_Harvested__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q5' + key.substring(2)), 'q5', 0);
                }
                if (key.startsWith('q7') && answers.get(key).Answer__c.equals(crop)) {
                    qualityRating.Percentage_Foreign_Matter__c = foreignMatterMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q8' + key.substring(2))));
                }
                if (key.startsWith('q10') && answers.get(key).Answer__c.equals(crop) && crop.equalsIgnoreCase('Maize')) {
                    maizeKey = key;
                    qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0')));
                }
                if (key.startsWith('q10') && answers.get(key).Answer__c.equals(crop) && (!crop.equalsIgnoreCase('Maize'))) {
                    if (String.isEmpty(maizeKey)) {
                        qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q12' + key.substring(3))));
                    }
                    else {
                        Integer selectedCropIndex = Integer.valueOf(key.substring(4));
                        Integer moistureContentIndex = selectedCropIndex - 1;
                        qualityRating.Moisture_Content__c = moistureContentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q12_' + moistureContentIndex)));
                    }
                }
                if (key.startsWith('q14') && answers.get(key).Answer__c.equals(crop)) {
                    qualityRating.Aflatoxin_Rating__c = aflatoxinRatingMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q15' + key.substring(3))));
                }
                if (key.startsWith('q18') && answers.get(key).Answer__c.equals(crop)) {
                    harvest.Quantity_Accepted__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q19' + key.substring(3)), 'q19', 0);
                }
                if (key.startsWith('q18') && answers.get(key).Answer__c.equals(crop)) {
                    harvest.Quantity_Rejected__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q20' + key.substring(3)), 'q19', 0);
                }
                harvest.Storage_Location__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q29_0'));
                harvest.Date_Harvested__c = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date();


            }
        // Save the quality rating object and return its Id as it is needed by the harvest object
        database.saveResult[] saveResult = database.insert(new Quality_Rating__c[]{ qualityRating });
        harvest.Current_Quality_Rating__c = saveResult[0].getId();
        
        // Save the harvest object
        database.insert(harvest);
        }
        return new String[] { '1', 'E-warehouse Harvest Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // Map of the crops grown by the Kenya farmers
    private static Map<String, String> cropMap = new Map<String, String> {
        '1' => 'Maize',
        '2' => 'Beans',
        '3' => 'Pigeon peas',
        '4' => 'Black beans(Dolichos)',
        '5' => 'Cow peas',
        '6' => 'Green grams'
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

}