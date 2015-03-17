global class GetJobsAndTasks implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> owner_names = new List<String>{'cisp', 'ffund', 'fao', 'Politecn'};
   
        string job_tempaltes_query = 'Select id from gfsurveys__JobTemplate__c where Owner.Alias in : owner_names and gfsurveys__Status__c =\'Published\'';
        gfsurveys__JobTemplate__c[] job_templates = Database.query(job_tempaltes_query);
        System.debug('Job Template Num:' + string.valueOf(job_templates.size()));
       
        // Task Template
        string task_templates_query = 'Select id from gfsurveys__TaskTemplate__c where gfsurveys__JobTemplate__c in :job_templates';
        gfsurveys__TaskTemplate__c[] task_templates = Database.query(task_templates_query);
        System.debug('Task Template Num:' + string.valueOf(task_templates.size()));
       
        // Job Activities
        Integer job_count = [Select Count() from gfsurveys__Job__c where gfsurveys__JobTemplate__c in :job_templates and Temp_Task_Count__c = 7 and Temp_Task_Ids_Filled__c = NULL];
        System.debug('Job Num:' + job_count);
        String query = 'Select Id from gfsurveys__Job__c where gfsurveys__JobTemplate__c in :job_templates and Temp_Task_Count__c = 7 and Temp_Task_Ids_Filled__c = NULL';
        return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
        for (sObject job: scope) {
            // Get tasks
            for (gfsurveys__Task__c[] tasks : [Select Id, gfsurveys__Submission__r.gfsurveys__Survey__r.Name from gfsurveys__Task__c where gfsurveys__Job__c =: job.Id]) {
                for (gfsurveys__Task__c task : tasks) {
                    String survey_name = task.gfsurveys__Submission__r.gfsurveys__Survey__r.Name;
                    String question_binding = '';
                    String field = '';
                    if (survey_name.contains('02_7')) {
                        question_binding = 'prd_02_02';
                        field = 'id7__c';
                    } else if (survey_name.contains('02_6')) {
                        question_binding = 'codigo_flia';
                        field = 'id6__c';
                    } else if (survey_name.contains('02_5')) {
                        question_binding = 'codigo_familia';
                        field = 'id5__c';
                    } else if (survey_name.contains('02_4')) {
                        question_binding = 'codigo_familia';
                        field = 'id4__c';
                    } else if (survey_name.contains('02_3')) {
                        question_binding = 'codigo_familia';
                        field = 'id3__c';
                    } else if (survey_name.contains('02_2')) {
                        question_binding = 'codigo_familia';
                        field = 'id2__c';
                    } else if (survey_name.contains('02_1')) {
                        question_binding = 'prd_02_2';
                        field = 'id1__c';
                    }
                    
                    if (field != '') {
                    	gfsurveys__Answer__c answer = [Select gfsurveys__Value__c from gfsurveys__Answer__c where gfsurveys__Submission__c =: task.gfsurveys__Submission__c and gfsurveys__Question__r.Name =: question_binding];
                        job.put(field, answer.gfsurveys__Value__c);
                    }    
                }
            }
            job.put('Temp_Task_Ids_Filled__c', 1);
        }
       
        update scope;
   }

   global void finish(Database.BatchableContext BC){

   }
}