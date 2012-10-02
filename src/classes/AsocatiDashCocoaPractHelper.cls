//This is the class for the post-processing of the survey "CACAO PRACTICES"

public with sharing class AsocatiDashCocoaPractHelper {

	public static List<String> processBaseline(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter, Person__c interviewee) {

	DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
    
    if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
    }
    
    //TODO: Get the metrics and do the post-processing!
            
	return new String[] { '1', 'All metric datas updated for farmer with id: ' + interviewee.id, 'SUPRESSMSG' };

	}
	
	
	public static void insertCocoaPractices(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cocoaPractices = new M_E_Metric__c();
        cocoaPractices.Name = 'cocoa_Practices';
        cocoaPractices.Label__c = '% promedio en el cumplimiento de las prácticas de cacao';
        cocoaPractices.M_E_Area__c = 'Certification';
        //What does this mean?
        cocoaPractices.Order__c = 4;
        //Trimestral value should be added to this picklist
        cocoaPractices.Update_Period__c = 'Quarterly';
        
        Database.insert(cocoaPractices);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cocoaPracticesData = new M_E_Metric_Data__c();
        
        cocoaPracticesData.M_E_Metric__c = cocoaPractices.Id;
        cocoaPracticesData.Actual_Value__c = answer;
        //This will be defined manually
        cocoaPracticesData.Projected_Value__c = projectedValue;
        
           //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cocoaPracticesData.Manual_Value__c = 80;
        //Used for variacion column
        cocoaPracticesData.Numerator__c = 45;
        
        Database.insert(cocoaPracticesData);	
		
	}
}