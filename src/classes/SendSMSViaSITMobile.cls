/*
 * Sends messages through the SIT Mobile gateway
 */
public with sharing class SendSMSViaSITMobile implements SendViaSMSGateway {
    
    private static SITMobile_Gateway_Settings__c settings;
    private static String senderName = 'lac';
    
    public String execute(List<Message> inputMessages) {
        settings = SITMobile_Gateway_Settings__c.getInstance();
        
        String response ='';
        for(Message message : inputMessages) {
            HttpRequest request = buildRequest(message, settings); 
                        
            if(Test.isRunningTest()) {
                if(message.recipients.size() == 1) {
                    response = getTestSingleResponse();
                }else if(message.recipients.size() > 1) {
                    response = getTestBulkResponse();
                }
            }else {
                HttpResponse httpResponse = sendRequest(request);
                response += httpResponse.getBody();
            }              
        }
        
        System.debug(LoggingLevel.WARN, response);
        return response;
    }
    
    private String getTestBulkResponse() {
        return '<RESP CONC=\'false\'>'+
            '<SEQ=\'1\' MID=\'1720260\' STA=\'OK\'>'+
            '<SEQ=\'1\' MID=\'1720261\' STA=\'OK\'>'+
            '</RESP>';
    }
    
    private String getTestSingleResponse() {
        return '<RESP CONC=\'false\'><SEQ=\'1\' MID=\'1720260\' STA=\'OK\'></RESP>';
    }
    
    public String createBody(List<Message> inputMessages, Boolean single) {
        return null;
    }
    
    public HttpRequest buildRequest(String body, Boolean single) {
        return null;
    }
    
    private HttpRequest buildRequest(Message message, SITMobile_Gateway_Settings__c gSettings) {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //request.setHeader('Accept:', '*/*');
        request.setEndpoint(gSettings.End_Point__c);
        
        String login = EncodingUtil.urlEncode(gSettings.Login__c, 'UTF-8');
        String password  = EncodingUtil.urlEncode(gSettings.Password__c, 'UTF-8');
        String clientId = EncodingUtil.urlEncode(gSettings.ClientID__c, 'UTF-8');
        String accountId= EncodingUtil.urlEncode(gSettings.AccountID__c, 'UTF-8');
        String text = EncodingUtil.urlEncode(message.body, 'UTF-8');
        String destination = getDestinationString(message);
        String seq = '123567890';
        String source = EncodingUtil.urlEncode(gSettings.Source__c, 'UTF-8');
        
        String reqBody = 'login=' + login + '&password=' + password + 
        '&clientID='+clientId + '&accountID='+ accountId +'&destination='+ destination + '&text='+text +
        '&seq='+ seq + '&source='+source;
        
        request.setBody(reqBody);
        request.setHeader('Content-Length', String.valueOf(reqBody.length()));
        
        System.debug(LoggingLevel.DEBUG, request.getBody());        
        return request;
    }
    
    private String getDestinationString(Message message) {
        String sb = '';
        boolean first = true;
        for (SendSMSHelpers.Recipient recipient : message.recipients.values()) {
            if (first) {
                first = false;
            } else {
                sb += ',';
            }
            
            sb += recipient.phoneNumber;
        }
        
        return sb;
    }
    
    public HttpResponse sendRequest(HttpRequest request) {
        Http http = new Http();
        return http.send(request);
    }
    
    public Map<String, Boolean> callback(String result, Map<String,Boolean> resultMap) {
        if (resultMap == null) {
            resultMap = new Map<String, Boolean>();
        }
        return resultMap;
    }
    
}