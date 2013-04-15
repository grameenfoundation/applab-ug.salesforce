/**
 *  Class to generate map polygon for the FarmerLand__c sObject.
 *  Extends MapPolygon
 */
public with sharing class FarmerLandMapPolygon extends MapPolygon {

    /**
     *  Coordinates of one farmLand vertice
     */
    private Coordinates farmCoords;

    /**
     *  Set Polygon vertice content
     *
     *  @param farmCoords - a single Coordinate of the farmland (vertice)
     */
    public FarmerLandMapPolygon(Coordinates farmCoords) {
        this.farmCoords = farmCoords;
        this.setLatitude(String.valueOf(farmCoords.Latitude));
        this.setLongitude(String.valueof(farmCoords.Longitude));
    }
}