global class MiniProfileWebService {
	webService static String getFarmerMiniProfile(String farmerId) {
		List<LAC_Farmer_Details__c> farmers = [SELECT Id, Person__c FROM LAC_Farmer_Details__c WHERE Id =: farmerId];
		if (!farmers.isEmpty()) {
			ApexPages.StandardController sc = new ApexPages.StandardController(farmers.get(0));
			LacFarmerDetailsController c = new LacFarmerDetailsController(sc);
			
			String profile = '';
			String spanStyle = 'width: 70px; font-weight: bold; display: inline-block; padding-right: 3px;';
	    	profile += '<div style="clear:both;">';
	    	profile += '<div><span style="'+ spanStyle +'">Searches</span><span>: '+ c.getSearchesNum() +'</span></div>';
	    	profile += '<div><span style="'+ spanStyle +'">Submissions</span><span>: '+ c.getSubmissionsNum() +'</span></div>';
	    	profile += '<div><span style="'+ spanStyle +'">Messages</span><span>: '+ c.getMessagesNum() +'</span></div>';
			profile += '</div>';
		
			return profile;		
		}
		
		return '';
	}
}