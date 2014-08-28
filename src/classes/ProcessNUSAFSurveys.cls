/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class carries out the IG/NUSAF Surveys post-processing
 *  Its test methods are in the NUSAFDashboardTests class
 **/
public with sharing class ProcessNUSAFSurveys {
    
    /**
    *  Registers a NUSAF Visit: the location, type of visit,
    *  the date and time of visit and the trainer's name
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
    public static List<String> registerNusafActivityVisit(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {
        
        Survey__c survey = Utils.loadSurvey(submission.surveyId);
        IG_Region__c region;
        Date dateOfVisit;
        String gps;
        SubmissionType type;

        if(survey.Survey_Name__c.containsIgnoreCase('SACM')) {
            type = SubmissionType.SACM_VISIT;
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('enroll')){
            type = SubmissionType.ENROLLMENT;
        }
        else {
            type = SubmissionType.NONE;
            //someone used an incorrect post-processing method. tech should fix this
            return new String[]{ '1', 'IG/NUSAF post-processing irrelevant for submission from IMEI: ' + submission.imei + ' survey is ' + survey.Survey_Name__c , 'SUPRESSMSG' };
        }

        //determine the region
        if(survey.Survey_Name__c.containsIgnoreCase('acholi')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'ACHOLI%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('bukedi')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'BUKEDI%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('elgon')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'ELGON%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('south karamoja')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE '%SOUTH KARAMOJA%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('north karamoja')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'NORTH KARAMOJA%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('lango')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'LANGO%' LIMIT 1];
        }
        else if(survey.Survey_Name__c.containsIgnoreCase('west nile')){
            region = [SELECT Id, Name FROM IG_Region__c WHERE Name LIKE 'WEST NILE%' LIMIT 1];
        }

        try {
            //for SACM visits, some records may be null i.e submission wasn't for project monitoring - here, we end processing
            if(type == SubmissionType.SACM_VISIT){
                String activity_type = ProcessSubmissionHelpers.getAnswerString(answers.get('activity_type_0'));
                if(String.isEmpty(activity_type) || !activity_type.equals('project')){
                    return new String[]{ '1', 'IG/NUSAF SACM non-monitoring submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' }; 
                }
            }

            //SACM submissions can have multiple projects combined. This is because question q9 is a repeat
            Integer projects_count = 0;
            List<String> repeats = ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q9_', answers);
            projects_count = repeats.size() == 0 ? 1 : repeats.size();
            Map<Id, IG_Subproject_Target__c> targetsToSave = new Map<Id, IG_Subproject_Target__c>();
            List<String[]> processingResponses = new List<String[]>();
            for(Integer i = 0; i < projects_count; i++){
                District__c district;
                Subcounty__c subcounty;
	            //read the district
	            String district_str = ProcessSubmissionHelpers.getAnswerString(answers.get('district_' + i));
	            District__c[] district_all = [SELECT Id, Name FROM District__c WHERE Name = :district_str];
	            if(district_all.isEmpty()){
	                return new String[]{ '0', 'IG/NUSAF: The district ' + district_str + ' provided is not in out system, please correct and submit again', 'PULSE' };
	            }
	            district = district_all[0];
	
	            //read subcounty
	            //add "_subs" to the district to get its subcounty binding. this is how the bindings were created
	            String subcounty_str = ProcessSubmissionHelpers.getAnswerString(answers.get(district_str + '_subs_' + i));
	            Subcounty__c[] subcounty_all = 
	                [SELECT
	                    Id,
	                    Display_Name__c
	                FROM
	                    Subcounty__c
	                WHERE
	                    Display_Name__c = :subcounty_str.replace('_', ' ')
	                    AND District__r.Name = :district.Name
	                ];
	            if(subcounty_all.isEmpty()){
	                if(subcounty_str.endsWith('_tc')){
	                    //some subcounties are town councils and end with variations of 'TC' 'T.C' T/C
	                    subcounty_all = 
	                        [SELECT
	                            Id,
	                            Display_Name__c
	                        FROM
	                            Subcounty__c
	                        WHERE
	                            Display_Name__c = :subcounty_str.replace('_tc', ' t.c').replace('_', ' ')
	                            AND District__r.Name = :district.Name
	                        ];
	                    if(subcounty_all.isEmpty()){
	                        subcounty_all = 
	                            [SELECT
	                                Id,
	                                Display_Name__c
	                            FROM
	                                Subcounty__c
	                            WHERE
	                                Display_Name__c = :subcounty_str.replace('_tc', ' t/c').replace('_', ' ')
	                                AND District__r.Name = :district.Name
	                            ];
	                    }
	                }
	                if(subcounty_all.isEmpty() && subcounty_str.contains('_')){
	                    //some subcounties have hiphens instead of spaces
	                    subcounty_str = subcounty_str.replace('_', '-');
	                    subcounty_all = 
	                        [SELECT
	                            Id,
	                            Display_Name__c
	                        FROM
	                            Subcounty__c
	                        WHERE
	                            Display_Name__c = :subcounty_str.replace('_', ' ')
	                            AND District__r.Name = :district.Name
	                        ];
	                }
	            }
	            if(subcounty_all.isEmpty()){
	                return new String[]{ '0', 'IG/NUSAF: The subcounty ' + subcounty_str.replace('_', ' ') + ' provided is not in salesforce or the district specified. Please inform your regional manager.', 'PULSE' };
	            }
	            subcounty = subcounty_all[0];
	
	            //here we can get the target name
	            //add "_subprojects" to the subcounty to get its subproject binding. this is how the bindings were created
	            String subproject_index = ProcessSubmissionHelpers.getAnswerString(answers.get( subcounty_str.replace(' ', '_').replace('-', '_') + '_subprojects_' + i ));
	
	            //get target object to be updated
	            IG_Subproject_Target__c[] targetsToUpdate = 
	                [SELECT       
	                    Name,                                 
	                    DateMobilization__c,                      
	                    DateFollowupVisit1__c,                    
	                    DateFollowupVisit2__c,                    
	                    DateFollowupVisit3__c,                    
	                    DatePreliminaryTrainingDay1__c,           
	                    DatePreliminaryTrainingDay2__c,           
	                    DatePreliminaryTrainingDay3__c,    
	                    LocationMobilization__c,
	                    LocationFollowupVisit1__c,
	                    LocationFollowupVisit2__c,
	                    LocationFollowupVisit3__c,
	                    LocationPreliminaryTrainingDay1__c,
	                    LocationPreliminaryTrainingDay2__c,
	                    LocationPreliminaryTrainingDay3__c,       
	                    IG_Region__c,                             
	                    District__c,                              
	                    Subcounty__c, 
	                    Subcounty__r.Display_Name__c,
	                    District__r.Name,                            
	                    Person__c,                                
	                    Person__r.First_Name__c,                  
	                    Person__r.Last_Name__c                    
	                FROM                                          
	                    IG_Subproject_Target__c                   
	                WHERE                                         
	                    Person__c = :interviewer.Id
	                    AND IG_Region__c = :region.Id
	                    AND District__r.Name = :district.Name
	                    AND Subcounty__r.Display_Name__c = :subcounty.Display_Name__c
	                    AND Phone_Display_Item_Position__c = :Integer.valueOf(subproject_index)];  
	            if(targetsToUpdate.isEmpty()) { 
	                //we have to get the person type__c since it was not retrieved in interviewer
	                Person__c interviewer_o = [SELECT Id, Name, Type__c FROM Person__c WHERE Id =:interviewer.Id];
	                if(interviewer_o.Type__c == IGDashboardHelpers.REGIONAL_MANAGER) {
	                    targetsToUpdate = 
	                        [SELECT       
	                            Name,                                 
	                            DateMobilization__c,                      
	                            DateFollowupVisit1__c,                    
	                            DateFollowupVisit2__c,                    
	                            DateFollowupVisit3__c,                    
	                            DatePreliminaryTrainingDay1__c,           
	                            DatePreliminaryTrainingDay2__c,           
	                            DatePreliminaryTrainingDay3__c,    
	                            LocationMobilization__c,
	                            LocationFollowupVisit1__c,
	                            LocationFollowupVisit2__c,
	                            LocationFollowupVisit3__c,
	                            LocationPreliminaryTrainingDay1__c,
	                            LocationPreliminaryTrainingDay2__c,
	                            LocationPreliminaryTrainingDay3__c,       
	                            IG_Region__c,                             
	                            District__c,                              
	                            Subcounty__c,    
	                            Subcounty__r.Display_Name__c,
	                            District__r.Name,                         
	                            Person__c,                                
	                            Person__r.First_Name__c,                  
	                            Person__r.Last_Name__c                    
	                        FROM                                          
	                            IG_Subproject_Target__c                   
	                        WHERE                                         
	                            IG_Region__c = :region.Id
	                            AND District__r.Name = :district.Name
	                            AND Subcounty__r.Display_Name__c = :subcounty.Display_Name__c
	                            AND Phone_Display_Item_Position__c = : Integer.valueOf(subproject_index)]; 
	                    if(targetsToUpdate.isEmpty()){
	                        return new String[]{ '0', 'IG/NUSAF: Could not find the specified subproject located in ' + subcounty_str + ' subcounty.', 'PULSE' };
	                    }
	                }
	            }
	            if(targetsToUpdate.isEmpty()){
	                return new String[]{ '0', 'IG/NUSAF: It looks like you were not assigned this target located in ' + subcounty_str + ' subcounty. Please contact your regional manager to do the assignment', 'PULSE' };
	            }
                IG_Subproject_Target__c target = targetsToUpdate[0];
	
	            dateOfVisit = Date.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('date_0')));
	            gps = ProcessSubmissionHelpers.getAnswerString(answers.get('gps_0'));
	            if(String.isNotEmpty(gps)){
	                gps = gps.split(' ')[0] + ' ' + gps.split(' ')[1];
	            }
	            else {
	                return new String[]{ '0', 'IG/NUSAF: ' + target.Name + ': You did not record the location of your visit. Please try capturing GPS and resubmit', 'PULSE' };
	            }
	
	            //if enrollment, update gps and date
	            if(type == SubmissionType.ENROLLMENT){
	                Boolean completed = ProcessSubmissionHelpers.getAnswerString(answers.get('completed_0')).equals('1');
	                target.DateMobilization__c = dateOfVisit;
	                target.LocationMobilization__c = gps;
	                targetsToSave.put(target.Id, target);
	                if(completed){
	                    processingResponses.add(new String[]{ '1', 'IG/NUSAF enrollment submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' });  
	                }
	                else{
	                    processingResponses.add(new String[]{ '1', 'IG/NUSAF enrollment submission for IMEI: ' + submission.imei + ' ' + target.Name + ' training was marked as Not-Completed. Please complete and resubmit.', 'PULSE' });     
	                }
	            }
	            else {
	                //if(type == SubmissionType.SACM_VISIT)
	                String meeting_type = ProcessSubmissionHelpers.getAnswerString(answers.get('meeting_type_0'));
	                if(meeting_type == null){
	                    return new String[]{ '0', target.Name + ': IG/NUSAF SACM FAILED. Answer on main activity of the day is missing - for IMEI: ' + submission.imei, 'PULSE' };                
	                }
	                else if(meeting_type.equals('training_day_1')){
	                    target.DatePreliminaryTrainingDay1__c = dateOfVisit;
	                    target.LocationPreliminaryTrainingDay1__c = gps;
	                }
	                else if(meeting_type.equals('training_day_2')){
	                    target.DatePreliminaryTrainingDay2__c = dateOfVisit;
	                    target.LocationPreliminaryTrainingDay2__c = gps;                
	                }
	                else if(meeting_type.equals('training_day_3')){
	                    target.DatePreliminaryTrainingDay3__c = dateOfVisit;
	                    target.LocationPreliminaryTrainingDay3__c = gps;                
	                }
	                else if(meeting_type.equals('followup_visit_1')){
	                    target.DateFollowupVisit1__c = dateOfVisit;
	                    target.LocationFollowupVisit1__c = gps;
	                }
	                else if(meeting_type.equals('followup_visit_2')){
	                    target.DateFollowupVisit2__c = dateOfVisit;
	                    target.LocationFollowupVisit2__c = gps;
	                }
	                else if(meeting_type.equals('followup_visit_3')){
	                    target.DateFollowupVisit3__c = dateOfVisit;
	                    target.LocationFollowupVisit3__c = gps;
	                }
	                //check if followup visits are completed
	                String project_status = ProcessSubmissionHelpers.getAnswerString(answers.get('project_status_0'));
	                if(project_status != null && project_status.equals('completed')){
	                    target.Monitoring_Concluded__c = true;
	                }
	                targetsToSave.put(target.Id, target);
	                processingResponses.add(new String[]{ '1', 'IG/NUSAF SACM submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' });
	            }
            }
            //we reach this point if processing is successful and there are records to update
            update targetsToSave.values();
            String combinedResponse = '';
            for(String[] response : processingResponses){
                System.debug(response);
                combinedResponse += response[1] + ' ';
            }
            return new String[]{ '1', combinedResponse, 'SUPRESSMSG' };
        }
        catch(Exception ex) {
            String message_ex = 'IG/NUSAF ----> you provided incorrect data or missing fields (' + ex.getMessage() + '::at line ' + ex.getLineNumber() + ') Please fill in correctly. If this persists, contact your regional manager for support';
            message_ex += '[' + survey.Survey_Name__c + ']';
            String[] response = new String[]{ '0', message_ex, 'PULSE' };
            System.debug(LoggingLevel.ERROR, response);
            return response;
        }
    } 

    public enum SubmissionType { ENROLLMENT, SACM_VISIT, NONE }
}