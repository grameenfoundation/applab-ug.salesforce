public class FileUploader {
	
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }
    private String content;
    
    private Map<String, UpdateSavingAccount> updates = new Map<String, UpdateSavingAccount>();
    //private List<Loan__c> newLoans = new List<Loan__c>();
    private List<Loan__c> existingLoans = new List<Loan__c>();
    
    private Set<String> updateIds = new Set<String>();
    private Set<String> updateLoanIds = new Set<String>();
    private List<String> erroneousLines = new List<String>();
    private List<String> errors = new List<String>();
    private CSV_Import__c importResult;
    
    // expect header line and 1000 rows
    private Integer sizeLimit = 1001;
    
    private Pattern loanContractRegex = Pattern.compile('LD[0-9]+');
    private Pattern loanAccountRegex = Pattern.compile('[0-9]+');
    private Pattern savingAccountRegex = Pattern.compile('[0-9]+');
    private Pattern dateRegex = Pattern.compile('[0-9]{8}');
    
    public Integer testFailure = -1;
    
    public PageReference readFile()
    {
    	// reset lists
    	updates = new Map<String, UpdateSavingAccount>();
	    existingLoans = new List<Loan__c>();
	    
	    updateIds = new Set<String>();
	    updateLoanIds = new Set<String>();
	    erroneousLines = new List<String>();
	    errors = new List<String>();
	 	
    	// check if the file is null
        if(contentFile == null){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.no_uploadfile));
            return null;
        }
        
    	// create the CSV Import object for tracking purposes
    	importResult = new CSV_Import__c();
    	importResult.Import_Date__c = Datetime.now();
    	importResult.Status__c = 'Starting';
    	importResult.Imported_Line_Count__c = 0;
    	importResult.Name = DateTime.now().format('yyyyMMdd-HHmmss-') + this.nameFile;
    	
    	// insert the logging object
        try {
            insert importResult;
            
            // test code, bad but there is no other way
            if(testFailure == 1){
            	throw new TestException();
            }
        }
        catch (Exception e) {
            system.debug(LoggingLevel.Error, 'EXCEPTION: ' + e);
            String errorMessage = String.format('{0} {1}', new String[]{System.Label.csvimport_error_msg, System.Label.contact_support});
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.nothing_imported));
            return null;
        }
    	
        List<List<String>> lines;
        
        // try parsing the content of the CSV and save as attachment to the CSV Import
        try {
        	// save the file content to a string
        	content = contentFile.toString();
        	// save the file as attachment to the importResult object
        	saveAttachment();
        	
        	// parse the file
        	lines = parseCSV(content, true);
        	
        	// test code, bad but there is no other way
            if(testFailure == 2){
            	throw new TestException();
            }
        }
        catch (Exception e) {
        	String errorMessage = String.format('{0} {1}', new String[]{System.Label.csvimport_parseerror_msg, System.Label.contact_support});
        	addError(errorMessage);
        	logError();
            return null;
        }
             
        // if there are too many lines, throw an error
        if(lines.size() > sizeLimit){
            String errorMessage = String.format('{0} {1}', new String[]{System.Label.csvfile_sizelimit, System.Label.contact_support});
            addError(errorMessage);
            logError();
            return null;
        }
        
        // keep track of the line we are converting to give useful information on error
        Integer lineNo = 2;

        // try saving the raw strings in objects to push to the database
        for(List<String> lineValues : lines) {
        	try {
                UpdateSavingAccount updateSavAcc = new UpdateSavingAccount();
                
                // check the format of saving account
                if(!savingAccountRegex.matcher(lineValues.get(3)).matches())
                    throw new MatchException('Saving Account is wrong format');
                // check the format of loan account
                if(!loanAccountRegex.matcher(lineValues.get(4)).matches())
                    throw new MatchException('Loan Account is wrong format');
                // check the format of loan contract
                if(!loanContractRegex.matcher(lineValues.get(5)).matches())
                    throw new MatchException('Loan Contract is wrong format');
                
                updateSavAcc.ClientName = lineValues.get(0);
                updateSavAcc.FciID = lineValues.get(1);
                updateSavAcc.NationalID = lineValues.get(2);
                updateSavAcc.SavingAccountNo = lineValues.get(3);
                updateSavAcc.LoanAccountNo = lineValues.get(4);
                updateSavAcc.LoanContractNo = lineValues.get(5);
                                
                // if the file contains the larger dataset (including balance)
                if(lineValues.size() == 10){
                	
                	if(!dateRegex.matcher(lineValues.get(6)).matches())
                        throw new MatchException('Disburse Date wrong format');
                       
                    if(!dateRegex.matcher(lineValues.get(7)).matches())
                        throw new MatchException('Maturity Date wrong format');
                       
                	updateSavAcc.DisburseDate = getDate(lineValues.get(6));
                	updateSavAcc.MaturityDate = getDate(lineValues.get(7));
                	updateSavAcc.LoanBalance = Integer.valueOf(lineValues.get(8));
                	updateSavAcc.LoanAmount = Integer.valueOf(lineValues.get(9));
                	
                	
                }
                
                if(updates.containsKey(updateSavAcc.FciID)){
                	addError(System.Label.csvimport_duplicate_msg + ' FCI ID:' + updateSavAcc.FciID);
                }
                else{
                	updates.put(updateSavAcc.FciID, updateSavAcc);
                	updateIds.add(updateSavAcc.FciID);
                	updateLoanIds.add(updateSavAcc.LoanContractNo);
                }
                // test code, bad but there is no other way
	            if(testFailure == 3){
	            	throw new MatchException();
	            }
	            // test code, bad but there is no other way
	            if(testFailure == 4){
	            	throw new TestException();
	            }
	        }
	        catch(MatchException me){
	        	String errorMessage = String.format('{0}, line #{1}',  new String[]{me.getMessage(), String.valueOf(lineNo)});
                addError(errorMessage);
	        }
	        catch (Exception e){
	        	String errorMessage = String.format(System.Label.csvimport_parseerrorline_msg,  new String[]{String.valueOf(lineNo)});
                addError(errorMessage);
	        }
	        finally {
	        	lineNo++;
	        }
        }
     
        // check if any errors occured while parsing through the objects from the raw data, stop the process
        if(getErrors().size() > 0){
            logError();
            return null;
        }       
        
        // Save a transaction start point
        Savepoint sp = Database.setSavepoint();
        
        List<Person__c> updateList;
        List<Loan__c> updateLoanList;
        try {
        	// get a list of all persons
            updateList = getPersonsBySet(updateIds, 'Name');
            // get a list of all loans
            updateLoanList = getLoansByFarmerNameSet(updateIds, updateLoanIds);
            system.debug(LoggingLevel.Debug, 'updateList: ' + updateList);
            system.debug(LoggingLevel.Debug, 'updateLoanList: ' + updateLoanList);
            
            // check if list with farmers is same size as csv file
	        if(updateList.size() != updateIds.size()){
	            List<String> missingIds = new List<String>();
	            for(String updateId : updateIds){
	                Boolean found = false;
	                for(Person__c p : updateList){
	                    if(updateId == p.Farmers__r[0].Name) found = true;
	                }
	                if(!found){
	                    String errorMessage = String.format(System.Label.client_not_found, new String[]{updateId});
	                    addError(errorMessage);
	                }
	            }
	        }
	        
	        // test code, bad but there is no other way
            if(testFailure == 5){
            	throw new TestException();
            }
            
        }
        catch(Exception e){
            system.debug(LoggingLevel.Error, 'EXCEPTION: ' + e);
            String errorMessage = String.format('{0} {1}', new String[]{System.Label.retrieve_client_error, System.Label.contact_support});
            addError(errorMessage);
            logError();
            return null;
        }
        
        
        
        if(getErrors().size() > 0){
            logError();
            return null;
        }
        
        // parse through the list with clients and find the SF item and store the updated version in list
        for(Person__c person : updateList){
        	Farmer__c farmer;
        	if(person.Farmers__r.size() != 1){
        		addError(String.format('{0} National ID: {1}', new String[]{System.Label.retrieve_client_error, person.ID_Number__c}));
        		continue;
        	}
        	else {
        		farmer = person.Farmers__r[0];
        	}
        	
        	// find the corresponding updated information
        	UpdateSavingAccount updateSaveAcc = updates.get(farmer.Name);
        	
        	// check if the updated information exists
	        if (updateSaveAcc == null) {
	        	String errorMessage = String.format(System.Label.client_not_found, new String[]{farmer.Name});
	        	addError(errorMessage);
            }
            else {
            	// from the person, only update the national ID
            	person.ID_Number__c = updateSaveAcc.NationalID;
            	
            	Loan__c updateLoan = null;
            	
	            // find corresponding loan
	            for(Loan__c loan : updateLoanList){
	                if(loan.Farmer__r.Name == farmer.Name){
	                    updateLoan = loan;
	                    break;
	                }
	            }
	            
	            // if loan is still null, we need to throw an error and continue
	            if(updateLoan == null){
	                String errorMessage = String.format(System.Label.loan_not_found, new String[]{farmer.Name});
                    addError(errorMessage);
                    continue;
	            }
	            else {
	            	existingLoans.add(updateLoan);
	            }
	            
	            updateLoan.Saving_Account_No__c = updateSaveAcc.SavingAccountNo;
	            updateLoan.Loan_Account_No__c = updateSaveAcc.LoanAccountNo;
	            updateLoan.Loan_Contract_No__c = updateSaveAcc.LoanContractNo;
	            
	            updateLoan.Disburse_Date__c = updateSaveAcc.DisburseDate;
	            updateLoan.Maturity_Date__c = updateSaveAcc.MaturityDate;
	            updateLoan.Balance__c = updateSaveAcc.LoanBalance;
	            updateLoan.Amount_Approved__c = updateSaveAcc.LoanAmount;   
            }
    	}
    	
    	// check if errors occured while updating the objects
    	if(getErrors().size() > 0){
            logError();
            return null;
        }
    	
    	// update the final list
    	// save the update
    	Boolean hasErrors = false;
    	List<Database.SaveResult> results1;
    	List<Database.SaveResult> results2;
        try {
            // check if we need to move to datasource
            results1 = Database.update(updateList);
            results2 = Database.update(existingLoans);
            
            // test code, bad but there is no other way
            if(testFailure == 6){
            	throw new TestException();
            }
        }
        catch(Exception e){
        	String errorMessage = String.format('{0} \n ERROR: {1}', new String[]{System.Label.contact_support, String.valueOf(e)});
            system.debug(LoggingLevel.Error, errorMessage);
            addError(errorMessage);
            logError();
            return null;
        }
        
        // iterate through the results and check whether an error has occured
        for(Database.SaveResult result : results1){
            if(!result.isSuccess())
               hasErrors = true;
        }
        for(Database.SaveResult result : results2){
            if(!result.isSuccess())
               hasErrors = true;
        }
        
        // if there are errors, rollback the database changes
        if(hasErrors){
        	Database.rollback(sp);
        	String errorMessage = String.format('{0} {1}', new String[]{System.Label.csvimport_error_msg, System.Label.contact_support});
            addError(errorMessage);
            logError();
            return null;
        }
        
        importResult.Imported_Line_Count__c = results1.size();
        importResult.Status__c = 'Finished';
        updateImportResult();
 
        return null;
    }
    
    private Date getDate(String dateStr){
    	Integer year = Integer.valueOf(dateStr.substring(0, 4));
    	Integer month = Integer.valueOf(dateStr.substring(4, 6));
    	Integer day = Integer.valueOf(dateStr.substring(6));
    	Date retValue = Date.newinstance(year, month, day);
    	system.debug(LoggingLevel.Debug, String.format('{0} - Year: {1}, Month: {2}, Day: {3}, Date: {4}', new String[]{dateStr, String.valueOf(year), String.valueOf(month), String.valueOf(day), retValue.format()}));
    	return retValue;
    }
    
    public void logError(){ //String message
    	//  log all errors (screen and object)
    	String irLog = '';
        for(String err : errors){
    	    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, err));
    	    irLog += err + '\n';
        }
        // show general message
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.nothing_imported));

    	importResult.Log__c = irLog;
    	importResult.Status__c = 'Failed';
        updateImportResult();
    }
    
    public Map<String, UpdateSavingAccount> getUpdates()
    {
        return updates;
    }

    public void saveAttachment(){
    	Id parentId = importResult.Id;
  
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(content);
        attachment.Name = importResult.Name;
        attachment.ParentId = parentId; 
        insert attachment;
        
    }
    
    public void updateImportResult(){
    	// insert the logging object
        try {
            update importResult;
        }
        catch (Exception e) {
            system.debug(LoggingLevel.Error, 'EXCEPTION: ' + e);
            String errorMessage = String.format('{0} {1}', new String[]{System.Label.csvimport_error_msg, System.Label.contact_support});
            addError(errorMessage);
            logError();
        }
    }
    
    
    /*
        Source: http://wiki.developerforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
        Adjusted so that the last item in the value list is the original line from the file
    */
    public List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug(LoggingLevel.Error, 'Limits exceeded?' + e.getMessage());
            addError('Problem occured splitting the files in lines. Maybe the file was too big?');
        }
        
        Integer lineNo = 1;
        for(String line : lines) {
            try {
                // check for blank CSV lines (only commas)
                if (line.replaceAll(',','').trim().length() == 0) break;
                // remove CR & LF
                line = line.replaceAll('\n', '');
                line = line.replaceAll('\r', '');
                
                List<String> fields = line.split(',');  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                
                for(String field : fields) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                }
                allFields.add(cleanFields);
                System.debug(LoggingLevel.Debug, 'Extracted fields:' + cleanFields);
            }
            catch(Exception e){
                System.debug(LoggingLevel.Error, 'Limits exceeded?' + e.getMessage());
                addError('Parse error on line '+lineNo+':' + line);
            }
            
            // increase the line number
            lineNo++;
        }
        if (skipHeaders) allFields.remove(0);
        // return all fields found on correct lines
        return allFields;       
    }
    
    public List<String> getErrors(){
        return errors;
    }
    
    public List<Loan__c> getExistingLoans(){
        return existingLoans;
    }
    
    public void addError(String error){
        if(errors == null)
           errors = new List<String>();
        errors.add(error);
    }
    
    public List<Person__c> getPersonsBySet(Set<String> values, String columnName){
        
        String q = 'SELECT Name, First_Name__c, Middle_Name__c, Last_Name__c, Date_of_Birth__c, Mobile_Number__c, ' + 
                   'ID_Number__c,  Village__c, District__r.Name, City__c, Picture_URL__c, Next_Of_Kin__c, ' +
                   'Next_Of_Kin_Telephone__c, Country__r.Name, Gender__c, ' +
                   '(SELECT Name, Group__r.Group_ID__c, Group__r.Name FROM PersonGroupAssociations__r),' +
                   '(SELECT ID, Name, Sale_Status__c FROM Farmers__r)' +
                   'FROM Person__c WHERE Id IN ' +
                   '(SELECT Person__c FROM Farmer__c WHERE '+ columnName +' IN :values)';
        return Database.query(q);
    }
    
    public List<Loan__c> getLoansByFarmerNameSet(Set<String> farmers, Set<String> contracts){
        return [SELECT 
                    Id, 
                    Name, 
                    Amount_Applied_For__c,
                    Amount_Approved__c,
                    Balance__c,
                    Application_Date__c,
                    Currency__c,
                    Decision_Date__c,
                    Farmer__r.Name,
                    Saving_Account_No__c,
                    Loan_Account_No__c,
                    Loan_Contract_No__c,
                    Disburse_Date__c,
                    Maturity_Date__c,
                    Status__c
                FROM Loan__c WHERE Farmer__r.Name IN :farmers];
    }
    
    public class UpdateSavingAccount {
        public String ClientName { get; set; }
        public String FciID { get; set; }
        public String NationalID { get; set; }
        public String SavingAccountNo { get; set; }
        public String LoanAccountNo { get; set; }
        public String LoanContractNo { get; set; }
        public Date DisburseDate { get; set; }
        public Date MaturityDate { get; set; }
        public Integer LoanBalance { get; set; }
        public Integer LoanAmount { get; set; }
    }
    
    public class MatchException extends Exception {}
    
    public class TestException extends Exception {}
    
    
    
    

}