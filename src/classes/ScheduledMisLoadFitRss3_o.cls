/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *	Scheduling class for importation of the RSS Feeds for 3.0 search
 **/
global class ScheduledMisLoadFitRss3_o implements Schedulable {
	/**
	*	Starts off the RSS importation operations
	*/
	global void execute(SchedulableContext context) {
		System.debug(Logginglevel.INFO, 'MIS: Schedule started');
		doCalloutFromFuture();
	}

	/**
	*	Scheduled apex can only allow callouts in future executions
	*/
	@future (callout = true)
	private static void doCalloutFromFuture() {
		MisLoadFitRss3_o batchKeywordsExporter = new MisLoadFitRss3_o();
		Database.executeBatch(batchKeywordsExporter, 30);
	}
}