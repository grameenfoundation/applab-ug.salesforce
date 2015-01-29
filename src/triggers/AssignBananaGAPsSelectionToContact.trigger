trigger AssignBananaGAPsSelectionToContact on Banana_Farmer_GAPs_Selection__c (after insert) {
List<Banana_Farmer_GAPs_Selection__c> bananaFarmerGAPs = trigger.new;
    
    // A set to contain all the unique contacts referenced by all the farmer objects
    Set<String> contactIds = new Set<String>();
    
    // A map to link each contact above with a list of the farmer objects he's linked to
    Map<String, List<String>> farmerGapsByContact = new Map<String, List<String>>();
    
    for (Banana_Farmer_GAPs_Selection__c bananaFarmerGAP : bananaFarmerGAPs) {
        contactIds.add(bananaFarmerGAP.CKW_Contact__c);
        
        // Check whether the contact for the current farmer already has an entry
        // in the farmerGapsByContact map
        List<String> contactFarmers = farmerGapsByContact.get(bananaFarmerGAP.CKW_Contact__c);
        if (contactFarmers == null) {
            contactFarmers = new List<String>();
        }
        contactFarmers.add(bananaFarmerGAP.Id);
        farmerGapsByContact.put(bananaFarmerGAP.CKW_Contact__c, contactFarmers);
    }
    
    // Get all the sObjectContactAssociation records for the contacts
    List<gfsurveys__SObjectContactAssociation__c> socas =  [Select Id, gfsurveys__AssociatedIds__c, 
                                                                      gfsurveys__SObjectApiName__c,
                                                                      gfsurveys__Contact__c, 
                                                                      gfsurveys__NumberOfRecords__c 
                                                        FROM gfsurveys__SObjectContactAssociation__c 
                                                        WHERE gfsurveys__SObjectApiName__c = 'Banana_Farmer_GAPs_Selection__c'
                                                        AND gfsurveys__Contact__c in:contactIds];
                                                        
    // Create a map of the sObjectContactAssociations with Contact__c as the Id
    Map<String, gfsurveys__SObjectContactAssociation__c> contactSocaMap = new Map<String, gfsurveys__SObjectContactAssociation__c>();
    if (socas.size() > 0) {
        for (gfsurveys__SObjectContactAssociation__c soca : socas) {
            contactSocaMap.put(soca.gfsurveys__Contact__c, soca);
        }
    }
    
    // Iterate thru the farmerGapsByContact map, to create or update a soca with the banana farmer gaps ids for each contact
    for (String contactId : farmerGapsByContact.keyset()) {
        List<String> bananaFarmerGAPsIds = farmerGapsByContact.get(contactId);
        gfsurveys__SObjectContactAssociation__c soca = contactSocaMap.get(contactId);
        if (soca == null) {
            soca = new gfsurveys__SObjectContactAssociation__c();
            soca.gfsurveys__SObjectApiName__c = 'Banana_Farmer_GAPs_Selection__c';
            soca.gfsurveys__AssociatedIds__c = String.join(bananaFarmerGAPsIds, ',');
            soca.gfsurveys__Contact__c = contactId;
            soca.gfsurveys__NumberOfRecords__c = bananaFarmerGAPsIds.size();
        }
        else {
            soca.gfsurveys__AssociatedIds__c = soca.gfsurveys__AssociatedIds__c + ',' + String.join(bananaFarmerGAPsIds, ',');
            soca.gfsurveys__NumberOfRecords__c += bananaFarmerGAPsIds.size();
        }
        contactSocaMap.put(contactId, soca);
    }
    upsert contactSocaMap.values();
}