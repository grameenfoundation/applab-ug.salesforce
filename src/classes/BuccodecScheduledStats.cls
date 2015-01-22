/**
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Scheduling class for importation statistical data from ckwapps.applab.org
 *  
 **/
global class BuccodecScheduledStats implements Schedulable {
    /**
     * Starts off the stats importation operations
     */
    global void execute(SchedulableContext context){
        doCalloutFromFuture();
    }

    /**
     *Scheduled apex can only allow callouts in future executions
     */
    @future (callout=true)
    private static void doCalloutFromFuture() {
        BuccodecHelpers.getRawDataStats();
    }
}