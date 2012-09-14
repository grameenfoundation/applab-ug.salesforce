public class MetricGraphController {
	private String chartData;
	private String chartTitle;
	private String metricId;
	
	public String getChartTitle() { 
		return chartTitle;
	}
	
	public String getChartData() {
		return chartData;
	}
	
	public MetricGraphController()	{
		PageReference pageRef = ApexPages.currentPage();        
        metricId = pageRef.getParameters().get('metricId');    
        setChartData();
	}
	
	public void setChartData() {
		String chdProjected = ''; //23,34,56 (Projected values)
		String chdActual = ''; // Actual values
		String chl = '';  // x axis Labels
		String chds = ''; // Scale (max and min)
		String chxr = ''; // y Axis Range
		Decimal absoluteMin = 0;
		Decimal absoluteMax = 100;
		
		// Load all values for the given metric up to the current quarter
        M_E_Metric_Data__c[] items = MetricHelpers.loadAllMetricData(this.metricId);
		
		// point count
		Integer actualCount = 0;
		Integer projectedCount = 0;
		
		for(M_E_Metric_Data__c item : items) {
			// Get label for the first metric
			if(this.chartTitle == null) {
				this.chartTitle = item.M_E_Metric__r.M_E_Area__c + ': ' + item.M_E_Metric__r.Label__c;
			}
			
			Decimal projectedVal = 0;
			if(item.Projected_Value__c != null) {
				projectedVal = item.Projected_Value__c;
			}
			chdProjected += projectedVal + ',';
			projectedCount++;
			
			Decimal actualVal = 0;
			if(!MetricHelpers.getCurrentQuarterAsString(0).equals(MetricHelpers.getQuarterAsString(item.Date__c))) {
				if(item.Actual_Value__c != null) {
					actualVal = item.Actual_Value__c;	
				}
				chdActual += actualVal + ',';
				actualCount++;
			}
			
			chl += MetricHelpers.getQuarterAsString(item.Date__c) + '|';
			
			if(Math.max(projectedVal, actualVal) > absoluteMax) {
				absoluteMax = Math.max(projectedVal, actualVal); 
			}
			
			if(Math.min(projectedVal, actualVal) < absoluteMin) {
				absoluteMin = Math.min(projectedVal, actualVal); 
			}
		}
		
		// Because we show one less coordinate for the actual graph, we have to do xy graphs, so we need to track the xpoint
		String xProjected = ''; // x coordinate for projected
		Integer total = items.size();
		String xActual = ''; // x coordinate for actual
		for(Integer i = 0; i < projectedCount; i++) {
			xProjected += (i * absoluteMax / Math.max(1, total - 1)) + ',';
		}
		for(Integer i = 0; i < actualCount; i++) {
			xActual += (i * absoluteMax / Math.max(1, total - 1)) + ',';
		}
		
		//remove the last comma or pipe
		if(chdProjected.length() > 1) {
			chdProjected = chdProjected.substring(0, chdProjected.length() -1);
			xProjected = xProjected.substring(0, xProjected.length() -1 );
		}
		if(chdActual.length() > 1) {
			chdActual = chdActual.substring(0, chdActual.length() -1);
			xActual = xActual.substring(0, xActual.length() - 1);
		}
		chl = chl.substring(0, chl.length() -1);
		
		// Set axis ranges and labels
		chds = absoluteMin + ',' + absoluteMax + ',' + absoluteMin + ',' + absoluteMax;
		chxr = '1,' + absoluteMin + ',' + absoluteMax;
		 
		String result = '&chd=t:' + xProjected + '|' + chdProjected + '|' + xActual + '|' + chdActual +'&chdl=Target|Actual&chl=' + chl + '&chds=' + chds + '&chxr=' + chxr + '&chxt=x,y';
		
		//Prepare the chart URL
		String chartPath = 'http://chart.apis.google.com/chart?chs=600x200&cht=lxy&chco=00FF00,0000FF&chm=o,00FF00,0,-1,10|o,0000FF,1,-1,10|B,00FF0050,0,1.0,5.0|B,0000FF50,1,1.0,5.0&chls=3|3';
		chartData = chartPath +  result;
	}
	
	public static testMethod void checkMetricGraph() {
		
		Date startDate = date.newInstance(2011, 1, 1);	
	    Date endDate = date.newInstance(2011, 3, 31);
	    
		// Create a test M_E_Metric__c and a M_E_Metric_Data__c
	    M_E_Metric__c testMetric = new M_E_Metric__c();
	    testMetric.Name = 'TEST_THIS_CODE';
	    testMetric.Label__c = 'This and that';
	    testMetric.M_E_Area__c = 'Impact';
	    testMetric.Order__c = 4;
	    testMetric.Update_Period__c = 'Daily';
	    database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
	    M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
	    testDataCurrent.M_E_Metric__c = testMetric.Id;
	    testDataCurrent.Actual_Value__c = 10;
	    testDataCurrent.Projected_Value__c = 15;
	    testDataCurrent.Date__c = startDate;
	    testDataCurrent.Comment__c = 'This should be this quarters.';
	    metricData.add(testDataCurrent);

	    M_E_Metric_Data__c testDataPrevious = new M_E_Metric_Data__c();
	    testDataPrevious.M_E_Metric__c = testMetric.Id;
	    testDataPrevious.Actual_Value__c = 10;
	    testDataPrevious.Projected_Value__c = 15;
	    testDataPrevious.Date__c = startDate.addMonths(-3);
	    testDataPrevious.Comment__c = 'This should be last quarters.';
	    metricData.add(testDataPrevious);
	    database.insert(metricData);
	    
	    MetricGraphController metricGraph = new MetricGraphController();
	    metricGraph.setChartData();
	}
}