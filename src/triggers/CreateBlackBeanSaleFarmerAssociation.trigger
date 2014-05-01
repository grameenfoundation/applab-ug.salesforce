trigger CreateBlackBeanSaleFarmerAssociation  on Ewarehouse_Sale_Black__c (after update) {
    //This trigger is called on every update of the Ewarehouse Sale Black  Beans Association, it calls the BlackBeansSaleFarmerAssociation Class to make a new Ewarehouse Sale Farmer Object
    Ewarehouse_Sale_Black__c[] black_beans_sale= Trigger.new;
    
    BlackBeansSaleFarmerAssociationCreator.getSaleFarmerDetails(Trigger.new); 
}