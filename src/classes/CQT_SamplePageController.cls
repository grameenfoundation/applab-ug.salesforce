public class CQT_SamplePageController { 
    
    public LAC_Farmer_Details__c objLACFarmerD;
    private CBL2_Farmer__c objFarmer;
    private CBL2_Farm__c objFarm;
    private CBL2_Lot__c objLot;
    //private Id LACFarmerDetails_Id;
    
    public CQT_SamplePageController () {
        Init();
        //if(ProductorId == null)
            //ProductorId = '000000003';
        //testReport();
    }
    
    private void Init(){
        ProductorId = '';
        ProductorName = '';
        ProductorLastName = '';
        FarmSelected = '';
        LotSelected = '';
        FarmSelected_Name = '';
        ProductorIdSelected = '';
        FarmsOptions = new List<SelectOption>();
        FarmsOptions.add(new SelectOption('','Seleccione una finca'));
        LotsOptions = new List<SelectOption>();
        LotsOptions.add(new SelectOption('','Lote no especificado'));
        objCoffeeSample = new CQT_CoffeeSample__c();
        ProducersOptions = new List<SelectOption>();
        ProducersOptions.add(new SelectOption('','Aquí aparecerá la lista de productores encontrados'));   
    }
    
    public String ProductorId { get; set; }
    public String ProductorName { get; set; }
    public String ProductorLastName { get; set; }
    public String FarmSelected { get; set; }
    public List<SelectOption> FarmsOptions {get; set; }
    public String LotSelected { get; set; }
    public List<SelectOption> LotsOptions {get; set; }
    public String FarmSelected_Name { get {return getNameFarmSelected();} set {} }
    public CQT_CoffeeSample__c objCoffeeSample { get; set; }
    public List<SelectOption> ProducersOptions {get; set; }
    public String ProductorIdSelected { get; set; }
        
    /*public PageReference SearchProductor() {
        //if(ProductorId != null)
        String queryStr = 'SELECT Id, National_ID__c, Contact__r.FirstName, First_Name__c, Last_Name__c FROM LAC_Farmer_Details__c WHERE National_ID__c = \'' + ProductorId + '\'';
        LAC_Farmer_Details__c [] LACfarmers = Database.query(queryStr);
        if(LACfarmers.size() > 0){
            ProductorName = LACfarmers[0].First_Name__c + ' ' + LACfarmers[0].Last_Name__c;
            LACFarmerDetails_Id = LACfarmers[0].Id;
            SearchFarmer_and_Farms(LACFarmerDetails_Id);
        }
        else
            ProductorName = 'no se encontró productor';
        return null;
    }*/
    
    public PageReference SearchProducers() {
        String queryStr = 'SELECT Id, National_ID__c, Contact__r.FirstName, First_Name__c, Last_Name__c FROM LAC_Farmer_Details__c WHERE National_ID__c LIKE \'%' + ProductorId + '%\' AND Contact__r.FirstName LIKE \'%' + ProductorName + '%\' AND Last_Name__c LIKE \'%' + ProductorLastName + '%\' LIMIT 6';
        LAC_Farmer_Details__c [] LACfarmers = Database.query(queryStr);
        if(LACfarmers.size() > 0){
            ProducersOptions = new List<SelectOption>();
            for(LAC_Farmer_Details__c farmer : LACfarmers){
                ProducersOptions.add(new SelectOption(farmer.Id, farmer.National_ID__c + ' - ' + farmer.First_Name__c + ' ' +farmer.Last_Name__c));
            }
            if(LACfarmers.size() > 5){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Existen más registos encontrados, por favor ajuste el (los) témino(s) de búsqueda');
                ApexPages.addMessage(myMsg);
            }
        }
        else
            ProductorName = 'no se encontró productor';
        return null;
    }
    
    /*private void SearchFarmer_and_Farms(Id Id_LACFarmerDetail) {
        CBL2_Farmer__c [] cbl2Farmers = [SELECT Id FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c =: Id_LACFarmerDetail];
        if(cbl2Farmers.size() > 0){
            //CBL2_Farm__c [] cbl2Farms = [SELECT Id, farmName__c FROM CBL2_Farm__c WHERE CBL2_Farms_Farmer__c =: cbl2Farmers[0].Id];
            CBL2_Farm__c [] cbl2Farms = [SELECT Id, farmName__c FROM CBL2_Farm__c WHERE Farmer__c =: Id_LACFarmerDetail];
            FarmsOptions = new List<SelectOption>();
            //boolean isDisabled = (cbl2Farms.size() > 0) ? true: false;
            //FarmsOptions.add(new SelectOption('','Seleccione una finca', isDisabled));
            FarmsOptions.add(new SelectOption('','Seleccione una finca'));
            if(cbl2Farms.size() > 0){                
                for (CBL2_Farm__c farm : cbl2Farms){
                    FarmsOptions.add(new SelectOption(farm.Id, farm.farmName__c));                 
                }
            }
        }            
    }*/
    
    public void SearchFarmer_and_Farms() {
		FarmSelected = '';
        FarmSelected_Name = '';
        LotSelected = '';
        CBL2_Farmer__c [] cbl2Farmers = [SELECT Id, LAC_Farmer_Details__r.National_ID__c, LAC_Farmer_Details__r.First_Name__c, LAC_Farmer_Details__r.Last_Name__c FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c =: ProductorIdSelected];
        if(cbl2Farmers.size() > 0){
            ProductorId = cbl2Farmers[0].LAC_Farmer_Details__r.National_ID__c;
            ProductorName = cbl2Farmers[0].LAC_Farmer_Details__r.First_Name__c;
            ProductorLastName = cbl2Farmers[0].LAC_Farmer_Details__r.Last_Name__c;
            //CBL2_Farm__c [] cbl2Farms = [SELECT Id, farmName__c FROM CBL2_Farm__c WHERE CBL2_Farms_Farmer__c =: cbl2Farmers[0].Id];
            CBL2_Farm__c [] cbl2Farms = [SELECT Id, farmName__c FROM CBL2_Farm__c WHERE Farmer__c =: ProductorIdSelected];
            FarmsOptions = new List<SelectOption>();
            //boolean isDisabled = (cbl2Farms.size() > 0) ? true: false;
            //FarmsOptions.add(new SelectOption('','Seleccione una finca', isDisabled));
            FarmsOptions.add(new SelectOption('','Seleccione una finca'));
            if(cbl2Farms.size() > 0){                
                for (CBL2_Farm__c farm : cbl2Farms){
                    FarmsOptions.add(new SelectOption(farm.Id, farm.farmName__c));                 
                }
            }
            LotsOptions = new List<SelectOption>();
            LotsOptions.add(new SelectOption('','Lote no especificado'));
        }            
    }
    
    public void SearchLots() {
        if(FarmSelected != ''){
            CBL2_Lot__c [] cbl2lots = [SELECT Id, lotName__c FROM CBL2_Lot__c WHERE Farm__c =: FarmSelected];
            LotsOptions = new List<SelectOption>();
            LotsOptions.add(new SelectOption('','Lote no especificado'));
            for(CBL2_Lot__c lot : cbl2lots){
                LotsOptions.add(new SelectOption(lot.Id, lot.lotName__c));                
            }
        }
    }
    
    private String getNameFarmSelected(){
        String strName = '';
        for(SelectOption option : FarmsOptions){
            if(FarmSelected == option.getValue())
                strName = Option.getLabel();
        }        
        return strName;        
    }
    
    public PageReference save() {
        if(ProductorIdSelected == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Debe seleccionar un productor');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(FarmSelected == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Debe seleccionar una Finca');
            ApexPages.addMessage(myMsg);
            return null;
        } 
        objCoffeeSample.LAC_Farmer__c = ProductorIdSelected;
        objCoffeeSample.Farm__c = FarmSelected;
        if(LotSelected != null)
            objCoffeeSample.Lot__c = LotSelected;
        try{
            Database.insert(objCoffeeSample);
            Init();
            PageReference pageRef = new PageReference('/apex/CQT_SamplePage');
        	pageRef.setRedirect(true);
        	return pageRef;
            //return new pagereference(page.CQT_SamplePage.getUrl());
        }
        catch(system.Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //contact.accountId = account.id;
        //ApexPages.StandardController contactController = new ApexPages.StandardController(contact);
        //return contactController.save();
        return null;//redirect to other page
    }
    
    public PageReference ClearAllFilds(){
        Init();        
        return null;
    }
    
    public PageReference AddAnalysis() {
        PageReference pageRef = new PageReference('/apex/CQT_AnalysisPage');
       	pageRef.setRedirect(true);
       	return pageRef;
    }
    
    /*public PageReference callpageredirect(){
        //<apex:commandLink action="{!callpageredirect}" value="Crear Nuevo Productor"/>
        PageReference demoPage = new PageReference('/apex/DeleteSurvey');
        demoPage.setRedirect(true);
        return demoPage;
    }*/
    
    /*
    public List<Report> Reportes {get; set; }
    
    public void testReport(){
        //string abc = reports.ReportMetadata.getName();
        Id reportId = '00O700000049Sbl'; //'00O70000004rBAX';
        //Reportes = [SELECT Id, Name, OwnerId FROM Report where Id =:reportId];
        Reportes = [SELECT Id, Name, OwnerId, DeveloperName FROM Report where Id=: reportId LIMIT 10];
        for(Report rep : reportes){
            Reports.ReportMetadata rm = Reports.ReportManager.describeReport(rep.Id).getReportMetadata();
            objCoffeeSample.Notes__c = rm.getReportType().getLabel() + ' - ' + rm.getReportType().getType();
        }
        
        //id report 00O700000049Sbl
        //report type Person Group Handsets 2
        //id report type 07070000000TVkL
        
        //Reports.ReportMetadata RepMet = Reports.ReportManager.describeReport(reportId).getReportMetadata();
    }
	*/

}