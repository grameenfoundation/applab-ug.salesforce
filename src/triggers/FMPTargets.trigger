trigger FMPTargets on FMP_Target__c (before insert, before update) {
	if (Trigger.isInsert) {
		List <FMP_Target__c> targetsToInsert = new List <FMP_Target__c>();
		List<String> newTargetFarmids = new List<String>();
		for (FMP_Target__c newTargetFarm : Trigger.new) {
		  	newTargetFarmids.add(newTargetFarm.FMP_Diagnostic__c);
		}
		List <FMP_Target__c> existingTargets = [Select FMP_Diagnostic__c From FMP_Target__c Where FMP_Diagnostic__c in :newTargetFarmids];

		for (FMP_Target__c newTarget : Trigger.new) {
			if (existingTargets.size() == 0) {
				FMP_Target__c ntarget = new FMP_Target__c ();
				ntarget.adequateTransportation__c = newTarget.adequateTransportation__c;
				ntarget.channelsScamperOk__c = newTarget.channelsScamperOk__c;
				ntarget.checklist__c = newTarget.checklist__c;
				ntarget.coffeeDryingSystemOk__c= newTarget.coffeeDryingSystemOk__c;
				ntarget.coffeePackaging__c= newTarget.coffeePackaging__c;
				ntarget.controlAccordingMonitoring__c= newTarget.controlAccordingMonitoring__c;
				ntarget.evaluationPulping__c= newTarget.evaluationPulping__c;
				ntarget.farmMap__c= newTarget.farmMap__c;
				ntarget.FMP_Diagnostic__c = newTarget.FMP_Diagnostic__c;
				ntarget.FaunaFloraRecoveryPlan__c= newTarget.FaunaFloraRecoveryPlan__c;
				ntarget.fermentationTanksOk__c= newTarget.fermentationTanksOk__c;
				ntarget.friendlyMethodsReducingHerbicide__c= newTarget.friendlyMethodsReducingHerbicide__c;
				ntarget.harvestEvaluation__c= newTarget.harvestEvaluation__c;
				ntarget.harvestRecord__c= newTarget.harvestRecord__c;
				ntarget.hasProtectionEquipment__c= newTarget.hasProtectionEquipment__c;
				ntarget.honeyWaterTreatmentTank__c= newTarget.honeyWaterTreatmentTank__c;
				ntarget.identifyingErodedAreas__c= newTarget.identifyingErodedAreas__c;
				ntarget.implemetationSeedbedPlan__c= newTarget.implemetationSeedbedPlan__c;
				ntarget.knowledgeAreasLots__c = newTarget.knowledgeAreasLots__c;
				ntarget.makingMonitoringPestsDiseases__c= newTarget.makingMonitoringPestsDiseases__c;
				ntarget.monitoringRecordPestDisease__c= newTarget.monitoringRecordPestDisease__c;
				ntarget.postControlEvaluation__c= newTarget.postControlEvaluation__c;
				ntarget.properCoffeeStorage__c= newTarget.properCoffeeStorage__c;
				ntarget.properSubstratesPreparation__c= newTarget.properSubstratesPreparation__c;
				ntarget.pulpCompostingPit__c= newTarget.pulpCompostingPit__c;
				ntarget.pulpingMachineOk__c= newTarget.pulpingMachineOk__c;
				ntarget.recordHarvesting__c= newTarget.recordHarvesting__c;
				ntarget.recordOfLabor__c= newTarget.recordOfLabor__c;
				ntarget.recordPesticideApplications__c= newTarget.recordPesticideApplications__c;
				ntarget.recordPurchasingInputs__c= newTarget.recordPurchasingInputs__c;
				ntarget.recordsAgrochemicalsApplications__c= newTarget.recordsAgrochemicalsApplications__c;
				ntarget.recordSalesCPS__c= newTarget.recordSalesCPS__c;
				ntarget.recordVarietiesTreesPerLot__c= newTarget.recordVarietiesTreesPerLot__c;
				ntarget.recoveryErodedAreas__c= newTarget.recoveryErodedAreas__c;
				ntarget.reforestationNativeSpecies__c= newTarget.reforestationNativeSpecies__c;
				ntarget.registrationWorkPerLot__c= newTarget.registrationWorkPerLot__c;
				ntarget.regulationOfShadow__c= newTarget.regulationOfShadow__c;
				ntarget.separationCoffeePerLot__c= newTarget.separationCoffeePerLot__c;
				ntarget.separationCoffeeQuality__c= newTarget.separationCoffeeQuality__c;
				ntarget.Submission__c= newTarget.Submission__c;
				ntarget.tanksMucilageRemoverOk__c= newTarget.tanksMucilageRemoverOk__c;
				ntarget.trainsStaffAgrochemicalsHandling__c= newTarget.trainsStaffAgrochemicalsHandling__c;
				ntarget.transformationPulpsForUse__c= newTarget.transformationPulpsForUse__c;
				ntarget.useProtectionEquipment__c= newTarget.useProtectionEquipment__c;
				ntarget.usingControlMethodsForPYE__c= newTarget.usingControlMethodsForPYE__c;
				ntarget.usingNativeSpeciesAsShading__c= newTarget.usingNativeSpeciesAsShading__c;
				ntarget.warehouseSafety__c= newTarget.warehouseSafety__c;
				ntarget.wastewaterManagement__c= newTarget.wastewaterManagement__c;
				ntarget.wetmillSafety__c= newTarget.wetmillSafety__c;
				ntarget.wetmillWaterManagement__c= newTarget.wetmillWaterManagement__c;
				ntarget.zarandaGoodCondition__c= newTarget.zarandaGoodCondition__c;
				targetsToInsert.add(ntarget);
			}
		}
		try {
        insert targetsToInsert;
	    } catch (system.Dmlexception e) {
	        system.debug (e);
	    }
	}
	if (Trigger.isUpdate) {
		List <FMP_Target__c> targetsToUpdate = new List <FMP_Target__c>();
		for (FMP_Target__c upTarget: Trigger.new) {
        	FMP_Target__c oldTarget = Trigger.oldMap.get(upTarget.Id);
        	FMP_Target__c upsertarget = new FMP_Target__c ();
        	upsertarget.Id= oldTarget.Id;
	        if(upTarget.adequateTransportation__c == 'Sí' && oldTarget.adequateTransportation__c == 'No') {
	        	upsertarget.adequateTransportation__c = upTarget.adequateTransportation__c;
	        }
	        else{
	        	upsertarget.adequateTransportation__c = oldTarget.adequateTransportation__c;
	        }
	        if(upTarget.channelsScamperOk__c == 'Sí' && oldTarget.channelsScamperOk__c == 'No') {
	        	upsertarget.channelsScamperOk__c= upTarget.channelsScamperOk__c;
	        }
	        else{
	        	upsertarget.channelsScamperOk__c = oldTarget.channelsScamperOk__c;
	        }
	        if(upTarget.checklist__c == 'Sí' && oldTarget.checklist__c == 'No') {
	        	upsertarget.checklist__c = upTarget.checklist__c;
	        }
	        else{
	        	upsertarget.checklist__c = oldTarget.checklist__c;
	        }
	        if(upTarget.coffeeDryingSystemOk__c == 'Sí' && oldTarget.coffeeDryingSystemOk__c == 'No') {
	        	upsertarget.coffeeDryingSystemOk__c = upTarget.coffeeDryingSystemOk__c;
	        }
	        else{
	        	upsertarget.coffeeDryingSystemOk__c = oldTarget.coffeeDryingSystemOk__c;
	        }
	        if(upTarget.coffeePackaging__c == 'Sí' && oldTarget.coffeePackaging__c == 'No') {
	        	upsertarget.coffeePackaging__c = upTarget.coffeePackaging__c;
	        }
	        else{
	        	upsertarget.coffeePackaging__c = oldTarget.coffeePackaging__c;
	        }
	        if(upTarget.controlAccordingMonitoring__c == 'Sí' && oldTarget.controlAccordingMonitoring__c == 'No') {
	        	upsertarget.controlAccordingMonitoring__c = upTarget.controlAccordingMonitoring__c;
	        }
	        else{
	        	upsertarget.controlAccordingMonitoring__c = oldTarget.controlAccordingMonitoring__c;
	        }
	        if(upTarget.evaluationPulping__c == 'Sí' && oldTarget.evaluationPulping__c == 'No') {
	        	upsertarget.evaluationPulping__c = upTarget.evaluationPulping__c;
	        }
	        else{
	        	upsertarget.evaluationPulping__c = oldTarget.evaluationPulping__c;
	        }
	        if(upTarget.farmMap__c== 'Sí' && oldTarget.farmMap__c == 'No') {
	        	upsertarget.farmMap__c = upTarget.farmMap__c;
	        }
	        else{
	        	upsertarget.farmMap__c= oldTarget.farmMap__c;
	        }
	        upsertarget.FMP_Diagnostic__c = oldTarget.FMP_Diagnostic__c;
	        if(upTarget.FaunaFloraRecoveryPlan__c == 'Sí' && oldTarget.FaunaFloraRecoveryPlan__c == 'No') {
	        	upsertarget.FaunaFloraRecoveryPlan__c = upTarget.FaunaFloraRecoveryPlan__c;
	        }
	        else{
	        	upsertarget.FaunaFloraRecoveryPlan__c = oldTarget.FaunaFloraRecoveryPlan__c;
	        }
	        if(upTarget.fermentationTanksOk__c == 'Sí' && oldTarget.fermentationTanksOk__c == 'No') {
	        	upsertarget.fermentationTanksOk__c = upTarget.fermentationTanksOk__c;
	        }
	        else{
	        	upsertarget.fermentationTanksOk__c = oldTarget.fermentationTanksOk__c;
	        }
	        if(upTarget.friendlyMethodsReducingHerbicide__c == 'Sí' && oldTarget.friendlyMethodsReducingHerbicide__c == 'No') {
	        	upsertarget.friendlyMethodsReducingHerbicide__c = upTarget.friendlyMethodsReducingHerbicide__c;
	        }
	        else{
	        	upsertarget.friendlyMethodsReducingHerbicide__c = oldTarget.friendlyMethodsReducingHerbicide__c;
	        }
	        if(upTarget.harvestEvaluation__c == 'Sí' && oldTarget.harvestEvaluation__c == 'No') {
	        	upsertarget.harvestEvaluation__c = upTarget.harvestEvaluation__c;
	        }
	        else{
	        	upsertarget.harvestEvaluation__c = oldTarget.harvestEvaluation__c;
	        }
			if(upTarget.harvestRecord__c == 'Sí' && oldTarget.harvestRecord__c == 'No') {
	        	upsertarget.harvestRecord__c = upTarget.harvestRecord__c;
	        }
	        else{
	        	upsertarget.harvestRecord__c = oldTarget.harvestRecord__c;
	        }
	        if(upTarget.hasProtectionEquipment__c == 'Sí' && oldTarget.hasProtectionEquipment__c == 'No') {
	        	upsertarget.hasProtectionEquipment__c = upTarget.hasProtectionEquipment__c;
	        }
	        else{
	        	upsertarget.hasProtectionEquipment__c = oldTarget.hasProtectionEquipment__c;
	        }
	        if(upTarget.honeyWaterTreatmentTank__c == 'Sí' && oldTarget.honeyWaterTreatmentTank__c == 'No') {
	        	upsertarget.honeyWaterTreatmentTank__c = upTarget.honeyWaterTreatmentTank__c;
	        }
	        else{
	        	upsertarget.honeyWaterTreatmentTank__c = oldTarget.honeyWaterTreatmentTank__c;
	        }
	        if(upTarget.identifyingErodedAreas__c == 'Sí' && oldTarget.identifyingErodedAreas__c == 'No') {
	        	upsertarget.identifyingErodedAreas__c = upTarget.identifyingErodedAreas__c;
	        }
	        else{
	        	upsertarget.identifyingErodedAreas__c = oldTarget.identifyingErodedAreas__c;
	        }
	        if(upTarget.implemetationSeedbedPlan__c == 'Sí' && oldTarget.implemetationSeedbedPlan__c == 'No') {
	        	upsertarget.implemetationSeedbedPlan__c = upTarget.implemetationSeedbedPlan__c;
	        }
	        else{
	        	upsertarget.implemetationSeedbedPlan__c = oldTarget.implemetationSeedbedPlan__c;
	        }
	        if(upTarget.knowledgeAreasLots__c == 'Sí' && oldTarget.knowledgeAreasLots__c == 'No') {
	        	upsertarget.knowledgeAreasLots__c = upTarget.knowledgeAreasLots__c;
	        }
	        else{
	        	upsertarget.knowledgeAreasLots__c = oldTarget.knowledgeAreasLots__c;
	        }
	        if(upTarget.knowledgeAreasLots__c == 'Sí' && oldTarget.knowledgeAreasLots__c == 'No') {
	        	upsertarget.knowledgeAreasLots__c = upTarget.knowledgeAreasLots__c;
	        }
	        else{
	        	upsertarget.knowledgeAreasLots__c = oldTarget.knowledgeAreasLots__c;
	        }
	        if(upTarget.makingMonitoringPestsDiseases__c == 'Sí' && oldTarget.makingMonitoringPestsDiseases__c == 'No') {
	        	upsertarget.makingMonitoringPestsDiseases__c = upTarget.makingMonitoringPestsDiseases__c;
	        }
	        else{
	        	upsertarget.makingMonitoringPestsDiseases__c = oldTarget.makingMonitoringPestsDiseases__c;
	        }
	        if(upTarget.monitoringRecordPestDisease__c == 'Sí' && oldTarget.monitoringRecordPestDisease__c == 'No') {
	        	upsertarget.monitoringRecordPestDisease__c = upTarget.monitoringRecordPestDisease__c;
	        }
	        else{
	        	upsertarget.monitoringRecordPestDisease__c = oldTarget.monitoringRecordPestDisease__c;
	        }
	        if(upTarget.postControlEvaluation__c == 'Sí' && oldTarget.postControlEvaluation__c == 'No') {
	        	upsertarget.postControlEvaluation__c = upTarget.postControlEvaluation__c;
	        }
	        else{
	        	upsertarget.postControlEvaluation__c = oldTarget.postControlEvaluation__c;
	        }
	        if(upTarget.properCoffeeStorage__c == 'Sí' && oldTarget.properCoffeeStorage__c == 'No') {
	        	upsertarget.properCoffeeStorage__c = upTarget.properCoffeeStorage__c;
	        }
	        else{
	        	upsertarget.properCoffeeStorage__c = oldTarget.properCoffeeStorage__c;
	        }
	        if(upTarget.properSubstratesPreparation__c == 'Sí' && oldTarget.properSubstratesPreparation__c == 'No') {
	        	upsertarget.properSubstratesPreparation__c = upTarget.properSubstratesPreparation__c;
	        }
	        else{
	        	upsertarget.properSubstratesPreparation__c = oldTarget.properSubstratesPreparation__c;
	        }
	        if(upTarget.pulpCompostingPit__c == 'Sí' && oldTarget.pulpCompostingPit__c == 'No') {
	        	upsertarget.pulpCompostingPit__c= upTarget.pulpCompostingPit__c;
	        }
	        else{
	        	upsertarget.pulpCompostingPit__c = oldTarget.pulpCompostingPit__c;
	        }
	        if(upTarget.pulpingMachineOk__c == 'Sí' && oldTarget.pulpingMachineOk__c == 'No') {
	        	upsertarget.pulpingMachineOk__c= upTarget.pulpingMachineOk__c;
	        }
	        else{
	        	upsertarget.pulpingMachineOk__c = oldTarget.pulpingMachineOk__c;
	        }
	        if(upTarget.recordHarvesting__c == 'Sí' && oldTarget.recordHarvesting__c == 'No') {
	        	upsertarget.recordHarvesting__c= upTarget.recordHarvesting__c;
	        }
	        else{
	        	upsertarget.recordHarvesting__c = oldTarget.recordHarvesting__c;
	        }
	        if(upTarget.recordOfLabor__c == 'Sí' && oldTarget.recordOfLabor__c == 'No') {
	        	upsertarget.recordOfLabor__c= upTarget.recordOfLabor__c;
	        }
	        else{
	        	upsertarget.recordOfLabor__c = oldTarget.recordOfLabor__c;
	        }
	        if(upTarget.recordPesticideApplications__c == 'Sí' && oldTarget.recordPesticideApplications__c == 'No') {
	        	upsertarget.recordPesticideApplications__c= upTarget.recordPesticideApplications__c;
	        }
	        else{
	        	upsertarget.recordPesticideApplications__c = oldTarget.recordPesticideApplications__c;
	        }
	        if(upTarget.recordPurchasingInputs__c == 'Sí' && oldTarget.recordPurchasingInputs__c == 'No') {
	        	upsertarget.recordPurchasingInputs__c= upTarget.recordPurchasingInputs__c;
	        }
	        else{
	        	upsertarget.recordPurchasingInputs__c = oldTarget.recordPurchasingInputs__c;
	        }
	        if(upTarget.recordsAgrochemicalsApplications__c == 'Sí' && oldTarget.recordsAgrochemicalsApplications__c == 'No') {
	        	upsertarget.recordsAgrochemicalsApplications__c= upTarget.recordsAgrochemicalsApplications__c;
	        }
	        else{
	        	upsertarget.recordsAgrochemicalsApplications__c = oldTarget.recordsAgrochemicalsApplications__c;
	        }
	        if(upTarget.recordSalesCPS__c == 'Sí' && oldTarget.recordSalesCPS__c == 'No') {
	        	upsertarget.recordSalesCPS__c= upTarget.recordSalesCPS__c;
	        }
	        else{
	        	upsertarget.recordSalesCPS__c = oldTarget.recordSalesCPS__c;
	        }
	        if(upTarget.recordVarietiesTreesPerLot__c == 'Sí' && oldTarget.recordVarietiesTreesPerLot__c == 'No') {
	        	upsertarget.recordVarietiesTreesPerLot__c= upTarget.recordVarietiesTreesPerLot__c;
	        }
	        else{
	        	upsertarget.recordVarietiesTreesPerLot__c = oldTarget.recordVarietiesTreesPerLot__c;
	        }
	        if(upTarget.recoveryErodedAreas__c == 'Sí' && oldTarget.recoveryErodedAreas__c == 'No') {
	        	upsertarget.recoveryErodedAreas__c= upTarget.recoveryErodedAreas__c;
	        }
	        else{
	        	upsertarget.recoveryErodedAreas__c = oldTarget.recoveryErodedAreas__c;
	        }
	        if(upTarget.reforestationNativeSpecies__c == 'Sí' && oldTarget.reforestationNativeSpecies__c == 'No') {
	        	upsertarget.reforestationNativeSpecies__c= upTarget.reforestationNativeSpecies__c;
	        }
	        else{
	        	upsertarget.reforestationNativeSpecies__c = oldTarget.reforestationNativeSpecies__c;
	        }
	        if(upTarget.registrationWorkPerLot__c == 'Sí' && oldTarget.registrationWorkPerLot__c == 'No') {
	        	upsertarget.registrationWorkPerLot__c= upTarget.registrationWorkPerLot__c;
	        }
	        else{
	        	upsertarget.registrationWorkPerLot__c = oldTarget.registrationWorkPerLot__c;
	        }
	        if(upTarget.regulationOfShadow__c == 'Sí' && oldTarget.regulationOfShadow__c == 'No') {
	        	upsertarget.regulationOfShadow__c= upTarget.regulationOfShadow__c;
	        }
	        else{
	        	upsertarget.regulationOfShadow__c = oldTarget.regulationOfShadow__c;
	        }
	        if(upTarget.separationCoffeePerLot__c == 'Sí' && oldTarget.separationCoffeePerLot__c == 'No') {
	        	upsertarget.separationCoffeePerLot__c= upTarget.separationCoffeePerLot__c;
	        }
	        else{
	        	upsertarget.separationCoffeePerLot__c = oldTarget.separationCoffeePerLot__c;
	        }
	        if(upTarget.separationCoffeeQuality__c == 'Sí' && oldTarget.separationCoffeeQuality__c == 'No') {
	        	upsertarget.separationCoffeeQuality__c= upTarget.separationCoffeeQuality__c;
	        }
	        else{
	        	upsertarget.separationCoffeeQuality__c = oldTarget.separationCoffeeQuality__c;
	        }
	        upsertarget.Submission__c = upTarget.Submission__c;
	        if(upTarget.tanksMucilageRemoverOk__c == 'Sí' && oldTarget.tanksMucilageRemoverOk__c == 'No') {
	        	upsertarget.tanksMucilageRemoverOk__c= upTarget.tanksMucilageRemoverOk__c;
	        }
	        else{
	        	upsertarget.tanksMucilageRemoverOk__c = oldTarget.tanksMucilageRemoverOk__c;
	        }
	        if(upTarget.trainsStaffAgrochemicalsHandling__c == 'Sí' && oldTarget.trainsStaffAgrochemicalsHandling__c == 'No') {
	        	upsertarget.trainsStaffAgrochemicalsHandling__c= upTarget.trainsStaffAgrochemicalsHandling__c;
	        }
	        else{
	        	upsertarget.trainsStaffAgrochemicalsHandling__c = oldTarget.trainsStaffAgrochemicalsHandling__c;
	        }
	        if(upTarget.transformationPulpsForUse__c == 'Sí' && oldTarget.transformationPulpsForUse__c == 'No') {
	        	upsertarget.transformationPulpsForUse__c= upTarget.transformationPulpsForUse__c;
	        }
	        else{
	        	upsertarget.transformationPulpsForUse__c = oldTarget.transformationPulpsForUse__c;
	        }
	        if(upTarget.useProtectionEquipment__c == 'Sí' && oldTarget.useProtectionEquipment__c == 'No') {
	        	upsertarget.useProtectionEquipment__c= upTarget.useProtectionEquipment__c;
	        }
	        else{
	        	upsertarget.useProtectionEquipment__c = oldTarget.useProtectionEquipment__c;
	        }
	        if(upTarget.usingControlMethodsForPYE__c == 'Sí' && oldTarget.usingControlMethodsForPYE__c == 'No') {
	        	upsertarget.usingControlMethodsForPYE__c= upTarget.usingControlMethodsForPYE__c;
	        }
	        else{
	        	upsertarget.usingControlMethodsForPYE__c= oldTarget.usingControlMethodsForPYE__c;
	        }
	        if(upTarget.usingNativeSpeciesAsShading__c == 'Sí' && oldTarget.usingNativeSpeciesAsShading__c == 'No') {
	        	upsertarget.usingNativeSpeciesAsShading__c= upTarget.usingNativeSpeciesAsShading__c;
	        }
	        else{
	        	upsertarget.usingNativeSpeciesAsShading__c= oldTarget.usingNativeSpeciesAsShading__c;
	        }
	        if(upTarget.warehouseSafety__c == 'Sí' && oldTarget.warehouseSafety__c == 'No') {
	        	upsertarget.warehouseSafety__c= upTarget.warehouseSafety__c;
	        }
	        else{
	        	upsertarget.warehouseSafety__c= oldTarget.warehouseSafety__c;
	        }
	        if(upTarget.wastewaterManagement__c == 'Sí' && oldTarget.wastewaterManagement__c == 'No') {
	        	upsertarget.wastewaterManagement__c= upTarget.wastewaterManagement__c;
	        }
	        else{
	        	upsertarget.wastewaterManagement__c= oldTarget.wastewaterManagement__c;
	        }
	        if(upTarget.wetmillSafety__c == 'Sí' && oldTarget.wetmillSafety__c == 'No') {
	        	upsertarget.wetmillSafety__c = upTarget.wetmillSafety__c;
	        }
	        else{
	        	upsertarget.wetmillSafety__c = oldTarget.wetmillSafety__c;
	        }
	        if(upTarget.wetmillWaterManagement__c == 'Sí' && oldTarget.wetmillWaterManagement__c == 'No') {
	        	upsertarget.wetmillWaterManagement__c = upTarget.wetmillWaterManagement__c;
	        }
	        else{
	        	upsertarget.wetmillWaterManagement__c = oldTarget.wetmillWaterManagement__c;
	        }
	        if(upTarget.zarandaGoodCondition__c == 'Sí' && oldTarget.zarandaGoodCondition__c == 'No') {
	        	upsertarget.zarandaGoodCondition__c = upTarget.zarandaGoodCondition__c;
	        }
	        else{
	        	upsertarget.zarandaGoodCondition__c = oldTarget.zarandaGoodCondition__c;
	        }

	        targetsToUpdate.add(upsertarget);
	 	}
	 	try {
        update targetsToUpdate;
	    } catch (system.Dmlexception e) {
	        system.debug (e);
	    }
	}
} 