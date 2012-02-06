global class ScheduledTdrDailyEmail implements Schedulable {

    // CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    // Run every day at 6am
    public static String cronExpression = '0 0 6 * * ?';

    global void execute(SchedulableContext sc) {

        Map<String, String> tdrParameters = new Map<String, String>();
        Country__c uganda = [
            SELECT
                Name,
                Id
            FROM
                Country__c
            WHERE
            Name = 'Uganda'
        ];
        tdrParameters.put('countries', '\'' + uganda.Id + '\'');

        // Get all the regions in Uganda and create a map of them
        Region__c[] regions = [
            SELECT
                Display_Name__c,
                Id
            FROM
                Region__c
            WHERE
                Country__r.Name = 'Uganda'
        ];
        Map<String, String> regionMap = new Map<String, String>();
        for (Region__c region : regions) {
            regionMap.put(region.Display_Name__c, (String)region.Id);
        }

        // Generate the parameters map for getting the tdrs
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('countries', '\'' + uganda.Id + '\'');
        List<String> tdrIds = new List<String>();

        // Add the dates for yesterday
        Date startDate = Date.today().addDays(-1);
        parameters.put('startDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate), true));
        parameters.put('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate), true));

        // Send the emails to the national level
        List<String> emailAddresses = new List<String>();
        emailAddresses.add('mwamir@mtn.co.ug');
        emailAddresses.add('kwebiij@mtn.co.ug');
        emailAddresses.add('nalukwb@mtn.co.ug');
        emailAddresses.add('lukandd@mtn.co.ug');
        TDR__c[] tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send to Central region
        emailAddresses.add('kiwagin@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('Central') + '\'');
        parameters.put('regions', '\'' + regionMap.get('Central') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send to East region
        emailAddresses.add('gyagene@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('Eastern') + '\'');
        parameters.put('regions', '\'' + regionMap.get('Eastern') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send to West region
        emailAddresses.add('ndobolj@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('Western') + '\'');
        parameters.put('regions', '\'' + regionMap.get('Western') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send to South West region
        emailAddresses.add('mutakar@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('South Western') + '\'');
        parameters.put('regions', '\'' + regionMap.get('South Western') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send to North region
        emailAddresses.add('ogwangp@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('Northern') + '\'');
        parameters.put('regions', '\'' + regionMap.get('Northern') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();

        // Send email to West Nile region
        emailAddresses.add('kibirae@mtn.co.ug');
        tdrParameters.put('regions', '\'' + regionMap.get('West Nile') + '\'');
        parameters.put('regions', '\'' + regionMap.get('West Nile') + '\'');
        tdrs = TdrHelpers.loadTdrs(tdrParameters, null);
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', TdrHelpers.generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();
        TdrHelpers.sendReportingEmails(parameters, emailAddresses);
        emailAddresses.clear();
    }
}