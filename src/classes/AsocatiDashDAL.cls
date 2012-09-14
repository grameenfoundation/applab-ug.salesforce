/**
	Data Access Layer class for AsocatiDashboard.page
*/

public with sharing class AsocatiDashDAL {

	public static List<M_E_Metric_Data__c> getProductionMetrics(){
	
		    M_E_Metric_Data__c[] productionMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('total_Prod_Hectare','prod_Plants_Hectare','total_Month_Prod')
            
           
        ];
    
        return productionMetrics;
		
	}
	
	public static List<M_E_Metric_Data__c> getQualityMetrics(){
	
		    M_E_Metric_Data__c[] qualityMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('average_Premium_Grain_Produced')
            
           
        ];
    
        return qualityMetrics;
		
	}
	
	public static List<M_E_Metric_Data__c> getCommercializationMetrics(){
	
		    M_E_Metric_Data__c[] commercializationMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('prod_Sold_Asocati','certified_Kilos_Sold_By_Asocati','exported_Vs_National')
            
           
        ];
    
        return commercializationMetrics;
		
	}
	
	public static List<M_E_Metric_Data__c> getCertificationMetrics(){
	
		    M_E_Metric_Data__c[] certificationMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('cocoa_Practices','certified_Producers','producers_Being_Certified','price_Differences')
            
           
        ];
    
        return certificationMetrics;
		
	}
	
	public static List<M_E_Metric_Data__c> getSocialMetrics(){
	
		    M_E_Metric_Data__c[] socialMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('number_Beneficiaries','number_Associates','number_Mobile_Sys_Users',
                						'number_Users_Registered','percentage_Active_Users','insertTotalReached','VulnerableFarmersReached',
                						'FemaleFarmersReached','EthnicMinorityReached','insertDisplacedReached','CKW_PerformanceData'
                						)
            
           
        ];
    
        return socialMetrics;
		
	}
	
	
	public static List<M_E_Metric_Data__c> getFinancialMetrics(){
	
		    M_E_Metric_Data__c[] financialMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c,
                Manual_Value__c,
                Numerator__c    
                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('financial_Access','mobile_Money')            
           
        ];
    
        return financialMetrics;
		
	}
	
	
		LAC_Farmer_Details__c getLacFarmer(Person__c interviewee){
		
		LAC_Farmer_Details__c[] farmer =  [
            SELECT
            	Person__c                       
            FROM
                LAC_Farmer_Details__c               
       //     WHERE
         //       LAC_Farmer_Details__c.Person__r.Id = farmer
             LIMIT 1
                
        ];
        
        if(farmer.size()>0)
        	return farmer[0];
        else
        	return null;
		
	}
	
	LAC_Farmer_Details__c getLacFarmer(String id){
		
		LAC_Farmer_Details__c[] farmer =  [
            SELECT
            	Person__c                       
            FROM
                LAC_Farmer_Details__c               
       //     WHERE
         //       LAC_Farmer_Details__c.Person__r.Id = id
             LIMIT 1
                
        ];
        
        if(farmer.size()>0)
        	return farmer[0];
        else
        	return null;
	
	}
	
	public static void insertMetric(M_E_Metric__c metric){
		//TODO:Improve this by checking exceptions thrown (if any)
		Database.insert(metric);
	}
	
	public static void insertMetric(M_E_Metric_Data__c metric){
		//TODO:Improve this by checking exceptions thrown (if any)
		Database.insert(metric);
	}
	
	/**
	TEST METHODS
	*/
	
	public static void testDeleteMetrics()
	{
		M_E_Metric_Data__c[] productionMetrics = [
            SELECT
            	M_E_Metric__r.Label__c,
            	Projected_Value__c,
                Actual_Value__c
                       
            FROM
                M_E_Metric_Data__c               
             WHERE
                M_E_Metric__r.Name IN ('total_Prod_Hectare','prod_Plants_Hectare','total_Month_Prod',
                						'average_Premium_Grain_Produced',
                						'prod_Sold_Asocati','certified_Kilos_Sold_By_Asocati','exported_Vs_National',
                						'cocoa_Practices','certified_Producers','producers_Being_Certified','price_Differences',
                						'number_Beneficiaries','number_Associates','number_Mobile_Sys_Users',
                						'number_Users_Registered','percentage_Active_Users','CKW_PerformanceData',
                						'insertTotalReached','VulnerableFarmersReached',
                						'FemaleFarmersReached','EthnicMinorityReached','insertDisplacedReached',
                						'financial_Access','mobile_Money')
        ];
		
		Database.delete(productionMetrics,false);
		
	}
	
	
	public static LAC_Farmer_Details__c[] getTestLacFarmer()
	{
		LAC_Farmer_Details__c[] farmer =  [
            SELECT
            	Person__c                       
            FROM
                LAC_Farmer_Details__c               
             WHERE
                LAC_Farmer_Details__c.Person__r.First_Name__c  = 'Pepito' AND
                LAC_Farmer_Details__c.Person__r.Last_Name__c = 'Perez'
        ];
        
        return farmer;
		
	}
	
	public static LAC_Farmer_Details__c testCreateLacFarmer(){
	
		//TODO: Check why this is not working anymore...
		Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'Pepito';
        testPerson.Last_Name__c = 'Perez';
        testPerson.Gender__c = 'Male';
        Database.insert(testPerson);

        LAC_Farmer_Details__c testFarmer = new LAC_Farmer_Details__c();
        testFarmer.Person__c = testPerson.Id;
        Database.insert(testFarmer);
			
		return testFarmer;
	}
	
	public static void testDeleteFarmer(){
		
		
		LAC_Farmer_Details__c[] farmer = getTestLacFarmer();
				
		Database.delete(farmer,false);
	}
	


}