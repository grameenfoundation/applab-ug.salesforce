/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Scheduling class for importation of the RSS Feeds for Obul search
 *
 *  Class scheduled is MisLoadFitRssObul
 **/
global class ScheduledMisLoadFitRssObul implements Schedulable {
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
        MisLoadFitRssObul batchKeywordsExporter = new MisLoadFitRssObul();
        Database.executeBatch(batchKeywordsExporter, 30);
    }
}