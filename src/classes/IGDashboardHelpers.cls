/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This is a helper class for IG/NUSAF Dashboard page
 *	A better way to make sure the dashboard controller
 *	class is not clogged.
 *  Its test methods are in the IGDashboardTests class 
 **/
public class IGDashboardHelpers {
    
    public static final String IG_CBT_VISITS_POSTPROCESSING_METHOD = 'IG_CBT_VISITS';
    public static final String IG_PERSON_TYPE_NAME = 'IG/NUSAF';
    
    public static String getDistricts(String orgName) {
        String selectClause =
            'SELECT '           +
                'Name, '        +
                'Latitude__c, ' +
                'Longitude__c ' +
            'FROM '             +
                'District__c '  +
            'ORDER BY '         +
                'Name';
        return selectClause;
    }
    
    /*
    * returns a query that fetches all subcounties from a given organisation
    *
    * @param	organisation the org whose subcounties to return
    * @return query string
    */
    public static String getSubcounties(String organisation){
        return 'SELECT Id, '                    +
                    'Display_Name__c, '         +
                    'District__c '              +
                'FROM Subcounty__c '            +
                'WHERE District__c != NULL '    +
                    'AND  District__c != \'\' ' +
                'ORDER BY Display_Name__c ';
    }
    
    /*
    * Returns a query that fetches all Community Based Trainers 
    * These are CKWs of type IG/NUSAF
    *
    * @return - a query that fetches person objects
    */
    public static string getCommunityBasedTrainers(){
        return 'SELECT '                    +
                    'Id, '                  +
                    'First_Name__c, '       +
                    'Last_Name__c, '        +
                    'Type__c '              +
                'FROM '                     +
                    'Person__c '            +
                'WHERE '                    +
                    'Type__c = \'' + IG_PERSON_TYPE_NAME + '\' '    +
                'ORDER BY '                 +
                    'First_Name__c, Last_Name__c';
                    
    }
    
    /*
    * Gets the total number of field visits made including targets
    * where targets are available, they will be summed up
    * @params - filters for the field visits made
    * @return - A metric data wrapper object with the aggregate data
    */
    public static MetricDataWrapper getTotalNumberOfFieldVisitsMetric(String region, String district, String subcounty, String dateFrom, String dateTo, Id cbt){
        MetricDataWrapper metric = new MetricDataWrapper();
        metric.setLabel('Total Number of field visits');
        
        //set the actual value
        String query = 'SELECT '                                        +
                            'Count(Id) '                                +
                        'FROM '                                         +
                            'Community_Based_Trainer_Field_Visit__c '   +
                        'WHERE '                                        +
                            'Name_of_Trainer__c != NULL ';
        query += String.isNotEmpty(region)? ' AND Subregion__c = \'' + region + '\' ': '';
        query += String.isNotEmpty(district)? ' AND District__r.Name = \'' + district + '\' ': '';
        query += String.isNotEmpty(district)? ' AND Subcounty__r.Display_Name__c = \'' + subcounty + '\' ': '';
        query += (String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo))? ' AND (Date_of_Visit__c >= ' + dateFrom + ' AND Date_of_Visit__c <= ' +dateTo + ') ': '';
        query += cbt != null? ' AND Person__r.Id = \'' + cbt + '\' ': '';
        
        List<AggregateResult> result = database.query(query);
        metric.setCurrentRealValue((Decimal)result[0].get('expr0'));
        
        String surveys = 'SELECT '                                                  +
                                'Id '                                               +
                            'FROM '                                                 +
                                'Survey__c '                                        +
                            'WHERE '                                                +
                                'Post_Processing_Method__c = \'' + IG_CBT_VISITS_POSTPROCESSING_METHOD + '\' ';
        surveys += (String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo))? 
                            ' (AND Start_Date__c <= ' + dateFrom + ' AND End_Date__c >= ' + dateTo + ') ': '';
        
        //set the target
        String targets_query = 'SELECT '                                                                                        +
                                    'Sum(Target_Value__c) '                                                                     +
                                'FROM '                                                                                         +
                                    'Community_Based_Trainer_Target__c '                                                        +
                                'WHERE '                                                                                        +
                                    'Survey__r.Post_Processing_Method__c = \'' + IG_CBT_VISITS_POSTPROCESSING_METHOD + '\' ';
        targets_query += (String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo))? 
                                    ' AND (Survey__r.Start_Date__c <= ' + dateFrom + ' AND Survey__r.End_Date__c >= ' + dateTo + ')': '';
        targets_query += cbt != null? ' AND Person__r.Id = \'' + cbt + '\' ': '';
        
        List<AggregateResult> result1 = database.query(targets_query);
        metric.setCurrentTarget((Decimal)result1[0].get('expr0'));
        
        return metric;
    }
    
    /*
    * returns a query that gets all field visits based on provided filters
    *
    * @params - filters for the field visits made
    * @return - a query returning field visits for given filters
    */
    public static String getFieldVisitDetails(String region, String district, String subcounty, String dateFrom, String dateTo, Id cbt){
        String query = 'SELECT '                                    +
                          'Id, '                                    +
                          'District__r.Name, '                      +
                          'Subcounty__r.Display_Name__c, '          +
                          'Subregion__c, '                          +
                          'Date_of_Visit__c, '                      +
                          'Interview_Latitude__c, '                 +
                          'Interview_Longitude__c, '                +
                          'Type_of_Visit__c, '                      +
                          'Name_of_Trainer__c '                     +
                        'FROM '                                     +
                          'Community_Based_Trainer_Field_Visit__c ' +
                        'WHERE '                                    +
                            'Name_of_Trainer__c != NULL ';
        query += String.isNotEmpty(region)? ' AND Subregion__c = \'' + region + '\' ': '';
        query += String.isNotEmpty(district)? ' AND District__r.Name = \'' + district + '\' ': '';
        query += String.isNotEmpty(district)? ' AND Subcounty__r.Display_Name__c = \'' + subcounty + '\' ': '';
        query += (String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo))? ' AND (Date_of_Visit__c >= ' + dateFrom + ' AND Date_of_Visit__c <= ' +dateTo + ') ': '';
        query += cbt != null? ' AND Person__r.Id = \'' + cbt + '\' ': '';
        return query;
    }
    
    /*
    * This method is called by our map api to provide markers for plotting
    * on the GIS maps.
    * For every field visit from the filters provided, a marker is created 
    * with that visit's co-ordinates plus a few descriptive details
    *
    * @params - filters for the visits
    * @return - an array of markers 
    */
    public static MetricMapWrapper[] getFieldVisitsMapMarkers(String region, String district, String subcounty, String dateFrom, String dateTo, Id cbt){
        Community_Based_Trainer_Field_Visit__c[] visits = database.query(IGDashboardHelpers.getFieldVisitDetails(region, district, subcounty, dateFrom, dateTo, cbt));      
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        if (visits.size() == 0) {
            return markers.values();
        }

        for (Community_Based_Trainer_Field_Visit__c visit : visits) {
            // Dont include if we are missing the location
            if (!String.isNotEmpty(visit.Interview_Latitude__c) || !String.isNotEmpty(visit.Interview_Longitude__c)) {
                continue;
            }
            String name = String.valueOf(visit.Date_of_Visit__c);
          
            MetricMapWrapper marker = null;
            marker = new MetricMapWrapper('CBTFieldVisit', 'FFD801', visit.Id, true);
            marker.gpsLatitude = visit.Interview_Latitude__c;
            marker.gpsLongitude = visit.Interview_Longitude__c;
             
            String content =    '<div>'                                                                 +
                                    'Visit Details<br/>'                                                +
                                    'Date:       ' + String.valueOf(visit.Date_of_Visit__c) + '<br/>'   +
                                    'Trainer:    ' + visit.Name_of_Trainer__c + '<br/>'                 +
                                    'Visit Type: ' + visit.Type_of_Visit__c + '<br/>';
            
            marker.addName(content);
            marker.markerTitle = name;
            markers.put(visit.Id, marker);
        }
        // Tidy up the created lists so to keep the heap size down.
        visits.clear();
        return markers.values();
    }
    
    /*
    * returns a query that gets surveys for the various IG/NUSAF activities to monitor
    * All shuch surveys have the same post-processing method
    * 
    * @params - filters for the field visits made
    * @return - a query that fetches survey objects
    */
    public static String getActivities(){
        return 	'SELECT '                   +
                    'Id, '                  +
                    'Survey_Name__c '       +
                'FROM '                     +
                    'Survey__c '            +
                'WHERE '                    +
                    'Post_Processing_Method__c = \'' + IG_CBT_VISITS_POSTPROCESSING_METHOD + '\''; 
    }
    
    public static String getCurrentTargets(Id survey){
        return  'SELECT '                                   +
                    'Id, '                                  +
                    'Survey__c, '                           +
                    'Person__c, '                           +
                    'Target_Value__c '                      +
                'FROM '                                     +
                    'Community_Based_Trainer_Target__c '    +
                'WHERE '                                    +
                    'Survey__c = \'' + survey + '\'';
    }
    
    /*
    * Creates a new target for every CBT for a given activity(survey)
    *
    * @param -	the survey whose target we are setting
    * @param -	the target value
    */
    public static void setNewTargetsForAll(Id survey, Decimal targetValue){
        List<Community_Based_Trainer_Target__c> newTargets = new List<Community_Based_Trainer_Target__c>();
        for(Person__c[] cbts : [SELECT Id FROM Person__c WHERE Type__c = :IG_PERSON_TYPE_NAME]){
            for(Person__c cbt : cbts){
                Community_Based_Trainer_Target__c newTarget = new Community_Based_Trainer_Target__c();
                newTarget.Survey__c = survey;
                newTarget.Person__c = cbt.Id;
                newTarget.Target_Value__c = targetValue;
                newTargets.add(newTarget);
            }
        }
        insert newTargets;
    }
    
    /*
    * Creates a new target for one CBT for a given activity(survey)
    *
    * @param -	the survey whose target we are setting
    * @param -	the target value
    * @param -	the CBT's Id whose target is being set
    */
    public static void setNewTargetForCBT(Id survey, Decimal targetValue, Id cbt){
        Community_Based_Trainer_Target__c newTarget = new Community_Based_Trainer_Target__c();
        newTarget.Survey__c = survey;
        newTarget.Person__c = cbt;
        newTarget.Target_Value__c = targetValue;
    
        insert newTarget;
    }
    
    /*
    * Searches through a list of targets and returns a target that belongs
    * to a specified person
    *
    * @param  -	Id of a person__c whose target we are searching for
    * @param  -	List of targets we are searching from
    * @return -	Target found or null if nothing found	
    */
    public static Community_Based_Trainer_Target__c getTarget(Id cbt, List<Community_Based_Trainer_Target__c> currentTargets){
        for(Community_Based_Trainer_Target__c target : currentTargets){
            if(target.Person__c == cbt){
                return target;
            }
        }
        return null;
    }
    
    /*
    * Gets the sum of field visits made per CBT using the parameters passed as filters.
    * It also sums up targets values available, they will be summed up
    * @params - filters for the field visits made
    * @return - A metric data wrapper object with the aggregate data
    */
    public static List<IGDashboardHelpers.Data> getBarGraphFieldVisitsMetrics(Survey__c survey, String region, String district, String subcounty, String dateFrom, String dateTo, Id cbt){
        List<IGDashboardHelpers.Data> metrics = new List<IGDashboardHelpers.Data>();
        IGDashboardHelpers.Data metric;
        //MetricDataWrapper metricTarget;
        
        String query =  'SELECT '                                       +
                            'Person__r.Id, '                            +
                            'Person__r.First_Name__c, '                 +
                            'Person__r.Last_Name__c, '                  +
                            'Count(Id) realValue '                      +
                        'FROM '                                         +
                            'Community_Based_Trainer_Field_Visit__c '   +
                        'WHERE '                                        +
                            'Survey__r.Id = \'' + survey.Id + '\' ';
        query += String.isNotEmpty(region)? ' AND Subregion__c = \'' + region + '\' ': '';
        query += String.isNotEmpty(district)? ' AND District__r.Name = \'' + district + '\' ': '';
        query += String.isNotEmpty(district)? ' AND Subcounty__r.Display_Name__c = \'' + subcounty + '\' ': '';
        query += (String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo))? ' AND (Date_of_Visit__c >= ' + dateFrom + ' AND Date_of_Visit__c <= ' +dateTo + ') ': '';
        query += cbt != null? ' AND Person__r.Id = \'' + cbt + '\' ': '';
        query +=        ' GROUP BY Person__r.Id, Person__r.First_Name__c, Person__r.Last_Name__c ';
        
        List<AggregateResult> results = database.query(query);
        for(AggregateResult result : results){
            //FETCH target (only one value should be available)
            String targets_query = 'SELECT '                                                        +
                                        'Sum(Target_Value__c) '                                     +
                                    'FROM '                                                         +
                                        'Community_Based_Trainer_Target__c '                        +
                                    'WHERE '                                                        +
                                        'Survey__r.Id = \'' + survey.Id + '\' '                     +
                                        'AND Person__r.Id = \'' + result.get('Id') + '\' ';
            List<AggregateResult> targetResult = database.query(targets_query);
            metric = new IGDashboardHelpers.Data(survey.Survey_Name__c, result.get('First_Name__c') + ' ' + result.get('Last_Name__c'), (Decimal)result.get('realValue'), (Decimal)targetResult[0].get('expr0') == null? 0:(Decimal)targetResult[0].get('expr0'), URL.getSalesforceBaseUrl().toExternalForm() + '/' + survey.id);
            metrics.add(metric);
        }
        return metrics;
    }
    
    /*
    * A class that carries data reflecting chart points
    */
    public class Data{
        public String name { get; set; }
        public String label { get; set; }
        public Decimal Actual_Submissions { get; set; }
        public Decimal Target_Submissions { get; set; }
        public String location { get; set; }
        public Data(String name, String label, Decimal data1, Decimal data2, String location){
            this.name = name;
            this.label = label;
            this.Actual_Submissions = data1;
            this.Target_Submissions = data2;
            this.location = location;
        }
    }
}