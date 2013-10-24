trigger UpdatePhoneState on Person__c (before insert, before update) {

    Person__c person = trigger.new[0];
    if (trigger.IsInsert || (trigger.old[0].Handset__c != trigger.new[0].Handset__c)) {
        PhoneStateUpdater.updatePhoneStateToAssigned(person);
    }

    if ((trigger.isUpdate) && (Trigger.old.size() == 1)) {
        Person__c personOld = trigger.old[0];
        Person__c personNew = trigger.new[0];
        if (personOld.Handset__c != null && personOld.Handset__c != personNew.Handset__c) {
            Phone__c phoneOld =
                [SELECT
                    Id,
                    Name,
                    IMEI__c,
                    State__c
                FROM 
                    Phone__c
                WHERE
                    Id = :personOld.Handset__c];
            phoneOld.State__c = 'Unassigned';

            Note phoneNote = new Note();
            phoneNote.Body = 'State change from Assigned to Unassigned.' +
              '\n' + 'Previous owner ' + personOld.First_Name__c + '\t' +
                personOld.Last_Name__c + '\t' + '(' + personOld.Name + ')' +
                 '\n' + ' User: ' + UserInfo.getUserName();
            phoneNote.Title = 'State Changed.';         
            phoneNote.ParentId = phoneOld.Id;

            insert phoneNote;
            database.update(phoneOld);
        }

    }
}