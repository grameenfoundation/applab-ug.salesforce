/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  EdnetUg SMS Gateway implementation
 *  Its test methods are in the SendSmsTest class 
 **/
public class SendSMSViaEdnetUg implements SendViaSMSGateway {
    
    private SMS_Gateway_Settings__c setting;
    private String senderName = 'Grameen';    	
	private Map<Integer, String> RESPONSE_MAP;
	private String MESSAGE_XML_RECIPIENT_FORMAT = '<gsm messageId="{0}">{1}</gsm>';
	private String MESSAGE_XML_REQUEST_FORMAT = 
		'<SMS>'									+
			'<authentification>'				+
				'<username>{0}</username>'		+
				'<password>{1}</password>'		+
			'</authentification>'				+
			'<message>'							+
				'<sender>{2}</sender>'			+
				'<text>{3}</text>'				+
				'<pushurl>{4}</pushurl>'		+
				'<nopush>0</nopush>'			+
			'</message>'						+
			'<recipients>'						+
				'{5}'							+
			'</recipients>'						+
		'</SMS>';	
	
	public SendSMSViaEdnetUg() {		
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
        // Loop through the messages
        for (Message message : inputMessages) {
       		HttpRequest request = buildRequest(createBody(new List<Message>{ message }, true), true);
            // If this is not a test then send the call out
            if (Test.isRunningTest()) {
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
            else {
                HttpResponse response = sendRequest(request);
                result = response.getStatusCode() == 200 ? processResponse(response.getBodyDocument()) : '';
                messagesSent = response.getStatusCode() == 200 ? inputMessages : new List<Message>{};
            }       		
        }
        System.debug(result);
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
            if (recipient.countryDialingCode == null) {
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
    	System.debug(results);
    	Integer status = Integer.valueOf(results.split(',')[0].split('=')[1]); 
    	if(!String.isEmpty(results) && messagesSent != null && messagesSent.size() > 0) {
    		for (SendSMSHelpers.Recipient recipient : messagesSent[0].recipients.values()) {
    			resultMap.put(
    				recipient.personId + 
    				'_splitter_' + 
    				EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(messagesSent[0].body))), 
    				status > 0 ? true : false
    			);
    		}
    	}
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
	
	private void notify(String status) {
		
		if(status.startsWith('-')) {			
            // Send mail to info services. This implies that the reponse is below 0 hence messages were not sent
            String[] toAddress = new String[]{};
            toAddress.add('InformationServices@grameenfoundation.org');
            toAddress.add('uganda_tech@grameenfoundation.org');
            String subject = 'Could not send SMSs ';
            String message = 'System failed to send messages. Reason : ' + RESPONSE_MAP.get(Integer.valueOf(status));
            Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[] { EmailHelpers.createEmail(toAddress, subject, message) };
            EmailHelpers.sendEmails(mail);
		}
	}
}