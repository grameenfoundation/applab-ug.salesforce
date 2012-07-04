public with sharing class PhoneStateUpdater {
    
    /*
        Method to ensure that the state of the Phone object is updated
        to Assigned. This method is fired off a trigger when a Person
        record is edited and its Handset record is changed.
        
        @param person - The Person object.
    */
    public static void updatePhoneStateToAssigned(Person__c person) {
        
        if (person.Handset__c != null) {
            
            Phone__c phone = [SELECT
                                   Id,
                                   Name, 
                                   IMEI__c, 
                                   State__c 
                              FROM 
                                   Phone__c 
                              WHERE 
                                   Id = :person.Handset__c];
            
            Person__c[] currentOwner = [SELECT 
                                              Id, 
                                              First_Name__c, 
                                              Gender__c, 
                                              Handset__c 
                                         FROM 
                                              Person__c 
                                         WHERE 
                                              Handset__c = :person.Handset__c
                                         AND 
                                              Id != :person.Id];
            if (currentOwner.size() > 0) {
                 trigger.new[0].addError('Sorry '+ UserInfo.getUserName() + 
                     ', Phone ' + phone.IMEI__c + ' already assigned to ' + 
                         currentOwner[0].First_Name__c);
            }
            String oldPhoneState = phone.State__c;
            phone.State__c = 'Assigned';
            Note phoneNote = new Note();            
            phoneNote.Body = 'State Change from ' + oldPhoneState +
             ' to Assigned. ' + '\n' + 'New Owner:' + person.First_Name__c +
              '\t' + person.Last_Name__c + '\t' + '(' + person.Name + ')' +
               '\n' + ' User: ' + UserInfo.getUserName();
            phoneNote.Title = 'State Changed';
            phoneNote.ParentId = phone.Id;
            insert phoneNote;       
            database.update(phone);
        }
    }
}