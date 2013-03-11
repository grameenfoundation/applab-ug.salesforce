/**
 * This class contains methods that respond to the GfSurveyContactGroupTrigger events.
 * I.e after insert, after update etc.
 *
 * Primarily the methods in this class cascade changes from the gfsurveys__ContactGroup__c records to 
 * the Group__c records. E.g When a gfsurveys__ContactGroup__c is created, a corresponding Group__c record 
 * is also created.
 *
 * The cascading is also applicable to the membership (Contact/Person group assocations) records for each of the 
 * classes (gfsurveys__ContactGroup__c and Group__c)
 *
 * @author Charles Tumwebaze
 */
public with sharing class GfSurveyContactGroupTriggerHandler {
	
	/**
	 * handles the after insert event on the gfsurveys__ContactGroup__c object as called by the 
	 * GFSurveyContactGroupTrigger. 
	 * This method is called when  gfsurveys__ContactGroup__c record(s) have been inserted into the datastore.
	 *
	 * @param newObjects an array of gfsurveys__ContactGroup__c records that have been inserted into the datastore.
	 */
    public void OnAfterInsert(gfsurveys__ContactGroup__c[] newObjects) {
    	createOrUpdateCkwGroups(newObjects, new Map<Id, gfsurveys__ContactGroup__c>());
    }
    
    /**
     * handles the after update event on the gfsurveys__ContactGroup__c object as called by the 
     * GFSurveyContactGroupTrigger.
     *
     * This method is called when gfsurveys__ContactGroup__c record(s) have been updated in the datastore.
     *
     * @param updatedObjects an array of gfsurveys__ContactGroup__c records after modifications have been made.
     * @param oldMap a map of Id to gfsurveys__ContactGroup__c records before modifications were made.
     */
    public void OnAfterUpdate(gfsurveys__ContactGroup__c[] updatedObjects, Map<Id, gfsurveys__ContactGroup__c> oldMap) {
    	createOrUpdateCkwGroups(updatedObjects, oldMap);
    }
    
    /**
     * handles the after delete event on the gfsurveys__ContactGroup__c object as called by the 
     * GFSurveyContactGroupTrigger.
     *
     * This method is called after gfsurveys__ContactGroup__c record(s) have been deleted from the datastore.
     *
     * @param objects an array of gfsurveys__ContactGroup__c records that have been deleted from the datastore.
     */
    public void OnAfterDelete(gfsurveys__ContactGroup__c[] deletedObjects) {
        deleteCkwGroups(deletedObjects);
    }
    
    /**
     * Retrieves Group__c records that correspond to the given gfsurveys__ContactGroup__c records.
     *
     * @param objects an array of gfsurveys__ContactGroup__c records for which Group__c records are required.
     *
     * @return list of Group__c records that have the same names as the given gfsurveys__ContactGroup__c records.
     */
    private List<Group__c> getCkwGroupsByGfSurveyGroups(gfsurveys__ContactGroup__c[] objects) {
    	List<String> groupNames = new List<String>();
        for(gfsurveys__ContactGroup__c g : objects){
           groupNames.add(g.Name);
        }
        
        return [SELECT Id, Name, Active__c FROM Group__c WHERE Name IN :groupNames];
    }
    
    /**
     * deletes ckw groups that have the same names as the given gfsurveys__ContactGroup__c 
     * objects. The gfsurveys__ContactGroup__c objects
     *
     * @param objects an array of gfsurveys__ContactGroup__c records whose corresponding Group__c records 
     * are to be deleted.
     */
    private void deleteCkwGroups(gfsurveys__ContactGroup__c[] objects) {
        delete getCkwGroupsByGfSurveyGroups(objects);
    }
    
    /**
     * creates or update Ckw Groups based on the given gfsurveys__ContactGroup__c records. I.e.
     * if a Group__c record does not exist, a new record will be created to correspond with the 
     * gfsurveys__ContactGroup__c record in the given objects parameter. <br/>
     * 
     * @Param oldMap holds the gfsurveys__ContactGroup__c records before they were updated and is useful 
     * during the update operation to get the old name of the gfsurveys__ContactGroup__c before it was 
     * renamed for cases where the name has changed. This is so that the rename of the group can be cascaded 
     * to the corresponding CKW Group (Group__c) record.
     */
    private void createOrUpdateCkwGroups(gfsurveys__ContactGroup__c[] objects, Map<Id, gfsurveys__ContactGroup__c> oldMap) {
    	
    	Set<Id> idz = oldMap.keySet(); 
    	List<String> groupNames = new List<String>();
    	for (Id identifier : idz) {
    		groupNames.add(oldMap.get(identifier).Name);	
    	}
    	
        for (gfsurveys__ContactGroup__c g : objects) {
			gfsurveys__ContactGroup__c oldGp = oldMap.get(g.Id);
			
			//add group name only if it doesn't already exist.
			if (oldGp != null && g.Name != oldGp.Name)
          		groupNames.add(g.Name);
          	else
          		groupNames.add(g.Name);
        }
        
        List<Group__c> ckwGroups = [SELECT Id, Name, Active__c FROM Group__c WHERE Name IN :groupNames];
    	List<Group__c> groups = new List<Group__c>();
    	
    	/*
    	 * we iterate over gfsurveys__ContactGroup__c records and create/update the 
    	 * corresponding Group__c records
    	 */
        for (gfsurveys__ContactGroup__c g : objects) {
            Group__c ckwGroup = null;
        	gfsurveys__ContactGroup__c oldGroup = oldMap.get(g.Id);
        	if (oldGroup != null) {
        		for(Group__c group1 : ckwGroups) {
        			if(group1.Name == oldGroup.Name)
            			ckwGroup = group1;
        		}
        	} else {
            	for (Group__c group1 : ckwGroups) {
        			if(group1.Name == g.Name)
            			ckwGroup = group1;
        		}
        	}
        	
            if (ckwGroup == null) {
                ckwGroup = new Group__c();
            }
            
            groups.add(ckwGroup);                    
            
            ckwGroup.Name = g.Name;
            if (g.gfsurveys__Status__c == 'Active') {
                ckwGroup.Active__c = true;   
            } else {
                ckwGroup.Active__c = false;   
            }
        }
        
        upsert groups;
    }
}