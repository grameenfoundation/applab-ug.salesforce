//This is the class for the post-processing of the survey "ENCUESTA MENSUAL Asocati"

public with sharing class AsocatiDashMonthlyHelper {
	
	public static List<String> processBaseline(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter, Person__c interviewee) {

	DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
    
    if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
    }
    
    //TODO: Get the metrics and do the post-processing!
            
	return new String[] { '1', 'All metric datas updated for farmer with id: ' + interviewee.id, 'SUPRESSMSG' };

	}
	/*
	METRICS FOR PRODUCTION
	*/
	
	public static void insertTotalMonthlyProd(Integer answer, Integer projectedValue, Person__c farmer){
	
		M_E_Metric__c totalMonthlyProd = new M_E_Metric__c();
        totalMonthlyProd.Name = 'total_Month_Prod';
        totalMonthlyProd.Label__c = 'Promedio de producción total mensual en kilos';
        totalMonthlyProd.M_E_Area__c = 'Production';
        //What does this mean?
        totalMonthlyProd.Order__c = 4;
        //Trimestral value should be added to this picklist
        totalMonthlyProd.Update_Period__c = 'Monthly';
        
        AsocatiDashDAL.insertMetric(totalMonthlyProd);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c totalMonthlyProdData = new M_E_Metric_Data__c();
        
        totalMonthlyProdData.M_E_Metric__c = totalMonthlyProd.Id;
        totalMonthlyProdData.Actual_Value__c = answer;
        //This will be defined manually
        totalMonthlyProdData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        totalMonthlyProdData.Manual_Value__c = 150;
        //Used for variacion column
        totalMonthlyProdData.Numerator__c = 27;
        
        //TODO: Enable this
        //prodPlantsHectData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(totalMonthlyProdData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart


	}
	
	
	/*
	METRICS FOR SOCIAL INCLUSION AND QUALITY OF LIFE
	*/
	
	public static void insertNumberBeneficiaries(Integer answer, Integer projectedValue){
		
		M_E_Metric__c numberBeneficiaries = new M_E_Metric__c();
        numberBeneficiaries.Name = 'number_Beneficiaries';
        numberBeneficiaries.Label__c = 'Número de beneficiarios';
        numberBeneficiaries.M_E_Area__c = 'Certification';
        //What does this mean?
        numberBeneficiaries.Order__c = 4;
        //Trimestral value should be added to this picklist
        numberBeneficiaries.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(numberBeneficiaries);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c numberBeneficiariesData = new M_E_Metric_Data__c();
        
        numberBeneficiariesData.M_E_Metric__c = numberBeneficiaries.Id;
        numberBeneficiariesData.Actual_Value__c = answer;
        //This will be defined manually
        numberBeneficiariesData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        numberBeneficiariesData.Manual_Value__c = 960;
        //Used for variacion column
        numberBeneficiariesData.Numerator__c = 32;
        
        AsocatiDashDAL.insertMetric(numberBeneficiariesData);	
		
	}
	
	public static void insertNumberAssociates(Integer answer, Integer projectedValue){
		
		M_E_Metric__c numberAssociates = new M_E_Metric__c();
        numberAssociates.Name = 'number_Associates';
        numberAssociates.Label__c = 'Número de asociados';
        numberAssociates.M_E_Area__c = 'Social';
        //What does this mean?
        numberAssociates.Order__c = 4;
        //Trimestral value should be added to this picklist
        numberAssociates.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(numberAssociates);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c numberAssociatesData = new M_E_Metric_Data__c();
        
        numberAssociatesData.M_E_Metric__c = numberAssociates.Id;
        //This has to be replaced for the value gathered from the survey
        numberAssociatesData.Actual_Value__c = answer;
        //This will be defined manually
        numberAssociatesData.Projected_Value__c = projectedValue;
        
          //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        numberAssociatesData.Manual_Value__c = 96;
        //Used for variacion column
        numberAssociatesData.Numerator__c = 17;
        
        AsocatiDashDAL.insertMetric(numberAssociatesData);	
		
	}
	

}