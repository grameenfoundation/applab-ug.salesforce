/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  EdnetUg SMS Gateway implementation
 *  Its test methods are in the SendSmsTest class 
 **/
global class SendSMSViaEdnetUg implements SendViaSMSGateway {
    
    global SMS_Gateway_Settings__c setting;
    global String senderName = 'Grameen';    	
	global Map<Integer, String> RESPONSE_MAP;
	global String MESSAGE_XML_RECIPIENT_FORMAT = '<gsm messageId="{0}">{1}</gsm>';
	global String MESSAGE_XML_REQUEST_FORMAT = 
		'<SMS>'									+
			'<authentification>'				+
				'<username>{0}</username>'		+
				'<password>{1}</password>'		+
			'</authentification>'				+
			'<message>'							+
				'<type>LongSMS</type>'			+
				'<sender>{2}</sender>'			+
				'<text>{3}</text>'				+
				'<pushurl>{4}</pushurl>'		+
				'<nopush>0</nopush>'			+
			'</message>'						+
			'<recipients>'						+
				'{5}'							+
			'</recipients>'						+
		'</SMS>';	
	
	global SendSMSViaEdnetUg() {		
        setting = SMS_Gateway_Settings__c.getInstance('EdnetUg');
		RESPONSE_MAP  = new Map<Integer, String>();
		RESPONSE_MAP.put(-1, 'Invalid username and/or password');
		RESPONSE_MAP.put(-2, 'Incorrect XML format');
		RESPONSE_MAP.put(-3, 'Not enough credits in user account');
		RESPONSE_MAP.put(-4, 'No good recipients');
		RESPONSE_MAP.put(-5, 'Error in processing your request');
	}
	
	public List<Message> messagesSent{ get; set; }

    // Send the messages via the gateway
    public String execute(List<Message> inputMessages) {
    	
    	String responseBody = '';
    	String result = '';
        messagesSent = inputMessages;
        // Loop through the messages
        for (Message message : inputMessages) {
        	if(message.groupId != null && message.groupId != '') {
        		//message sending for groups is batched
        		Database.executeBatch(new SendSMSBatches(message, '256'), 980); 
        	}
        	else {
	       		//HttpRequest request = buildRequest(createBody(new List<Message>{ message }, true), true);
	        	//insertMessages();
	            // If this is not a test then send the call out
	            /*if (Test.isRunningTest()) {
	                responseBody = 
	                	'<?xml version="1.0" encoding="UTF-8"?>' 		+
	                    '<RESPONSE>' 									+
	                        '<status>-2</status>' 						+
	                        '<credits>92052</credits>' 					+
	                    '</RESPONSE>';
	            	Dom.Document doc = new Dom.Document();
	            	doc.load(responseBody);
					result = processResponse(doc);
	            }
	            else {*/
	            	sendRequest(createBody(new List<Message>{ message }, true), setting.Bulk_End_Point__c, JSON.serialize(message));
	                //HttpResponse response = sendRequest(request);
	                //result = response.getStatusCode() == 200 ? processResponse(response.getBodyDocument()) : '';
	            /*}*/   
        	}    		
        }
        System.debug(LoggingLevel.INFO, result);
        return result;
    }

    // Create the body for the message
    public String createBody(List<Message> inputMessages, Boolean single) {
    	
        if (inputMessages.size() > 1) {
            throw new SendSMSHelpers.SendMessageException('Can only send one message through EdnetUg at once');
        }
        
    	String requestBody = MESSAGE_XML_REQUEST_FORMAT;
    	String recipients = '';
        for (SendSMSHelpers.Recipient recipient : inputMessages[0].recipients.values()) {
            if (recipient.countryDialingCode == null || recipient.phoneNumber == null) {
                continue;
            }
            if (recipient.phoneNumber.startsWith('0')) {
                recipient.phoneNumber = recipient.phoneNumber.substring(1);
            }
        	recipients += String.format(MESSAGE_XML_RECIPIENT_FORMAT, new String[]{ recipient.personId, String.valueOf(recipient.countryDialingCode) + recipient.phoneNumber });
        }
        return String.format(requestBody, new String[]{ setting.Username__c, setting.Password__c, senderName, inputMessages[0].body, '', recipients });
    }

    // Create the request to send to the gateway
    public HttpRequest buildRequest(String body, Boolean single) {
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setBodyAsBlob(Blob.valueOf('XML=' + EncodingUtil.urlEncode(body, 'UTF-8')));
        request.setHeader('Content-Type', 'application/xml');
        //request.setHeader('Accept:', '*/*');
		//request.setRequestProperty('Content-Encoding', 'UTF-8');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setEndpoint(setting.Bulk_End_Point__c);
        return request;
    }

    // Send the request to the gateway
    public HttpResponse sendRequest(HttpRequest request) {    	
        // Send the request
        return new Http().send(request);
    }

    /**
     * Parse the response from the Gateway.
     *
     * @param results - This should always be the output from execute
     * @param resultMap - Map that is used to pass back the success of each message
     *                      Key = <Person__c.Id>_splitter_<messageHash>
     *
     * @return - The populated result map
     */
    public Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap) {
    	// If the response code "> 0" then messages have been sent and. Here we can only know
    	// the count of messages sent and not the status of each one-by-one. 
    	return resultMap;
    }

	/**
	 * Processes the reponse XML picking out response status and the credits remaining
	 *
	 * @param doc - xml response
	 * 
	 * @return - Comma separated status and credits in the format status=100,credits=2000
	 */
	private String processResponse(Dom.Document doc) {
		
		String response = '';
        Dom.XMLNode res = doc.getRootElement();//RESPONSE
        
        String status = res.getChildElement('status', null).getText();
        String credits = res.getChildElement('credits', null).getText();
        notify(status);
        return 'status=' + status + ',credits=' + credits;
	}
	
	public static void notify(String message) {			
        // Send mail to info services. This implies that the reponse is below 0 hence messages were not sent
        String[] toAddress = new String[]{};
        //toAddress.add('InformationServices@grameenfoundation.org');
        //toAddress.add('uganda_tech@grameenfoundation.org');
        toAddress.add('jlhughabwe@grameenfoundation.org');
        toAddress.add('dmugume@grameenfoundation.org');
        String subject = 'Could not send SMS ';
        Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[] { EmailHelpers.createEmail(toAddress, subject, message) };
        EmailHelpers.sendEmails(mail);
	}

	/**
	 * To make a callout and perform DML in one transaction, we have to do so only in a @future method
	 * This comes at a disadvantage of rendering the callback method unusable
	 *
	 * @param xml 		- request body
	 * @param endpoint 	- gateway endpoint
	 * @param JSON 		- the Message class serialised to JSON since @future methods only take pirimitives
	 * 
	 */	
	@Future(callout=true)
	public static void sendRequest(String body, String endpoint, String datum) {
		
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setBodyAsBlob(Blob.valueOf('XML=' + EncodingUtil.urlEncode(body, 'UTF-8')));
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setEndpoint(endpoint);
        System.debug(LoggingLevel.INFO, body);
        
        HttpResponse resp = new Http().send(request);

		Map<Integer, String> RESPONSE_MAP  = new Map<Integer, String>();
		RESPONSE_MAP.put(-1, 'Invalid username and/or password');
		RESPONSE_MAP.put(-2, 'Incorrect XML format');
		RESPONSE_MAP.put(-3, 'Not enough credits in user account');
		RESPONSE_MAP.put(-4, 'No good recipients');
		RESPONSE_MAP.put(-5, 'Error in processing your request');
		String status = '';
		if(resp != null && resp.getStatusCode() == 200) {
			
			String response = '';
	        Dom.XMLNode res = resp.getBodyDocument().getRootElement();//RESPONSE
	        
	        status = res.getChildElement('status', null).getText();
	        String credits = res.getChildElement('credits', null).getText();
	        String result = 'status=' + status + ',credits=' + credits;
        	System.debug(LoggingLevel.INFO, result);
	        if(!status.contains('-')) {
				Message messagesSent = (Message)JSON.deserialize(datum, Message.class);
				List<Message__c> messages = new List<Message__c>();
				for (SendSMSHelpers.Recipient recipient : messagesSent.recipients.values()) {
					Message__c mesge = new Message__c();
					mesge.Recipient__c = recipient.personId;
					mesge.Body__c = messagesSent.body;
					mesge.Subject__c = messagesSent.subject;
					mesge.Sent_Time__c = Datetime.now();
					mesge.Expiration_Time__c = messagesSent.expirationTime;
					mesge.Category__c = messagesSent.catgory;
					mesge.From__c = messagesSent.senderId;
					mesge.OwnerId = messagesSent.senderId;
					mesge.Type__c = 'SMS';
					messages.add(mesge);
				}
				insert messages;
        		System.debug(LoggingLevel.INFO, '*** Message Logs Created ***');
	        }
	        else {
	        	notify('System failed to send messages. Reason : ' + RESPONSE_MAP.get(Integer.valueOf(status)));
	        }
		}
		else {
            System.debug(LoggingLevel.ERROR, Label.BULK_MESSAGE_PAGE_FAILED_QUEUE_ADD);     			
		}
	}
}