/**
 * This class contains methods that respond to the GfSurveyContactGroupMemberTrigger events.
 * I.e. after insert and after delete
 *
 * Primarily the methods in this class cascade changes from the gfsurveys__ContactGroupMember__c records
 * to the Person_Group_Association__c records. For cases where new gfsurveys__ContactGroupMember__c are 
 * created, new Person_Group_Association__c records will be created as well. 
 * For cases whether gfsurveys__ContactGroupMember__c are deleted, their corresponding 
 * Person_Group_Association__c will be created.
 *
 * @author Charles Tumwebaze
 */
public with sharing class GfSurveyContactGroupMemberTriggerHandler {

	/**
	 * handles the after delete event on the gfsurveys__ContactGroupMember__c object as called 
	 * by the GfSurveyContactGroupMemberTrigger.
	 * This method is called when gfsurveys__ContactGroupMember__c records have been inserted 
	 * into the datastore.
	 *
	 * @param objects an array of gfsurveys__ContactGroupMember__c records that have been deleted from the datastore. 
	 * And for which the corresponding Person_Group_Association__c records will be deleted.
	 */
	public void onAfterDelete(gfsurveys__ContactGroupMember__c[] objects){
		removeDeletedCkwPersonGroupAssocations(objects);
	}
	
	/**
	 * handles the after insert event on the gfsurveys__ContactGroupMember__c object as called 
	 * by the GfSurveyContactGroupMemberTrigger.
	 * This method is called when gfsurveys__ContactGroupMember__c record have been inserted into the 
	 * datastore.
	 *
	 * @param objects an array of gfsurveys__ContactGroupMember__c records that 
	 * have been added to the datastore and for which the corresponding Person_Group_Association__c 
	 * records will be created.
	 */
	public void onAfterInsert(gfsurveys__ContactGroupMember__c[] objects){
		createCkwPersonGroupAssocations(objects);
	}
	
	/**
     * create Person_Group_Association__c records for the corresponding gfsurveys__ContactGroupMember__c records 
     * in the given array.
     *
     * @param objects an array of gfsurveys__ContactGroupMember__c records from which the corresponding 
     * Person_Group_Association__c records are created. 
     */
    private void createCkwPersonGroupAssocations(gfsurveys__ContactGroupMember__c[] objects) {
    	//get a list of group identifiers
    	List<String> groupIds = new List<String>();
        for(gfsurveys__ContactGroupMember__c m : objects){
           groupIds.add(m.gfsurveys__ContactGroup__c);
        }
        
        Map<Id, gfsurveys__ContactGroup__c> groups = 
        	new Map<Id, gfsurveys__ContactGroup__c>([SELECT Id, Name FROM gfsurveys__ContactGroup__c WHERE Id IN : groupIds]);
        
        //creates a list of group names
        List<String> groupNames = new List<String>();
        Set<Id> ids = groups.keySet();
    	for (Id identifier : ids) {
        	groupNames.add(groups.get(identifier).Name);
        }
        
        List<Group__c> ckwGroups = [SELECT Id, Name FROM Group__c WHERE Name IN :groupNames];
    	List<Person_Group_Association__c> groupAssociations = new List<Person_Group_Association__c>();
    	
		//generate a list of contact identifiers from the membership records.
		List<String> contactIds = new List<String>();
		for (gfsurveys__ContactGroupMember__c member : objects) {
			contactIds.add(member.gfsurveys__Contact__c);
		}
		
		//get list of people that are associated with contacts in the membership records.
		List<Person__c> people = [
			SELECT 
				Id, 
				Contact__c
			FROM 
				Person__c 
			WHERE 
				Contact__c IN :contactIds
		];
		
		for (gfsurveys__ContactGroupMember__c member : objects) {
			//retrieve person
			Person__c person = null;
			for (Person__c p : people) {
				if(p.Contact__c == member.gfsurveys__Contact__c){
					person = p;
					break;
				}
			}
			
			//retrieve Group__c record
			Group__c ckwGroup = null;
			for (Group__c g : ckwGroups) {
				if (g.Name == groups.get(member.gfsurveys__ContactGroup__c).Name) {
					ckwGroup = g;
					break;
				}
			}
			
			if (person != null && ckwGroup != null){
				//determine if a person group assocation already exists
				Person_Group_Association__c pGroup = new Person_Group_Association__c();
    			pGroup.Group__c = ckwGroup.Id;
    			pGroup.Person__c = person.Id;
    			
    			groupAssociations.add(pGroup);
			}
		}
		
		insert groupAssociations;
    }
	
	/**
     * removes Person_Group_Association__c records for the corresponding  gfsurveys__ContactGroupMember__c records.
     *
     * @param objects an array of gfsurveys__ContactGroup__c records for which the corresponding
     * Person_Group_Association__c records will be deleted. 
     */
    private void removeDeletedCkwPersonGroupAssocations(gfsurveys__ContactGroupMember__c[] objects){
    	
    	//get a list of group identifiers
    	List<String> groupIds = new List<String>();
        for(gfsurveys__ContactGroupMember__c m : objects){
           groupIds.add(m.gfsurveys__ContactGroup__c);
        }
        
        List<gfsurveys__ContactGroup__c> groups = [SELECT Id, Name FROM gfsurveys__ContactGroup__c WHERE Id IN : groupIds];
        
        //creates a list of group names
        List<String> groupNames = new List<String>();
    	for (gfsurveys__ContactGroup__c g : groups) {
        	groupNames.add(g.Name);
        }
        
        //generate a list of contact identifiers from the membership records.
		List<String> contactIds = new List<String>();
		for (gfsurveys__ContactGroupMember__c member : objects) {
			contactIds.add(member.gfsurveys__Contact__c);
		}
        
        /*
         * retrieve person group assocations whose group names are in 
         * lists of group names defined above and the person references a contact
         * in the list defined about of contact identifiers.
         */
        List<Person_Group_Association__c> associations = [
	    		SELECT 
	    			Id,
	    			Group__c,
	    			Person__c,
	    			Person__r.Contact__c,
	    			Group__r.Name
	    		FROM 
	    			Person_Group_Association__c 
				WHERE 
					(Group__r.Name IN :groupNames 
					AND 
						Person__r.Contact__c IN :contactIds)
		];
						
		delete associations;
    }
}