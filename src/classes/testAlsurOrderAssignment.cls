@isTest 
private class testAlsurOrderAssignment{
    @isTest
	static void validateAlsurOrderAssignment(){
        // 1. Set things up
        Association__c association = new Association__c();
        association.Name = 'Alsurtest';
        insert association;

        Contact contact = new Contact();
        contact.FirstName = 'pedrito';
        contact.LastName = 'perez';
        insert contact;

        CPA_Order__c order = new CPA_Order__c();
        order.Number_of_Units_of_Presentation__c = 10;
        order.Contact__c = contact.Id;
        order.Expected_Delivery_Date__c = System.today();
        order.Unit_of_Presentation__c = '5';
        insert order;

        CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
        allocation.CPA_Order__c = order.Id;
        allocation.Association__c = association.Id;
        allocation.Number_of_Units_of_Presentation__c = 5;
        allocation.Number_of_Kilos__c = 5;
        insert allocation;


        CPA_Order_Allocation__c[] allocations = [SELECT Id, CPA_Order__c from CPA_Order_Allocation__c where CPA_Order__c =: order.Id];
        System.assertEquals(allocations.size(), 1);


        // 2. Run the code you want to test
        // Run findOrder() method
        AlsurOrderAssignment assignmentClass = new AlsurOrderAssignment();

        assignmentClass.getOrderItems();
        System.assert(assignmentClass.orderObjects.size() > 0);    

        List<SelectOption> options = assignmentClass.getAssociationItems();
        System.assert(options != null);

        assignmentClass.findOrder();
        System.assert(assignmentClass.orderObjects.size() > 0);
     
    }
}