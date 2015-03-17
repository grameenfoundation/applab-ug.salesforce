global class SBuxSegmentationProcessScheduler_CBL2 implements Schedulable {
   
   global void execute(SchedulableContext SC) {
      Id batchInstanceId = Database.executeBatch(new SbuxSegmentationProcessBatchJob_CBL2(), 100); 
   }
   
}