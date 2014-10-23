trigger CreateBeanSaleFarmerAssociation on Ewarehouse_Sale_Beans_Association__c (after update) {
    //This trigger is called on every update of the Ewarehouse Sale Beans Association, it calls the BeansSaleFarmerAssociation Class to make a new Ewarehouse Sale Farmer Object
    Ewarehouse_Sale_Beans_Association__c[] beans_sale= Trigger.new;
    
    BeansSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
    
}