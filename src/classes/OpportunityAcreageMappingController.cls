/**
 *  Controller to load the settings for the Opportunity Int'l Acreage Mapping Solution
 */
public with sharing class OpportunityAcreageMappingController extends DynamicDashboardBaseController {

    /**
     *  Default Constructor for OpportunityAcreageMappingController
     *  Sets all the DashboardName and Sections associated with the dashboard
     */
    public OpportunityAcreageMappingController() {
        setDashboardName('Opportunity Acreage Mapping Solution');
        setSections(loadSections());
    }
}