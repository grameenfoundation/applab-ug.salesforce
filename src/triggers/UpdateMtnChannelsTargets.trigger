<<<<<<< HEAD
trigger UpdateMtnChannelsTargets on MTN_Channels_Target__c (after insert) {

    // Get all the targets that are being set that are just a region
    List<String> regionIds = new List<String>();
    Map<String, Decimal> targetValues = new Map<String, Decimal>();
    for (MTN_Channels_Target__c target : trigger.new) {
        if (target.Region__c != null && target.Person__c == null) {
            regionIds.add(target.Region__c);
            targetValues.put(target.Region__c, target.Outlet_Visits__c);
        }
    }

    if (regionIds.size() > 0) {

        // Get all the people that are having a target set regionally
        String query = 
            'SELECT ' +
                'Id, ' +
                'Region__c ' +
            'FROM ' +
                'Person__c ' +
            'WHERE ' +
                'Region__c IN (' + MetricHelpers.generateCommaSeperatedString(regionIds, true) + ') ' +
                'AND Type__c = \'MTN Channel Staff\'';
        Person__c[] asrs = Database.query(query);

        // Create a target for these people
        List<MTN_Channels_Target__c> targets = new List<MTN_Channels_Target__c>();
        for (Person__c asr : asrs) {
            MTN_Channels_Target__c target = new MTN_Channels_Target__c();
            target.Person__c = asr.Id;
            target.Outlet_Visits__c = targetValues.get(asr.Region__c);
            target.Start_Date__c = Date.today();
            targets.add(target);
        }

        // Insert the targets. Must make sure that no region is set as that will cause recursive trigger calling
        Database.insert(targets);
    }
=======
trigger UpdateMtnChannelsTargets on MTN_Channels_Target__c (after insert) {

    // Get all the targets that are being set that are just a region
    List<String> regionIds = new List<String>();
    Map<String, Decimal> targetValues = new Map<String, Decimal>();
    for (MTN_Channels_Target__c target : trigger.new) {
        if (target.Region__c != null && target.Person__c == null) {
            regionIds.add(target.Region__c);
            targetValues.put(target.Region__c, target.Outlet_Visits__c);
        }
    }

    if (regionIds.size() > 0) {

        // Get all the people that are having a target set regionally
        String query = 
            'SELECT ' +
                'Id, ' +
                'Region__c ' +
            'FROM ' +
                'Person__c ' +
            'WHERE ' +
                'Region__c IN (' + MetricHelpers.generateCommaSeperatedString(regionIds, true) + ') ' +
                'AND Type__c = \'MTN Channel Staff\'';
        Person__c[] asrs = Database.query(query);

        // Create a target for these people
        List<MTN_Channels_Target__c> targets = new List<MTN_Channels_Target__c>();
        for (Person__c asr : asrs) {
            MTN_Channels_Target__c target = new MTN_Channels_Target__c();
            target.Person__c = asr.Id;
            target.Outlet_Visits__c = targetValues.get(asr.Region__c);
            target.Start_Date__c = Date.today();
            targets.add(target);
        }

        // Insert the targets. Must make sure that no region is set as that will cause recursive trigger calling
        Database.insert(targets);
    }
>>>>>>> origin/ci
}