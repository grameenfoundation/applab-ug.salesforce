/**
	Controller class for AsocatiDashboard.page
*/

public with sharing class AsocatiDashboardController {

	
	//Variable used to control wether the sections that are only related to the farmer should be hide
	private Boolean hideFarmerSections = false;
	//TODO: To check if this variable is needed or the farmer name can be passed directly to the page control.
	private String LacFarmerName = 'No farmer';
	
    //Property used for the Id entered by the user
	public String farmerId{
		get;
		set;
	}
	
	public AsocatiDashboardController() {
		
		
	}
	
	//Method used to store the farmer name that will be displayed on the page.
	public void setFarmerName(String name){
		this.LacFarmerName = name;
	}
	
	//Method used by the page to retrieve the farmer name and display it.
	public String getFarmerName(){
		
		//TODO:To delete once the issue with storing the testFarmer is solved.
		return this.LacFarmerName;
		
		
		LAC_Farmer__c []farmer = AsocatiDashDAL.getTestLacFarmer();
        
        if(farmer.size() > 0){
        	this.setHideFarmerSections(false);
        	return farmer[0].Person__r.First_Name__c + ' ' + farmer[0].Person__r.Last_Name__c;
        }        
        	
        else{
        	this.setHideFarmerSections(true);
        	return 'No farmer';
        }
        
    }

	//Property used to control wether the sections that are only related to the farmer should be hide
	public void setHideFarmerSections(Boolean hide){
		this.hideFarmerSections = hide;
	}
	
	public Boolean getHideFarmerSections(){
		return this.hideFarmerSections;
	}
	
	//Method used by the AsocatiDashboard.page to retrieve the production metrics
	public List<M_E_Metric_Data__c> getProductionMetrics(){
		
		M_E_Metric_Data__c[] productionMetrics = AsocatiDashDAL.getProductionMetrics();
		        
        return productionMetrics;
		
	}
	
	//Method used by the AsocatiDashboard.page to retrieve the quality metrics
	public List<M_E_Metric_Data__c> getQualityMetrics(){
		
		M_E_Metric_Data__c[] qualityMetrics = AsocatiDashDAL.getQualityMetrics();
		        
        return qualityMetrics;
		
	}
	
	//Method used by the AsocatiDashboard.page to retrieve the commercialization metrics
	public List<M_E_Metric_Data__c> getCommercializationMetrics(){
		
		
		M_E_Metric_Data__c[] commercializationMetrics = AsocatiDashDAL.getCommercializationMetrics();
		        
        return commercializationMetrics;
		
	}
	
	
	//Method used by the AsocatiDashboard.page to retrieve the certification metrics
	public List<M_E_Metric_Data__c> getCertificationMetrics(){
	
		M_E_Metric_Data__c[] certificationMetrics = AsocatiDashDAL.getCertificationMetrics();
		
        return certificationMetrics;
		
	}
	
	//Method used by the AsocatiDashboard.page to retrieve the social metrics	
	public List<M_E_Metric_Data__c> getSocialMetrics(){
			
		M_E_Metric_Data__c[] socialMetrics = AsocatiDashDAL.getSocialMetrics();
		
		return socialMetrics;
		
	}
	
	//Method used by the AsocatiDashboard.page to retrieve the financial metrics
	public List<M_E_Metric_Data__c> getFinancialMetrics(){
		
		M_E_Metric_Data__c[] financialMetrics = AsocatiDashDAL.getFinancialMetrics();
		
        return financialMetrics;
		
	}
	
	//TODO:Add event fired when the user hits enter at the search box and search the farmer.
	
	/*
	TEST METHODS
	*/	
	
	//Event fired by the search button.
	public void onTestSearchButton(){
		
		if(this.farmerId.length()>0)
		{
			//TODO:At the event instead of doing this go and search for the farmer  
			this.setFarmerName('John Angel');
			this.setHideFarmerSections(false);
		}
		else
		{
			this.setFarmerName('No farmer');
			this.setHideFarmerSections(true);
			
		}
		
		
	}
	
	//Event fired by the create button.
	public void onTestCreateButton(){
		
//		LAC_Farmer__c testLacFarmer = AsocatiDashDAL.testCreateLacFarmer();
				
		testCreateProductionMetrics(null);
		testCreateQualityMetrics(null);
		testCreateCommercializationMetrics(null);
		testCreateCertificationMetrics();
		testCreateSocialMetrics();
		testCreateFinancialMetrics();
		
	}
	
	//Event fired by the delete button.
	public void onTestDeleteButton(){
	
		AsocatiDashDAL.testDeleteMetrics();
		AsocatiDashDAL.testDeleteFarmer();		
	}

	
	private Boolean testLacFarmerExists()
	{
		LAC_Farmer__c[] farmer = AsocatiDashDAL.getTestLacFarmer();
		
		if(farmer.size()>0)
			return true;
		else
			return false;
	}
	
		
	private void testCreateProductionMetrics(LAC_Farmer__c testFarmer){
			
		AsocatiDashBaseLineHelper.insertTotalProdHect(92,100,null);
		AsocatiDashBaseLineHelper.insertProdPlantsHect(1300,1500,null);
		AsocatiDashMonthlyHelper.insertTotalMonthlyProd(170,200,null);
		
	}
	
	private void testCreateQualityMetrics(LAC_Farmer__c testFarmer){
	
		AsocatiDashBaseLineHelper.insertAveragePremiumGrainProduced(35,50,null);
	}
	
	private void testCreateCommercializationMetrics(LAC_Farmer__c testFarmer){
		
		AsocatiDashBaseLineHelper.insertProdSoldAsocati(350,400,true,null);
		AsocatiDashBaseLineHelper.insertCertifiedKilosSoldByAsocati(85,85,null);
		AsocatiDashBaseLineHelper.insertExportedVsNational(60,70);
	}
	
	private void testCreateCertificationMetrics(){	
		
		AsocatiDashCocoaPractHelper.insertCocoaPractices(95,100);
		AsocatiDashBaseLineHelper.insertCertifiedProducers(150,180);
		AsocatiDashBaseLineHelper.insertProducersBeingCertified(230,260);
		LacHelper.insertPriceDifferences(1.3,1.7);
	
	}
	
	private void testCreateSocialMetrics(){
	
		AsocatiDashBaseLineHelper.insertCKWPerformance(93,100);
		AsocatiDashBaseLineHelper.insertTotalReached(4200,5000);
		AsocatiDashBaseLineHelper.insertVulnerableFarmersReached(1700,1850);
		AsocatiDashBaseLineHelper.insertFemaleFarmersReached(1100,1400);
		AsocatiDashBaseLineHelper.insertEthnicMinorityReached(800,1000);
		AsocatiDashBaseLineHelper.insertDisplacedReached(600,750);
		
		

		AsocatiDashMonthlyHelper.insertNumberBeneficiaries(1200,1500);
		AsocatiDashMonthlyHelper.insertNumberAssociates(120,130);
/*
		LacHelper.insertNumberMobileSysUsers(9,9);
		AsocatiDashBaseLineHelper.insertNumberUsersRegistered(10,10);
		AsocatiDashBaseLineHelper.insertPercentageActiveUsers(11,11);
*/
	}
	
	private void testCreateFinancialMetrics(){
	
		AsocatiDashBaseLineHelper.insertFinancialAccess(60,80);
		AsocatiDashBaseLineHelper.insertMobileMoney(60,75);
	}
}