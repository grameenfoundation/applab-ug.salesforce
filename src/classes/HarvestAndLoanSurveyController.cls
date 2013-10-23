public with sharing class HarvestAndLoanSurveyController{
	
	private Map<String, Integer> cropPrice = new Map<String, Integer>();
	
    public HarvestAndLoanSurveyController() {
    }
    
    // Add the possibility for a farmer to have multiple harvests and calculate loan based on that
    public List<HarvestLoan> getLeadData(){
    	List<Harvest__c> harvestList = [SELECT 
											Id,
											Name,
											Crop__c,
											Farmer__r.Id,
											Farmer__r.Name,
											Farmer__r.Person__r.First_Name__c,
											Farmer__r.Person__r.Middle_Name__c,
											Farmer__r.Person__r.Last_Name__c,
											Farmer__r.Person__r.ID_Number__C,
											Quantity_Accepted__c
											FROM Harvest__c
											WHERE Farmer__c NOT IN (SELECT Farmer__c FROM Loan__c WHERE Loan_Contract_No__c != '')
											ORDER BY Farmer__c ASC NULLS FIRST];
	    List<HarvestLoan> hlList = new List<HarvestLoan>();
	    
	    // iterate through the results and combine multiple harvest from one farmer
	    HarvestLoan prev = null;
	    Id prevId = null;
	    for(Harvest__c h: harvestList){
	    	// if the same farmer, simply add the harvest to the existing HarvestLoan
	    	// else add a new HarvestLoan to the list and the harvest after
	    	if(prevId == h.Farmer__r.Id){
	    		addHarvest(prev, h);
	    	}
	    	else {
	    		HarvestLoan hl = fromHarvest(h);
	    		addHarvest(hl, h);
	    		hlList.add(hl);
	    		prev = hl;
	    		prevId = h.Farmer__r.Id;
	    	}
	    }

	    return hlList;
    }
    
    public PageReference exportPage(){
    	PageReference newPage = new PageReference('/apex/HarvestAndLoanSurveyExport');
    	return newPage;
    }
    
    public String getFileName(){
        return 'harvestloan-export-' + DateTime.now().format('yyyyMMddHHmmss');
    }
    
    public String getRunDate(){
        return DateTime.now().format('dd MMM yyyy, HH:mm:ss');
    }
    
    private void addHarvest(HarvestLoan hl, Harvest__c data){
    	HarvestValue hv = new HarvestValue();
    	
        hv.CropName = data.Crop__c;
        String cropNameLower = hv.CropName.toLowerCase();
        hv.QuantityAccepted = Integer.valueOf(data.Quantity_Accepted__c);
        
    	Integer valueOfCrop = -1;
        Integer valueOfHarvest = -1;
        if(cropPrice.containsKey(cropNameLower)){
            valueOfCrop = cropPrice.get(cropNameLower);
            valueOfHarvest = hv.QuantityAccepted * cropPrice.get(cropNameLower);
        }
        else {
            List<Commodities__c> comm = [SELECT Highest_Wholesale_Price__c FROM Commodities__c WHERE Name = :hv.CropName AND Market__r.Name = 'e-warehouse' ORDER BY Effective_date__c DESC LIMIT 1];
            if(comm.size() == 1){
                if(comm[0].Highest_Wholesale_Price__c > 0){
                    cropPrice.put(cropNameLower, Integer.valueOf(comm[0].Highest_Wholesale_Price__c));
                    valueOfHarvest = hv.QuantityAccepted * cropPrice.get(cropNameLower);
                    valueOfCrop = cropPrice.get(cropNameLower);
                }
                else{
                    hv.ValueOfHarvest = -1;
                    hv.ValueOfCrop = -1;
                    hv.Error = 'No valid crop price found: ' + hv.CropName;
                    
                }
            }
            else {
                hv.ValueOfHarvest = -1;
                hv.ValueOfCrop = -1;
                hv.Error = 'No valid crop price found: ' + hv.CropName;
            }
        }
        
        if(valueOfCrop > 0){
            hv.ValueOfCrop = valueOfCrop;
            hv.ValueOfHarvest = valueOfHarvest;
        }
    	
    	
    	// finally add the HarvestValue to the HarvestLoan
        hl.addHarvestValue(hv);
    }
    
    private HarvestLoan fromHarvest(Harvest__c data){
    	HarvestLoan hl = new HarvestLoan();
    	hl.FarmerId = data.Farmer__r.Id;
    	hl.FciID = data.Farmer__r.Name;
	    hl.FirstName = data.Farmer__r.Person__r.First_Name__c;
	    hl.MiddleName = data.Farmer__r.Person__r.Middle_Name__c;
	    hl.LastName = data.Farmer__r.Person__r.Last_Name__c;
	    hl.NationalID = data.Farmer__r.Person__r.ID_Number__c;
	    
	    return hl;
    }
    
    public class HarvestLoan {
    	public String FarmerId {get; set; }
        public String FciID {get; set; }
        public String FirstName {get; set; }
        public String MiddleName {get; set; }
        public String LastName {get; set; }
        public String NationalID {get; set; }
        private String error { get; set; }
        
        private List<HarvestValue> farmerHarvests {get; set;}
        
    	public HarvestLoan(){
    		farmerHarvests = new List<HarvestValue>();
    	}
    	
    	public void addHarvestValue(HarvestValue hv){
    		farmerHarvests.add(hv);
    	}
    	
    	public String getHarvest(){
    		// there are harvests stored, concat them
    		String h = '';
    		for(HarvestValue hv : farmerHarvests){
    			h += hv.CropName + '('+hv.QuantityAccepted+');';
    		}
            return h;
        }
        
        public Integer getValueOfHarvest(){
        	// there are harvests stored, sum amounts
            Integer h = 0;
            for(HarvestValue hv : farmerHarvests){
            	if(hv.Error != null){
            		Error = hv.Error;
            		return -1;
            	}
            	else {
            	   h += hv.ValueOfHarvest;	
            	}
                
            }
            return h;
        }
    	
    	public Integer getEstimatedLoanAmount(){
	        // there are harvests stored, sum amounts
            Integer h = 0;
            for(HarvestValue hv : farmerHarvests){
                if(hv.Error != null){
                    Error = hv.Error;
                    return -1;
                }
                else {
                   h += hv.ValueOfHarvest;  
                }
                
            }
            return h / 2;
        }
        
        public String getError(){
        	if(error != null)
        	   return error;
        	   
        	for(HarvestValue hv : farmerHarvests){
                if(hv.Error != null)
                    return hv.Error;
        	}
        	
        	return 'No errors';
        }
    }
    
    public class HarvestValue {
    	public String CropName { get; set; }
    	public Integer ValueOfCrop { get; set; }
    	public Integer QuantityAccepted {get; set; }
        public Integer ValueOfHarvest { get; set; }
        public String Error { get; set; }
    }
    
}