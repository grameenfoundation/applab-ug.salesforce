public class CallCenterController {
        
    String caseId = '';
    String phoneNumber;  
    String response;
    Boolean isNewFarmer;
    Farmer__c[] farmers;
    Farmer__c farmer;
    Case[] cases;

    Case currentCase;
        
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
        
    public Case[] getCases() {
        cases = getFarmerCases(farmer);
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
            farmers = getByPhoneNumber(phoneNumber);
            // Check if there is any farmer with a matching phone number  
            if (farmers.isEmpty() || farmers == null) {
                farmer = createDefaultFarmer();
                isNewFarmer  = true;
                farmers = getByPhoneNumber(phoneNumber);
                farmer = farmers[0];
            }  
            else {
                farmer = farmers[0];
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
       
    public PageReference getCaseDetails () {
        String caseId= ApexPages.currentPage().getParameters().get('cId');
        PageReference pageRef = new PageReference('/' + caseId + '?isdtp=mn&retURL=/ui/desktop/DesktopMainDefaultPage?isdtp=mn');
        return pageRef.setRedirect(true);
    }
         
    public PageReference linkArticles() {
        if (saveCurrentCase(farmer)) {
            PageReference pageRef = new PageReference('/knowledge/knowledgeHome.apexp?id=' + currentCase.Id + '&isdtp=mn');
            return pageRef.setRedirect(true);
        }            
        return null;
    }
    
    public PageReference saveCaseAndClear() {
        if (saveCurrentCase(farmer)) {
            if (currentCase.Status == 'Closed') {
                // For all closed cases update total_complete_interactions_call_center
                MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
            }
            clearCaseFields();    
            // Reset all fields and prepare for next search 
            clearAllFarmers();  
        }      
        return null;
    }
    
    public PageReference saveCaseAndClose() {
        currentCase.Status = 'Closed';
        if (saveCurrentCase(farmer)) {
             // For all closed cases update total_complete_interactions_call_center
            MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
            MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
            clearCaseFields();    
            // Reset all fields and prepare for next search 
            clearAllFarmers(); 
        } 
        return null;        
    }
    
    public PageReference saveCase() {
        if (saveCurrentCase(farmer)) {  
            if (currentCase.Status == 'Closed') {
                // For all closed cases update total_complete_interactions_call_center
                MetricHelpers.updateMetric('total_complete_interactions_call_center', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
                MetricHelpers.updateMetric('total_info_services_offered', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0)), true);
                clearCaseFields(); 
            }
        }
        return null;
    }
    
    private boolean saveCurrentCase(Farmer__c farmer) {     
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
        database.upsert(currentCase);               
        return true;
     }
        
    private Farmer__c createDefaultFarmer() {   
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
    
    private Farmer__c[] getByPhoneNumber(String phoneContact) {
        farmers = [
                SELECT 
                    Id,
                    Name,
                    Crops__c,
                    Livestock__c,
                    Topics_of_Interest__c,
                    Person__c,
                    Person__r.First_Name__c,
                    Person__r.Middle_Name__c,
                    Person__r.Last_Name__c,
                     Person__r.District_Name__c,
                    Person__r.District__c,
                    Person__r.Mobile_Number__c,
                    Person__r.Raw_Mobile_Number__c
                FROM
                    Farmer__c 
                WHERE
                    Person__r.Mobile_Number__c
                    LIKE
                    :('%' + phoneContact)
                ];
        return farmers; 
    }
    
    private Case[] getFarmerCases(Farmer__c farmer) {
        if (farmer == null) {
           return null;
        }
        cases = [
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
        
    public void clearCaseFields() {
        currentCase = null;
        setResponse('');
    }
    
    public void clearAllFarmers() {
        farmers = null;
        farmer = null;
    }
   
    static testmethod void testGetByPhoneNumber() {
        CallCenterController controller = new CallCenterController();
        String dummyPhoneNumber = '0749876342';
        controller.setPhoneNumber(dummyPhoneNumber);
        Farmer__c testFarmer = controller.createDefaultFarmer();  
        controller.setFarmer(testFarmer);      
        Farmer__c[] farmers = controller.getByPhoneNumber(dummyPhoneNumber);
        system.assert(!farmers.isEmpty());
        system.assert(farmers[0].Id == testfarmer.Id);
    }
    
    static testmethod void testSearchByPhoneNumber() {
        CallCenterController controller = new CallCenterController();
        String dummyPhoneNumber = '+256771234567';
        controller.setPhoneNumber(dummyPhoneNumber);       
        PageReference pageRef1 = controller.searchByPhoneNumber();
        PageReference pageRef2 = controller.saveFarmerChanges();
        system.assert(pageRef1 == null);
        system.assert(pageRef2 == null);
    }
    
    static testmethod void testCreateCases() {
        CallCenterController controller = new CallCenterController();
        Farmer__c testFarmer = controller.createDefaultFarmer(); 
        Case farmerCase = controller.getCurrentCase();        
        boolean saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , false);
        farmerCase.Subject = 'test';
        farmerCase.Category__c = 'Pulse';
        farmerCase.Status = 'New';
        saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , true);
        
    }
    
   static testmethod void testGetFarmerCases() {
        CallCenterController controller = new CallCenterController();
        Farmer__c testFarmer = null;
        Case[] cases1 = controller.getFarmerCases(testFarmer);
        testFarmer = controller.createDefaultFarmer(); 
        Case[] cases2 = controller.getFarmerCases(testFarmer);
        Case[] cases3 = controller.getCases();
        system.assert(cases1 ==null);
        system.assert(!cases2.isEmpty());        
    }
    
    static testmethod void testPageReferences() {
        CallCenterController controller = new CallCenterController();
        controller.setPhoneNumber('0791568666');
        controller.searchByPhoneNumber();
        Case currentCase = controller.getCurrentCase();
        currentCase.Status = 'Closed';
        controller.saveCase();
        controller.saveCaseAndClose();
        system.assert(currentCase != null);
    }

    // Testing getters and setters to increase code coverage
    static testmethod void testGettersAndSetters() {
        CallCenterController controller = new CallCenterController();
        String phoneNumber = '078000000';
        controller.setPhoneNumber(phoneNumber);               
        system.assert(controller.getPhoneNumber() == phoneNumber);       
        system.assert(controller.getFarmer() == null);
        system.assert(controller.getFarmers() == null);
        system.assert(controller.searchByPhoneNumber() ==  null);
        system.assert(controller.getIsNewFarmer() == true);
        system.assert(controller.getResponse() != 'response');
    }    
}