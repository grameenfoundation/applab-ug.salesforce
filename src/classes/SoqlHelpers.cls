public class SoqlHelpers {

    /**
     *  Helper class that builds generic SOQL.
     *  Calling methods should run the query.
     */
    public static String getCkws(Map<String, String> variables, Boolean ignorePersonList) {

        // Build the query to get the CKW details
        String selectClause = 'SELECT '                                              +
                'Name, '                                                             +
                'Status__c, '                                                        +
                'Active_Date__c, '                                                   +
                'Poverty_Status__c, '                                                +
                'Person__c, '                                                        +
                'Person__r.Gender__c, '                                              +
                'Person__r.First_Name__c, '                                          +
                'Person__r.Middle_Name__c, '                                         +
                'Person__r.Last_Name__c, '                                           +
                'Person__r.GPS_Location_N__c, '                                      +
                'Person__r.GPS_Location_E__c, '                                      +
                'Person__r.Village__c, '                                             +
                'Person__r.Parish__c, '                                              +
                'Person__r.Mobile_Number__c, '                                       +
                'Previous_Performance_Review__r.Performance_Level__c, '              +
                'Previous_Performance_Review__r.Start_Date__c, '                     +
                'Current_Performance_Review__r.Monthly_Target__r.Survey_Target__c, ' +
                'Current_Performance_Review__r.Monthly_Target__r.Search_Target__c, ' +
                'Current_Performance_Review__r.Total_Surveys__c, '                   +
                'Current_Performance_Review__r.Total_Searches__c '                   +
            'FROM '                                                                  +
                'CKW__c';

        String whereClause = '';
        if (variables.size() > 0) {
            whereClause = generateWhereClause(variables, 'CKW', ignorePersonList);
        }

        // Log the query just in case
        String query = selectClause + whereClause;
        System.debug(query);
        return query;
    }

    public static String getFarmers(Map<String, String> variables, Boolean ignorePersonList) {

        // Check the we have suitable params to stop hitting the limits.
        if (!getNamedVariable(variables, 'farmers').equals('') && !getNamedVariable(variables, 'ckws').equals('') && !getNamedVariable(variables, 'district').equals('')) {
            return '';
        }

        // Base query string
        String selectClause = 
            'SELECT '                           +
                'Name, '                        +
                'Crops__c, '                    +
                'Household_Status__c, '         +
                'Land_Size__c, '                +
                'Livestock__c, '                +
                'Registered_By__c, '            +
                'Registered_By__r.Name, '       +
                'Topics_of_Interest__c, '       +
                'Person__c, '                   +
                'Person__r.Gender__c, '         +
                'Person__r.First_Name__c, '     +
                'Person__r.Middle_Name__c, '    +
                'Person__r.Last_Name__c, '      +
                'Person__r.GPS_Location_N__c, ' +
                'Person__r.GPS_Location_E__c, ' +
                'Person__r.Village__c, '        +
                'Person__r.Parish__c '          +
            'FROM '                             +
                'Farmer__c ';

        String whereClause = '';
        if (variables.size() > 0) {
            whereClause = generateWhereClause(variables, 'FARMER', ignorePersonList);
        }

        // Log the query just in case
        String query = selectClause + whereClause;
        System.debug(query);
        return query;        
    }

    /**
     *  Construct a query that returns a count of the number of people who match a certain clause
     *
     * @param variables     - A name value pair of the variables used to calculate the where clause
     * @param mustIncPeople - There must be a list of persons passed in the variable map
     *
     * @return - The value. Note this one doesn't return the query. It runs it for and returns the result
     */
    public static Decimal getNumberOfPeople(Map<String, String> variables, Boolean mustIncPeople) {

        if (mustIncPeople && getNamedVariable(variables, 'persons').equals('')) {
            return 0.0;
        }

        String selectClause =
            'SELECT '                +
                'count(Name) total ' +
            'FROM '                  +
                'Person__c ';

        String whereClause = '';
        if (variables.size() > 0) {
            whereClause = generateWhereClause(variables, 'PERSON', false);
        }

        // Log the query just in case
        String query = selectClause + whereClause;
        System.debug(query);
        AggregateResult[] result = database.query(query);
        return (Decimal)(result[0].get('total'));
    }

    public static Decimal getSumOfPeople(String sumField, Map<String, String> variables, Boolean mustIncPeople) {

        String query =
            'SELECT '                                                   +
                'sum(' + sumField + ') sum '                            +
            'FROM '                                                     +
                'Person__c '                                            +
             'WHERE '                                                   +
                 ' Current_Poverty_Scorecard__c != NULL AND '           +
                addInWhereClause('Id', false, getNamedVariable(variables, 'persons'), null, false);

        System.debug(LoggingLevel.INFO, query);
        AggregateResult[] result = database.query(query);
        return (Decimal)(result[0].get('sum'));
    }
    /**
     *  Get a list of Organisations(partners). Calling method should run the query.
     *
     *  @return - The query as a string to be run.
     */
    public static String getOrganisations() {

        String query =
            'SELECT '                                +
                'Name, '                             +
                'Id '                                +
            'FROM '                                  +
                'Account '                           +
            'WHERE '                                 +
                'Is_Partner_Organisation__c = true ' +
                'OR Is_Farmer_Group__c = true '      +
            'ORDER BY '                              +
                'Name';
        System.debug(query);
        return query;
    }

    /**
     *  Get a list of projects. Calling method should run the query.
     *
     *  @param - An organisation that we want to get the projects for
     *
     *  @return - The query as a string to be run.
     */
    public static String getProjects(String organisations) {

        String query =
            'SELECT '   +
                'Name, '+
                'Id '   +
            'FROM '     +
                'Project__c';
        if (organisations != null && !organisations.equals('')) {
            query = query + ' WHERE Organisation__c = \'' + organisations + '\'';
        }
        query = query + ' ORDER BY Name';
        System.debug(query);
        return query;
    }

    /**
     * Get the words that we are looking for to show in the tag cloud
     *
     * @param variables - A name value pair of the variables used to calculate the where clause
     * @param numberOfWords - get the top n words. Pass in 0 to get all words.
     *
     * @return - The query as a string to be run.
     */
    public static String getTagCloudWords(Map<String, String> variables, Integer numberOfWords) {

        String selectClause = 
            'SELECT '                          +
                'Name, '                       +
                'Display_Order__c '            +
            'FROM '                            +
                'Tag_Cloud_Word__c '           +
            'WHERE '                           +
                'Is_Tag_Cloud_Word__c = true ' +
                'AND Active__c = true ';

        String whereClause = '';
        String whereClauses = getKeywordWhereClauses(variables);
        if (whereClauses.length() > 3) {
            whereClause = ' AND (' + whereClauses + ')';
        }
        String query = selectClause + ' ' + whereClause + ' ';

        // Add the order by clause
        query = query               +
            'ORDER BY '             +
            'Display_Order__c, Name';

        // Add limit clause if needed
        if (numberOfWords != null && numberOfWords > 0) {
            query = query + ' LIMIT ' + numberOfWords;
        }
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get the count for a given word in the search logs.
     *
     * @param word      - The word we are looking for.
     * @param variables - A map of the variables that may be used to narrow down the count.
     *
     * @return - The query string to be run.
     */
    public static String getTagCloudWordCount(String word, Map<String, String> variables) {

        String selectClause =
            'SELECT '                +
                'count(Name) total ' +
            'FROM '                  +
                'Search_Log__c '     +
            'WHERE '                 +
                'Query__c LIKE \'%' + word + '%\'';

        String whereClause = '';
        List<String> whereClauses = getSearchWhereClauses(variables);
        if (whereClauses.size() > 0) {
            whereClause = joinWhereClause(whereClauses, true);
        }
        String query = selectClause + ' ' + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get the keywords that are used by default in the search graph visualisations.
     */
    public static String getKeywords(Map<String, String> variables, Integer numberOfWords) {
        String selectClause = 
            'SELECT '                   +
                'Name, '                +
                'Display_Order__c '     +
            'FROM '                     +
                'Tag_Cloud_Word__c '    +
            'WHERE '                    +
                'Is_Keyword__c = true ' +
                'AND Active__c = true ';

        String whereClause = '';
        String whereClauses = getKeywordWhereClauses(variables);
        if (whereClauses.length() > 3) {
            whereClause = ' AND (' + whereClauses + ')';
        }
        String query = selectClause + ' ' + whereClause + ' ';

        // Add the order by clause
        query = query               +
            'ORDER BY '             +
            'Display_Order__c, Name';

        // Add limit clause if needed
        if (numberOfWords != null && numberOfWords > 0) {
            query = query + ' LIMIT ' + numberOfWords;
        }
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    public static String getKeywordWhereClauses(Map<String, String> variables) {

        List<String> whereClauses = new List<String>();
        if (getNamedVariable(variables, 'AllCat').equals('true')) {
            whereClauses.add(buildStandardWhereClause('=', 'Is_Category__c', 'true', false));
        }
        if (getNamedVariable(variables, 'AllCrops').equals('true')) {
            whereClauses.add(buildStandardWhereClause('=', 'Is_Crop__c', 'true', false));
        }
        if (getNamedVariable(variables, 'AllLivestock').equals('true')) {
            whereClauses.add(buildStandardWhereClause('=', 'Is_Livestock__c', 'true', false));
        }

        // As this should be seperated by OR do it here and dont use the joining method used in the others.
        String whereClause = '';
        Integer size = whereClauses.size();
        for (Integer i = 0; i < size; i++) {
            whereClause = whereClause + ' ' + whereClauses.get(i);
            if (i != size - 1) {
                whereClause = whereClause + ' OR ';
            }
        }
        return whereClause;
    }

    public static String getSearchesForGraph(Map<String, String> variables) {

        String selectClause =
            'SELECT '                     +
                'Query__c, '              +
                'Handset_Submit_Time__c ' +
            'FROM '                       +
                'Search_Log__c';
        String whereClause = '';
        List<String> whereClauses = getSearchWhereClauses(variables);
        if (whereClauses.size() > 0) {
            whereClause = 'WHERE ' + joinWhereClause(whereClauses, false);
        }
        String query = selectClause + ' ' + whereClause ;

        // Add the ordering clause
        query = query + ' ORDER BY Handset_Submit_Time__c ';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    public static Map<String, Integer> getSearchTotals(
            Map<String, String> variables,
            Map<String, Integer> searchTotals,
            String groupByField
    ) {

        String selectClause =
            'SELECT '                         +
                'count(id) total, '           +
                groupByField + ' groupValue ' +
            'FROM '                           +
                'Search_Log__c';

        String whereClause = '';
        List<String> whereClauses = getSearchWhereClauses(variables);
        if (whereClauses.size() > 0) {
            whereClause = 'WHERE ' + joinWhereClause(whereClauses, false);
        }

        // Generate the group by clause
        String groupByClause =
                ' GROUP BY ' + groupByField;

        String query = selectClause + ' ' + whereClause + ' ' + groupByClause;
        System.debug(LoggingLevel.INFO, query);
        for (AggregateResult result : database.query(query)) {

            Integer currentTotal = searchTotals.get((String)result.get('groupValue')) != null ? searchTotals.get((String)result.get('groupValue')) : 0;
            searchTotals.put((String)result.get('groupValue'), (Integer)result.get('total') + currentTotal);
        }
        return searchTotals;
    }

    public static String getSearches(Map<String, String> variables) {

        String selectClause =
            'SELECT '                           +
                'Query__c, '                    +
                'Latitude__c, '                 +
                'Longitude__c, '                +
                'Record_ID__c, '                +
                'Handset_Submit_Time__c, '      +
                'Server_Entry_Time__c, '        +
                'Submission_Latitude__c, '      +
                'Submission_Longitude__c, '     +
                'Submission_GPS_Timestamp__c, ' +
                'Interviewee__r.Name, '         +
                'Interviewer__r.Name '          +
            'FROM '             +
                'Search_Log__c';
        String whereClause = '';
        List<String> whereClauses = getSearchWhereClauses(variables);
        if (whereClauses.size() > 0) {
            whereClause = 'WHERE ' + joinWhereClause(whereClauses, false);
        }
        String query = selectClause + ' ' + whereClause ;

        // Add the ordering clause
        query = query + ' ORDER BY Handset_Submit_Time__c ';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private static List<String> getGroupsWhereClause(Map<String, String> variables) {

        List<String> whereClauses = new List<String>();
        if (!getNamedVariable(variables, 'Id').equals('')) {
            whereClauses.add(addInWhereClause('Id', false, getNamedVariable(variables, 'Id'), null, true));
        }
        if (!getNamedVariable(variables,'name').equals('')) {
            whereClauses.add(addInWhereClause('name', false, getNamedVariable(variables, 'name'), null, true));
        }
        return whereClauses;
    }
    private static List<String> getSearchWhereClauses(Map<String, String> variables) {

        List<String> whereClauses = new List<String>();

        // Check that the searches are valid
        if (!getNamedVariable(variables, 'allowTestSearch').equals('true')) {
            whereClauses.add(buildStandardWhereClause('!=', 'Interviewee__r.First_Name__c', 'Test', true));
            whereClauses.add(buildStandardWhereClause('!=', 'Interviewee__c', 'null', false));
        }
        if (!getNamedVariable(variables, 'farmers').equals('')) {
            whereClauses.add(addInWhereClause('Interviewee__c', false, getNamedVariable(variables, 'farmers'), null, false));
        }
        if (!getNamedVariable(variables, 'ckws').equals('')) {
            whereClauses.add(addInWhereClause('Interviewer__c', false, getNamedVariable(variables, 'ckws'), null, false));
        }

        if (!getNamedVariable(variables, 'povertyckws').equals('')) {
            if (getNamedVariable(variables, 'povertyckws').equals('non')) {
                whereClauses.add(buildStandardWhereClause('>', 'Interviewer__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
            }
            else if (getNamedVariable(variables, 'povertyckws').equals('poor')) {
                whereClauses.add(buildStandardWhereClause('<=', 'Interviewer__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
            }
        }

        // Distinguish by Farmer Gender
        if (!getNamedVariable(variables, 'genderfarmers').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Interviewee__r.Gender__c', getNamedVariable(variables, 'genderfarmers'), true));
        }

        // Distinguish by Registering Gender
        if (!getNamedVariable(variables, 'genderckws').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Interviewer__r.Gender__c', getNamedVariable(variables, 'genderckws'), true));
        }
        if (!getNamedVariable(variables, 'district').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Interviewer__r.District__r.Name', getNamedVariable(variables, 'district'), true));
        }
        if (!getNamedVariable(variables, 'searchStartDate').equals('')) {
            whereClauses.add(buildStandardWhereClause('>=', 'Handset_Submit_Time__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'searchStartDate'))), false), false));
        }
        if (!getNamedVariable(variables, 'searchEndDate').equals('')) {
            whereClauses.add(buildStandardWhereClause('<=', 'Handset_Submit_Time__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'searchEndDate'))), false), false));
        }
        if (!getNamedVariable(variables, 'keyword').equals('')) {
            String keywordClause = generateKeywordClause(getNamedVariable(variables, 'keyword'));
            if (keywordClause != null) {
                whereClauses.add(keywordClause);
            }
        }
        return whereClauses;
    }

    private static String generateKeywordClause(String keywords) {

        String clause = '';
        String[] keywordArray = keywords.split(';');
        if (keywordArray.size() == 0) {
            return null;
        }
        clause = '(';
        Integer counter = 1;
        for (String keyword : keywordArray) {
            clause += 'Query__c LIKE \'%' + keyword + '%\'';
            if (counter < keywordArray.size()) {
                clause += ' OR ';
            }
            counter++;
        }
        clause += ')';
        return clause;
    }

    public static String getDistricts(String orgName) {

        String selectClause =
            'SELECT '           +
                'Name, '        +
                'Latitude__c, ' +
                'Longitude__c ' +
            'FROM '             +
                'District__c';

        String whereClause = '';
        if (orgName != null && !orgName.equals('')) {
            whereClause =
                ' WHERE '                                           +
                    'Id IN ('                                       +
                        'SELECT '                                   +
                            'District__c '                          +
                        'FROM '                                     +
                            'Organisation_District_Association__c ' +
                        'WHERE '                                    +
                            'Organisation__r.Name = \''             +
                                orgName                             +
                            '\''                                    +
                    ')';
        }
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    public static String getDistrict(String district) {

        String query =
            'SELECT '           +
                'Name, '        +
                'Latitude__c, ' +
                'Longitude__c ' +
            'FROM '             +
                'District__c '  +
            'WHERE '            +
                'Name = \''     +
                    district    +
                '\'';
        return query;
    }

    public static String getSubcounty(String subcounty, Id districtId) {

        String query =
            'SELECT '                        +
                'Name, '                     +
                'District__c,'               +
                'Latitude__c, '              +
                'Longitude__c '              +
            'FROM '                          +
                'Subcounty__c '              +
            'WHERE '                         +
                'District__c = :districtId ' +
                'AND Display_Name__c = \''   +
                    subcounty                +
                '\'';
        return query;
    }

    /**
     *  Get a list of available groups
     */
    public static String getGroups(Map<String, String> variables) {

        String selectClause =
            'SELECT '     +
                'Id, '    +
                'Name '   +
            'FROM '       +
                'Group__c';

         String whereClause = '';
         if (variables != null) {
             List<String> whereClauses = getGroupsWhereClause(variables);
             if ( whereClauses.size() > 0) {
                 whereClause = ' WHERE '+ joinWhereClause(whereClauses, false);
             }
         }
         String query = selectClause + whereClause + ' ORDER BY Name';
         System.debug(LoggingLevel.INFO, query);
         return query;
    }

    public static String getGroups() {
        return getGroups(null);
    }

    /**
     *  Get the members details for a group
     *
     *  @param groupdId - The id of the group
     *
     *  @return - The query string to run
     */
    public static String getGroupMemberInfo(String groupId) {

        String selectClause =
            'SELECT '                                    +
                'Id, '                                   +
                'Name, '                                 +
                'Handset__r.IMEI__c '                    +
            'FROM '                                      +
                'Person__c '                             +
            'WHERE '                                     +
                'Id IN ('                                +
                    'SELECT '                            +
                        'Person__c '                     +
                    'FROM '                              +
                        'Person_Group_Association__c '   +
                    'WHERE '                             +
                        'Group__c = \'' + groupId + '\'' +
                ')';
        return selectClause;
    }

    /**
     *  Get the members details for a group
     *
     *  @param groupdId - The id of the group
     *
     *  @return - The query string to run
     */
    public static String getCkwGroupMemberInfo(String groupIds) {

        String selectClause =
             'SELECT '+
                 'Person__c, '+
                 'Person__r.First_Name__c, '+
                 'Person__r.Last_Name__c ,'+
                 'Person__r.Name, '+
                 'Person__r.Handset__r.IMEI__c, '+
                 'Group__c, '+
                 'Group__r.Name '+
             'FROM '                               +
                 'Person_Group_Association__c '    +
             'WHERE '                              +
                 'Group__c IN (' + groupIds + ')'  +
            'ORDER BY Person__r.First_Name__c';
        return selectClause;
    }

    /**
     *  Get a list of Applications
     *
     * @param onlyActive - Only return the active applications.
     *
     * @return - The query string to be run by the calling method
     */
    public static String getApplications(Boolean onlyActive) {

        String selectClause =
            'SELECT '                             +
                'Id, '                            +
                'Name, '                          +
                'Application_Name__c, '           +
                'Application_Version__c, '        +
                'Version_Name_Human_Readable__c ' +
            'FROM '                               +
                'Application_Version__c ';

        String whereClause = '';

        // Filter out the inactive applications if required
        if (onlyActive){
            whereClause = 'WHERE Application_Available__c = true';
        }
        String orderClause =
            'ORDER BY ' +
                'Application_Version__c, Application_Name__c';
        String query = selectClause + ' ' + whereClause + ' ' + orderClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get a count of how many handsets have applications installed on them
     *
     *  @param appIds - A list of the apps we want to include
     *  @param imeis  - A list of imeis that we want to include
     *
     *  @return - query string
     */
    public static String getApplicationPersonCount(List<String> appIds, List<String> imeis) {
        String query =
                'SELECT '                                                         +
                    'count(Id) total, '                                           +
                    'Application_Version__c app '                                 +
                'FROM '                                                           +
                    'Handset_Application_Association__c '                         +
                'WHERE '                                                          +
                    'Application_Version__c IN ('                                 +
                        MetricHelpers.generateCommaSeperatedString(appIds, true)  +
                    ') '                                                          +
                    'AND Handset__r.IMEI__c IN ('                                 +
                        + MetricHelpers.generateCommaSeperatedString(imeis, true) +
                    ') '                                                          +
                'Group By '                                                       +
                    'Application_Version__c';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get application group associations. Should only include one of the orderBy or groupdBy field.  The other should be null.
     *
     *  @param groupIds     - A list group ids that you are looking for
     *  @param appIds       - A list application ids that you are looking for
     *  @param onlyActive   - Include Apps that are active only
     *  @param groupByField - Field to group by
     *  @param orderByField - Field to order by
     *
     * @return - The query string to be run by the calling procedure
     */
    public static String getApplicationGroupAssociations(List<String> groupIds, List<String> appIds, Boolean onlyActive, String groupByField, String orderByField) {

        String selectClause = '';
        if (groupByField == null) {
            selectClause =
            'SELECT '                                                     +
                'Id, '                                                    +
                'Group__c, '                                              +
                'Application_Version__c, '                                +
                'Application_Version__r.Id, '                             +
                'Application_Version__r.Name, '                           +
                'Application_Version__r.Application_Version__c, '         +
                'Application_Version__r.Application_Name__c, '            +
                'Application_Version__r.Version_Name_Human_Readable__c, ' +
                'Group__r.Name, '                                         +
                'Group__r.Id, '                                           +
                'CreatedDate ';
        }
        else {
            selectClause =
                'SELECT '               +
                    'count(id) total, ' +
                    ' ' + groupByField + ' groupField ';
        }
        selectClause = selectClause + 'FROM ' +
                'Application_Version_Group_Association__c ';

        // Add the where clauses that may be needed
        List<String> whereClauses = new List<String>();
        String whereClause = '';
        if (appIds != null && appIds.size() > 0) {
            whereClauses.add(addInWhereClause('Application_Version__c', false, null, appIds, true));
        }
        if (groupIds != null && groupIds.size() > 0) {
            whereClauses.add(addInWhereClause('Group__c', false, null, groupIds, true));
        }

        // Filter out the inactive applications if required
        if (onlyActive){
            whereClauses.add(buildStandardWhereClause('=', 'Application_Version__r.Application_Available__c', 'true', false));
        }
        if (whereClauses.size() > 0) {
            whereClause = 'WHERE ' + joinWhereClause(whereClauses, false);
        }
        String orderByClause = '';


        // Add the order by clause if needed
        if (orderByField != null) {
            orderByClause = 'ORDER BY ' + orderByField;
        }

        // Add the group by clause if needed
        String groupByClause = '';
        if (groupByField != null) {
            groupByClause = 'GROUP BY ' + groupByField;
        }

        // Build the query string
        String query = (selectClause + ' ' + whereClause + ' ' + groupByClause + ' ' + orderByClause);
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get the survey details
     *
     * @param variables - A name value pair of the variables used to calculate the where clause
     */
    public static String getSurveys(Map<String, String> variables){

        String selectClause =
            'SELECT '             +
                'Id, '            +
                'Name, '          +
                'Survey_Name__c ' +
            'FROM '               +
                'Survey__c ';

        // Generate the where clause.
        List<String> whereClauses = new List<String>();
        if (!getNamedVariable(variables, 'orgName').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Account__r.Name', getNamedVariable(variables, 'orgName'), true));
        }
        if (!getNamedVariable(variables, 'org').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Account__r.Id', getNamedVariable(variables, 'org'), true));
        }
        if (!getNamedVariable(variables, 'SalesForceOnly').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', 'Save_To_Salesforce__c', getNamedVariable(variables, 'SalesForceOnly'), false));
        }
        String whereClause = '';
        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + joinWhereClause(whereClauses, false);
        }

        // Log the query just in case
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get submissions
     *
     * @param variables - A name value pair of the variables used to calculate the where clause
     */
    public static String getSubmissions(Map<String, String> variables) {

        String selectClause = 
            'SELECT '                                +
                'Id, '                               +
                'Name, '                             +
                'Interviewee_Name__c, '              +
                'Interviewee__c, '                   +
                'Interviewee__r.Name, '              +
                'Interviewer_Name__c, '              +
                'Interviewer__c, '                   +
                'Interviewer__r.Name, '              +
                'Survey_Name__c, '                   +
                'Survey__c, '                        +
                'Survey__r.Name, '                   +
                'Interview_Latitude__c, '            +
                'Interview_Longitude__c, '           +
                'Handset_Submit_Time__c, '           +
                'Data_Collection_Review_Status__c, ' +
                'Customer_Care_Review_Status__c '    +
            'FROM '                                  +
                'Submission_Meta_Data__c ';

        String whereClause = '';
        if (variables.size() > 0) {
            whereClause = generateSubmissionWhereClause(variables, false);
        }

        // Log the query just in case
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get the answers to surveys.
     *
     *  @param variables    - A map containing the variables for the where clause
     *  @param orderByFields - A list of the fields to order the query by
     */
    public static String getSubmissionAnswers(Map<String, String> variables, List<String> orderByFields) {

        String selectClause =
            'SELECT '                                                        +
                'Answer__c, '                                                +
                'Binding__c, '                                               +
                'Question_Text__c, '                                         +
                'Instance__c, '                                              +
                'Submission_Meta_Data__c, '                                  +
                'Submission_Meta_Data__r.Name, '                             +
                'Submission_Meta_Data__r.CreatedDate, '                      +
                'Submission_Meta_Data__r.Customer_Care_Review_Status__c, '   +
                'Submission_Meta_Data__r.Data_Collection_Review_Status__c, ' +
                'Submission_Meta_Data__r.Handset_Submit_Time__c, '           +
                'Submission_Meta_Data__r.Interview_Latitude__c, '            +
                'Submission_Meta_Data__r.Interview_Longitude__c, '           +
                'Submission_Meta_Data__r.Interviewer__r.Name, '              +
                'Submission_Meta_Data__r.Interviewer__r.First_Name__c, '     +
                'Submission_Meta_Data__r.Interviewer__r.Last_Name__c, '      +
                'Submission_Meta_Data__r.Interviewer__r.District__r.Name, '  +
                'Submission_Meta_Data__r.Interviewer__r.Subcounty__r.Name, ' +
                'Submission_Meta_Data__r.Interviewer__r.Parish__c, '         +
                'Submission_Meta_Data__r.Interviewer__r.Gender__c, '         +
                'Submission_Meta_Data__r.Interviewee__r.Name, '              +
                'Submission_Meta_Data__r.Interviewee__r.First_Name__c, '     +
                'Submission_Meta_Data__r.Interviewee__r.Last_Name__c, '      +
                'Submission_Meta_Data__r.Interviewee__r.Parish__c, '         +
                'Submission_Meta_Data__r.Interviewee__r.Gender__c '          +
            'FROM '                                                          +
                'Submission_Answer__c';
        String whereClause = '';
        if (!variables.isEmpty()) {
            whereClause = generateSubmissionWhereClause(variables, true);
        }
        String orderByClause = '';
        if (!orderByFields.isEmpty()) {
            orderByClause = ' ORDER BY ';
            Integer counter = 1;
            Integer size = orderByFields.size();
            for (String field : orderByFields) {
                orderByClause = orderByClause + field;
                if (counter < size) {
                    orderByClause = orderByClause + ', ';
                }
            }
        }

        String query = selectClause + whereClause + orderByClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     * Count how many submissions a survey has had
     *
     * @param variables    - A map containing the variables for the where clause
     * @param surveyTotals - A map containing the survey totals
     * @param groupByField - The field name that we wish to group by
     * @param surveyMap    - A map of surveys where the id is the key. Needed as you cannot group by .Name fields
     *
     */
    public static Map<String, Integer> countSurveyTotals(
            Map<String, String> variables,
            Map<String, Integer> surveyTotals,
            String groupByField,
            Map<String, Survey__c> surveyMap
    ) {

        String selectClause =
            'SELECT '                       +
                'count(id) total, '         +
                'Survey__r.Id surveyId ';
        if (groupByField != null) {
            selectClause = selectClause + ', ' + groupByField + ' groupValue ';
        }
        selectClause = selectClause +
            'FROM ' +
                'Submission_Meta_Data__c ';

        String whereClause = '';
        if (!variables.isEmpty()) {
            whereClause = generateSubmissionWhereClause(variables, false);
        }

        // Generate the group by clause
        String groupByClause =
                ' GROUP BY ' +
                    'Survey__r.Id';
        if (groupByField != null) {
            groupByClause = groupByClause + ', ' + groupByField;
        }
        String query = selectClause + whereClause + groupByClause;
        System.debug(LoggingLevel.INFO, query);

        for (AggregateResult result : database.query(query)) {
            List<String> mapName = new List<String>();

            mapName.add(surveyMap.get((String)result.get('surveyId')).Name);
            if (groupByField != null) {
                mapName.add((String)result.get('groupValue'));
            }
            Integer currentTotal = surveyTotals.get(MetricHelpers.createSplitName(mapName)) != null ? surveyTotals.get(MetricHelpers.createSplitName(mapName)) : 0;
            surveyTotals.put(MetricHelpers.createSplitName(mapName), (Integer)result.get('total') + currentTotal);

            // Add to the total for that survey too
            surveyTotals.put((String)result.get('surveyId'), (Integer)result.get('total') + currentTotal);
        }
        return surveyTotals;
    }

    /**
     *  Get stats for a survey
     */
    public static String getSurveyStats(
            Map<String, String> variables,
            List<String> groupByFields
    ) {

        // Check that we have the minimum data required
        if (getNamedVariable(variables, 'surveyName').equals('')
                || getNamedVariable(variables, 'binding').equals('')
                || getNamedVariable(variables, 'questionType').equals('')
                || getNamedVariable(variables, 'function').equals('')
        ) {
            return null;
        }

        String selectClause = 'SELECT ' + generateSurveySelectClause(variables);

        for (Integer i = 0; i < groupByFields.size(); i++) {
            selectClause = selectClause + ', Submission_Meta_Data__r.Interviewer__r.' + groupByFields.get(i) + ' groupField' + i;
        }

        selectClause = selectClause +
            ' FROM ' +
                'Submission_Answer__c ';

        String whereClause = '';
        if (!variables.isEmpty()) {
            whereClause = generateSubmissionWhereClause(variables, true);
        }

        // Generate the group by clause
        String groupByClause =
                ' GROUP BY ' +
                    'Submission_Meta_Data__r.Survey__r.Id';
        for (Integer i = 0; i < groupByFields.size(); i++) {
            groupByClause = groupByClause + ', Submission_Meta_Data__r.Interviewer__r.' + groupByFields.get(i);
        }
        String query = selectClause + whereClause + groupByClause;
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private static String generateSurveySelectClause(Map<String, String> variables) {

        String questionType = getNamedVariable(variables, 'questionType');
        String function = getNamedVariable(variables, 'function');
        String selectClause = '';

        // The select clause will be different depending on the questionType and function
        if (function.equals('sum') || function.equals('average')) {
            selectClause =
                'sum(Answer_Integer__c) total ';
        }
        else {
            selectClause =
                'count(id) total';
        }
        return selectClause;
    }

    /**
     *  From a variable name-value pair map. Generate a where clause for a query
     *
     *  @param variables - The map containing the variables. Note that dates and other types must have been
     *                     turned into strings before calling the map.
     *  @param answers   - Looking at the answers table. Will need to append to the fields
     *
     *  @return - A string that contains the where clause.
     */
    private static String generateSubmissionWhereClause(Map<String, String> variables, Boolean answers) {

        String answerTable = '';
        if (answers) {
            answerTable = 'Submission_Meta_Data__r.';
        }

        List<String> whereClauses = new List<String>();

        if (!getNamedVariable(variables, 'orgName').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', answerTable + 'Survey__r.Account__r.Name', getNamedVariable(variables, 'orgName'), true));
        }
        if (!getNamedVariable(variables, 'district').equals('')) {
            whereClauses.add(buildStandardWhereClause('=', answerTable + 'Interviewer__r.District__r.Name', getNamedVariable(variables, 'district'), true));
        }
        if (!getNamedVariable(variables, 'surveyName').equals('')) {
            whereClauses.add(addInWhereClause(answerTable + 'Survey__r.Name', false, getNamedVariable(variables, 'surveyName'), null, false));
        }
        if (!getNamedVariable(variables, 'dataCollectionStatusNot').equals('')) {
            whereClauses.add(buildStandardWhereClause('!=', answerTable + 'Data_Collection_Review_Status__c', getNamedVariable(variables, 'dataCollectionStatusNot'), true));
        }
        if (!getNamedVariable(variables, 'customerCareStatusNot').equals('')) {
            whereClauses.add(buildStandardWhereClause('!=', answerTable + 'Customer_Care_Review_Status__c', getNamedVariable(variables, 'customerCareStatusNot'), true));
        }
        if (!getNamedVariable(variables, 'ckws').equals('')) {
            whereClauses.add(addInWhereClause(answerTable + 'Interviewer__c', false, getNamedVariable(variables, 'ckws'), null, false));
        }
        if (!getNamedVariable(variables, 'farmers').equals('')) {
            whereClauses.add(addInWhereClause(answerTable + 'Interviewee__c', false, getNamedVariable(variables, 'farmers'), null, false));
        }
        if (!getNamedVariable(variables, 'submissionStartDate').equals('')) {
            whereClauses.add(buildStandardWhereClause('>=', answerTable + 'Handset_Submit_Time__c', getNamedVariable(variables, 'submissionStartDate'), false));
        }
        if (!getNamedVariable(variables, 'submissionEndDate').equals('')) {
            whereClauses.add(buildStandardWhereClause('<=', answerTable + 'Handset_Submit_Time__c', getNamedVariable(variables, 'submissionEndDate'), false));
        }

        if (!getNamedVariable(variables, 'povertyckws').equals('')) {
            if (getNamedVariable(variables, 'povertyckws').equals('non')) {
                whereClauses.add(buildStandardWhereClause('>', answerTable + 'Interviewer__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
            }
            else if (getNamedVariable(variables, 'povertyckws').equals('poor')) {
                whereClauses.add(buildStandardWhereClause('<=', answerTable + 'Interviewer__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
            }
        }

        // These should only be present when looking at the answer table
        if (answers) {
            if (!getNamedVariable(variables, 'submissionIds').equals('')) {
                whereClauses.add(addInWhereClause('Submission_Meta_Data__c', false, getNamedVariable(variables, 'submissionIds'), null, false));
            }

            // For the single select question type we need to add the posibilites that the answer is allowed to be
            if (!getNamedVariable(variables, 'selectOptions').equals('')) {
                whereClauses.add(addInWhereClause('Answer_Integer__c', false, null, getNamedVariable(variables, 'selectOptions').split(' '), false));
            }
            if (!getNamedVariable(variables, 'multipleOptions').equals('')) {
                whereClauses.add(generateMultipleSelectClause(getNamedVariable(variables, 'multipleOptions')));
            }
            if (!getNamedVariable(variables, 'binding').equals('')) {
                whereClauses.add(buildStandardWhereClause('=', 'Binding__c', getNamedVariable(variables, 'binding'), true));
           }
            if (!getNamedVariable(variables, 'questionType').equals('')) {
                String questionType = getNamedVariable(variables, 'questionType');
                if (questionType.equals('boolean')) {
                   whereClauses.add(buildStandardWhereClause('=', 'Answer_Boolean__c', 'true', true));
                }
            }
        }
        String whereClause = '';
        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + joinWhereClause(whereClauses, false);
        }
        return whereClause;
    }

    private static String generateMultipleSelectClause(String options) {

        String[] optionList = options.split(' ');
        String clause = '';
        Integer counter = 0;
        for (String option : optionList) {
            clause = clause + '(Answer_Short_Text__c LIKE \'' + option + '\'' + 
                            ' OR Answer_Short_Text__c LIKE \'% ' + option + ' %\'' +
                            ' OR Answer_Short_Text__c LIKE \'% ' + option + '\'' +
                            ' OR Answer_Short_Text__c LIKE \'' + option + ' %\')';
            if (counter < optionList.size() - 1) {
                clause = clause + ' OR ';
            }
        }
        return clause;
    }

    /**
     *  From a variable name-value pair map. Generate a where clause for a query
     *
     *  @param variables - The map containing the variables. Note that dates and other types must have been
                          turned into strings before calling the map.
     *
     *  @return - A string that contains the where clause.
     */
    private static String generateWhereClause(Map<String, String> variables, String queryType, Boolean ignorePersonList) {

        List<String> whereClause = new List<String>();
        String dateField = 'CreatedDate';

        if (!queryType.equals('SEARCHES') && !queryType.equals('PERSON')) {

            // Distinguish by region
            if (!getNamedVariable(variables, 'district').equals('')) {
                whereClause.add(buildStandardWhereClause('=', 'Person__r.District__r.Name', getNamedVariable(variables, 'district'), true));
            }

            // Distinguish by Group
            if (!getNamedVariable(variables, 'group').equals('')) {
                whereClause.add(
                    'Person__c IN (SELECT Person__c FROM Person_Group_Association__c WHERE ' +
                    addInWhereClause('Group__c', false, getNamedVariable(variables, 'group'), null, true) +
                    ') ');
            }

            // Distinguish By Imei
            if (!getNamedVariable(variables, 'imei').equals('')) {
                whereClause.add(addInWhereClause('Person__r.Handset__r.Imei__c', false, getNamedVariable(variables, 'imei'), null, true));
            }
        }

        // Person only clause
        if (queryType.equals('PERSON')) {
            if (!getNamedVariable(variables, 'persons').equals('')) {
                whereClause.add(addInWhereClause('Id', false, getNamedVariable(variables, 'persons'), null, false));
            }
            if (!getNamedVariable(variables, 'gender').equals('')) {
                whereClause.add(buildStandardWhereClause('=', 'Gender__c', getNamedVariable(variables, 'gender'), true));
            }
            if (!getNamedVariable(variables, 'poverty').equals('')) {
                whereClause.add(buildStandardWhereClause('>=', 'Current_Poverty_Scorecard__r.Poverty_Percentage__c', getNamedVariable(variables, 'poverty'), false));
            }
        }

        // CKW only clauses
        else if (queryType.equals('CKW')) {

            // Distinguish by person ids
            if (!getNamedVariable(variables, 'ckws').equals('') && !ignorePersonList) {
                whereClause.add(addInWhereClause('Person__c', false, getNamedVariable(variables, 'ckws'), null, false));
            }

            // Allow inactive CKWs
            if (!getNamedVariable(variables, 'allowInactive').equals('true')) {
                whereClause.add(buildStandardWhereClause('=', 'Status__c', 'Active', true));
            }

            // Distinguish by organisation
            if (!getNamedVariable(variables, 'org').equals('')) {
                whereClause.add(buildGroupWhereClause('Person__c', 'Organisation__r.id', 'Person_Organisation_Association__c', getNamedVariable(variables, 'org'), false));
            }
            if (!getNamedVariable(variables, 'orgName').equals('')) {
                whereClause.add(buildGroupWhereClause('Person__c', 'Organisation__r.name', 'Person_Organisation_Association__c', getNamedVariable(variables, 'orgName'), false));
            }

            // Distinguish by project
            if (!getNamedVariable(variables, 'project').equals('')) {
                whereClause.add(buildGroupWhereClause('Person__c', 'Project__r.id', 'Person_Project_Association__c', getNamedVariable(variables, 'project'), false));
            }

            // Distinguish by Gender
            if (!getNamedVariable(variables, 'genderckws').equals('')) {
                whereClause.add(buildStandardWhereClause('=', 'Person__r.Gender__c', getNamedVariable(variables, 'genderckws'), true));
            }

            // Distinguish by poverty level
            if (!getNamedVariable(variables, 'povertyckws').equals('')) {
                if (getNamedVariable(variables, 'povertyckws').equals('non')) {
                    whereClause.add(buildStandardWhereClause('>', 'Person__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
                else if (getNamedVariable(variables, 'povertyckws').equals('poor')) {
                    whereClause.add(buildStandardWhereClause('<=', 'Person__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
            }
            dateField = 'Active_Date__c';

            // Distinguish by dates
            if (!getNamedVariable(variables, 'startDate').equals('')) {
                whereClause.add(buildStandardWhereClause('>=', dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'startDate'))), true), false));
            }
            if (!getNamedVariable(variables, 'endDate').equals('')) {
                whereClause.add(buildStandardWhereClause('<=', dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'endDate'))), true), false));
            }
        }

        // Farmer only clauses
        else if (queryType.equals('FARMER')) {

            // Distinguish by person ids
            if (!getNamedVariable(variables, 'farmers').equals('') && !ignorePersonList) {
                whereClause.add(addInWhereClause('Person__c', false, getNamedVariable(variables, 'farmers'), null, false));
            }
            if (!getNamedVariable(variables, 'ckws').equals('')) {
                whereClause.add(addInWhereClause('Registered_By__c', false, getNamedVariable(variables, 'ckws'), null, false));
            }

            // Distinguish by Farmer Gender
            if (!getNamedVariable(variables, 'genderfarmers').equals('')) {
                whereClause.add(buildStandardWhereClause('=', 'Person__r.Gender__c', getNamedVariable(variables, 'genderfarmers'), true));
            }

            // Distinguish by Registering Gender
            if (!getNamedVariable(variables, 'genderckws').equals('')) {
                whereClause.add(buildStandardWhereClause('=', 'Registered_By__r.Gender__c', getNamedVariable(variables, 'genderckws'), true));
            }

            // Distinguish by Farmer poverty level
            if (!getNamedVariable(variables, 'povertyfarmers').equals('')) {
                if (getNamedVariable(variables, 'povertyfarmers').equals('non')) {
                    whereClause.add(buildStandardWhereClause('>', 'Person__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
                else if (getNamedVariable(variables, 'povertyfarmers').equals('poor')) {
                    whereClause.add(buildStandardWhereClause('<=', 'Person__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
            }

            // Distinguish by Registering level
            if (!getNamedVariable(variables, 'povertyckws').equals('')) {
                if (getNamedVariable(variables, 'povertyckws').equals('non')) {
                    whereClause.add(buildStandardWhereClause('>', 'Registered_By__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
                else if (getNamedVariable(variables, 'povertyckws').equals('poor')) {
                    whereClause.add(buildStandardWhereClause('<=', 'Registered_By__r.Current_Poverty_Scorecard__r.Poverty_Percentage__c', '34', false));
                }
            }

            // Distinguish by dates
            if (!getNamedVariable(variables, 'startDate').equals('')) {
                whereClause.add(buildStandardWhereClause('>=', 'Registered_By__r.' + dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'startDate'))), false), false));
            }
            if (!getNamedVariable(variables, 'endDate').equals('')) {
                whereClause.add(buildStandardWhereClause('<=', 'Registered_By__r.' + dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'endDate'))), false), false));
            }
            if (!getNamedVariable(variables, 'farmerStartDate').equals('')) {
                whereClause.add(buildStandardWhereClause('>=', dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'farmerDate'))), false), false));
            }
            if (!getNamedVariable(variables, 'farmerEndDate').equals('')) {
                whereClause.add(buildStandardWhereClause('<=', dateField, MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(MetricHelpers.convertStringToDate(getNamedVariable(variables, 'farmerEndDate'))), false), false));
            }
        }

        // Build the where clause
        String clause = '';
        if (whereClause.size() > 0) {
            clause = ' WHERE ' + joinWhereClause(whereClause, false);
        }
        return clause;
    }

    public static String joinWhereClause(List<String> clauses, Boolean startWithAnd) {

        // Build the where clause
        String whereString = '';
        if (startWithAnd) {
            whereString = 'AND ';
        }
        Integer length = clauses.size();
        for (Integer i = 0; i < length; i ++) {
            whereString = whereString + clauses.get(i);
            if (i < length -1) {
                whereString = whereString + ' AND ';
            }
        }
        return whereString;
    }

    public static String addInWhereClause(String objectName, Boolean negate, String ids, List<String> idList, Boolean incQuotes) {

        String[] values;
        if (ids != null) {
            values = ids.split(',');
        }
        else {
            values = idList;
        }
        String out = '';
        out = objectName + ' ';
        if (values.size() == 1) {
            if (negate) {
                out = out + '!';
            }
            out = out + '= ';
        }
        else {
            if (negate) {
                out = out + 'NOT ';
            }
            out = out + 'IN (';
        }
        out = out + MetricHelpers.generateCommaSeperatedString(values, incQuotes);
        if (values.size() > 1) {
            out = out + ')';
        }
        return out;
    }

    public static String buildStandardWhereClause(String operator, String left, String right, boolean incQuotes) {

        String out = left + ' ' + operator + ' ';
        if (incQuotes) {
            right = '\'' + right + '\'';
        }
        return out + right;
    }

    public static String buildGroupWhereClause(String left, String right, String objectName, String name, Boolean negate) {
        String out = left + ' ';
        if (negate) {
            out = out + 'NOT ';
        } 
        out = out + 'IN (SELECT '      +
                            left       + 
                        ' FROM '       +
                            objectName + 
                        ' WHERE '      + 
                            right + ' = \'' + name + '\')';
        return out;
    }

    public static String getNamedVariable(Map<String, String> variables, String name) {
        
        String variable = variables.get(name);
        if (variable == null || variable.equals('')) {
            return '';
        }
        return variable;
    }

    public static testMethod void getCKWs() {

        District__c district = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Gulu'];

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        testPerson.Gender__c = 'Female';
        testPerson.District__c = district.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        testCkw.Status__c = 'Active';
        database.insert(testCkw);

        // Create a 2nd CKW who is inactive
        Phone__c testHandset1 = new Phone__c();
        testHandset1.IMEI__c = '2TestIMEI';
        testHandset1.Serial_Number__c = '325246263253463';
        testHandset1.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset1);

        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = '2FirstName';
        testPerson1.Last_Name__c = '2LastName';
        testPerson1.Handset__c = testHandset1.Id;
        testPerson1.District__c = district.Id;
        testPerson1.Gender__c = 'Female';
        database.insert(testPerson1);

        CKW__c testCkw1 = new CKW__c();
        testCkw1.Person__c = testPerson1.id;
        testCkw1.Status__c = 'Inactive';
        database.insert(testCkw1);

        // Create an organistaion
        Account organisation = new Account();
        organisation.Name = 'TestOrganisation';
        organisation.BillingState = 'CA';
        database.insert(organisation);

        // Create a project
        Project__c project = new Project__c();
        project.Description__c = 'Hello how are you';
        project.Name = 'TestProject';
        project.Organisation__c = organisation.Id;
        database.insert(project);

        // Create Project Associations
        Person_Project_Association__c personProjectAssociation = new Person_Project_Association__c();
        personProjectAssociation.Person__c = testPerson.Id;
        personProjectAssociation.Project__c = project.Id;
        database.insert(personProjectAssociation);

        // Create Project Associations
        Person_Organisation_Association__c personOrganisationAssociation = new Person_Organisation_Association__c();
        personOrganisationAssociation.Person__c = testPerson.Id;
        personOrganisationAssociation.Organisation__c = organisation.Id;
        database.insert(personOrganisationAssociation);

        // Set the variable Map up
        Map<String, String> variables = new Map<String, String>();
        variables.put('allowInactive', 'false');
        variables.put('ckws', testPerson.Id + ',' + testPerson1.Id);
        variables.put('district', 'Gulu');
        variables.put('org', organisation.Id);
        variables.put('project', project.Id);
        variables.put('genderckws', 'Female');

        // Get the CKW list
        CKW__c[] ckws = database.query(getCkws(variables, true));
        System.assertEquals(ckws.size(), 1);

        // Test person count
        variables.clear();
        List<String> personList = new List<String>();
        personList.add('\'' + testPerson.id + '\'');
        personList.add('\'' + testPerson1.id + '\'');
        variables.put('persons', MetricHelpers.generateCommaSeperatedString(personList, false));
        variables.put('gender', 'Female');
        Decimal check = getNumberOfPeople(variables, true);
    }

    public static testMethod void testGetFarmers() {
       
        District__c district = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Gulu'];

        District__c district1 = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Kapchorwa'];

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPersonCkw = new Person__c();
        testPersonCkw.First_Name__c = 'FirstName';
        testPersonCkw.Last_Name__c = 'LastName';
        testPersonCkw.Handset__c = testHandset.Id;
        testPersonCkw.District__c = district.Id;
        testPersonCkw.Gender__c = 'Female';
        database.insert(testPersonCkw);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPersonCkw.id;
        testCkw.Status__c = 'Active';
        database.insert(testCkw);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.District__c = district.Id;
        testPerson.Gender__c = 'Female';
        database.insert(testPerson);
        
        Farmer__c testFarmer1 = new Farmer__c();
        testFarmer1.Registered_By__c = testPersonCkw.Id;
        testFarmer1.Person__c = testPerson.Id;
        database.insert(testFarmer1);

        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = '2FirstName';
        testPerson1.Last_Name__c = '2LastName';
        testPerson1.Gender__c = 'Female';
        testPerson1.District__c = district1.Id;
        database.insert(testPerson1);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Registered_By__c = testPersonCkw.Id;
        testFarmer2.Person__c = testPerson1.Id;
        database.insert(testFarmer2);

        // Set the variable Map up
        Map<String, String> variables = new Map<String, String>();
        variables.put('farmers', testPerson.Id + ',' + testPerson1.Id);
        variables.put('district', 'Gulu');
        variables.put('genderfarmers', 'Female');
        variables.put('genderckws', 'Female');

        // Get the CKW list
        Farmer__c[] farmers = database.query(getFarmers(variables, true));
        System.assert(farmers.size()  >= 1);
    }

    public static testMethod void testDistricts() {

        District__c district = new District__c();
        district.Name = 'Gulu';
        database.insert(district);

        District__c district1 = new District__c();
        district1.Name = 'Oyam';
        database.insert(district1);

        District__c[] allDistricts = database.query(getDistricts(null));
        System.assert(allDistricts.size() >= 2);
        District__c[] aDistrict = database.query(getDistrict('Gulu'));
        System.assert(aDistrict.size() >= 1);
    }

    public static testMethod void testTagCloud() {
        
        District__c district = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Gulu'];

        District__c district1 = [
            SELECT
                Name,
                Id
            FROM
                District__c
            WHERE
                Name = 'Kapchorwa'];

        // Create a new tag cloud word
        Tag_Cloud_Word__c tagWord = new Tag_Cloud_Word__c();
        tagWord.Name = 'George';
        tagWord.Is_Tag_Cloud_Word__c = true;
        tagWord.Is_Keyword__c = true;
        Map<String, String> variables = new Map<String, String>();
        variables.put('searchStartDate', '04/01/2011');
        variables.put('searchEndDate', '06/01/2011');
        Tag_Cloud_Word__c[] tagWords = database.query(getTagCloudWords(variables, 1));
        System.assert(1 >= tagWords.size());

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPersonCkw = new Person__c();
        testPersonCkw.First_Name__c = 'FirstName';
        testPersonCkw.Last_Name__c = 'LastName';
        testPersonCkw.Handset__c = testHandset.Id;
        testPersonCkw.District__c = district.Id;
        testPersonCkw.Gender__c = 'Female';
        database.insert(testPersonCkw);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPersonCkw.id;
        testCkw.Status__c = 'Active';
        database.insert(testCkw);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.District__c = district.Id;
        testPerson.Gender__c = 'Female';
        database.insert(testPerson);

        Farmer__c testFarmer1 = new Farmer__c();
        testFarmer1.Registered_By__c = testPersonCkw.Id;
        testFarmer1.Person__c = testPerson.Id;
        database.insert(testFarmer1);

        // Create a couple of searches.
        List<Search_Log__c> logs = new List<Search_Log__c>();
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPersonCkw.id;
            log.Interviewee__c = testPerson.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'George';
            log.Response__c = 'Content';
            logs.add(log);
        }
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPersonCkw.id;
            log.Interviewee__c = testPerson.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2011-05-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2011-05-01 00:00:00');
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'George';
            log.Response__c = 'Content';
            logs.add(log);
        }
        database.insert(logs);

        AggregateResult[] frequencyResults = database.query(getTagCloudWordCount('George', variables));
        System.assertEquals(7, Integer.valueOf(frequencyResults[0].get('total')));
        database.query(getKeywords(variables, 2));
        variables.put('ckws', '\'' + testPersonCkw.Id + '\'');
        variables.put('farmers', '\'' + testPerson.Id + '\'');
        variables.put('genderfarmers', 'Female');
        variables.put('genderckws', 'Female');
        variables.put('district', 'Gulu');
        Search_Log__c[] searchLogs = database.query(getSearches(variables));
        Search_Log__c[] searchLogsGraph = database.query(getSearchesForGraph(variables));
        System.assert(searchLogs.size() >= 7);
        Account[] orgs = database.query(getOrganisations());
        database.query(getProjects(null));
    }
    
    public static testMethod void testVariousResults(){
    
        Map<String, String> query_variables = new Map<String, String>();
        query_variables.put('farmers', 'value1');
        query_variables.put('ckws', 'value2');
        query_variables.put('district', 'value3');
        String farmers = getFarmers(query_variables, true);
        System.Assert(farmers.equals(''));
        
        Decimal numberOfPeople = getNumberOfPeople(new Map<String, String>(), true);
        System.Assert(0.0 == numberOfPeople);
        
        String querry = getProjects('NAADS');
        System.Assert(querry.length() > 0);
        
        Map<String, String> variables2 = new Map<String, String>();
        variables2.put('AllCat', 'true');
        variables2.put('AllCrops', 'true');
        variables2.put('AllLivestock', 'true');
        String words = getTagCloudWords(variables2, 0);
        System.Assert(words.contains('Is_Category__c'));
        
        String whereClause = getKeywordWhereClauses(variables2);
        System.Assert(whereClause.contains('Is_Crop__c'));
        
        //Search_Log__c log = new Search_Log__c();
        //log.Response__c = 'Test Log';
        //database.insert(log);
        //Map<String, String> variables3 = new Map<String, String>();
        //variables3.put('Response__c', 'Test Log');
        //Map<String, Integer> totals = getSearchTotals(variables3,  new Map<String, Integer>(), 'From_USSD__c');
        //System.Assert(totals != null);
        
        String clauses = generateMultipleSelectClause('value1 value2');
        System.Assert(clauses.contains('\'value1 %\''));
        System.Assert(clauses.contains('\'% value1\''));
        System.Assert(clauses.contains('\'% value1 %\''));
        
        Map<Id, User> users = getRoleSubordinateUsers('00570000002FSr1AAG');
        System.Assert(users != null);
        
        Set<ID> ids = getAllSubRoleIds(new Set<ID>{'00570000002FSr1AAG'});
        System.Assert(ids != null);
        
        Map<String, String> variables4 = new Map<String, String>();
        variables4.put('orgName', 'NAADS');
        variables4.put('org', 'GF');
        variables4.put('SalesForceOnly', 'true');
        String surveyQuery = getSurveys(variables4);
        System.Assert(surveyQuery.contains('Account__r.Name'));
        
        String info = getCkwGroupMemberInfo('00570000002FSr1AAG');
        System.Assert(info.contains('00570000002FSr1AAG'));
    }
    
    /**
     * Returns all the users who are below the current user in heirarchy
     * @param userId The User Id of the User whose subordinates we want to get
     */
    public static Map<Id, User> getRoleSubordinateUsers(Id userId) {
        // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
          UserRoleId IN :allSubRoleIds]);
          
        return users;
    }
    
    /**
     * Returns all roles that are below a certain set of roles in heirarchy
     * @param roleIds The Role Ids whose subordinates we want to get
     */
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
 
        Set<ID> currentRoleIds = new Set<ID>();
 
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
        currentRoleIds.add(userRole.Id);
 
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
  }
}