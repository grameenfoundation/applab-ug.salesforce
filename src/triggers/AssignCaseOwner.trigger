trigger AssignCaseOwner on Case (before insert) {
    for (Case newCase : Trigger.New) {
        if (newCase.Origin == 'CKW Pulse' && null != newCase.Person__c) {
           Person__c person = [
               SELECT 
                     OwnerId
               FROM 
                    Person__c
               WHERE
                    Id = :newCase.Person__c
               LIMIT 1];
           newCase.OwnerId = person.OwnerId;
        }
    }
}