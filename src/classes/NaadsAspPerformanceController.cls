/**
 * Controller class that facilitates display of 
 * the NAADS ASP performance records
 */
public with sharing class NaadsAspPerformanceController {

    // A list of performance data stats by each ASP
    public List<PerformanceStats> performanceStats { get; set; }

    public NaadsAspPerformanceController() {
        showAspPerformance();
    }

    /**
     * Handles the display of ASP Performance data
     *
     */       
    public List<PerformanceStats> showAspPerformance() {
        performanceStats = createAspPerformanceStats(getNaadsAspMetrics()).values();
        return performanceStats;
    }

    /**
     * Get a list of the Naads Metric data
     *
     *  @return - the list of the Naads metric data.
     */    
    public List<Naads_Asp_Daily_Visit_Metric__c> getNaadsAspMetrics() {

        List<Naads_Asp_Daily_Visit_Metric__c> naadsMetrics = [Select Person__c, 
                                                                    Person__r.First_Name__c, 
                                                                    Person__r.Last_Name__c, 
                                                                    Subcounty__c,
                                                                    Visit_Date__c ,
                                                                    Supervisory_Visit_Count__c,
                                                                    Group_Trainings_Count__c,
                                                                    Monthly_Visit_Count__c
                                                             From 
                                                                    Naads_Asp_Daily_Visit_Metric__c
                                                             Order by
                                                                    Person__c
                                                             ];                                                         
                                                             
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
    public Map<String, PerformanceStats> createAspPerformanceStats(List<Naads_Asp_Daily_Visit_Metric__c> naadsMetrics) {
        Map<String, PerformanceStats> performanceMapStats = new Map<String, PerformanceStats>();
        String person = '';
        
        for (Naads_Asp_Daily_Visit_Metric__c metric : naadsMetrics) {
            if ((String)metric.Person__c != person) {
                PerformanceStats performanceStats = new PerformanceStats(); 
                performanceStats.aspName = metric.Person__r.First_Name__c + ' ' + metric.Person__r.Last_Name__c;
                performanceStats.monthlyVisits = metric.Monthly_Visit_Count__c;
                performanceStats.groupTrainings = metric.Group_Trainings_Count__c;
                performanceStats.supervisoryVisits = metric.Supervisory_Visit_Count__c;
                //performanceStats = updatePerformance(performanceStats, metric);
                performanceMapStats.put((String)metric.Person__c, performanceStats);
                person = (String)metric.Person__c;
                
             }
             else if ((String)metric.Person__c == person){
                PerformanceStats performance = performanceMapStats.get(person);
                performance.monthlyVisits += metric.Monthly_Visit_Count__c;
                performance.groupTrainings += metric.Group_Trainings_Count__c;
                performance.supervisoryVisits += metric.Supervisory_Visit_Count__c;
                //performance = updatePerformance(performance, metric);
                performanceMapStats.put(person, performance);               
             }
        }
        return performanceMapStats;
    }

    // Class to represent an individual ASP's performance
    class PerformanceStats {
        String aspName;
        Decimal monthlyVisits;
        Decimal groupTrainings;
        Decimal supervisoryVisits;
        public PerformanceStats () {
            monthlyVisits = 0;
            groupTrainings = 0;
            supervisoryVisits = 0;
            aspName = '';
        }
        public String getAspName() {
            return aspName;
        }
        public Decimal getMonthlyVisits() { 
            return monthlyVisits;
        }
        public Decimal getGroupTrainings() {
            return groupTrainings;
        }
        public Decimal getSupervisoryVisits() {
         return supervisoryVisits; 
        }        
    }
}