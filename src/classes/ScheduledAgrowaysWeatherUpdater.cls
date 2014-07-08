global class ScheduledAgrowaysWeatherUpdater implements Schedulable {
    public static String cronExpression = '0 0 9 * * ?'; // run every day at 9am

    global void execute(SchedulableContext sc) {
        UpdateAgrowaysWeather.updateWeather();
    }
}