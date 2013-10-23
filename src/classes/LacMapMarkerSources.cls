// This class is a namespace for all the Classes that will generate lists of MapMarkers for the different Lac Map Parameters
public with sharing class LacMapMarkerSources {
	
	// Returns a list of Lac Farmer Map Markers
	public with sharing class Farmers implements MapComponentController.IMapMarkerSource {
		public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
							
			String query = 'SELECT Id, Picture_Attachment_Id__c, ' + 
								'(SELECT Id, ' + // Select the Farmer record(s)
								'Name, ' +
								'Commercial_Crops__c, '+
								'Farm_Area__c, '+
								'Planted_Area__c, '+
								'Quarterly_Sales__c, '+
								'Quarterly_Income_from_Coffee__c, '+
								'Quarterly_Production__c, '+
								'Food_Security_Status__c, '+
								'PPI_Score__c, '+
								'Certification_Obtained__c '+
								' FROM Contact.LAC_Farmer_Details__r' +
								'), ' +
							 	'(SELECT Person__c.Id, ' +  // Select the Person record(s)
							 	'Person__c.GPS_Location_N__c, ' +
							 	'Person__c.GPS_Location_E__c '+ 
							 	' FROM Contact.People__r)' +
							' FROM Contact';
							
			List<String> queryWhereClause = new List<String>();
			
			// Only select contacts who have farmers
			queryWhereClause.add('Id in (SELECT Contact__c from Lac_Farmer_Details__c)');
			
			if(parameters.containsKey('quarter')) {
				String quarter = parameters.get('quarter');
				Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
				queryWhereClause.add('(createdDate <=: quarterLastDay)');
			}
			
			if(queryWhereClause.size() > 0) {
				query += ' WHERE ' + String.join(queryWhereClause, ' AND ');
			}
			
			// Prevent over 1,000 (collection sizes cannot be above 1000, so the mapMarkers list returned is limited to 1000)
			query += ' LIMIT 1000';
			
			Contact[] farmerContacts = Database.query(query);
			
			List<MapMarkers> mapMarkers = new List<MapMarkers>();
			if(farmerContacts.size() > 0) {
				for(Contact farmerContact: farmerContacts) {
					LAC_Farmer_Details__c farmer = null;
					Person__c person = null;
					
					if(farmerContact.LAC_Farmer_Details__r.size() > 0) {
						farmer = farmerContact.LAC_Farmer_Details__r[0];
					}
					
					if(farmerContact.People__r.size() > 0) {
						person = farmerContact.People__r[0];
					}
				
					mapMarkers.add(new LacMapMarkers.LacFarmerMarker(farmer, person));	
				}
			}

    		return mapMarkers;	
		}
	}
	
	// Return a list of Searches Map Markers
	public with sharing class Searches implements MapComponentController.IMapMarkerSource {
		public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
			
			String query = 'SELECT Id, ' +
							'Submission_Latitude__c,' + 
							'Submission_Longitude__c, ' +
							'Handset_Submit_Time__c,' +
							'Interviewer__r.First_Name__c, ' +
							'Interviewer__r.Last_Name__c, ' +
							'Interviewer__r.Gender__c, ' +
							'Interviewee__r.First_Name__c, ' +
							'Interviewee__r.Last_Name__c, ' +
							'Interviewee__r.Gender__c, ' +
							'Query__c ' +
							'from Search_Log__c';
			
			List<String> queryWhereClause = new List<String>();
			queryWhereClause.add(' Interviewer__r.Country__r.Name = \'Colombia\'');
			
			if(parameters.containsKey('quarter')) {
				String quarter = parameters.get('quarter');
				Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
				queryWhereClause.add('(createdDate <=: quarterLastDay)');
			}
			
			if(queryWhereClause.size() > 0) {
				query += ' WHERE ' + String.join(queryWhereClause, ' AND ');
			}
			
			// Prevent over 1,000 (collection sizes cannot be above 1000, so the mapMarkers list returned is limited to 1000)
			query += ' LIMIT 1000';
			
			Search_Log__c[] searches = Database.query(query);
			
			List<MapMarkers> mapMarkers = new List<MapMarkers>();
			for (Search_Log__c searchLog : searches) {
    			mapMarkers.add(new LacMapMarkers.LacSearchMarker(searchLog));
			}
    		return mapMarkers;	
		}
	}
	
	// Return a list of Lac Ckw Map Markers
	public with sharing class CKWs implements MapComponentController.IMapMarkerSource {
		public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
			
			String query = 'SELECT Id, Name, ' +
							'Person__r.GPS_Location_E__c,' + 
							'Person__r.GPS_Location_N__c ' +
							'from CKW__c';
			
			List<String> queryWhereClause = new List<String>();
			queryWhereClause.add(' Person__r.Country__r.Name = \'Colombia\'');
			
			if(parameters.containsKey('quarter')) {
				String quarter = parameters.get('quarter');
				Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
				queryWhereClause.add('(createdDate <=: quarterLastDay)');
			}
			
			if(queryWhereClause.size() > 0) {
				query += ' WHERE ' + String.join(queryWhereClause, ' AND ');
			}
			
			// Prevent over 1,000 (collection sizes cannot be above 1000, so the mapMarkers list returned is limited to 1000)
			query += ' LIMIT 1000';
			
			CKW__c[] ckws = Database.query(query);
			
			List<MapMarkers> mapMarkers = new List<MapMarkers>();
			for (CKW__c ckw : ckws) {
    			mapMarkers.add(new LacMapMarkers.LacCkwMarker(ckw));
			}
    		return mapMarkers;	
		}
	}
	
	// Return a summary of recent map markers for the initial overview 
	public with sharing class AllPeople implements MapComponentController.IMapMarkerSource {
		public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
			List<MapMarkers> mapMarkers = new List<MapMarkers>();
			
			LacMapMarkerSources.Farmers farmers = new LacMapMarkerSources.Farmers();
			mapMarkers.addAll(farmers.loadMapMarkers(parameters));
			
			LacMapMarkerSources.CKWs ckws = new LacMapMarkerSources.CKWs();
			List<MapMarkers> ckwMapMarkers = ckws.loadMapMarkers(parameters);
			Integer j = 0;
			for(Integer i = mapMarkers.size(); i < 1000; i++) {
				if (j < ckwMapMarkers.size())
					mapMarkers.add(ckwMapMarkers.get(j++));
				else
					break;
			}
			
			
			
			LacMapMarkerSources.Searches searches = new LacMapMarkerSources.Searches();
			List<MapMarkers> searchMarkers = searches.loadMapMarkers(parameters);
			j = 0;
			for(Integer i = mapMarkers.size(); i < 1000; i++) {
				if (j < searchMarkers.size())
					mapMarkers.add(searchMarkers.get(j++));
				else 
					break;
			}
			
    		return mapMarkers;	
		}
	}
	
	static TestMethod void testAll() {
		LacMapMarkerSources.Farmers farmers = new LacMapMarkerSources.Farmers();
		farmers.loadMapMarkers(new Map<String, String>());
		
		LacMapMarkerSources.CKWs ckws = new LacMapMarkerSources.CKWs();
		ckws.loadMapMarkers(new Map<String, String>());
		
		LacMapMarkerSources.AllPeople allPeople = new LacMapMarkerSources.AllPeople();
		allPeople.loadMapMarkers(new Map<String, String>());
	}
}