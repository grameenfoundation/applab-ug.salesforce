/**
 *  Class to generate map markers for the Submission_Meta_Data__c sObject.
 *  Extends MapMarker
 */
public with sharing class SubmissionMapMarker extends MapMarkers {

    private Submission_Meta_Data__c submission;

    public SubmissionMapMarker(Submission_Meta_Data__c submission) {
        this.submission = submission;
        this.setLatitude(String.valueOf(submission.Submission_Latitude__c));
        this.setLongitude(String.valueOf(submission.Submission_Longitude__c));
        this.setMarkerTitle(submission.Survey_Name__c);
        setDefaultColour('Green');
    }

    // Create the content string for the marker pop up
    public override String getMarkerInfoContentString() {

        String content = '<div>' +
            this.submission.Survey_Name__c + '<br />' +
            //this.submission.Client_Location__r.Display_Name__c + '<br />' +
            getPersonDetails() +
            '</div>';
        return content;
    }

    public override void generateMarkerName(String splitter) {
        setColour(getDefaultColour());
        setMarkerName(joinMarkerName(submission.Interviewer__r.Name, getColour(), ''));
    }

    public override String getColour() {
        return this.colour;
    }

    private String getPersonDetails() {

        String content = '';

        // This not working getting  Invalid foreign key relationship: Submission_Meta_Data__c.Interveiwer__r
        if (this.submission.Interviewer__c != null) {   
            content = '<br />Name: ' + this.submission.Interviewer__r.First_Name__c + ' ' + this.submission.Interviewer__r.Last_Name__c + '<br />' +
                'Subcounty: ' + this.submission.Interviewer__r.Subcounty__r.Display_Name__c + '<br />';
                
        }
        //content = '<br/>Name: ' + submission.Interviewer_Name__c + '<br/>';
        return content;
    }

    static testMethod void testMarker() {
        District__c testDistrict = Utils.createTestDistrict('Test District');
        database.insert(testDistrict);

        Subcounty__c testSubCounty = Utils.createTestSubcounty('Test Subcounty', testDistrict.Id);
        database.insert(testSubCounty);
        
        Phone__c testPhone = Utils.createTestHandset('23423423111');
        database.insert(testPhone);

        Person__c testPerson = Utils.createTestPerson(testPhone.Id, '', false, testDistrict.Id, 'Male');
        Database.insert(testPerson);
        
        Account testAccount = Utils.createTestOrganisation('testorg');
        database.insert(testAccount);
        
        Survey__c testSurvey = Utils.createTestSurvey(testAccount, 'Test Survey');
        database.insert(testSurvey);
        
        Submission_Meta_Data__c submission = new Submission_Meta_Data__c();
        submission.Interviewer__c = testPerson.Id;
        submission.Submission_Latitude__c = 0.3;
        submission.Submission_Longitude__c = 32.5;
        submission.Survey__c = testSurvey.Id;
        submission.Handset_Submit_Time__c = datetime.now();
        submission.Result_Hash__c = 'sw324';
        submission.Submission_Size__c = 12.0;
        Database.insert(submission);

        SubmissionMapMarker marker = new SubmissionMapMarker(submission);
        marker.getMarkerInfoContentString();
        marker.generateMarkerName('');
    }
}