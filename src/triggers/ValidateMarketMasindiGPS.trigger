trigger ValidateMarketMasindiGPS on Market_Masindi__c (before insert) {
     
    for(Market_Masindi__c mrktMas : Trigger.new){
        C3P0_Market__c cMarkt=new C3P0_Market__c();
        
        cMarkt = [SELECT Market_Size__c,Market_Gps__Latitude__s,Market_Gps__Longitude__s FROM C3P0_Market__c WHERE Name=: trigger.new[0].Market_Name__c limit 1];
    
        if(MisSubcountyMarketPrices.applyMasindiGPSValidation(mrktMas,cMarkt)){
            
        }else{
            mrktMas.addError('GPS out of Range, Please go to the center of the market.');
        }
    }
}