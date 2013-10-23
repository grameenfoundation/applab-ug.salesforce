// This class is a namespace for all Lac Related Map Markers
public with sharing class LacMapMarkers {
	
	// Lac Farmer Map Marker
	public with sharing class LacFarmerMarker extends MapMarkers {
		private Lac_Farmer_Details__c farmer; 
		 
		private String parentRegistered;
	    public String getParentRegistered() {
	        return this.parentRegistered;
	    }
	    
	    public void setParentRegistered(String value) {
	        this.parentRegistered = value;
	    }
	    
		public LacFarmerMarker(Lac_Farmer_Details__c farmer, Person__c person) {
	        this.farmer = farmer;
	        if(person != null) {
		        this.setLatitude(person.GPS_Location_N__c);
		        this.setLongitude(person.GPS_Location_E__c);
	        }
	        this.setMarkerColour('FF0000'); // Red
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
	    	PageReference ref = new PageReference('/apex/LacFarmerDetailMini?id='+this.farmer.Id);
	    	String profile = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="yes" seamless="seamless" style="overflow:hidden"></iframe>';
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	    
	    private Integer getTotalQueriesAsked() {
	    	//return [SELECT COUNT() FROM Search_Log__c WHERE Interviewee__c =: this.farmer.Person__c];
	    	return 0;
	    }
	    
	    private Integer getSmsMessagesReceived() {
	    	return 0;
	    	//return [SELECT COUNT() FROM Message__c WHERE Recipient__c =: this.farmer.Person__c];
	    }
	    
	    private Decimal getHectaresUnderProduction() {
	    	/*
	    	List<LAC_Farm__c> farms = [
	    		SELECT 
	    			Id, 
	    			Area__c,
	    			LAC_Farmer_Id_Temp__c 
	    		FROM 
	    			LAC_Farm__c 
	    		WHERE 
	    			LAC_Farmer_Id_Temp__c =: this.farmer.Id];
	    			
	    	if (!farms.isEmpty()) {
	    		return farms.get(0).Area__c;
	    	}*/
	    	
	    	return 0.0;
	    } 
	}
	
	// Lac Ckw Map Marker
	public with sharing class LacCkwMarker extends MapMarkers {
		private CKW__c ckw;
		 
		private String parentRegistered;
	    public String getParentRegistered() {
	        return this.parentRegistered;
	    }
	    
	    public void setParentRegistered(String value) {
	        this.parentRegistered = value;
	    }
	    
		public LacCkwMarker(CKW__c ckw) {
	        this.ckw = ckw;
	        this.setLatitude(ckw.Person__r.GPS_Location_N__c);
	        this.setLongitude(ckw.Person__r.GPS_Location_E__c);
	        this.setMarkerColour('0000FF'); // Blue
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	// Returning an iframe causes it to load on demand, when the marker is clicked instead of loading all content for all markers at once
	    	PageReference ref = new PageReference('/apex/CkwDetailMini?id='+this.ckw.Id);
	    	String profile = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	}
	
	// Lac Search Map Marker
	public with sharing class LacSearchMarker extends MapMarkers {
		private Search_Log__c searchLog;
		 
		private String parentRegistered;
	    public String getParentRegistered() {
	        return this.parentRegistered;
	    }
	    
	    public void setParentRegistered(String value) {
	        this.parentRegistered = value;
	    }
	    
		public LacSearchMarker(Search_Log__c searchLog) {
	        this.searchLog = searchLog;
	        this.setLatitude(String.valueOf(searchLog.Submission_Latitude__c));
	        this.setLongitude(String.valueOf(searchLog.Submission_Longitude__c));
	        this.setMarkerColour('00FF00'); // Green
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	String profile = 'Type: Search Query <br/>';
	    	profile += 'Date: ' + this.searchLog.Handset_Submit_Time__c + ' <br/>';
	    	profile += 'Interviewer: ' + this.searchLog.Interviewer__r.First_Name__c + ' ' + this.searchLog.Interviewer__r.Last_Name__c + '<br/>';
	    	profile += 'Interviewee: ' + this.searchLog.Interviewee__r.First_Name__c + ' ' + this.searchLog.Interviewee__r.Last_Name__c + '<br/>';
	    	profile += 'Query: ' + this.searchLog.Query__c + '<br/>';
	    	
	    	PageReference ref = new PageReference('/'+this.searchLog.Id);
	    	profile += '<a href="' + ref.getUrl() + '">Go to Details</a>';
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	}
}