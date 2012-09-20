public with sharing class LacDashboardController {

        
        
        
        private final List<Survey__c> survey;

        public LacDashboardController() {
                survey = [select Survey_Name__c, Export_URL__c, Start_Date__c, Survey_Status__c from Survey__c];
                                
        }
        
        public List<Survey__c> getSurvey(){
                return survey; 
                
        }
}