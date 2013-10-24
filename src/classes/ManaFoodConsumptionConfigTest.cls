@IsTest
public with sharing class ManaFoodConsumptionConfigTest {
	
	@IsTest
    public static void testgetBindings() {
    	ManaFoodConsumptionConfig config = new ManaFoodConsumptionConfig();
    	List<String> foodMapKeys = new List<String>(ManaFoodConsumptionConfig.foodMap.keySet());
    	String sampleFoodName = foodMapKeys[0];
    	String purchaseSource = ManaFoodConsumptionConfig.Source_Purchase;
    	
    	String amountBinding = config.getAmountBinding(ManaFoodConsumptionConfig.sourcePrefixMap.get(purchaseSource), sampleFoodName);
    	System.assert(amountBinding == ManaFoodConsumptionConfig.sourcePrefixMap.get(purchaseSource) + 'a_' + sampleFoodName.toLowerCase());
    	
    	String codeBinding = config.getCodeBinding(ManaFoodConsumptionConfig.sourcePrefixMap.get(purchaseSource), sampleFoodName);
    	System.assert(codeBinding == ManaFoodConsumptionConfig.sourcePrefixMap.get(purchaseSource) + 'b_' + sampleFoodName.toLowerCase());
    }
}