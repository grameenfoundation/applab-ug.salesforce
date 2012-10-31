trigger AddMtnTdrActivity on TDR_Activity__c (before insert) {
    
    TDR_Activity__c tdrActivity = trigger.new[0];
    //Get the performance record for this activity
    TDR_Performance__c tdrPerformance = [Select Id, 
    											Times__c, 
    											Distances__c 
    									 from 
    									        TDR_Performance__c
    	                                 where 
    	                                        Id= :tdrActivity.TDR_Performance_Record__c];
    
    //Get the very first activity of the day for this tdr 
    TDR_Activity__c firstDaysActivity = [Select Id, 
                                                Activity_Latitude__c, 
                                                Activity_Longitude__c,
                                                Start_Time__c, 
                                                End_Time__c 
                                         from 
                                                TDR_Activity__c 
                                         where 
                                                TDR_Performance_Record__c = :tdrActivity.TDR_Performance_Record__c
                                         order by 
                                                CreatedDate 
                                         asc limit 1];
                                         
    //Get the previous activity for this tdr today
    TDR_Activity__c previousActivity = [Select Id,
                                               Activity_Latitude__c, 
                                                Activity_Longitude__c,
                                                Start_Time__c, 
                                                End_Time__c 
                                         from 
                                                TDR_Activity__c 
                                         where 
                                                TDR_Performance_Record__c = :tdrActivity.TDR_Performance_Record__c
                                         order by 
                                                CreatedDate 
                                         desc limit 1];
    	
    Decimal lat1 = decimal.valueOf(previousActivity.Activity_Latitude__c);
    Decimal lng1 = decimal.valueOf(previousActivity.Activity_Longitude__c);
    Decimal lat2 = decimal.valueOf(tdrActivity.Activity_Latitude__c);
    Decimal lng2 = decimal.valueOf(tdrActivity.Activity_Longitude__c);

    //Calculate the distance in metres between the 2 points of this activity and the first activity
    Decimal distance = Utils.calcDistance(lat1, lng1, lat2, lng2) * 1000;

    //Calculate the time difference between this activity and the very first one
    List<double> timeDifference = Utils.calculateTimeDifference(firstDaysActivity.End_Time__c, 
    	tdrActivity.Start_Time__c);
    	
    tdrPerformance.Distances__c = tdrPerformance.Distances__c + ',' + distance;
    tdrPerformance.Times__c = tdrPerformance.Times__c + ',' + timeDifference.get(0) + ':' +
    	timeDifference.get(1);
    	
    database.update(tdrPerformance);
}