@isTest
private class TestManaConsumptionChart {


	@isTest static void test_method_pieChart() {

		Mana_Household__c houseHold = new Mana_Household__c(Name = '12345678');
		insert houseHold;

		ApexPages.StandardController controller = new ApexPages.standardController(houseHold);


		Mana_Food__c food = new Mana_Food__c(Category__c = 'Vegetales', Name = 'Lechuga');
		insert food;

		Mana_Food_Consumption_Record__c foodConsumption = new Mana_Food_Consumption_Record__c( Household__c = houseHold.Id, Food__c = food.Id, Number_Consumed__c = 200);
		insert foodConsumption;

		
		ManaConsumptionChart mcc = new ManaConsumptionChart(new ApexPages.StandardController(houseHold));
		mcc.getFoodConsumption();
		System.assert(foodConsumption != null);

		String testName = 'test';
		Integer testSize = 1000;
		ManaConsumptionChart.pieWedgeData innerClass = new ManaConsumptionChart.pieWedgeData(testName, testSize);
		List<ManaConsumptionChart.pieWedgeData> testList = mcc.getPieData();

        System.assert(testList != null);
	}
	
}