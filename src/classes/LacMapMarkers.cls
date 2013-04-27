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
	    
		public LacFarmerMarker(Lac_Farmer_Details__c farmer) {
	        this.farmer = farmer;
	        this.setLatitude(farmer.Person__r.GPS_Location_N__c);
	        this.setLongitude(farmer.Person__r.GPS_Location_E__c);
	        this.setMarkerColour('FF0000'); // Red
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	String profile = 'Type: Farmer <br/>';
	    	profile += 'Id: ' + this.farmer.Name + '<br/>';
	    	profile += 'Name: ' + this.farmer.Person__r.First_Name__c + ' ' + this.farmer.Person__r.Last_Name__c + '<br/>';
	    	profile += (this.farmer.Person__r.Gender__c != NULL)?'Gender: ' + this.farmer.Person__r.Gender__c + '<br/>':'';
	    	profile += (this.farmer.Person__r.Age__c != NULL)?'Age: ' + this.farmer.Person__r.Age__c + '<br/>':'';
	    	
	    	PageReference ref = new PageReference('/'+this.farmer.Id);
	    	profile += '<a href=\'' + ref.getUrl() + '\'>Go to Profile</a>';
	    	
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
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
	        this.setDefaultColour('0000FF'); // Blue
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	String profile = 'Type: CKW <br/>';
	    	profile += 'Id: ' + this.ckw.Name + '<br/>';
	    	profile += 'Name: ' + this.ckw.Person__r.First_Name__c + ' ' + this.ckw.Person__r.Last_Name__c + '<br/>';
	    	profile += (this.ckw.Person__r.Gender__c != NULL)?'Gender: ' + this.ckw.Person__r.Gender__c + '<br/>':'';
	    	profile += (this.ckw.Person__r.Age__c != NULL)?'Age: ' + this.ckw.Person__r.Age__c + '<br/>':'';
	    	
	    	PageReference ref = new PageReference('/'+this.ckw.Id);
	    	profile += '<a href=\'' + ref.getUrl() + '\'>Go to Profile</a>';
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
	        this.setDefaultColour('00FF00'); // Green
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	String profile = 'Type: Search Query <br/>';
	    	profile += 'Date: ' + this.searchLog.Handset_Submit_Time__c + ' <br/>';
	    	profile += 'Interviewer: ' + this.searchLog.Interviewer__r.First_Name__c + ' ' + this.searchLog.Interviewer__r.Last_Name__c + '<br/>';
	    	profile += 'Interviewee: ' + this.searchLog.Interviewee__r.First_Name__c + ' ' + this.searchLog.Interviewee__r.Last_Name__c + '<br/>';
	    	profile += 'Query: ' + this.searchLog.Query__c + '<br/>';
	    	
	    	PageReference ref = new PageReference('/'+this.searchLog.Id);
	    	profile += '<a href=\'' + ref.getUrl() + '\'>Go to Details</a>';
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	}
}