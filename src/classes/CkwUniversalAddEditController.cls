/**
 * This class is an extension of the StandardController for the CKW__c 
 * custom object.
 *
 * This controller extension handles the Universal page for creating a CKW along with the supporting 
 * records such as; Person, Contact, Handset and Simcard
 */
public class CkwUniversalAddEditController {
    ApexPages.StandardController sController = null;
    private Phone__c tempHandset;
    
    public CkwUniversalAddEditController(ApexPages.StandardController controller) {
        ckw = (CKW__c)controller.getRecord();
        sController = controller;
        
        if(ckw.Id != null){
            ckw = [SELECT Id, Has_CKW_paid_the_commitment_fee__c, Contract_Signed__c, Recruiter__c, Secondary_Recruiter__c, 
            Status__c, Poverty_Status__c, CKW_Rank__c, CKW_Type__c, Serial_Number__c, Assigned_On__c, Current_Performance_Review__c, 
            Previous_Performance_Review__c, Person__c, Comprehension__c, Content_Absorption__c, Group_Dynamics__c, Attitude__c, 
            Special_Needs__c, General_Notes__c, Person__r.Id, Person__r.OwnerId, Person__r.First_Name__c, Person__r.Last_Name__c, Person__r.Gender__c, Person__r.Handset__c, 
            Person__r.Contact__c, Person__r.Education_Level__c, Person__r.Current_Poverty_Scorecard__c, 
            Person__r.District__c, Person__r.Region__c, Person__r.Subcounty__c, Person__r.Parish__c, Person__r.Village__c, 
            Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, 
            Person__r.Contact__r.Id, Person__r.Contact__r.AccountId, Person__r.Contact__r.OwnerId, Person__r.Contact__r.Salutation, Person__r.Contact__r.FirstName, 
            Person__r.Contact__r.LastName, Person__r.Contact__r.Birthdate, Person__r.Contact__r.Title, Person__r.Contact__r.Email, 
            Person__r.Contact__r.Phone, Person__r.Contact__r.MobilePhone,Person__r.Contact__r.Marital_Status__c, 
            Person__r.Contact__r.Head_Of_Household__c, Person__r.Contact__r.gfsurveys__mobilesurveys_LastCheckInDevice__c, 
            Person__r.Contact__r.gfsurveys__mobilesurveys_Username__c,Person__r.Contact__r.gfsurveys__mobilesurveys_Password__c, 
            Person__r.Contact__r.gfsurveys__mobilesurveys_Id__c, Person__r.Contact__r.Country__c,
            Person__r.Handset__r.Id,Person__r.Handset__r.Serial_Number__c, Person__r.Handset__r.Brand__c, 
            Person__r.Handset__r.IMEI__c, Person__r.Handset__r.Battery_Type__c, Person__r.Handset__r.OS_Firmware_Version__c, 
            Person__r.Handset__r.Purchase_Value_USD__c, Person__r.Handset__r.SIM__r.Id,
            Person__r.Handset__r.SIM__r.Name,Person__r.Handset__r.SIM__r.Carrier__c, Person__r.Handset__r.SIM__r.SIM_Serial_Number__c,
            Person__r.Contact__r.gfsurveys__mobilesurveys_LastCheckInDevice__r.Id,
            Person__r.Contact__r.gfsurveys__mobilesurveys_LastCheckInDevice__r.gfsurveys__LastCheckInDate__c,
            Person__r.Contact__r.gfsurveys__mobilesurveys_LastCheckInDevice__r.gfsurveys__Status__c  
            FROM CKW__c WHERE Id=:ckw.Id];
        }
        
        if(ckw.Person__c == null){
            person = new Person__c();
        }else{
            person = ckw.Person__r;
        }
        
        if(person.Contact__c != null){
            contact = ckw.Person__r.Contact__r;
        }else{
            contact = new Contact();
        }
        
        if(contact.gfsurveys__mobilesurveys_LastCheckInDevice__c != null){
            device = person.Contact__r.gfsurveys__mobilesurveys_LastCheckInDevice__r;
        }else{
            device = new gfsurveys__Device__c();
        }
            
        if(person.Handset__c != null){
            handset = ckw.Person__r.Handset__r;
        }else{
            handset = new Phone__c();
        }
        
        if(handset.SIM__c != null){
            simcard = Person.Handset__r.SIM__r;
        }else{
            simcard = new SIM__c();
        }
    }
    
    /**
     * get the Identifier of the ckw object from the url parameters
     */
    public String getCkwId(){
        return ApexPages.currentPage().getParameters().get('id');
    }
    
    /**
     * gets or sets the CKW__c custom object
     */
    public CKW__c ckw{get;set;}
    
    /**
     * gets or sets the Person__c custom object
     */
    public Person__c person{get;set;}
    
    /**
     * gets or sets the SIM__c custom object
     */
    public SIM__c simcard{get;set;}
    
    /**
     * gets or sets the Contact
     */
    public Contact contact{get;set;}
    
    /**
     * gets or sets the Phone__c custom object
     */
    public Phone__c handset{get;set;}
    
    /**
     * gets or sets the gfsurveys__Device__c custom object.
     */
    public gfsurveys__Device__c device{get;set;}
    
    /**
     * inserts or updates the SIM__c record associated with the handset 
     * the current CKW is assigned to.
     */
    public void saveSimcard(){
    	//if simcard is null, don't save/update
    	if(simcard == null)
    		return;
    		
        upsert simcard;
    }
    
    /**
     * inserts or updates the Phone__c record associated with the 
     * CKW being edited/created.
     */
    public void saveHandset(){
    	if (handset.SIM__c == null && simcard != null) {
        	handset.SIM__c = simcard.Id;
    	}
        
        upsert handset;
    }
    
    /**
     * inserts or updates the Contact record associated with the CKW 
     * being edited/created.
     */
    public void saveContact(){
        contact.MobilePhone = contact.Phone;
        contact.gfsurveys__mobilesurveys_LastCheckInDevice__c = device.Id;
        
        upsert contact;
    }
    
    /**
     * inserts or updates gfsurveys__Device__c object/record associated with the 
     * CKW being edited/created.
     */
    public void saveDevice(){
    	List<gfsurveys__Device__c> existingDevice = [
    		SELECT
    			Id,
    			gfsurveys__IMEI__c,
    			gfsurveys__OS__c,
    			gfsurveys__Model__c,
    			gfsurveys__Device_Id__c,
    			OwnerId 
    		FROM 
    			gfsurveys__Device__c 
    		WHERE 
    			gfsurveys__IMEI__c = :handset.IMEI__c
    	];
    	
    	if(existingDevice != null && !existingDevice.isEmpty()){
    		device = existingDevice.get(0);
    	}
    	
        device.gfsurveys__IMEI__c = handset.IMEI__c;
        device.gfsurveys__OS__c = handset.OS_Firmware_Version__c;
        device.gfsurveys__Model__c = handset.Brand__c;
        device.gfsurveys__Device_Id__c = handset.Serial_Number__c;
        device.OwnerId = contact.OwnerId;
        
        upsert device;
    }
    
    /**
     * inserts or updates the Person__c object referenced by the CKW being edited/created.
     */
    public void savePerson(){
        person.First_Name__c = contact.FirstName;
        person.Last_Name__c = contact.LastName;
        person.Email_Address__c = contact.Email;
        person.Country__c = contact.Country__c;
        person.Contact__c = contact.Id;
        person.Handset__c = handset.Id;
        person.ownerId = contact.OwnerId;
        
        if(person.Id == null){
            insert person;
        }else{
            update person;
        }
    }
    
    public void saveCkw(){
        if(ckw.Person__c == null){
            ckw.Person__c = person.Id;
        }
        
        upsert ckw;
    }
    
    /**
     * handles the save action of the CkwUniversalAddEditPage Visualforce page
     *
     * @return PageReference the page the will be displayed after the save operation.
     */
    public PageReference save() {
        try {
        	/**
        	 * if the IMEI has been provided
        	 * from the user interface, then we query for the existing 
        	 * handset and assign it to the handset reference in this controller.
        	 */
        	if (handset.IMEI__c != null) {
        		List<Phone__c> handsets = [
        			SELECT 
        				Id, 
        				Serial_Number__c, 
        				Brand__c, IMEI__c, 
        				Battery_Type__c, 
        				OS_Firmware_Version__c, 
            			Purchase_Value_USD__c,
        				SIM__r.Id, 
        				SIM__r.Name, 
        				SIM__r.Carrier__c, 
        				SIM__r.SIM_Serial_Number__c
        			FROM 
        				Phone__c 
        			WHERE IMEI__c = :handset.IMEI__c AND Id != :handset.Id];
        			
        		if (handsets != null && handsets.size() >= 1) {
        			List<Person__c> existingOwner = [
        				SELECT
        					Id,
        					First_Name__c,
        					Last_Name__c,
        					Handset__c
        				FROM
        					Person__c
        				WHERE Handset__c = :handsets.get(0).Id AND Id != :person.Id
        			];
        			
        			/*
        			 * if the device has an existing owner, report to the user about the 
        			 * assignee.
        			 */
        			if(existingOwner != null && !existingOwner.isEmpty()){
        				PageReference personPageRef = new ApexPages.StandardController(existingOwner.get(0)).view();
        				
        				String msgStr = 'Handset Already assigned to <a href="'+ personPageRef.getUrl()+'" target="_blank">'+ 
        					existingOwner.get(0).First_Name__c + ' ' + existingOwner.get(0).Last_Name__c+'</a>';
        					
        				ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, msgStr);
        				ApexPages.addmessage(msg);
        				
        				return null;
        			}else{
        				handset = handsets.get(0);
        				simcard = handset.SIM__r;
        			}
        		}
        	}
        	
            saveSimcard();
            saveHandset();
            saveDevice();
            saveContact();
            savePerson();
            saveCkw();
            
            return getCkwPage();
        }catch (Exception ex) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
           return null;
        }
    }
    
    /**
     * get the page reference of the current CKW being edited
     *
     * @return PageReference view page reference for the current CKW record.
     */
    public PageReference getCkwPage(){
        String ObjectPrefix = CKW__c.sObjectType.getDescribe().getKeyPrefix();
        PageReference p = new PageReference('/'+ObjectPrefix);
        p.setRedirect(true);
        
        return p;
    }
    
    /**
     * handles the SaveAndNew action of the CkwUniversalAddEditPage visualforce page and 
     * redirects the user to the create new CKW page.
     *
     * @return PageReference - page reference to which the user will be redirected.
     */
    public PageReference saveAndNew(){
        PageReference ref = save();
        if (ref != null) {
            String ObjectPrefix = CKW__c.sObjectType.getDescribe().getKeyPrefix();
            PageReference p = new PageReference('/'+ObjectPrefix+'/e');
            p.setRedirect(true);
        
            return p;
        }
        
        return ref;
    }
    
    /**
     * handles the cancel Action of the CkwUniversalAddEditPage visualforce page and 
     * redirects the user to the CKW cancel page.
     *
     * @return PageReference - page reference to which the user will be redirected.
     */
    public PageReference cancel(){
        return sController.cancel();
    }
    
    /**
     * tests the save action of this controller
     */
    @IsTest
    static void testSave(){
        CkwUniversalAddEditController controller = initTestController();
        controller.save();
        
        Phone__c handset = [SELECT Id FROM Phone__c WHERE Id=:controller.handset.Id];
        System.assertEquals(controller.handset.Id, handset.Id);
        
        gfsurveys__Device__c  device = [SELECT Id from gfsurveys__Device__c  where Id=:controller.device.Id];
        System.assertEquals(controller.device.Id, device.Id);
        
        SIM__c simcard = [SELECT Id FROM SIM__c WHERE Id=:controller.simcard.Id];
        System.assertEquals(controller.simcard.Id, simcard.Id);
        
        Person__c person = [SELECT Id FROM Person__c WHERE Id=:controller.person.Id];
        System.assertEquals(controller.person.Id, person.Id);
    }
    
    /**
     * tests the SaveAndNew action of this controller
     */
    @IsTest
    static void testSaveAndNew(){
        CkwUniversalAddEditController controller = initTestController();
        PageReference pageRef = controller.saveAndNew();
        String url = pageRef.getUrl();
        String ObjectPrefix = CKW__c.sObjectType.getDescribe().getKeyPrefix();
        System.assertEquals(url, '/'+objectPrefix+'/e');
    }
    
    /**
     * initializes the CkwUniversalAddEditController used during the test.
     *
     * @return CkwUniversalAddEditController - the initialized controller to use 
     * during testing.
     */
    static CkwUniversalAddEditController initTestController(){
        CkwUniversalAddEditController controller = new CkwUniversalAddEditController(new ApexPages.StandardController(new CKW__c()));
        controller.contact.LastName='Rambo';
        controller.contact.FirstName='John';
        controller.handset.Serial_Number__c='90000000';
        controller.handset.IMEI__c = '9989989893dkdkeid';
        controller.handset.Purchase_Value_USD__c = 450;
        controller.handset.OS_Firmware_Version__c = '4.5';
        controller.simcard.SIM_Serial_Number__c = '5566552241';
        controller.simcard.Name ='839idkdiekd';
        controller.contact.gfsurveys__mobilesurveys_Id__c='89e3938493oe3oe';
        controller.contact.gfsurveys__mobilesurveys_Username__c='8348493894';
        controller.contact.gfsurveys__mobilesurveys_Password__c='password';
        
        return controller;
    }
}
