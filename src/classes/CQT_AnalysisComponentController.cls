public class CQT_AnalysisComponentController {

    public String TasterSelected { get; set; }
    public List<SelectOption> TasterOptions {get; set; }
    public String SampleSearch   { get; set; }
    public List<SelectOption> SampleOptions {get; set; }
    public String SampleSelected { get; set; }
    public CQT_Analysis__c Analysis { get; set; }
    
    public CQT_AnalysisComponentController(){
        init();
    }
    
    private void init(){
        //Analysis = new CQT_Analysis__c();
        getTasterOptions();
        SampleOptions = new List<SelectOption>();
        SampleOptions.add(new SelectOption('','Seleccione una Muestra'));
    }
    
    private void getTasterOptions(){
        TasterOptions = new List<SelectOption>();
        TasterOptions.add(new SelectOption('','Seleccione un Catador'));
        list<CQT_Taster__c> tastersList = [SELECT Id, Name, firstName__c, lastName__c FROM CQT_Taster__c];
        for(CQT_Taster__c taster : tastersList){
            TasterOptions.add(new SelectOption(taster.Id, taster.firstName__c + ' ' + taster.lastName__c + ' (' + taster.Name + ')'));
        }
    }
    
    public void searchSampleOptions(){
        SampleOptions = new List<SelectOption>();
        SampleOptions.add(new SelectOption('','Seleccione una Muestra'));
        String queryStr = 'SELECT Id, Name FROM CQT_CoffeeSample__c WHERE Name LIKE \'%' + SampleSearch + '%\' LIMIT 15';
        //SampleOptions.add(new SelectOption('',queryStr));
        list<CQT_CoffeeSample__c> samplesList = Database.query(queryStr);
        for(CQT_CoffeeSample__c sample : samplesList){
            SampleOptions.add(new SelectOption(sample.Id, sample.Name));
        }
    }
    
    public PageReference save() {
        try{
            if(Analysis == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Análisis es null');
                ApexPages.addMessage(myMsg);
                return null;
            }
                
            if(TasterSelected == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Debe seleccionar un Catador');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(SampleSelected == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Debe seleccionar una Muestra');
                ApexPages.addMessage(myMsg);
                return null;
            }            
            Analysis.Taster__c = TasterSelected;
            Analysis.CoffeeSample__c = SampleSelected;
            //Database.insert(Analysis);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Análisis exitosamente ingresado Id: ' + Analysis.Id);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'la funcionalida de guardar será establecida en la página principal');
            ApexPages.addMessage(myMsg);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }        
        return null;
    }
    
    public void AssignTasterToAnalysis(){
        Analysis.Taster__c = TasterSelected;
    }
    
    public void AssignSampleToAnalysis(){
        Analysis.CoffeeSample__c = SampleSelected;
    }
}