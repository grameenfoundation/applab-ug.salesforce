/**
 * Batch class that schedules messages to be sent to farmers whose harvets have come into the gateway
 * in the last 1 hour
 * 
 */

global class HarvestMessageSender implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global static final String senderName = 'ckw admin';
    global static final String messageSubject = 'Harvest Received';
    global final String query;
    
    global HarvestMessageSender (String baseQuery) {
        query = baseQuery;
    }

    /**
     * Method called at the beginning of the batch job to return the records to be passed to the execute method
     * 
     * @param  Database.BatchableContext bc - Represents the parameter type of the batch job method and contains the batch job ID
     * @return Database.QueryLocator - An object that represents the record set returned by the getQueryLocator method
     * 
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    /**
     * Method that carries out the required processing for each batch of records passed to it
     *
     * @param Database.BatchableContext BC - REference to the context object
     * @param List<Ewarehouse_Harvest__c> inputHarvests - The List of harvests for which messages should be scheduled
     * @return void
     * 
     */
    global void execute(Database.BatchableContext BC, List<Ewarehouse_Harvest__c> inputHarvests) {
        User sender = [
            SELECT
                Id,
                Name
            FROM
                User
            WHERE
                Name = :senderName
                ];

        Savepoint sp = Database.setSavepoint();
        List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
        List<Ewarehouse_Harvest__c> harvestsToUpdate = new List<Ewarehouse_Harvest__c>();
        for (Ewarehouse_Harvest__c harvest: inputHarvests) {
            String messageBody = getHarvestValue(harvest);
            Scheduled_Message_Queue__c message = new Scheduled_Message_Queue__c(
                Subject__c = messageSubject,
                Message__c = messageBody,
                Sender__c = sender.Id,
                Expiration_Date__c = datetime.now().addDays(1),
                Send_Via_Pulse__c = false,
                Send_Via_SMS__c = true,
                Send_Date_Time__c = datetime.now(),
                Person__c = harvest.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id
            );
            messageQueue.add(message);

            //Add the loan message
            if (hasLoan(harvest.Ewarehouse_Farmer__r.Id)) {
                //Decimal eligibleLoanAmount = 0.5* (getCommodityValue('Beans', harvest.Beans_Harvested__c) + getCommodityValue('Black Beans', harvest.Black_Beans_Harvested__c) + getCommodityValue('Cow Peas', harvest.Cow_Peas_Harvested__c) + getCommodityValue('Green Grams', harvest.Green_Grams_Harvested__c) + getCommodityValue('Maize', harvest.Maize_Harvested__c) + getCommodityValue('Pigeon Peas', harvest.Pigeon_Peas_Harvested__c));
                String loanMessageBody = 'You are eligible for a loan of 50% of the crop value accepted into the E-warehouse';
                Scheduled_Message_Queue__c loanMessage = new Scheduled_Message_Queue__c(
                    Subject__c = messageSubject,
                    Message__c = loanMessageBody,
                    Sender__c = sender.Id,
                    Expiration_Date__c = datetime.now().addDays(1),
                    Send_Via_Pulse__c = false,
                    Send_Via_SMS__c = true,
                    Send_Date_Time__c = datetime.now(),
                    Person__c = harvest.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id
                );
                messageQueue.add(loanMessage);
            }
            // Mark the harvest as having had its message sent out
            harvest.Notification_Sent__c = true;
            harvestsToUpdate.add(harvest);
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
        update harvestsToUpdate;
    }

    /**
     * Clean up method called after the batch job has finished
     *
     * @param Database.BatchableContext BC - REference to the context object
     * @return void
     */
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob harvestMessageJob = [
            SELECT 
                Id, 
                Status, 
                NumberOfErrors, 
                JobItemsProcessed,
                TotalJobItems 
            FROM 
                AsyncApexJob 
            WHERE 
                Id = :BC.getJobId()];

        //Send email to the ewarehouse group notifying of job completion and statistics
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'ekamara@grameenfoundation.org'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Ewarehouse harvest notification message ' + harvestMessageJob.Status);
        mail.setPlainTextBody('The harvest message sender job processed ' + harvestMessageJob.TotalJobItems +
            'batches with '+ harvestMessageJob.NumberOferrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /** 
     * Get the value of the hravest stored in the e-warehouse
     *
     * @param Ewarehouse_Harvest__c harvest - The harvest whose value is to be calculated
     * @return String - A stringified value of the whole harvest
     * 
     */
    private String getHarvestValue(Ewarehouse_Harvest__c harvest) {
        /*
        String beanString = (harvest.Beans_Harvested__c > 0) ? harvest.Beans_Harvested__c + 'bags ' + 'Beans = KES '+ getCommodityValue('Beans', harvest.Beans_Harvested__c) + ',' : '';
        String blackBeansString = (harvest.Black_Beans_Harvested__c > 0) ? harvest.Black_Beans_Harvested__c + 'bags ' + 'Black Beans = KES ' + getCommodityValue('Black Beans', harvest.Black_Beans_Harvested__c) + ',' : '';
        String cowPeasString = (harvest.Cow_Peas_Harvested__c > 0) ? harvest.Cow_Peas_Harvested__c + 'bags ' + 'Cow peas = KES ' + getCommodityValue('Cow Peas', harvest.Cow_Peas_Harvested__c) + ',' : '';
        String greenGramsString = (harvest.Green_Grams_Harvested__c > 0) ? harvest.Green_Grams_Harvested__c + 'bags ' + 'Green Grams = KES ' + getCommodityValue('Green Grams', harvest.Green_Grams_Harvested__c) + ',' : '';
        String maizeString = (harvest.Maize_Harvested__c > 0) ? harvest.Maize_Harvested__c + 'bags ' + 'Maize = KES ' + getCommodityValue('Maize', harvest.Maize_Harvested__c) + ',' : '';
        String pigeonPeasString = (harvest.Pigeon_Peas_Harvested__c > 0) ? harvest.Pigeon_Peas_Harvested__c + 'bags ' + 'Pigeon Peas = KES ' + getCommodityValue('Pigeon Peas', harvest.Pigeon_Peas_Harvested__c) + ',' : '';
        */
        String beanString = (harvest.Beans_Harvested__c > 0) ? harvest.Beans_Harvested__c + 'bags of ' + 'Beans,' : '';
        String blackBeansString = (harvest.Black_Beans_Harvested__c > 0) ? harvest.Black_Beans_Harvested__c + 'bags of ' + 'Black Beans,' : '';
        String cowPeasString = (harvest.Cow_Peas_Harvested__c > 0) ? harvest.Cow_Peas_Harvested__c + 'bags of ' + 'Cow peas,' : '';
        String greenGramsString = (harvest.Green_Grams_Harvested__c > 0) ? harvest.Green_Grams_Harvested__c + 'bags of ' + 'Green Grams,' : '';
        String maizeString = (harvest.Maize_Harvested__c > 0) ? harvest.Maize_Harvested__c + 'bags of ' + 'Maize,' : '';
        String pigeonPeasString = (harvest.Pigeon_Peas_Harvested__c > 0) ? harvest.Pigeon_Peas_Harvested__c + 'bags of ' + 'Pigeon Peas,' : '';
        
        String message = harvest.Ewarehouse_Farmer__r.Contact__r.FirstName + ' ' + 
                         harvest.Ewarehouse_Farmer__r.Contact__r.LastName + ' ' +
                         harvest.Ewarehouse_Farmer__r.Auto_Generated_Farmer_ID__c + ': ' +
                         beanString +
                         blackBeansString +
                         cowPeasString +
                         greenGramsString +
                         maizeString +
                         pigeonPeasString;
        message.trim();
        message = message.removeEnd(',');
        message += ' accepted into the E-warehouse.';
        return message;
    }
    
    /**
     * Determine if a farmer has applied for a loan
     *
     * @param ID farmerId - The Id that of this farmer's record in the Ewarehouse_Farmer__c object
     * @return Boolean - true if the farmer has applied for a loan or false otherwise
     * 
     */
    private Boolean hasLoan(ID FarmerId) {
        Ewarehouse_Loan__c[] loanDetails = [SELECT Amount_Applied__c FROM Ewarehouse_Loan__c WHERE Ewarehouse_Farmer__c =: FarmerId and Status__c = 'Application'];
        if (loanDetails.size() > 0) {
            if (loanDetails[0].Amount_Applied__c > 0) { //We take the first loan because we assume the farmer will only have one loan
                return true;
            }
        }
        return false;
    }
    
    /**
     * Method to determine the value of a particular commodity given the number of bags that have been stored
     *
     * @param String crop - The name of the commoditi
     * @param Decimal numberOfBags - The number of bags whose value should be determined
     *
     * @return Decimal - The value of the commodity stored
     */
    private Decimal getCommodityValue(String crop, Decimal numberOfBags ) {
        Commodities__c commodity = [SELECT Highest_Wholesale_Price__c FROM Commodities__c WHERE Market__r.Name='e-warehouse' AND Name =: crop ORDER BY Effective_date__c DESC LIMIT 1];
        return (commodity.Highest_Wholesale_Price__c * numberOfBags * 90); //Assume that the crops are always stored in 90kg bags
    }
}