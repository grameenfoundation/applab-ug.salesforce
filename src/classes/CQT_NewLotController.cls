public class CQT_NewLotController {
    
    public String FarmId { get; set; }
	public String FarmName { get; set; }
    public CBL_Lot__c objCBLLot { get; set; }
    public String Productor_LAC_FD_Id { get; set; }
    
    public CQT_NewLotController(){
        PageReference pageRef = ApexPages.currentPage();
        if(pageRef.getParameters().get('FarmId') == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'llamado de página sin parámetro de finca');
            ApexPages.addMessage(myMsg);
        }
        else{
            FarmId = pageRef.getParameters().get('FarmId');
        	FarmName = pageRef.getParameters().get('FarmName');
            Productor_LAC_FD_Id = pageRef.getParameters().get('ProductorId');
        }
        objCBLLot = new CBL_Lot__c();
    }
    
	public PageReference save(){
        try{
             if(FarmId == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'llamado de página sin parametro de Finca, no podrá guardar el nuevo Lote');
            	ApexPages.addMessage(myMsg);
                return null;
            }
            //get last CBL_Baseline
            CBL_Farm__c [] cblFarm = [SELECT Id FROM CBL_Farm__c WHERE Farmer__c =: Productor_LAC_FD_Id and farmName__c =: FarmName ORDER BY CreatedDate DESC];
            if(cblFarm.size() > 0){
                objCBLLot.Farm__c = cblFarm[0].Id;
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No se encuentra la finca para asociar al lote, por favor comunicarlo al administrador del sistema');
            	ApexPages.addMessage(myMsg);
                return null;
            }           
            Database.insert(objCBLLot);
            return backToMainPage();
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Finca creada exitosamente: ' + objCBLLot.Id);
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