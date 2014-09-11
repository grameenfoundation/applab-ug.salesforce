@isTest
private class testAlsurCreateProductDeliveryTrigger
{
	@isTest
	static void testDeliveryCreation()
	{
		// Create a Farmer Order Allocation Object (one with Producer = "Si" and the other with Producer = "No")
		Association__c association = new Association__c();
		association.Name = 'Alsur';
		insert association;

		Alsur_Farmer__c farmer = new Alsur_Farmer__c();
		farmer.Association__c = association.Id;
		insert farmer;

		CPA_Order__c order = new CPA_Order__c();
		order.Number_of_Units_of_Presentation__c = 10;
		insert order;

		CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
		allocation.Association__c = association.Id;
		allocation.CPA_Order__c = order.Id;
		allocation.Number_of_Units_of_Presentation__c = 10;
		insert allocation;
		
		Farmer_Order_Allocation__c farmerAllocation1 = new Farmer_Order_Allocation__c();
		farmerAllocation1.Alsur_Farmer__c = farmer.Id;
		farmerAllocation1.CPA_Order_Allocation__c = allocation.Id;
		farmerAllocation1.Delivery_Date__c = System.today();
		farmerAllocation1.Number_of_Units_of_Presentation__c = 5;
		farmerAllocation1.Provider__c = 'Sí';
		insert farmerAllocation1;

		Farmer_Order_Allocation__c farmerAllocation2 = new Farmer_Order_Allocation__c();
		farmerAllocation2.Alsur_Farmer__c = farmer.Id;
		farmerAllocation2.CPA_Order_Allocation__c = allocation.Id;
		farmerAllocation2.Delivery_Date__c = System.today();
		farmerAllocation2.Number_of_Units_of_Presentation__c = 5;
		farmerAllocation2.Provider__c = 'No';
		insert farmerAllocation2;

		// Check that a corresponding Delivery Object is created for the one with Producer = "Si" 
		List<Farmer_Product_Delivery__c> deliveries = [SELECT Id, Farmer_Order_Allocation__c from Farmer_Product_Delivery__c where Farmer_Order_Allocation__c =: farmerAllocation1.Id OR Farmer_Order_Allocation__c =: farmerAllocation2.Id];
		System.assertEquals(1, deliveries.size());
		System.assertEquals(deliveries[0].Farmer_Order_Allocation__c, farmerAllocation1.Id);

		// Now update farmerAllocation2 to Si
		farmerAllocation2.Provider__c = 'Sí';
		update farmerAllocation2;

		// Check that a corresponding Delivery Object is created for the second 1 
		deliveries = [SELECT Id, Farmer_Order_Allocation__c from Farmer_Product_Delivery__c where Farmer_Order_Allocation__c =: farmerAllocation1.Id OR Farmer_Order_Allocation__c =: farmerAllocation2.Id];
		System.assertEquals(deliveries.size(), 2);

		// Update farmerAllocation1
		farmerAllocation1.Number_of_Units_of_Presentation__c = 3;
		update farmerAllocation1;

		// Deliveries are still 2:
		deliveries = [SELECT Id, Farmer_Order_Allocation__c from Farmer_Product_Delivery__c where Farmer_Order_Allocation__c =: farmerAllocation1.Id OR Farmer_Order_Allocation__c =: farmerAllocation2.Id];
		System.assertEquals(deliveries.size(), 2);

		// Insert over 90 records
		List<Farmer_Order_Allocation__c> allocations = new List<Farmer_Order_Allocation__c>();
		for (Integer i = 0; i < 100; i++) {
			Farmer_Order_Allocation__c farmerAllocation = new Farmer_Order_Allocation__c();
			farmerAllocation.Alsur_Farmer__c = farmer.Id;
			farmerAllocation.CPA_Order_Allocation__c = allocation.Id;
			farmerAllocation.Delivery_Date__c = System.today();
			farmerAllocation.Number_of_Units_of_Presentation__c = 5;
			farmerAllocation.Provider__c = 'Sí';
			allocations.add(farmerAllocation);
		}

		insert allocations;

		// Over 102 deliveries
		deliveries = [SELECT Id, Farmer_Order_Allocation__c from Farmer_Product_Delivery__c];
		System.assertEquals(deliveries.size(), 102);
	}
}