/**
 *  Class to represent a map marker that contains details about a CKW
 */

public with sharing class CkwMapMarker extends MapMarkers {

    private CKW__c ckw;

    public CkwMapMarker(CKW__c ckw) {
        this.ckw = ckw;
        this.setLatitude(ckw.Person__r.GPS_Location_E__c);
        this.setLongitude(ckw.Person__r.GPS_Location_N__c);
        this.setMarkerTitle(ckw.Name);
        setDefaultColour('Red');
    }

    // Generate the content string for a CKW
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.ckw.Name + '<br />' +
            getGender(this.ckw.Person__r.Gender__c) + '<br />' +
            getLocation() +
            getPerformanceLevel() +
            getThisMonthsPerformance() +
            getProjectString();

        // This needs to be changed to add links to the ectra details for the CKW
        // Will implement when this feature is required
        if (getShowMoreDetails()) {
        }
        return content;
    }

    // Create the location string
    public override String getLocation() {

        String location = '';
        if (this.ckw.Person__r.Parish__c != null) {
            location = 'Parish: ' + this.ckw.Person__r.Parish__c + '<br />';
        }
        if (this.ckw.Person__r.Village__c != null) {
            location = location + 'Village: ' + this.ckw.Person__r.Village__c + '<br />';
        }
        return location;
    }

    // Create the Performance level string for last month
    private String getPerformanceLevel() {

        String performance = 'Last months performance level is unavailable';
        if (ckw.Previous_Performance_Review__c != null) {
            performance = 'Last months performance level was: ' + ckw.Previous_Performance_Review__r.Performance_Level__c;
        }
        return performance;
    }

    // Create the performance level string for this month
    private String getThisMonthsPerformance() {

        String thisMonthPerformance = 'No performance record for this month<br />';
        if (ckw.Current_Performance_Review__c != null) {
            thisMonthPerformance = 'This months search target is: ' + ckw.Current_Performance_Review__r.Monthly_Target__r.Search_Target__c + '<br />' +
                'Searches performed this month: ' + ckw.Current_Performance_Review__r.Total_Searches__c + '<br />' +
                'This months surveys target is: ' + ckw.Current_Performance_Review__r.Monthly_Target__r.Survey_Target__c + '<br />' +
                'Surveys carried out this month: '+ ckw.Current_Performance_Review__r.Total_Surveys__c + '<br />';
        }
        return thisMonthPerformance;
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
            fieldValue = this.ckw.Person__r.Gender__c;
            setColour('Pink');
            if (fieldValue == null) {
                setColour('Black');
                fieldValue = 'Missing';
            }
            else if (fieldValue.equals('Male')) {
                setColour('Blue');
            }
        }

        // Set the colours for a status split
        else if (splitter.equals('Status')) {
            fieldValue = this.ckw.Status__c;
            setColour('Yellow');
            if (fieldValue == null) {
                setColour('Black');
                fieldValue = 'Missing';
            }
            else if (fieldValue.equals('Active')) {
                setColour('White');
            }
            else {
                fieldValue = 'Inactive';
            }
        }

        // Set the colours for a poverty level split
        else if (splitter.equals('Poverty')) {
            fieldValue = this.ckw.Poverty_Status__c;
            setColour('Green');
            if (fieldValue == null) {
                setColour('Black');
                fieldValue = 'Missing';
            }
            else if (fieldValue.equals('Not Poor')) {
                setColour('Yellow');
                fieldValue = 'Poor';
            }
            else {
                fieldValue = 'Very Poor';
            }
        }
        setMarkerName(joinMarkerName('CKW', getColour(), fieldValue));
    }

    static testMethod void testMarker() {

        CKW__c ckw = Utils.createTestCkw(null, 'Y', true, null, 'Female');
        Database.insert(ckw);
        CkwMapMarker marker = new CkwMapMarker(ckw);
        marker.getMarkerInfoContentString();
        marker.generateMarkerName('Gender');
        marker.generateMarkerName('Poverty');
        marker.generateMarkerName('Status');
    }
}