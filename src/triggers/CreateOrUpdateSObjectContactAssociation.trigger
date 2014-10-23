trigger CreateOrUpdateSObjectContactAssociation on CPA_Order__c (after insert) {

    // Create a map of contact and a list of orders created by that contact
    Map<String, List<String>> contactOrders = new Map<String, List<String>>();
    for (CPA_Order__c order : trigger.new) {
        List<String> orders = contactOrders.get(order.Contact__c);
        if (orders == null) {
            orders = new List<String>();
        }
        orders.add(order.Id);
        contactOrders.put(order.Contact__c, orders);
    }

    // Get a list of all Alsur contacts who need to share data
    List<Association_Contact_Association__c> alsurContacts = [Select Contact__c 
                                                                from Association_Contact_Association__c 
                                                            where 
                                                                Association_Name__c ='ALSUR MAIN'];

    Set<String> alsurContactIds = new Set<String>();
    for (Association_Contact_Association__c alsurContact : alsurContacts) {
        alsurContactIds.add(alsurContact.contact__c);
    }

    // Get a list of the SObjectContactAssociations for the CPA Order object if any exist
    gfsurveys__SObjectContactAssociation__c[] records = [Select Id, gfsurveys__AssociatedIds__c, 
                                                                    gfsurveys__SObjectApiName__c,
                                                                    gfsurveys__Contact__c, 
                                                                    gfsurveys__NumberOfRecords__c 
                                                      FROM gfsurveys__SObjectContactAssociation__c 
                                                      WHERE gfsurveys__SObjectApiName__c = 'CPA_Order__c'];

    // A map of Contact and an SObjectContactAssociation
    Map<String, gfsurveys__SObjectContactAssociation__c> contactSocaMap = new Map<String, gfsurveys__SObjectContactAssociation__c>();
    if (records.size() > 0) {
        for (gfsurveys__SObjectContactAssociation__c record : records) {
            contactSocaMap.put(record.gfsurveys__Contact__c, record);
        }  
    }
    for (String contactId : contactOrders.keyset()) {
        List<String> orders = contactOrders.get(contactId);

        // Check if this is an Alsur Contact, if so, we need all the other Alsur contacts to get this order
        // If this is not an Alsur contact, just create/update the SObjectContactAssociation for only this contact 
        if (alsurContactIds.contains(contactId)) {
            for (String alsurContactId : alsurContactIds) {
                gfsurveys__SObjectContactAssociation__c soca = contactSocaMap.get(alsurContactId);
                if (null == soca) {
                    soca = new gfsurveys__SObjectContactAssociation__c();
                    soca.gfsurveys__AssociatedIds__c = String.join(orders, ',');
                    soca.gfsurveys__SObjectApiName__c = 'CPA_Order__c';
                    soca.gfsurveys__Contact__c = alsurContactId;
                    soca.gfsurveys__NumberOfRecords__c = orders.size();
                }
                else {
                    soca.gfsurveys__AssociatedIds__c = soca.gfsurveys__AssociatedIds__c + ',' + String.join(orders, ',');
                    soca.gfsurveys__NumberOfRecords__c += orders.size();
                }
                contactSocaMap.put(alsurContactId, soca);
            }
        }
        else {
            gfsurveys__SObjectContactAssociation__c soca = contactSocaMap.get(contactId);
            if (null == soca) {
                soca = new gfsurveys__SObjectContactAssociation__c();
                soca.gfsurveys__AssociatedIds__c = String.join(orders, ',');
                soca.gfsurveys__SObjectApiName__c = 'CPA_Order__c';
                soca.gfsurveys__Contact__c = contactId;
                soca.gfsurveys__NumberOfRecords__c = orders.size();
                contactSocaMap.put(contactId, soca);
            }
            else {
                soca.gfsurveys__AssociatedIds__c = soca.gfsurveys__AssociatedIds__c + ',' + String.join(orders, ',');
                soca.gfsurveys__NumberOfRecords__c += orders.size();
                contactSocaMap.put(contactId, soca);
            }
        }
    }
    upsert contactSocaMap.values();
}