public with sharing class FMPCategoryResult {
	
	public String resultType;
	public String level;
	public Date resultDate; 
	
	public void setResultType(String resType) { 
		this.resultType = resType;
	}
	
	public void setLevel(String lvl) {
		this.level = lvl;
	}
	
	public void setResultDate(Date resDate) {
		this.resultDate = resDate;
	}
	
	public String getResultType() {
		return resultType;
	}
	
	public String getLevel() {
		return level;
	}
	
	public Date getDate() {
		return resultDate;
	} 
	
	/*
	private Farm_Management_Plan__c fmp = new Farm_Management_Plan__c();
	private PMF_Finca_Categoria_1__c registriesCat = new PMF_Finca_Categoria_1__c();
 	private PMF_Finca_Categoria_2__c millCat = new PMF_Finca_Categoria_2__c();
	private PMF_Finca_Categoria_3__c soilConservationCat = new PMF_Finca_Categoria_3__c();
	private PMF_Finca_Categoria_4__c shadowMgmtCat = new PMF_Finca_Categoria_4__c();
	private PMF_Finca_Categoria_5_MIPE__c MIPECat = new PMF_Finca_Categoria_5_MIPE__c();
	private PMF_Finca_Categoria_6_Control_malezas__c undergrowthCat = new PMF_Finca_Categoria_6_Control_malezas__c();
	private PMF_Finca_Categoria_7_Manejo_plaguicid__c pesticideMgmtCat = new PMF_Finca_Categoria_7_Manejo_plaguicid__c();
	private PMF_Finca_Categoria_8_Gestion_ambienta__c envMgmtCat = new PMF_Finca_Categoria_8_Gestion_ambienta__c();
	private PMF_Finca_Categ_9_Cosecha_PostCosecha__c harvestPostHarvestCat = new PMF_Finca_Categ_9_Cosecha_PostCosecha__c();
	private PMF_Finca_Categoria_10_Lotes__c lotsCat = new PMF_Finca_Categoria_10_Lotes__c();
	private PMF_Finca_Categoria_11_Alm_cigo__c seedbedCat = new PMF_Finca_Categoria_11_Alm_cigo__c();
	*/	

}