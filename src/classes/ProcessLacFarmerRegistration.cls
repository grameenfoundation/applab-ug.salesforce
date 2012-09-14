@RestResource(urlMapping='/ProcessLacFarmerRegistration/*')
global with sharing class ProcessLacFarmerRegistration {
	@HttpPost
	global static void processNewRegistration() {
		// get parameter data
		String requestBody = RestContext.request.requestBody.toString();

		// DEBUG:
		System.debug('Request body: ' + requestBody);

		// Parse the request body as xml and extract the submission id
		String submissionId = null;
		String notificationId = null;
		Boolean foundNotificationIdNode = false;
		Boolean foundSubmissionIdNode = false;
		XmlStreamReader reader = new XmlStreamReader(requestBody);
		while(reader.hasNext()) {
			// Get the notification Id (so that we only process it once)
			//Format <Id>...</Id>
			if(reader.getLocalName() == 'Id' && reader.getPrefix() != 'sf') {
				foundNotificationIdNode = true;
			}
			
			// Once foundNotificationIdNode is true, the next event will the characters for the Id
			if(reader.isCharacters() && foundNotificationIdNode) {
				notificationId = reader.getText();
				foundNotificationIdNode = false;	
			}
			
			// Format is <sf:Id>....</sf:Id>
			if (reader.getLocalName() == 'Id' && reader.getPrefix() == 'sf') {
				foundSubmissionIdNode = true;
			}
			
			// Once foundSubmissionIdNode is true, the next event will be the characters for the Id
			if(reader.isCharacters() && foundSubmissionIdNode) {
				submissionId = reader.getText();
				foundSubmissionIdNode = false;
				break; // This is the last thing we want
			}
			reader.next();
		} 
		
		if(submissionId != null) {
			// DEBUG:
			System.debug('Submission Id: ' + submissionId);
			
			createRegistrationObjects(notificationId, submissionId);
		}
	}

	@HttpGet
	global static void processNewRegistrationGet() {
		processNewRegistration();
	}
	
	static void createRegistrationObjects(String notificationId, String submissionId) {
		// We check whether we've processed this message before
		Processed_Outbound_Message__c message = [Select Id from Processed_Outbound_Message__c where Notification_Id__c =: notificationId limit 1];
		
		if(message != null) {
			// This notification has been processed, so we just return
			return;
		} else {
			message = new Processed_Outbound_Message__c();
			message.Notification_Id__c = notificationId;
			insert message;
		}
		
		// Load all the answers for this submission
		gfsurveys__Answer__c[] answers = [Select gfsurveys__Value__c, gfsurveys__TextValue__c, gfsurveys__NumericValue__c, 
											gfsurveys__DateTimeValue__c, gfsurveys__DateValue__c, gfsurveys__Question__r.Name
											from gfsurveys__Answer__c where gfsurveys__Submission__c =: submissionId];
											
		// Index them by the question name
		Map<String, gfsurveys__Answer__c> answersMap = new Map<String, gfsurveys__Answer__c>();
		
		for (gfsurveys__Answer__c answer : answers) {
			String key = answer.gfsurveys__Question__r.Name;
			
			// Append a numeric value in case there are more than one answer with this binding (e.g. a loop question)
			Integer instanceNumber = 0;
			while(1 == 1) {
				if(answersMap.containsKey(key + '_' + instanceNumber)) {
					instanceNumber++;
				} else {
					//answerMap.put(key + '_' + instanceNumber, answer);
					break;
				}
			}
		}
		
		// Send to the registration post processor for processing
		
	}
}