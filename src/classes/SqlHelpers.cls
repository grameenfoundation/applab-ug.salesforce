public with sharing class SqlHelpers {

	public static String formatDate(date d) {
		return d.year() + '-' + d.month() + '-' + d.day();	
	}

	public static String postServletRequest(String serverUrl, String servletDirectory, String requestBody, String contentType) {        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(serverUrl + servletDirectory);
        request.setHeader('content-type', contentType);
        request.setBody(requestBody);

        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            System.debug('REQUEST: ' + request.toString());
            System.debug('RESPONSE: ' + response.toString());
            System.debug('STATUS: ' + response.getStatus());
            System.debug('STATUS CODE: ' + response.getStatusCode());
            System.debug('RESPONSE BODY: ' + response.getBody());
            
            return response.getBody();  
         } catch(System.CalloutException e) {
            return e.getMessage();
         }                  
    }	
	
	/**
	* Default Content-Type to text/xml
	*/
	public static String postServletRequest(String serverUrl, String servletDirectory, String requestBody) {
		return postServletRequest(serverUrl, servletDirectory, requestBody, 'text/xml');
	}
	
	static testMethod void testFormatDate() {
		date d = Date.valueOf('2010-08-05');
		String formattedDate = formatDate(d); 
		System.assert(formattedDate == '2010-8-5');
	}

}