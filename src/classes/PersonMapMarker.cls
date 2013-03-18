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
        this.setMarkerTitle(person.Name);
        setDefaultColour('Blue');
    }

    // Create the content string for the marker pop up
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.person.Name + '<br />' +
            getGender(this.person.Gender__c) + '<br />' +
            getLocation();

        if (getShowMoreDetails()) {
            content += 'DETAILS';
        }
        content += '</div>';
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
        if (this.person.Subcounty__r.Display_Name__c != null) {
            location = location + 'Sub-county: ' + this.person.Subcounty__r.Display_Name__c + '<br />';
        }
        if (this.person.District__r.Name != null) {
            location = location + 'District: ' + this.person.District__r.Name + '<br />';
        }
        return location;
    }
    
    /**
     *  Generate the marker name for this map marker
     *  This will also set the colour of the marker if the splitter is of a certain value
     *
     *  @param splitter - The field used to split the markers into different colours
     */
    public override void generateMarkerName(String splitter) {

        String fieldValue = '';
        setColour(getDefaultColour());

        // Set the colours for a gender split
        if (splitter.equals('Gender')) {
            fieldValue = this.person.Gender__c;
            setColour('Pink');
            if (fieldValue == null) {
                setColour('Black');
                fieldValue = 'Missing';
            }
            else if (fieldValue.equals('Male')) {
                setColour('Blue');
            }
        }
        setMarkerName(joinMarkerName('', '', fieldValue));
    }


    static testMethod void testMarker() {
    
     String markerInfoContent = '<div>' +
            'null<br />' +
            'Gender: Male<br />' +
            'Parish: Test Parish<br />' +
            'Village: Test Village<br />' +
            '</div>';
           
        District__c district = new District__c();
        district.Name = 'Test District';
        Database.SaveResult districtResult = database.insert(district);
        
        Subcounty__c subcounty = new Subcounty__c();
        subcounty.Display_Name__c = 'Test Subcounty';
        subcounty.District__c = districtResult.getId();
        Database.SaveResult subcountyResult = database.insert(subcounty);
        
        List<District__c> districts = [SELECT Id FROM District__c WHERE Name = 'Test District'];
        List<Subcounty__c> subcounties = [SELECT Id FROM Subcounty__c WHERE Display_Name__c = 'Test Subcounty'];
        Person__c person = new Person__c();
        person.First_Name__c = 'Testing People';
        person.GPS_Location_E__c = '1';
        person.GPS_Location_N__c = '2';
        person.Gender__c = 'Male';
        person.Village__c = 'Test Village';
        person.Parish__c = 'Test Parish';
        person.District__c = districts.get(0).Id;
        person.Subcounty__c = subcounties.get(0).Id;
        database.insert(person);
        
        PersonMapMarker marker = new PersonMapMarker(person);
        System.debug(marker.getMarkerInfoContentString());
        System.assertEquals(marker.getMarkerInfoContentString(), markerInfoContent);
        
    }
}