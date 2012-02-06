public with sharing class TdrRegistrationController {

    // Get the available countries. Currently just Uganda but this will expand
    public String country;
    public String getCountry() {
        return this.country;
    }
    public void setCountry(String country) {
        this.country = country;
    }
    public List<SelectOption> countrys;
    public List<SelectOption> getCountrys() {

        List<SelectOption> options = new List<SelectOption>();
        Country__c[] countries = [
            SELECT
                Name,
                Id
            FROM
                Country__c
            WHERE
                Name = 'Uganda'];
        for (Country__c country : countries) {
            options.add(new SelectOption(country.Id, country.Name));
        }
        return options;
    }
    public void setCountrys(List<SelectOption> options) {
        this.countrys = options;
    }

    // Get the available regions. This can take into account a country that has been selected
    public String region;
    public String getRegion() {
        return this.region;
    }
    public void setRegion(String region) {
        this.region = region;
    }
    public List<SelectOption> regions;
    public List<SelectOption> getRegions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a Region---'));
        Region__c[] regions = database.query(TdrHelpers.buildRegionsQueryString(this.country));
        for (Region__c region : regions) {
            options.add(new SelectOption(region.Id, region.Display_Name__c));
        }
        return options;
    }
    public void setRegions(List<SelectOption> options) {
        this.regions = options;
    }

    public List<SelectOption> genders;
    public List<SelectOption> getGenders() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a Gender---'));
        Schema.DescribeFieldResult field = Person__c.Gender__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            options.add(new SelectOption(f.getLabel(), f.getLabel()));
        }
        return options;
    }
    public void setGenders(List<SelectOption> genders) {
        this.genders = genders;
    }

    public List<SelectOption> existingPhonesBoolean;
    public List<SelectOption> getExistingPhonesBoolean() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Select a Phone to use---'));
        options.add(new SelectOption('Yes', '---Use Existing Phone---'));
        options.add(new SelectOption('No', '---Enter a New Phone---'));
        return options;
    }
    public void setExistingPhonesBoolean(List<SelectOption> options) {
        this.existingPhonesBoolean = options;
    }

    public List<SelectOption> existingPhones;
    public List<SelectOption> getExistingPhones() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select an Existing Phone---'));
        Phone__c[] phones = [
            SELECT
                IMEI__c,
                Id,
                SIM__r.Name
            FROM 
                Phone__c 
            WHERE 
                State__c != 'Assigned'];
        if (!phones.isEmpty()) {
            for (Phone__c phone : phones) {
                String display = phone.IMEI__c;
                if (phone.SIM__r.Name != null) {
                    display += ' - ' + phone.SIM__r.Name;
                }
                options.add(new SelectOption(phone.Id, display));
            }
        }
        return options;
    }
    public void setExistingPhones(List<SelectOption> existingPhones) {
        this.existingPhones = existingPhones;
    }

    public List<SelectOption> phoneTypes;
    public List<SelectOption> getPhoneTypes() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select the Phone Type---'));
        Schema.DescribeFieldResult field = Phone__c.Brand__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            options.add(new SelectOption(f.getLabel(), f.getLabel()));
        }
        return options;
    }
    public void setPhoneTypes(List<SelectOption> options) {
        this.phoneTypes = options;
    }

    public Date_Picker__c dobDatePicker { get; set; }
    public String gender;
    public String useExistingPhone;
    public String existingPhone;

    public TdrRegistrationController() {

        setUp();

        // Check to see this is a redirect from another page. Pass code if it is
        if (ApexPages.currentPage().getParameters().containsKey('errorCode')) {
            String code = ApexPages.currentPage().getParameters().get('errorCode');
            if (code.equals('1')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Sales Rep has been registered successfully'));
            }
        }
    }

    private void setUp() {
        this.dobDatePicker = new Date_Picker__c();
        this.dobDatePicker.Start_Date__c = null;
        this.dobDatePicker.End_Date__c = null;
    }

    public PageReference submitTdrRegistration() {

        // Validate the submission
        PageReference pageRef = Apexpages.currentPage();
        Boolean isValid = true;
        if (pageRef.getParameters().get('countryParam') == null || pageRef.getParameters().get('countryParam').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select the country that the Sales Rep is from'));
            isValid = false;
        }
        if (pageRef.getParameters().get('regionParam') == null || pageRef.getParameters().get('regionParam').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select the region that the Sales Rep is from'));
            isValid = false;
        }
        if (pageRef.getParameters().get('firstNameParam') == null || pageRef.getParameters().get('firstNameParam').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Sales Rep must have a first name'));
            isValid = false;
        }
        if (pageRef.getParameters().get('lastNameParam') == null || pageRef.getParameters().get('lastNameParam').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The TDR must have a last name'));
            isValid = false;
        }
        if (pageRef.getParameters().get('genderParam') == null || pageRef.getParameters().get('genderParam').equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a gender for the Sales Rep'));
            isValid = false;
        }
        
        // Check the phone inputs
        String useExistingPhone = pageRef.getParameters().get('usingExistingPhoneParam');
        if (useExistingPhone == null || useExistingPhone.equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please state if you would like to enter a new phone or use an existing one'));
            isValid = false;
        }
        else {
            if (useExistingPhone.equals('Yes')) {
                if (pageRef.getParameters().get('existingPhoneParam') == null || pageRef.getParameters().get('existingPhoneParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an existing phone from the list of unassigned phones'));
                    isValid = false;
                }
            }
            else {
                if (pageRef.getParameters().get('newPhoneImeiParam') == null || pageRef.getParameters().get('newPhoneImeiParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the IMEI of the new phone you are entering'));
                    isValid = false;
                }
                if (pageRef.getParameters().get('newPhoneNumberParam') == null || pageRef.getParameters().get('newPhoneNumberParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the phone number for the new phone you are entering'));
                    isValid = false;
                }
                if (pageRef.getParameters().get('newPhoneSerialNumberParam') == null || pageRef.getParameters().get('newPhoneSerialNumberParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the serial number of the new phone you are entering'));
                    isValid = false;
                }
                if (pageRef.getParameters().get('newPhoneTypeParam') == null || pageRef.getParameters().get('newPhoneTypeParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a phone type for the phone you are entering'));
                    isValid = false;
                }
                if (pageRef.getParameters().get('newPhonePurcahseValueParam') == null || pageRef.getParameters().get('newPhonePurcahseValueParam').equals('')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the value that the new phone was purchased for'));
                    isValid = false;
                }
            }
        }
        Boolean success = true;
        if (isValid) {

            // Create a save point for the DB work to roll back to
            Savepoint sp = Database.setSavepoint();
            String phoneId;

            try {

                // Create a new phone if needed
                if (useExistingPhone.equals('No')) {

                    // Create a new sim card
                    SIM__c sim = new SIM__c();
                    sim.Name = pageRef.getParameters().get('newPhoneNumberParam');
                    sim.Carrier__c = 'MTN - Uganda';

                    // Use the phone number for now
                    sim.SIM_Serial_Number__c = pageRef.getParameters().get('newPhoneNumberParam');
                    Database.SaveResult simSaveResults = database.insert(sim, false);
                    if (!simSaveResults.isSuccess()) {
                        if (simSaveResults.getErrors()[0].getMessage().contains('duplicates')) {
                            if(simSaveResults.getErrors()[0].getMessage().contains('SIM_Serial_Number__c')) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the SIM card as this phone number already exists'));
                            }
                            else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the sim card for this Sales Rep. Please check the phone number field'));
                            }
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the sim card for this Sales Rep. Please check the phone number field'));
                        }
                        System.debug(LoggingLevel.Error, simSaveResults.getErrors()[0].getMessage());
                        Database.rollback(sp);
                        return null;
                    }

                    // Create a new Handset
                    Phone__c phone = new Phone__c();
                    phone.SIM__c = simSaveResults.getId();
                    phone.IMEI__c = pageRef.getParameters().get('newPhoneImeiParam');
                    phone.Purchase_Value_USD__c = Decimal.valueOf(pageRef.getParameters().get('newPhonePurcahseValueParam'));
                    phone.Serial_Number__c = pageRef.getParameters().get('newPhoneSerialNumberParam');
                    phone.Brand__c = pageRef.getParameters().get('newPhoneTypeParam');
                    Database.SaveResult phoneSaveResult = database.insert(phone, false);
                    if (!phoneSaveResult.isSuccess()) {
                        System.debug(LoggingLevel.Error, phoneSaveResult.getErrors()[0].getMessage());
                        if (phoneSaveResult.getErrors()[0].getMessage().contains('duplicates')) {
                            if (phoneSaveResult.getErrors()[0].getMessage().contains('IMEI__c')) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the handset for this Sales Rep. The imei provided matches one on the system already.'));
                            }
                            else if(phoneSaveResult.getErrors()[0].getMessage().contains('Serial_Number__c')) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the handset for this Sales Rep. The serial number provided matches one on the system already.'));
                            }
                            else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the handset for this Sales Rep. Please check the handset details provided.'));
                            }
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the handset for this Sales Rep. Please check the handset details provided'));
                        }
                        Database.rollback(sp);
                        return null;
                    }
                    phoneId = (String)phoneSaveResult.getId();

                }
                else {
                    phoneId = pageRef.getParameters().get('existingPhoneParam');
                }

                // Create a new Person object
                Person__c person = new Person__c();
                person.Date_of_Birth__c = TdrHelpers.convertStringToDate(pageRef.getParameters().get('dobParam'));
                person.Last_Name__c = pageRef.getParameters().get('lastNameParam');
                person.First_Name__c = pageRef.getParameters().get('firstNameParam');
                person.Middle_Name__c = pageRef.getParameters().get('middleNameParam');
                person.Region__c = pageRef.getParameters().get('regionParam');
                person.Gender__c = pageRef.getParameters().get('genderParam');
                person.Handset__c = phoneId;
                person.Type__c = 'TDR';

                Database.SaveResult personSaveResult = database.insert(person);
                if (!personSaveResult.isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the Sales Rep\'s bio infor. Please check the data provided'));
                    System.debug(LoggingLevel.Error, personSaveResult.getErrors()[0].getMessage());
                    Database.rollback(sp);
                    return null;
                }

                // Add the person to the MTN Group
                Group__c[] mtnGroup = [
                    SELECT
                        Id
                    FROM
                        Group__c
                    WHERE
                        Name = ''
                ];
                if (!mtnGroup.isEmpty()) {
                    Person_Group_Association__c pga  = new Person_Group_Association__c();
                    pga.Group__c = mtnGroup[0].Id;
                    pga.Person__c = personSaveResult.getId();
                    database.insert(pga);
                }

                // Create a new TDR object
                TDR__c tdr = new TDR__c();
                tdr.Person__c = personSaveResult.getId();
                Database.SaveResult tdrSaveResult = database.insert(tdr);
                if (!tdrSaveResult.isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create the Sales Rep\'s bio infor. Please check the data provided'));
                    System.debug(LoggingLevel.Error, tdrSaveResult.getErrors()[0].getMessage());
                    Database.rollback(sp);
                    return null;
                }
            }
            catch (Exception e) {
                success = false;
                System.debug(LoggingLevel.INFO, e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. Please try again. If the issue persists contact support'));
                Database.rollback(sp);
            }
        }
        if (isValid && success) {

            // Successful so redirect back to a blank form.
            PageReference newPage = Page.TdrRegistration;
            newPage.getParameters().put('errorCode', '1');
            newPage.setRedirect(true);
            return newPage;
        }
        else {

            // Failed so return so error msgs can be seen
            return null;
        }
    }

    // Test methods
    static testMethod void testGettersAndSetters()  {

        TdrRegistrationController controller = new TdrRegistrationController();
        controller.setCountrys(controller.getCountrys());
        controller.setCountry(controller.getCountry());
        controller.setRegion(controller.getRegion());
        controller.setRegions(controller.getRegions());
        controller.setGenders(controller.getGenders());
        controller.setExistingPhonesBoolean(controller.getExistingPhonesBoolean());
        controller.setExistingPhones(controller.getExistingPhones());
        controller.setPhoneTypes(controller.getPhoneTypes());
    }

    static testMethod void testAllFail() {

        PageReference pageRef = Page.TdrRegistration;
        pageRef.getParameters().put('errorCode', '1');
        pageRef.getParameters().put('countryParam', '');
        pageRef.getParameters().put('regionParam', '');
        pageRef.getParameters().put('firstNameParam', '');
        pageRef.getParameters().put('lastNameParam', '');
        pageRef.getParameters().put('genderParam', '');
        pageRef.getParameters().put('usingExistingPhoneParam', 'No');
        pageRef.getParameters().put('existingPhoneParam', '');
        pageRef.getParameters().put('newPhoneImeiParam', '');
        pageRef.getParameters().put('newPhoneNumberParam', '');
        pageRef.getParameters().put('newPhoneSerialNumberParam', '');
        pageRef.getParameters().put('newPhoneTypeParam', '');
        pageRef.getParameters().put('newPhonePurcahseValueParam', '');
        Test.setCurrentPage(pageRef);
        TdrRegistrationController controller = new TdrRegistrationController();
        controller.submitTdrRegistration();
    }

    static testMethod void succeedWithPhone() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        PageReference pageRef = Page.TdrRegistration;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('firstNameParam', 'Owen');
        pageRef.getParameters().put('lastNameParam', 'Davies');
        pageRef.getParameters().put('genderParam', 'Male');
        pageRef.getParameters().put('usingExistingPhoneParam', 'No');
        pageRef.getParameters().put('existingPhoneParam', '');
        pageRef.getParameters().put('newPhoneImeiParam', '1234546758493');
        pageRef.getParameters().put('newPhoneNumberParam', '352353623');
        pageRef.getParameters().put('newPhoneSerialNumberParam', 'egewtgwe323e');
        pageRef.getParameters().put('newPhoneTypeParam', 'IDEOS');
        pageRef.getParameters().put('newPhonePurcahseValueParam', '123');
        Test.setCurrentPage(pageRef);
        TdrRegistrationController controller = new TdrRegistrationController();
        controller.submitTdrRegistration();
    }

    static testMethod void succeedWithoutPhone() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a handset
        Phone__c phone = Utils.createTestHandset('12345');
        Database.insert(phone);

        PageReference pageRef = Page.TdrRegistration;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('firstNameParam', 'Owen');
        pageRef.getParameters().put('lastNameParam', 'Davies');
        pageRef.getParameters().put('genderParam', 'Male');
        pageRef.getParameters().put('usingExistingPhoneParam', 'Yes');
        pageRef.getParameters().put('existingPhoneParam', phone.Id);
        pageRef.getParameters().put('newPhoneImeiParam', '');
        pageRef.getParameters().put('newPhoneNumberParam', '');
        pageRef.getParameters().put('newPhoneSerialNumberParam', '');
        pageRef.getParameters().put('newPhoneTypeParam', '');
        pageRef.getParameters().put('newPhonePurcahseValueParam', '');
        Test.setCurrentPage(pageRef);
        TdrRegistrationController controller = new TdrRegistrationController();
        controller.submitTdrRegistration();
    }
}