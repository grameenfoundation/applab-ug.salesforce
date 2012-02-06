public class SubmissionSelectorController {

    private DashboardSelectorController dashboardSelectorController;
    private String surveyName;
    private String orgName;

    private String errorMessage;
    public String getErrorMessage() {
        return this.errorMessage;
    }
    public void setErrorMessage(String errorMsg) {
        this.errorMessage = errorMsg;
    }

    private Boolean showOrganisationChooser;
    public Boolean getShowOrganisationChooser() {
        return this.showOrganisationChooser;
    }
    public void setShowOrganisationChooser(Boolean bool) {
        this.showOrganisationChooser = bool;
    }

    private Boolean showSurveyChooser;
    public Boolean getShowSurveyChooser() {
        return this.showSurveyChooser;
    }
    public void setShowSurveyChooser(Boolean bool) {
        this.showSurveyChooser = bool;
    }

    private Boolean showDetails;
    public Boolean getShowDetails() {
        return this.showDetails;
    }
    public void setShowDetails(Boolean bool) {
        this.showDetails = bool;
    }

    public SubmissionSelectorController(DashboardSelectorController dashboardSelectorController) {

        // Get reference to current page
        PageReference currentPage = ApexPages.currentPage();

        this.dashboardSelectorController = dashboardSelectorController;

        // Check to see if we have preselected a survey. If there is a preselected survey then dont show the
        // organisation chooser either.
        setShowOrganisationChooser(false);
        setShowSurveyChooser(true);
        if (currentPage.getParameters().containsKey('surveysParam')) {
            setShowSurveyChooser(false);
            this.surveyName = currentPage.getParameters().get('surveysParam');
        }
        else {

            // Check which user is logged in and set the organistaion appropriately
            this.orgName = Utils.getOrgName(null);
            if (this.orgName.equals('null') || this.orgName.equals('')) {
                setShowOrganisationChooser(true);
            }
        }

        setShowDetails(true);

        // Check to see if we have an error message to display.
        if (currentPage.getParameters().containsKey('errorCode') && !currentPage.getParameters().get('errorCode').equals('Success')) {
            String code = currentPage.getParameters().get('errorCode');
            if (code.equals('0')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'This survey does not have a form attached to it. Please go to the form designer and save the survey'));
            }
            else if (code.equals('1')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Attached form is empty'));
            }
            else if (code.equals('2')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Invalid type of survey XML'));
            }
            else if (code.equals('3')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'There are no submissions that match the parameters you have choosen'));
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'An error has occured'));
            }
        }
    }

    public PageReference getSubmissionsExcel() {
        return getSubmissionsPage('xls');	
    }

    public PageReference getSubmissionsCsv() {
        return getSubmissionsPage('csv');
    }

    public PageReference getSubmissionsPage(String exportType) {

        PageReference newPage = null; 
        if(exportType == 'xls') {
            newPage = Page.SubmissionExcelExport;
            newPage.getParameters().put('dataType', 'xls');
        }
        else {
            newPage = Page.SubmissionCsvPage;
            newPage.getParameters().put('dataType', 'csv');
        }

        buildParameters();
        Map<String, String> variableMap = this.dashboardSelectorController.getVariableMap();
        for(String key : variableMap.keySet()) {
            newPage.getParameters().put(key, variableMap.get(key));
        }

        newPage.setRedirect(true);
        return newPage;
    }

    private Boolean buildParameters() {

        if (this.dashboardSelectorController.survey == null && this.surveyName == null) {
            return false;
        }

        // Sort the organisation parameter
        if (getShowOrganisationChooser()) {
            this.dashboardSelectorController.addVariable('orgName', this.dashboardSelectorController.organisations);
        }
        else {
            this.dashboardSelectorController.addVariable('orgName', this.orgName);
        }

        // Where do we get the survey name from
        if (getShowSurveyChooser()) {
            if (this.dashboardSelectorController.survey.contains('\'')) {
                this.dashboardSelectorController.addVariable('surveyName', this.dashboardSelectorController.survey);
            }
            else {
                this.dashboardSelectorController.addVariable('surveyName', '\'' + this.dashboardSelectorController.survey + '\'');
            }
        }
        else {
            if (this.surveyName.contains('\'')) {
                this.dashboardSelectorController.addVariable('surveyName', this.surveyName);
            }
            else {
                this.dashboardSelectorController.addVariable('surveyName', '\'' + this.surveyName + '\'');
            }
        }
        this.dashboardSelectorController.addVariable('district', this.dashboardSelectorController.district);
        this.dashboardSelectorController.addVariable('ckws', MetricHelpers.generateCommaSeperatedString(this.dashboardSelectorController.selectedCkws, true));
        this.dashboardSelectorController.addVariable('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(this.dashboardSelectorController.surveyDatePicker.Start_Date__c), false));
        this.dashboardSelectorController.addVariable('submissionEndDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(this.dashboardSelectorController.surveyDatePicker.End_Date__c), false));
        return true;
    }

    public static testMethod void testController() {
        SubmissionSelectorController controller = new SubmissionSelectorController(new DashboardSelectorController());
        controller.dashboardSelectorController.district = 'Hi';
        controller.dashboardSelectorController.selectedCkws.add('You');
        controller.dashboardSelectorController.selectedCkws.add('Me');
        controller.dashboardSelectorController.selectedCkws.add('Them');
        controller.dashboardSelectorController.survey = 'Go';
        String excelPage = controller.getSubmissionsExcel().getUrl();
        String csvPage = controller.getSubmissionsCsv().getUrl();
    }
}