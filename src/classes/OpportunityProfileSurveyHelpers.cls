/**
 *  Helper class to process the Opportunity Int'l AgriculturalClientMap Survey
 */
public with sharing class OpportunityProfileSurveyHelpers {

    private static Map<String, String> subcountyMap = null;

    /**
     *  Fill in the FarmerLand__c objects for this interviewee/Farmer
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param intervieweeId - The Person__r Id for the Opportunity Farmer to whom the survey was administered
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the person that administered the survey if required.
     */
    public static List<String> processClientProfileSurvey(Map<String, Submission_Answer__c> answers, Id intervieweeId) {

        boolean opportunityFarmerExists = false;
        boolean landExists = false;

        opportunityFarmerExists = checkIfOpportunityFarmerExists(answers);

        // Check if Opportunity Farmer already exists
         if (opportunityFarmerExists) {

            // Opportunity Farmer does exists so return an error
            return new String[] { '0', 'The Opportunity Farmer ' + answers.get('q7_0').Answer__c + ' ' + answers.get('q6_0').Answer__c + ': already exists in our System. Contact tech team', 'SUPRESSMSG' };
        }

        // Create contact, person and opportunity farmer 
        Contact contact = new Contact(AccountId = getAccountId(), LastName=answers.get('q7_0').Answer__c, FirstName=answers.get('q6_0').Answer__c);
        Person__c person = new Person__c();
        Opportunity_Farmer__c oppFarmer = new Opportunity_Farmer__c();

        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save contact and get the id back
        String errorMessage;
        Database.SaveResult contactSaveResult = database.insert(contact);
        if (!contactSaveResult.isSuccess()) {
            for (Database.Error error : contactSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            Database.rollback(sp);
            return new String[]{ '0', errorMessage, 'Your submission of the Agricultural Client Survey had an error in it please check the form. If you repeatedly get this message contact support' };       
        }

        person.First_Name__c = answers.get('q6_0').Answer__c;
        person.Middle_Name__c = answers.get('q8_0').Answer__c;
        person.Last_Name__c = answers.get('q7_0').Answer__c;
        person.Parish__c = answers.get('q45_0').Answer__c;
        person.Type__c = 'Opportunity Farmer';

        person.Contact__c = contact.Id;

        // Translate the single/multiple selects
        person.Gender__c = ProcessSubmissionHelpers.translateGender(answers.get('q25_0').Answer__c);

        String districtValue = answers.get('q30_0').Answer__c;
        String districtName = translateDistrictName(districtValue);
        District__c district = ProcessSubmissionHelpers.getDistrict(districtName);

        String subcountyName = '';
        subcountyName = getSubcountyMap().get(translateSubcountyName(answers, districtValue));
        System.debug('Subcounty: ' + subcountyName);
        Subcounty__c[] subcounty = [
                                    SELECT
                                        Id
                                    FROM
                                        Subcounty__c
                                    WHERE
                                        Display_Name__c = :subcountyName
                                    AND 
                                        District__c = :district.Id
                                    LIMIT 1
                                   ];
        if (subcounty.isEmpty()) {

           // Subcounty does not exist so return an error
           return new String[] { '0', 'Subcounty with name ' + subcountyName + ' is not in the system', 'SUPRESSMSG' };
        }

        person.Subcounty__c = subcounty[0].Id;
        person.District__c = district.Id;

        // Calculate the age of the person. Should this be a formula on Person
        // DOB comes in with the format YYYY-MM-dd (2011-09-30)
        Date dob = ProcessSubmissionHelpers.calculateDob(answers.get('q26_0').Answer__c);
        if (dob != null) {
            person.Date_of_Birth__c = dob;
            person.Age__c = ProcessSubmissionHelpers.calculateAge(dob);
           
        }

        // Save the person and get the id back
        Database.SaveResult personSaveResult = database.insert(person);
        Id personId;
        if (!personSaveResult.isSuccess()) {
            for (Database.Error error : personSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            Database.rollback(sp);
            return new String[]{ '0', errorMessage, 'Your submission of the Agricultural Client Survey had an error in it please check the form. If you repeatedly get this message contact support' };       
        }

        personId = personSaveResult.getId();

        // Populate and save the Opportunity Farmer
        oppFarmer.Person__c = personId;
        Database.SaveResult oppFarmerSaveResult = database.insert(oppFarmer);
        if (!oppFarmerSaveResult.isSuccess()) {
            for (Database.Error error : oppFarmerSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            Database.rollback(sp);
            return new String[]{ '0', errorMessage, 'Your submission of the Agricultural Client Survey had an error in it please check the form. If you repeatedly get this message contact support' };     
        }

        // Create this Opportunity Farmer's Land
        List<Coordinates> farmerLandCoordinatesList = new List<Coordinates>();

        // Check if farmer already has land
        landExists = checkIfFarmerLandExists(oppFarmer);

        if (landExists){
            deleteFarmerLand(oppFarmer);
        }

        // Loop through the answers and pull out the FarmerLand Markers
        Integer counter = 0;

        FarmerLand__c newFarmerLand = new FarmerLand__c();
        newFarmerLand.Opportunity_Farmer__c = oppFarmer.Id;

        while (answers.containsKey('q87_' + counter)) {
            Coordinates coordinate = new Coordinates();

            // Add gps if it is there
            if (answers.containsKey('q87_' + counter)) {
                String[] locationArray = answers.get('q87_' + counter).Answer__c.split(' ');
                if (locationArray != null && locationArray.size()>= 2) {
                    coordinate.Latitude = Decimal.valueOf(locationArray[0]);
                    coordinate.Longitude = Decimal.valueOf(locationArray[1]);
                }
            }

            farmerLandCoordinatesList.add(coordinate);
            counter++;
       }

       //Serialise coordinates list and assign it to the FarmerLand Coordinates field
       newFarmerLand.Coordinates__c = JSON.serialize(farmerLandCoordinatesList);

       farmerLandCoordinatesList.clear();

       // Insert the new farmerland entries into the db
       if (newFarmerLand != null) {
           database.insert(newfarmerLand);
       }
       else {
           return new String[]{ '0', 'FarmerLand not created', 'SUPRESSMSG' };
       }
       return new String[]{ '1', 'Opportunity farmer profile now in Salesforce: '+ oppFarmer , 'Opportunity farmer profile now in Salesforce: '+ oppFarmer };
    }

    /**
     * Get the Account Id to be used to create a Contact
     *
     *  @return - Id: AccountId
     */    
    private static Id getAccountId(){

        Account[] account =
                            [SELECT
                                Id
                            FROM
                                Account
                            WHERE
                                Name = 'Opportunity International'
                            LIMIT 1];
        if (account.isEmpty()) {
            return null;
        }
        else {
            return account[0].Id;
        }
    }

    /**
     * Check if the Opportunity Farmer being profiled already exists
     *
     *  @param answers - A map of the answers submitted for the survey
     *
     *  @return - boolean flag (true if they exist)
     */
    private static boolean checkIfOpportunityFarmerExists(Map<String, Submission_Answer__c> answers){
        Opportunity_Farmer__c[] existingOpportunityFarmer = database.query(buildOpportunityFarmerQueryString(answers));
        if (existingOpportunityFarmer.isEmpty()) {
            return false;
        }
        return true;
    }

    /**
     * Build query to check if the Opportunity Farmer being profiled already exists
     *
     *  @param answers - A map of the answers submitted for the survey
     *
     *  @return - String query
     */
    private static String buildOpportunityFarmerQueryString(Map<String, Submission_Answer__c> answers) {

        String query = 'SELECT ' +
                'Id ' +
            'FROM ' +
                'Opportunity_Farmer__c ' +
            getWhereClause(answers);
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Construct 'WHERE' clause to check if the FirstName + LastName + MiddleName combo already
     *  exists for an Opportunity Farmer being profiled
     *
     *  This is a meantime solution as Opportunity is yet to decide on using ID's to check uniqueness
     *
     *  @param answers - A map of the answers submitted for the survey
     *
     *  @return - 'where' clause string
     */
    private static String getWhereClause(Map<String, Submission_Answer__c> answers) {

        List<String> whereClauses = new List<String>();
        if (!String.isEmpty(answers.get('q6_0').Answer__c)) {
            whereClauses.add(' Person__r.First_Name__c = \'' + answers.get('q6_0').Answer__c + '\'');
        }
        if (!String.isEmpty(answers.get('q7_0').Answer__c)) {
            whereClauses.add(' Person__r.Last_Name__c = \'' + answers.get('q7_0').Answer__c + '\'');
        }
        if (!String.isEmpty(answers.get('q8_0').Answer__c)) {
            whereClauses.add(' Person__r.Middle_Name__c = \'' + answers.get('q8_0').Answer__c + '\'');
        }
        String clause = '';
        if (whereClauses.size() > 0) {
            clause = 'WHERE' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        return clause;
    }

/**
     *  Get the district name out of the survey
     *
     *  @param districtValue - A map containing the values for the the districts
     *
     *  @return - string Name of the district
     */
    private static String translateDistrictName(String districtValue) {

        Map<String, String> translationMap = null;
        translationMap = new Map<String, String> {
            '1' => 'Jinja',
            '2' => 'Mayuge',
            '3' => 'Iganga',
            '4' => 'Namutumba',
            '5' => 'Bugiri',
            '6' => 'Kamuli',
            '7' => 'Mbale',
            '8' => 'Budaka',
            '9' => 'Soroti',
            '10' => 'Sironko',
            '11' => 'Pallisa',
            '12' => 'Manafwa',
            '13' => 'Katakwi',
            '14' => 'Kumi'
        };
        return translationMap.get(districtValue);
    }

     /**
     *  Get the subcounty from District name basing on the binding and value of the ditrict
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - String Name of the subcounty
     */
    private static String translateSubcountyName(Map<String, Submission_Answer__c> answers, String districtBinding) {

        String subcountyName = '';
        if (districtBinding.equals('1')) {

            // Jinja
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kimaka',
                '2' => 'Butembe',
                '3' => 'Mafubira',
                '4' => 'Jinja Municipality',
                '5' => 'Masese',
                '6' => 'Walukuba',
                '7' => 'Mpumudde',
                '8' => 'Budondo',
                '9' => 'Buwenge'
            };
            subcountyName = translationMap.get(answers.get('q31_0').Answer__c);
        }
         if (districtBinding.equals('2')) {

            // Mayuge
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Bukatuube',
                '2' => 'Busakira',
                '3' => 'Imanyiro',
                '4' => 'Kigandalo',
                '5' => 'Malango',
                '6' => 'Wairasa',
                '7' => 'Bukabooli',
                '8' => 'Kiterera',
                '9' => 'Mayuge Town Council',
                '10' => 'Jaguzi Islands',
                '11' => 'Baitambogwe',
                '12' => 'Mpungwe'
            };
            subcountyName = translationMap.get(answers.get('q32_0').Answer__c);
        }
         if (districtBinding.equals('3')) {

            // Iganga
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Luuka',
                '2' => 'Bukanga',
                '3' => 'Nawandala',
                '4' => 'Nabitende',
                '5' => 'Namungwale',
                '6' => 'Nakalama',
                '7' => 'Buyunga',
                '8' => 'Iganga TC',
                '9' => 'Nakigo'
            };
            subcountyName = translationMap.get(answers.get('q33_0').Answer__c);
        }
        if (districtBinding.equals('4')) {

            // Namutumba
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Bulange',
                '2' => 'Nsinze',
                '3' => 'Namutumba',
                '4' => 'Magada',
                '5' => 'Kibaale',
                '6' => 'Ivukula'
            };
            subcountyName = translationMap.get(answers.get('q34_0').Answer__c);
        }
        if (districtBinding.equals('5')) {

            // Bugiri
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Nabukalu',
                '2' => 'Iwemba',
                '3' => 'Buluguyi',
                '4' => 'Bulesa',
                '5' => 'Kapyanga',
                '6' => 'Bugiri TC',
                '7' => 'Buwunga',
                '8' => 'Nankoma',
                '9' => 'Bulidha',
                '10' => 'Muterere',
                '11' => 'Budhaya'
            };
            subcountyName = translationMap.get(answers.get('q35_0').Answer__c);
        }
        if (districtBinding.equals('6')) {

            // Kamuli
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kidera',
                '2' => 'Namasagali',
                '3' => 'Bugaya',
                '4' => 'Nkondo',
                '5' => 'Balawoli',
                '6' => 'Buyende',
                '7' => 'Kagulu',
                '8' => 'Wankole',
                '9' => 'Nabwigulu',
                '10' => 'Kamuli TC',
                '11' => 'Kitayunjwa',
                '12' => 'Nawanyango',
                '13' => 'Namwendwa',
                '14' => 'Mbulamuti',
                '15' => 'Bugulumbia',
                '16' => 'Bulopa',
                '17' => 'Kisozi'
            };
            subcountyName = translationMap.get(answers.get('q36_0').Answer__c);
        }
        if (districtBinding.equals('7')) {

            // Mbale
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Bufumbo',
                '2' => 'Busiu',
                '3' => 'Bumasikye',
                '4' => 'Budaka',
                '5' => 'Bukonde',
                '6' => 'Bongokho',
                '7' => 'Budwale',
                '8' => 'Bumbobi',
                '9' => 'Bukiende',
                '10' => 'Lwasso',
                '11' => 'Bukasakya',
                '12' => 'Wanale',
                '13' => 'Mutoto',
                '14' => 'Nakaloke',
                '15' => 'Lukhonge',
                '16' => 'Bubyangu',
                '17' => 'Namakwekwe',
                '18' => 'Nyondo',
                '19' => 'Bungokho Matoto',
                '20' => 'Busano',
                '21' => 'Busoba',
                '22' => 'Bungokho',
                '23' => 'Industrial Division'
            };
            subcountyName = translationMap.get(answers.get('q37_0').Answer__c);
        }
        if (districtBinding.equals('8')) {

            // Budaka
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kamonkoli',
                '2' => 'Iki-iki',
                '3' => 'Kaderuna',
                '4' => 'Kimeruka',
                '5' => 'Naboa',
                '6' => 'Budaka',
                '7' => 'Lyama'
            };
            subcountyName = translationMap.get(answers.get('q38_0').Answer__c);
        }
        if (districtBinding.equals('9')) {

            // Soroti
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kyere',
                '2' => 'Bugondo',
                '3' => 'Asuret',
                '4' => 'Katine',
                '5' => 'Kamuda',
                '6' => 'Arapai',
                '7' => 'Soroti Municipal council',
                '8' => 'Kadungulu'
            };
            subcountyName = translationMap.get(answers.get('q39_0').Answer__c);
        }
        if (districtBinding.equals('10')) {

            // Sironko
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Buhugu',
                '2' => 'Buteza',
                '3' => 'Buyobo',
                '4' => 'Bukhulo',
                '5' => 'Bumasifwa',
                '6' => 'Busulani',
                '7' => 'Zesui',
                '8' => 'Buwalasi',
                '9' => 'Butandiga'
            };
            subcountyName = translationMap.get(answers.get('q41_0').Answer__c);
        }
        if (districtBinding.equals('11')) {

            // Pallisa
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Gogonyo',
                '2' => 'Apopong',
                '3' => 'Kasodo',
                '4' => 'Agule',
                '5' => 'Pallisa',
                '6' => 'Pallisa TC',
                '7' => 'Puti Puti',
                '8' => 'Kamuge',
                '9' => 'Kameke',
                '10' => 'Kibale',
                '11' => 'Butebo',
                '12' => 'Patete',
                '13' => 'Kakoro',
                '14' => 'Kabwangasi'
            };
            subcountyName = translationMap.get(answers.get('q40_0').Answer__c);
        }
        if (districtBinding.equals('12')) {

            // Manafwa
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kaato',
                '2' => 'Buwagago',
                '3' => 'Sibanga',
                '4' => 'Bugobero',
                '5' => 'Butiru',
                '6' => 'Bubutu',
                '7' => 'Bumwoni',
                '8' => 'Bumbo',
                '9' => 'Buputo',
                '10' => 'Buwabwala'
            };
            subcountyName = translationMap.get(answers.get('q42_0').Answer__c);
        }
        if (districtBinding.equals('13')) {

            // Katakwi
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kapujan',
                '2' => 'Magoro',
                '3' => 'Ngariam',
                '4' => 'Toroma',
                '5' => 'Omodoi',
                '6' => 'Usuk',
                '7' => 'Ongongoja'
            };
            subcountyName = translationMap.get(answers.get('q43_0').Answer__c);
        }
        if (districtBinding.equals('14')) {

            // Kumi
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kapiri',
                '2' => 'Kobwin',
                '3' => 'Kanyum',
                '4' => 'Mukongoro',
                '5' => 'Atutur',
                '6' => 'Ongino',
                '7' => 'Nyero',
                '8' => 'Ngora',
                '9' => 'Mukura',
                '10' => 'Kumi Town'
            };
            subcountyName = translationMap.get(answers.get('q44_0').Answer__c);
        }
        return subcountyName;
    }

    /**
     *  Get Subcounty Map for the Subcounties the survey covers
     *
     *  @return - A map of subcounties and their display Names
     */
    private static Map<String, String> getSubcountyMap() {
        if (null == subcountyMap) {
            subcountyMap = new Map<String, String>();
            subcountyMap.put('Kimaka', 'Kimaka');
            subcountyMap.put('Butembe', 'Butembe');
            subcountyMap.put('Mafubira', 'Mafubira');
            subcountyMap.put('Jinja Municipality', 'Jinja Municipality');
            subcountyMap.put('Walukuba', 'Walukuba');
            subcountyMap.put('Mpumudde', 'Mpumudde');
            subcountyMap.put('Budondo', 'Budondo');
            subcountyMap.put('Buwenge', 'Buwenge');
            subcountyMap.put('Bukatuube', 'Bukatuube');
            subcountyMap.put('Busakira', 'Busakira');
            subcountyMap.put('Imanyiro', 'Imanyiro');
            subcountyMap.put('Kigandalo', 'Kigandalo');
            subcountyMap.put('Malango', 'Malango');
            subcountyMap.put('Wairasa', 'Wairasa');
            subcountyMap.put('Bukabooli', 'Bukabooli');
            subcountyMap.put('Kiterera', 'Kiterera');
            subcountyMap.put('Mayuge Town Council', 'Mayuge Town Council');
            subcountyMap.put('Jaguzi Islands', 'Jaguzi Islands');
            subcountyMap.put('Baitambogwe', 'Baitambogwe');
            subcountyMap.put('Mpungwe', 'Mpungwe');
            subcountyMap.put('Luuka', 'Luuka');
            subcountyMap.put('Bukanga', 'Bukanga');
            subcountyMap.put('Nawandala', 'Nawandala');
            subcountyMap.put('Nabitende', 'Nabitende');
            subcountyMap.put('Namungwale', 'Namungwale');
            subcountyMap.put('Nakalama', 'Nakalama');
            subcountyMap.put('Buyunga', 'Buyunga');
            subcountyMap.put('Iganga TC', 'Iganga TC');
            subcountyMap.put('Nakigo', 'Nakigo');
            subcountyMap.put('Bulange', 'Bulange');
            subcountyMap.put('Nsinze', 'Nsinze');
            subcountyMap.put('Namutumba', 'Namutumba');
            subcountyMap.put('Magada', 'Magada');
            subcountyMap.put('Kibaale', 'Kibaale');
            subcountyMap.put('Ivukula', 'Ivukula');
            subcountyMap.put('Nabukalu', 'Nabukalu');
            subcountyMap.put('Iwemba', 'Iwemba');
            subcountyMap.put('Buluguyi', 'Buluguyi');
            subcountyMap.put('Bulesa', 'Bulesa');
            subcountyMap.put('Kapyanga', 'Kapyanga');
            subcountyMap.put('Bugiri TC', 'Bugiri TC');
            subcountyMap.put('Buwunga', 'Buwunga');
            subcountyMap.put('Nankoma', 'Nankoma');
            subcountyMap.put('Nakigo', 'Nakigo');
            subcountyMap.put('Bulidha', 'Bulidha');
            subcountyMap.put('Muterere', 'Muterere');
            subcountyMap.put('Budhaya', 'Budhaya');
            subcountyMap.put('Kidera', 'Kidera');
            subcountyMap.put('Namasagali', 'Namasagali');
            subcountyMap.put('Bugaya', 'Bugaya');
            subcountyMap.put('Nkondo', 'Nkondo');
            subcountyMap.put('Balawoli', 'Balawoli');
            subcountyMap.put('Buyende', 'Buyende');
            subcountyMap.put('Kagulu', 'Kagulu');
            subcountyMap.put('Wankole', 'Wankole');
            subcountyMap.put('Nabwigulu', 'Nabwigulu');
            subcountyMap.put('Kamuli TC', 'Kamuli TC');
            subcountyMap.put('Kitayunjwa', 'Kitayunjwa');
            subcountyMap.put('Nawanyango', 'Nawanyango');
            subcountyMap.put('Namwendwa', 'Namwendwa');
            subcountyMap.put('Mbulamuti', 'Mbulamuti');
            subcountyMap.put('Bugulumbia', 'Bugulumbia');
            subcountyMap.put('Bulopa', 'Bulopa');
            subcountyMap.put('Kisozi', 'Kisozi');
            subcountyMap.put('Bufumbo', 'Bufumbo');
            subcountyMap.put('Busiu', 'Busiu');
            subcountyMap.put('Bumasikye', 'Bumasikye');
            subcountyMap.put('Budaka', 'Budaka');
            subcountyMap.put('Bukonde', 'Bukonde');
            subcountyMap.put('Bongokho', 'Bongokho');
            subcountyMap.put('Budwale', 'Budwale');
            subcountyMap.put('Bumbobi', 'Bumbobi');
            subcountyMap.put('Bukiende', 'Bukiende');
            subcountyMap.put('Lwasso', 'Lwasso');
            subcountyMap.put('Bukasakya', 'Bukasakya');
            subcountyMap.put('Wanale', 'Wanale');
            subcountyMap.put('Mutoto', 'Mutoto');
            subcountyMap.put('Nakaloke', 'Nakaloke');
            subcountyMap.put('Bubyangu', 'Bubyangu');
            subcountyMap.put('Lukhonge', 'Lukhonge');
            subcountyMap.put('Namakwekwe', 'Namakwekwe');
            subcountyMap.put('Nyondo', 'Nyondo');
            subcountyMap.put('Bungokho Matoto', 'Bungokho Matoto');
            subcountyMap.put('Busano', 'Busano');
            subcountyMap.put('Busoba', 'Busoba');
            subcountyMap.put('Bungokho', 'Bungokho');
            subcountyMap.put('Industrial Division', 'Industrial Division');
            subcountyMap.put('Kamonkoli', 'Kamonkoli');
            subcountyMap.put('Iki-iki', 'Iki-iki');
            subcountyMap.put('Kaderuna', 'Kaderuna');
            subcountyMap.put('Kimeruka', 'Kimeruka');
            subcountyMap.put('Naboa', 'Naboa');
            subcountyMap.put('Budaka', 'Budaka');
            subcountyMap.put('Lyama', 'Lyama');
            subcountyMap.put('Kyere', 'Kyere');
            subcountyMap.put('Bugondo', 'Bugondo');
            subcountyMap.put('Asuret', 'Asuret');
            subcountyMap.put('Katine', 'Katine');
            subcountyMap.put('Kamuda', 'Kamuda');
            subcountyMap.put('Arapai', 'Arapai');
            subcountyMap.put('Soroti Municipal council', 'Soroti Municipal council');
            subcountyMap.put('Kadungulu', 'Kadungulu');
            subcountyMap.put('Buhugu', 'Buhugu');
            subcountyMap.put('Buteza', 'Buteza');
            subcountyMap.put('Buyobo', 'Buyobo');
            subcountyMap.put('Bukhulo', 'Bukhulo');
            subcountyMap.put('Bumasifwa', 'Bumasifwa');
            subcountyMap.put('Busulani', 'Busulani');
            subcountyMap.put('Zesui', 'Zesui');
            subcountyMap.put('Buwalasi', 'Buwalasi');
            subcountyMap.put('Butandiga', 'Butandiga');
            subcountyMap.put('Gogonyo', 'Gogonyo');
            subcountyMap.put('Apopong', 'Apopong');
            subcountyMap.put('Kasodo', 'Kasodo');
            subcountyMap.put('Agule', 'Agule');
            subcountyMap.put('Pallisa', 'Pallisa');
            subcountyMap.put('Pallisa TC', 'Pallisa TC');
            subcountyMap.put('Puti Puti', 'Puti Puti');
            subcountyMap.put('Kamuge', 'Kamuge');
            subcountyMap.put('Kameke', 'Kameke');
            subcountyMap.put('Kibale', 'Kibale');
            subcountyMap.put('Butebo', 'Butebo');
            subcountyMap.put('Patete', 'Patete');
            subcountyMap.put('Kakoro', 'Kakoro');
            subcountyMap.put('Kabwangasi', 'Kabwangasi');
            subcountyMap.put('Kaato', 'Kaato');
            subcountyMap.put('Buwagago', 'Buwagago');
            subcountyMap.put('Sibanga', 'Sibanga');
            subcountyMap.put('Bugobero', 'Bugobero');
            subcountyMap.put('Butiru', 'Butiru');
            subcountyMap.put('Bubutu', 'Bubutu');
            subcountyMap.put('Bumwoni', 'Bumwoni');
            subcountyMap.put('Bumbo', 'Bumbo');
            subcountyMap.put('Buputo', 'Buputo');
            subcountyMap.put('Buwabwala', 'Buwabwala');
            subcountyMap.put('Kapujan', 'Kapujan');
            subcountyMap.put('Magoro', 'Magoro');
            subcountyMap.put('Ngariam', 'Ngariam');
            subcountyMap.put('Toroma', 'Toroma');
            subcountyMap.put('Omodoi', 'Omodoi');
            subcountyMap.put('Usuk', 'Usuk');
            subcountyMap.put('Ongongoja', 'Ongongoja');
            subcountyMap.put('Kobwin', 'Kobwin');
            subcountyMap.put('Kanyum', 'Kanyum');
            subcountyMap.put('Mukongoro', 'Mukongoro');
            subcountyMap.put('Atutur', 'Atutur');
            subcountyMap.put('Ongino', 'Ongino');
            subcountyMap.put('Nyero', 'Nyero');
            subcountyMap.put('Ngora', 'Ngora');
            subcountyMap.put('Mukura', 'Mukura');
            subcountyMap.put('Kapiri', 'Kapiri');
            subcountyMap.put('Kumi Town', 'Kumi Town');
        }
        return subcountyMap;
    }

    /**
     *  Get the Opportunity_Farmer__c object that maps to the intervieweeId
     *
     *  @param intervieweeId - The Person__r Id for the Opportunity Farmer to whom the survey was administered
     *
     *  @return - Opportunity_Farmer__c object
     */
    private static Opportunity_Farmer__c getFarmer(Id intervieweeId) {

        Opportunity_Farmer__c[] opportunityFarmer =
                            [SELECT
                                Id
                            FROM
                                Opportunity_Farmer__c
                            WHERE
                                Person__r.Id = :intervieweeId
                            LIMIT 1];
        if (opportunityFarmer.isEmpty()) {
            return null;
        }
        else {
            return opportunityFarmer[0];
        }
    }

    /**
     *  Delete the FarmerLand__c object if already existent
     *  
     *  @param existingOppFarmer - existing Opportunity Farmer object
     */
    private static void deleteFarmerLand(Opportunity_Farmer__c existingOppFarmer) {

       List<FarmerLand__c> existingFarmerLand = new List<FarmerLand__c>();
       existingFarmerLand =
                            [SELECT
                                Id
                            FROM
                                FarmerLand__c
                            WHERE
                               Opportunity_Farmer__r.Id = :existingOppFarmer.Id];
        if (existingFarmerLand.isEmpty()) {
            System.debug('FarmerLand Non-Existent for this Farmer');
        }
        else {
            delete existingFarmerLand;
        }
    }

    /**
     *  Check if farmer has already existing FarmerLand__c object
     *
     *  @param existingOppFarmer - existing Opportunity Farmer Object
     *
     *  @return - A boolean flag indicating whether the 
     *            opportunity farmer already has land associated to them
     */
    private static boolean checkIfFarmerLandExists(Opportunity_Farmer__c existingOppFarmer){

        FarmerLand__c[] farmerland =
                            [SELECT
                                Id
                            FROM
                                FarmerLand__c
                            WHERE
                                Opportunity_Farmer__r.Id = :existingOppFarmer.Id
                            LIMIT 1];
        if (farmerLand.isEmpty()) {
            return false;
        }
        else {
            return true;
        }
    }
}