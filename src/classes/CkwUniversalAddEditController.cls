/**
 * This class is an extension of the StandardController for the CKW__c 
 * custom object.
 *
 * This controller extension handles the Universal page for creating a CKW along with the supporting 
 * records such as; Person, Contact, Handset and Simcard
 */
public with sharing class CkwUniversalAddEditController {
    ApexPages.StandardController sController = null;
    private Phone__c tempHandset;
    private Attachment profilePicture;
    private gfsurveys__Mobile_User__c mobileUser;
    
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
            Person__r.Contact__r.Head_Of_Household__c,
            Person__r.Contact__r.gfsurveys__mobilesurveys_Id__c, Person__r.Contact__r.Country__c,
            Person__r.Handset__r.Id,Person__r.Handset__r.Serial_Number__c, Person__r.Handset__r.Brand__c, 
            Person__r.Handset__r.IMEI__c, Person__r.Handset__r.Battery_Type__c, Person__r.Handset__r.OS_Firmware_Version__c, 
            Person__r.Handset__r.Purchase_Value_USD__c, Person__r.Handset__r.SIM__r.Id,
            Person__r.Handset__r.SIM__r.Name,Person__r.Handset__r.SIM__r.Carrier__c, Person__r.Handset__r.SIM__r.SIM_Serial_Number__c,
            Person__r.Contact__r.Picture__c,
            Person__r.Contact__r.Picture_Attachment_Id__c  
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
        
        this.profilePicture = new Attachment();
        this.mobileUser = new gfsurveys__Mobile_User__c();
    }

	public Attachment getProfilePicture() {
		this.profilePicture = new Attachment();
		
		if (contact.Picture_Attachment_Id__c != null) {
			List<Attachment> attachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Id = :contact.Picture_Attachment_Id__c ];
			if (!attachments.isEmpty()) {
				this.profilePicture = attachments.get(0);
			}
		}
		
		return this.profilePicture;
	}
	
	public gfsurveys__Mobile_User__c getMobileUser() {
		this.mobileUser = new gfsurveys__Mobile_User__c();
		if(contact.Id != null) {
			gfsurveys__Mobile_User__c[] mobileUsers = [SELECT Id, gfsurveys__Contact__c, gfsurveys__Password__c, gfsurveys__Status__c, gfsurveys__Username__c from gfsurveys__Mobile_User__c WHERE gfsurveys__Contact__c = :contact.Id LIMIT 1];
			if(!mobileUsers.isEmpty()) {
				this.mobileUser = mobileUsers.get(0);
			}
		}
		
		return this.mobileUser;
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
    public Phone__c existingHandset{get;set;}
    
    /**
     * inserts or updates the SIM__c record associated with the handset 
     * the current CKW is assigned to.
     */
    public void saveSimcard(){
        //if simcard is null, don't save/update
        if(simcard == null)
            return;
            
        if (simcard.SIM_Serial_Number__c == null) {
            simcard.SIM_Serial_Number__c.addError(Label.MISSING_REQUIRED_FIELD);
            return;
        }
            
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
        
        if (handset.IMEI__c == null) {
            handset.IMEI__c.addError(Label.MISSING_REQUIRED_FIELD);
        }
        
        if (handset.Serial_Number__c == null) {
            handset.Serial_Number__c.addError(Label.MISSING_REQUIRED_FIELD);
        }
        
        if (handset.Purchase_Value_USD__c == null) {
            handset.Purchase_Value_USD__c.addError(Label.MISSING_REQUIRED_FIELD);
        }
        
        upsert handset;
    }
    
    /**
     * inserts or updates the Contact record associated with the CKW 
     * being edited/created.
     */
    public void saveContact(){
        contact.MobilePhone = contact.Phone;
        
        upsert contact;
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
        
        /*
    	 * if the ckw status is changed to dropped, we don't assign 
    	 * the handset details to the person
    	 */
    	if (ckw.Status__c != 'Dropped') {
        	person.Handset__c = handset.Id;
    	} else {
    		person.Handset__c = null;
    	}
    	
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
     * gets the existing handset with the IMEI specified by the user in the 
     * handset property.
     */
    private Phone__c getExistingHandset() {
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
                WHERE IMEI__c = :handset.IMEI__c];
                
            if(handsets != null && !handsets.isEmpty()){
                return handsets.get(0);
            }
        }

    	return null;
    }
    
    /**
     * handles the save action of the CkwUniversalAddEditPage Visualforce page
     *
     * @return PageReference the page the will be displayed after the save operation.
     */
    public PageReference save() {
        try {    
            /*
             * if the ckw status is changed to dropped, we don't save the handset
             * details.
             */
            if (ckw.Status__c != 'Dropped') {
                Phone__c p = getExistingHandset();
                
                if (p != null) {
                    /*List<Person__c> existingOwner = [
                        SELECT
                            Id,
                            First_Name__c,
                            Last_Name__c,
                            Handset__c
                        FROM
                            Person__c
                        WHERE Handset__c = :p.Id AND Id != :person.Id
                    ];*/
                    List<CKW__c> existingOwner = [
                        SELECT
                            Id,
                            Person__r.Id,
                            Person__r.First_Name__c,
                            Person__r.Last_Name__c,
                            Person__r.Handset__c
                        FROM
                            CKW__c
                        WHERE
                            Person__r.Handset__c = :p.Id AND Person__r.Id != :person.Id
                    ];
                    
                    
                    /*
                     * if the handset has an existing owner, report to the user about the 
                     * assignee.
                     */
                    if(existingOwner != null && !existingOwner.isEmpty()) {
                        PageReference personPageRef = new ApexPages.StandardController(existingOwner.get(0)).view();
                        
                        String msgStr = 'Handset Already assigned to <a href="'+ personPageRef.getUrl()+'" target="_blank">'+ 
                            existingOwner.get(0).Person__r.First_Name__c + ' ' + existingOwner.get(0).Person__r.Last_Name__c+'</a>';
                            
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, msgStr);
                        ApexPages.addmessage(msg);
                        
                        return null;
                    } else {
                        /*
                         * if the handset is new or when the handset identifier is not equal to the 
                         * exising handset with the given IMEI
                         */
                        if (handset.Id == null || handset.Id != p.Id) {
                            handset = p;
                        }
                        
                        /*
                         * if the handset doesn't have a simcard and only when the simcard is 
                         * a new simcard
                         */ 
                        if (handset.SIM__r != null && simcard.Id == null) {
                            simcard = handset.SIM__r;
                        }
                    }
                }
                
                saveSimcard();
                saveHandset();
            }
            
            if (!ApexPages.hasMessages()) {
                saveContact();
                saveMobileUser();
                saveProfilePicture();
                savePerson();
                saveCkw();
                
                return getCkwPage();
            } else{
                return null;
            }
        } catch (Exception ex) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
           return null;
        }
    }
    
    /**
    * Save mobile User
    */
    public void saveMobileUser() {
    	if(this.mobileUser.Id != null) {
    		update this.mobileUser;
    	} else {
    		this.mobileUser.gfsurveys__Contact__c = contact.Id;
    		insert this.mobileUser;
    	}
    }
    
    /**
    * Save profile picture
    */
    public void saveProfilePicture() {
    	if(this.profilePicture.Body != null) {
			this.profilePicture.OwnerId = UserInfo.getUserId();
			
	    	if(this.profilePicture.Id != null) {
			 	update this.profilePicture;
	    	} else {
	    		this.profilePicture.Name = 'Profile Picture';
	    		this.profilePicture.ParentId = contact.Id;
	    		this.profilePicture.IsPrivate = true;
	    		insert this.profilePicture;
	    		
	    		// Set this as the active profile picture for the contact
				contact.Picture_Attachment_Id__c = this.profilePicture.Id;
				upsert contact; // Save contact again
	    	}
	    	
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
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
     * this method is called through an ajax request to assign an existing handset.
     *
     * @return PageReference - page reference to which the user will be redirected.
     */
    public PageReference assignExistingHandset() {
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
                WHERE Id = :person.Handset__c];
                
            if(handsets != null && !handsets.isEmpty()){
                handset = handsets.get(0);
                simcard = handsets.get(0).SIM__r;
            } else {
                handset = new Phone__c();
                simcard = new SIM__c();
            }
            
        return null;
    }
}