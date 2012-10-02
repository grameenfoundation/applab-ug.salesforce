trigger UpdateCurrentPovertyScorecard on Poverty_Scorecard__c (after insert) {

    if (Trigger.new.size() >= 1) {

        // Using a map so that if there is a batch containing the same person twice. The most recent
        // scorecard in that batch is used.
        Map<String, Person__c> persons = new Map<String, Person__c>();

        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Poverty_Scorecard__c povertyScorecard =  Trigger.new[i];

            // Get the person that this scorecard is for.
            Person__c person = [SELECT Id, Name, Current_Poverty_Scorecard__c FROM Person__c WHERE Id = :povertyScorecard.Person__c];
            person.Current_Poverty_Scorecard__c = povertyScorecard.Id;
            persons.put(person.Id, person);
        }

        // Update the persons.
        database.update(persons.values());
    }

}