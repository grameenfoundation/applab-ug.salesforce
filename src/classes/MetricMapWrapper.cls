public class MetricMapWrapper {

    /**
     *  Wrapper class that stores the data required to show a marker and its
     *  content window on a metric map
     */

    public String gpsLatitude { get; set; }
    public String gpsLongitude { get; set; }
    public String markerColour { get; set; }
    public String markerTitle { get; set; }
    public String markerLabel { get; set; }
    public String markerInfoContentString;

    private Map<String, Project__c> projectDescription;
    private String gender;
    private String thisMonthsPerformance;
    private String performanceLevel;
    private String location;
    private String name;
    private String markerType;
    private String id;
    private Boolean showMoreDetailLink;
    private String ckwParent;
    private String farmerParent;
    private String query;
    private String searchTime;
    private String submitTime;
    private String keyword;

    private String interviewerId;
    private String intervieweeId;
    private String surveyId;

    public MetricMapWrapper(String markerType, String colour, String id, boolean showMoreDetailLink) {

        // Set some defaults.
        this.markerType = markerType;
        this.gender = '';
        this.performanceLevel = '';
        this.location = '';
        this.name = '';
        this.thisMonthsPerformance = '';
        this.markerColour = colour;
        this.markerLabel = '';
        this.id = id;
        this.ckwParent = 'Unavailable';
        this.farmerParent = 'Unavailable';
        this.query = 'Unavailable';
        this.searchTime = 'Unavailable';
        this.submitTime = 'Unavailable';
        this.keyword = 'Unavailable';
        this.interviewerId = 'Unavailable';
        this.intervieweeId = 'Unavailable';
        this.surveyId = 'Unavailable';
        this.projectDescription = new Map<String, Project__c>();
        this.showMoreDetailLink = showMoreDetailLink;
    }

    public void addToProjectDesc(String projectName, Project__c project) {
        projectDescription.put(projectName, project);
    }

    public void addGender(string gender) {
        this.gender = gender;
    }

    public void addPerformanceLevel(String level) {
        this.performanceLevel = level;
    }

    public void addLocation(String location) {
        this.location = location;
    }

    public void addName(String name) {
        this.name = name;
    }

    public void addThisMonthPerformance(String performance) {
        this.thisMonthsPerformance = performance;
    }

    public void addCkwParent(String name) {
        this.ckwParent = name;
    }

    public void addFarmerParent(String name) {
        this.farmerParent = name;
    }

    public void addQuery(String query) {
        this.query = query;
    }

    public void addSearchTime(String searchTime) {
        this.searchTime = searchTime;
    }

    public void addSubmitTime(String submitTime) {
        this.submitTime = submitTime;
    }

    public String getMarkerInfoContentString() {
        setMarkerInfoContentString();
        return markerInfoContentString;
    }

    public void addLabel(String label) {
        this.markerLabel = label;
    }

    public void addKeyword(String keyword) {
        if (keyword.equals('')) {
            return;
        }
        this.keyword = keyword;
    }

    public void addInterviewerId(String Id) {
        this.interviewerId = Id;
    }

    public void addIntervieweeId(String Id) {
        this.intervieweeId = Id;
    }

    public void addSurveyId(String Id) {
        this.surveyId = Id;
    }

    public void setMarkerInfoContentString() {

        String content = '<div>';
        if (this.markerType.equals('CKW')) {
            content = content + 
                      this.name + '<br />' +
                      this.gender + '<br />' +
                      this.location +
                      this.performanceLevel + '<br />' +
                      this.thisMonthsPerformance + '<br />';
            if (this.projectDescription.size() > 0) {
                for (String projectName : projectDescription.keySet()) {
                    Project__c project = projectDescription.get(projectName);
                    content = content + '<strong>' + project.Organisation__r.Name + ': ' + projectName + '</strong><br />' +
                        project.Description__c + '<br />';
                }
            }

            // Add a link to more detailed stuff
            if (this.showMoreDetailLink) {
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'CKW\\\',\\\'\\\', \\\'' + this.id + '\\\', null , \\\'true\\\', \\\'true\\\', \\\'true\\\', null, null, \\\'true\\\')\\">Click Here for More Detailed CKW Map</a><br/>';
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openGraph(\\\'' + this.id + '\\\', null, null)\\">Click Here for CKW Search Graphs</a><br/>';
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openTagCloud(\\\'' + this.id + '\\\', null, null)\\">Click Here for CKW Tag Cloud</a>';
            }
        }
        else if (this.markerType.equals('Farmer')) {
            content = this.name + '<br />' +
                      this.gender + '<br />' +
                      this.location + '<br />' +
                      'Registered By: ' + this.ckwParent + '<br />';

            if (this.showMoreDetailLink) {
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'FARMERS\\\', \\\'\\\', null, \\\'' + this.id + '\\\', \\\'false\\\', \\\'true\\\', \\\'true\\\', null, null, \\\'true\\\')\\">Click Here for Farmer Searches Map</a><br/>';
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openGraph(null, \\\'' + this.id + '\\\', null)\\">Click Here for Farmer Searches Graphs</a><br/>';
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openTagCloud(null, \\\'' + this.id + '\\\', null)\\">Click Here for Farmer Searches Tag Cloud</a>';
            }
        }
        else if (this.markerType.equals('Search')) {
            content =   'Search for ' + this.query + '.<br />' +
                        'Carried out by ' + this.ckwParent + '<br />' +
                        'for ' + this.farmerParent + '.<br />' +
                        'Search carried out at ' + this.searchTime + '<br />' +
                        'Matches keyword ' + this.keyword + '<br />';

            if (this.showMoreDetailLink && !this.keyword.equals('Unavailable')) {
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'SEARCHES\\\',\\\'\\\', null, null , \\\'false\\\', \\\'true\\\', \\\'true\\\', \\\'' + this.keyword + '\\\', null, \\\'true\\\')\\">Click Here for Keyword Map</a><br/>';
            }
        }
        else if (this.markerType.equals('SearchSub')) {
            content =   'Search submitted for ' + this.query + '.<br />' +
                        'Carried out by ' + this.ckwParent + '<br />' +
                        'for ' + this.farmerParent + '.<br />' +
                        'Search carried out at ' + this.searchTime + '.<br />' +
                        'Search submitted at ' + this.submitTime + '.<br />' +
                        'Matches keyword ' + this.keyword + '<br />';

            if (this.showMoreDetailLink && !this.keyword.equals('Unavailable')) {
                content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'SEARCHES\\\',\\\'\\\', null, null , \\\'false\\\', \\\'true\\\', \\\'true\\\', \\\'' + this.keyword + '\\\', null, \\\'true\\\')\\">Click Here for Keyword Map</a><br/>';
            }
        }
        else if (this.markerType.equals('SurveySubmission')) {
            content =   'Survey submission for survey ' + this.name + '.<br />';
                if (this.interviewerId != 'Unavailable') {
                    content = content + 'Conducted by ' + this.ckwParent + '.<br />';
                }
                if (this.intervieweeId != 'Unavailable') {
                    content = content + 'Interviewee ' + this.farmerParent + '.<br />';
                }
            if (this.showMoreDetailLink) {
                if (UserInfo.getUserType() != 'GUEST') {
                    content += '<a href=\\"javascript\\:void(0)\\" onclick=\\"openPage(' + this.id + ')\\">Click to see submission</a><br/>';
                }
                content += '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'SURVEYS\\\', \\\'\\\', null, null , \\\'false\\\', \\\'false\\\', \\\'false\\\', null, \\\'' + this.surveyId + '\\\', \\\'false\\\')\\">Click to see all submissions for this survey</a><br/>';
                if (this.interviewerId != 'Unavailable') {
                    content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'SURVEYS\\\', \\\'\\\', \\\'' + this.interviewerId + '\\\', null , \\\'false\\\', \\\'false\\\', \\\'false\\\', null, null, \\\'false\\\')\\">Click to see all submissions for this interviewer</a><br/>';
                }
                if (this.intervieweeId != 'Unavailable') {
                    content = content + '<a href=\\"javascript\\:void(0)\\" onclick=\\"openMap(\\\'SURVEYS\\\', \\\'\\\', null, \\\'' + this.intervieweeId + '\\\', \\\'false\\\', \\\'false\\\', \\\'false\\\', null, null, \\\'false\\\')\\">Click to see all submissions for this interviewee</a><br/>';
                }
            }
        }
        else if (this.markerType.equals('Metric')) {
            content = 'Metric ' + this.name + '.<br />' +
                        'For district ' + this.location + '.<br />' +
                        'Value for this quarter = ' + this.thisMonthsPerformance + '.<br />' +
                        'Target for this quarter = ' + this.performanceLevel + '.<br />';
        }
        else if (this.markerType.equals('Harvest')) {
            content = this.name;
            content += '<a href=\\"javascript\\:void(0)\\" onclick=\\"window.open(\\\'/' + this.id + '\\\',\\\'_blank\\\');\\">See harvest details</a><br/>';
        }
        else if (this.markerType.equals('DairyHub')) {
            content = this.name;
            content += '<a href=\\"javascript\\:void(0)\\" onclick=\\"window.open(\\\'/' + this.id + '\\\',\\\'_blank\\\');\\">See hub details</a><br/>';
        }
        else if (this.markerType.equals('CBTFieldVisit')) {
            content = this.name;
            content += '<a href=\\"javascript\\:void(0)\\" onclick=\\"window.open(\\\'/' + this.id + '\\\',\\\'_blank\\\');\\">See visit details</a><br/>';
        }
        markerInfoContentString = content + '</div>';

    }

    public static testMethod void testConstructor() {
        
        District__c d = new District__c();
        d.Name = 'Gulu';
        insert d;

        District__c district = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Gulu' order by CreatedDate desc limit 1];

        // Create a 2nd CKW who is inactive
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253463';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        testPerson.District__c = district.id;
        testPerson.Gender__c = 'Female';
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        testCkw.Status__c = 'Inactive';
        database.insert(testCkw);

        // Create an organistaion
        Account organisation = new Account();
        organisation.Name = 'TestOrganisation';
        organisation.BillingState = 'CA';
        database.insert(organisation);

        // Create a project
        Project__c project = new Project__c();
        project.Description__c = 'Hello how are you';
        project.Name = 'TestProject';
        project.Organisation__c = organisation.Id;
        database.insert(project);

        // Create Project Associations
        Person_Project_Association__c personProjectAssociation = new Person_Project_Association__c();
        personProjectAssociation.Person__c = testPerson.Id;
        personProjectAssociation.Project__c = project.Id;
        database.insert(personProjectAssociation);

        MetricMapWrapper mmw = new MetricMapWrapper('CKW', 'FF0000', 'JimLad', true);
        mmw.addToProjectDesc(project.Name, project);
        mmw.addGender(testPerson.Gender__c);
        mmw.addLocation(testPerson.District__r.Name);
        mmw.addName(testPerson.Last_Name__c);
        mmw.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw.markerColour);

        MetricMapWrapper mmw1 = new MetricMapWrapper('Farmer', 'FF0000', 'JimLad', true);
        mmw1.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw1.markerColour);

        MetricMapWrapper mmw2 = new MetricMapWrapper('Search', 'FF0000', 'JimLad', true);
        mmw2.addKeyword('Maize');
        mmw2.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw2.markerColour);

        MetricMapWrapper mmw3 = new MetricMapWrapper('SearchSub', 'FF0000', 'JimLad', true);
        mmw3.addKeyword('Maize');
        mmw3.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw3.markerColour);

        MetricMapWrapper mmw4 = new MetricMapWrapper('SurveySubmission', 'FF0000', 'JimLad', true);
        mmw4.addIntervieweeId(testCkw.Id);
        mmw4.addInterviewerId(testCkw.Id);
        mmw4.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw4.markerColour);

        MetricMapWrapper mmw5 = new MetricMapWrapper('Metric', 'FF0000', 'JimLad', true);
        mmw5.getMarkerInfoContentString();
        System.assertEquals('FF0000', mmw5.markerColour);
    }
}