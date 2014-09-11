trigger AlsurCreateFarmerProductDeliveryForProviderOrders on Farmer_Order_Allocation__c (
	after insert, 
	after update) {
		Map<Id, Farmer_Order_Allocation__c> itemsMap = new Map<Id, Farmer_Order_Allocation__c>(); // Used for comparing old items to new ones
		Set<Id> allocationsWithExistingDeliveries = new Set<Id>();
		List<Farmer_Product_Delivery__c> deliveriesToInsert = new List<Farmer_Product_Delivery__c>();

		if (Trigger.isUpdate) {
			// put the old items in a map to ease comparison with new values
	        for (Farmer_Order_Allocation__c item : Trigger.old) {
	            itemsMap.put(item.Id, item);
	        }

	        // Fill allocationsWithExistingDeliveries
	        List<Id> idsInTrigger = new List<Id>();
	        for (Farmer_Order_Allocation__c item : Trigger.new) {
	            idsInTrigger.add(item.Id);
	        }
	        
	        for (Farmer_Product_Delivery__c[] items : [Select Farmer_Order_Allocation__c from Farmer_Product_Delivery__c where Farmer_Order_Allocation__c IN: idsInTrigger]) {
	        	for (Farmer_Product_Delivery__c item : items) {
	        		allocationsWithExistingDeliveries.add(item.Farmer_Order_Allocation__c);
	        	}
	        }
		}

		for (Farmer_Order_Allocation__c newItem : Trigger.new) {
			Boolean createDelivery = False; // Whether or not we should go ahead with the insert of 

			if (newItem.Provider__c == 'Sí') {
				if (Trigger.isUpdate) {
					// Compare old values to new ones and only create a if the Provider field have changed from No to Yes
					if (itemsMap.containsKey(newItem.Id)) {
						Farmer_Order_Allocation__c oldItem = itemsMap.get(newItem.Id);
						if (oldItem.Provider__c != newItem.Provider__c) {
							createDelivery = True;
						}
					}

					// Check if we need to first check for an existing delivery
					if (allocationsWithExistingDeliveries.contains(newItem.Id)) {
						createDelivery = False;
					}
				} else {
					createDelivery = True;
				}

				// If all is good, create the delivery
	            if (createDelivery) {
	            	// If we get here, we can create the delivery
		            Farmer_Product_Delivery__c delivery = new Farmer_Product_Delivery__c();
		            delivery.Number_of_Baskets__c = newItem.Number_of_baskets__c;
		            delivery.Delivery_Date__c = newItem.Delivery_Date__c;
		            if (newItem.Alsur_Farmer__c != null) {
		            	delivery.Farmer_Code__c = newItem.Alsur_Farmer__r.Farmer_Code__c;
		            }
		            delivery.Farmer_Order_Allocation__c = newItem.Id;
		            delivery.Is_Delivery_On_Time__c = 'Sí';
		            delivery.Number_of_Kilos__c = newItem.Number_of_Kilos__c;
		            delivery.Number_of_Units_of_Presentation__c = newItem.Number_of_Units_of_Presentation__c;
		            delivery.Presentacion__c = newItem.Presentacion__c;
		            deliveriesToInsert.add(delivery);
	            }
			}
		
            // If deliveriesToInsert is over 90, we insert and clear it
            if (deliveriesToInsert.size() > 90) {
            	insert deliveriesToInsert;
            	deliveriesToInsert = new List<Farmer_Product_Delivery__c>();
            }
		}

		if (deliveriesToInsert.size() > 0) {
			insert deliveriesToInsert;
		}
}