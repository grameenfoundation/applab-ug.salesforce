public class CPAOrderAllocationAssociationUpdater {

  public static void updateContactAssociations() {
    gfsurveys__SObjectContactAssociation__c[] records = [Select Id, gfsurveys__AssociatedIds__c, 
                                                              gfsurveys__SObjectApiName__c,
                                                               gfsurveys__Contact__c, 
                                                               gfsurveys__NumberOfRecords__c 
                                                FROM gfsurveys__SObjectContactAssociation__c 
                                                WHERE gfsurveys__SObjectApiName__c = 'CPA_Order_Allocation__c' 
                                                ];
    gfsurveys__SObjectContactAssociation__c[] recordsToDelete = new List<gfsurveys__SObjectContactAssociation__c>();
    if (records.size() > 0) {
      Set<String> removals = new Set<String>();
      for (gfsurveys__SObjectContactAssociation__c record : records) {
        removals.addAll(record.gfsurveys__AssociatedIds__c.split(','));
      }
      Set<String> removeOrders = new Set<String>();
      List<CPA_Order_Allocation__c> orders = [Select Expected_Delivery_Date__c, CreatedDate, Id from CPA_Order_Allocation__c where
                          Id in:removals];
      for (CPA_Order_Allocation__c order : orders) {
        if (order.Expected_Delivery_Date__c < date.today()) {
          removeOrders.add(order.Id);
        }
      }
      for (gfsurveys__SObjectContactAssociation__c record : records) {
        Set<String> originalAssociatedIds = new Set<String>(record.gfsurveys__AssociatedIds__c.split(','));
        originalAssociatedIds.removeAll(removeOrders);
        if (originalAssociatedIds.size() == 0) {
          recordsToDelete.add(record);
        }
        record.gfsurveys__AssociatedIds__c = String.join(new List<String>(originalAssociatedIds), ',');
        record.gfsurveys__NumberOfRecords__c = originalAssociatedIds.size();
      }
      if (recordsToDelete.size() > 0) {
        delete recordsToDelete;
      }
      gfsurveys__SObjectContactAssociation__c[] backupRecords = new gfsurveys__SObjectContactAssociation__c[]{};
      for (integer count = 0; count < records.size(); count++) {
        if (records[count].gfsurveys__NumberOfRecords__c > 0) {
          backupRecords.add(records[count]);
        }
      }
      records = backupRecords;
      update records;
    }
  }
}