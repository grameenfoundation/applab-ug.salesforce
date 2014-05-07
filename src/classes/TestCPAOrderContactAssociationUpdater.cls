@isTest
private class TestCPAOrderContactAssociationUpdater {

    static testMethod void testUpdateContactAssociations() {
        Contact testContact = new Contact(FirstName='test', LastName='contact');
        insert testContact;
        Client__c client = new Client__c(Name='testClient');
        insert client;
        Product__c product = new Product__c(Name='testProduct');
        insert product;
        Client_Product_Association__c cpa = new Client_Product_Association__c();
        cpa.Product__c = product.Id;
        cpa.Client__c = client.id;
        insert cpa;
        List<CPA_Order__c> testOrders = new List<CPA_Order__c>();
        for (integer index=0; index < 5; index++) {
            CPA_Order__c cpaOrder = new CPA_Order__c();
            cpaOrder.Client_Product_Association__c = cpa.id;
            cpaOrder.Price_per_Kilo__c = 550;
            cpaOrder.Presentacion__c = 'Malla';
            cpaOrder.Unit_of_Presentation__c = 'Kg.';
            cpaOrder.Contact__c = testContact.Id;
            cpaOrder.Expected_Delivery_Date__c = date.today().addDays(-(index + 2));
            cpaOrder.Number_of_Baskets__c = 10;
            cpaOrder.Number_of_Kilos__c = 100;
            cpaOrder.Number_of_Units_of_Presentation__c = 100;
            testOrders.add(cpaOrder);
        }
        insert testOrders;
        test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, gfsurveys__AssociatedIds__c from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                                 where gfsurveys__Contact__c=:testContact.id];
        System.assertEquals(1, 1);
        System.assertEquals(5, scas[0].gfsurveys__AssociatedIds__c.split(',').size());
        
        // Create 2 orders for today, which we shall check for after running the CPAOrderContactAssociationUpdater
        List<CPA_Order__c> todayOrders = new List<CPA_Order__c>();
        for (integer count = 1; count < 3; count++) {
            CPA_Order__c cpaOrder = new CPA_Order__c();
            cpaOrder.Client_Product_Association__c = cpa.id;
            cpaOrder.Price_per_Kilo__c = 550;
            cpaOrder.Presentacion__c = 'Malla';
            cpaOrder.Unit_of_Presentation__c = 'Kg.';
            cpaOrder.Contact__c = testContact.Id;
            cpaOrder.Expected_Delivery_Date__c = date.today();
            cpaOrder.Number_of_Baskets__c = 10 * count;
            cpaOrder.Number_of_Kilos__c = 100 * count;
            cpaOrder.Number_of_Units_of_Presentation__c = 100 * count;
            todayOrders.add(cpaOrder);
        }
        insert todayOrders;
        CPAOrderContactAssociationUpdater.updateContactAssociations();
        scas = [Select Id, gfsurveys__AssociatedIds__c from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                                 where gfsurveys__Contact__c=:testContact.id];
        System.assertEquals(2, scas[0].gfsurveys__AssociatedIds__c.split(',').size());
        test.stopTest();
    }
}