global class ManaHouseholdProductionRecordBatchJob implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Mana Household Production Record Surveys
        List<Id> survey_ids = new List<Id>{'a1h70000001Kpew', 'a1h70000001Kpf6', 'a1h70000001Kpf1', 'a1h70000001KpfB'};
        String query = 'Select Id from gfsurveys__Submission__c WHERE  gfsurveys__Survey__c IN :survey_ids AND temp_production_processed__c = False';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<gfsurveys__Submission__c> submissions) {
        System.debug('Orig num: ' + submissions.size());
        List<Mana_Household_Production_Record__c> records = new List<Mana_Household_Production_Record__c>();
        for (gfsurveys__Submission__c submission : submissions) { 
            System.debug('Submission: ' + submission.Id);
            // MANA Household Production Record
            Mana_Household_Production_Record__c record = new Mana_Household_Production_Record__c();
            String household_id_string = NULL;
            for (gfsurveys__Answer__c[] answers: [SELECT Id, 
                                                  gfsurveys__Question__r.name, 
                                                  gfsurveys__Question__r.gfsurveys__Caption__c, 
                                                  gfsurveys__Value__c, gfsurveys__Parent__c, 
                                                  gfsurveys__Instance__c,
                                                  gfsurveys__NumericValue__c
                                                  FROM gfsurveys__Answer__c WHERE gfsurveys__Submission__c =: submission.Id]){
                                                      for (gfsurveys__Answer__c answer: answers) {
                                                          String name = answer.gfsurveys__Question__r.Name;
                                                          String caption = answer.gfsurveys__Question__r.gfsurveys__Caption__c;
                                                          String value = answer.gfsurveys__Value__c;
                                                          Decimal numeric_value = answer.gfsurveys__NumericValue__c;
                                                          
                                                          if (caption == 'Código de familia') { household_id_string = value;}
                                                          else if (caption == 'Visita número') { record.Family_Visits__c = numeric_value;}
                                                          else if (caption == 'Fase de la huerta') { record.Backyard_Garden_Stage__c = value;} 
                                                          else if (caption == 'Área de la huerta (metros cuadrados)') { record.Backyard_Garden_Area__c = numeric_value;} 
                                                          else if (caption == 'Kilogramos producidos de ACELGA en la huerta en el último mes') { record.Acelga__c = numeric_value;}
                                                          else if (caption== 'Kilogramos producidos de AJÍ en la huerta en el último mes') { record.Aji__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de ARVEJA en la huerta en el último mes') { record.Arveja__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de ARROZ en la huerta en el último mes') { record.Arroz__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de BANANO en la huerta en el último mes') { record.Banano__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de BERENJENA en la huerta en el último mes') { record.Berenjena__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de BRÓCOLI en la huerta en el último mes') { record.Brocoli__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de CALABACÍN en la huerta en el último mes') { record.Calabacin__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de CEBOLLA DE RAMA en la huerta en el último mes') { record.Cebola_De_Rama__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de CEBOLLA DE HUEVO en la huerta en el último mes') { record.Cebola_De_Huevo__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de CILANTRO en la huerta en el último mes') { record.Cilantro__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de COL en la huerta en el último mes') { record.Col__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de COLIFLOR en la huerta en el último mes') { record.Coliflor__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de CURUBA en la huerta en el último mes') { record.Curuba__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de ESPINACA en la huerta en el último mes') { record.Espinaca__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de FRÍJOL en la huerta en el último mes') { record.Frijol__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de GRANADILLA en la huerta en el último mes') { record.Granadilla__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de HABICHUELA en la huerta en el último mes') { record.Habichuela__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de LECHUGA en la huerta en el último mes') { record.Lechuga__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de LULO en la huerta en el último mes') { record.Lulo__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de MAÍZ en la huerta en el último mes') { record.Maiz__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de MARACUYÁ en la huerta en el último mes') { record.Maracuya__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de MELÓN en la huerta en el último mes') { record.Melon__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de PAPAYA en la huerta en el último mes') { record.Papaya__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de PEPINO en la huerta en el último mes') { record.Pepino__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de PIMENTÓN en la huerta en el último mes') { record.Pimenton__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de PIÑA en la huerta en el último mes') { record.Pina__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de RÁBANO en la huerta en el último mes') { record.Rabano__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de REMOLACHA en la huerta en el último mes') { record.Remolacha__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de REPOLLO en la huerta en el último mes') { record.Repollo__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de SANDÍA en la huerta en el último mes') { record.Sandia__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de TOMATE ALIÑO en la huerta en el último mes') { record.Tomate_Alino__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de TOMATE DE ÁRBOL en la huerta en el último mes') { record.Tomate_De_Arbol__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de UCHUVA en la huerta en el último mes') { record.Uchuva__c = numeric_value;}
                                                          else if (caption == 'Kilogramos producidos de ZANAHORIA en la huerta en el último mes') { record.Zanahoria__c = numeric_value;}
                                                          else if (caption == 'Autoconsumo (Kg)') { record.Autoconsumo_Destination_Amount__c = numeric_value;}
                                                          else if (caption == 'Trueque (Kg)') { record.Trueque_Destination_Amount__c = numeric_value;}
                                                          else if (caption == 'Venta excedentes (Kg)') { record.Venta_Destination_Amount__c = numeric_value;}
                                                          else if (caption == 'Donación (Kg)') { record.Donacion_Destination_Amount__c = numeric_value;}
                                                          else if (caption == '¿La huerta cuenta con más de cinco especies sembradas?') { record.PC_1__c = value;}
                                                          else if (caption == '¿La huerta cuenta con más de dos especies NATIVAS sembradas?') { record.PC_6__c = value;}
                                                          else if (caption == '¿Cuenta con semilleros implementados?') { record.PC_2__c = value;}
                                                          else if (caption == '¿Tiene espacio de almacenamiento de agua?') { record.PC_7__c = value;}
                                                          else if (caption == '¿Cuenta con siembra escalonada?') { record.PC_3__c = value;}
                                                          else if (caption == '¿La familia hace uso racional de las semillas?') { record.PC_8__c = value;}
                                                          else if (caption == '¿La familia utiliza las distancias adecuadas para la siembra de hortalizas?') { record.PC_4__c = value;}
                                                          else if (caption == '¿Presencia de especies hortícolas de los 5 colores?') { record.PC_9__c = value;}
                                                          else if (caption == '¿Realizan cosecha oportuna de los cultivos?') { record.PC_5__c = value;}
                                                          else if (caption == '¿Realizan siembras periódicas?') { record.PC_10__c = value;}
                                                          else if (caption == '¿La familia realiza biocompostaje?') { record.DS_1__c = value;}
                                                          else if (caption == '¿La familia realiza rotación de cultivos?') { record.DS_4__c = value;}
                                                          else if (caption == '¿La familia hace uso de las trampas de colores?') { record.DS_2__c = value;}
                                                          else if (caption == '¿La familia implementa biopreparados?') { record.DS_5__c = value;}
                                                          else if (caption == '¿Tienen producción local de semillas?') { record.DS_3__c = value;}
                                                          else if (caption == '¿La familia conserva adecuadamente las semillas?') { record.DS_6__c = value;}
                                                      }
                                                  }
            
            // If the record has a household, let's save it
            if (household_id_string != NULL) {
                Mana_Household__c[] households = [Select Id FROM Mana_Household__c WHERE Name =: household_id_string];
                if (households.size() > 0) {
                    record.Household__c = households[0].Id;
                    records.add(record);
                    record.Submission__c = submission.Id;
                    submission.temp_production_processed__c = True;
                }
            }
        }
        if (records.size() > 0) {
            insert records;
            System.debug('Records inserted: ' + records.size());
        }
        update submissions;
    }
    
    global void finish(Database.BatchableContext bc) {
        // Do nothing
    }
}