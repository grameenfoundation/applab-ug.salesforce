public with sharing class IconLocationsFeedUpdater {
/**
 *  Class updates ICON Weather Feed Location Ids for Subcounties 
 */

    private Map<string,string> subcountyLocationIds;
    private Map<Subcounty__c, Person__c> subcountiesWithNoLocationIds ; 
    private List<Subcounty__c> subcountiesToUpdate;
    private String serverUrl;

    public IconLocationsFeedUpdater(){
        this.subcountyLocationIds = new Map<string,string>();
        this.subcountiesWithNoLocationIds= new Map<Subcounty__c, Person__c>();
        this.subcountiesToUpdate = new Subcounty__c[]{};
        initializeServerConstants();
    }

    @Future(callout=true)
    public static void updateIconLocations(){

         try {
            IconLocationsFeedUpdater iconLocationsFeedUpdater = new IconLocationsFeedUpdater();

            // Get subcounties with no locations ids
            iconLocationsFeedUpdater.getSubCounties();

            // Make http post
            iconLocationsFeedUpdater.getIconLocations();

            // Update Subcounties with location Ids
            iconLocationsFeedUpdater.markSubcountiesForUpdate();
        }
        catch (Exception e) {

            System.debug(LoggingLevel.DEBUG, 'An error occured');
            ErrorLog.writeLater('IconLocationsFeedUpdater', 'updateIconLocationsInfo', e.getMessage(), 1);
        }
    }

    private void initializeServerConstants() {

        Server_Configuration__c configuration = [
            SELECT
                Base_URL__c,
                Search_Path__c
            FROM
                Server_Configuration__c
            LIMIT 1];
        this.serverUrl = configuration.Base_URL__c + configuration.Search_Path__c;		
    }

    /**
     *  Calls Servlet in back end to pick the locaction Ids
     */
    private void getIconLocations(){

        String requestBody = this.constructRequestXml(this.subcountiesWithNoLocationIds);
        String queryResult = SqlHelpers.postServletRequest(this.serverUrl, 'updateIconLocationsFeed', requestBody);
        parseIconLocationIdsXml(queryResult, this.subcountyLocationIds);
    }

    /**
     *  Gets All Subcounties with no location Ids
     */
    private void getSubCounties() {

        for (CKW__c [] ckws : [
            SELECT
                Person__c,
                Person__r.Subcounty__c,
                Person__r.Subcounty__r.Id,
                Person__r.Subcounty__r.Name,
                Person__r.Subcounty__r.Latitude__c,
                Person__r.Subcounty__r.Longitude__c,
                Person__r.Subcounty__r.Location_Id__c,
                Person__r.Subcounty__r.District__c,
                Person__r.GPS_Location_E__c,
                Person__r.GPS_Location_N__c,
                Person__r.Id
            FROM
                CKW__c
            WHERE (
                (Person__r.Subcounty__r.Location_Id__c = NULL)
                AND (Person__r.Subcounty__c != NULL))
                AND (Person__r.GPS_Location_E__c != NULL)
                AND (Person__r.GPS_Location_N__c!= NULL)
        ]){

            //Add subcounty to collection
            for (CKW__c ckw: ckws) {
                if (subcountiesWithNoLocationIds.get(ckw.Person__r.Subcounty__r) == null) {
                    subcountiesWithNoLocationIds.put(ckw.Person__r.Subcounty__r, ckw.Person__r);
                }
            }
        }
    }

    /**
     * Construct the Xml request for the post body of the Servlet request
     *
     * @param subcountiesWithNoLocationIds - A map of the Subcounty and a Person Object pairs
     *
     * @return - String representation of the xml for request
     */
    private String constructRequestXml(Map<Subcounty__c, Person__c> subcountiesWithNoLocationIds) {

        Set<Subcounty__c> keys = subcountiesWithNoLocationIds.keySet();
        String requestBody = '<?xml version="1.0"?>' +
            '<locations>';
            for (Subcounty__c key : keys) {
                requestBody += '<location>' +
                '<subcounty_id>' + key.Id + '</subcounty_id>' +
                '<longitude>' + subcountiesWithNoLocationIds.get(key).GPS_Location_E__c + '</longitude>' +
                '<latitude>' + subcountiesWithNoLocationIds.get(key).GPS_Location_N__c + '</latitude>' +
                '</location>';
            }
            requestBody = requestBody +  '</locations>';

        return requestBody;
    }

    /**
     * Calls the parseIconLocationIdsRow that parses each <location../> tag in the Servlet response
     *
     * @param iconLocationIdsXml   - A String representation of the Xml returned from the UpdateIconLocationsFeed Servlet Call
     * @param subcountyLocationIds - Name value pairs of Subcounties and Location Ids
     */
    private void parseIconLocationIdsXml(String iconLocationIdsXml, Map<string,string> subcountyLocationIds){

        XmlStreamReader iconLocationIdsReader = new XmlStreamReader(iconLocationIdsXml);

        // Skip the opening <locations> tag
        iconLocationIdsReader.next();

        while (iconLocationIdsReader.hasNext()) {
            if (iconLocationIdsReader.isStartElement()) {
                parseIconLocationIdsRow(iconLocationIdsReader, subcountyLocationIds);
            }
            iconLocationIdsReader.next();
        }
    }

    /**
     * Gets the Subcounty Id and Location Id from each <location../>
     *
     * @param iconLocationIdsReader - XmlStreamReader
     * @param subcountyLocationIds  - Name value pairs of Subcounties and Location Ids
     */
    private void parseIconLocationIdsRow(XmlStreamReader iconLocationIdsReader, Map<string,string> subcountyLocationIds){

        if (iconLocationIdsReader.getLocalName() == 'location') {

            // Skip the <location> tag
            iconLocationIdsReader.next();
            String subcountyId= parseElement(iconLocationIdsReader);
            String locationId = parseElement(iconLocationIdsReader);
            subcountyLocationIds.put(subcountyId,locationId );
        }
    }

    /**
     * Calls database to update marked Subcounties with locations Ids. 
     */
    public void markSubcountiesForUpdate() {

        Set<Subcounty__c> keys = subcountiesWithNoLocationIds.keySet();

        for (Subcounty__c currentSubcounty : keys) {
            if (subcountyLocationIds.containsKey(currentSubcounty.Id) ){
                currentSubcounty.Location_Id__c = subcountyLocationIds.get(currentSubcounty.Id);
                subcountiesToUpdate.add(currentSubcounty);
            }
        }

        //Save Subcounties 
        Database.SaveResult[] updateResults = Database.update(subcountiesToUpdate);
        for (Database.SaveResult result : updateResults) {
            if (!result.isSuccess()) {
                ErrorLog.writeLater('IconLocationsFeedUpdater', 'updateSubcountyIconLocationIds',
                    'Failed to update Subcounty object: ' + result.getId(), 2);
            }
        }
    }

    /**
     * Gets text value from an Xml Element
     *
     * @param reader - XmlStreamReader
     *
     * @return - String representing text value in the Xml element.
     */
    private String parseElement(XmlStreamReader reader) {

        reader.next(); // skip the opening <column> tag

        String result = reader.getText();

        reader.next(); // move on to the next element
        reader.next(); // skip the closing </column> tag

        return result;
}

  private String fakeIconLocationsQuery() {

        String query = '<?xml version="1.0" encoding="utf-8"?>' +
            '<locations>' +
                '<location><subcounty_id>CKW-10-000250</subcounty_id><longitude>48.55</longitude><latitude>34.8</latitude></location>' +
                '<location><subcounty_id>CKW-10-000250</subcounty_id><longitude>48.55</longitude><latitude>34.8</latitude></location>' +
                '<location><subcounty_id>CKW-10-000250</subcounty_id><longitude>48.55</longitude><latitude>34.8</latitude></location>' +
                '<location><subcounty_id>CKW-10-000250</subcounty_id><longitude>48.55</longitude><latitude>34.8</latitude></location>' +
            '</locations>';

        return query;
    }

    private String fakeIconLocationsResponse() {

        String result = '<?xml version="1.0" encoding="utf-8"?>' +
            '<locations>' +
                '<location><subcounty_id>axio00003432</subcounty_id><location_id>1093423478</location_id></location>' +
                '<location><subcounty_id>axio00003456</subcounty_id><location_id>1093423334</location_id></location>' +
                '<location><subcounty_id>axio00003434</subcounty_id><location_id>1332434433</location_id></location>' +
                '<location><subcounty_id>axio00003467</subcounty_id><location_id>4566666666</location_id></location>' +
           '</locations>';

        return result;
    }

    static testMethod void testGetSubcountiesWithNoLocationIds(){
        IconLocationsFeedUpdater iconLocationsFeedUpdater = new IconLocationsFeedUpdater();  
        iconLocationsFeedUpdater.getSubCounties();
        String xml = iconLocationsFeedUpdater.constructRequestXml(iconLocationsFeedUpdater.subcountiesWithNoLocationIds);
        System.debug(xml);
    }


    static testMethod void testIconLocationsParsing() {

        IconLocationsFeedUpdater iconLocationsFeedUpdater = new IconLocationsFeedUpdater();                
        iconLocationsFeedUpdater.parseIconLocationIdsXml(iconLocationsFeedUpdater.fakeIconLocationsResponse(), iconLocationsFeedUpdater.subcountyLocationIds);
        Set<String> keys = iconLocationsFeedUpdater.subcountyLocationIds.keySet();

        System.debug('Size of subcounty locations data set: ' + keys.size() + '\n');
        System.debug('Subcounty Locations: \n');

        for (String key : keys) {
            System.debug(key + ': ' + iconLocationsFeedUpdater.subcountyLocationIds.get(key) + '\n');            
        }
    }

    static testMethod void testGetSubCountyObjects() {

        Integer subCountyCount = 0;
        IconLocationsFeedUpdater iconLocationsFeedUpdater = new IconLocationsFeedUpdater();

        iconLocationsFeedUpdater.getSubCounties();
        
        subCountyCount = iconLocationsFeedUpdater.subcountiesWithNoLocationIds.size();

        // Create a test CKW and SubCounty 
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Latitude__c = 3.6;
        testSubcounty.Longitude__c = 67.2;
        testSubcounty.Display_Name__c = 'HERE';
        database.insert(testSubcounty);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.GPS_Location_E__c = '3.2';
        testPerson.GPS_Location_N__c = '0.3';
        testPerson.Subcounty__c = testSubcounty.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        database.insert(testCkw);

        iconLocationsFeedUpdater.getSubCounties();
        System.assertNotEquals(subCountyCount,  iconLocationsFeedUpdater.subcountiesWithNoLocationIds.size());
    }

}