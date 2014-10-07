@isTest
private class testAlsurOrderAssignment{
	static void validateAlsurOrderAssignment(){

 		List<CPA_Order_Allocation__c> cpaorders = new List<CPA_Order_Allocation__c>{};
    			for(Integer i = 0; i < 200; i++){
        		CPA_Order_Allocation__c a = new CPA_Order_Allocation__c(Number_of_Units_of_Presentation__c = 100 + i);
        		cpaorders.add(a);
    			}
	
    // Start the test, this changes governor limit context to
    // that of trigger rather than test.

    		test.startTest();

    // Insert the Account records that cause the trigger to execute.

    		insert cpaorders;

    // Stop the test, this changes limit context back to test from trigger.

    		test.stopTest();

    // Query the database for the newly inserted records.

    		List<CPA_Order_Allocation__c> insertedcpaorders = [SELECT Number_of_Units_of_Presentation__c FROM CPA_Order_Allocation__c WHERE Id IN :cpaorders];

    // Assert that the Description fields contains the proper value now.

    			for(CPA_Order_Allocation__c a : insertedcpaorders){

      			System.assertEquals(100, a.Number_of_Units_of_Presentation__c);
  	}
}
}