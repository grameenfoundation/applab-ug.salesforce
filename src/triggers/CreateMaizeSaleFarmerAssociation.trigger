trigger CreateMaizeSaleFarmerAssociation on Ewarehouse_Sale_Maize_Association__c (after update) {

    Ewarehouse_Sale_Maize_Association__c[] maize_sale= Trigger.new;
    
    MaizeSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
    
}