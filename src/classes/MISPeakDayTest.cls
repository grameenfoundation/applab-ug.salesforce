@isTest
private class MISPeakDayTest
{
	
	static testMethod void testValidatePeakDayCorrect() {
       
        C3P0_Market__c c3po=new C3P0_Market__c();
        Date dDate = System.today();
        Datetime dt = (DateTime)dDate;
        String dayOfWeek = dt.format('EEEE'); 
        c3po.Peak__c=dayOfWeek;
              
        system.assertEquals(true,MISPeakDay.applyPeakDayValidation(c3po));        
    }
    
    static testMethod void testValidatePeakDayWrong() {
       
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Peak__c='Thursd';
              
        system.assertEquals(false,MISPeakDay.applyPeakDayValidation(c3po));        
    }

    static testMethod void testValidatePeakDayCorrectBushenyi() {

        Market_Bushenyi__c market=new Market_Bushenyi__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        Date dDate = System.today();
        Datetime dt = (DateTime)dDate;
        String dayOfWeek = dt.format('EEEE');
        c3po.Peak__c=dayOfWeek;
              
        system.assertEquals(true,MISPeakDay.applyPeakDayValidationBushenyi(c3po,market));        
    }

    static testMethod void testValidatePeakDayWrongBushenyi() {
        Market_Bushenyi__c market=new Market_Bushenyi__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Peak__c='Thursd';
              
        system.assertEquals(false,MISPeakDay.applyPeakDayValidationBushenyi(c3po,market));        
    }

    static testMethod void testValidatePeakDayCorrectMasindi() {

        Market_Masindi__c market=new Market_Masindi__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        Date dDate = System.today();
        Datetime dt = (DateTime)dDate;
        String dayOfWeek = dt.format('EEEE');
        c3po.Peak__c=dayOfWeek;
              
        system.assertEquals(true,MISPeakDay.applyPeakDayValidationMasindi(c3po,market));        
    }

    static testMethod void testValidatePeakDayWrongMasindi() {
        Market_Masindi__c market=new Market_Masindi__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Peak__c='Thur';
              
        system.assertEquals(false,MISPeakDay.applyPeakDayValidationMasindi(c3po,market));        
    }

    static testMethod void testValidatePeakDayCorrectKasese() {

        Market_Kasese__c market=new Market_Kasese__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        Date dDate = System.today();
        Datetime dt = (DateTime)dDate;
        String dayOfWeek = dt.format('EEEE');
        c3po.Peak__c=dayOfWeek;
              
        system.assertEquals(true,MISPeakDay.applyPeakDayValidationKasese(c3po,market));        
    }

    static testMethod void testValidatePeakDayWrongKasese() {
        Market_Kasese__c market=new Market_Kasese__c();
        market.Date_of_capture__c=System.today();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Peak__c='Thu';
              
        system.assertEquals(false,MISPeakDay.applyPeakDayValidationKasese(c3po,market));        
    }
}