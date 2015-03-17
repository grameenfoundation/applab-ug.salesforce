trigger CBL2FarmCreate on CBL2_Farm__c (after insert) {
	List<Id> farms_Ids = new List<Id>();
	List<CAFE_Practices_Score__c> cAFEPracticesToInsert = new List <CAFE_Practices_Score__c>();
	List<SFL_Scoring__c> sFLScoringToInsert = new List <SFL_Scoring__c>();
	List<FMP_Diagnostic__c> diagnosticToInsert = new List <FMP_Diagnostic__c>();

	boolean farmsExists = false;

  	for (CBL2_Farm__c idsNewFarms : Trigger.new) {
        farms_Ids.add(idsNewFarms.id);
  	}

  	for(List<SFL_Scoring__c> existingSFLScores : [Select LAC_SFL_Scores_Farm__c From SFL_Scoring__c Where LAC_SFL_Scores_Farm__c in :farms_Ids]){
  		for (CBL2_Farm__c newScoring : Trigger.new) {
			farmsExists = false;
			for(SFL_Scoring__c SFLScore: existingSFLScores){
				if(newScoring.Id == SFLScore.LAC_SFL_Scores_Farm__c)
				farmsExists = true;				
			}		
			if (!farmsExists) {
				SFL_Scoring__c  nScoring = new SFL_Scoring__c  ();
				nScoring .LAC_SFL_Scores_Farm__c = newScoring .Id;
				nScoring .LAC_SFL_Scores_Farmer__c= newScoring .CBL2_Farms_Farmer__c;
				sFLScoringToInsert.add(nScoring);
			}
	  	}
	  	try {
	   		insert SFLScoringToInsert;
		} 
		catch (system.Exception e) {
		   	system.debug (e);
		}
  	}
  	
	for(List<CAFE_Practices_Score__c> existingCAFEPractices : [Select Farm__c From CAFE_Practices_Score__c Where Farm__c in :farms_Ids]){
		for (CBL2_Farm__c newCPractices : Trigger.new) {
			farmsExists = false;
			for(CAFE_Practices_Score__c CFPractices: existingCAFEPractices){
				if(newCPractices.Id == CFPractices.Farm__c)
				farmsExists = true;				
			}		
			if (!farmsExists) {
				CAFE_Practices_Score__c  nPractices= new CAFE_Practices_Score__c ();
				nPractices .Farm__c = newCPractices.Id;
				nPractices .Baseline__c = newCPractices.CBL2_Farms_Farmer__c;
				cAFEPracticesToInsert.add(nPractices);
			}
	  	}
	  	try {
	   		insert CAFEPracticesToInsert;
		} 
		catch (system.Exception e) {
		   	system.debug (e);
		}
	}

	for(List<FMP_Diagnostic__c> existingDiagnostics : [Select PMF_Farm__c From FMP_Diagnostic__c Where PMF_Farm__c in :farms_Ids]){
		for (CBL2_Farm__c newDiagnostic : Trigger.new) {
			farmsExists = false;
			for(FMP_Diagnostic__c nDiagnostics: existingDiagnostics){
				if(newDiagnostic.Id == nDiagnostics.PMF_Farm__c)
				farmsExists = true;				
			}		
			if (!farmsExists) {
				FMP_Diagnostic__c  diagnostic= new FMP_Diagnostic__c();
				diagnostic.PMF_Farm__c = newDiagnostic.Id;
				diagnosticToInsert.add(diagnostic);
			}
	  	}
	  	try {
	   		insert diagnosticToInsert;
		} 
		catch (system.Exception e) {
		   	system.debug (e);
		}
	}
}