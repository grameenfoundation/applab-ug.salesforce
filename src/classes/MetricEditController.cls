public with sharing class MetricEditController {
	String recordId;
	String quarter;
	Boolean saved = false;
	M_E_Metric_Data__c metric;
	
	public MetricEditController() {
        PageReference pageRef = ApexPages.currentPage();
        this.recordId = pageRef.getParameters().get('recordId');
        this.quarter = MetricHelpers.getCurrentQuarterAsString(0);
        if(this.recordId != null && this.recordId != '') {
        	loadMetric();
        }
    }
    
    public void loadMetric() {
    	M_E_Metric_Data__c metric = [Select M_E_Metric__r.Name, 
    									M_E_Metric__r.Label__c, Projected_Value__c, Manual_Value__c,
    									Actual_Value__c, Comment__c from M_E_Metric_Data__c where Id =: this.recordId];
    	this.metric = metric;
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
    	update this.metric;
    	this.saved = true;
    }
    
    public Boolean getSaved() {
    	return this.saved;
    }
    
    static testMethod void testMetricEdit() {
    	M_E_Metric_Data__c metric = [Select Id from M_E_Metric_Data__c limit 1];
    	MetricEditController controller = new MetricEditController();
    	controller.setRecordId(metric.Id);
    	controller.loadMetric();
    	controller.save();
    	System.assertEquals(metric.Id, controller.getMetric().Id);
 		System.assertEquals(true, controller.getSaved());
 		   	
    }
}