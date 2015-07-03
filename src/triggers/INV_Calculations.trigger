trigger INV_Calculations on INV_Transaction__c (before insert) {

    List <INV_Stock__c> stockToUpdate = new List <INV_Stock__c>();
    List<Id> clientIds = new List<Id>();
    List<Id> articleIds = new List<Id>();
    Decimal sum = 0;
    //this string will be used when the quantity to send (transfer) is greater than the current stock
    String errorMsg = 'Usted posee menos elementos que los que desea transferir';

    //get the list of clients (source & destination) and the articles involved in transaction
    for (INV_Transaction__c newTransaction : Trigger.new) {
        clientIds.add(newTransaction.Destination__c);
        clientIds.add(newTransaction.Source__c);
        articleIds.add(newTransaction.Article__c);
    }

    //get the stock data for all the clients and articles involved in trasaction
    for(INV_Stock__c sourceCalculations: [Select Id, Stock__c, Client__c, Article__c From INV_Stock__c Where Client__c in:clientIds and Article__c in :articleIds]) {
        for(INV_Transaction__c newTransaction : Trigger.new) {
            
            //if the condition is true, the error message is assigned and the record is not saved
            if(sourceCalculations.Client__c == newTransaction.Source__c && sourceCalculations.Article__c == newTransaction.Article__c && newTransaction.Quantity__c > sourceCalculations.Stock__c){
                newTransaction.addError(errorMsg);
            }else{
                //When the client is the sender, the quantity of stock decrease   
                if(sourceCalculations.Client__c == newTransaction.Source__c && sourceCalculations.Article__c == newTransaction.Article__c){
                    sum=0;
                    sum = sourceCalculations.Stock__c - newTransaction.Quantity__c;
                    sourceCalculations.Stock__c = sum;
                    stockToUpdate.add(sourceCalculations);
                }
                //When the client is the receiver, the quantity of stock increase   
                if(sourceCalculations.Client__c == newTransaction.Destination__c && sourceCalculations.Article__c == newTransaction.Article__c){
                    sum=0;
                    sum = sourceCalculations.Stock__c + newTransaction.Quantity__c;
                    sourceCalculations.Stock__c = sum;
                    stockToUpdate.add(sourceCalculations);
                }
            }
        }
    }
    try {
        update stockToUpdate;
    } 
    catch (system.Exception e){
        system.debug (e);
    }
}