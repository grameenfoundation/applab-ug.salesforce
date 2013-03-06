/**
 * This trigger listens in on the after update event of the Person__c object to 
 * propagate it's ownership to the Contact associated object.
 *
 * @author Charles Tumwebaze
 */
trigger CkwUniversalPersonOwnershipPropagationTrigger on Person__c (after update) {
	CkwUniversalOwnershipPropagationHandler handler = new CkwUniversalOwnershipPropagationHandler();
	
	for (Person__c person : Trigger.new) {
		handler.propagateFromPersonToContact(person);
	}
}