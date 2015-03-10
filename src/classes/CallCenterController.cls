public class CallCenterController {
        
    String caseId = '';
    String phoneNumber;  
    String district;
    String sex;
    String response;
    Boolean isNewFarmer;
    Farmer__c[] farmers;
    Farmer__c farmer;
    Case[] cases;
    Case currentCase;
    Person__c[] ckws;
    Person__c ckw;
    Boolean callBackRequired = false;
    
    public String type { get; set; }
    public String fname { get; set; }
    public String lname { get; set; }
    public String callerType { get; set; }
        
    public String getDistrict() {
        return district;
    }
    
    public void setDistrict(String district) {
        this.district = district;
    }   
    
    public List<SelectOption> personType { 
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', ''));
            for(Schema.PicklistEntry item : Person__c.Type__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(item.getLabel(), item.getLabel()));
            }
            return options;
        }
    }
    
    public String getSex() {
        return sex;
    }
            
    public void setSex(String sex) {
        this.sex = sex;
    }
    
    public Person__c[] getCkws() {
        return ckws;
    }
        
    public void setCkws(Person__c[] ckws) {
        this.ckws = ckws;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;     
    }
        
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }  
    
    public Boolean getIsNewFarmer() {
        return this.isNewFarmer;
    }                                                          
    
    public Farmer__c[] getFarmers() {
        return farmers;
    }
        
    public Farmer__c getFarmer() {
        return farmer;
    }
        
    public void setFarmer(Farmer__c farmer) {
        this.farmer = farmer;
    }
     
    public Person__c getCkw() {
        return ckw;
    }
        
    public void setCkw(Person__c ckw) {
        this.ckw = ckw;
    }
        
    public Case[] getCases() {
        cases = farmer != null ? getFarmerCases(farmer) : getPersonCases(ckw);
        return cases;
    }
        
    public Case getCurrentCase() {
        if(currentCase == null) {
            currentCase = new Case();
        }
        return currentCase;
    }
    
    public String getResponse() {
        return this.response;
    }
    
    public void setResponse(String response) {
        this.response = response;
    }
    
    public Boolean getCallBackRequired() {
        return this.callBackRequired;
    }
    
    public void setCallBackRequired(Boolean callback) {
        this.callBackRequired = callback;
    }
                        
    public PageReference searchByPhoneNumber() {  
        // Clear all farmer details in preparation for new search
        isNewFarmer = false;
        clearCaseFields();
        clearAllFarmers(); 
        // Check if string is in format +2567xxxxxxxx and change to 7xxxxxxxx
        // where x in [0-9]
        if (phoneNumber.startsWith('+256')) {
            phoneNumber = phoneNumber.substring(4);  
        }   
        else if (phoneNumber.length() == 10) {
            phoneNumber = phoneNumber.substring(1);
        }
        if (isWellFormedPhoneNumber(phoneNumber)) {     
            if(callerType.equals('Farmer')) {              
                farmers = getByPhoneNumber(phoneNumber);
                // Check if there is any farmer with a matching phone number  
                farmer = (farmers != null && !farmers.isEmpty()) ? farmers[0] : null;   
            }
            else {
                ckws = getCkwByPhoneNumber(phoneNumber);       
                ckw = (ckws != null && !ckws.isEmpty()) ? ckws[0] : null;       
            }
        }      
        return null;        
    }
        
    public PageReference getFarmerDetails() {
        String farmerId = ApexPages.currentPage().getParameters().get('fId');
        PageReference pageRef = new PageReference('/' + farmerId);
        return pageRef.setRedirect(true);
    }
    
    public PageReference saveFarmerChanges() {
        database.update(farmer.Person__r);
        database.update(farmer);
        farmers = getByPhoneNumber(farmer.Person__r.Mobile_Number__c);
        farmer = farmers[0];
        isNewFarmer = false;
        return null;
    }
       
    public PageReference savePersonChanges() {
        database.update(ckw);
        farmers = getByPhoneNumber(ckw.Mobile_Number__c);
        ckw = ckws[0];
        isNewFarmer = false;
        return null;
    }
    
    public PageReference getCaseDetails () {
        String caseId= ApexPages.currentPage().getParameters().get('cId');
        PageReference pageRef = new PageReference('/' + caseId + '?isdtp=mn&retURL=/ui/desktop/DesktopMainDefaultPage?isdtp=mn');
        return pageRef.setRedirect(true);
    }
         
    public PageReference linkArticles() {
        if (farmer !=null ? saveCurrentCase(farmer) : saveCurrentCase(ckw)) {
            PageReference pageRef = new PageReference('/knowledge/knowledgeHome.apexp?id=' + currentCase.Id + '&isdtp=mn');
            return pageRef.setRedirect(true);
        }            
        return null;
    }
    
    public PageReference saveCaseAndClear() {
        if (farmer !=null ? saveCurrentCase(farmer) : saveCurrentCase(ckw)) {
            if (currentCase.Status == 'Closed') {
                // For all closed cases update total_complete_interactions_call_center
                MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            }
            clearCaseFields();    
            // Reset all fields and prepare for next search 
            clearAllFarmers();  
        }      
        return null;
    }
    
    public PageReference saveCaseAndClose() {
        currentCase.Status = 'Closed';
        if (farmer !=null ? saveCurrentCase(farmer) : saveCurrentCase(ckw)) {
             // For all closed cases update total_complete_interactions_call_center
            MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
            clearCaseFields();    
            // Reset all fields and prepare for next search 
            clearAllFarmers(); 
        } 
        return null;        
    }
    
    public PageReference saveCase() {
        if (farmer !=null ? saveCurrentCase(farmer) : saveCurrentCase(ckw)) {  
            if (currentCase.Status == 'Closed') {
                // For all closed cases update total_complete_interactions_call_center
                MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), false);
                clearCaseFields(); 
            }
        }
        return null;
    }
    
    public boolean saveCurrentCase(Farmer__c farmer) {     
        if (currentCase.Subject == null || currentCase.Category__c == null || currentCase.Status == null) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'The case must have Subject, Category and Status values');
            ApexPages.addMessage(errorMessage);
            return false;
        }      
        currentCase.Type = 'Question';            
        currentCase.Person__c = farmer.Person__r.Id;            
        currentCase.Reason = 'reason';
        currentCase.Response__c = this.response;
        currentcase.Origin = 'Phone Call';
        currentcase.Subject = callBackRequired ? '[CALLBACK REQUIRED] ' + currentcase.Subject : currentcase.Subject;
        database.upsert(currentCase);      
        if(callBackRequired) {
            CaseComment newCom = new CaseComment();
            newCom.CommentBody = 'This Case Requires a Callback before closing';
            newCom.IsPublished = FALSE;
            newCom.ParentId = currentCase.Id;
            insert newCom;
        }
        return true;
     }
     
    public boolean saveCurrentCase(Person__c person) {     
        if (currentCase.Subject == null || currentCase.Category__c == null || currentCase.Status == null) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'The case must have Subject, Category and Status values');
            ApexPages.addMessage(errorMessage);
            return false;
        }      
        currentCase.Type = 'Question';            
        currentCase.Person__c = person.Id;            
        currentCase.Reason = 'reason';
        currentCase.Response__c = this.response;
        currentcase.Origin = 'Phone Call';
        currentcase.Subject = callBackRequired ? '[CALLBACK REQUIRED] ' + currentcase.Subject : currentcase.Subject;
        database.upsert(currentCase);   
        if(callBackRequired) {
            CaseComment newCom = new CaseComment();
            newCom.CommentBody = 'This Case Requires a Callback before closing';
            newCom.IsPublished = FALSE;
            newCom.ParentId = currentCase.Id;
            insert newCom;
        }            
        return true;
     }
        
    public Farmer__c createDefaultFarmer() {   
        Farmer__c farmer;
        Person__c person;        
        farmer = new Farmer__c();
        person = new Person__c();             
        // Populate the biographical details for the farmer.
        person = addPersonBioDetails(person);          
        // Save the persons and farmer objects     
        database.insert(person);    
        farmer.Person__c = person.Id;     
        database.insert(farmer);     
        return farmer;       
    }

    private Person__c addPersonBioDetails(Person__c person) {
        
        // Set default values for Unknown Farmer
        person.First_Name__c = 'Unknown Call-Centre';
        person.Last_Name__c = 'Farmer';
        person.Raw_Mobile_Number__c = phoneNumber;
        person.Village__c = 'Unknown';
        person.Age__c = 0;  
        // Not yet on production system  
        // person.Type__c = 'Farmer';    
        return person;
    }
    
    private Boolean isWellFormedPhoneNumber(String phoneContact) {
        String phoneRegex = '[0-9]{9}';
        Pattern phoneNumberPattern = Pattern.compile(phoneRegex);
        Matcher numberMatch = phoneNumberPattern .matcher(phoneContact);
        return numberMatch.matches();
    }
    
    public Farmer__c[] getByPhoneNumber(String phoneContact) {
        String farmersQuery =
            'SELECT '                                                   +
                'Id,'                                                   +
                'Name,'                                                 +
                'Crops__c,'                                             +
                'Livestock__c,'                                         +
                'Topics_of_Interest__c,'                                +
                'Person__c,'                                            +
                'Person__r.First_Name__c,'                              +
                'Person__r.Middle_Name__c,'                             +
                'Person__r.Last_Name__c,'                               +
                'Person__r.District_Name__c,'                           +
                'Person__r.District__c,'                                +
                'Person__r.Mobile_Number__c,'                           +
                'Person__r.Raw_Mobile_Number__c '                       +
            'FROM '                                                     +
                'Farmer__c '                                            +
            'WHERE '                                                    +
                'Mobile_Number__c LIKE \'%' + phoneContact + '\' ';
        farmersQuery = sex != null && sex != '' ? 
            farmersQuery + 'AND Person__r.Gender__c = \'' + sex + '\' ' : farmersQuery;
        farmersQuery = type != null && type != '' ? 
            farmersQuery + 'AND Person__r.Type__c = \'' + type + '\' ' : farmersQuery;
        farmersQuery = (district != null && district != '') ? 
            farmersQuery + 'AND Person__r.District_Name__c = \'' + district + '\' ' : farmersQuery;
        farmersQuery = (fname != null && fname != '') ? 
            farmersQuery + 'AND Person__r.First_Name__c = \'' + fname + '\' ' : farmersQuery;
        farmersQuery = (lname != null && lname != '') ? 
            farmersQuery + 'AND Person__r.Last_Name__c = \'' + lname + '\' ' : farmersQuery;
        return database.query(farmersQuery); 
    }
    
        
    public Person__c[] getCkwByPhoneNumber(String phoneContact) {
        String query =
            'SELECT '                                                   +
                'Id,'                                                   +
                'Name,'                                                 +
                'First_Name__c,'                                        +
                'Middle_Name__c,'                                       +
                'Last_Name__c,'                                         +
                'District_Name__c,'                                     +
                'District__c,'                                          +
                'Mobile_Number__c,'                                     +
                'Raw_Mobile_Number__c '                                 +
            'FROM '                                                     +
                'Person__c '                                            +
            'WHERE '                                                    +
                'Mobile_Number__c LIKE \'%' + phoneContact + '\' ';
        query = sex != null && sex != '' ? 
            query + 'AND Gender__c = \'' + sex + '\' ' : query;
        query = type != null && type != '' ? 
            query + 'AND Type__c = \'' + type + '\' ' : query;
        query = (district != null && district != '') ? 
            query + 'AND District_Name__c = \'' + district + '\' ' : query;
        query = (fname != null && fname != '') ? 
            query + 'AND First_Name__c = \'' + fname + '\' ' : query;
        query = (lname != null && lname != '') ? 
            query + 'AND Last_Name__c = \'' + lname + '\' ' : query;
        return database.query(query); 
    }
    
    public Case[] getFarmerCases(Farmer__c farmer) {
        return farmer == null ?
            null :
            [
                SELECT
                    Id,                        
                    Subject,
                    CaseNumber,
                    Status,
                    Description,
                    CreatedDate
                FROM
                    Case
                WHERE
                    Person__c = :farmer.Person__r.Id
                ORDER BY CreatedDate DESC
                LIMIT 5
                                               
           ];
        return cases;
    }
    
    public Case[] getPersonCases(Person__c person) {
        return ckw == null ?
            null :
            [
                SELECT
                    Id,                        
                    Subject,
                    CaseNumber,
                    Status,
                    Description,
                    CreatedDate
                FROM
                    Case
                WHERE
                    Person__c = :person.Id
                ORDER BY CreatedDate DESC
                LIMIT 5
                                               
           ];
        return cases;
    }
        
    public void clearCaseFields() {
        currentCase = null;
        setResponse('');
    }
    
    public void clearAllFarmers() {
        farmers = null;
        farmer = null;
        ckws = null;
        ckw = null;
    }
}