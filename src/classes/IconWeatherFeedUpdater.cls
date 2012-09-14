public with sharing class IconWeatherFeedUpdater {
/**
 *  Class updates ICON Weather Feed 
 */
	private String serverUrl;
	private List<Subcounty__c> subcountiesWithLocationIds;
	
	public IconWeatherFeedUpdater(){
		this.subcountiesWithLocationIds = new Subcounty__c[]{};
		initializeServerConstants();
		
	}
	
	private void initializeServerConstants() {
			Server_Configuration__c configuration = [SELECT Base_URL__c, Search_Path__c
				FROM Server_Configuration__c LIMIT 1];
			this.serverUrl = configuration.Base_URL__c + configuration.Search_Path__c;		
		}
		
	@Future(callout=true)
	public static void updateIconWeather(){
		 try {
			IconWeatherFeedUpdater iconWeatherFeedUpdater = new IconWeatherFeedUpdater();
			
			//get subcounties with locations ids
			iconWeatherFeedUpdater.getSubCounties();
		   	
		   	//make http post to update weather
		   	iconWeatherFeedUpdater.getIconWeather();
		   } 
		   catch (Exception e) {
					System.debug('An error occured');	   	
	            ErrorLog.writeLater('IconWeatherFeedUpdater', 'updateIconWeatherInfo', e.getMessage(), 1);
	        }       
	}
	
	/**
     *  Calls Servlet in back end to update weather
     */
	private void getIconWeather(){
		 	String requestBody = this.constructRequestXml(this.subcountiesWithLocationIds);	    
	      	String queryResult = SqlHelpers.postServletRequest(this.serverUrl, 'updateIconWeatherFeed', requestBody);
	}
	
	/**
	*Gets  Subcounties with location Ids
	*/
	private void getSubCounties() {
	        for(Subcounty__c [] allSubcounties : [SELECT Name,
	                                                Display_Name__c,
										        	Location_Id__c, 
										        	District__r.Name,
										        	District__r.Region__c	        	
										        FROM Subcounty__c 
										        WHERE Location_Id__c != null
										        ]){
	       
	       for (Subcounty__c subcounty : allSubcounties){
					subcountiesWithLocationIds.add(subcounty);
			}
	    }
	}
	    
	/**
     * Construct the Xml request for the post body of the Servlet request
     *
     * @param subcountiesWithLocationIds     - A List of the Subcounties
     *
     * @return - String representation of the xml for request
     */	
	private String constructRequestXml(List<Subcounty__c> subcountiesWithLocationIds) {
		
	        String requestBody = '<?xml version="1.0"?>' +
	             '<locations>';
	             
	          for(Subcounty__c subcounty : subcountiesWithLocationIds) {
	             	requestBody += '<location>'+
	             		'<location_id>'+subcounty.Location_Id__c+'</location_id>'+
		             	'<subcounty_name>'+subcounty.Display_Name__c+'</subcounty_name>'+
		             	'<region_name>'+subcounty.District__r.Region__c+'</region_name>'+
		             	'<district_name>'+subcounty.District__r.Name+'</district_name>'+
		              '</location>';
	             } 
	          requestBody = requestBody +  '</locations>';
	          System.debug(requestBody);
	        return requestBody;
	}
	
	static testMethod void testConstructRequestXml(){
		IconWeatherFeedUpdater iconWeatherUpdater = new IconWeatherFeedUpdater();  
		iconWeatherUpdater.getSubCounties();
		String xml = iconWeatherUpdater.constructRequestXml(iconWeatherUpdater.subcountiesWithLocationIds);
		System.debug(xml);
	} 
	    
	private String fakeIconLocationsQuery() {
        String query = '<?xml version="1.0" encoding="utf-8"?>' +
            '<locations>' +
                '<location><location_id>100229362</location_id><subcounty_name>Benet</subcounty_name><region_name>Eastern Uganda</region_name><district_name>Kapchorwa</district_name></location></location>' +
                '<location><location_id>100229362</location_id><subcounty_name>Benet</subcounty_name><region_name>Eastern Uganda</region_name><district_name>Masindi</district_name></location></location>' +
                '<location><location_id>100229362</location_id><subcounty_name>Benet</subcounty_name><region_name>Eastern Uganda</region_name><district_name>Gulu</district_name></location></location>' +
                '<location><location_id>100229362</location_id><subcounty_name>Benet</subcounty_name><region_name>Eastern Uganda</region_name><district_name>Mubende</district_name></location></location>' +
            '</locations>';
                
        return query;
    }
}