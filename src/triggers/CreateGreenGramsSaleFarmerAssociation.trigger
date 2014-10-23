trigger CreateGreenGramsSaleFarmerAssociation on Ewarehouse_Sale_Green_Grams_Association__c (after update) {
    //This trigger is called on every update of the Ewarehouse Sale Green Grams Association, it calls the GreenGramsSaleFarmerAssociation Class to make a new Ewarehouse Sale Farmer Object
    Ewarehouse_Sale_Green_Grams_Association__c[] green_grams_sale= Trigger.new;
    
    GreenGramsSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
    
}