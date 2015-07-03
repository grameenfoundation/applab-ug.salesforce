public class CQT_AnalysisPageController {
  
    public integer AnalysisAmount { get; set; }
    public CQT_Analysis__c[] AnalysisList { get; set; }
    public String Text { get; set; }
    public CQT_Analysis__c Analysis { get; set; }
    public CQT_Analysis__c Analysis2 { get; set; }
    public CQT_Analysis__c Analysis3 { get; set; }
    public CQT_Analysis__c Analysis4 { get; set; }
    
    private List<CQT_CoffeeSample__c> SampleList;
    transient public Component.Apex.pageBlockSection dynCustomCom {get;set;}
        
    public CQT_AnalysisPageController(){
        //Analysis = new CQT_Analysis__c(PerformanceFactor__c = 'PerformanceFactor_muestra1');
        //Analysis2 = new CQT_Analysis__c(PerformanceFactor__c = 'PerformanceFactor_muestra2');
        LoadSamplestoAnalysis();
    }
    
    private void LoadSamplestoAnalysis(){
        integer count = 0;
        SampleList = [SELECT Id, LAC_Farmer__r.National_ID__c, Humidity__c, CoffeeBerryBorerPercent__c, GrainFirstGroupPercent__c, Variety__c FROM CQT_CoffeeSample__c WHERE Status__c = 'new'];
        //List<CQT_Analysis__c> 
        AnalysisList = new List<CQT_Analysis__c>();
        //CQT_Analysis__c[] AnalysisList; 
        dynCustomCom = new Component.Apex.pageBlockSection(columns = 1);
        //dynCustomCom.title = 'prueba: ' + SampleList.size();
        CQT_Analysis__c tmpAnalysis;
        String str;
        for(CQT_CoffeeSample__c sample: SampleList){
            tmpAnalysis = new CQT_Analysis__c(CoffeeSample__c=sample.Id);
            AnalysisList.add(tmpAnalysis);
            //str = string.format('[Cédula productor:{0}] - [Humedad:{1}] - [%Broca:{2}] - [%GranoPG:{3}] - [Variedad:{4}]', new String[] {sample.LAC_Farmer__r.National_ID__c , sample.Humidity__c, sample.CoffeeBerryBorerPercent__c, String.valueOf(sample.GrainFirstGroupPercent__c), sample.Variety__c});
            if(tmpAnalysis.CoffeeSample__c != null)
            	dynCustomCom.childComponents.add(new Component.CQT_Analysis_v2Component(sObjAnalysis=tmpAnalysis, sObjAnalysisList=AnalysisList, CoffeeSample=sample, AdditionalInfo=string.valueOf(++count)));
        }
        if(SampleList.size() == 0)
            Text = 'No existen muestras para analizar';
        //dynCustomCom.childComponents.add(new Component.CQT_Analysis_v2Component(sObjAnalysis=Analysis, sObjAnalysisList=AnalysisList));
    }
    
    public PageReference SaveAllAnalysis() {
        
        try{
            String str;
            CQT_CoffeeSample__c tmpSample;
            integer count = 0;
            //data validation
        	for(CQT_Analysis__c cqtAnalysis: AnalysisList){
                str = DataValidation(cqtAnalysis);
                count++;
                if(!string.isEmpty(str)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Campos a obligatorios análisis # ' + count + ': ' + str);
                    ApexPages.addMessage(myMsg);
                    return null;
                }
	        }
            //insert analysis and update each coffee sample
            for(CQT_Analysis__c cqtAnalysis: AnalysisList){
                Database.insert(cqtAnalysis);
                tmpSample = changeStatusSampleCoffee(cqtAnalysis.CoffeeSample__c);
                if(tmpSample != null)
                    Database.update(tmpSample);
            }
            PageReference pageRef = new PageReference('/apex/CQT_AnalysisPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }        
        return null;
    }

    private CQT_CoffeeSample__c changeStatusSampleCoffee(id idSample){
        for(CQT_CoffeeSample__c sample: SampleList){
            if(sample.Id == idSample){
                sample.Status__c = 'analyzed';
                return sample;
            }                
        }
        return null;
    }
    
    private String DataValidation(CQT_Analysis__c AnalysisVal){
    	String str = '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Taster__c))? 'Catador, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.RoastLevelOfSample__c))? 'Nivel de la muestra, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.FraganceAroma__c))? 'Fragancia/Aroma, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Dry__c))? 'Seco, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Break__c))? 'Espuma, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Flavor__c))? 'Sabor, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.AfterTaste__c))? 'S. Residual, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Acidity__c))? 'Acidez, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Intensity__c))? 'Intensidad, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Body__c))? 'Cuerpo, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Level__c))? 'Intensidad, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Uniformity__c))? 'Uniformidad, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Balance__c))? 'Balance, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.CleanCup__c))? 'Taza Limpia, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Sweetness__c))? 'Dulzor, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.Overall__c))? 'Puntaje Catador, ': '';
        str += (FieldIsEmptyOrNull(AnalysisVal.IntensityDefect__c))? 'Intensidad Defectos, ': '';
        return str;
    }
    
    private boolean FieldIsEmptyOrNull(object obj){
        if (obj == null)
            return true;
        else if (string.isEmpty(string.valueOf(obj)))
            return true;
        else return false;
    }
}