trigger ValidateMarketBushenyiPeakDay on Market_Bushenyi__c (before insert) {
        for(Market_Bushenyi__c mrktBus : Trigger.new){
            C3P0_Market__c cMarkt=new C3P0_Market__c();
            
            cMarkt = [SELECT Peak__c FROM C3P0_Market__c WHERE Name=: trigger.new[0].Market_Name__c limit 1];
            
            if(MISPeakDay.applyPeakDayValidationBushenyi(cMarkt,mrktBus)){
                
            }else{
                Date capture= mrktBus.Date_of_capture__c;
                Datetime dt = (DateTime)capture;
                String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..            
                mrktBus.addError(mrktBus.Date_of_capture__c+' Market Peak Day is Wrong! Correct Peak Day is '+cMarkt.Peak__c + ' but got '+ dayOfWeek );
            }
        }
    }