trigger populateContactLookUp on CKW_Cluster_Meeting__c (before insert) {
    Set<String> contactNames = new Set<String>();
    List<CKW_Cluster_Meeting__c> meetings = trigger.new;
    
    // A map to link each contact above with a list of the meetings he's linked to
    Map<String, List<CKW_Cluster_Meeting__c>> meetingsByContact = new Map<String, List<CKW_Cluster_Meeting__c>>();
    for (CKW_Cluster_Meeting__c meeting : meetings) {
        contactNames.add(meeting.CKW_Full_Name__c);
        List<CKW_Cluster_Meeting__c> contactMeetings = meetingsByContact.get(meeting.CKW_Full_Name__c);
        if (contactMeetings == null) {
            contactMeetings = new List<CKW_Cluster_Meeting__c>();
        }
        contactMeetings.add(meeting);
        meetingsByContact.put(meeting.CKW_Full_Name__c, contactMeetings);
    }
    List<Contact> ckwContacts = [Select Id, Name from Contact where Name in:contactNames];
    Map<String, String> contactNameIdMap = new Map<String, String>();
    if (ckwContacts.size() > 0) {
        for (Contact ckwContact : ckwContacts) {
            contactNameIdMap.put(ckwContact.Name, ckwContact.Id);
        }
        for (CKW_Cluster_Meeting__c meeting : meetings) {
            meeting.CKW__c = contactNameIdMap.get(meeting.CKW_Full_Name__c);
        }
    }
}