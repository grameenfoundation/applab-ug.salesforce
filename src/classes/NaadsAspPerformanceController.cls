/**
 * Controller class that facilitates display of 
 * the NAADS ASP performance records
 */
global with sharing class NaadsAspPerformanceController {

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
		performanceStats.sort();
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
        String subcounty = '';
        for (Naads_Asp_Daily_Visit_Metric__c metric : naadsMetrics) {
            if ((String)metric.Person__c != person) {
                PerformanceStats performanceStats = new PerformanceStats();
                performanceStats.subcounty = metric.Subcounty__c;
                performanceStats.aspName = metric.Person__r.First_Name__c + ' ' + metric.Person__r.Last_Name__c;
                performanceStats.monthlyVisits = metric.Monthly_Visit_Count__c;
                performanceStats.groupTrainings = metric.Group_Trainings_Count__c;
                performanceStats.supervisoryVisits = metric.Supervisory_Visit_Count__c;
                performanceMapStats.put((String)metric.Person__c, performanceStats);
                person = (String)metric.Person__c;
             }
             else if ((String)metric.Person__c == person){
                PerformanceStats performance = performanceMapStats.get(person);
                performance.monthlyVisits += metric.Monthly_Visit_Count__c;
                performance.groupTrainings += metric.Group_Trainings_Count__c;
                performance.supervisoryVisits += metric.Supervisory_Visit_Count__c;
                performanceMapStats.put(person, performance);      
             }
        }
        return performanceMapStats;
    }

    // Class to represent an individual ASP's performance
    global class PerformanceStats implements Comparable{
        String aspName;
        Decimal monthlyVisits;
        Decimal groupTrainings;
        Decimal supervisoryVisits;
        String subcounty;
        public PerformanceStats () {
            monthlyVisits = 0;
            groupTrainings = 0;
            supervisoryVisits = 0;
            aspName = '';
            subcounty = '';
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
        public String getSubcounty() {
            return subcounty;
        }

        // Implement the compareTo() method
        global Integer compareTo(Object compareTo) {
            PerformanceStats compareToEmp = (PerformanceStats)compareTo;
            if (subcounty == compareToEmp.subcounty) return 0;
            if (subcounty > compareToEmp.subcounty) return 1;
            return -1;        
        }     
    }
}