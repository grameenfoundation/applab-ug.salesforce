/**
 *	For UGANDA SMSs
 *  This class attempts to resolve the limits you meet when sending a message to a group that
 *  consists of too many people - to be more specific, more than 1000 members 
 *
 */
global class SendSMSBatches implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
		
	Message message;
	String countryCode;
	String successMessage;
	String className;
    String pulse = 'PULSE';
    SendSMSViaEdnetUg sender;
	
	global SendSMSBatches(Message message, String countryCode) {
		this.successMessage = '';
		this.message = message;
		this.countryCode = countryCode;
        this.sender = new SendSMSViaEdnetUg();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(
            'SELECT '												+
                'Person__c, '										+
                'Person__r.Last_Name__c, '							+
                'Person__r.Middle_Name__c, '						+
                'Person__r.First_Name__c, '							+
                'Person__r.Country__r.ISO_Standard_Code__c, '		+
                'Person__r.Mobile_Number__c '						+
            'FROM '													+
                'Person_Group_Association__c '						+
            'WHERE '												+
                'Group__c = \'' + this.message.groupId + '\''
    	);
	}
	
	global void execute(Database.BatchableContext BC, List<Person_Group_Association__c> people) {
        
        List<Message__c> messages = new List<Message__c>();
    	String requestBody = sender.MESSAGE_XML_REQUEST_FORMAT;
    	String recipients = '';
        for (Person_Group_Association__c recipient : people) {
        	String pnumber = recipient.Person__r.Mobile_Number__c;
            if (pnumber == null || pnumber == '' || pnumber == 'null') {
                continue;
            }
            if (pnumber.startsWith('0')) {
                pnumber = pnumber.substring(1);
            }
        	recipients += String.format(sender.MESSAGE_XML_RECIPIENT_FORMAT, new String[]{ recipient.Person__c, countryCode + pnumber });
        	
        	
			Message__c mesge = new Message__c();
			mesge.Recipient__c = recipient.Person__c;
			mesge.Body__c = message.body;
			mesge.Subject__c = message.subject;
			mesge.Sent_Time__c = Datetime.now();
			mesge.Expiration_Time__c = message.expirationTime;
			mesge.Category__c = message.catgory;
			mesge.From__c = message.senderId;
			mesge.OwnerId = message.senderId;
			mesge.Type__c = 'SMS';
			messages.add(mesge);
        }
        
        requestBody = String.format(requestBody, new String[]{ sender.setting.Username__c, sender.setting.Password__c, sender.senderName, message.body, '', recipients });
        
		HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setBodyAsBlob(Blob.valueOf('XML=' + EncodingUtil.urlEncode(requestBody, 'UTF-8')));
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Content-Length', String.valueOf(EncodingUtil.urlEncode(requestBody, 'UTF-8').length()));
        request.setEndpoint(sender.setting.Bulk_End_Point__c);
        System.debug(LoggingLevel.INFO, requestBody);
        
        HttpResponse resp = new Http().send(request);

		if(resp.getStatusCode() == 200) {
			
			String response = '';
	        Dom.XMLNode res = resp.getBodyDocument().getRootElement();
	        
	        String status = res.getChildElement('status', null).getText();
	        String credits = res.getChildElement('credits', null).getText();
	        String result = 'status=' + status + ',credits=' + credits;
        	System.debug(LoggingLevel.INFO, result);
	        if(!status.contains('-')) {
				insert messages;
        		System.debug(LoggingLevel.INFO, '*** Message Logs Created ***');
	        }
	        else {
	        	successMessage += '\N System failed to send ' + messages.size() + ' messages in this batch. Reason : ' + sender.RESPONSE_MAP.get(Integer.valueOf(status));
	        }
		}
		else {
	        successMessage += '\N System failed to send ' + messages.size() + ' messages in this batch. Reason : Failed request with status code ' + resp.getStatusCode();
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		if(successMessage.length() > 0) {
			SendSMSViaEdnetUg.notify(successMessage);
		}
	}
}