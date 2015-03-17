public class PulseMessagesTab {
    private static String startElements;
    private static final String endElements = '</table></body>';
    private static final String endHtmlElement= '</html>';
    
    public static void initializeStartElements() {
        if (startElements == null) {
            startElements = '<html><head><style type="text/css">';
            startElements += 'td { border-width: 2px; border-style: solid; }';
            startElements += '</style></head><body><table style="width:100%">';
        }
    }  
    
    // get the HTML for one message
    private static String getMessageHtml(Message__c pulseMessage) {
    	String message = '';
    	message += '<tr><td><p>';
    	message += '<b>' + Label.Subject + ':</b>';
    	message += pulseMessage.Subject__c;
    	message += '<br/>';
    	message += '<b>' + Label.From + ':</b>'; 
    	message += pulseMessage.From__r.Name;
    	message += '<br/>';
    	message += '<b>' + Label.Sent + ':</b>'; 
    	message += pulseMessage.Sent_Time__c;
    	message += '<br/></p><p>';
    	message += pulseMessage.Body__c;
    	message += '</p></tr></td>';
    	return message;
    }

    public static String getMessageListHtml(String imei) {
        initializeStartElements();
        String messageList = '';
        messageList += startElements;

        Message__c[] messages = [select Subject__c, From__r.Name, Sent_Time__c,Body__c 
                        from Message__c where Recipient__r.Handset__r.IMEI__c =: imei 
                        and Expiration_Time__c >= YESTERDAY 
<<<<<<< HEAD
=======
                        and (Type__c = null OR Type__c = 'Pulse')
>>>>>>> origin/ci
                        order by Sent_Time__c Desc];
        
        if(messages.size() == 0) {
        	messageList += '<p>' + Label.No_Messages + '</p>';
        } else {
	        for(Message__c message : messages) {
	        	messageList += getMessageHtml(message);
	        }
        }
        
        messageList += endElements;
        messageList += PulseEmbeddedBrowserHelpers.getPageLoadCompleteString();
        messageList += endHtmlElement;
        return messageList;
    }
    
    static testMethod void testPulseMessagesTab() {
    	initializeStartElements();
    	getMessageHtml(new Message__c());
    	getMessageListHtml('1234567890');
    }
}