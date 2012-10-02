//This is the class for the post-processing of the survey "Encuesta Organizaciones Productivas" 

public with sharing class AsocatiDashPOHelper {
	
	public static List<String> processBaseline(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter, Person__c interviewee) {

	DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
    
    if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
    }
    
    //TODO: Get the metrics and do the post-processing!
            
	return new String[] { '1', 'All metric datas updated for farmer with id: ' + interviewee.id, 'SUPRESSMSG' };

	}

}