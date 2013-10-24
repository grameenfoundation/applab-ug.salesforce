public with sharing class TestFarmerLandMapPolygon {

    /**
     *  Test method for the FarmerLandMapPolygon class
     */ 
    private static TestMethod void testFarmerLandMapPolygon() {

        // Create test coodinates
        Coordinates testFarmCoord = new Coordinates();
        testFarmCoord.Latitude = 2.0;
        testFarmCoord.Longitude = 32.0;

        FarmerLandMapPolygon landPolygon = new FarmerLandMapPolygon(testFarmCoord);   

        // Test success
        System.assertEquals(landPolygon.getLatitude(), '2.0');
        System.assertEquals(landPolygon.getLongitude(), '32.0');

        // Test failure
        System.assertNotEquals(landPolygon.getLatitude(), '1.0');
        System.assertNotEquals(landPolygon.getLongitude(), '31.0');
    }
}