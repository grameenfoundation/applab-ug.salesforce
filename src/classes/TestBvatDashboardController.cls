@isTest
private class TestBvatDashboardController {

    static testMethod void testLoadSections() {
        BvatDashboardController bvat = new BvatDashboardController();
        System.assert(bvat.getDashboardName().equals('BVAT Dashboard'));
        System.assert(bvat.loadSections() != null);
        System.assert(bvat.getCiwMaps() != null);
        System.assert(bvat.getSections() != null);
        
        /**System.assert(bvat.getFarmerMap() != null);
        System.assert(bvat.getCiwMetrics() != null);
        System.assert(bvat.getDistanceMetrics()!= null);
        System.assert(bvat.getSelector()!= null);
        System.assert(bvat.getRegistrationMetrics()!= null);
        System.assert(bvat.getContentMetric()!= null);
        System.assert(bvat.getCategoriesGraph()!= null);
        System.assert(bvat.getEnvironmentGraph()!= null);
        System.assert(bvat.getManagementGraph()!= null);
        System.assert(bvat.getAnimalGraph()!= null);
        System.assert(bvat.getHumanGraph()!= null);
        System.assert(bvat.getOtherGraph()!= null);
        System.assert(bvat.getRegGraphs()!= null);**/
    }
}