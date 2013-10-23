/**
 *  Class to represent a map marker that contains details about a BVAT Farmer
 */

public with sharing class BvatFarmerMapMarker extends MapMarkers {

    private BVAT_Farmer__c farmer;

    public BvatFarmerMapMarker(BVAT_Farmer__c farmer) {
        this.farmer = farmer;
        this.setLatitude(farmer.Person__r.GPS_Location_N__c);
        this.setLongitude(farmer.Person__r.GPS_Location_E__c);
        this.setMarkerTitle(farmer.Name + ', ' + farmer.Person__r.Last_Name__c + ' ' + farmer.Person__r.First_Name__c);
        setDefaultColour('Blue');
    }

    // Generate the content string for a CIW
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.farmer.Name + ', ' + this.farmer.Person__r.Last_Name__c + ' ' + this.farmer.Person__r.First_Name__c + '<br />' +
            getGender(this.farmer.Person__r.Gender__c) + '<br />';
            

        // This needs to be changed to add links to the ectra details for the BVAT Farmer
        // Will implement when this feature is required
        if (getShowMoreDetails()) {
        }
        return content;
    }
}