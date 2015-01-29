global class contactsBatchJob implements Database.Batchable<sObject>{
  global Database.QueryLocator start(Database.BatchableContext bc) {
      String contactID = '0017000000xVK8c';
      String query = 'Select Department from Contact where AccountId = :contactID and CreatedDate > 2014-07-30T01:15:00-00:00 and Department != null';
      return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext bc, List<Contact> departments) {
    for (Contact Department: departments) {
        contactProcessHandler handler = new contactProcessHandler(Department);
        handler.handle();
    }
    update departments;
  }
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }
}