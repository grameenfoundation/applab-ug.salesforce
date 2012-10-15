global class ScheduledUpdateKeywords implements Schedulable {

    // Cron expression => Seconds Hours DayOfMonth DayOfWeek OptionalYear
    public static String cronExpression = '0 30 6 * * ?'; // runs at 6:30 everyday
    
    global void execute(SchedulableContext sc) {
    	
    	//Pick all the different menus
    	Menu__c[] menus = 
    		[
    			SELECT
    				Id,
    				Label__c
    			FROM
    				Menu__c
    		];
    		
    	for (Menu__c menu : menus) {
    		UpdateKeywords.saveMenuItemsToStaticResource(menu.Label__c, menu.Label__c.remove(' '));
    	}
    }
}