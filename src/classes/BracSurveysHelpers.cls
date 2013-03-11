/**
* Helper class to deal with parsing submission for BRAC Surveys
*/
public with sharing class BracSurveysHelpers {
    
     /**
     *  Fill in the BRAC_Health_Visit__c objects for this BRAC Programme Assistant (PA)
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the BRAC PA who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the BRAC PA if required.
     */
    public static List<String> processHealthProgrammeSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission for FO with IMEI: ' + submission.imei, 'SUPRESSMSG' };
        }
        
        if(!ProcessSubmissionHelpers.createSubmissionMetaData(submission, person)) {
             return new String[] { '0', 'Brac PA with IMEI: ' + submission.imei + ' has submitted a survey without GPS data that is necessary ', 'SUPRESSMSG' };
        }

        BRAC_PA__c bracPa = loadBracPa(person);
        Client_Location__c clientLocation = loadClientLocation(bracPa);
        BRAC_Health_Visit__c healthVisit = getCurrentHealthVisit(bracPa);
        
        Boolean isHouseholdVisit = answers.get('hh_hf_0').Answer__c.equals('2') ? true : false;
        
        // Sort out the GPS for the submission. Look for the one in the survey. If that does not exist then use the background gps for the survey
        String[] gps = isHouseholdVisit ? ProcessSubmissionHelpers.getAnswerString(answers.get('q34_0')).split(' ') : ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')).split(' ');

        String latitude = submission.interviewLatitude;
        String longitude = submission.interviewLongitude;
        if (gps.size() > 2) {
            latitude = gps[0];
            longitude = gps[1];
        }

        Decimal distanceTravelled = Utils.calcDistance(Decimal.valueOf(latitude), Decimal.valueOf(longitude), Decimal.valueOf(clientLocation.Latitude__c), Decimal.valueOf(clientLocation.Longitude__c));
        healthVisit.Max_Distance_Traveled__c = healthVisit.Max_Distance_Traveled__c > distanceTravelled ? healthVisit.Max_Distance_Traveled__c : distanceTravelled;
        
        healthVisit.CHP_Visited__c += 1;
        healthVisit.CHP_Attended__c += 1;
        
        if (isHouseholdVisit) {
            healthVisit.Health_Visits__c += 1;
            
            // Check if there was any patient in the household
            if (answers.get('q13_0').Answer__c.equals('1')) {
                
                Boolean isMale = answers.get('q15_0').Answer__c.equals('1');
                Boolean isMalaria = answers.get('q16_0').Answer__c.equals('1');
                Boolean isDiarrhoea = answers.get('q16_0').Answer__c.equals('2');
                
                // Assign metrics based on age of sick person.  option 1 and 2 match children under 5
                if (answers.get('q14_0').Answer__c.equals('1') || answers.get('q14_0').Answer__c.equals('2')) {
                    if (isMale) {
                        if (isDiarrhoea) {
                            healthVisit.Diarrhoea_Under_5_Male__c += 1;
                        }
                        else if (isMalaria) {
                            healthVisit.Malaria_Under_5_Male__c += 1;
                        }
                    }
                    else {
                       if (isDiarrhoea) {
                            healthVisit.Diarrhoea_Under_5_Female__c += 1;
                        }
                        else if (isMalaria) {
                            healthVisit.Malaria_Under_5_Female__c += 1;
                        }
                    }
                }
                else {
                    if (isMale) {
                        if (isDiarrhoea) {
                            healthVisit.Diarrhoea_Over_5_Male__c += 1;
                        }
                        else if (isMalaria) {
                            healthVisit.Malaria_Over_5_Male__c += 1;
                        }
                    }
                    else {
                       if (isDiarrhoea) {
                            healthVisit.Diarrhoea_Over_5_Female__c += 1;
                        }
                        else if (isMalaria) {
                            healthVisit.Malaria_Over_5_Female__c += 1;
                        }
                    }               
                }
            }
        }
        else {
            healthVisit.Households_Visited__c += 1;
            String conductedForum = answers.get('hf_conducted_0').Answer__c;
            if (conductedForum.equals('1')) {
               healthVisit.CHP_Attended__c += 1;
                healthVisit.CHP_Visited__c += 1;
            }
            else if (conductedForum.equals('3')) {
               healthVisit.CHP_Attended__c += 1;
            }
        }
        
        Database.upsert(healthVisit);

        // Return success
        return new String[] { '1', 'PA Health Survey Processed for Brac PA with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    private static BRAC_PA__c loadBracPa(Person__c person) {
        BRAC_PA__c pa = [
           SELECT
              Id,
              Name,
              Area__c,
              Region__c,
              Person__c,
              Client_Location__c
           FROM
               BRAC_PA__c
           WHERE
               Person__c = :person.Id
           LIMIT 1 
        ];
        return pa;
    }
    
    private static Client_Location__c loadClientLocation(BRAC_PA__c bracPa) {
        Client_Location__c clientLocation = [
            SELECT
                Id,
                Latitude__c,
                Longitude__c
            FROM
                Client_Location__c
            WHERE
                Id = :bracPa.Client_Location__c
            LIMIT 1
        ];
        return clientLocation;
    }
    
    /*
    * Gets current BRAC_Health_Visit__c record for BRAC PA for this month. If this does not exist, 
    * a new one is created and returned
    */
    private static BRAC_Health_Visit__c getCurrentHealthVisit(BRAC_PA__c bracPa) {
        BRAC_Health_Visit__c[] healthVisits = [
            SELECT
                Id,
                Name,
                Date__c,
                Health_Visits__c,
                Households_Visited__c,
                Max_Distance_Traveled__c,
                CHP_Visited__c,
                CHP_Attended__c,
                BRAC_PA__c,
                BRAC_PA_Target__c,
                Pregnant_Women__c,
                Children_Immunised__c,
                Malaria_Under_5_Female__c,
                Malaria_Under_5_Male__c,
                Malaria_Over_5_Female__c,
                Malaria_Over_5_Male__c,
                Diarrhoea_Under_5_Male__c,
                Diarrhoea_Under_5_Female__c,
                Diarrhoea_Over_5_Male__c,
                Diarrhoea_Over_5_Female__c
            FROM
                BRAC_Health_Visit__c
            WHERE
                BRAC_PA__c = :bracPa.Id
              AND
                Date__c = :Date.today().toStartOfMonth()
            ];
        
        if (healthVisits.size() == 1) {
            return healthVisits.get(0);
        }       
         return createHealthVisitRecordForBracPa(bracPa);
    }
    
    private static BRAC_Health_Visit__c createHealthVisitRecordForBracPa(BRAC_PA__c bracPa) {
        BRAC_Health_Visit__c healthVisit = new BRAC_Health_Visit__c();
        healthVisit.BRAC_PA__c = bracPa.Id;
        
        // load latest active target
        BRAC_PA_Target__c target = [
           SELECT
               Id
           FROM
               BRAC_PA_Target__c
           WHERE
               Is_Active__c = true
           ORDER BY
               Date__c DESC
           LIMIT 1
        ];
        
        healthVisit.BRAC_PA_Target__c = target.Id;      
        healthVisit.Date__c = Date.today().toStartOfMonth();
        healthVisit.Health_Visits__c = 0;
        healthVisit.Households_Visited__c = 0;
        healthVisit.Max_Distance_Traveled__c = 0;
        healthVisit.CHP_Attended__c =0;
        healthVisit.CHP_Visited__c = 0;
        healthVisit.Pregnant_Women__c = 0;
        healthVisit.Children_Immunised__c = 0;
        healthVisit.Malaria_Under_5_Female__c = 0;
        healthVisit.Malaria_Under_5_Male__c = 0;
        healthVisit.Malaria_Over_5_Female__c = 0;
        healthVisit.Malaria_Over_5_Male__c = 0;
        healthVisit.Diarrhoea_Under_5_Male__c = 0;
        healthVisit.Diarrhoea_Under_5_Female__c = 0;
        healthVisit.Diarrhoea_Over_5_Male__c = 0;
        healthVisit.Diarrhoea_Over_5_Female__c = 0;
        Database.insert(healthVisit);
        return healthVisit;
    }    
}