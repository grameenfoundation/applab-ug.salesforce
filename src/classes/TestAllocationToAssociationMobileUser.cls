@isTest
public class TestAllocationToAssociationMobileUser{

	static testMethod void testAssignAllocationToAssociationMobileUser() {

		// Create a test Association
        Association__c association = new Association__c(Name='ALSUR ASSOC');
        insert association;

        //Create 2 contacts to assign to the above association
        Contact testContact = new Contact(FirstName='test', LastName='contact');
        insert testContact;
        Contact testContact2 = new Contact(FirstName='test2', LastName='contact2');
        insert testContact2;

        // Create the contact association objects for the 2 contacts
        Association_Contact_Association__c assoc = new Association_Contact_Association__c();
        assoc.Association__c = association.Id;
        assoc.Contact__c = testContact.Id;
        insert assoc;
        Association_Contact_Association__c assoc2 = new Association_Contact_Association__c();
        assoc2.Association__c = association.Id;
        assoc2.Contact__c = testContact2.Id;
        insert assoc2;

        // Create a client and then a client product association
        Client__c client = new Client__c(Name='testClient');
        insert client;
        Product__c product = new Product__c(Name='testProduct');
        insert product;
        Client_Product_Association__c cpa = new Client_Product_Association__c();
        cpa.Product__c = product.Id;
        cpa.Client__c = client.id;
        insert cpa;

        // Create an Order
        CPA_Order__c cpaOrder = new CPA_Order__c();
        cpaOrder.Client_Product_Association__c = cpa.id;
        cpaOrder.Price_per_Kilo__c = 550;
        cpaOrder.Presentacion__c = 'Malla';
        cpaOrder.Unit_of_Presentation__c = 'Kg.';
        cpaOrder.Contact__c = testContact.Id;
        cpaOrder.Expected_Delivery_Date__c = date.today().addDays(1);
        cpaOrder.Number_of_Baskets__c = 10;
        cpaOrder.Number_of_Kilos__c = 100;
        cpaOrder.Number_of_Units_of_Presentation__c = 100;
        insert cpaOrder;

        // Create an allocation for this order to the association above
        CPA_Order_Allocation__c allocation = new CPA_Order_Allocation__c();
        allocation.Association__c = association.Id;
        allocation.CPA_Order__c = cpaOrder.Id;
        allocation.Number_of_Kilos__c = 5;
        allocation.Number_of_Baskets__c = 50;
        allocation.Number_of_Units_of_Presentation__c = 50;
        insert allocation;
        test.startTest();
        List<gfsurveys__SObjectContactAssociation__c> scas = [Select Id, 
        																gfsurveys__AssociatedIds__c 
															    from 
                                                                    gfsurveys__SObjectContactAssociation__c
                                                            	where 
                                                            		gfsurveys__SObjectApiName__c='CPA_Order_Allocation__c'];
		System.assertEquals(2, scas.size());
		test.stopTest();
	}

}