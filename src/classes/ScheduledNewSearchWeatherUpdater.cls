/**
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *	Scheduling class for Weather Feeds in UpdateNewSearchWeather class CKW 3.0 Search
 **/

global class ScheduledNewSearchWeatherUpdater implements Schedulable {
    public static String cronExpression = '0 0 9 * * ?'; // run every day at 9am

    global void execute(SchedulableContext sc) {
        UpdateNewSearchWeather.updateWeather();
    }
}