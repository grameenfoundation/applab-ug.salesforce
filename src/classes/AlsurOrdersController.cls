public with sharing class AlsurOrdersController {

    public List<CPA_Order__c> ordersToCreate { 
        get {
            ordersToCreate = [Select Id,
                                    Order_Code__c,
                                    Client_Product_Association__c,
                                    Product_Name__c,
                                    Client__c,
                                    Presentacion__c,
                                    Unit_of_Presentation__c,
                                    Number_of_Units_of_Presentation__c,
                                    Number_of_Kilos__c,
                                    Number_of_Baskets__c,
                                    Price_per_Kilo__c,
                                    Expected_Delivery_Date__c
                            FROM
                                CPA_Order__c
                            WHERE
                                Id IN:ordersToCreate];
            return ordersToCreate;
        } 
        set; 
    } 
    public Client_Product_Association__c cpa { get; set; }
    public String client { get; set; }
    public String product { get; set;}
    public CPA_Order__c currentOrder { get; set; }
    public boolean showOrderPanel { get; set;}
    

    public AlsurOrdersController()
    {
        ordersToCreate = new List<CPA_Order__c>();
        showOrderPanel = false;
    }

    public PageReference createOrder() {
        currentOrder = new CPA_Order__c(Client_Product_Association__c = product);
        showOrderPanel = true;
        return null;
    }
    
    public List<SelectOption> getClientItems() {
        List<Client__c> clients = [Select Id, Name from Client__c];
        List<SelectOption> options = new List<SelectOption>();
        for (Client__c client : clients) {
            options.add(new SelectOption(client.Id, client.Name));
        }
        return options;
    }

    public List<SelectOption> getProductItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Client_Product_Association__c> cpaItems = new List<Client_Product_Association__c>();
        if (client == null || String.isEmpty(client)) {
            options.add(new SelectOption('NoClientSelected', 'Select a client first'));
        }
        else {
            cpaItems = [Select Id, Product_Name__c from Client_Product_Association__c where Client__c =:client];
        }
        for (Client_Product_Association__c cpaItem : cpaItems) {
            options.add(new SelectOption(cpaItem.Id, cpaItem.Product_Name__c));
        }
        return options;
    }

    public PageReference save() {
        Association_Contact_Association__c aca = [Select Contact__c from Association_Contact_Association__c
            where Association__r.Name = 'ALSUR MAIN' limit 1];
        currentOrder.Contact__c = aca.Contact__c;
        insert currentOrder;
        System.debug(currentOrder.Client_Product_Association__r.Product_Name__c);
        ordersToCreate.add(currentOrder);
        showOrderPanel = false;
        return null;
    }
    // The method to add a new item to the list
    public PageReference next(){
        return null;
    }

}