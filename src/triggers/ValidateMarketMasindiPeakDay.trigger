trigger ValidateMarketMasindiPeakDay on Market_Masindi__c (before insert) {
    for(Market_Masindi__c mrktMas : Trigger.new){
        
        C3P0_Market__c cMarkt=new C3P0_Market__c();
        cMarkt = [SELECT Peak__c FROM C3P0_Market__c WHERE Name=: trigger.new[0].Market_Name__c limit 1];
        
        if(MISPeakDay.applyPeakDayValidationMasindi(cMarkt,mrktMas)){
            
        }else{
            Date capture= mrktMas.Date_of_capture__c;
            Datetime dt = (DateTime)capture;
            String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
            mrktMas.addError('Market Peak Day is Wrong! Correct Peak Day is '+cMarkt.Peak__c+' but got '+ dayOfWeek);
        }
    }
}