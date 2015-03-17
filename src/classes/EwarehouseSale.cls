public with sharing class EwarehouseSale {
    
    private static ServiceLogger logger = new ServiceLogger();

    public String Id { get; set; }
    public String FarmerID { get; set; }
    
    public Decimal BeansNo90kgBags { get; set; }
    public Decimal CowPeasNo90kgBags { get; set; }
    public Decimal DolichosNo90kgBags { get; set; }
    public Decimal GreenGramsNo90kgBags { get; set; }
    public Decimal MaizeNo90kgBags { get; set; }
    public Decimal PigeonPeasNo90kgBags { get; set; }
    
    public Decimal BeansPrice90kgBag { get; set; }
    public Decimal CowPeasPrice90kgBag { get; set; }
    public Decimal DolichosPrice90kgBag { get; set; }
    public Decimal GreenGramsPrice90kgBag { get; set; }
    public Decimal MaizePrice90kgBag { get; set; }
    public Decimal PigeonPeasPrice90kgBag { get; set; }
    
    public Date SaleDate { get; set; }
    public Date BankDepositDate { get; set; }
    
    public String SaleStatus { get; set; }
    
    public String CommercialVillage { get; set; }
    
    public String VillageKnowledgeWorker { get; set; }
    
    //Sale_Date__c
    //Status__c
    //Commercial_Village__c
    //VillageKnowledgeWorker
    
    //Bank_Deposit__c.Deposit Date
    public static EwarehouseSale fromSfObject(Sale_Farmer_Associations__c sfObject){
        EwarehouseSale sale = new EwarehouseSale();
        
        Ewarehouse_Farmer__c sfFarmer = sfObject.Ewarehouse_Farmer__r;
        Sale_Record__c sfSale = sfObject.Ewarehouse_Sale__r;
        
        Sale_Farmer_Associations__c sfSaleFarmer = sfObject;
        
        
        // check whether sfSale contains data
        if(sfSale == null){
            logger.error('Sale_Farmer_Associations__c does not contain a valid Sale_Record__c, return null');
            logger.error(sfObject);
            return null;
        }
        
        // check whether sfFarmer contains data
        if(sfFarmer == null){
            logger.error('Sale_Farmer_Associations__c does not contain a valid Ewarehouse_Farmer__c, return null');
            logger.error(sfObject);
            return null;
        }
        
        // after verified sale exists, get the bank deposit and verify it exists
        Bank_Deposit__c sfBankDeposit = sfSale.Bank_Deposit__r;
        
        // check whether sfDeposit contains data
        if(sfBankDeposit == null){
            logger.error('Sale_Record__c does not contain a valid Bank_Deposit__c, return null');
            logger.error(sfSale);
            return null;
        }
        
        sale.Id = sfSale.Name;
        sale.FarmerID = sfFarmer.Name;
        
        sale.BeansNo90kgBags = sfSaleFarmer.Beans_Number_of_90kg_Bags__c;
        sale.CowPeasNo90kgBags = sfSaleFarmer.Cow_Peas_Number_of_90kg_Bags__c;
        sale.DolichosNo90kgBags = sfSaleFarmer.Dolichos_Number_of_90kg_Bags__c;
        sale.GreenGramsNo90kgBags = sfSaleFarmer.Green_Grams_Number_of_90kg_Bags__c;
        sale.MaizeNo90kgBags = sfSaleFarmer.Maize_Number_of_90kg_Bags__c;
        sale.PigeonPeasNo90kgBags = sfSaleFarmer.Pigeon_Peas_Number_of_90kg_Bags__c;
        
        sale.BeansPrice90kgBag = sfSale.Beans_Price_per_90kg_Bag__c;
        sale.CowPeasPrice90kgBag = sfSale.Cow_Peas_Price_per_90kg_Bag__c;
        sale.DolichosPrice90kgBag = sfSale.Dolichos_Price_per_90kg_Bag__c;
        sale.GreenGramsPrice90kgBag = sfSale.Green_Grams_Price_per_90kg_Bag__c;
        sale.MaizePrice90kgBag = sfSale.Maize_Price_per_90kg_Bag__c;
        sale.PigeonPeasPrice90kgBag = sfSale.Pigeon_Peas_Total_Amount__c;
        
        // set amounts listed as 'null' to 0
        if(sale.BeansNo90kgBags == null) sale.BeansNo90kgBags = 0;
        if(sale.CowPeasNo90kgBags == null) sale.CowPeasNo90kgBags = 0;
        if(sale.DolichosNo90kgBags == null) sale.DolichosNo90kgBags = 0;
        if(sale.GreenGramsNo90kgBags == null) sale.GreenGramsNo90kgBags = 0;
        if(sale.MaizeNo90kgBags == null) sale.MaizeNo90kgBags = 0;
        if(sale.PigeonPeasNo90kgBags == null) sale.PigeonPeasNo90kgBags = 0;
        
        if(sale.BeansPrice90kgBag == null) sale.BeansPrice90kgBag = 0;
        if(sale.CowPeasPrice90kgBag == null) sale.CowPeasPrice90kgBag = 0;
        if(sale.DolichosPrice90kgBag == null) sale.DolichosPrice90kgBag = 0;
        if(sale.GreenGramsPrice90kgBag == null) sale.GreenGramsPrice90kgBag = 0;
        if(sale.MaizePrice90kgBag == null) sale.MaizePrice90kgBag = 0;
        if(sale.PigeonPeasPrice90kgBag == null) sale.PigeonPeasPrice90kgBag = 0;
        
        sale.SaleDate = sfSale.Sale_Date__c;        
        sale.BankDepositDate = sfBankDeposit.Deposit_Date__c;
        
        sale.SaleStatus = sfSale.Status__c;
        
        sale.CommercialVillage = sfSale.Commercial_Village__c;
        sale.VillageKnowledgeWorker = sfSale.VKW_Name__c;
        
        return sale;
    }
}