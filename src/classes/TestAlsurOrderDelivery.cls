@isTest
private class TestAlsurOrderDelivery {
        
        @isTest static void test_method_one() {

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
                
        CPA_Order_Allocation__c orders = new CPA_Order_Allocation__c();
        orders.CPA_Order__c = order.Id;
        orders.Association__c = association.Id;
        orders.Number_of_Units_of_Presentation__c = 5;
        orders.Number_of_Kilos__c = 5;
        insert orders;

        AlsurOrderDelivery deliverys = new AlsurOrderDelivery();

        List<SelectOption> options = deliverys.getAssociationItems();
        System.assert(options != null);

        test.startTest();
        String nameQuery = 'Alsurtest';

        deliverys.executeSearch();
        System.assert(deliverys.orders != null);  

        Association_CPA_Order_Delivery__c allocation = new Association_CPA_Order_Delivery__c(
        CPA_Order_Allocation__c = orders.Id,
        Number_of_Kilos__c = orders.Number_of_Kilos__c,
        Number_of_Units_of_Presentation__c = orders.Number_of_Units_of_Presentation__c,
        Delivery_Date__c = System.today(),
        Unit_of_Presentation__c = orders.CPA_Order__r.Unit_of_Presentation__c,
        Delivery_Receipt_Number__c = '0');
        insert allocation;
        deliverys.save();
        System.assert(deliverys.save() != null);

        test.stopTest();

        }
}