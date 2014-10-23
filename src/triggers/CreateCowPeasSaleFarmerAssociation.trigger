trigger CreateCowPeasSaleFarmerAssociation on Ewarehouse_Sale_Cow_Peas_Association__c (after update) {
    //This trigger is called on every update of the Ewarehouse Cow Peas Association, it calls the CowPeasSaleFarmerAssociation Class to make a new Ewarehouse Sale Farmer Object
    Ewarehouse_Sale_Cow_Peas_Association__c[] cow_peas_sale= Trigger.new;
    
    CowPeasSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
}