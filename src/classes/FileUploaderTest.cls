public with sharing class FileUploaderTest {
	public static testMethod void testFileUploader(){
		insertTestData();
		FileUploader fu = new FileUploader();
		fu.contentFile = Blob.valueOf('FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\nJohn Doe,4euODw,NI-22345,22345,22345,LD423456,20130721,20130922,8000,10001');
		PageReference pr = fu.readFile();
	}
	
	public static testMethod void testFileUploaderNoFile(){
		FileUploader fu = new FileUploader();
		PageReference pr = fu.readFile();
	}
	
	public static testMethod void testFileUploaderError(){
		FileUploader fu = new FileUploader();
		fu.contentFile = Blob.valueOf('FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\nJohn Doe,4euODw,NI-22345,22345,22345,LD423456,20130721,20130922,8000,10001');
		fu.addError('Error');
		PageReference pr = fu.readFile();
	}
	
	public static testMethod void testFileUploaderException(){
		
		for(Integer x = 1;  x <= 6; x++){
			FileUploader fu = new FileUploader();
			fu.contentFile = Blob.valueOf('FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\nJohn Doe,4euODw,NI-22345,22345,22345,LD423456,20130721,20130922,8000,10001');
		
		    fu.testFailure = x;
		    Boolean exceptionThrown = false;
		    try{
		        PageReference pr = fu.readFile();
		    }catch (Exception e){
		        exceptionThrown = true;
		    }
		    // Fail the test if the expected NullValueNotAllowedException is not thrown.
		    System.assert(true, exceptionThrown);
			
		}
		
	}
	
	public static testMethod void testFileUploaderSizeLimit(){
		FileUploader fu = new FileUploader();
		String content = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\n';
		for(Integer x = 0; x <= 1003; x++){
			content += 'John Doe'+x+','+x+'euODw,NI-22345,22345,22345,LD423456,20130721,20130922,8000,10001\n';
		}
		fu.contentFile = Blob.valueOf(content);
		PageReference pr = fu.readFile();
	}
	
	public static testMethod void testFileUploaderValidation(){
		FileUploader fu = new FileUploader();
		String content = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\n';
		content += 'Sav,3eyUUD,NI-12345,SAV12345,LN-12345,LC12345,20130721,20130922,10002,10003\n';
		content += 'LoanAcc,4euODw,NI-22345,22345,LN22345,LD1234567890,20130721,20130922,10000,10001\n';
		content += 'LoanContract,5eyUUD,NI-12345,12345,12345,1234567890,20130721,20130922,10002,10003\n';
		content += 'Dsiburse,6euODw,NI-22345,22345,22345,LD1234567890,2013072,20130922,10000,10001\n';
		content += 'Maturity,7eyUUD,NI-12345,12345,12345,LD1234567890,20130721,2013092,10002,10003';
		
		fu.contentFile = Blob.valueOf(content);
		PageReference pr = fu.readFile();
	}
	
	public static Map<String, String> insertTestData(){
        
        Map<String, String> ids = new Map<String, String>();
        
        // create and insert country
        Country__c country = getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = getTestDistrict();
        insert district;
        
        // create and insert 2 Persons
        Person__c person1 = getTestPerson(country, district);
        Person__c person2 = getTestPerson(country, district);
        person2.First_Name__c = 'John';
        person2.Last_Name__c = 'Lennon';
        person2.Gender__c = 'Male';
        insert person1;
        insert person2;
        
        // with the person id, create and insert a Farmer
        Farmer__c farmer1 = getTestFarmer(person1);
        Farmer__c farmer2 = getTestFarmer(person2);
        farmer2.Name = '4euODw';
        farmer2.Land_Size__c = 10;
        farmer2.Had_Post_Harvest_Handling_Training__c = false;
        insert farmer1;
        insert farmer2;
        
        Group__c group1 = getGroup();
        insert group1;
        
        Person_Group_Association__c pga1 = getPersonGroupAsso(group1, person1);
        Person_Group_Association__c pga2 = getPersonGroupAsso(group1, person2);
        insert pga1;
        insert pga2;
        
        Harvest__c harvest1 = getHarvest(farmer1);
        Harvest__c harvest2 = getHarvest(farmer2);
        insert harvest1;
        insert harvest2;
        
        // create a loan
        Loan__c loan1 = getLoan(farmer1, harvest1);
        Loan__c loan2 = getLoan(farmer2, harvest2);
        loan2.Status__c = 'Repaid';
        insert loan1;
        insert loan2;
        
        // create sales
        Sale__c sale1_1 = getSale(farmer1);
        Sale__c sale1_2 = getSale(farmer1);
        Sale__c sale2_1 = getSale(farmer2);
        Sale__c sale2_2 = getSale(farmer2);
        insert sale1_1;
        insert sale1_2;
        insert sale2_1;
        insert sale2_2;
        
        // create loan repayments
        Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
        Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
        Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
        Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
        insert loanRepayment1_1;
        insert loanRepayment1_2;
        insert loanRepayment2_1;
        insert loanRepayment2_2;   
        
        Sale_Farmer_Association__c sf1 = getSaleFarmer(sale1_1, farmer1);
        Sale_Farmer_Association__c sf2 = getSaleFarmer(sale1_1, farmer2);
        Sale_Farmer_Association__c sf3 = getSaleFarmer(sale2_1, farmer1);
        Sale_Farmer_Association__c sf4 = getSaleFarmer(sale2_1, farmer2);
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
        ids.put('loan1Id', loan1.Id);
        ids.put('loan2Id', loan2.Id);
        ids.put('sale1_1Id', sale1_1.Id);
        ids.put('sale1_2Id', sale1_2.Id);
        ids.put('sale2_1Id', sale2_1.Id);
        ids.put('sale2_2Id', sale2_2.Id);
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
    
    public static Farmer__c getTestFarmer(Person__c person){
        Farmer__c farmer = new Farmer__c();
        farmer.Name = '3eyUUD';
        farmer.Person__c = person.Id;
        farmer.Status__c = 'Processed';
        farmer.Sale_Status__c = 'Paid';
        farmer.Land_Size__c = 35;
        farmer.Crops__c = 'Maize';
        farmer.Livestock__c = 'Goats';
        farmer.Had_Post_Harvest_Handling_Training__c = true;
        farmer.Crop_Storage_Material__c = 'Plastic bags';
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
    
    public static Harvest__c getHarvest(Farmer__c farmer){
        Harvest__c h = new Harvest__c();
        h.Crop__c = 'Beans';
        h.Date_Harvested__c = date.newinstance(2013, 4, 30);
        h.Farmer__c = farmer.Id;
        h.Quantity_Accepted__c = 1000.01;
        h.Quantity_Harvested__c = 2000.03;
        h.Quantity_Rejected__c = 1000.02;
        h.Storage_Location__c = 'Home';
        return h;
    }
    
    public static Loan__c getLoan(Farmer__c farmer, Harvest__c harvest){
        
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
        
    }
    
    public static Sale__c getSale(Farmer__c farmer){
        Sale__c sale = new Sale__c();
        //sale.Farmer__c = farmer.Id;
        sale.Status__c = 'New';
        
        return sale;
        
    }
    
    public static Sale_Farmer_Association__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
        Sale_Farmer_Association__c sf = new Sale_Farmer_Association__c();
        //sf.Amount_Applied__c = 6000.10;
        sf.Fee_Due__c = 5000.10;
        sf.Fee_Paid__c = 4000.10;
        sf.Farmer__c = farmer.Id;
        sf.Sale__c = sale.Id;
        return sf;
    }
    
    public static Loan_Repayment__c getLoanRepayment(Loan__c loan, Sale__c sale){

        Loan_Repayment__c lr = new Loan_Repayment__c();
        lr.Amount__c = 1500.00;
        lr.Payment_Date__c = date.newinstance(2013, 4, 30);
        lr.Remarks__c = 'reason';
        lr.Loan__c = loan.Id;
        lr.Sale__c = sale.Id;
        
        return lr;
        
    }
    
    public static Commodities__c getCommodity(){
        Commodities__c c = new Commodities__c();
        
        c.Name = 'Beans';
        c.Highest_Wholesale_Price__c = 200;
        
        return c;
        
    }
	
	
	
}