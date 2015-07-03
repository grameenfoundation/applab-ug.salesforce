/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *	Scheduling class for Weather Feeds in UpdateObulSearchWeather class Obul CKW Search
 **/
global  class ScheduledObulSearchWeatherUpdater implements Schedulable {
	
	public static String cronExpression = '0 0 9 * * ?'; // run every day at 9am

    global void execute(SchedulableContext sc) {
        UpdateObulSearchWeather.updateWeather();
    }
}