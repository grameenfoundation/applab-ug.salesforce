trigger UpdateGroupMembership on Group__c (after insert, after update) {

	if (Trigger.new.size()==1) {
		Group__c g = Trigger.new[0];
		if (g.Need_Update__c && g.Membership_Query__c != null) {
			CKWGroups.updateMembership(g.id, g.Membership_Query__c);
			ErrorLog.flush();
		}
	}
}