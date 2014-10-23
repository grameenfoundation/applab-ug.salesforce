/**
 * This trigger listens in o the after update event of the Contact object to 
 * propagated it's ownership to the Person__c associated object.
 *
 * @author Charles Tumwebaze
 */
trigger CkwUniversalContactOwnershipPropagationTrigger on Contact (after update) {
	CkwUniversalOwnershipPropagationHandler handler = new CkwUniversalOwnershipPropagationHandler();
	
	for (Contact contact : Trigger.new) {
		handler.propagateFromContactToPerson(contact);
	}
}