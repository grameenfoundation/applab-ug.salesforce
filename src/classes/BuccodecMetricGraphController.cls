/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  plots graph for metric datas of a given metric
 *  tests are in BuccodecTests class
 */
public class BuccodecMetricGraphController {
    
    private String chartData;
    private String chartTitle;
    
    public String metricId { get; set; }
    
    public String getChartTitle() { 
        return chartTitle;
    }
    
    public String getChartData() {
        return chartData;
    }
    
    public BuccodecMetricGraphController()  {
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
        
        String query1 = BuccodecHelpers.query +
            'FROM ' +
                'M_E_Metric_Data__c ' +
            'WHERE ' +
                'M_E_Metric__r.Id = :metricId ';
                
        // Load all values for the given metric up to the current quarter
        M_E_Metric_Data__c[] items = database.query(query1);
        
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

            if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Sum' || 
                    item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Count') {

                if(item.Numerator__c != null){
                    actualVal = item.Numerator__c;
                }
            }
            else if(item.M_E_Metric__r.On_The_Fly_Calculation_Type__c == 'Percentage'){
                
                if(item.Numerator__c != null && item.Denumerator__c != null && item.Denumerator__c != 0) {
                    actualVal = ((item.Numerator__c / item.Denumerator__c) * 100).setScale(2);
                }
            }

            chdActual += actualVal + ',';
            actualCount++;
            
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
        if(chl.length() > 0) {
            chl = chl.substring(0, chl.length() -1);
        }
        
        // Set axis ranges and labels
        chds = absoluteMin + ',' + absoluteMax + ',' + absoluteMin + ',' + absoluteMax;
        chxr = '1,' + absoluteMin + ',' + absoluteMax;
         
        String result = '&chd=t:' + xProjected + '|' + chdProjected + '|' + xActual + '|' + chdActual +'&chdl=Target|Actual&chl=' + chl + '&chds=' + chds + '&chxr=' + chxr + '&chxt=x,y';
        
        //Prepare the chart URL
        String chartPath = 'http://chart.apis.google.com/chart?chs=600x200&cht=lxy&chco=00FF00,0000FF&chm=o,00FF00,0,-1,10|o,0000FF,1,-1,10|B,00FF0050,0,1.0,5.0|B,0000FF50,1,1.0,5.0&chls=3|3';
        chartData = chartPath +  result;
    }
}