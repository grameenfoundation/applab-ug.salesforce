/**
 *  Class to generate map markers for the Farmer__c sObject.
 *  Extends MapMarker
 */
 public with sharing class FarmerMapMarker extends MapMarkers {

    private Farmer__c farmer;
    private String parentRegistered;
    public String getParentRegistered() {
        return this.parentRegistered;
    }
    public void setParentRegistered(String value) {
        this.parentRegistered = value;
    }

    public FarmerMapMarker(Farmer__c farmer) {
        this.farmer = farmer;
        this.setLatitude(farmer.Person__r.GPS_Location_E__c);
        this.setLongitude(farmer.Person__r.GPS_Location_N__c);
        setDefaultColour('Red');
    }

    // Create the content string for the marker pop up
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.farmer.Name + '<br />' +
            getGender(this.farmer.Person__r.Gender__c) + '<br />' +
            getLocation() +
            'Registered By: ' + getParentRegistered() + '<br />';

        // This section below will house the links to more details about the farmer.
        // Will be implemented when it is required
        if (getShowMoreDetails()) {
        }
        return content;
    }

    // Create the location string
    public override String getLocation() {

        String location = '';
        if (this.farmer.Person__r.Parish__c != null) {
            location = 'Parish: ' + this.farmer.Person__r.Parish__c + '<br />';
        }
        if (this.farmer.Person__r.Village__c != null) {
            location = location + 'Village: ' + this.farmer.Person__r.Village__c + '<br />';
        }
        return location;
    }

    static testMethod void testMarker() {

        Farmer__c farmer = new Farmer__c();
        FarmerMapMarker marker = new FarmerMapMarker(farmer);
        marker.getMarkerInfoContentString();
    }

}