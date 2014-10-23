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

        CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c(CPA_Order__c = order.Id, Association__c = association.Id, Number_of_Units_of_Presentation__c = 5, Number_of_Kilos__c = 5);
        insert allocation;

        // 2. Run the code you want to test
        // Run findOrder() methodNumber_of_Kilos__c = 5
        AlsurOrderAssignment assignmentClass = new AlsurOrderAssignment();

        assignmentClass.getOrderItems();
        System.assert(assignmentClass.orderObjects.size() > 0);    

        List<SelectOption> options = assignmentClass.getAssociationItems();
        System.assert(options != null);

        assignmentClass.findOrder();
        System.assert(assignmentClass.orderObjects.size() > 0);


        PageReference ref = new PageReference('/apex/AccountPage?aId=' + contact.Id);

        Test.setCurrentPage(ref);
 
        Test.startTest();
        assignmentClass.allocation = allocation;
        PageReference ref2 = assignmentClass.saveAllocation();
        Test.stopTest();
     
        System.assertNotEquals(ref2, null);

    }
}