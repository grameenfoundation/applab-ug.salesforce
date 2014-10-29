public class ManaConsumptionChart {

    private ApexPages.StandardController stdController;
	private Mana_Household__c houseHold;
    private List<AggregateResult> foodConsumption;

    public ManaConsumptionChart(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.houseHold = (Mana_Household__c)controller.getRecord();                                                
    }

    public List<AggregateResult> getFoodConsumption() {
        List<AggregateResult> foodConsumption = [Select Count (Id) i, 
                                                                    Food__r.Category__c nm
                                                                    From Mana_Food_Consumption_Record__c
                                                                    where Household__c =:houseHold.Id 
                                                                    group by  Food__r.Category__c];
                                                                    
        return foodConsumption;
    }

    public List<PieWedgeData> getPieData(){

    List<PieWedgeData> data = new List<PieWedgeData>();
    for (AggregateResult ar : getFoodConsumption()) {
        data.add(new PieWedgeData(
                (String) ar.get('nm'),
                (Integer) ar.get('i')
                ));
    }
    return data;
}

public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
}