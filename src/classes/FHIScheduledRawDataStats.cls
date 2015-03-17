/**
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *	Scheduling class for importation statistical data from ckwapps.applab.org
 **/
global class FHIScheduledRawDataStats implements Schedulable {
    /**
     * Starts off the stats importation operations
     */
    global void execute(SchedulableContext context){
        System.debug(Logginglevel.INFO, 'FHI stats imprt Schedule started');
        doCalloutFromFuture();
    }

    /**
     *Scheduled apex can only allow callouts in future executions
     */
    @future (callout=true)
    private static void doCalloutFromFuture() {
        FHISurveysHelpers.getRawDataStats();
    }
}