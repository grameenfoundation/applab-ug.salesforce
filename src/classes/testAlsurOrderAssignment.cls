@isTest
private class testAlsurOrderAssignment{
    @isTest
	static void validateAlsurOrderAssignment(){

        Association__c association = new Association__c();
        association.Name = 'Alsurtest';
        insert association;

        Contact__c contact = new Contact__c();
        contact.Firstname = 'pedrito';
        contact.Lastname = 'perez';
        insert contact;

        CPA_Order__c order = new CPA_Order__c();
        order.Number_of_Units_of_Presentation__c = 10;
        order.Contact__c = contact.Id;
        order.Expected_Delivery_Date__c = System.today();
        order.Unit_of_Presentation__c = 5;
        insert order;

        CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
        allocation.CPA_Order__c = order.Id;
        allocation.Association__c = association.Id;
        allocation.Number_of_Units_of_Presentation__c = order.Unit_of_Presentation__c;
        allocation.Number_of_Kilos__c = 5;
        insert allocation;

        allocations = [SELECT Id, CPA_Order__c from CPA_Order_Allocation__c where CPA_Order__c =: order.Id];
        System.assertEquals(allocations.size(), 1);
    } 
}