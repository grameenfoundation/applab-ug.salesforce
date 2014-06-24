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
    public static final String IG_PERSON_TYPE_NAME = 'IG/NUSAF';
    public static final String REGIONAL_MANAGER = 'IG/NUSAF Regional Manager';
       
       /**
        * IG has regions differing from ours, this query returns
        * IG regions registered
        */
    public static String getIGRegions() {
        String selectClause =
            'SELECT '               +
                'Id, '              +
                'Name '             +
            'FROM '                 +
                'IG_Region__c '     +
            'ORDER BY '             +
                'Name';
        return selectClause;
    }

    /**
     * @param region    the region whose districts to get: if empty returns all
     * @return a string query that fetches desired districts
     */
    public static String getDistricts(String region) {
        String selectClause =
            'SELECT '                                   +
                'District__r.Name, '                    +
                'District__r.Latitude__c, '             +
                'District__r.Longitude__c '             +
            'FROM '                                     +
                'IG_Region_District_Association__c ';

        String whereClause =
            'WHERE '                                    +
                'IG_Region__r.Id = \'' + region + '\' ';
        String orderByClause =
            'ORDER BY '                                 +
                'District__r.Name ';

        selectClause = String.isEmpty(region) ? selectClause + orderByClause : selectClause + whereClause + orderByClause;
        return selectClause;
    }
    
    /*
    * returns a query that fetches all subcounties from a given district
    *
    * @param	district the org whose subcounties to return
    * @return query string
    */
    public static String getSubcounties(String district){
        String selectClause = 
                'SELECT '                           + 
                    'Id, '                          +
                    'Display_Name__c, '             +
                    'District__c '                  +
                'FROM '                             +
                    'Subcounty__c ';
        String whereClause =
                'WHERE '                            +
                    'District__r.Id = \'' + district + '\' ';
        String orderByClause =
                'ORDER BY '                         +
                    'Display_Name__c ';
        selectClause = String.isEmpty(district) ? selectClause + orderByClause : selectClause + whereClause + orderByClause;
        return selectClause;
    }
    
    /*
    * Returns a query that fetches all Community Based Trainers in a given subcounty 
    * These are Persons of type IG/NUSAF attached to target objects of this subcounty
    *
    * @return - a query that fetches person objects
    */
    public static string getCommunityBasedTrainers(String districtId, String subcounty){
        String selectClause = 
                'SELECT '                               +
                    'Id, '                              +
                    'Person__r.Id, '                    +
                    'Person__r.First_Name__c, '         +
                    'Person__r.Last_Name__c, '          +
                    'Person__r.Type__c '                +
                'FROM '                                 +
                    'IG_Subproject_Target__c '          +
                'WHERE '                                +
                    'Person__c != NULL ';
        String whereClause = 
                    'AND District__r.Id = \'' + districtId + '\' ';
        String whereClause2 = 
                    'AND Subcounty__r.Id = \'' + subcounty + '\' ';
        String orderByClause =
                'ORDER BY '                             +
                    'Person__r.First_Name__c, Person__r.Last_Name__c';

        selectClause = String.isEmpty(districtId) ? selectClause : selectClause + whereClause;
        selectClause = String.isEmpty(subcounty) ? selectClause : selectClause + whereClause2;
        return selectClause + orderByClause;           
    }    
    
    /*
    * returns a query that gets all field visits based on provided filters
    *
    * @params - filters for the field visits made
    * @return - a query returning field visits for given filters
    */
    public static String getFieldVisitDetails(String region, String district, String subcounty, String dateFrom, String dateTo, String cbt){
        //if a regional manager is logged in, override
        //we convert from region Id to name due to karamoja 
        IG_Region__c userRegion = getUserRegion();
        userRegion = (userRegion == null && String.isNotEmpty(region)) ? [SELECT Id, Name FROM IG_Region__c WHERE Id = :region] : null;
        String subregion = (userRegion != null && userRegion.Name.containsIgnoreCase('karamoja')) ? '%KARAMOJA%' : '';
        subregion = (subregion == null && userRegion != null) ? userRegion.Name : null;
        String query = 
                'SELECT '                                               +
                    'Id, '                                              +
                    'Name, '                                            +
                    'Person__r.Id, '                                    +
                    'Person__r.First_Name__c, '                         +
                    'Person__r.Last_Name__c, '                          +
                    'DatePreliminaryTrainingDay1__c, '                  +
                    'DatePreliminaryTrainingDay2__c, '                  +
                    'DatePreliminaryTrainingDay3__c, '                  +
                    'DateFollowupVisit1__c, '                           +
                    'DateFollowupVisit2__c, '                           +
                    'DateFollowupVisit3__c, '                           +
                    'LocationMobilization__c, '                         +
                    'DateMobilization__c, '                             +
                    'IG_Region__r.Name '                                +
                'FROM '                                                 +
                    'IG_Subproject_Target__c '                          +
                'WHERE '                                                +
                    'Person__c != NULL '                                +
                    'AND LocationMobilization__c != NULL ';
        query = !String.isNotBlank(subregion) ? query : query + 
                    'AND IG_Region__r.Name LIKE \'' + subregion + '\' ';
        query = !String.isNotBlank(district) ? query : query + 
                    'AND District__r.Id = \'' + district + '\' ';
        query = !String.isNotBlank(subcounty) ? query : query + 
                    'AND Subcounty__r.Id = \'' + subcounty + '\' ';
        query = !String.isNotBlank(cbt) ? query : query + 
                    'AND Person__r.Id = \'' + cbt + '\' ';
        //note that karamoja regions are fused here since they view eachothers data (due to one login)
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
    public static MetricMapWrapper[] getFieldVisitsMapMarkers(String region, String district, String subcounty, String dateFrom, String dateTo, String cbt){
        IG_Subproject_Target__c[] visits = database.query(IGDashboardHelpers.getFieldVisitDetails(region, district, subcounty, dateFrom, dateTo, cbt));

        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        if (visits.size() == 0) {
            return markers.values();
        }

        for (IG_Subproject_Target__c visit : visits) {
            // Dont include if we are missing the location
            if (String.isEmpty(visit.LocationMobilization__c)) {
                continue;
            }
            String name = String.valueOf(visit.Name);
          
            MetricMapWrapper marker = null;
            if(visit.IG_Region__r.Name.containsIgnoreCase('acholi')){
                marker = new MetricMapWrapper('CBTFieldVisit', '606060', visit.Id, true);//blackish
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('bukedi')){
                marker = new MetricMapWrapper('CBTFieldVisit', 'A00000 ', visit.Id, true);//reddish
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('elgon')){
                marker = new MetricMapWrapper('CBTFieldVisit', '33CC00', visit.Id, true);//greenish
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('south karamoja')){
                marker = new MetricMapWrapper('CBTFieldVisit', '0000FF', visit.Id, true);//blue
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('north karamoja')){
                marker = new MetricMapWrapper('CBTFieldVisit', 'FFFF00', visit.Id, true);//yellow
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('lango')){
                marker = new MetricMapWrapper('CBTFieldVisit', 'FF00FF', visit.Id, true);//pinkish
            }
            else if(visit.IG_Region__r.Name.containsIgnoreCase('west nile')){
                marker = new MetricMapWrapper('CBTFieldVisit', 'FFFFFF', visit.Id, true);//white
            }
            else {
                marker = new MetricMapWrapper('CBTFieldVisit', 'FFA500', visit.Id, true);//orange                
            }
            marker.gpsLatitude = visit.LocationMobilization__c.split(' ')[0];
            marker.gpsLongitude = visit.LocationMobilization__c.split(' ')[1];
             
            String content =    '<div style="min-width:200px;min-height:150px">' +
                                    'Name:    ' + visit.Name + '<br/>' +
                                    'Trainer:    ' + visit.Person__r.First_Name__c + ' ' + visit.Person__r.Last_Name__c + '<br/>' +
                                    'Enrollment:       ' + String.valueOf(visit.DateMobilization__c) + '<br/>';
            if(visit.DatePreliminaryTrainingDay1__c != null){
                content += 'Training Day1:       ' + String.valueOf(visit.DatePreliminaryTrainingDay1__c) + '<br/>';
            }
            if(visit.DatePreliminaryTrainingDay2__c != null){
                content += 'Training Day2:       ' + String.valueOf(visit.DatePreliminaryTrainingDay2__c) + '<br/>';
            }            
            if(visit.DatePreliminaryTrainingDay3__c != null){
                content += 'Training Day3:       ' + String.valueOf(visit.DatePreliminaryTrainingDay3__c) + '<br/>';
            }
            if(visit.DateFollowupVisit1__c != null){
                content += 'Followup Visit 1:       ' + String.valueOf(visit.DateFollowupVisit1__c) + '<br/>';
            } 
            if(visit.DateFollowupVisit2__c != null){
                content += 'Followup Visit 2:       ' + String.valueOf(visit.DateFollowupVisit2__c) + '<br/>';
            } 
            if(visit.DateFollowupVisit3__c != null){
                content += 'Followup Visit 3:       ' + String.valueOf(visit.DateFollowupVisit3__c) + '<br/>';
            } 

            marker.addName(content);
            marker.markerTitle = name;
            markers.put(visit.Id, marker);
        }
        // Tidy up the created lists so to keep the heap size down.
        visits.clear();
        return markers.values();
    }    

    public static IG_Region__c getUserRegion(){
        String lName = userinfo.getLastName();
        //TODO: way forward on combining karamoja
        IG_Region__c[] region = [SELECT Id, Name from IG_Region__c WHERE Name LIKE :'%'+lName + '%' LIMIT 1];
        if(region.isEmpty()){
            return null;
        }
        return  region[0];
    }

    public static List<Data> getMetricsForRegion(String subregion, String district, String subcounty, String dateFrom, String dateTo, Id cbt){
        String subregionId = '\'' + subregion + '\'';
        Map<String, Data> data = new Map<String, Data>();
        IG_Region__c regionthis = IGDashboardHelpers.getUserRegion();
        //if we cant find the users region, lets try what was passed through
        regionthis = (regionthis == null && String.isNotBlank(subregion)) ? [SELECT Id, Name FROM IG_Region__c where Id = :subregion ] : regionthis;
        subregion = regionthis != null ? regionthis.Name : subregion;
        subregion = (subregion != null && subregion.containsIgnoreCase('karamoja')) ? '%KARAMOJA%' : subregion;
        String selectClause = 
            'SELECT '                                       +
                'DateMobilization__c,'                      +
                'DateFollowupVisit1__c,'                    +
                'DateFollowupVisit2__c,'                    +
                'DateFollowupVisit3__c,'                    +
                'DatePreliminaryTrainingDay1__c,'           +
                'DatePreliminaryTrainingDay2__c,'           +
                'DatePreliminaryTrainingDay3__c,'           +
                'IG_Region__c,'                             +
                'IG_Region__r.Name,'                        +
                'District__c,'                              +
                'Subcounty__c,'                             +
                'Person__c,'                                +
                'Person__r.First_Name__c,'                  +
                'Person__r.Last_Name__c '                   +
            'FROM '                                         +
                'IG_Subproject_Target__c '                  +
            'WHERE '                                        +
                'Person__c != NULL ';
                selectClause += String.isEmpty(subregion) ? '' : 
                'AND IG_Region__r.Name LIKE \'' + subregion + '\' ';
                selectClause += String.isEmpty(district) ? '' : 
                'AND District__r.Id = \'' + district + '\' ';
                selectClause += String.isEmpty(subcounty) ? '' : 
                'AND Subcounty__r.Id = \'' + subcounty + '\' ';
                selectClause += String.isEmpty(cbt) ? '' : 
                'AND Person__r.Id = \'' + cbt + '\' ';
        System.debug(LoggingLevel.WARN, selectClause);
        IG_Subproject_Target__c[] targets = database.query(selectClause);
        for(IG_Subproject_Target__c target : targets){
            Id regionId = target.IG_Region__c;
            Data datum = data.get(String.valueOf(regionId));
            if(datum == null){
                String name = target.IG_Region__r.Name;
                datum = new Data(String.valueOf(target.IG_Region__r.Id), name, '','','','');
            }
            //we keep this count for use in counting total targets
            datum.count = datum.count + 1;
            //mobilzation
            if(target.DateMobilization__c != null){
                datum.mobilization_count = datum.mobilization_count + 1;
            }
            //preliminary training
            if(target.DatePreliminaryTrainingDay1__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            if(target.DatePreliminaryTrainingDay2__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            if(target.DatePreliminaryTrainingDay3__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            //followups
            if(target.DateFollowupVisit1__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            if(target.DateFollowupVisit2__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            if(target.DateFollowupVisit3__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            double current_completion = 0;
            //average completion is count of submissions done in relation to expected submissions
            //having in mind that we expect 1 mobilzation, 3 trainings and 3 followups (i.e. 7 submissions) for 1 subproject 
            current_completion = ((datum.mobilization_count + datum.preliminary_count + datum.followup_visits_count) /
                (datum.count * 1 + datum.count * 3 + datum.count * 3)) * 100;
            datum.completion = current_completion.round();

            data.put(String.valueOf(regionId), datum);
        }
        return data.values();
    }

    public static List<Data> getIndividualMetrics(Boolean isRegionalManager, String subregion, String districtName, String subcountyDisplayName, String dateFrom, String dateTo, Id cbt){
        Map<String, Data> data = new Map<String, Data>();
        //turn subregion id to region name and check if its karamoja
        String regionname = '';
        if(isRegionalManager){
            IG_Region__c regionthis = IGDashboardHelpers.getUserRegion();
            regionname = regionthis != null ? regionthis.Name : '';
            regionname = regionname.containsIgnoreCase('KARAMOJA') ? '%KARAMOJA%' : regionname;
        }
        else {
            IG_Region__c regionthis = String.isEmpty(subregion) ? null : [SELECT Id, Name FROM IG_Region__c WHERE Id = :subregion];
            regionname = regionthis == null ? '' : regionthis.Name;
        }

        String selectClause = 
            'SELECT '                                       +
                'DateMobilization__c,'                      +
                'DateFollowupVisit1__c,'                    +
                'DateFollowupVisit2__c,'                    +
                'DateFollowupVisit3__c,'                    +
                'DatePreliminaryTrainingDay1__c,'           +
                'DatePreliminaryTrainingDay2__c,'           +
                'DatePreliminaryTrainingDay3__c,'           +
                'IG_Region__c,'                             +
                'District__c,'                              +
                'Subcounty__c,'                             +
                'Person__c,'                                +
                'Person__r.First_Name__c,'                  +
                'Person__r.Last_Name__c '                   +
            'FROM '                                         +
                'IG_Subproject_Target__c '                  +
            'WHERE '                                        +
                'Person__c != NULL ';
                selectClause += String.isEmpty(regionname) ? '' : 
                'AND IG_Region__r.Name LIKE \'' + regionname + '\' ';
                selectClause += String.isEmpty(districtName) ? '' : 
                'AND District__r.Name = \'' + districtName + '\' ';
                selectClause += String.isEmpty(subcountyDisplayName) ? '' : 
                'AND Subcounty__r.Display_Name__c = \'' + subcountyDisplayName + '\' ';
                selectClause += String.isEmpty(cbt) ? '' : 
                'AND Person__r.Id = \'' + cbt + '\' ';
        System.debug(LoggingLevel.WARN, selectClause);
        IG_Subproject_Target__c[] targets = database.query(selectClause);
        for(IG_Subproject_Target__c target : targets){
            Id person = target.Person__c;
            Data datum = data.get(String.valueOf(person));
            if(datum == null){
                String name = target.Person__r.First_Name__c + ' ' + target.Person__r.Last_Name__c;
                datum = new Data(String.valueOf(target.Person__r.Id), name, '','','','');
            }
            //we keep this count for use in counting total targets
            datum.count = datum.count + 1;
            //mobilzation
            if(target.DateMobilization__c != null){
                datum.mobilization_count = datum.mobilization_count + 1;
            }
            //preliminary training
            if(target.DatePreliminaryTrainingDay1__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            if(target.DatePreliminaryTrainingDay2__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            if(target.DatePreliminaryTrainingDay3__c != null){
                datum.preliminary_count = datum.preliminary_count + 1;
            }
            //followups
            if(target.DateFollowupVisit1__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            if(target.DateFollowupVisit2__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            if(target.DateFollowupVisit3__c != null){
                datum.followup_visits_count = datum.followup_visits_count + 1;
            }
            double current_completion = 0;
            //average completion is count of submissions done in relation to expected submissions
            //having in mind that we expect 1 mobilzation, 3 trainings and 3 followups (i.e. 7 submissions) for 1 subproject 
            current_completion = ((datum.mobilization_count + datum.preliminary_count + datum.followup_visits_count) /
                (datum.count * 1 + datum.count * 3 + datum.count * 3)) * 100;
            datum.completion = current_completion.round();

            data.put(String.valueOf(person), datum);
        }
        return data.values();
    }
    
    /*
    * A class that carries dashboard metrics data
    */
    public class Data{
        public String name { get; set; }
        public String label { get; set; }
        public String mobilization { get; set; }
        public String preliminary { get; set; }
        public String followup_visits{ get; set; }
        public String percentage_completion{ get; set; }

        public Integer count { get; set; }
        public Integer mobilization_count { get; set; }
        public Integer preliminary_count { get; set; }
        public Integer followup_visits_count { get; set; }
        public double completion { get; set; }

        public Data(String name, String label, String mobilization, String preliminary, String followup_visits, String percentage_completion){
            this.name = name;
            this.label = label;
            this.mobilization = mobilization;
            this.preliminary = preliminary;
            this.followup_visits = followup_visits;
            this.percentage_completion = percentage_completion;
            count = 0;
            mobilization_count = 0;
            preliminary_count = 0;
            followup_visits_count = 0;
            completion = 0.0;
        }
    }
}