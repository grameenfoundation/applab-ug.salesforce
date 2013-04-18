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
          this.setMarkerColour('FF0000');
      }
      
      public override String getMarkerInfoContentString() {
        String profile = 'Name: ' + this.farmer.Person__r.First_Name__c + ' ' + this.farmer.Person__r.Last_Name__c + '<br/>';
        profile += 'Gender: ' + this.farmer.Person__r.Gender__c;
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
          this.setDefaultColour('0000FF');
      }
      
      public override String getMarkerInfoContentString() {
        String profile = 'Name: ' + this.ckw.Person__r.First_Name__c + ' ' + this.ckw.Person__r.Last_Name__c + '<br/>';
        profile += 'Gender: ' + this.ckw.Person__r.Gender__c;
        return profile;
      }
      
      public override String getLocation() {
        return '';
      }
  }
}