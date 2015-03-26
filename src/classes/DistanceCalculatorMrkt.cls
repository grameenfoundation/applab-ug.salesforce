/*
  Class that validates CKW GPS
*/
public with sharing class DistanceCalculatorMrkt {
    public DistanceCalculatorMrkt() {
        
    }
    private static Double EARTH_RADIUS = 6371000.00; // Radius in meters default

    public static Double calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2,   Decimal longitude2){
        Double lat1 = latitude1.doubleValue();
        Double lon1 = longitude1.doubleValue();
        Double lat2 = latitude2.doubleValue();
        Double lon2 = longitude2.doubleValue();
        Double Radius = DistanceCalculatorMrkt.EARTH_RADIUS; //6371.00;
        Double dLat = DistanceCalculatorMrkt.toRadians(lat2-lat1);
        Double dLon = DistanceCalculatorMrkt.toRadians(lon2-lon1);            
        Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +Math.cos(DistanceCalculatorMrkt.toRadians(lat1)) *   Math.cos(DistanceCalculatorMrkt.toRadians(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
        Double c = 2 * Math.asin(Math.sqrt(a));
        Double result=Radius * c;
        system.debug('Distance is '+result);  
        return result;      
    }
    
    public static Double toRadians(Double degree){
       // Value degree * Pi/180
       Double res = degree * 3.1415926 / 180;
       return res;  
    }
}