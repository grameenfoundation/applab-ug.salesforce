global class CreateMarketLinkTransaction {	
	
	/**
	* Creates MarketLink_Transaction, MarketLink_Farmers and MarketLink_Farmer_Assciations
	*
	* @ MarketLinkTransaction - transaction receipt details
	* @ List<FarmerTransaction> - farmer transaction details
	* 
	* return A tuple list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required (should be printed to backend)
    *              element 3 - Message to be sent to the submitter
	*/
    webservice static List<String> createTransaction(MarketLinkTransaction marketLinkTransactionAdapter, List<FarmerTransaction> farmerTransactionAdapters) {
   	
    	List<String> result = new List<String>();
    	
    	// Set save point to enable rollback
    	Savepoint sPoint = Database.setSavepoint();
    	try {
    		CKW__c ckw = getTransactionCKW(marketLinkTransactionAdapter.imei);
        	Market_Link_Transaction__c marketLinkTransaction = saveMarketLinkTransactionDetails(marketLinkTransactionAdapter, ckw);
        
       		for (FarmerTransaction farmerTransactionAdapter : farmerTransactionAdapters) {
        		saveAndAssociateFarmerTransaction(farmerTransactionAdapter, marketLinkTransaction);
       		}
       		result.add('0');
       		result.add('');
       		result.add('Transaction has been successfully saved');
    	}
    	catch (Exception ex) {
    		System.debug(ex);
    	    
    	    // Rollback changes
    	    Database.rollback(sPoint);    	    
    		result.add('1');
       		result.add(ex.getMessage());
       		result.add('Transaction has not successfully saved');
    	}
    	return result;
    }
    
    private static CKW__c getTransactionCKW(String imei) {
    	CKW__c ckw = [
    		SELECT
    			Id
    		FROM
    			CKW__c
    		WHERE
    			Person__r.Handset__r.IMEI__c = :imei
    		LIMIT 1
    		];
    	return ckw;
    }
    
    private static Market_Link_Transaction__c saveMarketLinkTransactionDetails(MarketLinkTransaction adapter, CKW__c ckw) {
    	Market_Link_Transaction__c marketLinkTransaction = new Market_Link_Transaction__c();
    	marketLinkTransaction.District_Name__c = adapter.district;
    	marketLinkTransaction.Crop__c = adapter.crop;
    	marketLinkTransaction.Transaction_Date__c = DateTime.valueOf(adapter.transactionDate);
    	marketLinkTransaction.Type__c = adapter.transactionType;
    	
    	if (marketLinkTransaction.Type__c.trim().equals('marketSale')) {
    		marketLinkTransaction.Market_Name__c = adapter.name;
    	}
    	else {
    		marketLinkTransaction.Buyer_Name__c = adapter.name;
    	}
    	marketLinkTransaction.Total_Quantity__c = adapter.totalQuantity;
    	marketLinkTransaction.Total_Transaction_Fee__c = adapter.totalTransactionFee;
    	marketLinkTransaction.Total_Transport_Cost__c = adapter.totalTransportCost;
    	marketLinkTransaction.Total_Income__c = adapter.totalIncome;
    	marketLinkTransaction.Unit_Price__c = adapter.unitPrice;
    	marketLinkTransaction.CKW__c = ckw.Id;
    	database.insert(marketLinkTransaction);
    	return marketLinkTransaction;
    }
    
    private static void saveAndAssociateFarmerTransaction(FarmerTransaction adapter, Market_Link_Transaction__c marketLinkTransaction) {
    	Market_Link_Farmer__c marketLinkFarmer = new Market_Link_Farmer__c();
    	marketLinkFarmer.Farmer_Name__c = adapter.name;
    	
    	if (adapter.farmerId != null && !adapter.farmerId.equals('')) {
    		Farmer__c farmer = [
    			SELECT
    				Id
    			FROM
    				Farmer__c
    			WHERE
    				Name = :adapter.farmerId
    			LIMIT 1
    		];
    		marketLinkFarmer.Farmer__c = farmer.Id;
    	}
    	database.insert(marketLinkFarmer);
    	
    	// create and save MarketLink Farmer Association
    	MarketLink_Farmer_Association__c association = new MarketLink_Farmer_Association__c();
    	association.Income__c = adapter.income;
    	association.Quantity__c = adapter.quantity;
    	association.Transaction_Fee__c = adapter.transactionFee;
    	association.Transport_Cost__c = adapter.transportCost;
    	association.Market_Link_Transaction__c = marketLinkTransaction.Id;
    	association.Market_Link_Farmer__c = marketLinkFarmer.Id;
    	database.insert(association);   	
    }
    
    global class MarketLinkTransaction {    
        webservice String crop;
        webservice String district;
        webservice String transactionDate;
        webservice String transactionType;
        webservice double unitPrice;
        webservice double totalQuantity;
        webservice double totalTransactionFee;
        webservice double totalTransportCost;
        webservice double totalIncome;
        webservice String name;
        webservice String imei; 
    }
    
    global class FarmerTransaction {
    	webservice String name;
    	webservice String farmerId;
    	webservice double quantity;
    	webservice double transactionFee;
    	webservice double transportCost;
    	webservice double income;
    }
    
    static testMethod void testEachMethod() {
    	    	
    	String imei = '23426756';
    	database.insert(Utils.createTestCkw(null, imei, true, null, null));    	    	
    	CKW__c ckw = getTransactionCKW(imei);
    	System.assert(ckw != null);
    	
    	// build MarketLinkTransaction adapter
    	MarketLinkTransaction madapter = new MarketLinkTransaction();
    	madapter.crop = 'beans';
    	madapter.district = 'Kampala';
    	madapter.transactionDate = '2012-02-02 00:00:00';
    	madapter.transactionType = 'marketSale';
    	madapter.totalQuantity = 50;
    	madapter.totalTransactionFee = 1000;
    	madapter.totalTransportCost = 3000;
    	madapter.totalIncome = 200000;
    	madapter.unitPrice = 200;
    	madapter.name = 'Mbarara Market';
    	madapter.imei = imei;
    	
    	Market_Link_Transaction__c marketLinkTransaction = saveMarketLinkTransactionDetails(madapter, ckw);
    	System.debug('transaction Id ' + MarketLinkTransaction.Id);
    	System.assert(marketLinkTransaction.Id != null);
    	
    	// build FarmerTrasactionAdapter
    	FarmerTransaction fadapter = new FarmerTransaction();
    	fadapter.farmerId = '';
    	fadapter.income = 1000;
    	fadapter.name = 'james oo test';
    	fadapter.transactionFee = 100;
    	fadapter.transportCost = 100;
    	fadapter.quantity = 10;
    	
    	saveAndAssociateFarmerTransaction(fadapter, marketLinkTransaction);    	
    }
    
    static testmethod void testCreateTransaction() {
    	
    	String imei = '23426756';
    	database.insert(Utils.createTestCkw(null, imei, true, null, null));    	    	
    	CKW__c ckw = getTransactionCKW(imei);
    	System.assert(ckw != null);
    	
    	// build MarketLinkTransaction adapter
    	MarketLinkTransaction madapter = new MarketLinkTransaction();
    	madapter.crop = 'beans';
    	madapter.district = 'Kampala';
    	madapter.transactionDate = '2012-02-02 00:00:00';
    	madapter.transactionType = 'marketSale';
    	madapter.totalQuantity = 50;
    	madapter.totalTransactionFee = 1000;
    	madapter.totalTransportCost = 3000;
    	madapter.totalIncome = 200000;
    	madapter.unitPrice = 200;
    	madapter.name = 'Mbarara Market';
    	madapter.imei = imei;
    	
    	// build FarmerTrasactionAdapters
    	FarmerTransaction fadapter = new FarmerTransaction();
    	fadapter.farmerId = '';
    	fadapter.income = 1000;
    	fadapter.name = 'james oo test';
    	fadapter.transactionFee = 100;
    	fadapter.transportCost = 100;
    	fadapter.quantity = 10;
    	
    	// build FarmerTrasactionAdapter
    	FarmerTransaction fadapter1 = new FarmerTransaction();
    	fadapter1.farmerId = '';
    	fadapter1.income = 1000;
    	fadapter1.name = 'oo test';
    	fadapter1.transactionFee = 100;
    	fadapter1.transportCost = 100;
    	fadapter1.quantity = 10;
    	
    	List<FarmerTransaction> farmerTransactions = new List<FarmerTransaction>();
    	farmerTransactions.add(fadapter);
    	farmerTransactions.add(fadapter1);
    	
    	List<String> transactionResult = createTransaction(madapter, farmerTransactions);
    	System.assertEquals(transactionResult.get(0), '0');
    }
}