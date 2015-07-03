@isTest
private class INV_CalculationsTriggerTest {
	
	@isTest static void test_Inv_Calc() {

		INV_Article__c article = new INV_Article__c();
		article.Name = 'Marca A';
		article.Description__c = 'Marca A';
		insert article;

		INV_Client__c cliente1 = new INV_Client__c();
		cliente1.Description__c  = 'Cliente 1';
		insert cliente1;

		INV_Client__c cliente2 = new INV_Client__c();
		cliente2.Description__c  = 'Cliente 2';
		insert cliente2;

		INV_Stock__c stock1 = new INV_Stock__c();
		stock1.Article__c = article.Id;
		stock1.Client__c = cliente1.Id;
		stock1.Stock__c = 3;
		insert stock1;

		INV_Stock__c stock2 = new INV_Stock__c();
		stock2.Article__c = article.Id;
		stock2.Client__c = cliente2.Id;
		stock2.Stock__c = 3;
		insert stock2;

		INV_Transaction__c trans = new INV_Transaction__c();
		trans.Article__c = article.Id;
		trans.Source__c = cliente1.Id;
		trans.Destination__c = cliente2.Id;
		trans.Quantity__c = 2;
		insert trans;

	}
	
}