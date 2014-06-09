trigger AssignAllocationToAssociationMobileUser on CPA_Order_Allocation__c (after insert) {

	// Map to contain a list of allocations for each association
	Map<String, List<String>> associationOrders = new Map<String, List<String>>();

	// Set of unique associations within this transaction
	Set<String> allocationAssociations = new Set<String>();

	// Populate the map and set
	for (CPA_Order_Allocation__c allocation : trigger.new) {
		allocationAssociations.add(allocation.Association__c);
		List<String> allocations = associationOrders.get(allocation.Association__c);
		if (allocations == null) {
			allocations = new List<String>();
		}
		allocations.add(allocation.Id);
		associationOrders.put(allocation.Association__c, allocations);
	}

	// Get the Contacts for each of the associations in this transaction, these are the contacts 
	// for whom SObjectContactAssociations will be created
	List<Association_Contact_Association__c> associationUsers = [Select Contact__c, Association__c from 
																	Association_Contact_Association__c
																where Association__c in:allocationAssociations];

	// Create and populate a map of Associations and their Contacts (Mobile Users)
	Map<String, List<String>> associationContactsMap = new Map<String, List<String>>();

	// We only want to do this for contacts associated with an association
	if (associationUsers.size() > 0) {
		for (Association_Contact_Association__c associationUser : associationUsers) {
			List<String> associationUserList = associationContactsMap.get(associationUser.Association__c);
			if (associationUserList == null) {
				associationUserList = new List<String>();
			}
			associationUserList.add(associationUser.Contact__c);
			associationContactsMap.put(associationUser.Association__c, associationUserList);
		}

		// Create a set of all the Contacts of the associations in this transaction
		Set<String> allAssociationContactIds = new Set<String>();
		for (List<String> str : associationContactsMap.values()) {
			allAssociationContactIds.addAll(str);
		}

		// Check if any SObjectContactAssociations exist for the above contacts
	    gfsurveys__SObjectContactAssociation__c[] records = [Select Id, gfsurveys__AssociatedIds__c, 
	                                                                    gfsurveys__SObjectApiName__c,
	                                                                    gfsurveys__Contact__c, 
	                                                                    gfsurveys__NumberOfRecords__c 
	                                                      FROM gfsurveys__SObjectContactAssociation__c 
	                                                      WHERE gfsurveys__SObjectApiName__c = 'CPA_Order_Allocation__c'
	                                                      AND gfsurveys__Contact__c in:allAssociationContactIds];
        Map<String, gfsurveys__SObjectContactAssociation__c> contactSocaMap = new Map<String, gfsurveys__SObjectContactAssociation__c>();
        if (records.size() > 0) {
        	for (gfsurveys__SObjectContactAssociation__c record : records) {
        		contactSocaMap.put(record.gfsurveys__Contact__c, record);
        	}
        }

        // Create or update the SObjectContactAssociations for the contacts
        for (String associationId : allocationAssociations) {
        	List<String> orders = associationOrders.get(associationId);
        	List<String> associationContacts = associationContactsMap.get(associationId);
        	if (associationContacts != null) {
        		for (String contactId : associationContacts) {
        			gfsurveys__SObjectContactAssociation__c record = contactSocaMap.get(contactId);
        			if (record == null) {
        				record = new gfsurveys__SObjectContactAssociation__c();
        				record.gfsurveys__Contact__c = contactId;
        				record.gfsurveys__SObjectApiName__c = 'CPA_Order_Allocation__c';
        				record.gfsurveys__AssociatedIds__c = String.join(orders, ',');
        				record.gfsurveys__NumberOfRecords__c = orders.size();
        			}
        			else {
        				record.gfsurveys__AssociatedIds__c = record.gfsurveys__AssociatedIds__c + ',' + String.join(orders, ',');
        				record.gfsurveys__NumberOfRecords__c += orders.size();
        			}
        			contactSocaMap.put(contactId, record);
        		}
        	}
        }
        upsert contactSocaMap.values();
	}
}