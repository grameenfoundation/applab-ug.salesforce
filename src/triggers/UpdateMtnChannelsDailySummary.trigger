trigger UpdateMtnChannelsDailySummary on MTN_Channels_Activity__c (after delete, after insert, after undelete, 
after update) {

    // Most common useage so just do a simple update
    if (trigger.isInsert && trigger.new.size() == 1) {
        MtnChannelsHelpers.addToSingleSummary(trigger.new[0]);
        return;
    }
    if ((trigger.isUnDelete || trigger.isUpdate) && trigger.new.size() == 1) {
        MtnChannelsHelpers.updateSingleSummary(trigger.new[0], trigger.old[0]);
    }
    if (trigger.isDelete && trigger.old.size() == 1) {
        MtnChannelsHelpers.removeSingleSummary(trigger.old[0]);
        return;
    }

    // Dig out all the people who have had records changed and get the date range of changes
    Date startDate = Date.today();
    Date endDate = Date.today();
    Set<String> peopleIds = new Set<String>();
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        peopleIds.add(Trigger.new[i].Person__c);
        if (startDate.daysBetween(Trigger.new[i].Start_Time__c.Date()) < 0) {
            startDate = Trigger.new[i].Start_Time__c.Date();
        }
        if (endDate.daysBetween(Trigger.new[i].Start_Time__c.Date()) > 0) {
            endDate = Trigger.new[i].Start_Time__c.Date();
        }
    }
    for (Integer i = 0; i < Trigger.old.size(); i++) {
        peopleIds.add(Trigger.old[i].Person__c);
        if (startDate.daysBetween(Trigger.old[i].Start_Time__c.Date()) < 0) {
            startDate = Trigger.old[i].Start_Time__c.Date();
        }
        if (endDate.daysBetween(Trigger.old[i].Start_Time__c.Date()) > 0) {
            endDate = Trigger.old[i].Start_Time__c.Date();
        }
    }

    MtnChannelsHelpers.updateDailySummaries(peopleIds, startDate, endDate);
}