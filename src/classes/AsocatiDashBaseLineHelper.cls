//This is the class for the post-processing of the survey "LINEA DE BASE Asocati" 

public with sharing class AsocatiDashBaseLineHelper {

	public static List<String> processBaseline(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c submitter, Person__c interviewee) {

	DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
    
    if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
    }
    
 
    //Metrics for PRODUCTION 
    
    //From survey: LINEA DE BASE Asocati
    //TODO: Double check that Answer_Integer__c can be used instead of using Decimal.valueOf.
    Decimal totalCocoaProdHectare = Decimal.valueOf(answers.get('HectaresCacao_0').Answer__c);
    Decimal prodPlantsHectare = Decimal.valueOf(answers.get('PlantasProductivasHA_0').Answer__c);
    
    //Metrics for QUALITY
    Decimal cocoaPremiumKilos = Decimal.valueOf(answers.get('KilosPremiumTrimestre_0').Answer__c);
    Decimal cocoaCorrienteKilos = Decimal.valueOf(answers.get('KilosCorrienteTrimestre_0').Answer__c);
    Decimal cocoaPasillaKilos = Decimal.valueOf(answers.get('KilosPasillaTrimestre_0').Answer__c);
    
    Decimal cocoaTotalKilos = cocoaPremiumKilos + cocoaCorrienteKilos + cocoaPasillaKilos;
    
    Decimal percentagePremium = cocoaPremiumKilos/cocoaTotalKilos;
    Decimal percentageCorriente = cocoaCorrienteKilos/cocoaTotalKilos;
    Decimal percentagePasilla = cocoaPasillaKilos/cocoaTotalKilos;
    
    //Metrics for COMMERCIALIZATION
    
    Decimal kilosSoldToAsocati = Decimal.valueOf(answers.get('KilosVendidoAAsocatiTrimestre').Answer__c);
    //TODO: Check if this is the way of getting info from multiselects
    String certifications = answers.get('YaCertificado').Answer__c;



    if(certifications.equalsIgnoreCase('YES')){
       	insertProdSoldAsocati(kilosSoldToAsocati, 0, true,interviewee);    	    
    }
    else{
    	insertProdSoldAsocati(kilosSoldToAsocati, 0, false,interviewee);
    }
   
    
    //Metrics for CERTIFICATION
         
    
        
	return new String[] { '1', 'All metric datas updated for farmer with id: ' + interviewee.id, 'SUPRESSMSG' };

	}
	
	
	/*
	METRICS FOR PRODUCTION
	*/
	public static void insertTotalProdHect(Integer answer, Integer projectedValue, Person__c farmer){
	
		M_E_Metric__c totalProdHect = new M_E_Metric__c();
        totalProdHect.Name = 'total_Prod_Hectare';
        totalProdHect.Label__c = 'Producción de kilos promedio por hectárea';
        totalProdHect.M_E_Area__c = 'Production';
        //What does this mean?
        totalProdHect.Order__c = 4;
        //Trimestral value should be added to this picklist
        totalProdHect.Update_Period__c = 'Quarterly';
        
   		AsocatiDashDAL.insertMetric(totalProdHect);
        
        
        //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c totalProdHectData = new M_E_Metric_Data__c();
        
        totalProdHectData.M_E_Metric__c = totalProdHect.Id;
        totalProdHectData.Actual_Value__c = answer;
        //This will be defined manually
        totalProdHectData.Projected_Value__c = projectedValue;
        
        //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        totalProdHectData.Manual_Value__c = 72;
        //Used for variacion column
        totalProdHectData.Numerator__c = 25;
        
        
        
        //TODO: Enable this
//       totalProdHectData.Person__c = farmer.id;
        
        
        AsocatiDashDAL.insertMetric(totalProdHectData);
        
        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate production by these and build the chart
        
        
	}
	
	public static void insertProdPlantsHect(Integer answer, Integer projectedValue, Person__c farmer){
	
		M_E_Metric__c prodPlantsHect = new M_E_Metric__c();
        prodPlantsHect.Name = 'prod_Plants_Hectare';
        prodPlantsHect.Label__c = 'Promedio de plantas productivas por hectárea';
        prodPlantsHect.M_E_Area__c = 'Production';
        //What does this mean?
        prodPlantsHect.Order__c = 4;
        //Trimestral value should be added to this picklist
        prodPlantsHect.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(prodPlantsHect);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c prodPlantsHectData = new M_E_Metric_Data__c();
        
        prodPlantsHectData.M_E_Metric__c = prodPlantsHect.Id;
        prodPlantsHectData.Actual_Value__c = answer;
        //This will be defined manually
        prodPlantsHectData.Projected_Value__c = projectedValue;
        
        //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        prodPlantsHectData.Manual_Value__c = 1200;
        //Used for variacion column
        prodPlantsHectData.Numerator__c = 30;
        
        
        //TODO: Enable this
        //prodPlantsHectData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(prodPlantsHectData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart


	}
	
	/*
	METRICS FOR QUALITY
	*/
	
	public static void insertAveragePremiumGrainProduced(Decimal answer, Integer projectedValue, Person__c farmer){
		
		M_E_Metric__c averagePremiumGrainProduced = new M_E_Metric__c();
        averagePremiumGrainProduced.Name = 'average_Premium_Grain_Produced';
        averagePremiumGrainProduced.Label__c = 'Porcentaje de cacao tipo Premium producido';
        averagePremiumGrainProduced.M_E_Area__c = 'Quality';
        //What does this mean?
        averagePremiumGrainProduced.Order__c = 4;
        //Trimestral value should be added to this picklist
        averagePremiumGrainProduced.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(averagePremiumGrainProduced);
        
        
        M_E_Metric_Data__c averagePremiumGrainProducedData = new M_E_Metric_Data__c();
        
        averagePremiumGrainProducedData.M_E_Metric__c = averagePremiumGrainProduced.Id;
        averagePremiumGrainProducedData.Actual_Value__c = answer;
        //This will be defined manually
        averagePremiumGrainProducedData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        averagePremiumGrainProducedData.Manual_Value__c = 25;
        //Used for variacion column
        averagePremiumGrainProducedData.Numerator__c = 15;
        
        //TODO: Enable this
        //prodSoldAsocatiData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(averagePremiumGrainProducedData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart
	}
	
	
	
	
	/*
	METRICS FOR COMMERCIALIZATION
	*/
	
	public static void insertProdSoldAsocati(Decimal answer, Integer projectedValue, boolean isCertified,Person__c farmer){
		
		M_E_Metric__c prodSoldAsocati = new M_E_Metric__c();
        prodSoldAsocati.Name = 'prod_Sold_Asocati';
        prodSoldAsocati.Label__c = 'Producción total vendida a ASOCATI por trimestre';
        prodSoldAsocati.M_E_Area__c = 'Commercialization';
        //What does this mean?
        prodSoldAsocati.Order__c = 4;
        //Trimestral value should be added to this picklist
        prodSoldAsocati.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(prodSoldAsocati);
        
        
        M_E_Metric_Data__c prodSoldAsocatiData = new M_E_Metric_Data__c();
        
        prodSoldAsocatiData.M_E_Metric__c = prodSoldAsocati.Id;
        prodSoldAsocatiData.Actual_Value__c = answer;
        //This will be defined manually
        prodSoldAsocatiData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        prodSoldAsocatiData.Manual_Value__c = 280;
        //Used for variacion column
        prodSoldAsocatiData.Numerator__c = 16;
        //TODO: Enable this
        //prodSoldAsocatiData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(prodSoldAsocatiData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart
	}
	
	public static void insertCertifiedKilosSoldByAsocati(Decimal answer, Integer projectedValue,Person__c farmer){
		
		M_E_Metric__c certifiedKilosSoldByAsocati = new M_E_Metric__c();
        certifiedKilosSoldByAsocati.Name = 'certified_Kilos_Sold_By_Asocati';
        certifiedKilosSoldByAsocati.Label__c = '% de kilos certificados vendidos por ASOCATI';
        certifiedKilosSoldByAsocati.M_E_Area__c = 'Commercialization';
        //What does this mean?
        certifiedKilosSoldByAsocati.Order__c = 4;
        //Trimestral value should be added to this picklist
        certifiedKilosSoldByAsocati.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(certifiedKilosSoldByAsocati);
        
        
        M_E_Metric_Data__c certifiedKilosSoldByAsocatiData = new M_E_Metric_Data__c();
        
        certifiedKilosSoldByAsocatiData.M_E_Metric__c = certifiedKilosSoldByAsocati.Id;
        certifiedKilosSoldByAsocatiData.Actual_Value__c = answer;
        //This will be defined manually
        certifiedKilosSoldByAsocatiData.Projected_Value__c = projectedValue;
        
          //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        certifiedKilosSoldByAsocatiData.Manual_Value__c = 80;
        //Used for variacion column
        certifiedKilosSoldByAsocatiData.Numerator__c = 20;
        
        //TODO: Enable this
        //prodSoldAsocatiData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(certifiedKilosSoldByAsocatiData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart
	}
	
	//TODO: Gather information for Sales distribution metric. Since this metric will be provided directly by ASOCATI we may
	//leave its post-processing in this class.
	
	public static void insertExportedVsNational(Decimal answer, Integer projectedValue){
		
		M_E_Metric__c exportedVsNational = new M_E_Metric__c();
        exportedVsNational.Name = 'exported_Vs_National';
        exportedVsNational.Label__c = '% de kilos exportados vs vendidos a nivel nacional';
        exportedVsNational.M_E_Area__c = 'Commercialization';
        //What does this mean?
        exportedVsNational.Order__c = 4;
        //Trimestral value should be added to this picklist
        exportedVsNational.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(exportedVsNational);
        
        
        M_E_Metric_Data__c exportedVsNationalData = new M_E_Metric_Data__c();
        
        exportedVsNationalData.M_E_Metric__c = exportedVsNational.Id;
        exportedVsNationalData.Actual_Value__c = answer;
        //This will be defined manually
        exportedVsNationalData.Projected_Value__c = projectedValue;
        
          //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        exportedVsNationalData.Manual_Value__c = 40;
        //Used for variacion column
        exportedVsNationalData.Numerator__c = 35;
        
        //TODO: Enable this
        //prodSoldAsocatiData.Person__c = farmer.id;
        
        AsocatiDashDAL.insertMetric(exportedVsNationalData);

        //TODO: Get population type, ethnicity and PPI score information.

        //TODO: Disaggregate productive plants by these and build the chart
	}
	/*
	METRICS FOR CERTIFICATION 
	*/
	
	public static void insertCertifiedProducers(Integer answer, Integer projectedValue){
		
		M_E_Metric__c certifiedProducers = new M_E_Metric__c();
        certifiedProducers.Name = 'certified_Producers';
        certifiedProducers.Label__c = 'Número de productores certificados';
        certifiedProducers.M_E_Area__c = 'Certification';
        //What does this mean?
        certifiedProducers.Order__c = 4;
        //Trimestral value should be added to this picklist
        certifiedProducers.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(certifiedProducers);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c certifiedProducersData = new M_E_Metric_Data__c();
        
        certifiedProducersData.M_E_Metric__c = certifiedProducers.Id;
        certifiedProducersData.Actual_Value__c = answer;
        //This will be defined manually
        certifiedProducersData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        certifiedProducersData.Manual_Value__c = 110;
        //Used for variacion column
        certifiedProducersData.Numerator__c = 60;
        
        AsocatiDashDAL.insertMetric(certifiedProducersData);	
		
	}
	
	public static void insertProducersBeingCertified(Integer answer, Integer projectedValue){
		
		M_E_Metric__c producersBeingCertified = new M_E_Metric__c();
        producersBeingCertified.Name = 'producers_Being_Certified';
        producersBeingCertified.Label__c = 'Número de productores en proceso de certificación';
        producersBeingCertified.M_E_Area__c = 'Certification';
        //What does this mean?
        producersBeingCertified.Order__c = 4;
        //Trimestral value should be added to this picklist
        producersBeingCertified.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(producersBeingCertified);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c producersBeingCertifiedData = new M_E_Metric_Data__c();
        
        producersBeingCertifiedData.M_E_Metric__c = producersBeingCertified.Id;
        producersBeingCertifiedData.Actual_Value__c = answer;
        //This will be defined manually
        producersBeingCertifiedData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        producersBeingCertifiedData.Manual_Value__c = 170;
        //Used for variacion column
        producersBeingCertifiedData.Numerator__c = 60;
        
        AsocatiDashDAL.insertMetric(producersBeingCertifiedData);	
		
	}
	
	
	
	
	/*
	METRICS FOR SOCIAL INCLUSION AND QUALITY OF LIFE
	*/
	
	public static void insertCKWPerformance(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'CKW_PerformanceData';
        cKWPerformance.Label__c = '% de CKW cumpliendo sus metas ';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 89;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 37;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
	}
	
	public static void insertVulnerableFarmersReached(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'VulnerableFarmersReached';
        cKWPerformance.Label__c = ' - Productores vulnerables alcanzados';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 1300;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 85;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
	}
	
	public static void  insertFemaleFarmersReached(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'FemaleFarmersReached';
        cKWPerformance.Label__c = ' - Mujeres cabezas de familia alcanzadas';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 800;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 87;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
	
		
	}
	
	public static void  insertEthnicMinorityReached(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'EthnicMinorityReached';
        cKWPerformance.Label__c = ' - Minorias etnicas alcanzadas';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 600;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 75;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
		
	}
	
	public static void  insertDisplacedReached(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'insertDisplacedReached';
        cKWPerformance.Label__c = ' - Productores desplazados alcanzados';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 450;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 80;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
		
	}
	public static void  insertTotalReached(Integer answer, Integer projectedValue){
		
		M_E_Metric__c cKWPerformance = new M_E_Metric__c();
        cKWPerformance.Name = 'insertTotalReached';
        cKWPerformance.Label__c = 'Total de productores alcanzados';
        cKWPerformance.M_E_Area__c = 'Inclusion';
        //What does this mean?
        cKWPerformance.Order__c = 4;
        //Trimestral value should be added to this picklist
        cKWPerformance.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(cKWPerformance);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c cKWPerformanceData = new M_E_Metric_Data__c();
        
        cKWPerformanceData.M_E_Metric__c = cKWPerformance.Id;
        cKWPerformanceData.Actual_Value__c = answer;
        //This will be defined manually
        cKWPerformanceData.Projected_Value__c = projectedValue;
        
         //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        cKWPerformanceData.Manual_Value__c = 3200;
        //Used for variacion column
        cKWPerformanceData.Numerator__c = 100;
        
        AsocatiDashDAL.insertMetric(cKWPerformanceData);	
		
		
	}
	
	
	
	
	
	//TODO:This metric has to be gathered from the registration survey REGISTRO NUEVOS USUARIOS
	public static void insertNumberUsersRegistered(Integer answer, Integer projectedValue){
		
		M_E_Metric__c numberUsersRegistered = new M_E_Metric__c();
        numberUsersRegistered.Name = 'number_Users_Registered';
        numberUsersRegistered.Label__c = 'Número de usuarios registrados';
        numberUsersRegistered.M_E_Area__c = 'Social';
        //What does this mean?
        numberUsersRegistered.Order__c = 4;
        //Trimestral value should be added to this picklist
        numberUsersRegistered.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(numberUsersRegistered);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c numberUsersRegisteredData = new M_E_Metric_Data__c();
        
        numberUsersRegisteredData.M_E_Metric__c = numberUsersRegistered.Id;
        //This has to be replaced for the value gathered from the survey
        numberUsersRegisteredData.Actual_Value__c = answer;
        //This will be defined manually
        numberUsersRegisteredData.Projected_Value__c = projectedValue;
        
        AsocatiDashDAL.insertMetric(numberUsersRegisteredData);	
		
	}
	
	//TODO:This metric has to be gathered from CKWSearch usage... need to find out how to do this.
	public static void insertPercentageActiveUsers(Integer answer, Integer projectedValue){
		
		M_E_Metric__c percentageActiveUsers = new M_E_Metric__c();
        percentageActiveUsers.Name = 'percentage_Active_Users';
        percentageActiveUsers.Label__c = 'Número de usuarios activos del sistema';
        percentageActiveUsers.M_E_Area__c = 'Social';
        //What does this mean?
        percentageActiveUsers.Order__c = 4;
        //Trimestral value should be added to this picklist
        percentageActiveUsers.Update_Period__c = 'Quarterly';
        
        AsocatiDashDAL.insertMetric(percentageActiveUsers);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c percentageActiveUsersdData = new M_E_Metric_Data__c();
        
        percentageActiveUsersdData.M_E_Metric__c = percentageActiveUsers.Id;
        //This has to be replaced for the value gathered from the survey
        percentageActiveUsersdData.Actual_Value__c = answer;
        //This will be defined manually
        percentageActiveUsersdData.Projected_Value__c = projectedValue;
        
        AsocatiDashDAL.insertMetric(percentageActiveUsersdData);	
		
	}
	
	/*
	METRICS FOR FINANCIAL
	*/
	//TODO:This metric has to be gathered from the registration survey REGISTRO NUEVOS USUARIOS
	
	public static void insertFinancialAccess(Integer answer, Integer projectedValue){
		
		M_E_Metric__c financialAccess = new M_E_Metric__c();
        financialAccess.Name = 'financial_Access';
        financialAccess.Label__c = '% de productores que tuvieron acceso a un credito con entidades financieras durante el ultimo año';
        financialAccess.M_E_Area__c = 'Financial';
        //What does this mean?
        financialAccess.Order__c = 4;
        //Anual value should be added to this picklist
        financialAccess.Update_Period__c = 'Yearly';
        
        AsocatiDashDAL.insertMetric(financialAccess);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c financialAccessdData = new M_E_Metric_Data__c();
        
        financialAccessdData.M_E_Metric__c = financialAccess.Id;
        //This has to be replaced for the value gathered from the survey
        financialAccessdData.Actual_Value__c = answer;
        //This will be defined manually
        financialAccessdData.Projected_Value__c = projectedValue;
        
        //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        financialAccessdData.Manual_Value__c = 40;
        //Used for variacion column
        financialAccessdData.Numerator__c = 70;
        
        AsocatiDashDAL.insertMetric(financialAccessdData);	
		
	}
	
	public static void insertMobileMoney(Integer answer, Integer projectedValue){
		
		M_E_Metric__c mobileMoney = new M_E_Metric__c();
        mobileMoney.Name = 'mobile_Money';
        mobileMoney.Label__c = '% de compras realizadas a traves de dinero movil';
        mobileMoney.M_E_Area__c = 'Financial';
        //What does this mean?
        mobileMoney.Order__c = 4;
        //Anual value should be added to this picklist
        mobileMoney.Update_Period__c = 'Yearly';
        
        AsocatiDashDAL.insertMetric(mobileMoney);
        
         //Create a M_E_Metric_Data__c object
        M_E_Metric_Data__c mobileMoneyData = new M_E_Metric_Data__c();
        
        mobileMoneyData.M_E_Metric__c = mobileMoney.Id;
        //This has to be replaced for the value gathered from the survey
        mobileMoneyData.Actual_Value__c = answer;
        //This will be defined manually
        mobileMoneyData.Projected_Value__c = projectedValue;
        
          //This is only for Mastercard demo. Need to be calculated and stored in the proper object/fields
        //Used for anterior column
        mobileMoneyData.Manual_Value__c = 20;
        //Used for variacion column
        mobileMoneyData.Numerator__c = 85;
        
        AsocatiDashDAL.insertMetric(mobileMoneyData);	
		
	}
	
}