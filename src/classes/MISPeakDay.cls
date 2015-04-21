/*
  Class for computing all MIS Peak Day validations
  MISPeakDayTest contains all tests for this class 
*/
public class MISPeakDay {
    
    public MISPeakDay() {
        
    }
    private static boolean  status=false;
    
    public static boolean applyPeakDayValidation(C3P0_Market__c c) {
        Date dateNow = System.today();
		Datetime dt = (DateTime)dateNow;
		String dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
                     
        //Compare peak Days
        if(c.Peak__c.equalsIgnoreCase(dayOfWeek)){
            System.debug('Peak Day Correct ');
            MISPeakDay.status=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Peak Day Wrong ');
            }		
        return MISPeakDay.status;
    }
}