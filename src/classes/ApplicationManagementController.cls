public class ApplicationManagementController {

    public List<String> groups { get; set; }
    public List<SelectOption> groupsList;
    public List<SelectOption> getGroupsList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- All Groups --'));
        Group__c[] groups = database.query(SoqlHelpers.getGroups());
        for (Group__c groupToAdd : groups) {
            options.add(new SelectOption(groupToAdd.Id, groupToAdd.Name));
        }
        return options;
    }

    public void setGroupsList(List<SelectOption> options) {
        this.groupsList = options;
    }

    public List<String> applications { get; set; }
    public List<SelectOption> applicationsList;
    public List<SelectOption> getApplicationsList() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- All Applications --'));
        Application_Version__c[] applications = database.query(SoqlHelpers.getApplications(true));
        for (Application_Version__c application : applications) {
            options.add(new SelectOption(application.Id, application.Application_Name__c + ' ' + application.Version_Name_Human_Readable__c));
        }
        return options;
    }

    public void setApplicationsList(List<SelectOption> options) {
        this.applicationsList = options;
    }

    public List<ApplicationGroupWrapper> applicationGroupList;
    public List<ApplicationGroupWrapper> getApplicationGroupList() {
        return this.applicationGroupList;
    }
    public void setApplicationGroupList(List<ApplicationGroupWrapper> applicationGroupList) {
        this.applicationGroupList = applicationGroupList;
    }

    public List<Person__c> applicationGroupPersonList;
    public List<Person__c> getApplicationGroupPersonList() {
        return this.applicationGroupPersonList;
    }
    public void setApplicationGroupPersonList(List<Person__c> applicationGroupPersonList) {
        this.applicationGroupPersonList = applicationGroupPersonList;
    }

    public Boolean showApplicationGroupList;
    public Boolean getShowApplicationGroupList() {
        return this.showApplicationGroupList;
    }
    public void setShowApplicationGroupList(Boolean show) {
        this.showApplicationGroupList = show;
    }

    public Boolean showPeopleList;
    public Boolean getShowPeopleList() {
        return this.showPeopleList;
    }
    public void setShowPeopleList(Boolean show) {
        this.showPeopleList = show;
    }

    public String errorMsg;
    public String getErrorMsg() {
        return this.errorMsg;
    }
    public void setErrorMsg(String msg) {

        if (this.errorMsg == null || this.errorMsg.equals('')) {
            this.errorMsg = msg;
        }
        else {
            this.errorMsg = this.errorMsg + '<br />' + msg;
        }
    }

    Transient Map<String, Group__c> groupTotalMap;

    // Constructor for this controller
    public ApplicationManagementController() {

        setUp();
    }

    private void setUp() {

        this.groups = new List<String>();
        this.applications = new List<String>();
        setErrorMsg('');
        setShowApplicationGroupList(false);
        setShowPeopleList(false);
    }

    public PageReference reloadPage() {

        // Decide which method has been called from the visualforce page.
        String method = Apexpages.currentPage().getParameters().get('methodParam');
        getParameters();
        if (method.equalsIgnoreCase('ADD')) {
            System.debug(LoggingLevel.INFO, 'Adding applications');
            return addApplications();
        }
        else if (method.equalsIgnoreCase('REMOVE')) {
            System.debug(LoggingLevel.INFO, 'Removeing applications');
            return removeApplications();
        }
        else if (method.equalsIgnoreCase('SHOW_GROUPS')) {
            System.debug(LoggingLevel.INFO, 'Showing apps in a group');
            setGroupMap(this.groups);
            return showApplicationsGroupCount();
        }
        else if (method.equalsIgnoreCase('SHOW_APPS')) {
            System.debug(LoggingLevel.INFO, 'Showing groups with an app');
            return showGroupsApplicationCount();
        }
        else if (method.equalsIgnoreCase('SHOW_PEOPLE')) {
            System.debug(LoggingLevel.INFO, 'Showing people ina a group with a particualar app');
            return getPeopleGroupApplication(this.groups.get(0), this.applications.get(0), Apexpages.currentPage().getParameters().get('negateParam'));
        }
        else {
        
            // Should not see this error. If it is shown there is a programming error
            setErrorMsg('Failed to run your query. Please try again');
            return null;
        }
    }

    /**
     *  Add the application versions passed in to the groups passed in
     */
    public PageReference addApplications() {

        if(checkParameters()) {

            System.debug(LoggingLevel.INFO, 'Adding applications: ' + this.applications + ' to groups: ' + this.groups);
            List<Application_Version_Group_Association__c> newVersions = new List<Application_Version_Group_Association__c>();
            for (String groupId : this.groups) {

                // Check the application versions that already exist so we are not duplicating them.
                List<String> groupIds = new List<String>();
                groupIds.add(groupId);
                Set<String> exisitingGroupAppIds = getApplicationIds(database.query(SoqlHelpers.getApplicationGroupAssociations(groupIds, this.applications, false, null, 'Application_Version__r.Application_Version__c')));
                for (String applicationId : this.applications) {
                    if (exisitingGroupAppIds.size() == 0 || !exisitingGroupAppIds.contains(applicationId)) {
                        Application_Version_Group_Association__c newAppVersion = new Application_Version_Group_Association__c();
                        newAppVersion.Group__c = groupId;
                        newAppVersion.Application_Version__c = applicationId;
                        newVersions.add(newAppVersion);
                    }
                }
            }

            // Batch the DML insert just incase. Need the batchNumber as SF doesn't support standard % operator
            Integer batchNumber = 1;
            Integer totalLinksAdded = 0;
            System.debug(LoggingLevel.INFO, 'Application Links to be added = ' + newVersions.size());
            List<Application_Version_Group_Association__c> newApplicationsBatch = new List<Application_Version_Group_Association__c>();
            for (Application_Version_Group_Association__c appVersion : newVersions) {
                newApplicationsBatch.add(appVersion);
                if (newApplicationsBatch.size() == (batchNumber * 100)) {
                    database.insert(newApplicationsBatch);
                    newApplicationsBatch.clear();
                    totalLinksAdded = totalLinksAdded + 100;
                    batchNumber++;
                }
            }

            // Add the last batch
            if (newApplicationsBatch.size() > 0) {
                totalLinksAdded = totalLinksAdded + newApplicationsBatch.size();
                database.insert(newApplicationsBatch);
            }
            System.debug(LoggingLevel.INFO, 'Application Links added = ' + totalLinksAdded);
        }
        return null;
    }

    /**
     *  Remove the application versions passed in from the groups passed in
     */
    public PageReference removeApplications() {

        if(checkParameters()) {
            Set<String> appIdsToDelete = new Set<String>();
            appIdsToDelete.addAll(this.applications);
            List<Application_Version_Group_Association__c> versionsToDelete = new List<Application_Version_Group_Association__c>();

            // Get the existing application versions for the group
            List<Application_Version_Group_Association__c> exisitingVersions = database.query(SoqlHelpers.getApplicationGroupAssociations(this.groups, this.applications, false, null, 'CreatedDate'));
            for (Application_Version_Group_Association__c exisitingVersion : exisitingVersions) {
                if (appIdsToDelete.contains(exisitingVersion.Application_Version__c)) {
                    versionsToDelete.add(exisitingVersion);
                }
            }
            System.debug(LoggingLevel.INFO, 'Apllication links to delete = ' + versionsToDelete.size());

            // Batch the DML delete just incase. Need the batchNumber as SF doesn't support standard % operator
            Integer batchNumber = 1;
            List<Application_Version_Group_Association__c> versionsToDeleteBatch = new List<Application_Version_Group_Association__c>();
            for (Application_Version_Group_Association__c appVersion : versionsToDelete) {
                versionsToDeleteBatch.add(appVersion);
                if (versionsToDeleteBatch.size() == (batchNumber * 100)) {
                    database.delete(versionsToDeleteBatch);
                    versionsToDeleteBatch.clear();
                    batchNumber++;
                }
            }

            // Delete the last batch
            if (versionsToDeleteBatch.size() > 0) {
                database.delete(versionsToDeleteBatch);
            }
        }
        return null;
    }

    /**
     *  Show a count of who does and does not have the application in all groups.
     */
    public PageReference showGroupsApplicationCount() {

        List<ApplicationGroupWrapper> counts = new List<ApplicationGroupWrapper>();
        if (this.applications == null || this.applications.size() == 1) {

            // Get all the groups that should have this application
            Application_Version_Group_Association__c[] appVersionGroupAssociaitons = database.query(SoqlHelpers.getApplicationGroupAssociations(null, this.applications, true, null, null));

            // Loop through each group and get the imeis for that group and then get the counts
            List<String> groupIds = new List<String>();
            for (Application_Version_Group_Association__c appVersionGroupAssociaiton :appVersionGroupAssociaitons) {
                String id = (String)appVersionGroupAssociaiton.Group__c;
                groupIds.add(id);
            }

            // Set up the group map
            setGroupMap(groupIds);
            for (String groupId : groupIds) {
                List<String> imeis = getImeiList(groupId);

                if (imeis.size() == 0) {

                    // No people in this group 
                }
                else {

                    // This should only return one row
                    AggregateResult[] appPersonCounts = database.query(SoqlHelpers.getApplicationPersonCount(this.applications, imeis));
                    if (appPersonCounts.size() == 0) {

                        // No people in this group with this app return a blank wrapper
                        ApplicationGroupWrapper applicationGroupWrapper = new ApplicationGroupWrapper(this.groupTotalMap.get(groupId).Name, 0, this.groupTotalMap.get(groupId).Membership_Count__c.intValue(), groupId, this.applications.get(0));
                        counts.add(applicationGroupWrapper);
                    }
                    else {
                        Integer total = (Integer)(appPersonCounts[0].get('total'));
                        String appId = (String)(appPersonCounts[0].get('app'));
                        ApplicationGroupWrapper applicationGroupWrapper = new ApplicationGroupWrapper(this.groupTotalMap.get(groupId).Name, total, this.groupTotalMap.get(groupId).Membership_Count__c.intValue() - total, groupId, appId);
                        counts.add(applicationGroupWrapper);
                    }
                }
            }
            setApplicationGroupList(counts);
            System.debug(LoggingLevel.INFO, 'Showing ' + counts.size() + ' in list');
            setShowApplicationGroupList(true);
            setShowPeopleList(false);
        }
        else {

            // Add the error message. Front end should not let us get here
            setErrorMsg('Please select one application only');
            setShowApplicationGroupList(false);
            setShowPeopleList(false);
        }
        return null;
    }

    /**
     *  Show counts for who has the current applications for a particular group
     */
    public PageReference showApplicationsGroupCount() {

        if(this.groups == null || this.groups.size() == 1) {

            // Get the latest applications for this group
            Application_Version_Group_Association__c[] appGroupLinks = database.query(SoqlHelpers.getApplicationGroupAssociations(this.groups, null, true, null, 'CreatedDate'));
            if (appGroupLinks.size() == 0) {
                setErrorMsg('There are no applications assigned to this group');
                return null;
            }
            Map<String, Application_Version_Group_Association__c> appGroupLinksMap = new Map<String, Application_Version_Group_Association__c>();
            for (Application_Version_Group_Association__c appGroupLink : appGroupLinks) {
                if (!appGroupLinksMap.keySet().contains(appGroupLink.Application_Version__r.Application_Name__c)) {
                    appGroupLinksMap.put(appGroupLink.Application_Version__r.Application_Name__c, appGroupLink);
                }
                else {
                    Application_Version_Group_Association__c comparison = appGroupLinksMap.get(appGroupLink.Application_Version__r.Application_Name__c);
                    if (comparison.Application_Version__r.Application_Version__c < appGroupLink.Application_Version__r.Application_Version__c) {
                        appGroupLinksMap.put(appGroupLink.Application_Version__r.Application_Name__c, appGroupLink);
                    }
                }
            }

            // Loop through the newest apps and count who has them and who doesn't
            List<String> appIds = new List<String>();
            for (String appName : appGroupLinksMap.keySet()) {
                appIds.add(appGroupLinksMap.get(appName).Application_Version__r.Id);
            }

            // Create a map of the applications that are being used so we can fill the details in
            String query =
                'SELECT '                             +
                    'Id, '                            +
                    'Name, '                          +
                    'Application_Name__c, '           +
                    'Version_Name_Human_Readable__c ' +
                'FROM '                               +
                    'Application_Version__c '         +
                'WHERE '                              +
                    'Id IN (' + MetricHelpers.generateCommaSeperatedString(appIds, true) + ')';
            System.debug(LoggingLevel.INFO, query);
            Application_Version__c[] applications = database.query(query);
            Map<String, Application_Version__c> appMap = new Map<String, Application_Version__c>(); 
            for (Application_Version__c application : applications) {
                String appId = (String)application.Id;
                appMap.put(appId, application);
            }

            // Get the IMEIs for this group
            List<String> imeis = getImeiList(this.groups.get(0));
            
            // For each application that we are looking at go and find the counts
            List<ApplicationGroupWrapper> counts = new List<ApplicationGroupWrapper>();

            AggregateResult[] appPersonCounts = database.query(SoqlHelpers.getApplicationPersonCount(appIds, imeis));
            Set<String> foundAppIds = new Set<String>();
            for (AggregateResult appPersonCount :appPersonCounts) {
                Integer total = (Integer)(appPersonCount.get('total'));
                String appId = (String)(appPersonCount.get('app'));
                foundAppIds.add(appId);
                Application_Version__c appVer = appMap.get(appId);
                ApplicationGroupWrapper applicationGroupWrapper = new ApplicationGroupWrapper(appVer.Application_Name__c + ' ' + appVer.Version_Name_Human_Readable__c, total, this.groupTotalMap.get(this.groups.get(0)).Membership_Count__c.intValue() - total, this.groups.get(0), appId);
                counts.add(applicationGroupWrapper);
            }

            // Loop through the apps and check that they were found. If not then create empty groups
            for (String appId : appIds) {
                if (!foundAppIds.contains(appId)) {
                    Application_Version__c appVer = appMap.get(appId);
                    ApplicationGroupWrapper applicationGroupWrapper = new ApplicationGroupWrapper(appVer.Application_Name__c + ' ' + appVer.Version_Name_Human_Readable__c, 0, this.groupTotalMap.get(this.groups.get(0)).Membership_Count__c.intValue(), this.groups.get(0), appId);
                    counts.add(applicationGroupWrapper);
                }
            }

            setApplicationGroupList(counts);
            System.debug(LoggingLevel.INFO, 'Showing ' + counts.size() + ' in list');
            setShowApplicationGroupList(true);
            setShowPeopleList(false);
        }
        else {

            // Add the error message. Front end should not let us get here
            setErrorMsg('Please select one group only');
            setShowApplicationGroupList(false);
            setShowPeopleList(false);
        }
        return null;
    }

    /**
     *  Show a list of people of either have an application in a group  or who don't
     *
     *  @param groupId       - Id of the group we are looking at
     *  @param applicationId - Id of the application we are looking at
     *  @param have          - true if they have this app, false if not
     */
    public PageReference getPeopleGroupApplication(String groupId, String applicationId, String have) {

        // Get the people we are looking for
        String query =
            'SELECT '               +
                'Id, '              +
                'First_Name__c, '   +
                'Last_Name__c, '    +
                'District__c, '     +
                'District_Name__c, '     +
                'Parish__c, '       +
                'Village__c, '      +
                'Mobile_Number__c ' +
            'FROM '                 +
                'Person__c '        +
            'WHERE '                +
                'Handset__c ';

        // Negate if required
        if (have.equals('false')) {
            query = query + ' NOT ';
        }
        query = query + 'IN ( '                                                 +
                    'SELECT '                                                   +
                        'Handset__c '                                           +
                    'FROM '                                                     +
                        'Handset_Application_Association__c '                   +
                    'WHERE '                                                    +
                        'Application_Version__r.Id = \'' + applicationId + '\'' +
                ') '                                                            +
                'AND Id IN ( '                                                  +
                    'SELECT '                                                   +
                        'Person__c '                                            +
                    'FROM '                                                     +
                        'Person_Group_Association__c '                          +
                    'WHERE '                                                    +
                        'Group__c = \'' + groupId + '\''                        +
                ')';
        System.debug(LoggingLevel.INFO, query);
        Person__c[] people = database.query(query);
        if (people.size() == 0) {
            setErrorMsg('No people matched the group and application you selected');
            setShowPeopleList(false);
            setShowApplicationGroupList(false);
        }
        else {
            setShowPeopleList(true);
            setShowApplicationGroupList(false);
            System.debug(LoggingLevel.INFO, 'Returning ' + people.size() + ' people.');
        }
        setApplicationGroupPersonList(people);
        return null;
    }

    /**
     *  Get the parameters from the visualforce page
     *
     *  @return - Boolean stating if the parameters passed in are valid. They always should be as the
     *            js validation on the front end should catch it.
     */
    private void getParameters() {

        this.applications = Apexpages.currentPage().getParameters().get('applicationsParam').split(',');
        this.groups = Apexpages.currentPage().getParameters().get('groupsParam').split(',');
    }

    private Boolean checkParameters() {

        // Check that we have some valid parameters
        if (this.applications.size() == 0 && this.groups.size() == 0) {
            return false;
        }
        return true;
    }

    /**
     *  Generate a set of unique applicationIds from a list of Application_Version_Group_Association__c
     */
    private set<String> getApplicationIds(List<Application_Version_Group_Association__c> appVersionGroups) {

        Set<String> appIds = new Set<String>();
        for (Application_Version_Group_Association__c appVersionGroup : appVersionGroups) {
            appIds.add((String)appVersionGroup.Application_Version__c);
        }
        return appIds;
    }

    private void setGroupMap(List<String> groupId) {

        this.groupTotalMap = new Map<String, Group__c>();
        String query =
            'SELECT '                  +
                'Id, '                 +
                'Name, '               +
                'Membership_Count__c ' +
            'FROM '                    +
                'Group__c '            +
            'WHERE '                   +
                'Id IN (' + MetricHelpers.generateCommaSeperatedString(groupId, true) + ')';
        System.debug(LoggingLevel.INFO, query);
        Group__c[] groups = database.query(query);

        for (Group__c groupToAdd : groups) {
            this.groupTotalMap.put(groupToAdd.Id, groupToAdd);
        }
    }

    private List<String> getImeiList(String groupId) {

        List<String> imeis = new List<String>();
        Person__c[] persons = database.query(SoqlHelpers.getGroupMemberInfo(groupId));
        for (Person__c person : persons) {
            imeis.add(person.Handset__r.IMEI__c);
        }
        return imeis;
    }

    public static testMethod void testController() {

        PageReference pageRef = Page.ApplicationManagement;

        Test.setCurrentPageReference(pageRef);
        ApplicationManagementController controller = new ApplicationManagementController();

        List<String> groupIds = new List<String>();
        Group__c currentGroup = new Group__c();
        database.insert(currentGroup);
        groupIds.add((String)currentGroup.Id);

        controller.groups = groupIds;

        Person__c person = Utils.createTestPerson('', 'TESTME', true, null, 'Female');
        database.insert(person);

        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Person__c = person.Id;
        pga.Group__c = currentGroup.Id;
        database.insert(pga);

        Application_Version__c application = [SELECT Id FROM Application_Version__c WHERE Application_Available__c = true LIMIT 1];
        List<String> applicationIds = new List<String>();
        applicationIds.add((String)application.Id);

        Application_Version_Group_Association__c appVerAssoc = new Application_Version_Group_Association__c();
        appVerAssoc.Application_Version__c = application.Id;
        appVerAssoc.Group__c = currentGroup.Id;
        database.insert(appVerAssoc);

        controller.applications = applicationIds;
        controller.setGroupMap(groupIds);
        controller.getImeiList(groupIds.get(0));
        controller.setGroupsList(controller.getGroupsList());
        controller.setApplicationsList(controller.getApplicationsList());
        controller.setErrorMsg('ERROR');
        controller.setErrorMsg('ERROR');
        controller.getErrorMsg();
        controller.addApplications();
        controller.showApplicationsGroupCount();
        controller.showGroupsApplicationCount();
        controller.getPeopleGroupApplication(controller.groups.get(0), controller.applications.get(0),'true');
        controller.getPeopleGroupApplication(controller.groups.get(0), controller.applications.get(0),'false');
        controller.removeApplications();
    }
}