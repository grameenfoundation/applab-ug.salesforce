/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Scheduling class for importation of the RSS Feeds for Agroways search
 *
 *  Class scheduled is MisLoadFitRssAggroways
 **/
global class ScheduledMisLoadFitRssAggroways implements Schedulable {
    /**
    *   Starts off the RSS importation operations
    */
    global void execute(SchedulableContext context) {
        System.debug(Logginglevel.INFO, 'MIS: Schedule started');
        doCalloutFromFuture();
    }

    /**
    *   Scheduled apex can only allow callouts in future executions
    */
   // @future (callout = true)
    private static void doCalloutFromFuture() {
        MisLoadFitRssAggroways batchKeywordsExporter = new MisLoadFitRssAggroways();
        Database.executeBatch(batchKeywordsExporter, 30);
    }
}