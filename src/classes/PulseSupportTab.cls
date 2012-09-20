/**
 * Set of helper functions used for displaying and processing the support tab
 * 
 */
public class PulseSupportTab {
    private static String startElements = '';
    private static final String endElements = '<p><input type=\'Submit\' value=\'' + Label.Send + '\' name=\'submitButton\' style=\'width:50%\'></p>'
                + '</form></body>';
    private static final String endHtmlElement = '</html>';

    private static String getHiddenHandsetControl(String imei) {
        return '<input type=\'hidden\' name=\'handsetId\' value=\'' + imei + '\'></input>';
    }
    
    private static String getHiddenLanguageControl() {
        return '<input type=\'hidden\' name=\'lang\' value=\'' + PulseController.language + '\'></input>';
    }
	
    public static void initializeStartElements(String baseSiteUrl) {
        if (startElements == '') {
           	startElements += '<html>';
            startElements += '<head>';

            startElements += '</head>';
            startElements += '<body>';
            startElements += '<form name=\'supportForm\' action=\'';
            
            String submissionUrl = baseSiteUrl + 'submitSupportTicket';
            startElements += submissionUrl;
            startElements += '\' method=\'POST\' onsubmit="if(document.getElementById(\'supportInput\').value == \'\') {alert(\'' + Label.Error_Invalid_Pulse_Support_Input + '\'); return false;}else{document.getElementById(\'submitButton\').disable; return true;}">';
        }
    }

    // Get the common form controls that are used in all support tabs
    private static String getFormControls(String imei) {
        String selectBox = '';
        Case caseObject = new Case();
        
        Map<String, Schema.SObjectField> fields = caseObject.getSObjectType().getDescribe().fields.getMap();
        
        if (fields != null) {
            for (String fieldName : fields.keySet()) {
                Schema.DescribeFieldResult field = fields.get(fieldName).getDescribe();
                if (field.getName().equalsIgnoreCase('type')) {
			        List<Schema.PicklistEntry> typePicklistValues = field.getPicklistValues();
			        if (typePicklistValues.size() > 0) {
			            selectBox += '<p><select name=\'supportType\' style=\'width:100%\'>';
			            for (Schema.PicklistEntry picklistEntry : typePicklistValues) {
			            	selectBox += '<option value=\'' +
			                            picklistEntry.getValue() +
			                            '\'>' + picklistEntry.getLabel() + '</option>';
			            }
			            selectBox += '</select></p>';
			        }
                }
            }
        }
        return selectBox + '<p><textarea id=\'supportInput\' rows=\'5\' style=\'width:100%\' name=\'supportText\'></textarea></p>'
                + getHiddenHandsetControl(imei) + getHiddenLanguageControl();
    }
	
    public static String getSupportFormHtml(String imei, String baseSiteUrl) {
        initializeStartElements(baseSiteUrl);
        return startElements + '<p>' + Label.Pulse_Support_Tab_Instructions + ':</p>'
                + getFormControls(imei) + endElements + PulseEmbeddedBrowserHelpers.getPageLoadCompleteString() +
                endHtmlElement;
    }
    
	public static String processSubmission(String imei, String caseType, String message, Person__c person, String baseSiteUrl) {
		Case supportCase = new Case();
        supportCase.reason = 'New Reason';
        if(null != caseType) {
            supportCase.type = caseType;
        } else {
            supportCase.type = 'Unknown';
        }
        
        supportCase.origin = 'CKW Pulse';
        supportCase.status = 'New';
        supportCase.description =  message;
        supportCase.Person__c = person.Id;
        supportCase.subject = Label.From + ' ' + person.Name;
        insert supportCase;
        
        if (supportCase.id != null) {
            // Finally, try to obtain the case number
            Case[] cases = [SELECT CaseNumber from case WHERE id=: supportCase.Id];
            if (cases.size() > 0) {
            	return PulseSupportTab.getSubmissionResponse(imei, cases[0].CaseNumber, false, baseSiteUrl);
            }
        }
        return PulseSupportTab.getSubmissionResponse(imei, Label.Error_Support_Request_Submission_Failed, true, baseSiteUrl);	
	}
	
    public static String getSubmissionResponse(String imei, String responseMessage, Boolean error, String baseSiteUrl) {
        initializeStartElements(baseSiteUrl);
        String responseString = startElements;
        if(error) {
            responseString += '<p><h3><font color="red">' + responseMessage + '.</font></h3></p>';
        } else {
            responseString += '<p><h3><font color="green">' + String.format(Label.Pulse_Support_Submission_Success, new String[] {responseMessage}) + '.</font></h3></p>';
        }
        return responseString + '<p>'+ Label.Pulse_Support_Tab_Instructions +':</p>'
                + getFormControls(imei) + endElements + PulseEmbeddedBrowserHelpers.getPageLoadCompleteString() +
                endHtmlElement;
    }
    
    static testMethod void testPulseSupportTab() {
    	initializeStartElements('URL');
    	getHiddenHandsetControl('1234567890');
    	getHiddenLanguageControl();
    	getFormControls('1234567890');
    	getSupportFormHtml('1234567890', 'URL');
    	processSubmission('123457890', null, 'test', new Person__c(), 'URL');
    }
}