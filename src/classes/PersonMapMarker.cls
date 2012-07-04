/**
 *  Class to generate map markers for the Person__c sObject.
 *  Extends MapMarker
 */
public with sharing class PersonMapMarker extends MapMarkers {

    private Person__c person;

    public PersonMapMarker(Person__c person) {
        this.person = person;
        this.setLatitude(person.GPS_Location_E__c);
        this.setLongitude(person.GPS_Location_N__c);
        setDefaultColour('Blue');
    }

    // Create the content string for the marker pop up
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.person.Name + '<br />' +
            getGender(this.person.Gender__c) + '<br />' +
            getLocation();

        if (getShowMoreDetails()) {
            content += 'DEATILS';
        }
        return content;
    }

    // Create the location string
    public override String getLocation() {

        String location = '';
        if (this.person.Parish__c != null) {
            location = 'Parish: ' + this.person.Parish__c + '<br />';
        }
        if (this.person.Village__c != null) {
            location = location + 'Village: ' + this.person.Village__c + '<br />';
        }
        return location;
    }

    static testMethod void testMarker() {

        Person__c person = new Person__c();
        PersonMapMarker marker = new PersonMapMarker(person);
        marker.getMarkerInfoContentString();
        
    }
}