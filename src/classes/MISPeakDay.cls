/*
  Class for computing all MIS Peak Day validations
  MISPeakDayTest contains all tests for this class 
*/
public class MISPeakDay {
    
    public MISPeakDay() {
        
    }
    private static boolean  status=false;
    
    public static boolean applyPeakDayValidation(C3P0_Market__c c3p0) {
        Date dateNow = System.today();
        Datetime dt = (DateTime)dateNow;
        String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
                     
        //Compare peak Days
        if(c3p0.Peak__c.equalsIgnoreCase(dayOfWeek)){
            System.debug('Peak Day Correct ');
            MISPeakDay.status=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Peak Day Wrong ');
            }		
        return MISPeakDay.status;
    }
    
    public static boolean applyPeakDayValidationBushenyi(C3P0_Market__c c3p0, Market_Bushenyi__c market) {

        Date capture= market.Date_of_capture__c;
        Datetime dt = (DateTime)capture;
        String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
                     
        //Compare peak Days
        if(c3p0.Peak__c.equalsIgnoreCase(dayOfWeek)){
            System.debug('Peak Day Correct ');
            MISPeakDay.status=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Peak Day Wrong ');
            }       
        return MISPeakDay.status;
    }
    
    public static boolean applyPeakDayValidationMasindi(C3P0_Market__c c3p0, Market_Masindi__c market) {

        Date capture= market.Date_of_capture__c;
        //Date dateNow = System.today();
        Datetime dt = (DateTime)capture;
        String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
                     
        //Compare peak Days
        if(c3p0.Peak__c.equalsIgnoreCase(dayOfWeek)){
            System.debug('Peak Day Correct ');
            MISPeakDay.status=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Peak Day Wrong ');
            }       
        return MISPeakDay.status;
    }

    public static boolean applyPeakDayValidationKasese(C3P0_Market__c c3p0, Market_Kasese__c market) {

        Date capture= market.Date_of_capture__c;
        //Date dateNow = System.today();
        Datetime dt = (DateTime)capture;
        String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
                     
        //Compare peak Days
        if(c3p0.Peak__c.equalsIgnoreCase(dayOfWeek)){
            System.debug('Peak Day Correct ');
            MISPeakDay.status=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Peak Day Wrong ');
            }       
        return MISPeakDay.status;
    }

}