/**
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *	Scheduling class for importation of the RSS Feeds
 **/
global class ScheduledMisLoadFitRss implements Schedulable {
	
	/**
	*	Starts off the RSS importation operations
	*/
	global void execute(SchedulableContext context){
    	System.debug(Logginglevel.INFO, 'MIS: Schedule started');
        doCalloutFromFuture();
	}
	
	/**
	*	Scheduled apex can only allow callouts in future executions
	*/
	//@future (callout=true)
  	private static void doCalloutFromFuture() {
  		MisLoadFitRss batchKeywordsExporter = new MisLoadFitRss();
  		Database.executeBatch(batchKeywordsExporter, 30);
	}
}