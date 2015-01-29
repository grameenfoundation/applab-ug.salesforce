public with sharing class EwarehouseDataSourceMock {
    
    private static ServiceLogger logger = new ServiceLogger();
    
    public static Map<String, String> insertTestData(){
        
        Map<String, String> ids = new Map<String, String>();
        
        // create and insert country
        Country__c country = getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = getTestDistrict();
        insert district;
        
        Contact contact = getTestContact();
        insert contact;
        
        // create and insert 2 Persons
        Person__c person1 = getTestPerson(country, district);
        Person__c person2 = getTestPerson(country, district);
        person2.First_Name__c = 'John';
        person2.Last_Name__c = 'Lennon';
        person2.Gender__c = 'Male';
        insert person1;
        insert person2;
        
        // with the person id, create and insert a Farmer
        Ewarehouse_Farmer__c farmer1 = getTestFarmer(person1, contact);
        Ewarehouse_Farmer__c farmer2 = getTestFarmer(person2, contact);
        farmer2.Farmer_ID__c = '002';
        farmer2.Name = 'a3Bn0000000CfPI';
        farmer2.Land_Size__c = 10;
        insert farmer1;
        insert farmer2;
        
        Group__c group1 = getGroup();
        insert group1;
        
        Person_Group_Association__c pga1 = getPersonGroupAsso(group1, person1);
        Person_Group_Association__c pga2 = getPersonGroupAsso(group1, person2);
        insert pga1;
        insert pga2;
        
        // create bank deposits
        Bank_Deposit__c deposit1_1 = getBankDeposit(contact);
        Bank_Deposit__c deposit1_2 = getBankDeposit(contact);
        Bank_Deposit__c deposit2_1 = getBankDeposit(contact);
        Bank_Deposit__c deposit2_2 = getBankDeposit(contact);
        insert deposit1_1;
        insert deposit1_2;
        insert deposit2_1;
        insert deposit2_2;
        
        // create sales
        Sale_Record__c sale1_1 = getTestSale(deposit1_2);
        sale1_1.Name = 'a3Hn00000008X2R';
        
        Sale_Record__c sale1_2 = getTestSale(deposit1_2);
        sale1_2.Name = 'a3Hn00000008X0B';
        
        Sale_Record__c sale2_1 = getTestSale(deposit2_1);
        sale2_1.Name = 'a3Hn00000008X06';
        
        Sale_Record__c sale2_2 = getTestSale(deposit2_2);
        sale2_2.Name = 'a3Hn00000008X01';
        insert sale1_1;
        insert sale1_2;
        insert sale2_1;
        insert sale2_2;
                
        // create sale-farmer-assos
        Sale_Farmer_Associations__c sf1 = getSaleFarmer(sale1_1, farmer1);
        Sale_Farmer_Associations__c sf2 = getSaleFarmer(sale1_2, farmer2);
        Sale_Farmer_Associations__c sf3 = getSaleFarmer(sale2_1, farmer1);
        Sale_Farmer_Associations__c sf4 = getSaleFarmer(sale2_2, farmer2);
        insert sf1;
        insert sf2;
        insert sf3;
        insert sf4;
                
        ids.put('person1Id', person1.Id);
        ids.put('person2Id', person2.Id);
        ids.put('farmer1Id', farmer1.Id);
        ids.put('farmer2Id', farmer2.Id);
        ids.put('farmer1Name', farmer1.Name);
        ids.put('farmer2Name', farmer2.Name);
        
        ids.put('sale1_1Id', sale1_1.Id);
        ids.put('sale1_2Id', sale1_2.Id);
        ids.put('sale2_1Id', sale2_1.Id);
        ids.put('sale2_2Id', sale2_2.Id);
        
        ids.put('sale1_1Name', sale1_1.Name);
        ids.put('sale1_2Name', sale1_2.Name);
        ids.put('sale2_1Name', sale2_1.Name);
        ids.put('sale2_2Name', sale2_2.Name);
        
        ids.put('deposit1_1Id', deposit1_1.Id);
        ids.put('deposit1_2Id', deposit1_2.Id);
        ids.put('deposit2_1Id', deposit2_1.Id);
        ids.put('deposit2_2Id', deposit2_2.Id);
        
        ids.put('sf1Id', sf1.Id);
        ids.put('sf2Id', sf2.Id);
        ids.put('sf3Id', sf3.Id);
        ids.put('sf4Id', sf4.Id);
        
        logger.debug(ids);

        return ids;
    }
    
    public static Contact getTestContact(){
        Contact c = new Contact();
        c.FirstName = 'Johnny';
        c.LastName = 'Depp';
        c.Birthdate= date.newinstance(1937, 12, 21);
        c.OtherCity= 'Kisumu city';
        c.Marital_Status__c = 'Single';
        c.Spouse_Name__c = 'Oskar';
        c.Picture_Url__c = 'http://www.himmelreich-it.com/image.jpg';
        
        return c;
    }
    
    // mock data for test runs
    public static District__c getTestDistrict(){
        District__c district = new District__c();
        district.Name = 'TIGANIA WEST';
        return district;
    }
    
    public static Country__c getTestCountry(){
        Country__c country = new Country__c();
        country.Name = 'Kenya';
        country.ISO_Standard_Code__c = 'KE';
        country.Language__c = 'Swahili';
        return country;
    }

    public static Person__c getTestPerson(Country__c country, District__c district){
        
        Person__c person = new Person__c();
        
        person.First_Name__c = 'Jane';
        person.Middle_Name__c = 'The Actrice';
        person.Last_Name__c = 'Fonda';
        person.Date_of_Birth__c = date.newinstance(1937, 12, 21);
        person.Raw_Mobile_Number__c = '+254123456789';
        person.Gender__c = 'Female';
        person.Village__c = 'Kisumu';
        person.City__c = 'Kisumu city';
        person.District__c = district.Id;
        person.Country__c = country.Id;
        person.ID_Number__c = 'ID0987654321';
        person.Picture_URL__c = 'http://www.himmelreich-it.com/image.jpg';
        person.Next_Of_Kin__c = 'Ted Turner';
        person.Next_Of_Kin_Telephone__c = '+254123456788';
        
        return person;
    }
    
    public static Ewarehouse_Farmer__c getTestFarmer(Person__c person, Contact contact){
        Ewarehouse_Farmer__c farmer = new Ewarehouse_Farmer__c();
        
        farmer.Name = 'a3Bn0000000Cf6G';
        farmer.Farmer_ID__c = '999';
        farmer.Commercial_Villages__c = 'ATHWANA';
        farmer.District__c = 'TIGANIA WEST';
        farmer.Commercial_Purchase_Groups__c = 'KARATHIA WOMEN GROUP';
        
        farmer.Ewarehouse_Person__c = person.Id;
        farmer.Contact__c = contact.Id;
        farmer.Land_Size__c = 35;
        farmer.Status__c = 'Processed';
        farmer.Crops__c = 'Maize';
        
        //farmer.District__c = 'TIGANIA WEST';
        farmer.Registration_Date__c = datetime.newinstance(2013, 4, 30, 12, 34, 54);
        //farmer.Commercial_Purchase_Groups__c = 'KARATHIA WOMEN GROUP';
        farmer.Registered_By__c = contact.Id;
        
        return farmer;
    }
    
    public static Group__c getGroup(){
        Group__c groupC = new Group__c();
        groupC.Name = 'Kiruri Farmers';
        groupC.Group_ID__c = 'A12/012/001/002';
        return groupC;
    }
    
    public static Person_Group_Association__c getPersonGroupAsso(Group__c groupC, Person__c person){
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Group__c = groupC.Id;
        pga.Person__c = person.Id;
        return pga;
    }
    
    public static Sale_Record__c getTestSale(Bank_Deposit__c deposit){
        
        Sale_Record__c sale = new Sale_Record__c();
        sale.Bank_Deposit__c = deposit.Id;
        sale.Beans_Number_of_90kg_Bags__c = 1;
        sale.Commercial_Purchase_Group__c='a1cn00000004RwWAAU a1cn00000004RwXAAU';
        sale.Tigania_East_Commercial_Village__c='';
        sale.Tigania_West_Commercial_Village__c='ATHWANA';
        sale.Beans_Price_per_90kg_Bag__c = 10;
        sale.Cow_Peas_Number_of_90kg_Bags__c = 2;
        sale.Cow_Peas_Price_per_90kg_Bag__c = 20;
        sale.Dolichos_Number_of_90kg_Bags__c = 3;
        sale.Dolichos_Price_per_90kg_Bag__c = 30;
        sale.Green_Grams_Number_of_90kg_Bags__c = 4;
        sale.Green_Grams_Price_per_90kg_Bag__c = 40;
        sale.Maize_Number_of_90kg_Bags__c = 5;
        sale.Maize_Price_per_90kg_Bag__c = 50;
        
        sale.Pigeon_Peas_Total_Amount__c = 6;
        sale.Pigeon_Peas_Price_per_90kg_Bag__c = 60;
        
        sale.Sale_Date__c = date.newInstance(2014, 2, 4);
        sale.VKW_Name__c = 'Steven Mugo';
        sale.Ewarehouse_Sale_Total_Amount__c = '45000';
        
        //sale.Status__c = 
        //sale.Farmer__c = farmer.Id;
        //sale.Status__c = 'New';
        
        return sale;
        
    }
    
    public static Sale_Farmer_Associations__c getSaleFarmer(Sale_Record__c sale, Ewarehouse_Farmer__c farmer){
        
        Sale_Farmer_Associations__c sf = new Sale_Farmer_Associations__c();
        
        sf.Beans_Number_of_90kg_Bags__c = sale.Beans_Number_of_90kg_Bags__c;
        sf.Cow_Peas_Number_of_90kg_Bags__c = sale.Cow_Peas_Number_of_90kg_Bags__c;
        sf.Dolichos_Number_of_90kg_Bags__c = sale.Dolichos_Number_of_90kg_Bags__c;
        sf.Green_Grams_Number_of_90kg_Bags__c = sale.Green_Grams_Number_of_90kg_Bags__c;
        sf.Maize_Number_of_90kg_Bags__c = sale.Maize_Number_of_90kg_Bags__c;
        sf.Pigeon_Peas_Number_of_90kg_Bags__c = sale.Pigeon_Peas_Total_Amount__c;
        
        sf.Ewarehouse_Farmer__c = farmer.Id;
        sf.Ewarehouse_Sale__c = sale.Id;
        sf.Sale_Farmer_Unique_ID__c = sf.Ewarehouse_Sale__c+''+farmer.Id;
        
        sf.Name = 'SF-001';
        
        return sf;
    }
        
    public static Bank_Deposit__c getBankDeposit(Contact c){
        Bank_Deposit__c deposit = new Bank_Deposit__c();
        deposit.Amount__c = 100;
        deposit.Bank_Transaction_Id__c = 'TRXBD-001';
        deposit.Commercial_Purchase_Groups__c = 'CPG-001';
        deposit.Deposit_Date__c = date.newInstance(2014, 2, 5);
        deposit.District__c = 'TIGANIA WEST';
        deposit.Name = 'a3Kn00000004E5z';
        deposit.Registered_By__c = c.Id;
        
        return deposit;
    }
    
    
    // mock datasource implementations
    public class AllExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
        public List<Ewarehouse_Farmer__c> getFarmer(String name){
            throwError();
            return null;
        }
        
        public List<Ewarehouse_Farmer__c> getFarmersByStatus(String status){
            throwError();
            return null;
        }
        
        public Ewarehouse_Farmer__c[] getFarmers(Set<String> farmerIds){
            throwError();
            return null;
        }
        
        public Database.SaveResult updateFarmer(Ewarehouse_Farmer__c farmer){
            throwError();
            return null;
        }
        
        public Sale_Farmer_Associations__c[] getSales(String status){
            throwError();
            return null;
        }
        
        public Sale_Record__c[] getSales(Set<String> saleIds){
            throwError();
            return null;
        }
    
        public Database.SaveResult updateSale(Sale_Record__c sale){
            throwError();
            return null;
        }
    }
    
    public class UpdateFarmerLoanExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
        EwarehouseDataSource ds = new EwarehouseDataSource();
        public List<Ewarehouse_Farmer__c> getFarmer(String name){
            return ds.getFarmer(name);
        }
        
        public List<Ewarehouse_Farmer__c> getFarmersByStatus(String status){
            throwError();
            return null;
        }
        
        public Ewarehouse_Farmer__c[] getFarmers(Set<String> farmerIds){
            throwError();
            return null;
        }
        
        public Database.SaveResult updateFarmer(Ewarehouse_Farmer__c farmer){
            throwError();
            return null;
        }
        
        public Sale_Farmer_Associations__c[] getSales(String status){
            throwError();
            return null;
        }
        
        public Sale_Record__c[] getSales(Set<String> saleIds){
            throwError();
            return null;
        }
    
        public Database.SaveResult updateSale(Sale_Record__c sale){
            throwError();
            return null;
        }
        
    }
    
    public static void throwError(){
        insert new Ewarehouse_Farmer__c();
    }
    
}