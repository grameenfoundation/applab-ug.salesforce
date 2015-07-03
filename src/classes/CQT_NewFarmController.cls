public class CQT_NewFarmController {
    
    public String Productor_LAC_FD_Id { get; set; }
	public String ProductorName { get; set; }
    public CBL_Farm__c objCBLFarm { get; set; }

    public CQT_NewFarmController(){
        PageReference pageRef = ApexPages.currentPage();
        if(pageRef.getParameters().get('ProductorId') == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'llamado de página sin parámetro de productor');
            ApexPages.addMessage(myMsg);
        }
        else{            
            Productor_LAC_FD_Id = pageRef.getParameters().get('ProductorId');
        	ProductorName = pageRef.getParameters().get('ProductorName');
        }
        objCBLFarm = new CBL_Farm__c();
    }
    
    public PageReference save(){
        try{
             if(Productor_LAC_FD_Id == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'llamado de página sin parametro de productor, no podrá guardar la nueva Finca');
            	ApexPages.addMessage(myMsg);
                return null;
            }
            //get last CBL_Baseline
            CBL_CoffeeBaseline__c [] cblBaseline = [SELECT Id FROM CBL_CoffeeBaseline__c WHERE Farmer__c =: Productor_LAC_FD_Id ORDER BY CreatedDate DESC];
            if(cblBaseline.size() > 0){
                objCBLFarm.Baseline__c = cblBaseline[0].Id;
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'El productor no tiene Línea Base, por favor comunicarlo al administrador del sistema');
            	ApexPages.addMessage(myMsg);
                return null;
            }           
            objCBLFarm.Farmer__c = Productor_LAC_FD_Id;
            Database.insert(objCBLFarm);
            return backToMainPage();
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Finca creada exitosamente: ' + objCBLFarm.Id);
            //ApexPages.addMessage(myMsg);
            //return null;
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }        
    }
    
    public PageReference cancel(){
        return backToMainPage();
    }
    
    private PageReference backToMainPage(){
        //send the user to main page to continue with the process
        PageReference pageRef = new PageReference('/apex/CQT_SamplePage');
        pageRef.setRedirect(true);
        return pageRef;
    }
}