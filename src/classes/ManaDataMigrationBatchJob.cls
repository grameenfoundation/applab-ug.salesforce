global class ManaDataMigrationBatchJob implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext bc) {
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
        String query = 'Select Id, temp_processed__c from gfsurveys__Job__c where gfsurveys__JobTemplate__c in :job_templates and Temp_Task_Count__c = 7 and ids_equal__c = \'true\' and temp_processed__c = False';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<gfsurveys__Job__c> jobs) {
		for (gfsurveys__Job__c job : jobs) {
			if(job.temp_processed__c == true)
                continue;
        
            Mana_Household__c household = new Mana_Household__c();
            Mana_Household_Repeatable_Data__c householdRepeatableData = new Mana_Household_Repeatable_Data__c();
            Map<Decimal, Mana_Beneficiary__c> beneficiaries = new Map<Decimal, Mana_Beneficiary__c>();
            Map<Decimal, Contact> contacts = new Map<Decimal, Contact>();
            List<Mana_Food_Consumption_Submission__c> consumption_records = new List<Mana_Food_Consumption_Submission__c>();
            List<Mana_Household_PPI_Score__c> ppis = new List<Mana_Household_PPI_Score__c>();
                
            for (gfsurveys__Task__c[] tasks : [Select Id, gfsurveys__Submission__r.gfsurveys__PPIScore__c, gfsurveys__Submission__r.gfsurveys__Surveyor__c, gfsurveys__Submission__r.gfsurveys__Survey__r.Name, gfsurveys__Submission__r.gfsurveys__Survey__r.OwnerId from gfsurveys__Task__c where gfsurveys__Job__c =: job.Id]) {
                for (gfsurveys__Task__c task : tasks) {
                    String survey_name = task.gfsurveys__Submission__r.gfsurveys__Survey__r.Name;
                    String question_binding = '';
                    String field = '';
                   
                    if (survey_name.contains('02_7')) {
                        // Baseline
                        // Create contact, beneficiary and household
                        household.Registration_Submission_Record__c = task.gfsurveys__Submission__c;
                        household.Interviewer__c = task.gfsurveys__Submission__r.gfsurveys__Surveyor__c;
                       
                        // Process Baseline
                        processBaseline(task.gfsurveys__Submission__r, household, contacts, beneficiaries, householdRepeatableData);
                       
                        // Insert household
                        insert household;
                       
                        System.debug('Contact Size: ' + contacts.size());
                        System.debug('Beneficiary Size: ' + beneficiaries.size());
                        
                        List <Contact> contacts_to_insert = new List<Contact>();
                        for (Decimal Key : contacts.keySet()) {
                            contacts_to_insert.add(contacts.get(key));
                        }
                        
                        if (contacts_to_insert.size() > 0) {
                            insert contacts_to_insert;
                        }
                       
                        
                        List <Mana_Beneficiary__c> beneficiaries_to_insert = new List<Mana_Beneficiary__c>();
                        for (Decimal key : beneficiaries.keySet()) {
                            Contact contact = contacts.get(key);
                            if (contact != null) {
                                beneficiaries.get(key).Contact__c = contact.Id;
                                beneficiaries.get(key).Household__c = household.Id;
                            }
                           
                            beneficiaries_to_insert.add(beneficiaries.get(key));
                        }
                        
                        if (beneficiaries_to_insert.size() > 0) {
                            insert beneficiaries_to_insert;
                        }
                       
                        householdRepeatableData.Household__c = household.Id;
                        insert householdRepeatableData;
                    } else if (survey_name.contains('02_6')) {
                        // PPI
                        // Create household PPI
                        Mana_Household_PPI_Score__c ppi = new Mana_Household_PPI_Score__c();
                        ppi.Score__c = task.gfsurveys__Submission__r.gfsurveys__PPIScore__c;
                        ppis.add(ppi);
                    } else if (survey_name.contains('02_5') || survey_name.contains('02_4') || survey_name.contains('02_3') || survey_name.contains('02_2') || survey_name.contains('02_1')) {
                        // Weekly consumption - Other
                        // Just create a Food Consumption Submission Record
                        Mana_Food_Consumption_Submission__c consumption_record = new Mana_Food_Consumption_Submission__c();
                        consumption_record.Submission__c = task.gfsurveys__Submission__c;
                        consumption_records.add(consumption_record);
                    }
                }
            }
           
            if (household.Id != null) {
                if (consumption_records.size() > 0) {
                    for (Mana_Food_Consumption_Submission__c consumption_record: consumption_records) {
                         consumption_record.Household__c = household.Id;
                    }
                    insert consumption_records;
                }
               
                if (ppis.size() > 0) {
                    for (Mana_Household_PPI_Score__c ppi: ppis) {
                        ppi.Household__c = household.Id;
                    }
                    insert ppis;
                }
            }
            job.temp_processed__c = true;
		}
        
		update jobs;
	}

	private void processBaseline(gfsurveys__Submission__c submission, Mana_Household__c household, Map<Decimal, Contact> contacts, Map<Decimal, Mana_Beneficiary__c> beneficiaries, Mana_Household_Repeatable_Data__c householdRepeatableData) {
        //processing top level answers
        for (gfsurveys__Answer__c answer:
             [SELECT
              Id,
              gfsurveys__Question__r.name,
              gfsurveys__Question__r.gfsurveys__Caption__c,
              gfsurveys__Value__c,
              gfsurveys__Parent__c,
              gfsurveys__Instance__c
              FROM gfsurveys__Answer__c WHERE  gfsurveys__Submission__c = :submission.Id AND gfsurveys__Parent__c = NULL]) {
                 
                  String name = answer.gfsurveys__Question__r.Name;
                  String caption = answer.gfsurveys__Question__r.gfsurveys__Caption__c;
                  String value = answer.gfsurveys__Value__c;
                 
                  if (value != null) {
                      populateManaHousehold(name, value, caption, household);
                      populateManaHouseholdRepeatableData(name, value, caption, householdRepeatableData);
                  }
                 
                  for (gfsurveys__Answer__c child :
                       [SELECT
                        Id,
                        gfsurveys__Question__r.name,
                        gfsurveys__Question__r.gfsurveys__Caption__c,
                        gfsurveys__Value__c,
                        gfsurveys__Parent__c,
                        gfsurveys__Instance__c
                        FROM gfsurveys__Answer__c WHERE  gfsurveys__Submission__c = :submission.Id AND gfsurveys__Parent__c = :answer.Id]) {
                            System.debug('Found Child: ' + child.Id);
                           
                            Mana_Beneficiary__c beneficiary = null;
                            Contact contact = null;
                           
                            if(child.gfsurveys__Instance__c != null) {
                                System.debug('Found Child Instance: ' + child.gfsurveys__Instance__c);
                                beneficiary = beneficiaries.get(child.gfsurveys__Instance__c);
                                if(beneficiary == null) {
                                    beneficiary = new Mana_Beneficiary__c();
                                    beneficiaries.put(child.gfsurveys__Instance__c, beneficiary);
                                }
                               
                                contact = contacts.get(child.gfsurveys__Instance__c);
                                if(contact == null) {
                                    contact = new Contact();
                                    contact.OwnerId = submission.gfsurveys__Survey__r.OwnerId;
                                    contacts.put(child.gfsurveys__Instance__c, contact);
                                }
                            }
                           
                            populateContact(child.gfsurveys__Question__r.Name, child.gfsurveys__Value__c, contact);
                            populateBeneficiary(child.gfsurveys__Question__r.Name, child.gfsurveys__Value__c, beneficiary);
                        }
              }
        System.debug('Contact size: ' + contacts.size());
        System.debug('Beneficiary size: ' + beneficiaries.size());
    }
    
    private void populateBeneficiary (String name, String value, Mana_Beneficiary__c beneficiary) {
        if (name == 'edad') {
            beneficiary.Reported_Age__c = Decimal.valueOf(value);
        } else if (name == 'prd_02_15') {
            //beneficiary.
        } else if (name == 'prd_02_20a') {
            beneficiary.Desmovilizados__c = value;
        } else if (name == 'prd_02_20b') {
            beneficiary.Victimas_del_conflicto__c = value;
        } else if (name == 'prd_02_20c') {
            beneficiary.Discapacitados__c = value;
        } else if (name == 'prd_02_20d') {
            beneficiary.LGTBI__c = value;
        } else if (name == 'prd_02_24') {
            beneficiary.Attends_School__c = value;
        } else if (name == 'prd_02_26a') {
            beneficiary.Control_prenatal__c = value;
        } else if (name == 'prd_02_26b') {
            beneficiary.Crecimiento_y_desarrollo__c = value;
        } else if (name == 'prd_02_26c') {
            beneficiary.Mana_infantil__c = value;
        } else if (name == 'prd_02_26d') {
            beneficiary.PAE__c = value;
        } else if (name == 'prd_02_26e') {
            beneficiary.Centro_de_Recuperacion_Nutricional__c = value;
        } else if (name == 'prd_02_26f') {
            beneficiary.Red_unidos__c = value;
        } else if (name == 'prd_02_26g') {
            beneficiary.Otros_programas__c = value;
        }
    }
    
    private void populateContact(String name, String value, Contact contact) {
        if (name == 'prd_02_11_1') {
            contact.LastName = value;
        } else if (name == 'prd_02_12_1') {
            contact.FirstName = value;
        } else if (name == 'prd_02_13') {
            contact.BirthDate = Date.valueOf(value);
        }
    }
    
    private void populateManaHouseholdRepeatableData(String name, String value, String caption, Mana_Household_Repeatable_Data__c householdRepeatableData) {
        if (name == 'integrante_menor_18') {
            householdRepeatableData.FS_Children__c = value;
        } else if (name == 'gasto_alimentos_semana') {
            householdRepeatableData.Weekly_Food_Spend__c = value;  
        } else if (name == 'prd_02_28') {
            householdRepeatableData.Has_Backyard_Garden__c = value;
        } else if (name == 'excedentes_huerta') {
            householdRepeatableData.Backyard_Garden_Generates_Surplus__c = value;  
        } else if (name == 'ingreso_huerta_mes') {
            householdRepeatableData.Backyard_Garden_Monthly_Sales__c = Double.valueOf(value);  
        } else if (name == 'prd_02_30') {
            householdRepeatableData.Backyard_Garden_Main_Fertilizer_Type__c = value;  
        } else if (name == 'prd_02_31') {
            householdRepeatableData.Backyard_Garden_Pest_Control_Method__c = value;  
        } else if (name == 'prd_02_34') {
            householdRepeatableData.FS_1__c = value;  
        } else if (name == 'prd_02_35') {
            householdRepeatableData.FS_2__c = value;  
        } else if (name == 'prd_02_36') {
            householdRepeatableData.FS_3__c = value;  
        } else if (name == 'prd_02_37') {
            householdRepeatableData.FS_4__c = value;  
        } else if (name == 'prd_02_38') {
            householdRepeatableData.FS_5__c = value;
        } else if (name == 'prd_02_39') {
            householdRepeatableData.FS_6__c = value;  
        } else if (name == 'prd_02_40') {
            householdRepeatableData.FS_7__c = value;  
        } else if (name == 'prd_02_41') {
            householdRepeatableData.FS_8__c = value; 
        } else if (name == 'prd_02_42') {
            householdRepeatableData.FS_9__c = value;
        } else if (name == 'prd_02_43') {
            householdRepeatableData.FS_10__c = value;  
        } else if (name == 'prd_02_44') {
            householdRepeatableData.FS_11__c = value;  
        } else if (name == 'prd_02_45') {
            householdRepeatableData.FS_12__c = value;
        } else if (name == 'prd_02_46') {
            householdRepeatableData.FS_13__c = value;
        } else if (name == 'prd_02_47') {
            householdRepeatableData.FS_14__c = value;  
        } else if (name == 'prd_02_48') {
            householdRepeatableData.FS_15__c = value; 
        }
    }
    
    private void populateManaHousehold(String name, String value, String caption, Mana_Household__c household) {
        if (name == 'prd_02_02') {
            household.Name = value;
        } else if (caption.toLowerCase() == 'region') {
            household.Region__c = value;
        } else if (caption.toLowerCase() == 'municipio') {
               household.Municipio__c = value; 
        } else if (name == 'prd_02_06') {
            household.Zona__c = value;
        } else if (caption.toLowerCase() == 'corregimiento') {
            household.Corrigimiento__c = value;
        } else if (name == 'vereda') {
            household.Vereda__c = value;
        } else if (name == 'lugar_encuesta') {
            household.Survey_Place__c = value;
        } else if (name == 'prd_02_10') {
            household.Sisben_Score__c = Decimal.valueOf(value);
        } else if (name == 'integrates_flia') {
            household.Miembros_del_hogar__c = Decimal.valueOf(value);
        } else if (name == 'telefono_sms') {
            household.Telefono__c = value;
        }
    }

	global void finish(Database.BatchableContext bc) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {'crmadmin@applab.org'});
		mail.setReplyTo('crmadmin@applab.org');
		mail.setSenderDisplayName('MANA Data Migration Batch Processing');
		mail.setSubject('MANA Data Migration Batch Process Completed');
		mail.setPlainTextBody('Batch Process has completed');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}