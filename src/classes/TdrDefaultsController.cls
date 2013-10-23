public with sharing class TdrDefaultsController {

    /**
     *  Controller for the setting of TDR targets both default and specific
     */

    private TdrSelectorController tdrSelectorController;
    public String targetType { get; set; }

    /**
     *  Constructor for the controller
     */
    public TdrDefaultsController(TdrSelectorController tdrSelectorController) {

        this.tdrSelectorController = tdrSelectorController;

        // Hide the controlls from the TdrSelector that are not needed for the defaults
        this.tdrSelectorController.setHideForTargets(true);

        // Depending on the page that this is for hide the TDR selection.
        // Get reference to current page
        PageReference currentPage = ApexPages.currentPage();
        if (currentPage.getParameters().containskey('targetType')) {
            this.targetType = currentPage.getParameters().get('targetType');
            this.tdrSelectorController.pageBlockTitle = 'Set Targets for Sales Reps';
            if (this.targetType.equals('DEFAULT')) {
                this.tdrSelectorController.pageBlockTitle = 'Set Default for Sales Reps';
                this.tdrSelectorController.setHideForDefaultTargets(true);
            }
        }
        else {
            this.tdrSelectorController.redirectHome('0');
        }
    }

    /**
     *  Submit the targets
     */
    public PageReference submitTargets() {

        System.debug(LoggingLevel.DEBUG, 'Setting Targets');

        String[] paramsResult = this.tdrSelectorController.getTdrParameters();
        if (paramsResult.get(0).equals('0')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, paramsResult.get(1)));
            return null;
        }

        this.tdrSelectorController.addParameter('targetType', Apexpages.currentPage().getParameters().get('typeParam'));

        Map<String, String> newTargets = new Map<String, String>();
        newTargets.put('Corporate_Sales_Calls', Apexpages.currentPage().getParameters().get('corporateSalesCallParam'));
        newTargets.put('MM_Agent_Full_Report', Apexpages.currentPage().getParameters().get('mmLongParam'));
        newTargets.put('MM_Agent_Short_Report', Apexpages.currentPage().getParameters().get('mmShortParam'));
        newTargets.put('School_Sales_Calls', Apexpages.currentPage().getParameters().get('schoolSalesCallParam'));

        // Decide upon the type of target to update
        String errorMsg = '';
        if (Apexpages.currentPage().getParameters().get('typeParam').equals('TDR')) {
            try {
                errorMsg = TdrHelpers.updateTdrPerformanceTarget(this.tdrSelectorController.getParameters(), newTargets);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. Please try again. If the issue persists contact support'));
                errorMsg = 'Internal error has caused Sales Reps target setting to fail';
            }
        }
        else if (Apexpages.currentPage().getParameters().get('typeParam').equals('DEFAULT')) {
            try {
                errorMsg = TdrHelpers.updateDefaultTdrPerformance(this.tdrSelectorController.getParameters(), newTargets);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. Please try again. If the issue persists contact support'));
                errorMsg = 'Internal error has cause default target setting to fail';
            }
        }
        else {

            // Should never get here. If we have it is the devs fault not the user
            errorMsg = 'Method for updating targets does not exist. Please try another one';
        }
        if (!errorMsg.equals('Success')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have added the targets successfully'));
        }

        System.debug('Finished Setting Targets');
        return null;
    }

    public PageReference redirectToLanding() {
        return this.tdrSelectorController.redirectHome('');
    }

    static testMethod void testController() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);
        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        PageReference pageRef = Page.TdrDefaultTargets;
        pageRef.getParameters().put('targetType', 'DEFAULT');
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('corporateSalesCallParam', '2.0');
        ApexPages.currentPage().getParameters().put('mmLongParam', '2.0');
        ApexPages.currentPage().getParameters().put('mmShortParam', '2.0');
        ApexPages.currentPage().getParameters().put('schoolSalesCallParam', '2.0');
        ApexPages.currentPage().getParameters().put('yearParam', '2011');
        ApexPages.currentPage().getParameters().put('countryParam', (String)country.Id);
        ApexPages.currentPage().getParameters().put('regionParam', (String)region.Id);
        ApexPages.currentPage().getParameters().put('tdrParam', '');
        ApexPages.currentPage().getParameters().put('monthParam', '');
        ApexPages.currentPage().getParameters().put('weeklyRangeStartParam', '');
        ApexPages.currentPage().getParameters().put('weeklyRangeEndParam', '');
        ApexPages.currentPage().getParameters().put('showWeeklyParam', '');

        TdrDefaultsController controller = new TdrDefaultsController(new TdrSelectorController());

        ApexPages.currentPage().getParameters().put('typeParam', 'DEFAULT');
        controller.submitTargets();
        ApexPages.currentPage().getParameters().put('typeParam', 'TDR');
        controller.submitTargets();
        ApexPages.currentPage().getParameters().put('typeParam', 'NONE');
        controller.submitTargets();
        controller.redirectToLanding();
    }
}