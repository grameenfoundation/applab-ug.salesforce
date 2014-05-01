trigger CreateSaleFarmerAssociation on Sale_Record__c (before insert,before update) {
    Sale_Record__c[] ewarehouse_sale = Trigger.new;
    
    SaleFarmerAssociationCreator.getSaleDetails(Trigger.new);    
}