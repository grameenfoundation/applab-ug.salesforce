trigger ValidateMarketKasesePeakDay on Market_Kasese__c (before insert) {
    for(Market_Kasese__c mrktKas : Trigger.new){
        
        C3P0_Market__c cMarkt=new C3P0_Market__c();
        cMarkt = [SELECT Peak__c FROM C3P0_Market__c WHERE Name=: trigger.new[0].Market_Name__c limit 1];
        
        if(MISPeakDay.applyPeakDayValidation(cMarkt)){
            
        }else{
            mrktKas.addError('Market Peak Day is Wrong! Correct Peak Day is '+cMarkt.Peak__c);
        }
    }
}