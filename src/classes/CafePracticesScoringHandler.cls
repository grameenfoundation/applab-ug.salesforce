public with sharing class CafePracticesScoringHandler {

	private CBL_Farm__c farm;
	private Integer montlyMinimumWage = 616000; 
	private Double factorSociaResponsibility = 0.4186;
	private Double factorCoffeeGrowing = 0.4186;
	private Double factorWetCoffeeProcessing = 0.1628;
	/*
	� = \u00E1
	� = \u00E9
	� = \u00ED
	� = \u00F3
	� = \u00FA
	� = \u00F1
	*/

	public CafePracticesScoringHandler(CBL_Farm__c f) {
		farm = f;
	}

	public void handle() {
		//Traer la lista de fincas para el CBL	
		//Recorrer la lista de fincas creando el score para cada una
		//Create the score object to be saved related to the FMP and the Farm
		CP_Farm_Score__c score = new CP_Farm_Score__c();
		score.Farm__c = farm.Id;
		score.Baseline__c = farm.Baseline__c;	
		
		//Get the SocioEconomic survey info
		CBL_SocioEconomic__c[] socioEconomicList = [Select Id, childrenStudying__c from CBL_SocioEconomic__c where Baseline__c = :farm.Baseline__c];
		CBL_SocioEconomic__c socioEconomic = null;
		if (socioEconomicList.size() > 0) {
			socioEconomic = socioEconomicList[0];
		} else {
			System.debug('No socio economic');
			return;
		}
		
		//Get the WetMill survey info
		CBL_WetMill__c[] wetMillList = [Select Id, documentationAndLabeling__c, dryMeans__c, pulpManagement__c, residualWaterDistOver40__c, riskOfContamWResidualWater__c, lastWashWaterRecycled__c from CBL_WetMill__c where Baseline__c = :farm.Baseline__c];
		CBL_WetMill__c wetMill = null;
		if (wetMillList.size() > 0) {
			wetMill = wetMillList[0];
		} 
		else {
			System.debug('No wet mill');
			return;
		}
		
		//Calificar indicadores por categor�as almacenando los valores en el CP_FarmScore
		/* ---- CATEGORY 1: Social Responsibility Category ----- */
		Integer socialResponsibilityIndicators = 0;
		if (farm.permWorkersMinimumMonthWage__c >= montlyMinimumWage) {
			socialResponsibilityIndicators++;
		}
		if (farm.tempWorkersMinimumDailyWage__c >= (montlyMinimumWage/30)) {
			socialResponsibilityIndicators++;
		}
		if (farm.workersPaidRegularly__c == 'Cumple') {
			socialResponsibilityIndicators++;
		}
		if (farm.permWorkersMinimumMonthWage__c >= montlyMinimumWage) {
			socialResponsibilityIndicators++;
		}
		if (farm.tempWorkersMinimumDailyWage__c >= (montlyMinimumWage/30)) {
			socialResponsibilityIndicators++;
		}
		String valueForcedLabor = 'No hay trabajo forzado' + ';' + 'No hay pr\u00E1cticas de retenci\u00F3n' + ';' + 
			'No hay empleados ilegales' + ';' + 'No se les retiene su identificaci\u00F3n' + ';' +  
			'No pagan dep\u00F3sitos para poder trabajar';
		if (farm.forcedLabor__c == valueForcedLabor)
	 	{
			socialResponsibilityIndicators++;
		}
		if (farm.hiresUnderAge__c != 'S\u00ED, de menos de 14 a\u00F1os') {
			socialResponsibilityIndicators++;
		}
		List<String> underAgeWorkConditions = new List<String>();
		underAgeWorkConditions.add('Van a la escuela');
		underAgeWorkConditions.add('No sobrepasan las horas de trabajo');
		underAgeWorkConditions.add('No ponen en riego salud y crecimiento');
		if (farm.underAgeWorkConditions__c != null && validatePicklistVsStringList(underAgeWorkConditions, farm.underAgeWorkConditions__c)) {
			socialResponsibilityIndicators++;
		}
		if (farm.discrimination__c == 'De acuerdo') {
			socialResponsibilityIndicators++;
		}
		if (farm.forcedLabor__c == valueForcedLabor) {
			socialResponsibilityIndicators++;
		}
		if (farm.physicalOralSexualAbuse__c == 'En desacuerdo') {
			socialResponsibilityIndicators++;
		}
		if (farm.forcedLabor__c == valueForcedLabor) {	
			socialResponsibilityIndicators++;
		}
		if (socioEconomic.childrenStudying__c == 'S\u00ED, TODOS est\u00E1n asistiendo') {
			socialResponsibilityIndicators++;
		}
		if (farm.useOfProtApplicationDangSubstances__c == 'S\u00ED, siempre') {
			socialResponsibilityIndicators++;
		}
		if (farm.useOfProtApplicationDangSubstances__c == 'S\u00ED, siempre') {
			socialResponsibilityIndicators++;
		}
		if (farm.dangSubstancesManipulatorsTrained__c == 'S\u00ED') {
			socialResponsibilityIndicators++;
		}
		if (farm.underagePregnantProtected__c == 'S\u00ED se cumple') {
			socialResponsibilityIndicators++;
		}
		if (farm.entranceProhibited48Hours__c == 'Cumple') {
			socialResponsibilityIndicators++;
		}
		
		/* ---- CATEGORY 2: Coffee Growing Category ----- */
		Integer coffeGrowingIndicators = 0;
		if (farm.waterBodiesBufferZones__c != null && farm.waterBodiesBufferZones__c.contains('> al 50% de cuerpos de agua permanentes')) {
			coffeGrowingIndicators++;
		}
		if (farm.waterBodiesBufferZones__c != null && farm.waterBodiesBufferZones__c.contains('100% de cuerpos de agua permanentes')) {
			coffeGrowingIndicators++;
		}
		if (farm.waterBodiesBufferZones__c != null && farm.waterBodiesBufferZones__c.contains('> al 50% de cuerpos de agua intemitentes')) {
			coffeGrowingIndicators++;
		}
		if (farm.waterBodiesBufferZones__c != null && farm.waterBodiesBufferZones__c.contains('100% de cuerpos de agua intermitentes')) {
			coffeGrowingIndicators++;
		}
		if (farm.wasteDisposedSafeWay__c == 'Cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.erosionZonesIdentified__c == 'S\u00ED') {
			coffeGrowingIndicators++;
		}
		if (farm.farmManagmtDocuments__c != null && farm.farmManagmtDocuments__c.contains('Plan de conservaci\u00F3n de suelos')) {
			coffeGrowingIndicators++;
		}
		if (farm.percErosionZoneRiskPrevention__c >= 0.5) {
			coffeGrowingIndicators++;
		}
		if (farm.percErosionZoneRiskPrevention__c ==  100) {
			coffeGrowingIndicators++;
		}
		if (farm.percErosionZoneRiskPrevention__c >=  0.5) {
			coffeGrowingIndicators++;
		}
		if (farm.weedsControlMethods__c !=  'Control qu\u00EDmico/herbicidas') {
			coffeGrowingIndicators++;
		}
		if (farm.percShadeLeguminous__c >= 0.25) {
			coffeGrowingIndicators++;
		}
		if (farm.percShadeLeguminous__c >= 0.5) {
			coffeGrowingIndicators++;
		}
		if (farm.lastSoilSampling__c == 'entre 1-2 a\u00F1os' || farm.lastSoilSampling__c == 'menos de 1 a\u00F1o') {
			coffeGrowingIndicators++;
		}
		if (farm.fertAcordingSoilAnalysis__c == 'Fertiliza basado en an\u00E1lisis de suelo') {
			coffeGrowingIndicators++;
		}
		if (farm.farmManagmtDocuments__c != null && farm.farmManagmtDocuments__c.contains('Plan de manejo de sombra')) {
			coffeGrowingIndicators++;
		}
		if (farm.shadowLevelsNumber__c >= 1 && farm.percentageShade__c >= 0.1) {
			coffeGrowingIndicators++;
		}
		if (farm.numberOfShadeSpecies__c >= 2) {
			coffeGrowingIndicators++;
		}
		if (farm.shadowLevelsNumber__c >= 1 && farm.percentageShade__c >= 0.4) {
			coffeGrowingIndicators++;
		}
		if (farm.shadowLevelsNumber__c >= 2) {
			coffeGrowingIndicators++;
		}
		if (farm.promotesFloraAndFaunaPreservation__c == 'Si se cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.turnedForestInCropArea__c != 'S\u00ED') {
			coffeGrowingIndicators++;
		}
		if (farm.farm_Area_Ha__c != null && farm.Forest_Area_Ha__c != null && farm.Forest_Area_Ha__c > 0) {
			double percForestArea = farm.farm_Area_Ha__c / farm.Forest_Area_Ha__c;
			if (percForestArea >= 0.05) {
				coffeGrowingIndicators++;
			}
			if (percForestArea >= 0.1) {
				coffeGrowingIndicators++;
			}
		}
		if (farm.biologicalDiversityContrib__c == 'S\u00ED') {
			coffeGrowingIndicators++;
		}
		if (farm.diseaseControlAgrochemicals__c == 'No usa ning\u00FAn producto qu\u00EDmico' 
			&& (farm.weedsControlHerbicides__c == '' || farm.weedsControlHerbicides__c == null) 
			&& farm.plagueControlAgroChemicals__c == 'No usa ning\u00FAn producto qu\u00EDmico') {
			coffeGrowingIndicators++;
		}
		if (farm.farmManagmtDocuments__c != null && farm.farmManagmtDocuments__c.contains('Registro de insumos') && farm.farmManagmtDocuments__c.contains('Plan de MIPE')) {
			coffeGrowingIndicators++;
		}
		if (farm.safeStorageForSupplies__c == 'Cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.safeStorageForSupplies__c == 'Cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.agrochemOriginalContainerProperUse__c == 'Cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.farmManagmtDocuments__c != null && farm.farmManagmtDocuments__c.contains('Plan de MIPE')) {
			coffeGrowingIndicators++;
		}
		if (farm.registersPlague_DiseaseCtrlSupplies__c != null && farm.registersPlague_DiseaseCtrlSupplies__c.contains('Fecha de aplicaci\u00F3n')
			&& farm.registersPlague_DiseaseCtrlSupplies__c.contains('Dosis')
			&& farm.registersPlague_DiseaseCtrlSupplies__c.contains('Lote')) {
			coffeGrowingIndicators++;
		}
		if (farm.containersNotReused__c == 'Cumple') {
			coffeGrowingIndicators++;
		}
		if (farm.farmManagmtDocuments__c != null && farm.farmManagmtDocuments__c.contains('Plan y registro de Podas de caf\u00E9')) {
			coffeGrowingIndicators++;
		}
		
		/* ---- CATEGORY 3: Wet Coffee Processing Category ----- */
		Integer wetCoffeProcessingIndicators = 0;
		if (wetMill.lastWashWaterRecycled__c == 'S\u00ED') {
			wetCoffeProcessingIndicators++;
		}
		if (wetMill.riskOfContamWResidualWater__c == 'No') {
			wetCoffeProcessingIndicators++;
		}
		if (wetMill.residualWaterDistOver40__c == 'S\u00ED') {
			wetCoffeProcessingIndicators++;
		}
		if (
			wetMill.pulpManagement__c != 'La amontona sin protecci\u00F3n' 
			&& wetMill.pulpManagement__c != 'Lo vierte al r\u00EDo' 
			&& wetMill.pulpManagement__c != 'La bota' 
			&& wetMill.pulpManagement__c != 'Riesgo de contaminar fuentes de agua' 
			&& wetMill.pulpManagement__c != 'Otros'
		) {
			wetCoffeProcessingIndicators++;
		}
		if (wetMill.pulpManagement__c != null && wetMill.pulpManagement__c.contains('Procesa en compost en cuanto es posible')) {
			wetCoffeProcessingIndicators++;
		}
		if (wetMill.dryMeans__c != 'Secadora mec\u00E1nica'
			&& wetMill.dryMeans__c != 'Otro'){
			wetCoffeProcessingIndicators++;
		}
		if (wetMill.documentationAndLabeling__c == 'S\u00ED') {
			wetCoffeProcessingIndicators++;
		}
		
		//Calculate percentages per categories					
		score.Social_Responsibility_Practices_Met__c = socialResponsibilityIndicators;
		score.Coffee_Growing_Practices_Met__c = coffeGrowingIndicators;
		score.Wet_Coffee_Processing_Practices_Met__c = wetCoffeProcessingIndicators;
		
		farm.CP_Calculation_Date__c = Date.today();
		
		insert score;
	}					
	
	private Boolean validatePicklistVsStringList(List<String> strings, String valuesToCompare) {
		for (String str : strings) {
			if (!valuesToCompare.contains(str)) {
				return false;
			}
		} 
		return true;
	}

}