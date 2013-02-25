public with sharing class GfSurveyContactGroupTriggerHandler {
	

	public void OnBeforeInsert(gfsurveys__ContactGroup__c[] newObjects){
		
    }

    public void OnAfterInsert(gfsurveys__ContactGroup__c[] newObjects){
    	createOrUpdateCkwGroups(newObjects, new Map<Id, gfsurveys__ContactGroup__c>());
    	createCkwPersonGroupAssocations(newObjects);
    }
    
    public void OnAfterUpdate(gfsurveys__ContactGroup__c[] oldObjects, gfsurveys__ContactGroup__c[] updatedObjects, Map<Id, gfsurveys__ContactGroup__c> oldMap){
    	createOrUpdateCkwGroups(updatedObjects, oldMap);
    	createCkwPersonGroupAssocations(updatedObjects);
    	removeDeletedCkwPersonGroupAssocations(updatedObjects);
    }
    
    public void OnAfterDelete(gfsurveys__ContactGroup__c[] deletedObjects){
        deleteCkwGroups(deletedObjects);
    }
    
    private void deleteCkwGroups(gfsurveys__ContactGroup__c[] objects){
    	List<Group__c> ckwGroupsForDelete = new List<Group__c>();
            for(gfsurveys__ContactGroup__c g : objects){
                Group__c ckwGroup = null;
                try{
                    ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:g.Name];
                }catch(Exception ex){}
                
                if(ckwGroup != null){
                    ckwGroupsForDelete.add(ckwGroup);
                }
            }
            
            delete ckwGroupsForDelete;
    }
    
    private void removeDeletedCkwPersonGroupAssocations(gfsurveys__ContactGroup__c[] objects){
    	List<Person_Group_Association__c> groupAssociations = new List<Person_Group_Association__c>();
        for(gfsurveys__ContactGroup__c g : objects){
            Group__c ckwGroup = null;
            try{
                ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:g.Name];
            }catch(Exception ex){ 
            }
            
            if(ckwGroup != null){
				for(gfsurveys__ContactGroupMember__c[] members: 
					[SELECT gfsurveys__Contact__c, gfsurveys__Contact__r.Id, gfsurveys__ContactGroup__c,gfsurveys__ContactGroup__r.Id,gfsurveys__ContactGroup__r.Name 
						FROM gfsurveys__ContactGroupMember__c WHERE (gfsurveys__ContactGroup__r.Name=:g.Name AND isDeleted=true) ALL ROWS] ){
					
					for(gfsurveys__ContactGroupMember__c member : members){
						Person__c person = null;
		        		try{
		        			person = [SELECT Id, Contact__r.Id FROM Person__c WHERE Contact__r.Id =:member.gfsurveys__Contact__r.Id LIMIT 1];
		        		}catch(Exception ex){
		        			System.debug(ex.getMessage());
		        		}
		        			        		
		        		if(person != null){
			        		Person_Group_Association__c pGroup = null;
			        		
			        		try{
			        			pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
			        				WHERE (Group__r.Name=:ckwGroup.Name AND Person__r.Id=:person.Id)];
			        		}catch(Exception ex){
			        			System.debug(ex.getMessage());
			        		}
			        		
			        		if(pGroup != null){
			        			groupAssociations.add(pGroup);
			        		}
		        		}
					}
				}
            }
         }
         
        delete groupAssociations;
    }
    
    private void createCkwPersonGroupAssocations(gfsurveys__ContactGroup__c[] objects){
    	List<Person_Group_Association__c> groupAssociations = new List<Person_Group_Association__c>();
        for(gfsurveys__ContactGroup__c g : objects){
            Group__c ckwGroup = null;
            try{
                ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:g.Name];
            }catch(Exception ex){   
            }
            
            if(ckwGroup != null){
				for(gfsurveys__ContactGroupMember__c[] members: 
					[SELECT gfsurveys__Contact__c, gfsurveys__Contact__r.Id, gfsurveys__ContactGroup__c,gfsurveys__ContactGroup__r.Id,gfsurveys__ContactGroup__r.Name FROM gfsurveys__ContactGroupMember__c WHERE gfsurveys__ContactGroup__r.Name=:g.Name] ){
					
					for(gfsurveys__ContactGroupMember__c member : members){
						Person__c person = null;
		        		try{
		        			person = [SELECT Id, Contact__r.Id FROM Person__c WHERE Contact__r.Id =:member.gfsurveys__Contact__r.Id LIMIT 1];
		        		}catch(Exception ex){
		        			System.debug(ex.getMessage());
		        		}
		        			        		
		        		if(person != null){
			        		Person_Group_Association__c pGroup = null;
			        		
			        		try{
			        			pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
			        				WHERE (Group__r.Name=:ckwGroup.Name AND Person__r.Id=:person.Id)];
			        		}catch(Exception ex){
			        			System.debug(ex.getMessage());
			        		}
			        		
			        		if(pGroup == null){
			        			pGroup = new Person_Group_Association__c();
			        			pGroup.Group__c = ckwGroup.Id;
			        			pGroup.Person__c = person.Id;
			        			
			        			groupAssociations.add(pGroup);
			        		}
		        		}
					}
				}
            }
         }
        insert groupAssociations;
    }
    
    private void createOrUpdateCkwGroups(gfsurveys__ContactGroup__c[] objects, Map<Id, gfsurveys__ContactGroup__c> oldMap){
    	List<Group__c> ckwGroupsForInsert = new List<Group__c>();
        List<Group__c> ckwGroupsForUpdate = new List<Group__c>();
        for(gfsurveys__ContactGroup__c g : objects){
            Group__c ckwGroup = null;
            try{
            	gfsurveys__ContactGroup__c oldGroup = oldMap.get(g.Id);
            	if(oldGroup != null){
                	ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:oldGroup.Name];
            	}else{
                	ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:g.Name];
            	}
            }catch(Exception ex){
            	system.debug(ex.getMessage());   
            }
            if(ckwGroup == null){
                ckwGroup = new Group__c();
                ckwGroupsForInsert.add(ckwGroup);
            }else{
                ckwGroupsForUpdate.add(ckwGroup);                    
            }
            ckwGroup.Name = g.Name;
            if(g.gfsurveys__Status__c == 'Active'){
                ckwGroup.Active__c = true;   
            }else{
                ckwGroup.Active__c = false;   
            }
        }
        
        insert ckwGroupsForInsert;
        update ckwGroupsForUpdate;
    }
    
    @IsTest
    static void testGroupNameUpdate(){
    	RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		Group__c ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup != null);
    		
    		gfGroup.Name='Testing2';
    		update gfGroup;
    		
    		Group__c ckwGroup2 = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup2 != null);
			system.assertEquals(ckwGroup.Id, ckwGroup2.Id);	
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}    	
    }
    
    @IsTest
    static void testGroupDeletion(){
    	RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		
    		system.assert(pGroup != null);

			delete gfGroup;
			
			Group__c ckwGroup = null;
			try{
				ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
			}catch(Exception ex){}
			
    		system.assert(ckwGroup == null);
    		
    		Person_Group_Association__c removedGroup = null;
    		try{
	    		removedGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
					WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		}catch(Exception ex){}
    		
    		system.assert(removedGroup == null);
				
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    @IsTest
    static void testGroupMembershipRemoval(){
    	RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		
    		system.assert(pGroup != null);
    		
    		delete member;
    		
    		Person_Group_Association__c removedGroup = null;
    		try{
	    		removedGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
					WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		}catch(Exception ex){}
    		
    		if(removedGroup == null)
    			system.assert(true);
    		else
    			system.assert(false);
				
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    @IsTest
    static void testGroupMemberShipCreation(){
    	RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		
    		system.assert(pGroup != null);
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    @IsTest
    static void testGroupCreation(){
    	RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		Group__c ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup != null);
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
}