@isTest
private class TestAlsurCreateFarmerProdDeliverytrigger {
	
	@isTest 
	static void test_method_one() {
	
		Association__c association = new Association__c();
		association.Name = 'Alsur';
		insert association;

		Contact contact = new Contact();
		contact.LastName = 'testAlsurCreateProductDelivery';
		contact.FirstName = 'Contact';
		insert contact;

		Alsur_Farmer__c farmer = new Alsur_Farmer__c();
		farmer.Association__c = association.Id;
		insert farmer;

		CPA_Order__c order = new CPA_Order__c();
		order.Number_of_Units_of_Presentation__c = 10;
		order.Contact__c = contact.Id;
		insert order;

		CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
		allocation.Association__c = association.Id;
		allocation.CPA_Order__c = order.Id;
		allocation.Number_of_Units_of_Presentation__c = 10;
		insert allocation;
		
		Farmer_Order_Allocation__c farmerAllocation = new Farmer_Order_Allocation__c();
		farmerAllocation.Alsur_Farmer__c = farmer.Id;
		farmerAllocation.CPA_Order_Allocation__c = allocation.Id;
		farmerAllocation.Delivery_Date__c = System.today();
		farmerAllocation.Number_of_Units_of_Presentation__c = 3;
		farmerAllocation.Provider__c = 'No';
		insert farmerAllocation;

		Farmer_Product_Delivery__c farmerProductDelivery = new Farmer_Product_Delivery__c();
		farmerProductDelivery.Farmer_Order_Allocation__c = farmerAllocation.Id;
		farmerProductDelivery.TypeOfDelivery__c = 'Productor - entrega IGUAL a asignación';
		farmerProductDelivery.Number_of_Units_of_Presentation__c = 5;
		insert farmerProductDelivery;

		Farmer_Product_Delivery__c farmerProductDelivery2= new Farmer_Product_Delivery__c();
		farmerProductDelivery2.Farmer_Order_Allocation__c = farmerAllocation.Id;
		farmerProductDelivery2.TypeOfDelivery__c = 'Productor-entrega DIFERENTE a asignación';
		farmerProductDelivery2.Number_of_Units_of_Presentation__c = 5;
		insert farmerProductDelivery2;

		List<Farmer_Product_Delivery__c> deliveries = [SELECT Id, Farmer_Order_Allocation__c, TypeOfDelivery__c from Farmer_Product_Delivery__c where TypeOfDelivery__c = 'Productor - entrega IGUAL a asignación'];
		System.assertEquals(1, deliveries.size());

	}
		
}