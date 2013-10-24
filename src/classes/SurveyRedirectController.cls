public class SurveyRedirectController {

    private final Survey__c survey;

    public SurveyRedirectController(ApexPages.StandardController stdController) {
        this.survey = (Survey__c)stdController.getRecord();
    }

    public SurveyRedirectController(Survey__c survey) {
        this.survey = survey;
    }

    public PageReference redirectPage() {
        Survey__c s = [SELECT Name, Save_To_Salesforce__c FROM Survey__c WHERE Id = :this.survey.Id];
        PageReference newPage = null;
        if (s.Save_To_Salesforce__c) {
            newPage = Page.SubmissionSelector;
            newPage.getParameters().put('surveysParam', s.Name);
        }
        else {
            newPage = Page.SurveySubmissions;
            newPage.getParameters().put('id', this.survey.Id);
        }

        newPage.setRedirect(true);
        return newPage;
    }

    public static testMethod void testSurveyRedirectController () {

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        SurveyRedirectController controller = new SurveyRedirectController(survey2);
        controller.redirectPage();
    }
}