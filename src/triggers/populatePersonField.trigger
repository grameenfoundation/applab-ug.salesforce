trigger populatePersonField on C3P0_CKW__c (before insert) {
    List<String> contactIds = new List<String>();
    List<C3P0_CKW__c> ckws = trigger.new;
    for (C3P0_CKW__c ckw : ckws) {
        contactIds.add(ckw.Contact__c);
    }
    List<Person__c> persons = [Select Id, Contact__c from Person__c where Contact__c in: contactIds];
    Map<String, String> contactPersonMap = new Map<String, String>();
    for (Person__c person : persons) {
        contactPersonMap.put(person.Contact__c, person.Id);
    }
    for (C3P0_CKW__c ckw : ckws) {
        if (contactPersonMap.containsKey(String.valueOf(ckw.Contact__c))) {
            ckw.Person__c = contactPersonMap.get(String.valueOf(ckw.Contact__c));
        }
    }
    //insert ckws;
}