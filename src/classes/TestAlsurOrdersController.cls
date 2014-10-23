@isTest
private class TestAlsurOrdersController {
	
	@isTest static void test_method_one() {

        Association__c association = new Association__c();
        association.Name = 'Alsurtest';
        insert association;

	Client__c client = new Client__c();
        client.Name = 'Alsurtest';
        insert client;

        Product__c product = new Product__c();
        product.Name = 'Papaya';
        insert product;

        Contact contact = new Contact();
        contact.FirstName = 'pedrito';
        contact.LastName = 'perez';
        insert contact;

        Client_Product_Association__c cpaItems = new Client_Product_Association__c();
        cpaItems.Product__c = product.Id;
        cpaItems.Client__c = client.Id;
        insert  cpaItems;

        Association_Contact_Association__c aca = new Association_Contact_Association__c(Contact__c = contact.Id, Association__c = association.Id);
        insert aca;

        CPA_Order__c currentOrder = new CPA_Order__c(Contact__c = aca.Contact__c, Number_of_Units_of_Presentation__c = 4);
        insert  currentOrder;

        PageReference ref = new PageReference('/apex/AccountPage?aId=' + contact.Id);
        Test.setCurrentPage(ref);

	AlsurOrdersController aoc = new AlsurOrdersController();

        List<SelectOption> options = aoc.getClientItems();
        System.assert(options != null);

        List<SelectOption> option = aoc.getProductItems();
        System.assert(option != null);

        aoc.createOrder();

        System.assert(aoc.ordersToCreate != null);
                   
        aoc.currentOrder = currentOrder;
        System.assert(aoc.currentOrder != null);

        Test.startTest();
        PageReference ref2 = aoc.next();
        Test.stopTest();
     
        system.assertEquals(ref2, null);
       
	}
}