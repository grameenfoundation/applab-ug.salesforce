global with sharing class MetricSectionComponentController {

    private List<M_E_Metric__c> metrics;
    private List<MetricDataWrapper> metricDatas;
    private static M_E_Metric_Data__c loadMetricData;

    public String regionName { get; set; }
    public Id districtId { get; set; }
    public Id subcountyId { get; set; }
    public Date fromdate { get; set; }
    public Date todate { get; set; }
    public Id metricId { get; set; }
    public String tabName { get; set; }
    public Metric_Section__c thisSection { get; set; }

    public MetricSectionComponentController(){  
    }

    public List<M_E_Metric__c> getMetrics(){
        if(metrics == null) {
            metrics = [
                SELECT
                    Id,
                    Name, 
                    Label__c, 
                    Automated__c, 
                    Projected_Value__c,
                    Order__c, 
                    Is_Header__c, 
                    Is_On_Fly__c, 
                    Calculation_Type__c,
                    On_The_Fly_Calculation_Type__c, 
                    Subdivider__c ,
                    Sub_Area__c
                FROM 
                    M_E_Metric__c 
                WHERE 
                    Metric_Section__r.Id = :metricId AND
                    Not_For_Public__c = false
                ORDER BY Order__c
            ];
        }
        return metrics;
    }

    public List<MetricDataWrapper> getMetricDatas(){
        if(metricDatas == null) {
            if(thisSection == null){
                if(metricId != null) {
                    thisSection = [
                       SELECT
                            Name,
                            Allow_Update__c,
                            Is_Active__c,
                            Show_Targets__c,
                            Default_Show__c,
                            Show_Break_Down__c
                        FROM
                            Metric_Section__c
                        WHERE
                            Id = :metricId 
                    ];
                }
            }
            metricDatas = new List<MetricDataWrapper>();
            List<M_E_Metric__c> metrics =  getMetrics();
            for(M_E_Metric__c metric : metrics) {
                MetricDataWrapper data = new MetricDataWrapper();
                data.setLabel(metric.Label__c);
                data.isHeader = metric.Is_Header__c;
                data.setOnFly(metric.Is_On_Fly__c);
                data.setCalculation(metric.On_The_Fly_Calculation_Type__c);
                data.setCurrentTarget(String.valueOf(metric.Projected_Value__c));
                data.setOrderNumber(metric.Order__c);
                if(!metric.Is_Header__c){
                    String query = '';
                    //get values
                    if(metric.On_The_Fly_Calculation_Type__c == 'Count'){
                        query = 'SELECT M_E_Metric__c, Sum(Denumerator__c) realValue FROM M_E_Metric_Data__c WHERE Denumerator__c > 0 AND M_E_Metric__c = \'' + metric.Id + '\' ';
                    }
                    else if (metric.On_The_Fly_Calculation_Type__c == 'Sum'){
                        query = 'SELECT M_E_Metric__c, Sum(Denumerator__c) realValue FROM M_E_Metric_Data__c WHERE Denumerator__c > 0 AND M_E_Metric__c = \'' + metric.Id + '\' ';
                    }
                    else if (metric.On_The_Fly_Calculation_Type__c == 'Percentage'){
                        query = 'SELECT M_E_Metric__c, Sum(Denumerator__c) denumerator, Sum(Numerator__c) numerator FROM M_E_Metric_Data__c WHERE M_E_Metric__c = \'' + metric.Id + '\' ';
                    }
                    else if (metric.On_The_Fly_Calculation_Type__c == 'Average'){
                        query = 'SELECT M_E_Metric__c, Sum(Denumerator__c) denumerator, Sum(Numerator__c) numerator FROM M_E_Metric_Data__c WHERE M_E_Metric__c = \'' + metric.Id + '\' ';
                    }
                    else if(metric.Automated__c == 'False') {
                        query = 'SELECT Id, Manual_Value__c, Projected_Value__c FROM M_E_Metric_Data__c WHERE M_E_Metric__c = \'' + metric.Id + '\' ';
                    }
                    //build where clause
                    String whereClause = '';
                    List<String> clauses = new List<String>();
                    String subdivider = metric.Subdivider__c == 'District' && districtId != null ? ' District__c = \'' + districtId + '\' ' : '';
                    subdivider = metric.Subdivider__c == 'Subcounty' && subcountyId != null ? ' Subcounty__c = \'' + subcountyId + '\' ' : subdivider;
                    String dateRange = fromdate != null && todate != null ? ' Date__c >= ' + datetime.newInstance(fromdate.year(), fromdate.month(), fromdate.day()).format('yyyy-MM-dd') + ' AND Date__c <= ' + datetime.newInstance(todate.year(), todate.month(), todate.day()).format('yyyy-MM-dd') + ' ' : '';
                    String regionFilter = metric.Subdivider__c == 'District' && String.isNotEmpty(regionName) ? ' District__r.Name IN (' + MetricHelpers.generateCommaSeperatedString(FHISurveysHelpers.getDistrictsInRegion(regionName), true) + ') ' : '';
                    regionFilter = metric.Subdivider__c == 'Subcounty' && String.isNotEmpty(regionName) ? ' Subcounty__r.District__r.Name IN (' + MetricHelpers.generateCommaSeperatedString(FHISurveysHelpers.getDistrictsInRegion(regionName), true) + ') ' : regionFilter;
                    clauses.add(subdivider);
                    clauses.add(dateRange);
                    clauses.add(regionFilter);
                    whereClause = joinClauses(clauses);
                    whereClause = String.isNotBlank(whereClause) ? ' ' + whereClause : whereClause;
                    query = query.contains('Sum') || query.contains('Count') ? query + whereClause + ' GROUP BY M_E_Metric__c' : query;
                    System.debug(query);

                    Decimal value;
                    if (metric.On_The_Fly_Calculation_Type__c == 'Percentage' || metric.On_The_Fly_Calculation_Type__c == 'Average') {
                        List<AggregateResult> result = database.query(query);
                        value = result.size() > 0 ? (Decimal)result.get(0).get('denumerator') : 1;
                        Decimal value1 = result.size() > 0 ? (Decimal)result.get(0).get('numerator') : 0;
                        data.setCurrentDenumerator(value);
                        data.setCurrentNumerator(value1);
                    } 
                    else if (metric.On_The_Fly_Calculation_Type__c == 'Sum' || metric.On_The_Fly_Calculation_Type__c == 'Count') {
                        List<AggregateResult> result = database.query(query);
                        value = result.size() > 0 ? (Decimal)result.get(0).get('realValue') : 0;
                        value = value == null ? 0 : value;
                        data.setCurrentDenumerator(value);
                    }
                    else {
                        List<M_E_Metric_Data__c> result = database.query(query);
                        value = result.size() > 0 ? (Decimal)result.get(0).Manual_Value__c : 0;
                        Decimal value1 = result.size() > 0 ? (Decimal)result.get(0).Projected_Value__c : 0;
                        data.setCurrentRealValue(value);
                        data.setCurrentTarget(value1);
                        data.setCurrentId(String.valueOf(result.get(0).Id));
                    }
                    //set current total submissions
                    //this is the count of all submission made minus rejected ones
                    if(thisSection.Show_Break_Down__c){
                        String value1 = metric.Sub_Area__c;
                        value1 = value1 == null || value1.equalsIgnoreCase('Sub Area is not set') ? '' : value1;
                        data.setSubArea(value1);
                    }
                }
                metricDatas.add(data);
            }
        }
        return metricDatas;
    }

    @RemoteAction
    global static M_E_Metric_Data__c getMetricData(String id) {
        if(loadMetricData == null) {
            loadMetricData = loadMetricData(id);
        }
        return loadMetricData;
    }

    private static M_E_Metric_Data__c loadMetricData(String id) {

        return [SELECT
                Id,
                Name,
                Comment__c,
                Manual_Value__c,
                Actual_Value__c,
                Projected_Value__c,
                Date__c,
                Person__c,
                Person__r.District__c,
                District__c,
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Name,
                M_E_Metric__r.Propagate_Targets__c,
                M_E_Metric__r.Metric_Section__r.RollOver_Time__c
            FROM
                M_E_Metric_Data__c
            WHERE
                id = :id];
    }

    public String joinClauses(List<String> clauses){
        String joined = '';
        for(String clause : clauses){
            if(String.isNotEmpty(clause)){
                joined += ' AND ' + clause;
            }
        }
        return joined;
    }
}