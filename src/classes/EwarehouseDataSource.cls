/*
 * Datasource for accessing objcets within Salesforce. Includes Interface which can be used to Mock the class during testing
 * Classes will use the Interface [IEwarehouseDataSource] and instantiate by default the [EwarehouseDataSource]
 */
public with sharing class EwarehouseDataSource implements IEwarehouseDataSource {
    
    private static ServiceLogger logger = new ServiceLogger();
    
    public List<Ewarehouse_Farmer__c> getFarmer(String name){
        return [SELECT
                    ID, 
                    Name,
                    Registration_Date__c,
                    District__c,
                    Contact__c,
                    Status__c,
                    Auto_Generated_Farmer_ID__c,
                    Commercial_Purchase_Groups__c,
                    Ewarehouse_Person__r.First_Name__c,
                    Ewarehouse_Person__r.Middle_Name__c,
                    Ewarehouse_Person__r.Last_Name__c,
                    Ewarehouse_Person__r.Mobile_Number__c,
                    Ewarehouse_Person__r.Village__c             
                FROM 
                    Ewarehouse_Farmer__c
                WHERE
                    Name = :name];
                    
    }
    
    public List<Ewarehouse_Farmer__c> getFarmersByStatus(String status){
        // if status is new, also return farmers without a status
        if(status == 'New'){
            return [SELECT
                    ID, 
                    Name,
                    Registration_Date__c,
                    District__c,
                    Contact__c,
                    Status__c,
                    Auto_Generated_Farmer_ID__c,
                    Commercial_Purchase_Groups__c,
                    Ewarehouse_Person__r.First_Name__c,
                    Ewarehouse_Person__r.Middle_Name__c,
                    Ewarehouse_Person__r.Last_Name__c,
                    Ewarehouse_Person__r.Mobile_Number__c,
                    Ewarehouse_Person__r.Village__c             
                FROM 
                    Ewarehouse_Farmer__c
                WHERE 
                    Status__c = 'New' OR Status__c = '' LIMIT 20];
        }
        // else pick up the farmers with the exact status requested
        return [SELECT
                    ID, 
                    Name,
                    Registration_Date__c,
                    District__c,
                    Contact__c,
                    Status__c,
                    Auto_Generated_Farmer_ID__c,
                    Commercial_Purchase_Groups__c,
                    Ewarehouse_Person__r.First_Name__c,
                    Ewarehouse_Person__r.Middle_Name__c,
                    Ewarehouse_Person__r.Last_Name__c,
                    Ewarehouse_Person__r.Mobile_Number__c,
                    Ewarehouse_Person__r.Village__c             
                FROM 
                    Ewarehouse_Farmer__c
                WHERE
                    Status__c = :status];
                    
    }
    
    public Ewarehouse_Farmer__c[] getFarmers(Set<String> farmerIds){
        String q = 'SELECT Id, Name, Status__c FROM Ewarehouse_Farmer__c WHERE Name IN :farmerIds';
        return Database.query(q);
    }
    
    public Database.SaveResult updateFarmer(Ewarehouse_Farmer__c farmer){
        return Database.update(farmer);
    }
    
    // retrieve new sales (not synchronized)
    public Sale_Farmer_Associations__c[] getSales(String status){
        // build generic soql query
        String q = 'SELECT ID, Name, Beans_Number_of_90kg_Bags__c, Maize_Number_of_90kg_Bags__c, Cow_Peas_Number_of_90kg_Bags__c, Dolichos_Number_of_90kg_Bags__c, Green_Grams_Number_of_90kg_Bags__c, Pigeon_Peas_Number_of_90kg_Bags__c, ' +
                         
                    'Ewarehouse_Farmer__c,  ' + 
                    'Ewarehouse_Farmer__r.Name, ' + 
                    
                    'Ewarehouse_Sale__c,  ' + 
                    'Ewarehouse_Sale__r.Name, ' + 
                    'Ewarehouse_Sale__r.Status__c,  ' + 
                    'Ewarehouse_Sale__r.Sale_Date__c,  ' +
                    'Ewarehouse_Sale__r.Commercial_Village__c,  ' +
                    'Ewarehouse_Sale__r.VKW_Name__c,  ' + 
                    
                    'Ewarehouse_Sale__r.Beans_Number_of_90kg_Bags__c, ' + 
                    'Ewarehouse_Sale__r.Cow_Peas_Number_of_90kg_Bags__c, ' + 
                    'Ewarehouse_Sale__r.Dolichos_Number_of_90kg_Bags__c, ' + 
                    'Ewarehouse_Sale__r.Green_Grams_Number_of_90kg_Bags__c, ' + 
                    'Ewarehouse_Sale__r.Maize_Number_of_90kg_Bags__c, ' + 
                    'Ewarehouse_Sale__r.Pigeon_Peas_Total_Amount__c, ' + 
                    
                    'Ewarehouse_Sale__r.Beans_Price_per_90kg_Bag__c, ' + 
                    'Ewarehouse_Sale__r.Cow_Peas_Price_per_90kg_Bag__c, ' + 
                    'Ewarehouse_Sale__r.Dolichos_Price_per_90kg_Bag__c, ' + 
                    'Ewarehouse_Sale__r.Green_Grams_Price_per_90kg_Bag__c, ' + 
                    'Ewarehouse_Sale__r.Maize_Price_per_90kg_Bag__c, ' + 
                    'Ewarehouse_Sale__r.Pigeon_Peas_Price_per_90kg_Bag__c, ' + 

                    'Ewarehouse_Sale__r.Bank_Deposit__c, ' + 
                    'Ewarehouse_Sale__r.Bank_Deposit__r.Deposit_Date__c ' + 
                    
                    'FROM Sale_Farmer_Associations__c ';
        
        // decide what where clause is needed
        if(status == 'New')
            q = q + 'WHERE Ewarehouse_Sale__r.Status__c = \'--None--\' OR Ewarehouse_Sale__r.Status__c = \'New\' OR Ewarehouse_Sale__r.Status__c = \'\'';
        else
            q = q + 'WHERE Ewarehouse_Sale__r.Status__c = \''+ status +'\'';
        
        logger.debug(q);
        // exectute query and return result
        return Database.query(q);
        
    }
    
    public Sale_Record__c[] getSales(Set<String> saleIds){
        String q = 'SELECT Id, Name, Status__c, Commercial_Village__c, VKW_Name__c FROM Sale_Record__c WHERE Name IN :saleIds';
        return Database.query(q);
    }
    
    public Database.SaveResult updateSale(Sale_Record__c sale){
        return Database.update(sale);
    }
    
    
    /*
     * Interface for accessing SalesForce objects for the e-Warehouse
     */
    public interface IEwarehouseDataSource{
        // returns a Farmer (single item List) given an name (Farmer id)
        List<Ewarehouse_Farmer__c> getFarmer(String name);
        
        // return a list of farmers by status
        List<Ewarehouse_Farmer__c> getFarmersByStatus(String status);
        
        // runs a dynamic query to get clients and returns the associated objects
        Ewarehouse_Farmer__c[] getFarmers(Set<String> farmerIds);
        
        // update a farmer, currently only used to update the Status
        Database.SaveResult updateFarmer(Ewarehouse_Farmer__c farmer);
        
        // retrieve a list of Sale_Farmer objects given a certain status 
        Sale_Farmer_Associations__c[] getSales(String status);
        
        // retrieve a list of Sale records given a Set of IDs
        Sale_Record__c[] getSales(Set<String> saleIds);
    
        // update a list of Sale records
        Database.SaveResult updateSale(Sale_Record__c sale);
        
    }
    
    
}