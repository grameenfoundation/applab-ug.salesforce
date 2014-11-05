trigger AssignCoffeeFarmersToContact  on Coffee_Farmer__c (after insert) {
    List<Coffee_Farmer__c> coffeeFarmers = trigger.new;
    
    // A set to contain all the unique contacts referenced by all the farmer objects
    Set<String> contactIds = new Set<String>();
    
    // A map to link each contact above with a list of the farmer objects he's linked to
    Map<String, List<String>> farmersByContact = new Map<String, List<String>>();
    
    for (Coffee_Farmer__c coffeeFarmer : coffeeFarmers) {
        contactIds.add(coffeeFarmer.Registered_By__c);
        
        // Check whether the contact for the current farmer already has an entry
        // in the farmersByContact map
        List<String> contactFarmers = farmersByContact.get(coffeeFarmer.Registered_By__c);
        if (contactFarmers == null) {
            contactFarmers = new List<String>();
        }
        contactFarmers.add(coffeeFarmer.Id);
        farmersByContact.put(coffeeFarmer.Registered_By__c, contactFarmers);
    }
    
    // Get all the sObjectContactAssociation records for the contacts
    List<gfsurveys__SObjectContactAssociation__c> socas =  [Select Id, gfsurveys__AssociatedIds__c, 
                                                                      gfsurveys__SObjectApiName__c,
                                                                      gfsurveys__Contact__c, 
                                                                      gfsurveys__NumberOfRecords__c 
                                                        FROM gfsurveys__SObjectContactAssociation__c 
                                                        WHERE gfsurveys__SObjectApiName__c = 'Coffee_Farmer__c'
                                                        AND gfsurveys__Contact__c in:contactIds];
                                                        
    // Create a map of the sObjectContactAssociations with Contact__c as the Id
    Map<String, gfsurveys__SObjectContactAssociation__c> contactSocaMap = new Map<String, gfsurveys__SObjectContactAssociation__c>();
    if (socas.size() > 0) {
        for (gfsurveys__SObjectContactAssociation__c soca : socas) {
            contactSocaMap.put(soca.gfsurveys__Contact__c, soca);
        }
    }
    
    // Iterate thru the farmersByContact map, to create or update a soca with the coffee farmer ids for each contact
    for (String contactId : farmersByContact.keyset()) {
        List<String> coffeeFarmerIds = farmersByContact.get(contactId);
        gfsurveys__SObjectContactAssociation__c soca = contactSocaMap.get(contactId);
        if (soca == null) {
            soca = new gfsurveys__SObjectContactAssociation__c();
            soca.gfsurveys__SObjectApiName__c = 'Coffee_Farmer__c';
            soca.gfsurveys__AssociatedIds__c = String.join(coffeeFarmerIds, ',');
            soca.gfsurveys__Contact__c = contactId;
            soca.gfsurveys__NumberOfRecords__c = coffeeFarmerIds.size();
        }
        else {
            soca.gfsurveys__AssociatedIds__c = soca.gfsurveys__AssociatedIds__c + ',' + String.join(coffeeFarmerIds, ',');
            soca.gfsurveys__NumberOfRecords__c += coffeeFarmerIds.size();
        }
        contactSocaMap.put(contactId, soca);
    }
    upsert contactSocaMap.values();
    
    // Set the Country, Type and Farmer Type fields on Person and Focus Farmer objects
    Country__c country = [Select Id from Country__c where Name='Uganda'];

    List<Focus_Farmer__c> focusFarmers = new List<Focus_Farmer__c>();
    List<Person__c> persons = new List<Person__c>();
    List<String> focusFarmerIds = new List<String>();
    List<String> personIds = new List<String>();
    for (Coffee_Farmer__c coffeeFarmer : coffeeFarmers) {
        focusFarmerIds.add(coffeeFarmer.Focus_Farmer__c);
    }
    focusFarmers = [Select Farmer_Type__c, Person__c From Focus_Farmer__c where Id in:focusFarmerIds];
    for (Focus_Farmer__c focusFarmer : focusFarmers) {
        personIds.add(focusFarmer.Person__c);
        focusFarmer.Farmer_Type__c = 'Coffee';
    }
    persons = [Select Id, Type__c from Person__c where id in:personIds];
    for (Person__c person : persons) {
        person.Type__c = 'Focus Farmer';
        person.Country__c = country.Id;
    }
    update persons;
    update focusFarmers;
}