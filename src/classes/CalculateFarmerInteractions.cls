/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Calculates SMSs, callcenter calls, search-logs and farmer meetings each focus
 *  farmer was involved in.
 *
 *  Tests are in TestCalculateFarmerInteractions class
 *  
 **/
global class CalculateFarmerInteractions implements Database.Batchable<sObject>, Database.Stateful {

    global final String farmerPersonQuery;
    global Integer day = date.today().day();
    
    global CalculateFarmerInteractions(String query) {
        farmerPersonQuery = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(farmerPersonQuery);
    }

    global void execute(Database.BatchableContext BC, List<Person__c> farmerPersons) {

        // Maps to hold the stats
        Map<String, Integer> personCallStats = new Map<String, Integer>();
        Map<String, Integer> personSmsStats = new Map<String, Integer>();
        Map<String, Integer> personSearchStats = new Map<String, Integer>();
        Map<String, Integer> personGroupMeetStats = new Map<String, Integer>();

        Set<String> personIds = new Set<String>();
        for (Person__c person : farmerPersons) {
            personIds.add(person.Id);
            personCallStats.put(person.Id, 0);
            personSmsStats.put(person.Id, 0);
            personSearchStats.put(person.Id, 0);
            personGroupMeetStats.put(person.Id, 0);
        }
        // Get farmer records, so as to identify each farmer's main crop
        List<Focus_Farmer__c> focusFarmers = [Select Id, Person__c, Farmer_Type__c, District__c from Focus_Farmer__c where Person__c in:personIds];

        // Create a map to link persons to their focus farmer ids
        Map<String, String> personFocusFarmerLink = new Map<String, String>();
        
        Map<String, String> focusFarmerPersonLink = new Map<String, String>();

        List<String> bananaFocusFarmers = new List<String>();
        List<String> coffeeFocusFarmers = new List<String>();
        List<String> maizeFocusFarmers = new List<String>();
        for (Focus_Farmer__c focusFarmer : focusFarmers) {
            personFocusFarmerLink.put(focusFarmer.Person__c, focusFarmer.Id);
            focusFarmerPersonLink.put(focusFarmer.Id, focusFarmer.Person__c);
            if (focusFarmer.Farmer_Type__c.equals('Banana')) {
                bananaFocusFarmers.add(focusFarmer.Id);
            }
            else if(focusFarmer.Farmer_Type__c.equals('Coffee')) {
                coffeeFocusFarmers.add(focusFarmer.Id);
            }
            else if(focusFarmer.Farmer_Type__c.equals('Maize')) {
                maizeFocusFarmers.add(focusFarmer.Id);
            }
        }

        // Create a map of Focus Farmer and the Contact who registered the farmer
        Map<String, String> focusFarmerContact = new Map<String, String>();
        List<Banana_Farmer__c> bananaFarmers = [Select Focus_Farmer__c, Registered_By__c from Banana_Farmer__c where Focus_Farmer__c in:bananaFocusFarmers];
        List<Coffee_Farmer__c> coffeeFarmers = [Select Focus_Farmer__c, Registered_By__c from Coffee_Farmer__c where Focus_Farmer__c in:coffeeFocusFarmers];
        List<Maize_Farmer__c> maizeFarmers = [Select Focus_Farmer__c, Registered_By__c from Maize_Farmer__c where Focus_Farmer__c in:maizeFocusFarmers];
        for (Banana_Farmer__c bananaFarmer : bananaFarmers) {
            focusFarmerContact.put(bananaFarmer.Focus_Farmer__c, bananaFarmer.Registered_By__c);
        }
        for (Coffee_Farmer__c coffeeFarmer : coffeeFarmers) {
            focusFarmerContact.put(coffeeFarmer.Focus_Farmer__c, coffeeFarmer.Registered_By__c);
        }
        for (Maize_Farmer__c maizeFarmer : maizeFarmers) {
            focusFarmerContact.put(maizeFarmer.Focus_Farmer__c, maizeFarmer.Registered_By__c);
        }

        // Get call centre stats
        AggregateResult[] callCentre = day == 1 ? 
            [Select Person__c, count(id) calls from Case where Person__c in:personIds and CreatedDate = LAST_MONTH and Origin = 'Phone Call' group by Person__c] :
            [Select Person__c, count(id) calls from Case where Person__c in:personIds and CreatedDate = THIS_MONTH and Origin = 'Phone Call' group by Person__c];
        for (AggregateResult ar : callCentre) {
            String personId = (String)ar.get('Person__c');
            Integer calls = (Integer)ar.get('calls');
            personCallStats.put(personId, calls);
        }

        // Get SMS stats
        AggregateResult[] smsStats = day == 1 ? 
            [Select Recipient__c, count(id) sms from Message__c where Recipient__c in:personIds and Sent_Time__c = LAST_MONTH and Type__c = 'SMS' group by Recipient__c]:
            [Select Recipient__c, count(id) sms from Message__c where Recipient__c in:personIds and Sent_Time__c = THIS_MONTH and Type__c = 'SMS' group by Recipient__c];
        for (AggregateResult smsStat : smsStats) {
            String personId = (String)smsStat.get('Recipient__c');
            Integer sms = (Integer)smsStat.get('sms');
            personSmsStats.put(personId, sms);     
        }

        // Get Search Log stats
        AggregateResult[] searchStats = day == 1 ?
            [Select Interviewee__c, count(id) searches from Search_Log__c where Interviewee__c in:personIds and Submission_GPS_Timestamp__c = LAST_MONTH group by Interviewee__c]:
            [Select Interviewee__c, count(id) searches from Search_Log__c where Interviewee__c in:personIds and Submission_GPS_Timestamp__c = THIS_MONTH group by Interviewee__c];
        for (AggregateResult smsStat : searchStats) {
            String personId = (String)smsStat.get('Interviewee__c');
            Integer search = (Integer)smsStat.get('searches');
            personSearchStats.put(personId, search);     
        }

        // grouping by Banana_Farmer__r.Focus_Farmer__r.Person__c is not possible
        for(Person__c farmerPerson : farmerPersons) {
            String query = day == 1 ? 
                'SELECT Count() FROM Banana_Cluster_Meeting__c WHERE Meeting_Date__c = LAST_MONTH AND Banana_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ':
                'SELECT Count() FROM Banana_Cluster_Meeting__c WHERE Meeting_Date__c = THIS_MONTH AND Banana_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ';
            Integer meetings = Database.countQuery(query);
            personGroupMeetStats.put(farmerPerson.Id, meetings); 
        }        

        for(Person__c farmerPerson : farmerPersons) {
            String query = day == 1 ? 
                'SELECT Count() FROM Coffee_Cluster_Meeting__c WHERE Please_add_the_date_of_the_meeting__c = LAST_MONTH AND Coffee_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ':
                'SELECT Count() FROM Coffee_Cluster_Meeting__c WHERE Please_add_the_date_of_the_meeting__c = THIS_MONTH AND Coffee_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ';
            Integer meetings = Database.countQuery(query);
            personGroupMeetStats.put(farmerPerson.Id, meetings + personGroupMeetStats.get(farmerPerson.Id)); 
        }

        for(Person__c farmerPerson : farmerPersons) {
            String query = day == 1 ? 
                'SELECT Count() FROM Maize_Cluster_Meeting__c WHERE Meeting_Date__c = LAST_MONTH AND Maize_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ':
                'SELECT Count() FROM Maize_Cluster_Meeting__c WHERE Meeting_Date__c = THIS_MONTH AND Maize_Farmer__r.Focus_Farmer__r.Person__c = \'' + farmerPerson.Id + '\' ';
            Integer meetings = Database.countQuery(query);
            personGroupMeetStats.put(farmerPerson.Id, meetings + personGroupMeetStats.get(farmerPerson.Id)); 
        }
        
        List<C3P0_Farmer_Interaction__c> farmerInteractions = day == 1 ? [
            Select Id, 
                Contact__c,
                Focus_Farmer__c,
                Focus_Farmer__r.Person__c,
                Number_of_Calls_to_Call_Centre__c, 
                Number_of_Group_Meetings_Attended__c,
                Number_of_Searches__c,
                Number_of_SMS__c,
                Month__c
            FROM
                C3P0_Farmer_Interaction__c
            WHERE
                Month__c = LAST_MONTH
            AND
                Focus_Farmer__c in:personFocusFarmerLink.values()]:[
            Select Id, 
                Contact__c,
                Focus_Farmer__c,
                Focus_Farmer__r.Person__c,
                Number_of_Calls_to_Call_Centre__c, 
                Number_of_Group_Meetings_Attended__c,
                Number_of_Searches__c,
                Number_of_SMS__c,
                Month__c
            FROM
                C3P0_Farmer_Interaction__c
            WHERE
                Month__c = THIS_MONTH
            AND
                Focus_Farmer__c in:personFocusFarmerLink.values()];
        
        Map<String, C3P0_Farmer_Interaction__c> personInteractions = new Map<String, C3P0_Farmer_Interaction__c>();
        for (C3P0_Farmer_Interaction__c personInteraction : farmerInteractions) {
            personInteractions.put(personInteraction.Focus_Farmer__c, personInteraction);
        }
        
        //some interaction records may not exist, create em
        for(String fFarmer : personFocusFarmerLink.values()) {
            C3P0_Farmer_Interaction__c interxn = personInteractions.get(fFarmer);
            if(interxn == null) {
                C3P0_Farmer_Interaction__c interaction = new C3P0_Farmer_Interaction__c();
                String personId = focusFarmerPersonLink.get(fFarmer);
                interaction.Focus_Farmer__c = fFarmer;
                interaction.Month__c =  day == 1 ? date.today().toStartOfMonth().addMonths(-1): date.today().toStartOfMonth();
                interaction.Number_of_Calls_to_Call_Centre__c = personCallStats.get(personId);
                interaction.Number_of_Group_Meetings_Attended__c = personGroupMeetStats.get(personId);
                interaction.Number_of_Searches__c = personSearchStats.get(personId);
                interaction.Number_of_SMS__c = personSmsStats.get(personId);
                interaction.Contact__c = focusFarmerContact.get(fFarmer);
                farmerInteractions.add(interaction);
                personInteractions.put(interaction.Focus_Farmer__c, interaction);           
            }
        }

        // iterate thru the map
        for (String focusFarmerId : personInteractions.keyset()) {
            String personId = focusFarmerPersonLink.get(focusFarmerId);
            C3P0_Farmer_Interaction__c interaction = personInteractions.get(focusFarmerId);

            interaction = interaction == null ? new C3P0_Farmer_Interaction__c() : interaction;
            Date dateOf = day == 1 ? date.today().toStartOfMonth().addMonths(-1): date.today().toStartOfMonth();
            interaction.Month__c = interaction == null ? dateOf : interaction.Month__c;
            interaction.Contact__c = interaction == null ? focusFarmerContact.get(focusFarmerId) : interaction.Contact__c;
            //interaction.Focus_Farmer__c = interaction == null ? focusFarmerId : interaction.Focus_Farmer__c;
            //above commented line is seen as reparenting
            if(interaction == null) {
                interaction.Focus_Farmer__c = focusFarmerId;
            }

            interaction.Number_of_Calls_to_Call_Centre__c = personCallStats.get(personId) == null ? 0 : personCallStats.get(personId);
            interaction.Number_of_Group_Meetings_Attended__c = personGroupMeetStats.get(personId) == null ? 0 : personGroupMeetStats.get(personId);
            interaction.Number_of_Searches__c = personSearchStats.get(personId) == null ? 0 : personSearchStats.get(personId);
            interaction.Number_of_SMS__c = personSmsStats.get(personId);
            personInteractions.put(focusFarmerId, interaction);
        }
        upsert personInteractions.values();
    }

    global void finish(Database.BatchableContext BC) {

    }
}