global class EMPTrainingAsistantScheduler implements Schedulable {

	global void execute(SchedulableContext sc) {
		Id batchInstanceId = Database.executeBatch(new EMPTrainingAsistantBatchJob(), 100); 
	}
}