/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Scheduling class for importation of the RSS Feeds for 3.0 search
 *
 *  Class scheduled is MisLoadFitRssNew
 **/
global class ScheduledMisLoadFitRssNew implements Schedulable {
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
        MisLoadFitRssNew batchKeywordsExporter = new MisLoadFitRssNew();
        Database.executeBatch(batchKeywordsExporter, 30);
    }
}