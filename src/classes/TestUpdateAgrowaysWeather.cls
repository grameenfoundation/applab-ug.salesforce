@isTest
public class TestUpdateAgrowaysWeather {

	private static TestMethod void testUpdateWeather() {

		// Set up CKW Search Menu
		Menu__c ckwSearchMenu = new Menu__c();
		ckwSearchMenu.Label__c = 'CKW Search';
		database.SaveResult menuSaveResult = database.insert(ckwSearchMenu);
		Menu_Item__c topLevel = new Menu_Item__c();
		topLevel.Menu__c = menuSaveResult.getId();
		topLevel.Label__c = 'Regional Weather Info';
		database.SaveResult topLevelSR = database.insert(topLevel);
		Menu_Item__c level2 = new Menu_Item__c();
		level2.Parent_Item__c = topLevelSR.getId();
		level2.Menu__c = menuSaveResult.getId();
		level2.Label__c = 'Daily and 5 day Forecast';
		database.SaveResult level2SR = database.insert(level2);
		Menu_Item__c level3 = new Menu_Item__c(Parent_Item__c=level2SR.getId(), Menu__c=menuSaveResult.getId(), Label__c='Eastern Uganda');
		database.SaveResult level3SR = database.insert(level3);
		Menu_Item__c level4 = new Menu_Item__c(Parent_Item__c=level3SR.getId(), Menu__c=menuSaveResult.getId(), Label__c='Jinja');
		database.SaveResult level4SR=database.insert(level4);
		Menu_Item__c level5 = new Menu_Item__c(Parent_Item__c=level4SR.getId(), Menu__c=menuSaveResult.getId(), Label__c='Budondo');
		level5.Attribution__c = 'Information provided by the ICON Weather Feed Service';
		level5.Content__c = 'Today sunny, tomorrow windy';
		database.SaveResult level5SR = database.insert(level5);

		// Set up Agroways Menu
		Menu__c agroways = new Menu__c();
		agroways.Label__c = 'Agroways';
		database.SaveResult agrowaysMenuSaveResult = database.insert(agroways);
		topLevel = new Menu_Item__c();
		topLevel.Menu__c = agrowaysMenuSaveResult.getId();
		topLevel.Label__c = 'Weather Information';
		database.SaveResult topLevelR = database.insert(topLevel);
		level2 = new Menu_Item__c();
		level2.Parent_Item__c = topLevelR.getId();
		level2.Menu__c = agrowaysMenuSaveResult.getId();
		level2.Label__c = 'Daily and 5 day forecast ';
		database.SaveResult level2R = database.insert(level2);
		level3 = new Menu_Item__c(Parent_Item__c=level2R.getId(), Menu__c=agrowaysMenuSaveResult.getId(), Label__c='Eastern Uganda');
		database.SaveResult level3R=database.insert(level3);
		level4 = new Menu_Item__c(Parent_Item__c=level3R.getId(), Menu__c=agrowaysMenuSaveResult.getId(), Label__c='Jinja');
		database.SaveResult level4R=database.insert(level4);
		level5 = new Menu_Item__c(Parent_Item__c=level4R.getId(), Menu__c=agrowaysMenuSaveResult.getId(), Label__c='Budondo');
		level5.Attribution__c = 'Information provided by the ICON Weather Feed Service';
		database.SaveResult level5R =database.insert(level5);
		test.startTest();
		UpdateAgrowaysWeather.updateWeather();
		Menu_Item__c updatedItem = [Select Content__c from Menu_Item__c where Id=:level5R.getId()];
		System.assertEquals('Today sunny, tomorrow windy', updatedItem.Content__c);
		test.stopTest();
	}
}