/**
 * This class handles the propagation of ownership from Person__c to Contact or from
 * Contact to Person__c records according to their associations.
 */
public with sharing class CkwUniversalOwnershipPropagationHandler {

	/**
	 * propagates the ownership of the given contact to the person 
	 * records that are associated with it.
	 *
	 * @param contact the contact from which the ownership is to be propagaged.
	 */
	public void propagateFromContactToPerson(Contact contact){
		List<Person__c> persons = [
			SELECT 
				Id, 
				OwnerId, 
				Contact__r.Id 
			FROM 
				Person__c 
			WHERE 
				Contact__r.Id = :contact.Id AND OwnerId != :contact.ownerId];
				
		for (Person__c person : persons) {
			person.OwnerId = contact.OwnerId;	
		}
		
		update persons;
	}
	
	/**
	 * propagates the ownership of the given person to the contact record
	 * that is associated with it.
	 *
	 * @param person the perosn from which the ownership is to be propagaged.
	 */
	public void propagateFromPersonToContact(Person__c person){
		List<Contact> contacts = [
			SELECT
				Id,
				OwnerId
			FROM 
				Contact
			WHERE
				Id = :person.Contact__c AND ownerId != :person.ownerId
		];
		
		if (contacts != null) {
			for(Contact contact : contacts){
				contact.OwnerId = person.OwnerId;
			}
			
			update contacts;
		}
	}
	
	/**
	 * propagates the ownership of the given group record to the gfsurveys__ContactGroup__c
	 * records associated with it.
	 *
	 * @param groupc the group from which the ownership is to be propagated.
	 */
	public void propagateFromCkwGroupToGfSurveyGroup(Group__c groupc) {
		List<gfsurveys__ContactGroup__c> groups = [
			SELECT
				Id,
				Name,
				OwnerId
			FROM
				gfsurveys__ContactGroup__c
			WHERE 
				Name = :groupc.Name AND ownerId != :groupc.OwnerId
		];
		
		if (groups != null) {
			for (gfsurveys__ContactGroup__c g : groups) {
				g.OwnerId = groupc.OwnerId;
			}
			
			update groups;
		}
	}
}