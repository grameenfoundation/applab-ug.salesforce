/**
 * Controller class that facilitates display of 
 * the NAADS ASP performance records
 */
global with sharing class AaspPerformanceController {

    public List<PerformanceStats> getPerformanceStats() {
        endDate = getEndDate(selectedDate);
        startDate = endDate.toStartOfMonth();
        List<PerformanceStats> performanceStats = createAspPerformanceStats(getNaadsAspMetrics()).values();
        performanceStats.sort();
        return performanceStats;
    }
    public PageReference getDisplayDate() {
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }

    private Date getEndDate(String dateString) {
    
        if (dateString == null) {
            return date.today();
        }
        String month = dateString.substring(0,3);
        String year = dateString.substring(4);
        String endDate = '30';
        String mth = '1';
        String yr = '2013';
        
        if (month.equals('Jan')) {
            mth = '1';
            endDate = '31';
        }
        else if (month.equals('Feb')) {
            mth = '2';
            if (Date.isLeapYear((Integer.valueOf(year)))) {
                endDate = '29';
            }
            else {
                endDate = '28';
            }
        }
        else if (month.equals('Mar')) {
            mth = '3';
            endDate = '31';
        }
        else if (month.equals('Apr')) {
            mth = '4';
            endDate = '30';
        }
        else if (month.equals('May')) {
            mth = '5';
            endDate = '31';
        }
        else if (month.equals('Jun')) {
            mth = '6';
            endDate = '30';
        }
        else if (month.equals('Jul')) {
            mth = '7';
            endDate = '31';
        }
        else if (month.equals('Aug')) {
            mth = '8';
            endDate = '31';
        }
        else if (month.equals('Sep')) {
            mth = '9';
            endDate = '30';
        }
        else if (month.equals('Oct')) {
            mth = '10';
            endDate = '31';
        }
        else if (month.equals('Nov')) {
            mth = '11';
            endDate = '30';
        }
        else if (month.equals('Dec')) {
            mth = '12';
            endDate = '31';
        }
        return date.parse(mth + '/' + endDate + '/'+yr);
    }
 
    public String selectedDate { get; set; }
    private Date endDate = date.today();
    private Date startDate = date.today();

    public List<SelectOption> getLoadDateOptions() {

        Date collectionStartDate = date.parse('12/13/2012');
        List<SelectOption> options = new List<SelectOption>();
        Date startDate = MetricHelpers.getRollOverStartDate(collectionStartDate, 'Monthly');
        Date endDate = MetricHelpers.getRollOverEndDate(Date.today(), 'Monthly');
        while (startDate.daysBetween(endDate) >= 0) {
            String optionString = MetricHelpers.createDispRollOverString(startDate, 'Monthly');
            options.add(new SelectOption(optionString, optionString));
            startDate = MetricHelpers.increaseDateRollOver(startDate, 'Monthly');
        }
        return options;
    }
    

    /**
     * Handles the display of ASP Performance data
     *
     */       
    /**public List<PerformanceStats> showAspPerformance() {
        performanceStats = createAspPerformanceStats(getNaadsAspMetrics()).values();
        performanceStats.sort();
        return performanceStats;
    }**/

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
                                                             Where
                                                                    Visit_Date__c <=:endDate
                                                             And
                                                                    Visit_Date__c >=:startDate
                                                             Order by
                                                                    Person__c
                                                             ];
        System.debug('We have '+naadsMetrics.size() + ' visit metrics.');                                                       
                                                             
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
        for (Naads_Asp_Daily_Visit_Metric__c metric : naadsMetrics) {System.debug('value '+metric.Person__r.First_Name__c + ' on ' + metric.Visit_Date__c);
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
        System.debug('performance stats map size is ' + performanceMapStats.size());
        return performanceMapStats;
    }

    // Class to represent an individual ASP's performance
    global class PerformanceStats implements Comparable {
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