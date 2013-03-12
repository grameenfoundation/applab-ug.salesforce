/**
 * Controller class that facilitates display of 
 * the NAADS ASP performance records
 */
public with sharing class NaadsAspPerformanceController {

    public List<PerformanceStats> performanceStats { get; set; }

    public NaadsAspPerformanceController() {
        showAspPerformance();
    }
    public List<PerformanceStats> showAspPerformance() {
        performanceStats = createAspPerformanceStats(getNaadsAspMetrics()).values();
        return performanceStats;
    }

    /**
     * Get a list of the Naads Metric data
     *
     *  @return - the list of the Naads metric data.
     */    
    public List<Naads_Advisory_Form_Metrics__c> getNaadsAspMetrics() {

        List<Naads_Advisory_Form_Metrics__c> naadsMetrics = [Select Person__c, 
                                                                    Person__r.First_Name__c, 
                                                                    Person__r.Last_Name__c, 
                                                                    Subcounty__c, Type__c, 
                                                                    Visit_Date__c 
                                                             From 
                                                                    Naads_Advisory_Form_Metrics__c 
                                                             order by 
                                                                    Person__c];                                                            
                                                             
        return naadsMetrics;
    }

    /**
     * Create a map of Naads ASPs with  
     * their Performance stats
     *
     *  @param naadsMetrics - A list of Naads Metric data
     *
     *  @return - A map of ASP with performance data
     */
    public Map<String, PerformanceStats> createAspPerformanceStats(List<Naads_Advisory_Form_Metrics__c> naadsMetrics) {
        Map<String, PerformanceStats> performanceMapStats = new Map<String, PerformanceStats>();
        String person = '';
        
        for (Naads_Advisory_Form_Metrics__c metric : naadsMetrics) {
            if ((String)metric.Person__c != person) {
                PerformanceStats performanceStats = new PerformanceStats(); 
                performanceStats.aspName = metric.Person__r.First_Name__c + ' ' + metric.Person__r.Last_Name__c;
                performanceStats = updatePerformance(performanceStats, metric);
                performanceMapStats.put((String)metric.Person__c, performanceStats);
                person = (String)metric.Person__c;
             }
             else if ((String)metric.Person__c == person){
                PerformanceStats performance = performanceMapStats.get(person);
                performance = updatePerformance(performance, metric);
                performanceMapStats.put(person, performance);               
             }
        }
        return performanceMapStats;
    }
    
    /**
     * Update the performance stats object based on 
     * the type of Naads metric supplied.
     *
     *  @param performance - The name of the metric required
     *  @param metric - Start date for the quarter
     *
     *  @return - the updated performance record.
     */
    private PerformanceStats updatePerformance(PerformanceStats performance, Naads_Advisory_Form_Metrics__c metric) {
    
        PerformanceStats performanceRecord = performance;
        if (metric.Type__c.equals('Farmer group training record')) {
            performanceRecord.groupTrainings++;
        }
        else if (metric.Type__c.equals('Service provider monthly visit schedule')) {
            performanceRecord.monthlyVisits++;
        }
        else if (metric.Type__c.equals('Supervisory visiting report')) {
            performanceRecord.supervisoryVisits++;
        }
        return performanceRecord;   
    }

    // Class to represent an individual ASP's performance
    class PerformanceStats {
        String aspName;
        Integer monthlyVisits;
        Integer groupTrainings;
        Integer supervisoryVisits;
        public PerformanceStats () {
            monthlyVisits = 0;
            groupTrainings = 0;
            supervisoryVisits = 0;
            aspName = '';
        }
        public String getAspName() {
            return aspName;
        }
        public Integer getMonthlyVisits() { 
            return monthlyVisits;
        }
        public Integer getGroupTrainings() {
            return groupTrainings;
        }
        public Integer getSupervisoryVisits() {
         return supervisoryVisits; 
        }        
    }
}