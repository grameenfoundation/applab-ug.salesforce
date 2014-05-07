trigger CreateOrUpdateSObjectContactAssociation on CPA_Order__c (after insert) {

    CPA_Order__c cpaOrder = trigger.new[0];
    gfsurveys__SObjectContactAssociation__c[] records = [Select Id, gfsurveys__AssociatedIds__c, 
                                                                    gfsurveys__SObjectApiName__c,
                                                                     gfsurveys__Contact__c, 
                                                                     gfsurveys__NumberOfRecords__c 
                                                      FROM gfsurveys__SObjectContactAssociation__c 
                                                      WHERE gfsurveys__SObjectApiName__c = 'CPA_Order__c' 
                                                      AND gfsurveys__Contact__c =: cpaOrder.Contact__c];
    List<CPA_Order__c> newOrders = trigger.new; 
    List<Id> orderIds = new List<Id>();
    for (CPA_Order__c order : newOrders) {
        orderIds.add(order.Id);
    }
    if (records.size() > 0) {
        gfsurveys__SObjectContactAssociation__c record = records[0];
        record.gfsurveys__AssociatedIds__c = record.gfsurveys__AssociatedIds__c + ',' + String.join(orderIds, ',');
        record.gfsurveys__NumberOfRecords__c += orderIds.size();
        update record;
    }
    else {
        gfsurveys__SObjectContactAssociation__c record = new gfsurveys__SObjectContactAssociation__c();
        record.gfsurveys__AssociatedIds__c = String.join(orderIds, ',');
        record.gfsurveys__SObjectApiName__c = 'CPA_Order__c';
        record.gfsurveys__Contact__c = cpaOrder.Contact__c;
        record.gfsurveys__NumberOfRecords__c = orderIds.size();
        insert record;
    }
}