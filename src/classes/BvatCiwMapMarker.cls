/**
 *  Class to represent a map marker that contains details about a BVAT CIW
 */

public with sharing class BvatCiwMapMarker extends MapMarkers {

    private CIW__c ciw;

    public BvatCiwMapMarker(CIW__c ciw) {
        this.ciw = ciw;
        this.setLatitude(ciw.Person__r.GPS_Location_N__c);
        this.setLongitude(ciw.Person__r.GPS_Location_E__c);
        this.setMarkerTitle(ciw.Name + ', ' + ciw.Person__r.Last_Name__c + ' ' + ciw.Person__r.First_Name__c);
        setDefaultColour('Red');
    }

    // Generate the content string for a CIW
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.ciw.Name + ', ' + this.ciw.Person__r.Last_Name__c + ' ' + this.ciw.Person__r.First_Name__c + '<br />' +
            getGender(this.ciw.Person__r.Gender__c) + '<br />';
            

        // This needs to be changed to add links to the ectra details for the CIW
        // Will implement when this feature is required
        if (getShowMoreDetails()) {
        }
        return content;
    }
}