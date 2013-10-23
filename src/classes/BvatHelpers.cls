/**
 * Helper class to deal with BVAT Dashboard
 */
public with sharing class BvatHelpers {

    /**
     *  Fill in the CIW__c objects for this CIW Registration
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processCiwInformationSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);

        CIW__c ciw = loadCiw(person);
        
        Person__c ciwPerson = person;
        String[] namesArray = answers.get('q1_0').Answer__c.split(' ');
        
        if(namesArray != null && namesArray.size() >= 1) {
            ciwPerson.First_Name__c = namesArray[0];
            if(namesArray.size() >= 2) {
            ciwPerson.Last_Name__c = namesArray[1];
            }
            else {
                ciwPerson.Last_Name__c = namesArray[0];
            }
        }        
        if (ciwPerson.Handset__c == null) {
            ciwPerson.Raw_Mobile_Number__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0'));
        } else {
            ciwPerson.Handset__r.SIM__r.Name = ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0'));
        }

        ciwPerson.Age__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q3_0'),'q3', 0);
        ciwPerson.Gender__c = translateGender(ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')));
        ciwPerson.Type__c = 'BVAT CIW';
        
        
        //Read the GPS Location
        String[] locationArray = answers.get('q11_0').Answer__c.split(' ');
        if (locationArray != null && locationArray.size() >= 2) {
            ciwPerson.GPS_Location_N__c = locationArray[0];
            ciwPerson.GPS_Location_E__c = locationArray[1];            
        }
        else {
            ciwPerson.GPS_Location_N__c = submission.interviewLatitude;
            ciwPerson.GPS_Location_E__c = submission.interviewLongitude;
        }
        
        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save the person and get the id back
        String errorMessage;
        Database.UpsertResult personSaveResult;

        personSaveResult = Database.upsert(ciwPerson);
        Id personId;

        personId = personSaveResult.getId();
        
        ciw.Person__c = personId;
        ciw.Education_Level__c = translateEducationLevel(ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0')));
        
        
        ciw.Areas_Of_Expertise__c = generateCsvFromSet(getTranslatedSetOfAreasOfExpertise(ProcessSubmissionHelpers.getAnswerSet(answers.get('q5_0'))));   
        ciw.Joining_Year__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_0'),'q6',true);
        ciw.Location_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0'));
        ciw.Sub_Location_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0'));
        ciw.GPS_Location__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0'));   
        ciw.Updated_Date__c = date.newInstance(handsetSubmitTime.year(), handsetSubmitTime.month(), handsetSubmitTime.day());
        
        // Set a rollback point
        Savepoint spCiw = Database.setSavepoint();

        // Save the CIW and get the id back
        errorMessage = '';
        Database.UpsertResult ciwSaveResult = Database.upsert(ciw);
        Id ciwId;

        ciwId = ciwSaveResult.getId();
        
        Set<String> counties = getTranslatedSetOfCounties(ProcessSubmissionHelpers.getAnswerSet(answers.get('q8_0')));
        
        for(String countyName : counties) {

            CIW_County_Association__c cca = new CIW_County_Association__c();
            cca.CIW__c = ciwId;
            
            Kenyan_County__c county = [
                SELECT 
                    Id 
                FROM 
                    Kenyan_County__c 
                WHERE 
                    County_Name__c = :countyName
                LIMIT 1
            ];            

            cca.Kenyan_County__c = county.Id;           
            Database.insert(cca);
        }
        
        // Create a distance travelled metric for the CIW
        CIW__c ciw2 = [Select Id, Name from CIW__c where Id=:ciwId];
        M_E_Metric__c[] existingCiwDistanceMetric = [Select Id from M_E_Metric__c where Name=:ciw2.Name];
        if (existingCiwDistanceMetric.isEmpty()) {
            String ciwMetricSectionTitle = 'Distance covered by CIW(km)';
            Metric_Section__c ciwDistanceMetricSection = [Select Id from Metric_Section__c where Title__c =:ciwMetricSectionTitle];
            M_E_Metric__c ciwDistanceMetric = new M_E_Metric__c();
            ciwDistanceMetric.Name = ciw2.Name;
            ciwDistanceMetric.Metric_Section__c = ciwDistanceMetricSection.Id;
            ciwDistanceMetric.Update_Period__c = 'Ticker';
            ciwDistanceMetric.Label__c = ciw2.Name;
            ciwDistanceMetric.Is_On_Fly__c = true;
            ciwDistanceMetric.On_The_Fly_Calculation_Type__c = 'SUM';
            
            database.insert(ciwDistanceMetric);
        }
        
        // Return success
        return new String[] { '1', 'One On One survey processed for CIW Information with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    
    /**
     *  Fill in the BVAT_Farmer__c objects for this Farmer Registration
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processFarmerRegistrationSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        
        //Load the details of the CIW who is carrying out the registration
        CIW__c ciw = loadCiw(person);

        BVAT_Farmer__c farmer = new BVAT_Farmer__c();
        
        Person__c fPerson = new Person__c();
        String[] namesArray = answers.get('q1_0').Answer__c.split(' ');
        
        if(namesArray != null && namesArray.size() >= 1) {
            fPerson.First_Name__c = namesArray[0];
            if(namesArray.size() >= 2) {
            fPerson.Last_Name__c = namesArray[1];
            }
            else {
                fPerson.Last_Name__c = namesArray[0];
            }
        }  
        fPerson.First_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        fPerson.Last_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
        fPerson.Age__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q3_0'),'q3', 0);
        fPerson.Gender__c = translateGender(ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')));
        fPerson.Raw_Mobile_Number__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));
        
        String[] locationArray;
        if (answers.containsKey('q14_0')) {
            locationArray = answers.get('q14_0').Answer__c.split(' ');
        }
        if (locationArray != null && locationArray.size() >= 2) {
            fPerson.GPS_Location_N__c = locationArray[0];
            fPerson.GPS_Location_E__c = locationArray[1];            
        } else {
            fPerson.GPS_Location_N__c = submission.interviewLatitude;
            fPerson.GPS_Location_E__c = submission.interviewLongitude;
        }

        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save the person and get the id back
        String errorMessage;
        Database.SaveResult personSaveResult = Database.insert(fPerson);
        Id personId;

        personId = personSaveResult.getId();
        
        farmer.Person__c = personId;
        farmer.Education_Level__c = translateEducationLevel(ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0')));        
        farmer.Years_Of_Farming__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_0'),'q6',true);
        farmer.Farm_Size__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_0'),'q7',true);
        farmer.Farming_Reason__c = translateFarmingReason(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));
        farmer.Has_Farmer_Group__c = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0')));
        if (farmer.Has_Farmer_Group__c) {
            farmer.Group_Name__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0')); 
            farmer.Group_Activity__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0'));
            farmer.Group_Size__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q12_0'),'q12',true);
            farmer.GPS_Location__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q14_0')); 
        }
        farmer.Registered_By__c = ciw.Id;

        // Set a rollback point
        Savepoint spFarmer = Database.setSavepoint();

        // Save the Farmer and get the id back
        errorMessage = '';
        Database.SaveResult farmerSaveResult = Database.insert(farmer);
        Id farmerId;

        farmerId = farmerSaveResult.getId();
        
        List<String> farmerRegMetricNames = new List<String> {
            'Farmers Registered',
            'Farmers Reached',
            'Farmers in Group',
            ciw.Name
        };
        Date currentDate = handsetSubmitTime.date();
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Real_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                BVAT_CIW__c,
                Denumerator__c,
                Numerator__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c = :currentDate
            AND 
                BVAT_CIW__c =:ciw.Id
            AND
                M_E_Metric__r.Name 
            IN :farmerRegMetricNames
        ];
        if (datas.isEmpty()) {
            datas = new M_E_Metric_Data__c[]{};
            for (String metricName : farmerRegMetricNames) {
                M_E_Metric_Data__c mData = MetricHelpers.createNewMetric(metricName, currentDate, 0.0, null, null, null, 'Biovision Africa Trust', false);
                mData.BVAT_CIW__c = ciw.Id;
                datas.add(mdata);
            }
        }

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {  
             dataMap.put(mData.M_E_Metric__r.Name, mData);
        }
        
        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : farmerRegMetricNames) {
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            if (totalNewData == null) {
                totalNewData = MetricHelpers.createNewMetric(key, currentDate, 0.0, null, null, null, 'Biovision Africa Trust', false);
                totalNewData.BVAT_CIW__c = ciw.Id;
            }

            // Update the metric based on the key
            if (key.equals('Farmers Registered')) {
                 totalNewData.Denumerator__c += 1;
            }
            if (key.equals('Farmers Reached')) {
                totalNewData.Denumerator__c += 1;
            }
            if (key.equals('Farmers in Group')) {
                totalNewData.Denumerator__c += 1;
                if (farmer.Has_Farmer_Group__c) {
                    totalNewData.Numerator__c += 1;
                }
            }
            if (farmer.Has_Farmer_Group__c && key.equals(ciw.Name) && ((farmer.GPS_Location__c != null) || (farmer.GPS_Location__c != ' '))) {
                Decimal latitude = 0.0;
                Decimal longitude = 0.0;
                if (ciw.GPS_Location__c == null || ciw.GPS_Location__c == '') {
                    latitude = Decimal.valueOf(ciw.Person__r.GPS_Location_N__c);
                    longitude = Decimal.valueOf(ciw.Person__r.GPS_Location_E__c);
                }
                else {
                    String[] ciwLocation = ciw.GPS_Location__c.split(' ');
                    latitude = Decimal.valueOf(ciwLocation[0]);
                    longitude = Decimal.valueOf(ciwLocation[1]);
                }
                Decimal farmerLatitude = Decimal.valueOf(fPerson.GPS_Location_N__c);
                Decimal farmerLongitude = Decimal.valueOf(fPerson.GPS_Location_E__c);
                Decimal distanceTravelled = Utils.calcDistance(latitude, longitude, farmerLatitude, farmerLongitude);
                totalNewData.Denumerator__c += distanceTravelled;
            }
            dataMap.put(key, totalNewData);
        }
        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
        for(Database.upsertResult result : uResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    system.debug(LoggingLevel.ERROR,'Error: ' + error.getMessage()); 
                }
                return new String[] { '0', 'Error in submission', 'SUPRESSMSG' };
            }
        }
        return new String[] { '1', 'Farmer Registration survey processed for CIW Information with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    /**
     *  Fill in the BVAT_Content__c objects for this Content Survey
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the Person that Submitted the Survey
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the F/O if required.
     */
    public static List<String> processContentSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        List<String> returnValues = new List<String>();
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);

        CIW__c ciw = loadCiw(person);
        BVAT_Content__c content = new BVAT_Content__c();
                
        content.Content_Areas_Trained__c = generateCsvFromSet(getTranslatedSetOfContentAreasTrained(ProcessSubmissionHelpers.getAnswerSet(answers.get('q1_0'))));
        content.Environment__c = generateCsvFromSet(getTranslatedSetOfEnvironment(ProcessSubmissionHelpers.getAnswerSet(answers.get('q2_0'))));
        content.Crop_Management__c = generateCsvFromSet(getTranslatedSetOfCropManagement(ProcessSubmissionHelpers.getAnswerSet(answers.get('q3_0'))));
        content.Animal_Keeping__c = generateCsvFromSet(getTranslatedSetOfAnimalKeeping(ProcessSubmissionHelpers.getAnswerSet(answers.get('q4_0'))));
        content.Human_Health__c = generateCsvFromSet(getTranslatedSetOfHumanHealth(ProcessSubmissionHelpers.getAnswerSet(answers.get('q5_0'))));
        content.Key_Content_Areas__c = generateCsvFromSet(getTranslatedSetOfKeyContentAreas(ProcessSubmissionHelpers.getAnswerSet(answers.get('q6_0'))));
        content.Environment_Key_Areas__c = generateCsvFromSet(getTranslatedSetOfEnvironmentKeyAreas(ProcessSubmissionHelpers.getAnswerSet(answers.get('q7_0'))));
        content.Crop_Management_Key_Areas__c = generateCsvFromSet(getTranslatedSetOfCropManagementKeyAreas(ProcessSubmissionHelpers.getAnswerSet(answers.get('q8_0'))));
        content.Animal_Keeping_Key_Areas__c = generateCsvFromSet(getTranslatedSetOfAnimalKeepingKeyAreas(ProcessSubmissionHelpers.getAnswerSet(answers.get('q9_0'))));
        content.Human_Health_Key_Areas__c = generateCsvFromSet(getTranslatedSetOfHumanHealthKeyAreas(ProcessSubmissionHelpers.getAnswerSet(answers.get('q10_0'))));
        content.Other_Info_Needs__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0'));
        content.Accessible_FCP__c = generateCsvFromSet(getTranslatedSetOfAccessibleFcp(ProcessSubmissionHelpers.getAnswerSet(answers.get('q12_0'))));
        content.Useful_TOF_Avenue__c = translateInformationAvenue(ProcessSubmissionHelpers.getAnswerString(answers.get('q13_0')));
        content.Information_Benefits__c = generateCsvFromSet(getTranslatedSetOfInformationBenefits(ProcessSubmissionHelpers.getAnswerSet(answers.get('q14_0'))));
        content.Other_TCP_Needs__c = ProcessSubmissionHelpers.getAnswerString(answers.get('q15_0'));
        content.CIW__c = ciw.Id;
        
        
        // Set a rollback point
        Savepoint spContent = Database.setSavepoint();

        // Save the Farmer and get the id back
        String errorMessage = '';
        Database.SaveResult contentSaveResult = Database.insert(content);
        Id contentId;

        contentId = contentSaveResult.getId();
                        
        // Return success
        return new String[] { '1', 'Content survey processed for CIW Information with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    
    private static String generateCsvFromSet(Set<String> input) {
        String csvOutput = '';
        if (null != input && !input.isEmpty()) {
            for(String str: input) {
                if(csvOutput.length() > 1) {
                    csvOutput = csvOutput + ';';
                }
                csvOutput = csvOutput + str;              
            }
        }
        return csvOutput;
    }

    
    private static String translateGender(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Male',
            '2' => 'Female'         
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateFarmingReason(String optionNumber) {
        
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Consumption',
            '2' => 'Selling',
            '3' => 'Consumption and Selling'        
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateEducationLevel(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'None',
            '2' => 'Primary',
            '3' => 'Secondary',
            '4' => 'University',
            '5' => 'Tertiary'           
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateAreasOfExpertise(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Environment',
            '2' => 'Crop Management',
            '3' => 'Animal Keeping',
            '4' => 'Human Health'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateInformationAvenue(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'TOF Magazine',
            '2' => 'CIWs',
            '3' => 'TOF Radio',
            '4' => 'Infonet-Biovision',
            '5' => 'Mkulima Mbunifu'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateInformationBenefits(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Improved soil fertility',
            '2' => 'Healthy produce for consumption',
            '3' => 'Increased crop yields',
            '4' => 'Improved environmental conservation',
            '5' => 'Increased production for sale',
            '6' => 'Reduced cost of production',
            '7' => 'Better management of pests',
            '8' => 'Improved income',
            '9' => 'Improved family food security',
            '10' => 'Improved animal health and welfare',
            '11' => 'Better group interactions',
            '12' => 'Improved awareness'          
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateContentAreasTrained(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Environment',
            '2' => 'Crop Management',
            '3' => 'Animal Keeping',
            '4' => 'Human Health',
            '5' => 'Value Addition',
            '6' => 'Financial Management',
            '7' => 'Market Intelligence'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateEnvironment(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Agro-ecological zones',
            '2' => 'Water management',
            '3' => 'Soil management',
            '4' => 'Sustainable and organic agriculture',
            '5' => 'Conservation agriculture',
            '6' => 'Tree agroforestry',
            '7' => 'Food processing and value addition'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateCropManagement(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Crops fruits vegetables',
            '2' => 'Fodder production',
            '3' => 'Products',
            '4' => 'Pests diseases weeds',
            '5' => 'Fruit and vegetable processing',
            '6' => 'Natural pest control',
            '7' => 'Cultural practices'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateAnimalKeeping(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Animal husbandry and welfare',
            '2' => 'Livestock species and commercial insects',
            '3' => 'Livestock health and diseases',
            '4' => 'Zoonotic diseases',
            '5' => 'Fodder production',
            '6' => 'Animal products'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateHumanHealth(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Healthy food',
            '2' => 'Nutrition related diseases',
            '3' => 'Insect transmitted diseases',
            '4' => 'Hygiene and sanitation'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateKeyContentAreas(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Environment',
            '2' => 'Crop Management',
            '3' => 'Animal Keeping',
            '4' => 'Human Health',
            '5' => 'Value Addition',
            '6' => 'Financial Management',
            '7' => 'Market Intelligence'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateEnvironmentKeyAreas(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Agro-ecological zones',
            '2' => 'Water management',
            '3' => 'Soil management',
            '4' => 'Sustainable and organic agriculture',
            '5' => 'Conservation agriculture',
            '6' => 'Tree',
            '7' => 'Processing and value addition',
            '8' => 'Sustainable energy'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateCropManagementKeyAreas(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Crops fruits vegetables',
            '2' => 'Pest and disease management',
            '3' => 'Medicinal plants',
            '4' => 'Natural pest control',
            '5' => 'Cultural practices',
            '6' => 'Fodder production',
            '7' => 'Products'             
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateHumanHealthKeyAreas(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Healthy food',
            '2' => 'Nutrition related diseases',
            '3' => 'Insect transmitted diseases',
            '4' => 'Medicinal Plants'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    private static String translateAnimalKeepingKeyAreas(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Animal husbandry and welfare',
            '2' => 'Livestock species and commercial insects',
            '3' => 'Livestock health and diseases',
            '4' => 'Zoonotic diseases'            
        };
        
        return translationMap.get(optionNumber);
    }
    
        private static String translateCounties(String optionNumber) {
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Baringo County',
            '2' => 'Bomet County',
            '3' => 'Bungoma County',
            '4' => 'Busia County',
            '5' => 'Elgeyo/Marakwet County',
            '6' => 'Embu County',
            '7' => 'Garissa County',
            '8' => 'Homa Bay County',
            '9' => 'Isiolo County',
            '10' => 'Kajiado County',
            '11' => 'Kakamega County',
            '12' => 'Kericho County',
            '13' => 'Kiambu County',
            '14' => 'Kilifi County',
            '15' => 'Kirinyaga County',
            '16' => 'Kisii County',
            '17' => 'Kisumu County',
            '18' => 'Kitui County',
            '19' => 'Kwale County',
            '20'=> 'Laikipia County',
            '21' => 'Lamu County',
            '22' => 'Machakos County',
            '23' => 'Makueni County',
            '24' => 'Mandera County',
            '25' => 'Marsabit County',
            '26' => 'Meru County',
            '27' => 'Migori County',
            '28' => 'Mombasa County',
            '29' => 'Murang\'a County',
            '30' => 'Nairobi County',
            '31' => 'Nakuru County',
            '32' => 'Nandi County',
            '33' => 'Narok County',
            '34' => 'Nyamira County',
            '35' => 'Nyandarua County',
            '36' => 'Nyeri County',
            '37' => 'Samburu County',
            '38' => 'Siaya County',
            '39' => 'Taita Taveta County',
            '40' => 'Tana River County',
            '41' => 'Tharaka Nithi County',
            '42' => 'Trans Nzoia County',
            '43' => 'Turkana County',
            '44' => 'Uasin Gishu County',
            '45' => 'Vihiga County',
            '46' => 'Wajir County',
            '47' => 'West Pokot County'            
        };
        
        return translationMap.get(optionNumber);
    }
    
    /**
    * Methods to get translatedSet of various Multiple Select answers
    */
    private static Set<String> getTranslatedSetOfContentAreasTrained(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateContentAreasTrained(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfEnvironment(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateEnvironment(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfCropManagement(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateCropManagement(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfAnimalKeeping(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateAnimalKeeping(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfHumanHealth(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateHumanHealth(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfKeyContentAreas(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateKeyContentAreas(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;   
    }
    
    private static Set<String> getTranslatedSetOfEnvironmentKeyAreas(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateEnvironmentKeyAreas(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfCropManagementKeyAreas(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateCropManagementKeyAreas(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfHumanHealthKeyAreas(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateHumanHealthKeyAreas(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfAnimalKeepingKeyAreas(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateAnimalKeepingKeyAreas(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfAccessibleFcp(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateInformationAvenue(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfInformationBenefits(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateInformationBenefits(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
    private static Set<String> getTranslatedSetOfAreasOfExpertise(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateAreasOfExpertise(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }
    
        private static Set<String> getTranslatedSetOfCounties(Set<String> answerSet) {        
        Set<String> translatedSet;
        translatedSet = new Set<String>();
        if (null != answerSet && !answerSet.isEmpty()) {
            for(String str: answerSet) {
                String translatedValue = translateCounties(str);
                if(null != translatedValue) {
                    translatedSet.add(translatedValue);
                }
            }
        }
        
        return translatedSet;    
    }      
    
    private static CIW__c loadCiw(Person__c person) {
        CIW__c[] ciw = [
           SELECT
              Id,
              Name,
              GPS_Location__c,
              Person__r.GPS_Location_E__c,
              Person__r.GPS_Location_N__c
           FROM
               CIW__c
           WHERE
               Person__c = :person.Id
           LIMIT 1 
        ];
        
        if (!ciw.isEmpty()) {
            return ciw[0];
        }      
        return createCiwForPerson(person);
    }
    
    private static CIW__c createCiwForPerson(Person__c person) {
        CIW__c ciw = new CIW__c();
        ciw.Person__c = person.Id;
        ciw.Joining_Year__c = 2012;
        database.insert(ciw);
        return ciw;
    }
        
    
    /**
    * Methods to wrap private methods for Testing
    */
    public static String testTranslateGender(string s){
         //This method can only be called from a test method.
         //This method allows calling a private method from test code to allow for faster test performance.
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateGender(s);         
    }
    
    public static String testTranslateEducationLevel(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateEducationLevel(s);         
    }
    
    public static String testTranslateFarmingReason(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateFarmingReason(s);         
    }
    
    public static String testTranslateInformationAvenue(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateInformationAvenue(s);         
    }
    
    public static String testTranslateAreasOfExpertise(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateAreasOfExpertise(s);         
    }
    
    public static String testTranslateInformationBenefits(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateInformationBenefits(s);         
    }
    
    public static String testTranslateContentAreasTrained(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateContentAreasTrained(s);         
    }
    
    public static String testTranslateEnvironment(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateEnvironment(s);         
    }
    
    public static String testTranslateCropManagement(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateCropManagement(s);         
    }
    
    public static String testTranslateAnimalKeeping(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateAnimalKeeping(s);         
    }
    
    public static String testTranslateHumanHealth(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateHumanHealth(s);         
    }
    
    public static String testTranslateKeyContentAreas(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateKeyContentAreas(s);         
    }
    
    public static String testTranslateEnvironmentKeyAreas(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateEnvironmentKeyAreas(s);         
    }
    
    public static String testTranslateCropManagementKeyAreas(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateCropManagementKeyAreas(s);         
    }
    
    public static String testTranslateHumanHealthKeyAreas(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateHumanHealthKeyAreas(s);         
    }
    
    public static String testTranslateAnimalKeepingKeyAreas(string s){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return translateAnimalKeepingKeyAreas(s);         
    }    
    
    public static Set<String> testGetTranslatedSetOfContentAreasTrained(Set<String> data){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return getTranslatedSetOfContentAreasTrained(data);         
    }    
    
    public static String testGenerateCsvFromSetOfContentAreasTrained(Set<String> data){
         
          if (!test.isRunningTest()){
            throw new TestException('This method can only be called from a test.');
          }
         
          return generateCsvFromSet(getTranslatedSetOfContentAreasTrained(data));         
    }
    
}