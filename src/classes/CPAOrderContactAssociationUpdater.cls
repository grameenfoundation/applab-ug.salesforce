public with sharing class CPAOrderContactAssociationUpdater {

    static String apiName = 'CPA_Order__c';
    
    public static void updateContactAssociations() {
          gfsurveys__SObjectContactAssociation__c[] records = [Select Id, gfsurveys__AssociatedIds__c, 
                                                                    gfsurveys__SObjectApiName__c,
                                                                     gfsurveys__Contact__c, 
                                                                     gfsurveys__NumberOfRecords__c 
                                                      FROM gfsurveys__SObjectContactAssociation__c 
                                                      WHERE gfsurveys__SObjectApiName__c = 'CPA_Order__c' 
                                                      ];
          Set<String> removals = new Set<String>();
          for (gfsurveys__SObjectContactAssociation__c record : records) {
              removals.addAll(record.gfsurveys__AssociatedIds__c.split(','));
          }
          Set<String> removeOrders = new Set<String>();
          List<CPA_Order__c> orders = [Select Expected_Delivery_Date__c, CreatedDate, Id from CPA_Order__c where
                              Id in:removals];
          for (CPA_Order__c order : orders) {
              if (order.Expected_Delivery_Date__c < date.today()) {
                  removeOrders.add(order.Id);
              }
          }
          for (gfsurveys__SObjectContactAssociation__c record : records) {
              Set<String> originalAssociatedIds = new Set<String>(record.gfsurveys__AssociatedIds__c.split(','));
              originalAssociatedIds.removeAll(removeOrders);
              record.gfsurveys__AssociatedIds__c = String.join(new List<String>(originalAssociatedIds), ',');
              record.gfsurveys__NumberOfRecords__c = originalAssociatedIds.size();
          }
          update records;
    }
    
}