trigger CBL_Service_UpdateDataCbl2 on CBL_Service__c (after insert) {
    Set<Id> service_Ids = new Set<Id>();
    Set<Id> cbl_Ids = new Set<Id>();
    
    //get a list with Baseline id related to service rows inserted
    for (CBL_Service__c newRow : Trigger.new) {
        service_Ids.add(newRow.Id);
            cbl_Ids.add(newRow.Baseline__c);
    }
    //get a list with service rows completed (field Baseline__r.Farmer__c)
    for(List<CBL_Service__c> services : [SELECT Id, Baseline__c, Baseline__r.Farmer__c, anualTecnicoVisits__c, certificationTrainings__c, contractsToSell_BuyCoffee__c, creditServiceImprovements__c, creditServiceScoring__c, gatheringServiceImprovements__c, gatheringServiceScore__c, mechanismsComplaints__c, meetingsParticipation__c, organizationSatisfaction__c, organizationServices__c, ReaseonVisitNotUseful__c, supplyingServiceImprovements__c, supplyingServiceScore__c, trainingsImproveCrop__c, trainingTopics__c, trainingUsefulness__c, visitUsefulness__c, Submission__c 
                FROM CBL_Service__c WHERE Id IN :service_Ids]){
        //get the farmers2 to update only the service data
        for(List<CBL2_Farmer__c> farmers : [SELECT Id, service_anualTecnicoVisits__c, service_certificationTrainings__c, service_contractsToSell_BuyCoffee__c, service_creditServiceImprovements__c, service_creditServiceScoring__c, service_gatheringServiceImprovements__c, service_gatheringServiceScore__c, service_mechanismsComplaints__c, service_meetingsParticipation__c, service_organizationSatisfaction__c, service_organizationServices__c, service_ReaseonVisitNotUseful__c, service_supplyingServiceImprovements__c, service_supplyingServiceScore__c, service_trainingsImproveCrop__c, service_trainingTopics__c, service_trainingUsefulness__c, service_visitUsefulness__c, LAC_Farmer_Details__c, Submission_Servicios__c 
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN (SELECT Farmer__c FROM CBL_CoffeeBaseline__c WHERE Id IN: cbl_Ids)]){
            for(CBL_Service__c service: services ){
                for(CBL2_Farmer__c farmer: farmers){
                    //update if the LAC_Farmer_Details are the same
                    if(farmer.LAC_Farmer_Details__c == service.Baseline__r.Farmer__c){
                        farmer.service_anualTecnicoVisits__c=service.anualTecnicoVisits__c;
                        farmer.service_certificationTrainings__c=service.certificationTrainings__c;
                        farmer.service_contractsToSell_BuyCoffee__c=service.contractsToSell_BuyCoffee__c;
                        farmer.service_creditServiceImprovements__c=service.creditServiceImprovements__c;
                        farmer.service_creditServiceScoring__c=service.creditServiceScoring__c;
                        farmer.service_gatheringServiceImprovements__c=service.gatheringServiceImprovements__c;
                        farmer.service_gatheringServiceScore__c=service.gatheringServiceScore__c;
                        farmer.service_mechanismsComplaints__c=service.mechanismsComplaints__c;
                        farmer.service_meetingsParticipation__c=service.meetingsParticipation__c;
                        farmer.service_organizationSatisfaction__c=service.organizationSatisfaction__c;
                        farmer.service_organizationServices__c=service.organizationServices__c;
                        farmer.service_ReaseonVisitNotUseful__c=service.ReaseonVisitNotUseful__c;
                        farmer.service_supplyingServiceImprovements__c=service.supplyingServiceImprovements__c;
                        farmer.service_supplyingServiceScore__c=service.supplyingServiceScore__c;
                        farmer.service_trainingsImproveCrop__c=service.trainingsImproveCrop__c;
                        farmer.service_trainingTopics__c=service.trainingTopics__c;
                        farmer.service_trainingUsefulness__c=service.trainingUsefulness__c;
                        farmer.service_visitUsefulness__c=service.visitUsefulness__c;
                        farmer.Submission_Servicios__c= service.Submission__c; 
                    }                                 
                }
            }
            //update all the farmers with new service data
            try{
                update farmers;
            }
            catch(system.Exception e){
                system.debug (e);
            }
        }
    }
}