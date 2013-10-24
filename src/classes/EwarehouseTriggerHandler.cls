public with sharing class EwarehouseTriggerHandler {

    public void onAfterHarvestInsert(List<Harvest__c> objects) {
        User sender = [
                    SELECT
                        Id,
                        Name
                    FROM
                        User
                    WHERE
                        Name = 'ckw admin'
                ];
        String messageSubject = 'Harvest Received';
        //Schedule the message for sending
        Savepoint sp = Database.setSavepoint();
        List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
        for (Harvest__c harvest: objects) {
            Farmer__c recipient = getFarmerPerson(harvest);
            String messageBody = getHarvestValue(harvest);
            Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                Subject__c = messageSubject,
                Message__c = messageBody,
                Sender__c = sender.Id,
                Expiration_Date__c = datetime.now().addDays(1),
                Send_Via_Pulse__c = false,
                Send_Via_SMS__c = true,
                Send_Date_Time__c = datetime.now(),
                Person__c = recipient.Person__r.Id
            );
            System.debug(message);
            messageQueue.add(message);
        }
     
        // Save the scheduled messsages. Parse the SaveResults and roll back all the new messages if there is a failure.
        Database.SaveResult[] saveMessageResults = Database.insert(messageQueue, false);
        for (Database.SaveResult result : saveMessageResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug(LoggingLevel.INFO, error.getMessage());
                }
                //TODO: Notify tech team of this failure
                
                Database.rollBack(sp);
            }
        }
    }
    
    
    private Farmer__c getFarmerPerson(Harvest__c harvest) {
        return [SELECT Person__r.Id FROM Farmer__c WHERE Id =: harvest.Farmer__c];
    }
    
    private String getHarvestValue(Harvest__c harvest) {
        Harvest__c harvestDetails = [SELECT 
                                         Farmer__r.Name, 
                                         Crop__c, 
                                         Quantity_Accepted__c, 
                                         Farmer__r.Person__r.First_Name__c, 
                                         Farmer__r.Person__r.Last_Name__c
                                      FROM 
                                         Harvest__c 
                                      WHERE 
                                         Id =: harvest.Id];
        String message = harvestDetails.Farmer__r.Person__r.First_Name__c + ' ' + 
                         harvestDetails.Farmer__r.Person__r.Last_Name__c + ' ' +
                         harvestDetails.Farmer__r.Name + ': ' +
                         harvestDetails.Quantity_Accepted__c + 'bags ' +
                         harvestDetails.Crop__c + '= ' +
                         '2000';
        return message;
    }
    
    public void onAfterSaleRegistrationInsert(List<Sale_Farmer_Association__c> objects) {
        User sender = [
                    SELECT
                        Id,
                        Name
                    FROM
                        User
                    WHERE
                        Name = 'ckw admin'
                ];
        String messageSubject = 'Sale Registration Received';
        //Schedule the message for sending
        Savepoint sp = Database.setSavepoint();
        List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
        for (Sale_Farmer_Association__c saleFarmer: objects) {
            Farmer__c recipient = getFarmerSalePerson(saleFarmer);
            String messageBody = getSaleValue(saleFarmer);
            Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                Subject__c = messageSubject,
                Message__c = messageBody,
                Sender__c = sender.Id,
                Expiration_Date__c = datetime.now().addDays(1),
                Send_Via_Pulse__c = false,
                Send_Via_SMS__c = true,
                Send_Date_Time__c = datetime.now(),
                Person__c = recipient.Person__r.Id
            );
            System.debug(message);
            messageQueue.add(message);
        }
     
        // Save the scheduled messsages. Parse the SaveResults and roll back all the new messages if there is a failure.
        Database.SaveResult[] saveMessageResults = Database.insert(messageQueue, false);
        for (Database.SaveResult result : saveMessageResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug(LoggingLevel.INFO, error.getMessage());
                }
                //TODO: Notify tech team of this failure
                
                Database.rollBack(sp);
            }
        }   	
    }
    
    private Farmer__c getFarmerSalePerson(Sale_Farmer_Association__c saleFarmer) {
        return [SELECT Person__r.Id FROM Farmer__c WHERE Id =: saleFarmer.Farmer__c];
    }
    
    private String getSaleValue(Sale_Farmer_Association__c saleFarmer) {
        Sale_Farmer_Association__c saleDetails = [SELECT 
                                         Farmer__r.Name, 
                                         Beans_Number_of_90kg_Bags_Sold__c, 
                                         Cow_Peas_Number_of_90kg_Bags_Sold__c,
                                         Dolichos_Number_of_90kg_Bags_Sold__c,
                                         Green_Grams_Number_of_90kg_Bags_Sold__c,
                                         Maize_Number_of_90kg_Bags_Sold__c,
                                         Pigeon_Peas_Number_of_90kg_Bags_Sold__c,
                                         Sale__c,
                                         Sale__r.Beans_Price_Per_90kg_Bag__c,
                                         Sale__r.Cow_Peas_Price_Per_90kg_Bag__c,
                                         Sale__r.Dolichos_Price_Per_90kg_Bag__c,
                                         Sale__r.Green_Grams_Price_Per_90kg_Bag__c,
                                         Sale__r.Maize_Price_Per_90kg_Bag__c,
                                         Sale__r.Pigeon_Peas_Price_Per_90kg_Bag__c,
                                         Farmer__r.Person__r.First_Name__c, 
                                         Farmer__r.Person__r.Last_Name__c
                                      FROM 
                                         Sale_Farmer_Association__c 
                                      WHERE 
                                         Id =: saleFarmer.Id];
                                         
        Decimal totalSale = saleDetails.Beans_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Beans_Price_Per_90kg_Bag__c +
        					saleDetails.Cow_Peas_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Cow_Peas_Price_Per_90kg_Bag__c +
        					saleDetails.Dolichos_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Dolichos_Price_Per_90kg_Bag__c + 
        					saleDetails.Green_Grams_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Green_Grams_Price_Per_90kg_Bag__c +
        					saleDetails.Maize_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Maize_Price_Per_90kg_Bag__c +
        					saleDetails.Pigeon_Peas_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Pigeon_Peas_Price_Per_90kg_Bag__c;
       
	    String beanString = (saleDetails.Beans_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Beans_Number_of_90kg_Bags_Sold__c + ' bags Beans =  Ksh ' + (saleDetails.Beans_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Beans_Price_Per_90kg_Bag__c)  : '';
	    String cowPeasString = (saleDetails.Cow_Peas_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Cow_Peas_Number_of_90kg_Bags_Sold__c + ' bags Cow Peas =  Ksh ' + (saleDetails.Cow_Peas_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Cow_Peas_Price_Per_90kg_Bag__c)  : '';
	    String dolichosString = (saleDetails.Dolichos_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Dolichos_Number_of_90kg_Bags_Sold__c + ' bags Dolichos =  Ksh ' + (saleDetails.Dolichos_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Dolichos_Price_Per_90kg_Bag__c)  : '';
	    String greenGramsString = (saleDetails.Green_Grams_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Green_Grams_Number_of_90kg_Bags_Sold__c + ' bags Green grams =  Ksh ' + (saleDetails.Green_Grams_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Green_Grams_Price_Per_90kg_Bag__c)  : '';                   
	    String maizeString = (saleDetails.Maize_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Maize_Number_of_90kg_Bags_Sold__c + ' bags Maize =  Ksh ' + (saleDetails.Maize_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Maize_Price_Per_90kg_Bag__c)  : '' ;
	    String pigeonPeasString = (saleDetails.Pigeon_Peas_Number_of_90kg_Bags_Sold__c > 0) ? saleDetails.Pigeon_Peas_Number_of_90kg_Bags_Sold__c + ' bags Pigeon Peas =  Ksh ' + (saleDetails.Pigeon_Peas_Number_of_90kg_Bags_Sold__c * saleDetails.Sale__r.Pigeon_Peas_Price_Per_90kg_Bag__c)  : '';                   
                         
                         
                         
                         				
        String message = saleDetails.Farmer__r.Person__r.First_Name__c + ' ' + 
                         saleDetails.Farmer__r.Person__r.Last_Name__c + ' ' +
                         saleDetails.Farmer__r.Name + ': ' +
                         beanString +
						 cowPeasString  +
						 dolichosString +
                         greenGramsString +
                         maizeString +
                         pigeonPeasString;
        
        message.trim();              
        return message + ' Total sale = Ksh ' + totalSale;
    }
}