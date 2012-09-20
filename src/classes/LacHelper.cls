//This is the class for the post-processing of the information given by GF

public with sharing class LacHelper {
	
	/*
	METRICS FOR CERTIFICATION 
	*/
	
	public static void insertPriceDifferences(Decimal answer, Decimal projectedValue){
		
		M_E_Metric__c priceDifferences = new M_E_Metric__c();
        priceDifferences.Name = 'price_Differences';
        priceDifferences.Label__c = 'Diferencia de precios entre cultivos certificados y no certificados';
        priceDifferences.M_E_Area__c = 'Certification';
        //What does this mean?
        priceDifferences.Order__c = 4;
        //Trimestral value should be added to this picklist
        priceDifferences.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(priceDifferences);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c priceDifferencesData = new M_E_Metric_Data__c();
        
        priceDifferencesData.M_E_Metric__c = priceDifferences.Id;
        priceDifferencesData.Actual_Value__c = answer;
        //This will be defined manually
        priceDifferencesData.Projected_Value__c = projectedValue;
        
          //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        priceDifferencesData.Manual_Value__c = 1.1;
        //Used for variacion column
        priceDifferencesData.Numerator__c = 10;
        
        
        AsocatiDashDAL.insertMetric(priceDifferencesData);	
		
	}
	
	
	/*
	METRICS FOR SOCIAL INCLUSION AND QUALITY OF LIFE
	*/
	public static void insertNumberMobileSysUsers(Integer answer, Integer projectedValue){
		
		M_E_Metric__c numberMobileSysUsers = new M_E_Metric__c();
        numberMobileSysUsers.Name = 'number_Mobile_Sys_Users';
        numberMobileSysUsers.Label__c = 'Número de usuarios del sistema movil que estan asociados';
        numberMobileSysUsers.M_E_Area__c = 'Social';
        //What does this mean?
        numberMobileSysUsers.Order__c = 4;
        //Trimestral value should be added to this picklist
        numberMobileSysUsers.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(numberMobileSysUsers);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c numberMobileSysUsersData = new M_E_Metric_Data__c();
        
        numberMobileSysUsersData.M_E_Metric__c = numberMobileSysUsers.Id;
        //This has to be replaced for the value gathered from the survey
        numberMobileSysUsersData.Actual_Value__c = answer;
        //This will be defined manually
        numberMobileSysUsersData.Projected_Value__c = projectedValue;
        
        
        
        AsocatiDashDAL.insertMetric(numberMobileSysUsersData);	
		
	}
	
	

}