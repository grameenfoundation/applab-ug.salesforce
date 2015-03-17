@isTest
public with sharing class EWarehouseMEDashboardControllerTest {
    
    static void loadTestData(){
         // insert test data
        insertTestData();
        
        Country__c country = getTestCountry();
        insert country;
        
        District__c district = getTestDistrict();
        insert district;
        
        Person__c vkw = getTestPerson(country, district);
        vkw.Type__c = 'VKW';
        insert vkw;
        
    }
     
    static testMethod void testConstructor(){
        loadTestData();
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
    }
    
    static testMethod void getImpactData(){
        
        loadTestData();
        
        // create and insert country
        Country__c country = getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = getTestDistrict();
        insert district;
        
<<<<<<< HEAD
=======
        Contact contact = getTestContact();
        insert contact;
>>>>>>> origin/ci
        
        // create and insert 2 Persons
        Person__c person3 = getTestPerson(country, district);
        Person__c person4 = getTestPerson(country, district);
        person3.First_Name__c = 'John2';
        person3.Last_Name__c = 'Lennon2';
        person3.Gender__c = 'Male';
        person4.First_Name__c = 'John3';
        person4.Last_Name__c = 'Lennon3';
        person4.Gender__c = '';
        insert person3;
        insert person4;
        
        // with the person id, create and insert a Farmer
<<<<<<< HEAD
        Farmer__c farmer3 = getTestFarmer(person3);
        Farmer__c farmer4 = getTestFarmer(person4);
        farmer3.Name = '3eyUUD';
        farmer4.Name = '4eyUUD';
        insert farmer3;
        insert farmer4;
=======
        Ewarehouse_Farmer__c farmer3 = getTestFarmer(person3,contact);
        Ewarehouse_Farmer__c farmer4 = getTestFarmer(person4,contact);
        farmer3.Name = '3eyUUD';
        farmer3.Farmer_ID__c = '777';
        farmer4.Name = '4eyUUD';
        farmer4.Farmer_ID__c = '998';
        //insert farmer3;
        //insert farmer4;
>>>>>>> origin/ci
        
        PPI_Data__c ppi1 = new PPI_Data__c();
        ppi1.Person__c = person3.Id;
        ppi1.Question_1__c = '8';
        ppi1.Question_2__c = '8';
        ppi1.Question_3__c = '8';
        ppi1.Question_4__c = '8';
        ppi1.Question_5__c = '8';
        ppi1.Question_6__c = '8';
        ppi1.Question_7__c = '8';
        ppi1.Question_8__c = '8';
        ppi1.Question_9__c = '8';
        ppi1.Question_10__c = '8';
        ppi1.Score__c = 80.0;
        ppi1.Date__c = Date.newInstance(2013, 7, 25);
        ppi1.Version__c = '1';
        insert ppi1;
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> impactData = controller.getImpactData();
        System.debug('impactData = ' + impactData);
<<<<<<< HEAD
        System.assertEquals(15, impactData.size());
        Integer x = 0;
        System.assertEquals('No of farmers registered', impactData[x].Name);
        System.assertEquals('4', impactData[x++].Count);
=======
        System.assertEquals(11, impactData.size());
        Integer x = 0;
        System.assertEquals('No of farmers registered', impactData[x].Name);
        System.assertEquals('2', impactData[x++].Count);
>>>>>>> origin/ci
        System.assertEquals('By gender:', impactData[x].Name);
        System.assertEquals('', impactData[x++].Count);
        System.assertEquals('- Male', impactData[x].Name);
        System.assertEquals('50.0%', impactData[x++].Count);
        System.assertEquals('- Female', impactData[x].Name);
<<<<<<< HEAD
        System.assertEquals('25.0%', impactData[x++].Count);
        System.assertEquals('- Unknown', impactData[x].Name);
        System.assertEquals('25.0%', impactData[x++].Count);
        
        System.assertEquals('Poverty distribution:', impactData[x].Name);
        System.assertEquals('', impactData[x++].Count);
        System.assertEquals('- Below $2.50/day poverty line', impactData[x].Name);
        System.assertEquals('2.2%', impactData[x++].Count);
        System.assertEquals('- Below 150% of national poverty line', impactData[x].Name);
        System.assertEquals('6.7%', impactData[x++].Count);
        System.assertEquals('- Below extreme poverty line', impactData[x].Name);
        System.assertEquals('0.4%', impactData[x++].Count);
        
        System.assertEquals('No of farmers trained on post-harvest handling', impactData[x].Name);
        System.assertEquals('75.0%', impactData[x++].Count);
        System.assertEquals('No of farmers implementing new storage techniques', impactData[x].Name);
        System.assertEquals('100.0%', impactData[x++].Count);
        
        System.assertEquals('Total loans disbursed', impactData[x].Name);
=======
        System.assertEquals('50.0%', impactData[x++].Count);
        System.assertEquals('Poverty distribution:', impactData[x].Name);
        System.assertEquals('', impactData[x++].Count);
        
        System.assertEquals('No of farmers trained on post-harvest handling, Prior to e-Warehouse project', impactData[x].Name);
        //System.assertEquals('0.0%', impactData[x++].Count);
        System.assertEquals('20,470', impactData[x++].Count);
        System.assertEquals('No of farmers implementing new storage techniques', impactData[x].Name);
        //System.assertEquals('0.0%', impactData[x++].Count);
        System.assertEquals('12,552', impactData[x++].Count);
        System.assertEquals('Total loans disbursed', impactData[x].Name);
        System.assertEquals('33', impactData[x++].Count);
        System.assertEquals('Total loans repaid', impactData[x].Name);
        System.assertEquals('33', impactData[x++].Count);
        
        System.assertEquals('Loan repayment rate', impactData[x].Name);//u are here
        System.assertEquals('100%', impactData[x++].Count);
        System.assertEquals('No of farmers fully paid for sales', impactData[x].Name);
        System.assertEquals('0', impactData[x++].Count);
        
        //List Iindex Exception
        /*System.assertEquals('Total loans disbursed', impactData[x].Name);
>>>>>>> origin/ci
        System.assertEquals('2', impactData[x++].Count);
        System.assertEquals('Total loans repaid', impactData[x].Name);
        System.assertEquals('1', impactData[x++].Count);
        System.assertEquals('Loan repayment rate', impactData[x].Name);
        System.assertEquals('50.0%', impactData[x++].Count);
        System.assertEquals('No of farmers fully paid for sales', impactData[x].Name);
<<<<<<< HEAD
        System.assertEquals('4', impactData[x++].Count);
=======
        System.assertEquals('4', impactData[x++].Count);*/
>>>>>>> origin/ci
        
        /*
        Part of FCI information
        System.assertEquals('No of Village Knowledge Workers registered', impactData[x].Name);
        System.assertEquals('1', impactData[x++].Count);
        System.assertEquals('Increase in farmers storing grains and delaying sale', impactData[x].Name);
        System.assertEquals('0.00', impactData[x++].Count);
        System.assertEquals('Increase in farmers with access to financial services', impactData[x].Name);
        System.assertEquals('0.00', impactData[x++].Count);
        */
        
    }
    
    static testMethod void getFarmersByAcre(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getFarmersByAcre();
        
        System.assertEquals(2, testData.size());
<<<<<<< HEAD
        System.assertEquals('6 - 10 acre', testData[0].Name);
        System.assertEquals('50.0', testData[0].Count);
        System.assertEquals('31 - 40 acre', testData[1].Name);
=======
        System.assertEquals('9 - 11 acre', testData[0].Name);
        System.assertEquals('50.0', testData[0].Count);
        System.assertEquals('> 14 acre', testData[1].Name);
>>>>>>> origin/ci
        System.assertEquals('50.0', testData[1].Count);
        
    }
    
    static testMethod void getGrainCollected(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getGrainCollected();
        System.debug('getGrainCollected' + testData);
        System.assertEquals(6, testData.size());
<<<<<<< HEAD
        System.assertEquals('Beans', testData[0].Name);
        System.assertEquals('180', testData[0].Count);
=======
        System.assertEquals('Green grams', testData[0].Name);
        System.assertEquals('0', testData[0].Count);
>>>>>>> origin/ci
    }
    
    static testMethod void getGrainSold(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getGrainSold();
        System.debug('getGrainSold' + testData);
        System.assertEquals(0, testData.size());
        //System.assertEquals('Goats', testData[0].Name);
        //System.assertEquals('2', testData[0].Count);
    }
    
    
    
   public static Map<String, String> insertTestData(){
        
        Map<String, String> ids = new Map<String, String>();
        
<<<<<<< HEAD
=======
        Contact contact = getTestContact();
        insert contact;
       
>>>>>>> origin/ci
        // create and insert country
        Country__c country = getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = getTestDistrict();
        insert district;
<<<<<<< HEAD
=======
       
       // create bank deposits
        Bank_Deposit__c deposit1_1 = getBankDeposit(contact);
        Bank_Deposit__c deposit1_2 = getBankDeposit(contact);
        Bank_Deposit__c deposit2_1 = getBankDeposit(contact);
        Bank_Deposit__c deposit2_2 = getBankDeposit(contact);
        insert deposit1_1;
        insert deposit1_2;
        insert deposit2_1;
        insert deposit2_2;
>>>>>>> origin/ci
        
        // create and insert 2 Persons
        Person__c person1 = getTestPerson(country, district);
        Person__c person2 = getTestPerson(country, district);
        person2.First_Name__c = 'John';
        person2.Last_Name__c = 'Lennon';
        person2.Gender__c = 'Male';
        insert person1;
        insert person2;
        
        // with the person id, create and insert a Farmer
<<<<<<< HEAD
        Farmer__c farmer1 = getTestFarmer(person1);
        Farmer__c farmer2 = getTestFarmer(person2);
        farmer2.Name = '2eyUUD';
        farmer2.Land_Size__c = 10;
        farmer2.Had_Post_Harvest_Handling_Training__c = false;
=======
        Ewarehouse_Farmer__c farmer1 = getTestFarmer(person1,contact);
        Ewarehouse_Farmer__c farmer2 = getTestFarmer(person2,contact);
        farmer2.Name = '2eyUUD';
        farmer2.Farmer_ID__c = '997';
        farmer2.Land_Size__c = 10;
        farmer2.Post_Harvest_Training__c = false;
>>>>>>> origin/ci
        insert farmer1;
        insert farmer2;
        
        Group__c group1 = getGroup();
        insert group1;
        
        Person_Group_Association__c pga1 = getPersonGroupAsso(group1, person1);
        Person_Group_Association__c pga2 = getPersonGroupAsso(group1, person2);
        insert pga1;
        insert pga2;
        
<<<<<<< HEAD
        Harvest__c harvest1 = getHarvest(farmer1);
        Harvest__c harvest2 = getHarvest(farmer2);
=======
        Ewarehouse_Harvest__c harvest1 = getHarvest(farmer1);
        Ewarehouse_Harvest__c harvest2 = getHarvest(farmer2);
>>>>>>> origin/ci
        insert harvest1;
        insert harvest2;
        
        // create a loan
<<<<<<< HEAD
        Loan__c loan1 = getLoan(farmer1, harvest1);
        Loan__c loan2 = getLoan(farmer2, harvest2);
=======
        Ewarehouse_Loan__c loan1 = getLoan(farmer1, harvest1);
        Ewarehouse_Loan__c loan2 = getLoan(farmer2, harvest2);
>>>>>>> origin/ci
        loan2.Status__c = 'Repaid';
        insert loan1;
        insert loan2;
        
        // create sales
<<<<<<< HEAD
        Sale__c sale1_1 = getSale(farmer1);
        Sale__c sale1_2 = getSale(farmer1);
        Sale__c sale2_1 = getSale(farmer2);
        Sale__c sale2_2 = getSale(farmer2);
=======
        Sale_Record__c sale1_1 = getSale(farmer1,deposit1_1);
        Sale_Record__c sale1_2 = getSale(farmer1,deposit1_2);
        Sale_Record__c sale2_1 = getSale(farmer2,deposit2_1);
        Sale_Record__c sale2_2 = getSale(farmer2,deposit2_2);
>>>>>>> origin/ci
        insert sale1_1;
        insert sale1_2;
        insert sale2_1;
        insert sale2_2;
        
        // create loan repayments
<<<<<<< HEAD
        Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
        Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
        Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
        Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
=======
        Loan_Repayments__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
        Loan_Repayments__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
        Loan_Repayments__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
        Loan_Repayments__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
>>>>>>> origin/ci
        insert loanRepayment1_1;
        insert loanRepayment1_2;
        insert loanRepayment2_1;
        insert loanRepayment2_2;   
        
<<<<<<< HEAD
        Sale_Farmer_Association__c sf1 = getSaleFarmer(sale1_1, farmer1);
        Sale_Farmer_Association__c sf2 = getSaleFarmer(sale1_1, farmer2);
        Sale_Farmer_Association__c sf3 = getSaleFarmer(sale2_1, farmer1);
        Sale_Farmer_Association__c sf4 = getSaleFarmer(sale2_1, farmer2);
=======
        Sale_Farmer_Associations__c sf1 = getSaleFarmer(sale1_1, farmer1);
        Sale_Farmer_Associations__c sf2 = getSaleFarmer(sale1_1, farmer2);
        Sale_Farmer_Associations__c sf3 = getSaleFarmer(sale2_1, farmer1);
        Sale_Farmer_Associations__c sf4 = getSaleFarmer(sale2_1, farmer2);
>>>>>>> origin/ci
        insert sf1;
        insert sf2;
        insert sf3;
        insert sf4;
        
        ids.put('person1Id', person1.Id);
        ids.put('person2Id', person2.Id);
<<<<<<< HEAD
        ids.put('farmer1Id', farmer1.Id);
        ids.put('farmer2Id', farmer2.Id);
        ids.put('farmer1Name', farmer1.Name);
        ids.put('farmer2Name', farmer2.Name);
        ids.put('loan1Id', loan1.Id);
        ids.put('loan2Id', loan2.Id);
=======
       
        ids.put('farmer1Id', farmer1.Id);
        ids.put('farmer2Id', farmer2.Id);
       
        ids.put('farmer1Name', farmer1.Name);
        ids.put('farmer2Name', farmer2.Name);
       
        ids.put('loan1Id', loan1.Id);
        ids.put('loan2Id', loan2.Id);
       
        ids.put('deposit1_1Id', deposit1_1.Id);
        ids.put('deposit1_2Id', deposit1_2.Id);
        ids.put('deposit2_1Id', deposit2_1.Id);
        ids.put('deposit2_2Id', deposit2_2.Id);
       
>>>>>>> origin/ci
        ids.put('sale1_1Id', sale1_1.Id);
        ids.put('sale1_2Id', sale1_2.Id);
        ids.put('sale2_1Id', sale2_1.Id);
        ids.put('sale2_2Id', sale2_2.Id);
<<<<<<< HEAD
=======
       
>>>>>>> origin/ci
        ids.put('loanRepayment1_1Id', loanRepayment1_1.Id);
        ids.put('loanRepayment1_2Id', loanRepayment1_2.Id);
        ids.put('loanRepayment2_1Id', loanRepayment2_1.Id);
        ids.put('loanRepayment2_2Id', loanRepayment2_2.Id);
        ids.put('sf1Id', sf1.Id);
        ids.put('sf2Id', sf2.Id);
        ids.put('sf3Id', sf3.Id);
        ids.put('sf4Id', sf4.Id);
        
        system.debug(ids);

        return ids;
    }
    
    // mock data for test runs
    public static District__c getTestDistrict(){
        District__c district = new District__c();
        district.Name = 'Isiolo';
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
        person.Type__c = 'Farmer';
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
    
<<<<<<< HEAD
    public static Farmer__c getTestFarmer(Person__c person){
        Farmer__c farmer = new Farmer__c();
        farmer.Name = '3eyUUD';
=======
    /*public static Farmer__c getTestFarmer(Person__c person){
        Farmer__c farmer = new Farmer__c();
        farmer.Name = '3eyUUD';
        farmer.Farmer_ID__c = 
>>>>>>> origin/ci
        farmer.Person__c = person.Id;
        farmer.Status__c = 'Processed';
        farmer.Sale_Status__c = 'Paid';
        farmer.Land_Size__c = 35;
        farmer.Crops__c = 'Maize';
        farmer.Livestock__c = 'Goats';
        farmer.Had_Post_Harvest_Handling_Training__c = true;
        farmer.Crop_Storage_Material__c = 'Plastic bags';
        return farmer;
<<<<<<< HEAD
=======
    }*/
    
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
    //New Method with Ewarehouse_Farmer__c as the Object instead of Famer__c
    
    public static Ewarehouse_Farmer__c getTestFarmer(Person__c person, Contact contact){
        Ewarehouse_Farmer__c farmer = new Ewarehouse_Farmer__c();
        //farmer.Name = 'a3Bn0000000Cf6G';
        //farmer.Farmer_ID__c = '999';
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
>>>>>>> origin/ci
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
    
<<<<<<< HEAD
    public static Harvest__c getHarvest(Farmer__c farmer){
=======
    /*public static Harvest__c getHarvest(Farmer__c farmer){
>>>>>>> origin/ci
        Harvest__c h = new Harvest__c();
        h.Crop__c = 'Beans';
        h.Date_Harvested__c = date.newinstance(2013, 4, 30);
        h.Farmer__c = farmer.Id;
        h.Quantity_Accepted__c = 1000.01;
        h.Quantity_Harvested__c = 2000.03;
        h.Quantity_Rejected__c = 1000.02;
        h.Storage_Location__c = 'Home';
        return h;
<<<<<<< HEAD
    }
    
    public static Loan__c getLoan(Farmer__c farmer, Harvest__c harvest){
=======
    }*/
    //New Method with Ewarehouse_Farmer__c as the Object instead of Famer__c
    
    public static Ewarehouse_Harvest__c getHarvest(Ewarehouse_Farmer__c farmer){
        Ewarehouse_Harvest__c h = new Ewarehouse_Harvest__c();
        /*h.Beans_Harvested__c = 3;
        h.Black_Beans_Harvested__c = 3;
        h.Cow_Peas_Harvested__c = 3;
        h.Green_Grams_Harvested__c = 3;
        h.Maize_Harvested__c = 3;
        h.Pigeon_Peas_Harvested__c = 3;*/
        
        h.Harvest_Date__c = date.newinstance(2013, 4, 30);
        h.Ewarehouse_Farmer__c = farmer.Id;        
        h.Storage_Location__c = 'Home';
        return h;
    }
    
   /* public static Loan__c getLoan(Farmer__c farmer, Harvest__c harvest){
>>>>>>> origin/ci
        
        Loan__c loan = new Loan__c();
        loan.Amount_Applied_For__c = 130000;
        loan.Amount_Approved__c = 120000;
        loan.Application_Date__c = date.newinstance(2013, 4, 30);
        loan.Decision_Date__c = date.newinstance(2013, 5, 1);
        loan.Balance__c = 120000;
        loan.Status__c = 'Applied';
        loan.Currency__c = 'KES';
        loan.Farmer__c = farmer.Id; 
        if(harvest != null)
            loan.Harvest__c = harvest.Id; 
        
        return loan;
        
<<<<<<< HEAD
    }
    
    public static Sale__c getSale(Farmer__c farmer){
=======
    }*/
    //New Method with Ewarehouse_Farmer__c as the Object instead of Famer__c
     public static Ewarehouse_Loan__c getLoan(Ewarehouse_Farmer__c farmer, Ewarehouse_Harvest__c harvest){
        
        Ewarehouse_Loan__c loan = new Ewarehouse_Loan__c();
        loan.Amount_Applied__c = 130000;
        loan.Amount_Approved__c = 120000;
        loan.Application_Date__c = date.newinstance(2013, 4, 30);
        loan.Decision_Date__c = date.newinstance(2013, 5, 1);
        loan.Balance__c = 120000;
        loan.Status__c = 'Applied';
        //loan.Currency__c = 'KES';
        loan.Ewarehouse_Farmer__c = farmer.Id; 
         if(harvest != null){
             loan.Ewarehouse_Harvest__c = harvest.Id; 
         }
            
        
        return loan;
        
    }
    
   /* public static Sale__c getSale(Farmer__c farmer){
>>>>>>> origin/ci
        Sale__c sale = new Sale__c();
        //sale.Farmer__c = farmer.Id;
        sale.Status__c = 'New';
        
        return sale;
        
<<<<<<< HEAD
    }
    
    public static Sale_Farmer_Association__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
=======
    }*/
    
    //Add Deposit details
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
    //New Method with Ewarehouse_Farmer__c as the Object instead of Famer__c
    public static Sale_Record__c getSale(Ewarehouse_Farmer__c farmer,Bank_Deposit__c deposit){
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
    
    /*public static Sale_Farmer_Association__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
>>>>>>> origin/ci
        Sale_Farmer_Association__c sf = new Sale_Farmer_Association__c();
        //sf.Amount_Applied__c = 6000.10;
        sf.Fee_Due__c = 5000.10;
        sf.Fee_Paid__c = 4000.10;
        sf.Farmer__c = farmer.Id;
        sf.Sale__c = sale.Id;
        return sf;
<<<<<<< HEAD
    }
    
    public static Loan_Repayment__c getLoanRepayment(Loan__c loan, Sale__c sale){

        Loan_Repayment__c lr = new Loan_Repayment__c();
        lr.Amount__c = 1500.00;
        lr.Payment_Date__c = date.newinstance(2013, 4, 30);
        lr.Remarks__c = 'reason';
        lr.Loan__c = loan.Id;
        lr.Sale__c = sale.Id;
=======
    }*/
    //New Method with Ewarehouse_Farmer__c as the Object instead of Famer__c
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
    
    public static Loan_Repayments__c getLoanRepayment(Ewarehouse_Loan__c loan, Sale_Record__c sale){

        Loan_Repayments__c lr = new Loan_Repayments__c();
        lr.Amount__c = 1500.00;
        lr.Payment_Date__c = date.newinstance(2013, 4, 30);
        lr.Remarks__c = 'reason';
        lr.Ewarehouse_Loan__c = loan.Id;
        lr.Ewarehouse_Sale__c = sale.Id;
>>>>>>> origin/ci
        
        return lr;
        
    }
    
    public static Commodities__c getCommodity(){
        Commodities__c c = new Commodities__c();
        
        c.Name = 'Beans';
        c.Highest_Wholesale_Price__c = 200;
        
        return c;
        
    }
}