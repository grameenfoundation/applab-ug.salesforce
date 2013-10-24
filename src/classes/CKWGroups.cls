public with sharing class CKWGroups {

    /*
     * Method to ensure that the membership count of the Group object is kept
     * up to date. This method is fired off a trigger when a Person_Group_Association
     * record is changed.
     *
     * @param groupId - A string representing the id of the group.
     */
    public static void updateMembershipCount(String groupId) {

        Integer membershipCount = [
            SELECT
                count()
            FROM
                Person__c
            WHERE
                id IN (
                    SELECT
                        Person__c
                    FROM
                        Person_Group_Association__c 
                    WHERE 
                        Group__c = :groupId
                )
            ];

        // Extract the group that is being updated
        Group__c groupToUpdate = [
            SELECT
                id,
                Membership_Count__c
            FROM
                Group__c
            WHERE
                id = :groupId];

        // Update the group with the new membership count
        groupToUpdate.Membership_Count__c = membershipCount;
        Database.update(groupToUpdate);
    }

    /*
     * Method to ensure that all the existing members of a group should actually be
     * in the group and that there are no members left out of the group that should
     * be in it.
     * Uses the Group__c.Membership_Query__c field to determine the query that defines
     * the group.
     *
     * @param groupId     - A string representing the id of the group.
     * @param queryString - The query to be run.
     */
    public static void updateMembership(String groupId, String queryString) {

        // Mark the group as updated. Done at the start otherwise the triggers
        // will recursively call.
        markGroupAsUpdated(groupId);

        // Get the target map of Persons that need to be in the group from the
        // Membership_Query__c field
        Map<ID, Person__c> targetMap = generateTargetMap(queryString);

        // Extract all the People that are already in the group
        Map<ID, ID> existingMemberMap = new Map<ID, ID>();

        // Create an empty list of People to store who needs to be deleted
        List<Person_Group_Association__c> membersToDelete = new Person_Group_Association__c[]{};

        // Iterate over the existing people and determine if they are in the target group
        for (Person_Group_Association__c member: [
            SELECT
                id,
                Person__c 
            FROM
                Person_Group_Association__c
            WHERE
                Group__c = :groupId]
        ) {
            if (!targetMap.containsKey(member.Person__c)) {
                membersToDelete.add(member);
            }

            // Add to the map for existing CKWs
            existingMemberMap.put(member.Person__c, member.id);
        }

        // Generate the list of Person_Group_Association__c that need to be
        // added to Salesforce
        List<Person_Group_Association__c> membersToAdd = 
            generateMembersToAddList(targetMap.keySet(), existingMemberMap, groupId);

        // Delete the members that should not be there
        database.delete(membersToDelete);

        // Insert the new members of the group
        database.insert(membersToAdd);
    }

    /*
     * This method is to be run from the schedular. Will just set the Needs_Update
     * field to true so that the triggers on the Group object will fire to update the
     * membership of the groups and the count.
     */
    public static void markGroupsForUpdate() {

        // Dig out all the group ids.  Cannot filter on Membersip_Query__c
        // due to its data type. Hence the extra work in the for loop
        Group__c[] groups = [
            SELECT
                id,
                Need_Update__c,
                Membership_Query__c
            FROM
                Group__c];

        List<Group__c> groupsToUpdate = new Group__c[]{};

        for (Group__c currentGroup : groups) {
            if (currentGroup.Membership_Query__c != null) {

                // Set the Need Update field to true
                currentGroup.Need_Update__c = true;
                groupsToUpdate.add(currentGroup);
            }
        }

        // Update the groups.
        Database.update(groupsToUpdate);
    }

    /*
     * Helper method to signify that a group has had its membership updated.
     *
     * @param groupId     - A string representing the id of the group.
     */
    public static void markGroupAsUpdated(String groupId) {

        // Dig out the group
        Group__c groupToBeUpdated = [
            SELECT
                id,
                Need_Update__c
            FROM
                Group__c
            WHERE
                id = :groupId];

        // Set the Need Update field to false
        groupToBeUpdated.Need_Update__c = false;

        // Update the group
        Database.update(groupToBeUpdated);
    }

    /*
     * Helper method to extract the map of people that are already in a
     * group
     *
     * @param queryString - the query to be run to generate the membership
     *
     * @return - A map containing the target membership
     */
    public static Map<Id,Person__c> generateTargetMap(String queryString) {

        // Get the Person ids that are should be included in the group
        Map<ID, Person__c> targetMap = new Map<ID, Person__c>();

        // We cannot guarantee that the query has been entered correctly so
        // we need to catch errors. This is because it is a user entered query.
        // This should be validated in a Visual Force Page that add/edits the
        // groups
        try {

            // Query has been successfully run
            for (Person__c groupMember : database.query(queryString)) {
                targetMap.put(groupMember.id, groupMember);
            }
         } catch (Exception e) {
            ErrorLog.writeLater('CKWGroups.cls', 'generateTargetMap', e.getMessage(), 1);
        }
        return targetMap;
    }

    /*
     * Helper method to genreate the a list of Person_Group_Association__c
     * that need to be added to update the membership of the group
     *
     * @param targetKeyValues   - A set of ids of persons in the group already
     * @param existingMemberMap - A map of the existing members
     * @param groupId           - The id of the group these people are going
     *                            to join
     *
     * @return - A List of Person_Group_Association__c objects that need to be
     *             added to the Person_Groups_Association__c table
     */
    public static List<Person_Group_Association__c> generateMembersToAddList(Set<Id> targetKeyValues, Map<Id,String> existingMemberMap, String groupId) {

        List<Person_Group_Association__c> membersToAdd = new Person_Group_Association__c[]{};
        for (ID value: targetKeyValues) {
            if (!existingMemberMap.containsKey(value)) {

                //Create the new group association object
                Person_Group_Association__c newAssociation = new Person_Group_Association__c();
                newAssociation.Person__c = value;
                newAssociation.Group__c  = groupId;
                membersToAdd.add(newAssociation);

            }
        }
        return membersToAdd;
    }

    /*
     * Test Method to see if the group membership queries will update
     * the membership of a group successfully. This also tests the new
     * workflow and the added triggers.
     */
    static testMethod void updateGroup() {

        // Create a new test person object
        Person__c testPerson = new Person__c();
        testPerson.Fathers_Name__c = 'Davies';
        testPerson.First_Name__c   = 'Owen';

        // Create a new test group object
        String groupId = 'Test Davies Group';
        Group__c testGroup   = new Group__c();
        testGroup.Membership_Count__c = 0;
        testGroup.Membership_Query__c = null;
        testGroup.Name = groupId;
        testGroup.Need_Update__c = false;
        testGroup.Active__c      = true;

        Database.insert(testPerson);
        Database.insert(testGroup);

        System.debug('DOING THE TEST FOR UPDATE GROUP');

        Group__c groupBefore = [
            SELECT
                id,
                Membership_Count__c
            FROM
                Group__c
            WHERE
                Name = :groupId
            LIMIT 1];
        Decimal countBefore = groupBefore.Membership_Count__c;
        System.debug('Before WE GET GOING' + groupBefore.Membership_Count__c);

        // This should fire the workflow that updates the test davies group
        testGroup.Membership_Query__c = 'SELECT id, First_Name__c FROM Person__c WHERE Fathers_Name__c = \'Davies\'';
        Database.update(testGroup);

        Group__c groupEnd = [
            SELECT
                Membership_Count__c
            FROM
                Group__c
            WHERE
                Name = :groupId
            LIMIT 1];
        Decimal countEnd = groupEnd.Membership_Count__c;
        System.debug('End ONCE WE HAVE UPDATED EVERYTHING' + countEnd);
    }

    /**
     * This test method should fire the workflow that set the group to 
     * needing updating.  This in turn should fire the UpdateGroupMembership
     * trigger which will the fire the UpdateGroupMembershipCount trigger.
     */
    static testMethod void updateMembershipQuery() {

        // Create a new test person object
        Person__c testPerson = new Person__c();
        testPerson.Fathers_Name__c = 'Davies';
        testPerson.First_Name__c   = 'Owen';

        // Create a new test group object
        String groupId = 'Test Davies Group';
        Group__c testGroup   = new Group__c();
        testGroup.Membership_Count__c = 0;
        testGroup.Membership_Query__c = null;
        testGroup.Name = groupId;
        testGroup.Need_Update__c = false;
        testGroup.Active__c      = true;
        
        Database.insert(testPerson);
        Database.insert(testGroup);
        
        String testQuery = 'SELECT id FROM Person__c WHERE id IN (SELECT Person__c FROM CKW__c)';
        Group__c groupToUpdate = [
            SELECT
                id,
                Membership_Query__c
            FROM
                Group__c
            WHERE
                Name = :groupId];

        groupToUpdate.Membership_Query__c = testQuery;

        Database.update(groupToUpdate);
    }

    /**
     * Test method to see if changing the members of a group will fire the
     * membership count trigger. This method deals with both adding and
     * deleting a member of the group.
     */
    static testMethod void changeGroupMembership() {


        // Create a new test person object
        Person__c testPerson = new Person__c();
        testPerson.Fathers_Name__c = 'Davies';
        testPerson.First_Name__c   = 'Owen';

        // Create a new test group object
        String groupId = 'Test Davies Group';
        Group__c testGroup   = new Group__c();
        testGroup.Membership_Count__c = 0;
        testGroup.Membership_Query__c = null;
        testGroup.Name = groupId;
        testGroup.Need_Update__c = false;
        testGroup.Active__c      = true;

        Database.insert(testPerson);
        Database.insert(testGroup);

        Group__c groupBefore = [
            SELECT
                id,
                Membership_Count__c
            FROM
                Group__c
            WHERE
                Name = :groupId
            LIMIT 1];
        Decimal countBefore = groupBefore.Membership_Count__c;
        System.debug('Before ' + groupBefore.Membership_Count__c);    

        Person__c[] p = [
            SELECT
                id
            FROM
                Person__c
            WHERE
                First_Name__c = 'Owen'];

        Person_Group_Association__c testAssociation = new Person_Group_Association__c();
        testAssociation.Group__c  = groupBefore.id;
        testAssociation.Person__c = p[0].id;
        database.insert(testAssociation);

        Group__c groupMiddle = [
            SELECT
                Membership_Count__c
            FROM
                Group__c
            WHERE
                Name = :groupId
            LIMIT 1];
        Decimal countMiddle = groupMiddle.Membership_Count__c;
        System.debug('Middle ' + countMiddle);

        Person_Group_Association__c[] del = [
            SELECT
                id
            FROM
                Person_Group_Association__c
            WHERE
                Group__c = : groupBefore.id
                AND Person__c = : p[0].id];
        database.delete(del);

        Group__c groupEnd = [
            SELECT
                Membership_Count__c
            FROM
                Group__c
            WHERE
                Name = :groupId
            LIMIT 1];

        Decimal countEnd = groupEnd.Membership_Count__c;
        System.debug('End ' + countEnd);
        updateMembershipCount(testGroup.id);
        updateMembership(testGroup.id, 'SELECT Name FROM Person__c LIMIT 100');
        markGroupsForUpdate();
    }
}