global class SBuxSegmentationProcessScheduler implements Schedulable {
   
   global void execute(SchedulableContext SC) {
      Id batchInstanceId = Database.executeBatch(new SbuxSegmentationProcessBatchJob(), 100); 
   }
   
}