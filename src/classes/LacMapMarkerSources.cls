// This class is a namespace for all the Classes that will generate lists of MapMarkers for the different Lac Map Parameters
public with sharing class LacMapMarkerSources {
  
  // Returns a list of Lac Farmer Map Markers
  public with sharing class Farmers implements MapComponentController.IMapMarkerSource {
    public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
      String query = 'SELECT Id, ' +
              'Person__r.GPS_Location_E__c,' + 
              'Person__r.GPS_Location_N__c, ' +
              'Person__r.First_Name__c, ' +
              'Person__r.Last_Name__c, ' +
              'Person__r.Gender__c ' +
              'from Lac_Farmer_Details__c';
      
      List<String> queryWhereClause = new List<String>();
      if(parameters.containsKey('quarter')) {
        String quarter = parameters.get('quarter');
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
        queryWhereClause.add('(createdDate <=: quarterLastDay)');
      }
      
      if(queryWhereClause.size() > 0) {
        query += ' WHERE ' + String.join(queryWhereClause, ' AND ');
      }
      
      // Prevent over 50,000
      query += ' LIMIT 50000';
      
      Lac_Farmer_Details__c[] farmers = Database.query(query);
      
      List<MapMarkers> mapMarkers = new List<MapMarkers>();
      for (Lac_Farmer_Details__c farmer : farmers) {
          mapMarkers.add(new LacMapMarkers.LacFarmerMarker(farmer));
      }
        return mapMarkers;  
    }
  }
  
  // Return a list of Lac Ckw Map Markers
  public with sharing class CKWs implements MapComponentController.IMapMarkerSource {
    public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
      
      String query = 'SELECT Id, ' +
              'Person__r.GPS_Location_E__c,' + 
              'Person__r.GPS_Location_N__c, ' +
              'Person__r.First_Name__c, ' +
              'Person__r.Last_Name__c, ' +
              'Person__r.Gender__c ' +
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
      
      // Prevent over 50,000
      query += ' LIMIT 50000';
      
      CKW__c[] ckws = Database.query(query);
      
      List<MapMarkers> mapMarkers = new List<MapMarkers>();
      for (CKW__c ckw : ckws) {
          mapMarkers.add(new LacMapMarkers.LacCkwMarker(ckw));
      }
        return mapMarkers;  
    }
  }
  
  // Return a list of Lac Ckw Map Markers
  public with sharing class AllPeople implements MapComponentController.IMapMarkerSource {
    public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
      List<MapMarkers> mapMarkers = new List<MapMarkers>();
      
      LacMapMarkerSources.Farmers farmers = new LacMapMarkerSources.Farmers();
      mapMarkers.addAll(farmers.loadMapMarkers(parameters));
    
      LacMapMarkerSources.CKWs ckws = new LacMapMarkerSources.CKWs();
      mapMarkers.addAll(ckws.loadMapMarkers(parameters));
      
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