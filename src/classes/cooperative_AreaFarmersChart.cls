public with sharing class cooperative_AreaFarmersChart {

    private ApexPages.StandardController stdController;
    private LAC_Cooperative__c cooperative;
    public Decimal maxFarmArea;
    
    public Cooperative_AreaFarmersChart(ApexPages.StandardController controller) {
        if (controller <> null){
            this.stdController = controller;
            this.cooperative = (LAC_Cooperative__c)controller.getRecord();
            getMaxFarmArea();       
        }                                         
    }
    
    /**
    *Get the maximum farm area related to a cooperative
    *
    */
    public void getMaxFarmArea(){
        maxFarmArea = (Decimal) [Select MAX(Farm_Area__c) fArea 
                                From LAC_Farmer_Details__c 
                                Where cooperativeProfile__c =:cooperative.Id][0].get('fArea');
        if (maxFarmArea == null) maxFarmArea = 0;
    }

    /**
    *Get an area list related to a farmers that belongs a specific cooperative
    *
    */
    public List<LAC_Farmer_Details__c> getAreaFarmers() {
        List<LAC_Farmer_Details__c> areaFarmers= [Select Farmer_Code__c, 
                                                Farm_Area__c 
                                                From LAC_Farmer_Details__c 
                                                Where cooperativeProfile__c =:cooperative.Id];                                                                    
        return areaFarmers;
    }

    /**
    *Create a range of values to group (or categorize) each area, the increment is 1 unit  
    *
    */
    private Map<Integer, Integer> prepareCategories(){
        Map<Integer, Integer> mapCategory = new Map<Integer, Integer>();
        Integer MaxArea = maxFarmArea.round(System.RoundingMode.CEILING).intValue();
        
        for(Integer i=0; i<=MaxArea; i++){
            mapCategory.put(i, 0);
        }
        return mapCategory;
    }
    
    /**
    *Get the amount of areas categorized
    *
    */
    Public List<barSerieData> getCategories(){
        List<barSerieData> data = new List<barSerieData>();
        Map<Integer, Integer> mapCategory = prepareCategories();
        for (LAC_Farmer_Details__c areas : getAreaFarmers()) {
            mapCategory.put(areas.Farm_Area__c.intValue(), mapCategory.get(areas.Farm_Area__c.intValue()) + 1);
        }
        
        List<Integer> categoryOrder = new List<Integer>(mapCategory.keySet());
        categoryOrder.sort();
        for (Integer category : categoryOrder){
            data.add(new barSerieData(category.format(), mapCategory.get(category)));
        }
        return data;
    }
    
    public LAC_Cooperative__c cooperativeProp{
        get{return cooperative; }
        set{cooperative = value; }
    }

    public class barSerieData {

        public String name { get; set; }
        public Decimal data { get; set; }

        public barSerieData(String name, Decimal data) {
            this.name = name;
            this.data = data;
        }
    }
}
