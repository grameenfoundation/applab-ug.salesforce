/**
 *  A test class for OpportunityAcreageMappingController
 */
@isTest
public with sharing class TestOpportunityAcreageMappingController {

    /**
     *  Test method for the opportunityAcreageMappingController
     */
    private static TestMethod void testOpportunityAcreageMappingController() {

        // Create a test opportunityFarmerSelector controller 
        OpportunityAcreageMappingController opportunityAcreageMappingController = new OpportunityAcreageMappingController();
        opportunityAcreageMappingController.setDashboardName('Opp');
        opportunityAcreageMappingController.setSections(opportunityAcreageMappingController.loadSections());

        // Test success
        System.assertEquals(opportunityAcreageMappingController.getDashboardName(), 'Opp');

        // Test failure
        System.assertNotEquals(opportunityAcreageMappingController.getDashboardName(), 'Oppt');
    }
}