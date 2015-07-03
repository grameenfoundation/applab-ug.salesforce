trigger ValidateMarketKasesePeakDay on Market_Kasese__c (before insert) {
    for(Market_Kasese__c mrktKas : Trigger.new){
        
        C3P0_Market__c cMarkt=new C3P0_Market__c();
        cMarkt = [SELECT Peak__c FROM C3P0_Market__c WHERE Name=: trigger.new[0].Market_Name__c limit 1];
        
        if(MISPeakDay.applyPeakDayValidationKasese(cMarkt,mrktKas)){
            
        }else{
            Date capture= mrktKas.Date_of_capture__c;
            Datetime dt = (DateTime)capture;
            String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
            mrktKas.addError('Market Peak Day is Wrong! Correct Peak Day is '+cMarkt.Peak__c + ' but got '+ dayOfWeek);
        }
    }
}