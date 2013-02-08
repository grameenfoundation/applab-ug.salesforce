public with sharing class ProcessEwareHseFarmerRegistration {

    public static List<String> processFarmerRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
    
        //Create a Contact object for this farmer
        Contact contact = new Contact();
        String name = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        String[] names = name.split(',');
        if (null != names ) {
            contact.FirstName = names[0];
            contact.LastName = names[1];
        }
        Account account = [Select Id from Account limit 1];
        contact.AccountId = account.Id;
        //Save the contact object and return its id
        database.SaveResult[] saveResult = database.insert(new Contact[] {contact});
        
        //Create the Poverty Index object for the contact
        Poverty_Index__c povertyIndex = new Poverty_Index__c();
        povertyIndex.Contact__c = saveResult[0].getId();
        povertyIndex.Female_Head_Spouse_Highest_School_Grade__c = schoolGradeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0')));
        povertyIndex.Household_Member_Count__c = householdMemberCount.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0')));
        povertyIndex.Main_dwelling_floor_material__c = mainDwellingFlourMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q22_0')));
        povertyIndex.Main_source_of_lighting_fuel__c = lightingSourceFuelMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q23_0')));
        povertyIndex.Male_head_type_of_business__c = businessTypeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0')));
        povertyIndex.Number_of_frying_pans__c = fryingPanCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q27_0')));
        povertyIndex.Number_of_mosquito_nets__c = mosquitoNetsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q25_0')));
        povertyIndex.Number_of_towels__c = towelsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q26_0')));
        povertyIndex.Num_of_habitable_rooms_in_main_dwelling__c = habitableRoomsCountMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q21_0')));
        povertyIndex.Own_iron_box__c = ownsIronBoxMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q24_0')));
        database.insert(povertyIndex);
        
        //Create the farmer object
        EW_Farmer__c farmer = new EW_Farmer__c();
        farmer.Contact__c = saveResult[0].getId();
        farmer.Land_Size__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q15_0'), 'q15', 0.0);
        farmer.Registered_Date__c = date.today();
        farmer.Crops__c = buildCropsString(ProcessSubmissionHelpers.getAnswerSet(answers.get('q16_0')));
        farmer.Household_Status__c = householdStatusMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0')));
        farmer.Information_Needs__c = buildInfoNeedsString(ProcessSubmissionHelpers.getAnswerSet(answers.get('q56_0')));
        VKW__c vkw = [Select Id, Person__c from VKW__c where Person__c =: person.Id];
        farmer.Registered_By__c = vkw.Id;
        database.insert(farmer);
        
        return new String[]{'1','Farmer saved successfully','SUPRESSMSG'};
    }
    
    private static Map<String, String> cropMap = new Map<String, String> {
        '1' => 'Maize',
        '2' => 'Beans',
        '3' => 'Mwitemania, Canadian Wonder, Rose Coco',
        '4' => 'Pigeon peas',
        '5' => 'Black beans(Dolichos)',
        '6' => 'Cow peas (Kunde)',
        '7' => 'Green grams'
    };
    
    private static String buildCropsString (Set<String> crops) {
        String returnValue = '';
        Integer i = 0;
        for (String crop : crops) {
            returnValue += cropMap.get(crop);
            if (i <= crops.size() - 1) {
                returnValue += ',';
            }
        }
        return returnValue;
    }
    private static Map<String, String> infoNeedsMap = new Map<String, String> {
        '1' => 'Pest Management',
        '2' => 'Agronomic Practice',
        '3' => 'Use of inputs',
        '4' => 'Access to credit/loan'
    };
    
    private static String buildInfoNeedsString(Set<String> infoNeeds) {
        String returnValue = '';
        Integer i = 0;
        for (String infoNeed: infoNeeds) {
            returnValue += infoNeedsMap .get(infoNeed);
            if (i <= infoNeeds.size() - 1) {
                returnValue += ',';
            }
        }
        return returnValue;
    }
    
    private static Map<String, String> householdStatusMap = new Map<String, String> {
        '1' => 'Man as head of household',
        '2' => 'Woman as head of household',
        '3' => 'Child as head of household',
        '4' => 'Other'
    };
    
    private static Map<String, String> mosquitoNetsCountMap = new Map<String, String> {
        '1' => 'None',
        '2' => 'One',
        '4' => 'Two or more'
    };
    
    private static Map<String, String> towelsCountMap = new Map<String, String> {
        '0' => 'None',
        '6' => 'One',
        '10' => 'Two or more'
    };
    
    private static Map<String, String> fryingPanCountMap = new Map<String, String> {
        '0' => 'None',
        '3' => 'One',
        '7' => 'Two or more'
    };
    
    private static Map<String, String> habitableRoomsCountMap = new Map<String, String> {
        '0' => 'One',
        '2' => 'Two',
        '5' => 'Three',
        '8' => 'Four or more'
    };

    private static Map<String, String> householdMemberCount = new Map<String, String> {
        '0' => 'Nine or more',
        '5' => 'Seven or eight',
        '8' => 'Six',
        '12' => 'Five',
        '18' => 'Four',
        '22' => 'Three',
        '32' => 'One or two'
    };
    
    private static Map<String, String> schoolGradeMap = new Map<String, String> {
        '0' => 'None or preschool',
        '1' => 'Primary standards 1 to 6',
        '2' => 'Primary standard 7',
        '12' => 'Primary standard 8, or seconary',
        '18' => 'No female head/spouse',
        '32' => 'Secondary form 4 or higher'
    };
    
    private static Map<String, String> businessTypeMap = new Map<String, String> {
        '0' => 'Does not work',
        '2' => 'No male head/spouse',
        '5' => 'Agriculture, hunting, forestry, fishing, mining, or quarrying',
        '8' => 'Any other'
    };
    
    private static Map<String, String> mainDwellingFlourMap = new Map<String, String> {
        '0' => 'Wood, earth, or other',
        '3' => 'Cement, or tiles'
    };

    private static Map<String, String> lightingSourceFuelMap = new Map<String, String> {
        '0' => 'Collected firewood, purchased firewood, grass, or dry cell (torch)',
        '6' => 'Paraffin, candles, biogas, or other',
        '12' => 'Electricity, solar, or gas'
    };
    
    private static Map<String, boolean> ownsIronBoxMap = new Map<String, boolean> {
        '0' => false,
        '4' => true    
    };
    
    static testMethod void testProcessFarmerRegistration() {
        
        //Create a person
         Person__c person = Utils.createTestPerson(null, 'Testing', true, null, 'Female');
         database.insert(person);
         //Create a Contact
         Contact contact = new Contact();
         contact.FirstName = 'Testing';
         contact.LastName = 'Testing';
         database.insert(contact);
         //Create a VKW
         VKW__c vkw = new VKW__c();
         vkw.Contact__c = contact.Id;
         vkw.Person__c = person.Id;
         database.insert(vkw);
         
         //Create submission info
         Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
         answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Ricky,Kaka', null, null, null));
         answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '2', null, null, null));
         answers.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18', '8', null, null, null));
         answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '0', null, null, null));
         answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '6', null, null, null));
         answers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '7', null, null, null));
         answers.put('q27_0', Utils.createTestSubmissionAnswer(null, 'q27', '3', null, null, null));
         answers.put('q25_0', Utils.createTestSubmissionAnswer(null, 'q25', '2', null, null, null));
         answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '6', null, null, null));
         answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '8', null, null, null));
         answers.put('q24_0', Utils.createTestSubmissionAnswer(null, 'q24', '0', null, null, null));
         answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '2', null, null, null));
         answers.put('q16_0', Utils.createTestSubmissionAnswer(null, 'q16', '1 2 3', null, null, null));
         answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '3', null, null, null));
         answers.put('q56_0', Utils.createTestSubmissionAnswer(null, 'q56', '2 3 4', null, null, null));
         ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
         submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
         submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
         submission.imei = '32432443253';
         submission.resultHash = '1';
         Account account = new Account();
         account.BillingState = 'CA';
         account.Name = 'Tester';
         database.insert(account);
         List<String> returnValues = new List<String>();
         returnValues = processFarmerRegistration(submission, answers, person);
         System.assert(returnValues.get(0).equals('1'));
    }
}