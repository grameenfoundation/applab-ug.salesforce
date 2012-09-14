global class FarmerRegistration {

    global class AddFarmerRegistration {
        webservice String handsetId;
        webservice String farmerId;
        webservice Boolean hasLinkedFarmer;
        webservice String linkedFarmerId;

        webservice String firstName;
        webservice String lastName;
        webservice String fathersName;
        webservice Double age;
        webservice String gender;
        webservice String mobileNumber;
        webservice String village;
        webservice String latitude;
        webservice String longitude;

        webservice String householdStatus;
        webservice String crops;
        webservice String livestock;
        webservice String topics;
        webservice Double landSize;

        webservice Double children;
        webservice String fuel;
        webservice String education;
        webservice Boolean clothes;
        webservice Boolean shoes;
        webservice Boolean watch;
        webservice Boolean net;
        webservice Boolean radio;
        webservice String roof;
        webservice String wall;

        webservice String question1;
        webservice String question2;
        webservice String question3;
        webservice String question4;
        webservice String question5;
        webservice String question6;
        webservice String question7;
        webservice String question8;
        webservice String question9;
        webservice String question10;
        webservice String ppiVersion;

        webservice String farmerGroups;

        webservice String errorMessage;
        webservice Boolean success;
        webservice Boolean isUpdate;
    }

    webservice static AddFarmerRegistration registerFarmer(AddFarmerRegistration farmerRegistration) {

        if (farmerRegistration.farmerId.toUpperCase().startsWith('GF')) {
            farmerRegistration.success = true;
            farmerRegistration.errorMessage = 'Registering a test farmer so ignore but mark as success so it deleted of the phone';
            return farmerRegistration;
        }

        // Load the CKW that registered this farmer.
        Person__c ckw = Utils.loadPersonImei(farmerRegistration.handsetId);
        if (ckw == null) {
            farmerRegistration.success = false;
            farmerRegistration.errorMessage = 'CKW with the imei: ' + farmerRegistration.handsetId + ' does not exist on our system';
            return farmerRegistration;
        }

        // Load the new farmer to see if this is an update or not.
        Farmer__c farmer;
        Person__c person;
        Boolean oldStyle = false;
        List<Farmer__c> farmers = Utils.loadFarmerFromId(farmerRegistration.farmerId);
        if (farmers.isEmpty()) {
            farmer = new Farmer__c();
            farmer.Name = farmerRegistration.farmerId;
            farmer.Registered_By__c = ckw.Id;
            person = new Person__c();
            oldStyle = true;
        }
        else if (farmers.size() == 1) {
            farmer = farmers[0];
            person = Utils.loadPersonId(farmer.Person__c);
            farmerRegistration.isUpdate = true;
        }
        else {

            // This reg will fail due to there being more than 1 farmer with the Id already.
           farmerRegistration.success = false;
           farmerRegistration.errorMessage = 'There are more than 1 farmer with id: ' + farmerRegistration.farmerId + ' mark as success on the phone';
           return farmerRegistration;
        }
        person.District__c = ckw.District__c;
        person.Country__c = ckw.Country__c;
        person.Type__c = 'Farmer';

        // Load the linked farmer if required
        Farmer__c linkedFarmer;
        Person__c linkedPerson;
        Poverty_Scorecard__c linkedPovertyScorecard;
        PPI_Data__c linkedPpiData;

        // Check that the linked and farmer ids are not the same. If they are then allow through but with no link
        if (farmerRegistration.linkedFarmerId != null && farmerRegistration.linkedFarmerId.toUpperCase().equals(farmerRegistration.farmerId.toUpperCase())) {
            farmerRegistration.hasLinkedFarmer = false;
        }
        if (farmerRegistration.hasLinkedFarmer) {
            List<Farmer__c> linkedFarmers = Utils.loadFarmerFromId(farmerRegistration.linkedFarmerId.toUpperCase());
            if (linkedFarmers.size() == 1) {
                linkedFarmer = linkedFarmers.get(0);
                linkedPerson = Utils.loadPersonId(linkedFarmer.Person__c);

                // Load the poverty scorecard for this farmer
                linkedPovertyScorecard = Utils.loadCurrentPovertyScorecard(linkedFarmer.Person__c);
                if (farmerRegistration.question2 != null) {
                    linkedPpiData = Utils.loadCurrentPpi(linkedFarmer.Person__c);
                }
            }
            else {

                // This reg will fail due to the linked farmer id being invalid.
                farmerRegistration.success = false;
                farmerRegistration.errorMessage = 'The linked farmer id: ' + farmerRegistration.linkedFarmerId + ' is invalid';
                return farmerRegistration;
            }
        }

        // Populate the biographical details for the farmer.
        person = addPersonBioDetails(person, farmerRegistration, linkedPerson);
        farmer = addFarmerBioDetails(farmer, farmerRegistration, linkedFarmer);

        // Check that the household links are set up.
        Boolean updateLinkedPerson = false;
        if (farmerRegistration.hasLinkedFarmer) {
            updateLinkedPerson = buildPersonHouseholdLinks(person, linkedPerson);
        }

        // Save the persons and farmer objects
        List<Person__c> peopleToSave = new List<Person__c>();
        peopleToSave.add(person);
        if (updateLinkedPerson) {
            peopleToSave.add(linkedPerson);
        }

        Database.upsert(peopleToSave);
        if (oldStyle) {
            farmer.Person__c = person.Id;
        }
        Database.upsert(farmer);

        // Update the poverty scorecards.
        List<Poverty_Scorecard__c> povertyScorecardsToSave = new List<Poverty_Scorecard__c>();
        Poverty_Scorecard__c newPovertyScorecard;
        List<PPI_Data__c> ppiDatasToSave = new List<PPI_Data__c>();
        if (farmerRegistration.hasLinkedFarmer) {
            newPovertyScorecard = duplicatePovertyScorecard(linkedPovertyScorecard, person.Id);
            if (newPovertyScorecard != null) {
                povertyScorecardsToSave.add(newPovertyScorecard);
            }
            if (farmerRegistration.question2 != null) {
                PPI_Data__c newPpi = duplicatePpi(linkedPpiData, person.Id);
                if (newPpi != null) {
                    ppiDatasToSave.add(newPpi);
                }
            }
       }
        else {
            povertyScorecardsToSave = addNewPovertyScorecards(farmer, farmerRegistration, person);
            if (farmerRegistration.question2 != null) {
                ppiDatasToSave = addNewPpi(person, farmerRegistration);
            }
        }

        if (!povertyScorecardsToSave.isEmpty()) {
            Database.insert(povertyScorecardsToSave);
        }
        if (!ppiDatasToSave.isEmpty()) {
            Database.insert(ppiDatasToSave);
        }

        // Add any farmer group links that are required
        Database.insert(addFarmerGroups(farmer, farmerRegistration, linkedFarmer));

        // Done so update the metric
        if (!farmerRegistration.isUpdate) {
            MetricHelpers.updateMetric('total_farmers_reached', 1.0, null, null, MetricHelpers.getQuarterFirstDay(MetricHelpers.getQuarterAsString(0)), MetricHelpers.getQuarterLastDay(MetricHelpers.getQuarterAsString(0)), false);
        }

        // Add to the CKW who registered the farmer performance review
        CKW__c ckwSObject = Utils.loadCkwFromPersonSalesforceId((String)ckw.Id);
        if (ckwSObject != null) {
            PerformanceReviewHelpers.updatePerformanceRecord(ckwSObject, Date.today().toStartOfMonth(), 'Farmers_Registered__c', 1.0, false);
        }
        farmerRegistration.success = true;
        return farmerRegistration;
    }

    private static Person__c addPersonBioDetails(Person__c person, AddFarmerRegistration farmerRegistration, Person__c linkedPerson) {

        Double age = farmerRegistration.age;

        //Calculate year of bith from age
        String yearOfBirth = String.valueOf((Date.today().year()) - Integer.valueOf(age));

        person.First_Name__c = farmerRegistration.firstName;
        person.Last_Name__c = farmerRegistration.lastName;
        person.Fathers_Name__c = farmerRegistration.fathersName;

        // Set date of birth to 1 Jan
        person.Date_of_Birth__c = date.parse('1/1/' + yearOfBirth);
        if (farmerRegistration.mobileNumber != null && farmerRegistration.mobileNumber.length() < 20) {
            person.Raw_Mobile_Number__c = farmerRegistration.mobileNumber;
        }
        person.GPS_Location_N__c = farmerRegistration.latitude;
        person.GPS_Location_E__c = farmerRegistration.longitude;
        person.Gender__c = farmerRegistration.gender;
        if (linkedPerson != null && linkedPerson.Village__c != null) {
            person.Village__c = linkedPerson.Village__c;
        }
        else {
            person.Village__c = farmerRegistration.village;
        }
        return person;
    }

    private static Farmer__c addFarmerBioDetails(Farmer__c farmer, AddFarmerRegistration farmerRegistration, Farmer__c linkedFarmer) {

        farmer.Household_Status__c = farmerRegistration.householdStatus;
        if (linkedFarmer == null) {
            farmer.Crops__c = farmerRegistration.crops;
            farmer.Land_Size__c = farmerRegistration.landSize;
            farmer.Livestock__c = farmerRegistration.livestock;
            farmer.Topics_of_Interest__c = farmerRegistration.topics;
        }
        else {
            farmer.Crops__c = linkedFarmer.Crops__c;
            farmer.Land_Size__c = linkedFarmer.Land_Size__c;
            farmer.Livestock__c = linkedFarmer.Livestock__c;
            farmer.Topics_of_Interest__c = linkedFarmer.Topics_of_Interest__c;
        }
        return farmer;
    }

    private static Boolean buildPersonHouseholdLinks(Person__c person, Person__c linkedPerson) {

        Boolean updateLinkedPerson = false;
        Person_Household__c personHousehold;
        if (linkedPerson != null) {
            if (linkedPerson.Person_Household__c != null) {
            person.Person_Household__c = linkedPerson.Person_Household__c;
            }
            else {
                personHousehold = new Person_Household__c();
                database.insert(personHousehold);
                person.Person_Household__c = personHousehold.Id;
                linkedPerson.Person_Household__c = personHousehold.Id;
                updateLinkedPerson = true;
            }
        }
        else {
            personHousehold = new Person_Household__c();
            database.insert(personHousehold);
            person.Person_Household__c = personHousehold.Id;
        }
        return updateLinkedPerson;
    }

    private static List<Poverty_Scorecard__c> addNewPovertyScorecards(Farmer__c farmer, AddFarmerRegistration farmerRegistration, Person__c person) {

        List<Poverty_Scorecard__c> newScorecards = new List<Poverty_Scorecard__c>();

        // Create the new poverty scorecard for this farmer
        Poverty_Scorecard__c newCard = new Poverty_Scorecard__c();
        newCard.Children_Under_Eleven__c = farmerRegistration.children;
        newCard.Cooking_Fuel__c = farmerRegistration.fuel;
        newCard.Education_Level__c = farmerRegistration.education;
        newCard.Household_Members_Have_Clothes__c = farmerRegistration.clothes;
        newCard.Household_Members_Have_Shoes__c = farmerRegistration.shoes;
        newCard.Owns_Jewelry_Watch__c = farmerRegistration.watch;
        newCard.Owns_Mosquito_Net__c = farmerRegistration.net;
        newCard.Owns_TV_Radio_Cassette__c = farmerRegistration.radio;
        newCard.Roof_Material__c = farmerRegistration.roof;
        newCard.Wall_Material__c = farmerRegistration.wall;
        newCard.Person__c = farmer.Person__c;
        newCard.Date__c = Date.today();

        // Get the other farmers in this farmers household
        if (person.Person_Household__c != null) {
            Person__c[] householdMembers = Utils.getHouseholdMembers(person.Person_Household__c);

            // Loop though and clone the new scorecard and add the correct person to it
            if (!householdMembers.isEmpty()) {
                for (Person__c member : householdMembers) {
                    newScorecards.add(duplicatePovertyScorecard(newCard, member.Id));
                }
            }
        }
        else {
            newScorecards.add(newCard);
        }
        return newScorecards;
    }

    private static Poverty_Scorecard__c duplicatePovertyScorecard(Poverty_Scorecard__c scorecardToCopy, String personId) {

        if (scorecardToCopy == null) {
            return null;
        }
        Poverty_Scorecard__c newCard = new Poverty_Scorecard__c();
        newCard.Person__c = personId;
        newCard.Children_Under_Eleven__c = scorecardToCopy.Children_Under_Eleven__c;
        newCard.Cooking_Fuel__c = scorecardToCopy.Cooking_Fuel__c;
        newCard.Education_Level__c = scorecardToCopy.Education_Level__c;
        newCard.Household_Members_Have_Clothes__c = scorecardToCopy.Household_Members_Have_Clothes__c;
        newCard.Household_Members_Have_Shoes__c = scorecardToCopy.Household_Members_Have_Shoes__c;
        newCard.Owns_Jewelry_Watch__c = scorecardToCopy.Owns_Jewelry_Watch__c;
        newCard.Owns_Mosquito_Net__c = scorecardToCopy.Owns_Mosquito_Net__c;
        newCard.Owns_TV_Radio_Cassette__c = scorecardToCopy.Owns_TV_Radio_Cassette__c;
        newCard.Roof_Material__c = scorecardToCopy.Roof_Material__c;
        newCard.Wall_Material__c = scorecardToCopy.Wall_Material__c;
        newCard.Date__c = Date.today();
        return newCard;
    }

    private static List<PPI_Data__c> addNewPpi(Person__c person, AddFarmerRegistration farmerRegistration) {

        List<PPI_Data__c> newPpis = new List<PPI_Data__c>();

        // Create the new poverty scorecard for this farmer
        PPI_Data__c newPpi = new PPI_Data__c();
        newPpi.Person__c = person.Id;
        newPpi.Version__c = farmerRegistration.ppiVersion;
        newPpi.Question_1__c = farmerRegistration.question1;
        newPpi.Question_2__c = farmerRegistration.question2;
        newPpi.Question_3__c = farmerRegistration.question3;
        newPpi.Question_4__c = farmerRegistration.question4;
        newPpi.Question_5__c = farmerRegistration.question5;
        newPpi.Question_6__c = farmerRegistration.question6;
        newPpi.Question_7__c = farmerRegistration.question7;
        newPpi.Question_8__c = farmerRegistration.question8;
        newPpi.Question_9__c = farmerRegistration.question9;
        newPpi.Question_10__c = farmerRegistration.question10;
        newPpi.Country__c = 'Uganda';
        newPpi.Date__c = Date.today();
        newPpi.Score__c = caluclatePpiScore(newPpi);

        // Get the other farmers in this farmers household
        if (person.Person_Household__c != null) {
            Person__c[] householdMembers = Utils.getHouseholdMembers(person.Person_Household__c);

            // Loop though and clone the new scorecard and add the correct person to it
            if (!householdMembers.isEmpty()) {
                for (Person__c member : householdMembers) {
                    newPpis.add(duplicatePpi(newPpi, member.Id));
                }
            }
        }
        else {
            newPpis.add(newPpi);
        }
        return newPpis;
    }

    private static Decimal caluclatePpiScore(PPI_Data__c ppiData) {

        Decimal score = 0.0;
        score += translateQuestion1(ppiData.Question_1__c);
        score += translateQuestion2(ppiData.Question_2__c);
        score += translateQuestion3(ppiData.Question_3__c);
        score += translateQuestion4(ppiData.Question_4__c);
        score += translateQuestion5(ppiData.Question_5__c);
        score += translateQuestion6(ppiData.Question_6__c);
        score += translateQuestion7(ppiData.Question_7__c);
        score += translateQuestion8(ppiData.Question_8__c);
        score += translateQuestion9(ppiData.Question_9__c);
        score += translateQuestion10(ppiData.Question_10__c);
        return score;
    }

    private static Decimal translateQuestion1(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 6.0,
            'C' => 9.0,
            'D' => 14.0,
            'E' => 27.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion2(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 2.0,
            'C' => 4.0,
            'D' => 5.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion3(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 2.0,
            'C' => 6.0,
            'D' => 8.0,
            'E' => 19.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion4(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 5.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion5(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 2.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion6(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 11.0,
            'C' => 17.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion7(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 4.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion8(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 7.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion9(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 5.0
        };
        return translationMap.get(value);
    }

    private static Decimal translateQuestion10(String value) {

        Map<String, Decimal> translationMap = new Map<string, Decimal> {
            'A' => 0.0,
            'B' => 9.0
        };
        return translationMap.get(value);
    }

    private static PPI_Data__c duplicatePpi(PPI_Data__c ppiToCopy, String personId) {

        if (ppiToCopy == null) {
            return null;
        }
        PPI_Data__c newPpi = new PPI_Data__c();
        newPpi.Person__c = personId;
        newPpi.Date__c = Date.today();
        newPpi.Question_1__c = ppiToCopy.Question_1__c;
        newPpi.Question_2__c = ppiToCopy.Question_2__c;
        newPpi.Question_3__c = ppiToCopy.Question_3__c;
        newPpi.Question_4__c = ppiToCopy.Question_4__c;
        newPpi.Question_5__c = ppiToCopy.Question_5__c;
        newPpi.Question_6__c = ppiToCopy.Question_6__c;
        newPpi.Question_7__c = ppiToCopy.Question_7__c;
        newPpi.Question_8__c = ppiToCopy.Question_8__c;
        newPpi.Question_9__c = ppiToCopy.Question_9__c;
        newPpi.Question_10__c = ppiToCopy.Question_10__c;
        newPpi.Country__c = ppiToCopy.Country__c;
        newPpi.Score__c = ppiToCopy.Score__c;
        newPpi.Version__c = ppiToCopy.Version__c;
        return newPpi;
    }

    private static List<Person_Organisation_Association__c> addFarmerGroups(Farmer__c farmer, AddFarmerRegistration farmerRegistration, Farmer__c linkedFarmer) {

        String[] farmerGroupsIds = farmerRegistration.farmerGroups.split('@#@');
        List<Person_Organisation_Association__c> newGroupLinks = new List<Person_Organisation_Association__c>();
        List<Person_Organisation_Association__c> oldGroupLinks = new List<Person_Organisation_Association__c>();
        List<Person_Organisation_Association__c> existingFarmerGroups = Utils.getCurrentPersonOrganisationLinks(farmer.Person__c);

        // Loop through the groups recieved and update or create as required
        for (String farmerGroupsId : farmerGroupsIds) {
            if (farmerGroupsId.length() == 0) {
                break;
            }
            Boolean addNewGroup = true;
            for (Person_Organisation_Association__c existingFarmerGroup : existingFarmerGroups) {
                String poaId = (String)existingFarmerGroup.Id;
                if (poaId.equalsIgnoreCase(farmerGroupsId)) {
                    addNewGroup = false;
                }
            }
            if (addNewGroup) {
                Person_Organisation_Association__c newLink = new Person_Organisation_Association__c();
                newLink.Person__c = farmer.Person__c;
                newLink.Organisation__c = farmerGroupsId;
                newLink.Start_Date__c = Date.today();
                newGroupLinks.add(newLink);
            }
        }

        // Remove any links that the farmer no longer has.
        for (Person_Organisation_Association__c existingFarmerGroup : existingFarmerGroups) {
            Boolean removeGroup = true;
            for (String farmerGroupsId : farmerGroupsIds) {
                String poaId = (String)existingFarmerGroup.Id;
                if (poaId.equalsIgnoreCase(farmerGroupsId)) {
                    removeGroup = false;
                }
            }
            if (removeGroup) {
                existingFarmerGroup.End_Date__c = Date.today();
                oldGroupLinks.add(existingFarmerGroup);
            }
        }
 
        database.update(oldGroupLinks);
        return newGroupLinks;
    }

    static testMethod void testAddNewFarmerRegistration() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create an organisation.
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);

        AddFarmerRegistration farmerRegistration = new AddFarmerRegistration();
        farmerRegistration.handsetId = 'TestCKW1';
        farmerRegistration.farmerId = 'OD99998';
        farmerRegistration.hasLinkedFarmer = false;

        farmerRegistration.firstName = 'George';
        farmerRegistration.lastName = 'Malone';
        farmerRegistration.fathersName = 'Bobby';
        farmerRegistration.householdStatus = 'Child of household head';
        farmerRegistration.age = 25;
        farmerRegistration.gender = 'Male';
        farmerRegistration.village = 'Here';
        farmerRegistration.mobileNumber = '01234567890';
        farmerRegistration.latitude = '32.15';
        farmerRegistration.longitude = '0.32';

        farmerRegistration.farmerGroups = org.Id;
        farmerRegistration.crops = 'Maize';
        farmerRegistration.landSize = 3.0;
        farmerRegistration.livestock = 'Cows';
        farmerRegistration.topics = 'Market Prices';

        farmerRegistration.children = 4.0;
        farmerRegistration.fuel = 'Firewood';
        farmerRegistration.education = 'O level';
        farmerRegistration.clothes = true;
        farmerRegistration.shoes = false;
        farmerRegistration.watch = true;
        farmerRegistration.net = false;
        farmerRegistration.radio = true;
        farmerRegistration.roof = 'Iron sheet/tin';
        farmerRegistration.wall = 'Burnt bricks with mud/mud poles';
        farmerRegistration.isUpdate = false;

        AddFarmerRegistration registeredFarmer = registerFarmer(farmerRegistration);
        System.assert(registeredFarmer.success);
    }

    static testMethod void testAddNewFarmerRegistrationWithoutPpi() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create an organisation.
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);

        AddFarmerRegistration farmerRegistration = new AddFarmerRegistration();
        farmerRegistration.handsetId = 'TestCKW1';
        farmerRegistration.farmerId = 'OD99998';
        farmerRegistration.hasLinkedFarmer = false;

        farmerRegistration.firstName = 'George';
        farmerRegistration.lastName = 'Malone';
        farmerRegistration.fathersName = 'Bobby';
        farmerRegistration.householdStatus = 'Child of household head';
        farmerRegistration.age = 25;
        farmerRegistration.gender = 'Male';
        farmerRegistration.village = 'Here';
        farmerRegistration.mobileNumber = '01234567890';
        farmerRegistration.latitude = '32.15';
        farmerRegistration.longitude = '0.32';

        farmerRegistration.farmerGroups = org.Id;
        farmerRegistration.crops = 'Maize';
        farmerRegistration.landSize = 3.0;
        farmerRegistration.livestock = 'Cows';
        farmerRegistration.topics = 'Market Prices';

        farmerRegistration.children = 4.0;
        farmerRegistration.fuel = 'Firewood';
        farmerRegistration.education = 'O level';
        farmerRegistration.clothes = true;
        farmerRegistration.shoes = false;
        farmerRegistration.watch = true;
        farmerRegistration.net = false;
        farmerRegistration.radio = true;
        farmerRegistration.roof = 'Iron sheet/tin';
        farmerRegistration.wall = 'Burnt bricks with mud/mud poles';
        farmerRegistration.isUpdate = false;

        AddFarmerRegistration registeredFarmer = registerFarmer(farmerRegistration);
        System.assert(registeredFarmer.success);
        Farmer__c farmer = [SELECT Person__c FROM Farmer__c WHERE Farmer__c.Name = 'OD99998'];
        PPI_Data__c datas = Utils.loadCurrentPpi(farmer.Person__c);
        System.assert(datas == null);
    }

    static testMethod void testAddLinkedFarmerRegistration() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);
        Poverty_Scorecard__c  povertyScorecard1 = Utils.createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);

        // Create an organisation.
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);

        AddFarmerRegistration farmerRegistration = new AddFarmerRegistration();
        farmerRegistration.handsetId = 'TestCKW1';
        farmerRegistration.farmerId = 'OD99998';
        farmerRegistration.hasLinkedFarmer = true;
        farmerRegistration.linkedFarmerId = 'OD99999';

        farmerRegistration.firstName = 'George';
        farmerRegistration.lastName = 'Malone';
        farmerRegistration.fathersName = 'Bobby';
        farmerRegistration.householdStatus = 'Child of household head';
        farmerRegistration.age = 25;
        farmerRegistration.gender = 'Male';
        farmerRegistration.mobileNumber = '01234567890';
        farmerRegistration.latitude = '32.15';
        farmerRegistration.longitude = '0.32';
        farmerRegistration.isUpdate = false;

        farmerRegistration.farmerGroups = org.Id;
        AddFarmerRegistration registeredFarmer = registerFarmer(farmerRegistration);
        System.assert(registeredFarmer.success);
    }
}