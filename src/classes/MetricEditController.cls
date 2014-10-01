public with sharing class MetricEditController {
	String recordId;
	String quarter;
	Boolean saved = false;
	M_E_Metric_Data__c metric;
	M_E_Metric__c eaddMetric;
	Boolean isEadd = false;
	
	public MetricEditController() {
        PageReference pageRef = ApexPages.currentPage();
        this.recordId = pageRef.getParameters().get('recordId');
        isEadd = pageRef.getParameters().get('operation') == 'eadd'? true: false;
        this.quarter = MetricHelpers.getCurrentQuarterAsString(0);
        if(this.recordId != null && this.recordId != '') {
        	loadMetric();
        }
    }
    
    public void loadMetric() {
    	//with eadd, what we want is the Projected value and its stored in the M_E_Metric__c not M_E_Metric_Data__c
    	if(isEadd){
    		this.eaddMetric = [Select Id, Name, Label__c, Projected_Value__c from M_E_Metric__c where Id =: this.recordId];
    		this.metric = new M_E_Metric_Data__c();//the UI binds to this. We will pick values from therein at save time
    		this.metric.Projected_Value__c = eaddMetric.Projected_Value__c;
    		this.quarter = this.eaddMetric.Name;
    	}
        else{
            M_E_Metric_Data__c metric = [
                SELECT 
                    M_E_Metric__r.Name, 
                    M_E_Metric__r.Automated__c,
                    M_E_Metric__r.Label__c, 
                    Projected_Value__c, 
                    Manual_Value__c,
                    Actual_Value__c, 
                    Comment__c 
                FROM 
                    M_E_Metric_Data__c 
                WHERE 
                    Id =: this.recordId];
            this.metric = metric;
        }
    }
    
    public String getQuarter() {
		return this.quarter;    	
    }

    public String getRecordId() {
    	return this.recordId;
    }
    
    public void setRecordId(String id) {
    	this.recordId = id;
    }
    
    public M_E_Metric_Data__c getMetric() {
    	return this.metric;
    }
    
    public void save() {
    	if(isEadd){
    		this.eaddMetric.Projected_Value__c = metric.Projected_Value__c;
    		update this.eaddMetric;
    		this.saved = true;
    	}
    	else{
	    	update this.metric;
	    	this.saved = true;
    	}
    }
    
    public Boolean getSaved() {
    	return this.saved;
    }
    
    public void setIsEadd(Boolean eadd) {
    	isEadd = eadd;
    }
    
    static testMethod void testMetricEdit() {
    	M_E_Metric_Data__c metric = [Select Id from M_E_Metric_Data__c limit 1];
    	MetricEditController controller = new MetricEditController();
    	controller.setRecordId(metric.Id);
    	controller.loadMetric();
    	controller.save();
    	System.assertEquals(metric.Id, controller.getMetric().Id);
 		System.assertEquals(true, controller.getSaved());
 		   	
 		M_E_Metric__c eaddmetric = [Select Id from M_E_Metric__c limit 1];
 		controller = new MetricEditController();
 		controller.setRecordId(eaddmetric.Id);
 		controller.setIsEadd(true);
    	controller.loadMetric();
    	controller.getMetric().Projected_Value__c = 100;
    	controller.save();
 		System.assertEquals(true, controller.getSaved());
    }
}