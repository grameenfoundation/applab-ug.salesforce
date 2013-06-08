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
	    	String profile = '<div style="width: 304px;">';
	    	
	    	//profile image
	    	String imageUrl = '#';
	    	if (this.farmer.Contact__r.Picture_Attachment_Id__c != null) {
	    		imageUrl = '/servlet/servlet.FileDownload?file=' + this.farmer.Contact__r.Picture_Attachment_Id__c;
	    	}
	    	profile += '<div id="pImage" style="width: 100px height: 100px; float: left;">';
	    	profile += '<img src="'+ imageUrl +'" width="100px" height="100px"/>';
	    	profile += '</div>';
	    	
	    	//profile details
	    	profile += '<div id="pDetails" style="width: 200px; height: 100px; float: right;">';
	    	profile += '<div>Type: Farmer</div>';
	    	
	    	PageReference ref = new PageReference('/'+this.farmer.Id);
	    	profile += '<div><a href="' + ref.getUrl() + '">Name: ' + this.farmer.Person__r.First_Name__c + 
	    				  ' ' + this.farmer.Person__r.Last_Name__c + '</a></div>';
	    	
	    	if (this.farmer.Person__r.Gender__c != null) {
	    		profile += '<div>Gender: ' + this.farmer.Person__r.Gender__c + '</div>';
	    	}
	    	
	    	if (this.farmer.Person__r.Age__c != null) {
	    		profile += '<div>Age: '+ this.farmer.Person__r.Age__c +'</div>';
	    	}
	    	
	    	profile += '</div>';
	    	
	    	//certification crops
	    	String headerStyle = 'height: 20px; background-color: #E5E5E5; color: #FFFFF; font-weight:bold';
	    	profile += '<div style="clear:both; height: 100px; padding-top: 3px; ">';
	    	profile += '<div style="' + headerStyle + '">Certification Crops</div>';
	    	profile += '</div>';
	    	
	    	//other section
	    	profile += '<div>';
	    	profile += '<div style="' + headerStyle + '">Others</div>';
	    	profile += '<div>HA Under Production: '+ getHectaresUnderProduction() +'</div>';
	    	profile += '<div>Certification Status: ?</div>';
	    	profile += '<div>Total Queries Asked: '+ getTotalQueriesAsked() +'</div>';
	    	profile += '<div>SMS Messages Received: ' + getSmsMessagesReceived() + '</div>';
	    	profile += '<div>Surveys Completed: ?</div>';
	    	profile += '<div>Sales for QTR: '+ getSalesForQtr() +'</div>';
	    	profile += '<div>Kilos Produced for QTR: ' + getKilosProducedForQtr() + '</div>';
	    	profile += '<div>PPI Povery Likelyhood: ' + getPPILikelyhood() + '</div>';
	    	profile += '<div>Food Security Status: ?</div>';
	    	profile += '</div>';
	    	
	    	profile += '</div>';

	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	    
	    private Decimal getPPILikelyhood() {
	    	Decimal val = this.farmer.Person__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c;
	    	if(val == null)
	    		return 0.0;
	    		
	    	return val;
	    }
	    
	    private Decimal getSalesForQtr() {
	    	//TODO sales for quarter
	    	return 0.0;
	    }
	    
	    private Decimal getKilosProducedForQtr() {
	    	//TODO kilo produced for qtr
	    	return 0.0;
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
	        this.setDefaultColour('0000FF'); // Blue
	    }
	    
	    public override String getMarkerInfoContentString() {
	    	String profile = '<div style="width: 304px;">';
	    	
	    	//profile image
	    	String imageUrl = '#';
	    	if (this.ckw.Person__r.Contact__r.Picture_Attachment_Id__c != null) {
				imageUrl = '/servlet/servlet.FileDownload?file=' + this.ckw.Person__r.Contact__r.Picture_Attachment_Id__c;
		    	profile += '<div id="pImage" style="width: 100px height: 100px; float: left;">';
		    	profile += '<img src="'+ imageUrl +'" width="100px" height="100px"/>';
		    	profile += '</div>';
	    	}
	    	
	    	//profile details
	    	profile += '<div id="pDetails" style="width: 200px; height: 100px; float: right;">';
	    	profile += '<div>Type: CKW</div>';
	    	
	    	PageReference ref = new PageReference('/'+this.ckw.Id);
	    	profile += '<div><a href="' + ref.getUrl() + '">Name: ' + this.ckw.Person__r.First_Name__c + 
	    				  ' ' + this.ckw.Person__r.Last_Name__c + '</a></div>';
	    	
	    	if (this.ckw.Person__r.Gender__c != null) {
	    		profile += '<div>Gender: ' + this.ckw.Person__r.Gender__c + '</div>';
	    	}
	    	
	    	if (this.ckw.Person__r.Age__c != null) {
	    		profile += '<div>Age: '+ this.ckw.Person__r.Age__c +'</div>';
	    	}

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
	    	profile += '<a href="' + ref.getUrl() + '">Go to Details</a>';
	    	return profile;
	    }
	    
	    public override String getLocation() {
	    	return '';
	    }
	}
}