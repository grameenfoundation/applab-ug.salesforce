/**
 *  Class to generate map polygon for the FarmerLand__c sObject.
 *  Extends MapPolygon
 */
public with sharing class FarmerLandMapPolygon extends MapPolygon {

    /**
     *  Set Polygon vertice content
     *
     *  @param farmCoords - a single Coordinate of the farmland (vertice)
     */
    public FarmerLandMapPolygon(Coordinates farmCoords) {
        this.setLatitude(String.valueOf(farmCoords.Latitude));
        this.setLongitude(String.valueof(farmCoords.Longitude));
    }
}