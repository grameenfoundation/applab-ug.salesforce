public class ERD_DescribeSObjects {
	
	public static final Integer DESCRIBE_CALL_LIMIT = 5;	
	
    /*
	 * Description:  Returns a Map of ClassNames -- > Field Schema mappings begining with the provided cursor and ending
	 * when the max describe call limit is hit or their are no more classes left to describe
	 */
    public static Map<String, Map<String, Schema.SObjectField>> getAll(Integer cursor) {
        
        Map<String, Schema.SObjectType> globalDescribe= Schema.getGlobalDescribe(); 
        Schema.DescribeSObjectResult describeResult;   
        List<Schema.ChildRelationship> childRelationship;     
        Set<String> fieldKeys = new Set<String>();
        Set<String> keys = globalDescribe.keySet();
        Integer counter = 0;
        Map<String, Map<String, Schema.SObjectField>> fieldNamesByClassName = new Map<String, Map<String, Schema.SObjectField>>();
        
        //for each class in the schema        
        for(String key : keys) {
            //only describe custom objects
            if(key.contains('__c') ) { 
                Map<String, Schema.SObjectField> sObjectField;
                Integer size = 0;
                describeResult = globalDescribe.get(key).getDescribe();
                //proceed if the max describe limit has not been reached
                if(counter >= cursor && counter < (cursor + DESCRIBE_CALL_LIMIT)) {
                    sObjectField = describeResult.fields.getMap(); 
                    fieldNamesByClassName.put(describeResult.getName(), sObjectField);                                                                    
                }                
                if(sObjectField != null) {
                    size = sObjectField.keySet().size();
                }
                counter++;
            }
        }
        return fieldNamesByClassName;              
    }
    
    testMethod static void testGetAll() {
       Map<String, Schema.SObjectType> control = Schema.getGlobalDescribe();        
       Map<String, Map<String, Schema.SObjectField>> test = ERD_DescribeSObjects.getAll(0);
        
        Set<String> cKeys = control.keySet();
        Set<String> tKeys = test.keySet();
        
        if(cKeys.size() > DESCRIBE_CALL_LIMIT) {
       // 	System.assertEquals(DESCRIBE_CALL_LIMIT, tKeys.size());	
        } else {
       // 	System.assertEquals(cKeys.size(), tKeys.size());
        }
    } 
}