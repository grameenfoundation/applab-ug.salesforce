<<<<<<< HEAD
trigger AddMtnChannelsTarget on Person__c (after insert, after update) {

    List<String> regionIds = new List<String>();
    Integer counter = 0;
    List<Person__c> staffMembers = new List<Person__c>();
    for (Person__c person : trigger.new) {

        // Only interested in people who have had their region changed and who are MTN Channels staff
        if ((trigger.isInsert ||
                (trigger.isUpdate && 
                    trigger.new[counter].Region__c != trigger.old[counter].Region__c)
                ) &&
                trigger.new[counter].Type__c != null &&
                trigger.new[counter].Type__c.equals('MTN Channel Staff')) {
            regionIds.add(person.Region__c);
            staffMembers.add(person);
        }
        counter++;
    }

    if (regionIds.size() > 0) {

        // Loop through the regions and get the most recent target. This will break on a large mass update
        // However we should not be doing large mass update
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        for (String regionId : regionIds) {
            MTN_Channels_Target__c[] regionalTargets = [
                SELECT
                    Outlet_Visits__c
                FROM
                    MTN_Channels_Target__c
                WHERE
                    Region__c = :regionId
                    AND Person__c = null
                ORDER BY
                    Start_Date__c DESC];
            if (regionalTargets.size() == 0) {
                targetMap.put(regionId, 0.0);
            }
            else {
                targetMap.put(regionId, regionalTargets[0].Outlet_Visits__c);
            }
        }

        // Create the targets
        List<MTN_Channels_Target__c> targets = new List<MTN_Channels_Target__c>();
        for (Person__c person : staffMembers) {
            MTN_Channels_Target__c target = new MTN_Channels_Target__c();
            target.Start_Date__c = Date.today();
            target.Outlet_Visits__c = targetMap.get(person.Region__c);
            target.Person__c = person.Id;
            targets.add(target);
        }
        Database.insert(targets);
    }
=======
trigger AddMtnChannelsTarget on Person__c (after insert, after update) {

    List<String> regionIds = new List<String>();
    Integer counter = 0;
    List<Person__c> staffMembers = new List<Person__c>();
    for (Person__c person : trigger.new) {

        // Only interested in people who have had their region changed and who are MTN Channels staff
        if ((trigger.isInsert ||
                (trigger.isUpdate && 
                    trigger.new[counter].Region__c != trigger.old[counter].Region__c)
                ) &&
                trigger.new[counter].Type__c != null &&
                trigger.new[counter].Type__c.equals('MTN Channel Staff')) {
            regionIds.add(person.Region__c);
            staffMembers.add(person);
        }
        counter++;
    }

    if (regionIds.size() > 0) {

        // Loop through the regions and get the most recent target. This will break on a large mass update
        // However we should not be doing large mass update
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        for (String regionId : regionIds) {
            MTN_Channels_Target__c[] regionalTargets = [
                SELECT
                    Outlet_Visits__c
                FROM
                    MTN_Channels_Target__c
                WHERE
                    Region__c = :regionId
                    AND Person__c = null
                ORDER BY
                    Start_Date__c DESC];
            if (regionalTargets.size() == 0) {
                targetMap.put(regionId, 0.0);
            }
            else {
                targetMap.put(regionId, regionalTargets[0].Outlet_Visits__c);
            }
        }

        // Create the targets
        List<MTN_Channels_Target__c> targets = new List<MTN_Channels_Target__c>();
        for (Person__c person : staffMembers) {
            MTN_Channels_Target__c target = new MTN_Channels_Target__c();
            target.Start_Date__c = Date.today();
            target.Outlet_Visits__c = targetMap.get(person.Region__c);
            target.Person__c = person.Id;
            targets.add(target);
        }
        Database.insert(targets);
    }
>>>>>>> origin/ci
}