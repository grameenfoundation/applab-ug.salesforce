trigger GenerateEwarehouseIdTrigger on Ewarehouse_Farmer__c (before insert,before update) {   
 
    //Call to new Ewarehouse Farmer Object Trigger
    Ewarehouse_Farmer__c[] commercial_group = Trigger.new;
    //Call to class to get the Commercial Purchase Group ID values
    EwarehouseIdGenerator.getCommercialGroupID( Trigger.new );
    //Call to the Mobile User & created farmer association 
    EwarehouseIdGenerator.getFarmerClient( Trigger.new ); 
}