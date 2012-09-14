public with sharing class TdrSelectorController {

    /**
     *  Controller class for the MTN TDR Selector template
     */

    // Set up the page layout options
    public FormDetails[] formDetails;
    public FormDetails[] getFormDetails() {

        List<FormDetails> formDetails = new List<FormDetails>();
        FormDetails all = new FormDetails('ALL', 'country,region,tdrs,year,month,weekRangeStart,weekRangeEnd,showBarGraph,showTopTwelve,showTopTwelveComparison,showDailyActivityReport,showTrendGraph,setDefaultTargets,setTdrTargets,showWeekly');
        formDetails.add(all);
        return formDetails;
    }
    public void setFormDetails(List<FormDetails> options) {
        this.formDetails = options;
    }

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

    // Get the available TDRs. This should only be called if a region has been selected
    public String[] tdrs;
    public List<String> getTdrs() {
        return this.tdrs;
    }
    public void setTdrs(List<String> tdrs) {
        this.tdrs = tdrs;
    }
    public List<SelectOption> tdrList;
    public List<SelectOption> getTdrList() {

        List<SelectOption> options = new List<SelectOption>();
        if (this.region == null || this.region.equals('')) {
            options.add(new SelectOption('NONE', '---Please Select A Region First---'));
        }
        else {

            // Add the country param
            if (!this.country.equals('')) {
                addParameter('countries', '\'' + this.country + '\'');
            }

            // Add the region
            if (!this.region.equals('')) {
                addParameter('regions', '\'' + this.region + '\'');
            }
            TDR__c[] tdrs = TdrHelpers.loadTdrs(this.parameters, getTdrOrderByList());
            if (tdrs == null) {
                options.add(new SelectOption('NONE', 'There are no Sales Reps for this region'));
                return options;
            }
            options.add(new SelectOption('NONE', 'All Sales Reps'));
            for (TDR__c tdr : tdrs) {
                options.add(new SelectOption(tdr.Person__r.Id, tdr.Person__r.Last_Name__c
                    + ' ' + tdr.Person__r.First_Name__c));
            }
            tdrs.clear();
        }
        return options;
    }
    public void setTdrList(List<SelectOption> options) {
        this.tdrList = options;
    }

    /**
     *  Generate the order by clause for any TDR query
     *
     *  @return - A list of the fields to order the query by.
     */
    private List<String> getTdrOrderByList() {
        return new String[] { 'Person__r.Last_Name__c', 'Person__r.First_Name__c' };
    }

    // Set up the year select options
    public String year;
    public String getYear() {
        return this.year;
    }
    public void setYear(String year) {
        this.year = year;
    }
    public List<SelectOption> years;
    public List<SelectOption> getYears() {

        Integer startYear = 2011;
        Integer endYear = date.today().year() + 1;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Select a Year---'));
        while (startYear != endYear) {
            options.add(new SelectOption(String.valueOf(startYear), String.valueOf(startYear)));
            startYear++;
        }
        return options;
    }
    public void setYears(List<SelectOption> options) {
        this.years = options;
    }

    // Set up the months select list. TODO - make this more clever based on the year choosen
    public String month;
    public String getMonth() {
        return this.month;
    }
    public void setMonth(String month) {
        this.month = month;
    }
    public List<SelectOption> months;
    public List<SelectOption> getMonths() {

        Integer year = Integer.valueOf(getYear());
        Integer currentYear = Date.today().year();
        Integer startMonth = 1;
        Integer endMonth = 12;
        if (year == 2011) {
            startMonth = 11;
        }
        if (year == currentYear) {
            endMonth = Date.today().month();
        }
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Select a Month---'));
        for (Integer i = startMonth; i <= endMonth; i++) {
            options.add(new SelectOption(String.valueOf(i), translateMonth(i)));
        }
        return options;
    }
    public void setMonths(List<SelectOption> options) {
        this.months = options;
    }

    private Map<Integer, String> monthMap;
    private void initMonthMap() {

        this.monthMap = new Map<Integer, String> {
            1 => 'January',
            2 => 'February',
            3 => 'March',
            4 => 'April',
            5 => 'May',
            6 => 'June',
            7 => 'July',
            8 => 'August',
            9 => 'September',
            10 => 'October',
            11 => 'November',
            12 => 'December'
        };
    }
    private String translateMonth(Integer month) {
        if (this.monthMap == null) {
            this.initMonthMap();
        }
        return this.monthMap.get(month);
    }

    public String getScope() {
        return getParameter('scope');
    }

    // Set up the date range selector for the weekly options
    public Date_Picker__c weekRangeDatePicker { get; set; }
    private String startDate;
    private String endDate;

    // The helper variables. These are not set from the VF page
    private Map<String, String> parameters = new Map<String, String>();

    // Hide the controls that are not needed when setting targets
    public Boolean hideForTargets;
    public Boolean getHideForTargets() {
        return this.hideForTargets;
    }
    public void setHideForTargets(Boolean bool) {
        this.hideForTargets = bool;
    }
    public Boolean hideForDefaultTargets;
    public Boolean getHideForDefaultTargets() {
        return this.hideForDefaultTargets;
    }
    public void setHideForDefaultTargets(Boolean bool) {
        this.hideForDefaultTargets = bool;
    }

    private String showWeekly;

    public String pageBlockTitle { get; set; }

    /**
     *  Constructor for this controller
     */
    public TdrSelectorController() {

        setUp();
    }

    public void setUp() {

        this.country = '';
        this.region = '';
        this.tdrs = new List<String>();
        this.setYear('2011');
        this.month = '';
        initMonthMap();

        // Set up and default the date ranges
        this.weekRangeDatePicker = new Date_Picker__c();
        this.weekRangeDatePicker.Start_Date__c = null;
        this.weekRangeDatePicker.End_Date__c = null;
        this.showWeekly = 'false';

        // Default the scope
        addParameter('scope', 'REGION');

        this.setHideForDefaultTargets(false);
        this.setHideForTargets(false);

        this.pageBlockTitle = 'Select Options';
    }

    /**
     *  Redirect the user back to the panding page and pass through any error codes
     */
    public PageReference redirectHome(String code) {

        if (code == null || code.equals('')) {
            code = 'success';
        }
        PageReference newPage = Page.TdrLandingPage;
        newPage.setRedirect(true);
        newPage.getParameters().put('errorCode', code);
        return newPage;
    }

    /**
     *  Generate the parameters for a tdr query from the inputs from the page.
     */
    public List<String> getTdrParameters() {

        // Reset the map
        this.parameters.clear();

        // Set data from the select lists
        setCountry(Apexpages.currentPage().getParameters().get('countryParam'));
        setRegion(Apexpages.currentPage().getParameters().get('regionParam'));

        // Add the country param
        if (!this.country.equals('')) {
            addParameter('countries', '\'' + this.country + '\'');
        }

        // Add the region
        if (!this.region.equals('')) {
            addParameter('regions', '\'' + this.region + '\'');
        }

        setTdrs(Apexpages.currentPage().getParameters().get('tdrParam').split(','));
        setYear(Apexpages.currentPage().getParameters().get('yearParam'));
        setMonth(Apexpages.currentPage().getParameters().get('monthParam'));

        addParameter('year', Apexpages.currentPage().getParameters().get('yearParam'));
        addParameter('month', Apexpages.currentPage().getParameters().get('monthParam'));

        // Set date ranges
        this.startDate =  Apexpages.currentPage().getParameters().get('weeklyRangeStartParam').equals('') ? null : Apexpages.currentPage().getParameters().get('weeklyRangeStartParam');
        this.endDate =  Apexpages.currentPage().getParameters().get('weeklyRangeEndParam').equals('') ? null : Apexpages.currentPage().getParameters().get('weeklyRangeEndParam');
        this.showWeekly = Apexpages.currentPage().getParameters().get('showWeeklyParam');

        // Decide upon the scope
        if (this.region.equals('')) {
            addParameter('scope', 'COUNTRY');
        }
        else {
            addParameter('scope', 'REGION');
        }

        // Add the TDRs. This is going to be a list of the Person__r.Id for the TDRs.
        // If no TDRs have been selected go off and get the Person__r.Id for the TDRs.
        if (this.tdrs.isEmpty() || this.tdrs[0].equals('NONE') || this.tdrs[0].equals('')) {
            this.tdrs = TdrHelpers.getTdrPersonList(this.parameters);
        }
        addParameter('tdrs', TdrHelpers.generateCommaSeperatedString(this.tdrs, true));

        // Decide what type of TDR Performance is required
        String timePeriod = 'DAILY';
        if (this.showWeekly.equals('true')) {
            timePeriod = 'WEEKLY';
        }
        if (this.startDate == null) {
            if (this.month.equals('')) {
                timePeriod = 'YEARLY';
            }
            else {
                timePeriod = 'MONTHLY';
            }
        }
        addParameter('type', timePeriod);

        // Generate the date parameters
        if (timePeriod.equals('DAILY')) {
            Date start = TdrHelpers.convertStringToDate(this.startDate);
            Date endD = null;
            String startString = TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(start), true);
            this.parameters.put('startDate', startString);
            if (this.endDate == null) {
                addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToEndDate(start), true));
            }
            else {
                endD = TdrHelpers.convertStringToDate(this.endDate);
                addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToEndDate(endD), true));
            }

            // Check that the date range is close enough to carry out the more complicated tasks
            if (endD != null) {
                Integer gap = start.daysBetween(endD);
                if (gap > 93) {
                    return new String[] {'0', 'Your date range is too far apart. Three months is the maximum to view daily reports' };
                }
                else if (gap < 0) {
                    return new String[] {'0', 'Your end date is after your start date' };
                }
            }
        }
        else if (timePeriod.equals('WEEKLY')) {

            // Convert dates to be the start of the week
            Date start = TdrHelpers.convertStringToDate(this.startDate).toStartOfWeek();
            Date endD = null;
            String startString = TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(start), true);
            addParameter('startDate', startString);
            if (this.endDate == null) {
                addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToEndDate(start), true));
            }
            else {
                endD = TdrHelpers.convertStringToDate(this.endDate).toStartOfWeek();
                addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToEndDate(endD), true));
            }

            // Check that the date range is close enough to carry out the more complicated tasks
            if (endD != null) {
                Integer gap = start.daysBetween(endD);
                if (gap > 190) {
                    return new String[] {'0', 'Your date range is too far apart. Six months is the maximum for weekly range' };
                }
                else if (gap < 0) {
                    return new String[] {'0', 'Your end date is after your start date' };
                }
            }
        }
        else if (timePeriod.equals('MONTHLY')) {

            Date startDate = Date.parse(this.month + '/01/' + this.year);
            addParameter('startDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate), true));
            addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate.addMonths(1).addDays(-1)), true));
        }
        else {
            Date startDate = Date.parse('01/01/' + this.year);
            addParameter('startDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate), true));
            addParameter('endDate', TdrHelpers.convertDateTimeToString(TdrHelpers.convertToStartDate(startDate.addMonths(12).addDays(-1)), true));
        }
        return new String[] { '1', '' };
    }

    /**
     *  Clear the variable map
     */
    public void clearVariableMap() {

        if (this.parameters == null) {
            this.parameters = new Map<String, String>();
        }
        else {
            this.parameters.clear();
        }
    }

    /**
     *  Add a parameter to the parameter map
     */
    public void addParameter(String key, String value) {

        if (this.parameters == null) {
            this.parameters = new Map<String, String>();
        }
        this.parameters.put(key, value);
    }

    /**
     *  Get a param from the variable map.
     *
     *  @param key - The key for the map
     *
     *  @return - The value or blank string if the param does not exist in the map
     */
    public String getParameter(String key) {

        if (this.parameters == null || !this.parameters.containsKey(key)) {
            return '';
        }
        return this.parameters.get(key);
    }

    /**
     *  Get the whole parameter map
     */
    public Map<String, String> getParameters() {

        if (this.parameters == null) {
            this.parameters = new Map<String, String>();
        }
        return this.parameters;
    }

    // Test Methods
    static testMethod void testGettersAndSetters() {

        TdrSelectorController controller = new TdrSelectorController();
        controller.setTdrList(controller.getTdrList());
        controller.setFormDetails(controller.getFormDetails());
        controller.setCountry(controller.getCountry());
        controller.setCountrys(controller.getCountrys());
        controller.setCountry(controller.getCountrys()[0].getValue());
        controller.setRegions(controller.getRegions());
        controller.setRegion(controller.getRegion());
        controller.setRegion(controller.getRegions()[1].getValue());
        controller.setTdrs(controller.getTdrs());
        controller.setTdrList(controller.getTdrList());
        controller.setYear(controller.getYear());
        controller.setYears(controller.getYears());
        controller.setMonth(controller.getMonth());
        controller.setMonths(controller.getMonths());
        controller.setHideForTargets(controller.getHideForTargets());
        controller.setHideForDefaultTargets(controller.getHideForDefaultTargets());

    }

    static testMethod void testGetParameters() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        PageReference pageRef = Page.TdrRegistration;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', '');
        pageRef.getParameters().put('monthParam', '');
        pageRef.getParameters().put('weeklyRangeStartParam', '');
        pageRef.getParameters().put('weeklyRangeEndParam', '');
        pageRef.getParameters().put('showWeeklyParam', 'false');
        Test.setCurrentPage(pageRef);
        TdrSelectorController controller = new TdrSelectorController();

        // Test Yearly
        pageRef.getParameters().put('yearParam', '2011');
        Test.setCurrentPage(pageRef);
        controller.getTdrParameters();
        System.assertEquals('YEARLY', controller.getParameter('type'));

        // Test Monthly
        pageRef.getParameters().put('monthParam', '11');
        Test.setCurrentPage(pageRef);
        controller.getTdrParameters();
        System.assertEquals('MONTHLY', controller.getParameter('type'));

        // Test Daily
        pageRef.getParameters().put('weeklyRangeStartParam', '11/30/2011');
        pageRef.getParameters().put('weeklyRangeEndParam', '11/30/2011');
        Test.setCurrentPage(pageRef);
        controller.getTdrParameters();
        System.assertEquals('DAILY', controller.getParameter('type'));

        // Test Weekly
        pageRef.getParameters().put('showWeeklyParam', 'true');
        Test.setCurrentPage(pageRef);
        controller.getTdrParameters();
        System.assertEquals('WEEKLY', controller.getParameter('type'));
    }
}