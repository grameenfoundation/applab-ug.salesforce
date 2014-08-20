/**
* A class to handle post processing of 
* all the Agroways surveys
*/
public class ProcessAgrowaysSurveys {

    /**
    *  Fill in the objects for this Farmer Registration
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object VAC who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the VAC if required.
    */
    public static List<String> processAgrowaysFarmerRegistration(ProcessSurveySubmission.SurveySubmission submission,
        Map<String, Submission_Answer__c> answers, Person__c interviewer) {

        // Check that the farmer id does not already exist
        Farmer__c[] farmers = Utils.loadFarmerFromId(ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0')));
        if (!farmers.isEmpty()) {
            return new String[] {'0', 'The Farmer Id is already in use by another', 'SUPPRESSMSG'};
        }
        Account account = [Select Id from Account where Name = 'Agroways' limit 1];

        String name = ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')).replaceAll('\\s+',' ');System.debug(name);
        String[] fullName = name.split(' ');
        String firstName = fullName[0];
        String lastName = fullName[1];

        // Create the Contact object
        Contact contact = new Contact(firstName=firstName, LastName = lastName, accountId = account.Id);
        insert contact;

        // Create the Person object
        Person__c person = new Person__c(First_Name__c=firstName, Last_Name__c = lastName);
        person.Raw_Mobile_Number__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0'));
        person.Father_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));
        person.Gender__c = genderMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));
        person.District__c = [Select Id from District__c where Name =:districtMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0'))) limit 1].Id;
        person.Subcounty__c = [Select Id from Subcounty__c where Display_Name__c =:ProcessSubmissionHelpers.getAnswerString(answers.get('q6_0')) limit 1].Id;
        person.Village__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0')); 
        insert person;

        // Create the PPI object
        PPI_Data__c ppiObject = new PPI_Data__c();
        ppiObject.Person__c = person.Id;
        ppiObject.Country__c = 'Uganda';
        ppiObject.Version__c = 'Uganda';
        ppiObject.Date__c = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date();
        ppiObject.Question_1__c = hhMembersMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q15_0'))).toPlainString();
        ppiObject.Question_2__c = childrenInSchoolMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q16_0'))).toPlainString();
        ppiObject.Question_3__c = femaleGradeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q17_0'))).toPlainString();
        ppiObject.Question_4__c = roofMaterialMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0'))).toPlainString();
        ppiObject.Question_5__c = wallMaterialMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0'))).toPlainString();
        ppiObject.Question_6__c = lightingSourceMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0'))).toPlainString();
        ppiObject.Question_7__c = toiletTypeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q21_0'))).toPlainString();
        ppiObject.Question_8__c = ownElectricEquipmentMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q22_0'))).toPlainString();
        ppiObject.Question_9__c = ownTwoClothesSetMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q23_0'))).toPlainString();
        ppiObject.Question_10__c = ownOnePairOfShoesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q24_0'))).toPlainString();
        ppiObject.Score__c = Decimal.valueOf(ppiObject.Question_1__c)        +
                    Decimal.valueOf(ppiObject.Question_2__c)                 +
                    Decimal.valueOf(ppiObject.Question_3__c)                 +
                    Decimal.valueOf(ppiObject.Question_4__c)                 +
                    Decimal.valueOf(ppiObject.Question_5__c)                 +
                    Decimal.valueOf(ppiObject.Question_6__c)                 +
                    Decimal.valueOf(ppiObject.Question_7__c)                 +
                    Decimal.valueOf(ppiObject.Question_8__c)                 +
                    Decimal.valueOf(ppiObject.Question_9__c)                 +
                    Decimal.valueOf(ppiObject.Question_10__c);
        // Create the Farmer object
        Farmer__c farmer = new Farmer__c(Person__c = person.Id);
        farmer.Household_Status__c = householdStatusMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0')));
        farmer.Land_Size__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q10_0'), 'q10', 0);
        Set<String> crops = ProcessSubmissionHelpers.getAnswerSet(answers.get('q11_0'));
        String cropString = '';
        for (String crop : crops) {
            if (String.isEmpty(cropString)) {
               cropString = cropMap.get(crop);
            }
            else {
                cropString = cropMap.get(crop) + ';' + cropString;
            } 
        }
        farmer.Crops__c = cropString;
        Set<String> topics = ProcessSubmissionHelpers.getAnswerSet(answers.get('q13_0'));
        String topicString = '';
        for (String topic : topics) {
            if (String.isEmpty(topicString)) {
               topicString = topicsMap.get(topic);
            }
            else {
                topicString = topicsMap.get(topic) + ';' + topicString;
            } 
        }
        farmer.Topics_of_Interest__c = topicString;
        insert farmer;
        return new String[]{ '1', 'Agroways Farmer Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // A map of gender
    private static Map<String, String> genderMap = new Map<String, String> {
        '1' => 'Male',
        '2' => 'Female'
    };

    // A map of Districts
    private static Map<String, String> districtMap = new Map<String, String> {
        '1' => 'Mayuge',
        '2' => 'Kamuli',
        '3' => 'Luuka',
        '4' => 'Kaliro',
        '5' => 'Buyende',
        '6' => 'Jinja'
    };

    // A map of household status
    private static Map<String, String> householdStatusMap = new Map<String, String> {
        '1' => 'Household head',
        '2' => 'Spouse of household head',
        '3' => 'Child of household head',
        '4' => 'Other'
    };

    // Map of the crops grown by the Agroways farmers
    private static Map<String, String> cropMap = new Map<String, String> {
        '1' => 'Maize',
        '2' => 'Beans',
        '3' => 'Cassava',
        '4' => 'Groundnuts',
        '5' => 'Sorghum',
        '6' => 'Rice',
        '7' => 'Millet',
        '8' => 'Coffee',
        '9' => 'Bananas',
        '10' => 'Sugarcane',
        '11' => 'Other',
        '12' => 'None'
    };

    // Map of Subscription Topics
    private static Map<String, String> topicsMap = new Map<String, String> {
        '1' => 'Market Prices',
        '2' => 'Market Opportunities',
        '3' => 'Weather',
        '4' => 'Planting/Garden Prep',
        '5' => 'Pest and Disease Management',
        '6' => 'Soil Management',
        '7' => 'Harvesting/PHH',
        '8' => 'Farming as a Business',
        '9' => 'Livestock Rearing',
        '10' => 'Health',
        '11' => 'Education',
        '12' => 'Agricultural Financing',
        '13' => 'Other'
    };

    // A map of to calculate hh members count score
    private static Map<String, Decimal> hhMembersMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 6,
        '3' => 9,
        '4' => 14,
        '5' => 27
    };

    // A map of to calculate children in school score
    private static Map<String, Decimal> childrenInSchoolMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 2,
        '3' => 4,
        '4' => 5
    };

    // A map of to calculate highest grade female score
    private static Map<String, Decimal> femaleGradeMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 2,
        '3' => 6,
        '4' => 8,
        '5' => 19
    };

    // A map to calculate score of major roof material
    private static Map<String, Decimal> roofMaterialMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 5
    };

    // A map to calculate score of major wall material
    private static Map<String, Decimal> wallMaterialMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 2
    };

    // A map to calculate score of lighting source
    private static Map<String, Decimal> lightingSourceMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 11,
        '3' => 17 
    };

    // A map to calculate score of toilet type
    private static Map<String, Decimal> toiletTypeMap = new Map<String, Decimal> {
        '1' => 0,
        '2' => 4
    };

    // A map to calculate score of toilet type
    private static Map<String, Decimal> ownElectricEquipmentMap = new Map<String, Decimal> {
        '1' => 7,
        '2' => 0
    };

    // A map to calculate score of toilet type
    private static Map<String, Decimal> ownTwoClothesSetMap = new Map<String, Decimal> {
        '1' => 5,
        '2' => 0
    };

    // A map to calculate score of toilet type
    private static Map<String, Decimal> ownOnePairOfShoesMap = new Map<String, Decimal> {
        '1' => 9,
        '2' => 0
    };

    public static List<String> processFarmerGroupRegistration(ProcessSurveySubmission.SurveySubmission submission,
        Map<String, Submission_Answer__c> answers, Person__c interviewer) {

        Agroways_Farmer_Group__c farmerGroup = new Agroways_Farmer_Group__c();
        farmerGroup.District__c = [Select Id from District__c where Name=:farmerGroupDistrictMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0'))) limit 1].Id;
        farmerGroup.VAC__c = interviewer.Id;
        farmerGroup.Farmer_Group_Registered__c = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')));
        if (farmerGroup.Farmer_Group_Registered__c) {
            farmerGroup.Registration_Level__c = registrationLevelMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q13_0')));
        }
        farmerGroup.Group_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0'));
        farmerGroup.Group_Type__c = groupTypeMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q17_0')));
        farmerGroup.Interviewee_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0'));
        farmerGroup.Interviewee_Position_in_Farmer_Group__c = positionMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0')));
        farmerGroup.Major_Activity__c = majorActivityMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0')));
        farmerGroup.Number_of_Members__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q15_0'), 'q15', 1);
        farmerGroup.Works_with_other_groups__c = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q23_0')));
        farmerGroup.Year_Formed__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q14_0'), 'q14', 2000);
        Set<String> groupServices = ProcessSubmissionHelpers.getAnswerSet(answers.get('q21_0'));
        String serviceString = '';
        for (String service : groupServices) {
            if (String.isEmpty(serviceString)) {
               serviceString = servicesMap.get(service);
            }
            else {
                serviceString = servicesMap.get(service) + ';' + serviceString;
            } 
        }
        farmerGroup.Services_Provided_to_Farmers__c = serviceString;
        insert farmerGroup;
        return new String[]{ '1', 'Agroways Farmer Group Registration successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }

    // A map to contain the districts in the survey
    private static Map<String, String> farmerGroupDistrictMap = new Map<String, String> {
        '1' => 'Mayuge',
        '2' => 'Kamuli',
        '3' => 'Buyende',
        '4' => 'Luuka',
        '5' => 'Kaliro',
        '6' => 'Jinja'
    };

    // A map with group type info
    private static Map<String, String> groupTypeMap = new Map<String, String> {
        '1' => 'Community Based Organisation',
        '2' => 'Farmer Cooperative',
        '3' => 'Farmer Society',
        '4' => 'Farmer Club/Group',
        '5' => 'Women Group',
        '6' => 'Youth Club',
        '7' => 'Faith-based Organisation',
        '8' => 'SACCO',
        '9' => 'Welfare/Funeral Club',
        '10' => 'Other'
    };

    // A map with position info
    private static Map<String, String> positionMap = new Map<String, String> {
        '1' => 'Chairman',
        '2' => 'Secretary',
        '3' => 'Treasurer',
        '4' => 'Publicity',
        '5' => 'Other'
    };

    // A map of major farmer group activities
    private static Map<String, String> majorActivityMap = new Map<String, String> {
        '1' => 'Saving',
        '2' => 'Access to farming information',
        '3' => 'Labour',
        '4' => 'Joint gardening',
        '5' => 'Farming credit/loans',
        '6' => 'Access to agro inputs',
        '7' => 'Marketing of produce',
        '8' => 'Social support',
        '9' => 'Storage',
        '10' => 'Other'
    };

    // A map of registration level info
    private static Map<String, String> registrationLevelMap = new Map<String, String> {
        '1' => 'International',
        '2' => 'National',
        '3' => 'District',
        '4' => 'Subcounty',
        '5' => 'Parish',
        '6' => 'Village',
        '7' => 'Other'
    };

    // A map of services provided by the farmer group
    private static Map<String, String> servicesMap = new Map<String, String> {
        '1' => 'Trainings on good agriculture practices',
        '2' => 'Access to market information',
        '3' => 'Access to quality inputs',
        '4' => 'Access to credit/loans',
        '5' => 'Labour',
        '6' => 'Group Marketing',
        '7' => 'Other'
    };
}