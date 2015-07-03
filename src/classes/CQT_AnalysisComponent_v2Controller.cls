public class CQT_AnalysisComponent_v2Controller {
    
    public String TasterSelected { get; set; }
    public List<SelectOption> TasterOptions {get; set; }
    public String SampleSearch   { get; set; }
    public List<SelectOption> SampleOptions {get; set; }
    public String SampleSelected { get; set; }
    public CQT_Analysis__c Analysis { get; set; }
    
    public String SumFraganceAroma { get; set; }
    public String NumDefectCups { get; set; }
    public Decimal TotalDefects { get; set; }
    public Decimal SubTotalScore { get; set; }
    public Decimal TotalScore { get; set; }
    
    public CQT_AnalysisComponent_v2Controller(){
        init();
    }
    
    private void init(){
        //Analysis = new CQT_Analysis__c();
        getTasterOptions();
        SampleOptions = new List<SelectOption>();
        SampleOptions.add(new SelectOption('','Seleccione una Muestra'));
        SampleSearch = (Analysis == null)? 'nulo': 'valor';
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
            if(Analysis.CoffeeSample__c == null){ //SampleSelected
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
    
    //public void AssignSampleToAnalysis(){
    //    Analysis.CoffeeSample__c = ;
    //}
    
    public void SumFraganceAroma(){
        //avg FraganceAroma__c, Dry__c & Break__c
        //Decimal avg = (String.isEmpty(String.valueOf(Analysis.FraganceAroma__c)) ? 0 : Decimal.valueOf(Analysis.FraganceAroma__c)) + (String.isEmpty(String.valueOf(Analysis.Dry__c)) ? 0 : Decimal.valueOf(Analysis.Dry__c)) + (String.isEmpty(String.valueOf(Analysis.Break__c)) ? 0 : Decimal.valueOf(Analysis.Break__c));
        Decimal avg = 0;
        decimal divisor = 0;
        if(!String.isEmpty(String.valueOf(Analysis.FraganceAroma__c))){
            avg += Decimal.valueOf(Analysis.FraganceAroma__c);
            divisor++;
        }
        if(!String.isEmpty(String.valueOf(Analysis.Dry__c))){
            avg += Decimal.valueOf(Analysis.Dry__c);
            divisor++;
        }
        if(!String.isEmpty(String.valueOf(Analysis.Break__c))){
            avg += Decimal.valueOf(Analysis.Break__c);
            divisor++;
        }
        avg = avg / divisor;
		SumFraganceAroma = String.valueOf(roundingScale(avg));
        TotalScore();
    }
    
    private decimal roundingScale(Decimal decTarget){
        //possible decimal values: [0.00 - 0.25 - 0.50 - 0.75]
        Decimal intPart = decTarget.intValue();
        decTarget = decTarget - intPart;
        if(decTarget >= 0.875)
            intPart += 1.00;
        else if(decTarget >= 0.625)
            intPart += 0.75;
        else if(decTarget >= 0.375)
            intPart += 0.50;
        else if(decTarget >= 0.125)
            intPart += 0.25;
        else
            intPart += 0.00;
        return intPart;
    }
    
    public void FillDefects(){
        String tmp = String.valueOf(Analysis.Uniformity__c);
        /*if (tmp == '1 Taza')
            NumDefectCups = '1';
        else if (tmp == '2 Tazas')
            NumDefectCups = '2';
        else if (tmp == '3 Tazas')
            NumDefectCups = '3';
        else if (tmp == '4 Tazas')
            NumDefectCups = '4';
        else if (tmp == '5 Tazas')
            NumDefectCups = '5';
        else NumDefectCups = '0';
		*/
        NumDefectCups = String.valueOf(NumCups(tmp));
        MultDefects();
    }
    
    public void MultDefects(){
        String tmp = String.valueOf(Analysis.IntensityDefect__c);
        integer intOperation = 0;
        if (tmp == 'Ligero=2')
            intOperation = 2;
        else if (tmp == 'Rechazo=4')
            intOperation = 4;
        else intOperation = 0;
        TotalDefects = NumCups(String.valueOf(Analysis.Uniformity__c)) * intOperation;
        TotalScore();
    }
    
    public void TotalScore(){
        SubTotalScore = TotalScore = 0;
        SubTotalScore = valueOf(Analysis.RoastLevelOfSample__c) + valueOf(SumFraganceAroma) + valueOf(Analysis.Flavor__c) + valueOf(Analysis.AfterTaste__c) + valueOf(Analysis.Acidity__c) + valueOf(Analysis.Body__c) + valueOf(Analysis.Balance__c) + valueOf(Analysis.Overall__c) + NumCupsInvert(Analysis.CleanCup__c) + NumCupsInvert(Analysis.Sweetness__c);
        if(TotalDefects == null) TotalDefects = 0;
        TotalScore = SubTotalScore - TotalDefects;
        Analysis.TotalDefects__c = TotalDefects;
        Analysis.TotalScore__c = TotalScore;
    }
    
    private Decimal valueOf(String str){
        if(str == '' || string.isEmpty(str))
            return 0.0;
        else
            return Decimal.valueOf(str); 
    }
    
    private Decimal valueOfCups(String str){
        if(str == '' || string.isEmpty(str))
            return 10.0;
        else
            return Decimal.valueOf(str); 
    }
    
    private integer NumCups(string str){
        integer intNumCups;
        if (str == '1 Taza')
            intNumCups = 1;
        else if (str == '2 Tazas')
            intNumCups = 2;
        else if (str == '3 Tazas')
            intNumCups = 3;
        else if (str == '4 Tazas')
            intNumCups = 4;
        else if (str == '5 Tazas')
            intNumCups = 5;
        else intNumCups = 0;
        return intNumCups;
    }
    
    private integer NumCupsInvert(string str){
        integer intNumCups;
        if (str == '1 Taza')
            intNumCups = 8;
        else if (str == '2 Tazas')
            intNumCups = 6;
        else if (str == '3 Tazas')
            intNumCups = 4;
        else if (str == '4 Tazas')
            intNumCups = 2;
        else if (str == '5 Tazas')
            intNumCups = 0;
        else intNumCups = 10;
        return intNumCups;
    }
}