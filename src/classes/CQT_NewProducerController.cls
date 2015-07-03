public class CQT_NewProducerController {

    public String NationalID { get; set; }
    public String ProductorName { get; set; }
    public String ProductorLastName { get; set; }
    public String PhoneNumber { get; set; }
    public String Community { get; set; }
    
    public CQT_NewProducerController(){
        
    }
    
    public PageReference save(){
        try{
            if(NationalID == '' || ProductorName == '' || ProductorLastName == ''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Debe ingresar toda la información solicitada');
                ApexPages.addMessage(myMsg);
                return null;
    		}
            
        	//create contact
            contact NewContact = new Contact(FirstName = ProductorName, LastName = ProductorLastName);
            Database.insert(NewContact);
            //Country, OrganizationName, ContactOwner ???
            //create LAC Farmer Details
            LAC_Farmer_Details__c NewLAC_FD = new LAC_Farmer_Details__c(Contact__c = NewContact.Id, National_ID__c=NationalID, Community__c=Community, Cell_Phone_Number__c=PhoneNumber);
            Database.insert(NewLAC_FD);
            //create CBL Coffee Baseline (this data is update to cbl2 by triggers)
            CBL_CoffeeBaseline__c NewCBL_CBL = new CBL_CoffeeBaseline__c(Farmer__c = NewLAC_FD.Id, baselineName__c = 'Creado por CQT');
            Database.insert(NewCBL_CBL);
            
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Productor creado exitosamente');
            //ApexPages.addMessage(myMsg);
			
            return backToMainPage();
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference cancel(){
    	//other option in tag <apex:commandButton: oncomplete="window.open('/apex/CQT_SamplePage')"
    	return backToMainPage();
    }
    
    private PageReference backToMainPage(){
        //send the user to main page to continue with the process
        PageReference pageRef = new PageReference('/apex/CQT_SamplePage');
        pageRef.setRedirect(true);
        return pageRef;
    }    
}