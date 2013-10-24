/**
 * This trigger listens in on the after update event of the Group__c object to 
 * propagate it's ownership to the gfsurveys__ContactGroup__c associated object.
 *
 * @author Charles Tumwebaze
 */
trigger CkwUniversalGroupOwnershipPropagationTrigger on Group__c (after update) {
	CkwUniversalOwnershipPropagationHandler handler = new CkwUniversalOwnershipPropagationHandler();
	
	for (Group__c ckwGroup : Trigger.new) {
		handler.propagateFromCkwGroupToGfSurveyGroup(ckwGroup);
	}
}