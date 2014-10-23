trigger CreatePigeonPeasSaleFarmerAssociation on Ewarehouse_Sale_Pigeon_Peas_Association__c (after update) {

    Ewarehouse_Sale_Pigeon_Peas_Association__c[] pigeon_peas_sale= Trigger.new;
    
    PigeonPeasSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
    
}