@isTest
public class SmepCsvUploadTest {
    /*
    static testMethod void smepCsvUpload() 
    {
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        Map<String, String> ids = DataSourceMock.insertTestData();
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        system.debug('Farmer Id=' + id);
        
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
        
        Blob bodyBlob = Blob.valueOf('FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo\nJohn Doe,3eyUUD,NI-12345,SAV-12345,LN-12345,LC-12345');
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug(c.getErrors());
        System.assertEquals(0, c.getErrors().size());
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
        
    }
    
    static testMethod void smepCsvUploadLimit()
    {
    	// this method does not need to run all the time...
    	return;
    	
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        // create and insert country
        Country__c country = DataSourceMock.getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = DataSourceMock.getTestDistrict();
        insert district;
        
        List<Person__c> persons = new List<Person__c>();
        List<Farmer__c> farmers = new List<Farmer__c>();
        
        for(Integer x = 1; x <= 1000; x++){
            Person__c person = DataSourceMock.getTestPerson(country, district);
            persons.add(person);
        }
        insert persons;
        
        for(Integer x = 1; x <= 1000; x++){
            Farmer__c farmer = DataSourceMock.getTestFarmer(persons[x - 1]);
            farmer.Name = farmer.Name + x;
            farmers.add(farmer);
        }
        insert farmers;
        
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
        
        String csvContent = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo\n';
        for(Farmer__c farmer : farmers){
        	String[] params = new String[]{farmer.Person__r.First_Name__c, farmer.Person__r.Middle_Name__c, farmer.Person__r.Last_Name__c, farmer.Name};
        	csvContent += String.format('{0} {1} {2},{3},NI-12345,SAV-12345,LN-12345,LC-12345\n', params);
        }
        
        Blob bodyBlob = Blob.valueOf(csvContent);
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug(c.getErrors());
        System.assertEquals(0, c.getErrors().size());
        System.assertEquals(1000, c.getUpdates().size());
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
        
    }
    
    static testMethod void smepCsvUploadOverLimit() {
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        String csvContent = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo\n';
        for(Integer x = 1; x <= 1011; x++){
        	String[] params = new String[]{'John', String.valueOf(x), 'Doe', 'xx' + String.valueOf(x)};
            csvContent += String.format('{0} {1} {2},{3},NI-12345,SAV-12345,LN-12345,LC-12345\n', params);
        }
       
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
                     
        Blob bodyBlob = Blob.valueOf(csvContent);
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug('Errors: ' + c.getErrors());
        System.debug('Updates: ' + c.getUpdates().size());
        System.assertEquals(1, c.getErrors().size());
        
        String message = String.format('{0} {1}', new String[]{System.Label.csvfile_sizelimit, System.Label.contact_support});
        System.assertEquals(message, c.getErrors()[0]);
        
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
    }
    
    static testMethod void smepCsvUploadFileError() {
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        String csvContent = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo\n';
        csvContent += 'JohnDoe,1012,NI-12345,54321,12345,LD12345\n';
        csvContent += 'JohnDoe,1013,NI-1234';
        
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
                     
        Blob bodyBlob = Blob.valueOf(csvContent);
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug('Errors: ' + c.getErrors());
        System.debug('Updates: ' + c.getUpdates().size());
        System.assertEquals(1, c.getErrors().size());
        
        String message = String.format(System.Label.csvimport_parseerrorline_msg,  new String[]{String.valueOf(3)});
        System.assertEquals(message, c.getErrors()[0]);
        
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
    }
    
    static testMethod void smepCsvUploadInfoOnly() {
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        
        // create and insert country
        Country__c country = DataSourceMock.getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = DataSourceMock.getTestDistrict();
        insert district;
        
        Person__c person1 = DataSourceMock.getTestPerson(country, district);
        Person__c person2 = DataSourceMock.getTestPerson(country, district);
        insert person1;
        insert person2;
        
        Farmer__c farmer1 = DataSourceMock.getTestFarmer(person1);
        farmer1.Name = '1012';
        Farmer__c farmer2 = DataSourceMock.getTestFarmer(person2);
        farmer2.Name = '1013';
        
        insert farmer1;
        insert farmer2;
        
        String csvContent = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo\n';
        csvContent += 'JohnDoe,1012,NI-12345,54321,12345,LD12345\n';
        csvContent += 'JohnDoe2,1013,NI-22345,54322,22345,LD22345\n';
        
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
                     
        Blob bodyBlob = Blob.valueOf(csvContent);
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug('Errors: ' + c.getErrors());
        System.debug('Updates: ' + c.getUpdates().size());
        System.assertEquals(0, c.getErrors().size());
        
        List<Person__c> tPerson1 = [SELECT ID, Name, ID_Number__c FROM Person__c WHERE Id = :person1.Id];
        System.assertEquals(1, tPerson1.size());
        System.assertEquals('NI-12345', tPerson1[0].ID_Number__c);
        
        List<Person__c> tPerson2 = [SELECT ID, Name, ID_Number__c FROM Person__c WHERE Id = :person2.Id];
        System.assertEquals(1, tPerson2.size());
        System.assertEquals('NI-22345', tPerson2[0].ID_Number__c);
        
        List<Loan__c> tLoan1 = [SELECT ID, Name, Saving_Account_No__c, Loan_Account_No__c, Loan_Contract_No__c FROM Loan__c WHERE Farmer__c = :farmer1.Id];
        System.assertEquals(1, tLoan1.size());
        System.assertEquals('54321', tLoan1[0].Saving_Account_No__c);
        System.assertEquals('12345', tLoan1[0].Loan_Account_No__c);
        System.assertEquals('LD12345', tLoan1[0].Loan_Contract_No__c);
        
        List<Loan__c> tLoan2 = [SELECT ID, Name, Saving_Account_No__c, Loan_Account_No__c, Loan_Contract_No__c FROM Loan__c WHERE Farmer__c = :farmer2.Id];
        System.assertEquals(1, tLoan2.size());
        System.assertEquals('54322', tLoan2[0].Saving_Account_No__c);
        System.assertEquals('22345', tLoan2[0].Loan_Account_No__c);
        System.assertEquals('LD22345', tLoan2[0].Loan_Contract_No__c);
             
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
    }
    
    static testMethod void smepCsvUploadMix() {
        System.debug('Unit Test: SmepCsvIpload Controller');
        
        
        // create and insert country
        Country__c country = DataSourceMock.getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = DataSourceMock.getTestDistrict();
        insert district;
        
        Person__c person1 = DataSourceMock.getTestPerson(country, district);
        Person__c person2 = DataSourceMock.getTestPerson(country, district);
        insert person1;
        insert person2;
        
        Farmer__c farmer1 = DataSourceMock.getTestFarmer(person1);
        farmer1.Name = '1012';
        Farmer__c farmer2 = DataSourceMock.getTestFarmer(person2);
        farmer2.Name = '1013';
        
        insert farmer1;
        insert farmer2;
        
        Harvest__c harvest1 = DataSourceMock.getHarvest(farmer1);
        insert harvest1;
        Loan__c loan1 = DataSourceMock.getLoan(farmer1, harvest1);
        loan1.Saving_Account_No__c = '54321';
        loan1.Loan_Account_No__c = '12345';
        loan1.Loan_Contract_No__c = 'LD12345';
        insert loan1;
         
        String csvContent = 'FarmerClientName,FCIID,NationalID,SavingsAccountNo,LoanAccountNo,LoanContractNo,DisbursementDate,MaturityDate,LoanBalance,LoanAmount\n';
        csvContent += 'JohnDoe,1012,NI-12345,54321,12345,LD12345,20130721,20130922,10000,10001\n';
        csvContent += 'JohnDoe2,1013,NI-22345,54322,22345,LD22345\n';
        
        //Set current page to AttachOppPaperwork
        PageReference oPage = new PageReference('/apex/uploadaccounts');
        Test.setCurrentPage(oPage);
        
        //Instantiate Controller
        FileUploader c = new FileUploader();
                     
        Blob bodyBlob = Blob.valueOf(csvContent);
        c.contentFile = bodyBlob;
        
        //Verify variable values
        System.assertNotEquals(null, c.contentFile); //c.file instantiated
        
        //Test File Upload
        System.debug('-->FileUploader.readFile() called');
        
        //upload the attachment
        PageReference uploadTest = c.readFile();
        
        System.debug('Errors: ' + c.getErrors());
        System.debug('Updates: ' + c.getUpdates().size());
        System.assertEquals(0, c.getErrors().size());
        
        List<Person__c> tPerson1 = [SELECT ID, Name, ID_Number__c FROM Person__c WHERE Id = :person1.Id];
        System.assertEquals(1, tPerson1.size());
        System.assertEquals('NI-12345', tPerson1[0].ID_Number__c);
        
        List<Person__c> tPerson2 = [SELECT ID, Name, ID_Number__c FROM Person__c WHERE Id = :person2.Id];
        System.assertEquals(1, tPerson2.size());
        System.assertEquals('NI-22345', tPerson2[0].ID_Number__c);
        
        List<Loan__c> tLoan1 = [SELECT ID, Name, Saving_Account_No__c, Loan_Account_No__c, Loan_Contract_No__c,
                                Disburse_Date__c, Maturity_Date__c, Balance__c, Amount_Approved__c
                                FROM Loan__c WHERE Id = :loan1.Id];
        System.assertEquals(1, tLoan1.size());
        System.assertEquals(loan1.Id, tLoan1[0].Id);
        System.assertEquals('54321', tLoan1[0].Saving_Account_No__c);
        System.assertEquals('12345', tLoan1[0].Loan_Account_No__c);
        System.assertEquals('LD12345', tLoan1[0].Loan_Contract_No__c);
        System.assertEquals(Date.newinstance(2013, 7, 21), tLoan1[0].Disburse_Date__c);
        System.assertEquals(Date.newinstance(2013, 9, 22), tLoan1[0].Maturity_Date__c); //0200-12-02
        System.assertEquals(10000, tLoan1[0].Balance__c);
        System.assertEquals(10001, tLoan1[0].Amount_Approved__c);
        
        List<Loan__c> tLoan2 = [SELECT ID, Name, Saving_Account_No__c, Loan_Account_No__c, Loan_Contract_No__c FROM Loan__c WHERE Farmer__c = :farmer2.Id];
        System.assertEquals(1, tLoan2.size());
        System.assertEquals('54322', tLoan2[0].Saving_Account_No__c);
        System.assertEquals('22345', tLoan2[0].Loan_Account_No__c);
        System.assertEquals('LD22345', tLoan2[0].Loan_Contract_No__c);
             
        System.assertEquals(null, uploadTest); //method should return null, refreshing the page
    }
    
     */
    static testMethod void smepCsvUploadRegEx(){
        
        Pattern loanContractRegex = Pattern.compile('LD[0-9]+');
	    Pattern loanAccountRegex = Pattern.compile('[0-9]+');
	    Pattern savingAccountRegex = Pattern.compile('[0-9]+');
	    Pattern dateRegex = Pattern.compile('[0-9]{8}');
        
        
        System.assertEquals(true, loanContractRegex.matcher('LD13122000770').matches());
        System.assertEquals(false, loanContractRegex.matcher('LD').matches());
        System.assertEquals(true, loanContractRegex.matcher('LD1').matches());
        System.assertEquals(false, loanContractRegex.matcher('LD1e').matches());
        
        System.assertEquals(false, loanAccountRegex.matcher('LD13122000770').matches());
        System.assertEquals(false, loanAccountRegex.matcher('LD').matches());
        System.assertEquals(true, loanAccountRegex.matcher('124').matches());
        System.assertEquals(false, loanAccountRegex.matcher('123e').matches());
        
        System.assertEquals(false, savingAccountRegex.matcher('LD13122000770').matches());
        System.assertEquals(false, savingAccountRegex.matcher('LD').matches());
        System.assertEquals(true, savingAccountRegex.matcher('124').matches());
        System.assertEquals(false, savingAccountRegex.matcher('123e').matches());
        
        System.assertEquals(true, dateRegex.matcher('20103032').matches());
        System.assertEquals(false, dateRegex.matcher('LD103032').matches());
        System.assertEquals(false, dateRegex.matcher('zxcvbnma').matches());
        System.assertEquals(false, dateRegex.matcher('201030322').matches());
        System.assertEquals(false, dateRegex.matcher('2010303').matches());
    	
    	//Boolean test2 = Pattern.matches('[a-zA-Z0-9_\\-\\.]', 'LD1312200077');
        
    	
    	//Boolean test = Pattern.matches('LD[0-9.]', 'LD1312200077');
    	//System.assertEquals(true, test);
    }
    
    

}

/*

public static testMethod void testMyController() {
       
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.success;
       
       //In this case, the Visualforce page named 'success' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
     
       //Instantiate and construct the controller class.   
       thecontroller controller = new thecontroller();

       //Example of calling an Action method. Same as calling any other Apex method. 
       //Normally this is executed by a user clicking a button or a link from the Visualforce
       //page, but in the test method, just test the action method the same as any 
       //other method by calling it directly. 

       //The .getURL will return the page url the Save() method returns.
       String nextPage = controller.save().getUrl();

       //Check that the save() method returns the proper URL.
       System.assertEquals('/apex/failure?error=noParam', nextPage);

       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('qp', 'yyyy');
     
       //Instantiate a new controller with all parameters in the page
       controller = new thecontroller(); 

       //Example of calling the 'setter' method for several properties. 
       //Normally these setter methods are initiated by a user interacting with the Visualforce page, 
       //but in a test method, just call the setter method directly. 
       controller.setLastName('lastname');
       controller.setFirstName('firstname');
       controller.setCompany('acme');
       controller.setEmail('firstlast@acme.com');
       nextPage = controller.save().getUrl();

       //Verify that the success page displays
       System.assertEquals('/apex/success', nextPage);
       
   }


*/