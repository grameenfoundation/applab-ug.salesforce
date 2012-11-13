global class ScheduledTdrWeeklyEmail implements Schedulable {

    global void execute(SchedulableContext sc) {

        Map<String, List<String>> addresses = new Map<String, List<String>>();


        // Add the dates for yesterday
        Date startDate = Date.today().addDays(-8);

        // Send the emails to the national level
        List<String> emailAddresses = new List<String>();
        emailAddresses.add('opetoo@mtn.co.ug');
        emailAddresses.add('harunas@mtn.co.ug');
        emailAddresses.add('kobaa@mtn.co.ug');
        emailAddresses.add('asiimwi@mtn.co.ug');
        emailAddresses.add('nimusid@mtn.co.ug');

        addresses.put('all', emailAddresses);
        // Send to Central region
        List<String> centralEmails= new List<String>();
        centralEmails.add('kiwagin@mtn.co.ug');
        addresses.put('Central', centralEmails);

        // Send to East region
        List<String> eastEmails= new List<String>();
        eastEmails.add('gyagene@mtn.co.ug');
        addresses.put('Eastern', eastEmails);

        // Send to West region
        List<String> westEmails = new List<String>();
        westEmails.add('ndobolj@mtn.co.ug');
        addresses.put('Western', westEmails);

        // Send to South West region
        List<String> southWestEmails= new List<String>();
        southWestEmails.add('mutakar@mtn.co.ug');
        addresses.put('South Western', southWestEmails);

        // Send to North region
        List<String> northEmails = new List<String>();
        northEmails.add('ogwangp@mtn.co.ug');
        addresses.put('Northern', northEmails);

        // Send email to West Nile region
        List<String> westNileEmails = new List<String>();
        westNileEmails.add('kibirae@mtn.co.ug');
        addresses.put('West Nile', westNileEmails);

		List<String> personIds = new List<String>();
		Person__c[] people = 
		    [SELECT 
		        Id 
		    FROM 
		        Person__c 
		    WHERE 
		        Type__c = 'TDR' 
		      AND 
		        ID IN 
		        (SELECT 
		             Person__c 
		         FROM 
		             TDR__c )];
                       
        for (Person__c person : people) {
            personIds.add(person.Id);
        }
        TdrHelpers.sendWeeklyEmails(addresses, personIds, startDate);
    }
}