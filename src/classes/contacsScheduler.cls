global class contacsScheduler implements Schedulable { 
   global void execute(SchedulableContext SC) {
      Id batchInstanceId = Database.executeBatch(new contactsBatchJob(), 40); 
   }
}