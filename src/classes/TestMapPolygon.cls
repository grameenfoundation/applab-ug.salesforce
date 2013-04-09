/**
 *  A test class for MapPolygon
 */
@isTest
public with sharing class TestMapPolygon {

    /**
     *  Test method for the MapPolygon class
     */
    private static TestMethod void testPolygon() {

        // Create test polygon vertice
        MapPolygon polygon = new MapPolygon();
        polygon.setLatitude('2.2');
        polygon.setLongitude('32.0');

        // Test success
        System.assertEquals(polygon.getLatitude(), '2.2');
        System.assertEquals(polygon.getLongitude(), '32.0');

        // Test failure
        System.assertNotEquals(polygon.getLatitude(), '31.0');
        System.assertNotEquals(polygon.getLongitude(), '2.3');
    }
}