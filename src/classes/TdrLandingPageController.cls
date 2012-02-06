public with sharing class TdrLandingPageController {

    public Boolean hideFromUser { get; set; }

    private Map<String, String> translationMap;

    public TdrLandingPageController() {

        // Check what can be displayed based on the user logged in.
        this.hideFromUser = false;
        if (UserInfo.getProfileId().equals('00e70000001FiEpAAK')) {
            this.hideFromUser = true;
        }

        // Get reference to current page
        PageReference currentPage = ApexPages.currentPage();

        // Check to see if we have an error message to display.
        if (currentPage.getParameters().containsKey('errorCode') && !currentPage.getParameters().get('errorCode').equals('Success')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, translateErrorCode(currentPage.getParameters().get('errorCode'))));
        }
    }

    public PageReference openPage() {

        // Get reference to current page
        PageReference currentPage = ApexPages.currentPage();

        PageReference newPage = null;

        // Find the page that it is
        String pageType = currentPage.getParameters().get('type');

        // Based on the type redirect the user to the correct page. Would love a switch statement here.
        if (pageType.equals('graphs')) {
            newPage = Page.TdrGraph;
            newPage.setRedirect(true);
        }
        else if (pageType.equals('tdrTargets')) {
            newPage = Page.TdrDefaultTargets;
            newPage.getParameters().put('targetType', 'TDR');
            newPage.setRedirect(true);
        }
        else if (pageType.equals('defaultTargets')) {
            newPage = Page.TdrDefaultTargets;
            newPage.getParameters().put('targetType', 'DEFAULT');
            newPage.setRedirect(true);
        }
        else if (pageType.equals('reg')) {
            newPage = Page.TdrRegistration;
            newPage.setRedirect(true);
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, translateErrorCode('1')));
        }
        return newPage;
    }

    private String translateErrorCode(String code) {

        if (this.translationMap == null) {
            setTranslationMap();
        }
        String errorMessage = this.translationMap.get(code);
        if (errorMessage == null || errorMessage.equals('')) {
            errorMessage = 'An unknown error has occured. If this persitis please contact support';
        }
        return errorMessage;

    }

    private void setTranslationMap() {

        this.translationMap = new Map<String, String> {
            '0' => 'You are trying to set targets for a type that does not exist. Stop it!',
            '1' => 'The page you are trying to access does not exist. Please select another page.'
         };
    }

    static testMethod void testController() {

        PageReference pageRef = Page.TdrLandingPage;
        Test.setCurrentPage(pageRef);

        TdrLandingPageController controller = new TdrLandingPageController();

        // Add each possible type and test the url that is reutrned
        String newPageUrl;
        ApexPages.currentPage().getParameters().put('type', 'graphs');
        newPageUrl = controller.openPage().getUrl();
        System.assertEquals('/apex/tdrgraph', newPageUrl);
        ApexPages.currentPage().getParameters().put('type', 'reg');
        newPageUrl = controller.openPage().getUrl();
        System.assertEquals('/apex/tdrregistration', newPageUrl);


        ApexPages.currentPage().getParameters().put('type', 'tdrTargets');
        PageReference newPage= controller.openPage();
        newPageUrl = newPage.getUrl();
        System.assertEquals('/apex/tdrdefaulttargets?targetType=TDR', newPageUrl);
        System.assertEquals('TDR', newPage.getParameters().get('targetType'));
        ApexPages.currentPage().getParameters().put('type', 'defaultTargets');
        newPage = controller.openPage();
        newPageUrl = newPage.getUrl();
        System.assertEquals('/apex/tdrdefaulttargets?targetType=DEFAULT', newPageUrl);
        System.assertEquals('DEFAULT', newPage.getParameters().get('targetType'));

    }

    static testMethod void testTranslation() {

        TdrLandingPageController controller = new TdrLandingPageController();
        System.assertEquals('You are trying to set targets for a type that does not exist. Stop it!', controller.translateErrorCode('0'));
        System.assertEquals('An unknown error has occured. If this persitis please contact support', controller.translateErrorCode('NO CODE'));
    }
}