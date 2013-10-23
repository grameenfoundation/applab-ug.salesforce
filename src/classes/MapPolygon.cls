/**
 *  Virtual class for a map polygon used with google maps.
 *  Any object that wants to be represented as a map polygon must extend this class
 */
public with sharing virtual class MapPolygon {

    /**
     *  Set the latitude for the polygon vertice.
     */
    private String latitude;
    public String getLatitude() {
        return this.latitude;
    }
    public void setLatitude(String value) {
        this.latitude = value;
    }

    /**
     *  Set the longitude for the polygon vertice.
     */
    private String longitude;
    public String getLongitude() {
        return this.longitude;
    }
    public void setLongitude(String value) {
        this.longitude = value;
    }
}