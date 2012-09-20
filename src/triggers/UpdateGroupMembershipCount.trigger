trigger UpdateGroupMembershipCount on Person_Group_Association__c (after delete, after insert, after undelete, 
after update) {

    Set<Id> groupsUpdated = new Set<Id>();
    if (Trigger.isDelete) {
        if (Trigger.old.size()>=1) {
            for (Integer i = 0; i < Trigger.old.size(); i++) {
                Person_Group_Association__c groupToUpdate = Trigger.old[i];
                if (!groupsUpdated.contains(groupToUpdate.Group__c)) {
                    groupsUpdated.add(groupToUpdate.Group__c);
                }
            }
        }
    }
    else {
        if (Trigger.new.size() >= 1) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Person_Group_Association__c groupToUpdate = Trigger.new[i];
                if (!groupsUpdated.contains(groupToUpdate.Group__c)) {
                    groupsUpdated.add(groupToUpdate.Group__c);
                }
            }
        }
    }
    List<Id> groupsToUpdate = new List<Id>();
    groupsToUpdate.addAll(groupsUpdated);
    for (Integer i = 0; i < groupsToUpdate.size(); i++) {
        CKWGroups.updateMembershipCount(groupsToUpdate.get(i));
    }
}