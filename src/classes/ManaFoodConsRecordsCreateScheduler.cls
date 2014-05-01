global class ManaFoodConsRecordsCreateScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      Id batchInstanceId = Database.executeBatch(new ManaFoodConsumptionRecordsCreateBatchJob(), 49); 
   }
}