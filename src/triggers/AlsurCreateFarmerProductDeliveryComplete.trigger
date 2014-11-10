trigger AlsurCreateFarmerProductDeliveryComplete on Farmer_Product_Delivery__c (
	after insert) {
	List<Farmer_Product_Delivery__c> deliveriesToInsert = new List<Farmer_Product_Delivery__c>();
	for (Farmer_Product_Delivery__c newItem : Trigger.new) {
		if (newItem.TypeOfDelivery__c == 'Productor - entrega IGUAL a asignación') {
	        for(Farmer_Order_Allocation__c foa : [SELECT Number_of_Baskets__c, Delivery_Date__c, Number_of_Kilos__c, Number_of_Units_of_Presentation__c, Presentacion__c FROM Farmer_Order_Allocation__c WHERE Id =:newItem.Farmer_Order_Allocation__c]){ 
			Farmer_Product_Delivery__c delivery = new Farmer_Product_Delivery__c();
			delivery.Number_of_Baskets__c = foa.Number_of_baskets__c;
			delivery.Delivery_Date__c = foa.Delivery_Date__c;
			delivery.Is_Delivery_On_Time__c = 'Sí';
			delivery.Number_of_Kilos__c = foa.Number_of_Kilos__c;
		    delivery.Number_of_Units_of_Presentation__c = foa.Number_of_Units_of_Presentation__c;
		    delivery.Presentacion__c = foa.Presentacion__c;
		    deliveriesToInsert.add(delivery);
		    }
	    }
	}
    if (deliveriesToInsert.size() > 90) {
        insert deliveriesToInsert;
        deliveriesToInsert = new List<Farmer_Product_Delivery__c>();
    }
}