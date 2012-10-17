global class ScheduledAssetTrackerDailyEmail implements Schedulable {

    global void execute(SchedulableContext sc) {
    	//pick all equipment returns from yesterday
    	Equipment_Return__c[] equipmentReturns = [Select Id, Equipment_Type__c, 
    	Field_Officer__r.District_Name__c, Field_Officer__r.First_Name__c, Handset__c, Asset__c From Equipment_Return__c 
    	where CreatedDate >=:date.today().addDays(-1) And Field_Officer__c !=: null];

    	List<String>emailAddresses = new List<String>();
    	//construct an email for each, send to Cecilia and Sadat
    	for (Equipment_Return__c equipmentReturn : equipmentReturns) {
    		emailAddresses.add('cmbawadde@grameenfoundation.org');
        	emailAddresses.add('sntume@grameenfoundation.org');
        	String subject = 'Asset from field';
        	String message = '';
        	if (equipmentReturn.Equipment_Type__c.equals('Phone')) {
        		Phone__c phone = [Select IMEI__c from Phone__c where Id =: equipmentReturn.Handset__c];
        	    message = 'Phone with IMEI ' + phone.IMEI__c + ' is supposed to be returned to the field, it is with '+ equipmentReturn.Field_Officer__r.First_Name__c
        	     + ' of ' + equipmentReturn.Field_Officer__r.District_Name__c;
        	}
        	else {
        		Asset__c asset = [Select Serial_Number__c From Asset__c where Id=: equipmentReturn.Asset__c];
        		message= 'Asset with serial number ' + asset.Serial_Number__c + ' is supposed to be returned to the field, it is with '+
        		equipmentReturn.Field_Officer__r.First_Name__c + ' of ' + equipmentReturn.Field_Officer__r.District_Name__c;
        	}
            Messaging.SingleEmailMessage email = EmailHelpers.createEmail(emailAddresses, subject, message);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            emails.add(email);
            EmailHelpers.sendEmails(emails);
    	}
    }
}