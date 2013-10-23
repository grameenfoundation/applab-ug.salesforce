/**
 *  Class to generate map markers for the Client_LOcation__c sObject.
 *  Extends MapMarker
 */
public with sharing class ClientLocationMapMarker extends MapMarkers {

    private Client_Location__c location;

    public ClientLocationMapMarker(Client_Location__c location) {
        this.location = location;
        this.setLatitude(location.Latitude__c);
        this.setLongitude(location.Longitude__c);
        this.setMarkerTitle(location.Name);
        setDefaultColour('Green');
    }

    // Create the content string for the marker pop up
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.location.Display_Name__c + '<br />' +
            this.location.Type__c + '<br />' +
            'For: ' + this.location.Account__r.Name + '<br />' +
            this.location.Description__c + '<br />' +
            getPersonDetails() +
            '</div>';
        return content;
    }

    public override void generateMarkerName(String splitter) {
        setColour(getDefaultColour());
        setMarkerName(joinMarkerName(location.Type__c, getColour(), ''));
    }

    public override String getColour() {
        return this.colour;
    }

    private String getPersonDetails() {

        String content = '';
        if (location.Person__c != null) {
            content = '<br />Name: ' + location.Person__r.First_Name__c + ' ' + location.Person__r.Last_Name__c + '<br />' +
                'Subcounty: ' + location.Person__r.Subcounty__r.Display_Name__c + '<br />';
        }
        return content;
    }

    static testMethod void testMarker() {

        Client_Location__c location = new Client_Location__c();
        location.Display_Name__c = 'lk';
        location.Latitude__c = '';
        location.Longitude__c = '';
        location.Type__c = 'Rain Gauge';
        Database.insert(location);

        ClientLocationMapMarker marker = new ClientLocationMapMarker(location);
        marker.getMarkerInfoContentString();
        marker.generateMarkerName('');
    }
}