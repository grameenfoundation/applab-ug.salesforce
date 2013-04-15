/**
 *  A test class for OpportunityFarmerSelectorController
 */
@isTest
public with sharing class TestOpportunityFarmerSelectorController {

    /**
     *  Test method for the opportunityFarmerSelectorController
     */
    private static TestMethod void testOpportunityFarmerSelectorController() {

        // Create a test opportunityFarmerSelector controller 
        OpportunityFarmerSelectorController opportunityFarmerSelectorController = new OpportunityFarmerSelectorController();

        // Populate The OpportunityFarmerSelector
        opportunityFarmerSelectorController.setOpportunityFarmers(opportunityFarmerSelectorController.loadOpportunityFarmers());
        opportunityFarmerSelectorController.getOpportunityFarmers();
        opportunityFarmerSelectorController.refreshData();
        opportunityFarmerSelectorController.getValues();
        opportunityFarmerSelectorController.getActionFunctionName();

        // Test Success
        opportunityFarmerSelectorController.setOpportunityFarmer('dat3718');
        String result = opportunityFarmerSelectorController.getOpportunityFarmer();
        System.assert(result.equals('dat3718'));

        // Test Failure
        opportunityFarmerSelectorController.setOpportunityFarmer('dbt3718');
        result = opportunityFarmerSelectorController.getOpportunityFarmer();
        System.assertNotEquals(result, 'dat3718');
    }
}