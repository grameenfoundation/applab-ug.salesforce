trigger AlsurCreateFarmerProductDeliveryComplete on Farmer_Product_Delivery__c (before insert) {
	for (Farmer_Product_Delivery__c newItem : Trigger.new) {
		if (newItem.TypeOfDelivery__c == 'Productor - entrega IGUAL a asignación') {
			for(Farmer_Order_Allocation__c foa : [SELECT Number_of_Baskets__c, Delivery_Date__c, Number_of_Kilos__c, Number_of_Units_of_Presentation__c, Presentacion__c FROM Farmer_Order_Allocation__c WHERE Id =:newItem.Farmer_Order_Allocation__c]){ 
				newItem.Number_of_Baskets__c = foa.Number_of_baskets__c;
				newItem.Delivery_Date__c = foa.Delivery_Date__c;
				newItem.Is_Delivery_On_Time__c = 'Sí';
				newItem.Number_of_Kilos__c = foa.Number_of_Kilos__c;
				newItem.Number_of_Units_of_Presentation__c = foa.Number_of_Units_of_Presentation__c;
				newItem.Presentacion__c = foa.Presentacion__c;
			}
		}
	}
}