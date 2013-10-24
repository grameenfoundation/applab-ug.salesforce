/**
 *  Virtual class for a map marker used with google maps.
 *  Any object that wants to be represented as a map marker must extend this class
 */

public with sharing virtual class MapMarkers {

    // Set a default colour for the map marker. Should be called by the extending class during the constructor
    private String defaultColour;
    public String getDefaultColour() {
        return this.defaultColour;
    }
    public void setDefaultColour(String value) {
        this.defaultColour = value;
    }

    // Set the latitude for the marker. Must be called for the marker to show up
    private String latitude;
    public String getLatitude() {
        return this.latitude;
    }
    public void setLatitude(String value) {
        this.latitude = value;
    }

    // Set the longitude for the marker. Must be called for the marker to show up
    private String longitude;
    public String getLongitude() {
        return this.longitude;
    }
    public void setLongitude(String value) {
        this.longitude = value;
    }

    // The colour that the marker will be shown as on the map.
    // Use hex colour format
    private String markerColour;
    public String getMarkerColour() {
        return this.markerColour;
    }
    public void setMarkerColour(String value) {
        this.markerColour = value;
    }

    // The title that will show when a marker is hovered over on the map
    private String markerTitle;
    public String getMarkerTitle() {
        return this.markerTitle;
    }
    public void setMarkerTitle(String value) {
        this.markerTitle = value;
    }

    private String markerLabel;
    public String getMarkerLabel() {
        return this.markerLabel;
    }
    public void setMarkerLabel(String value) {
        this.markerLabel = value;
    }

    // HTML String that contains the content that is shown when a marker is clicked on
    public String markerInfoContentString;
    public virtual String getMarkerInfoContentString() {
        return this.markerInfoContentString;
    }
    public virtual void setMarkerInfoContentString(String value) {
        this.markerInfoContentString = value;
    }

    // Allow the links to more detailed maps, graphs, tag clouds, etc. Default to off
    private Boolean showMoreDetails = false;
    public Boolean getShowMoreDetails() {
        return this.showMoreDetails;
    }
    public void setShowMoreDetails(Boolean value) {
        this.showMoreDetails = value;
    }

    // List of projects that may be included with a map marker
    private List<String> projectLists = new List<String>();
    public List<String> getProjectLists() {
        return this.projectLists;
    }
    public void setProjectLists(List<String> values) {
        this.projectLists = values;
    }

    // Add the HTML that would display the project
    public void addProject(Project__c project) {
        this.projectLists.add(
            '<strong>' +
            project.Organisation__r.Name +
            ': ' +
            project.Name +
            '</strong><br />' +
            project.Description__c +
            '<br />'
        );
    }
    public String getProjectString() {
        String projectString = '';
        for (String project : this.getProjectLists()) {
            projectString += project;
        }
        return projectString;
    }

    // Get the gender string for the markers
    public String getGender(String gender) {

        String personGender = '';
        if (gender != null) {
            personGender = 'Gender: ' + gender;
        }
        return personGender;
    }

    // Dummy methof for the location of the marker. Returns empty string if extending class doesn't need a location
    public virtual String getLocation() {
        return '';
    }

    private String markerName;
    public String getMarkerName() {
        return this.markerName;
    }
    public void setMarkerName(String value) {
        this.markerName = value;
    }
    public virtual void generateMarkerName(String splitter) {
        setMarkerName('Default Marker');
    }

    public String colour;
    public virtual String getColour() {
        if (this.colour == null) {
            return getDefaultColour();
        }
        return this.colour;
    }
    public void setColour(String value) {
        this.colour = value;
    }

    // Create a unique string with splitters for each type of map marker
    public String joinMarkerName(String mapObject, String markerField, String markerFieldValue) {

        // Note that you should pass an empty string if one of the input values does not apply
        return mapObject + '#@#' + markerField + '#@#'+ markerFieldValue;
    }

    static testMethod void testMarker() {

        Account testOrg = Utils.createTestOrganisation('it');
        Database.insert(testOrg);

        Project__c testProj = new Project__c();
        testProj.Organisation__r = testOrg;
        testProj.Name = 'It';
        testProj.Description__c = 'was';
        Database.insert(testProj);

        Person__c person = Utils.createTestPerson(null, '', false, null, 'Female');
        Database.insert(person);

        MapMarkers marker = new MapMarkers();
        marker.addProject(testProj);
        System.assertEquals(marker.getProjectString(), '<strong>TestOrg_it: It</strong><br />was<br />');
        System.assertEquals('Gender: Female', marker.getGender(person.Gender__c));
        System.assertEquals(marker.joinMarkerName('a', 'rock', 'lobster'), 'a#@#rock#@#lobster');
        marker.generateMarkerName(null);
        System.assertEquals(marker.getMarkerName(), 'Default Marker');
    }
}