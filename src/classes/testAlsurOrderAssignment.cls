@isTest
private class testAlsurOrderAssignment{
    @isTest
	static void validateAlsurOrderAssignment(){

        Association__c association = new Association__c();
        association.Name = 'Alsurtest';
        insert association;

        CPA_Order__c order = new CPA_Order__c();
        order.Number_of_Units_of_Presentation__c = 10;
        order.Contact__c = contact.Id;
        order.Expected_Delivery_Date__c = System.today();
        order.Unit_of_Presentation__c = 5;
        order.Presentacion__c = "5 al día";
        insert order;

        CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
        allocation.CPA_Order__c = order.Id;
        allocation.Association__c = association.Id;
        allocation.Number_of_Units_of_Presentation__c = order.Unit_of_Presentation__c;
        allocation.Number_of_Kilos__c = 5;
        allocation.Presentacion__c = order.Presentacion__c;
        insert allocation;

        allocations = [SELECT Id, CPA_Order__c from CPA_Order_Allocation__c where CPA_Order__c =: order.Id];
        System.assertEquals(allocations.size(), 1);
}
}