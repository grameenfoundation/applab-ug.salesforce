/**
 * Virtual class that sets up the basic methods to be used by all components that are grouped together in a parent component.
 * Allows the child components to share their values between each other.
 */

public with sharing virtual class ChildComponentBase {

    // Key for the section that this compononet is part of
    // Assigned from the attribute passed into the component
    private String sectionKey;
    public String getSectionKey() {
        return this.sectionKey;
    }
    public void setSectionKey(String value) {
        this.sectionKey = value;
    }

    // Unique key for this child component. Used for identification by the parent
    // Assigned from the attribute passed into the component
    private String key;
    public String getKey() {
        return this.key;
    }
    public void setKey(String key) {
        this.key = key;
        if (this.parentComponentController != null) {
            this.parentComponentController.setChildMap(key, this);
        }
    }

    // Parent controller. Assigned from the attribute passed into the component
    private ParentComponentBase parentComponentController;
    public ParentComponentBase getParentComponentController() {
        return this.parentComponentController;
    }
    public void setParentComponentController (ParentComponentBase controller) {
        this.parentComponentController = controller;
        if (this.key != null) {
            this.parentComponentController.setChildMap(this.key, this);
        }
    }

    private Boolean showData = true;
    public Boolean getShowData() {
        return this.showData;
    }
    public void setShowData(Boolean value) {
        this.showData = value;
    }

    private Boolean expanded;
    public Boolean getExpanded() {
        return this.expanded;
    }
    public void setExpanded(Boolean value) {
        this.expanded = value;
    }

    // The name of the sObject type that is being used by the extending class
    public String sObjectName;

    // Id for the record being used. Needed if we get access to this before the actual sObject. Can then load the sObject in the extending class
    public String sObjectId;
    public String getsObjectId() {
        return this.sObjectId;
    }
    public virtual void setsObjectId(String value) {
        this.sObjectId = value;
    }

    // The record that the extending class is dealing with
    public sObject sObjectRecord;
    public virtual sObject getsObjectRecord() {
        return this.sObjectRecord;
    }
    public virtual void setsObjectRecord(sObject value) {
        this.sObjectId = value.Id;
        this.sObjectRecord = value;
    }

    // Set up the start date
    private Date startDate;
    public Date getStartDate() {
        return this.startDate;
    }
    public Date getStartDate(Boolean useDefault) {

        // Get the date period from the controlling sObject
        String datePeriod = getFieldValue('Date_Period__c');
        if (datePeriod == null) {
            datePeriod = getParentValue('DatePeriod');
        }
        String ds = getFieldValue('Default_Show__c');
        Integer defaultShow = 0;
        if (!ds.equals('')) {
            defaultShow = Integer.valueOf(ds);
        }

        // Looking for all records so no need to set a start time
        if (datePeriod.equals('All')) {
            this.startDate = null;
        }
        else {

            // Default the start date if one has not been entered by a selector component in the same section
            if (this.startDate == null && useDefault) {
                if (datePeriod.equalsIgnoreCase('Day')) {
                    this.startDate = Date.today().addDays(-defaultShow);
                }
                else if (datePeriod.equalsIgnoreCase('Week')) {
                    this.startDate = Date.today().toStartOfWeek().addDays(-defaultShow * 7);
                }
                else if (datePeriod.equalsIgnoreCase('Month')) {
                    this.startDate = Date.today().toStartOfMonth().addMonths(-defaultShow);
                }
                else if (datePeriod.equalsIgnoreCase('Quarter')) {
                    this.startDate = Date.today().toStartOfMonth().addMonths(-defaultShow * 3);
                }
                else {
                    this.startDate = Date.parse('01/01/' + Date.today().year()).addMonths(-defaultShow * 12);
                }
            }
        }
        return this.startDate;
    }
    public void setStartDate(Date newStartDate) {
        this.startDate = newStartDate;
    }

    // Set up the end date
    private Date endDate;
    public Date getEndDate() {
        return this.endDate;
    }
    public Date getEndDate(Boolean useDefault) {

        String datePeriod = getFieldValue('Date_Period__c');
        if (datePeriod == null) {
            datePeriod = getParentValue('DatePeriod');
        }
        String ds = getFieldValue('Default_Show__c');
        Integer defaultShow = 0;
        if (!ds.equals('')) {
            defaultShow = Integer.valueOf(ds);
        }
        if (datePeriod.equals('All')) {
            this.endDate = null;
        }
        else {
            if (this.endDate == null) {
                if (useDefault) {
                    this.endDate = Date.today();
                }
                else {
                    return null;
                }
            }
            if (datePeriod.equalsIgnoreCase('Week')) {
                this.endDate = this.endDate.toStartOfWeek().addDays(6);
            }
            else if (datePeriod.equalsIgnoreCase('Month')) {
                this.endDate = this.endDate.toStartOfMonth().addMonths(1).addDays(-1);
            }
            else if (datePeriod.equalsIgnoreCase('Quarter')) {
                this.endDate = this.endDate.toStartOfMonth().addMonths(3).addDays(-1);
            }
            else if (datePeriod.equalsIgnoreCase('Year')) {
                this.endDate = Date.parse('01/01/' + this.endDate.year()).addMonths(12).addDays(-1);
           }
        }
        return this.endDate;
    }
    public void setEndDate(Date newEndDate) {
        this.endDate = newEndDate;
    }

    /**
     *  Takes the date string generated by the date components and converts into usable dates
     */
    public virtual void setDates(String dateString) {

        String[] dates = dateString.split('_ext_');
        for (Integer i = 0; i < dates.size(); i++) {
            String[] dateArray = dates[i].split('_int_');
            if (dateArray.size() != 2) {
                continue;
            }
            if (dateArray[0].equals('start_date') && !dateArray[1].equals('NONE')) {
                setStartDate(DateTime.newInstance(Long.valueOf(dateArray[1])).date());
                System.debug(dateArray[1]);
            }
            else if (dateArray[0].equals('end_date') && !dateArray[1].equals('NONE')) {
                setEndDate(DateTime.newInstance(Long.valueOf(dateArray[1])).date());
                System.debug(dateArray[1]);
            }
        }
    }

    // Set the dimensions for the child componenets displays
    private String width;
    public String getWidth() {
        return this.width;
    }
    public void setWidth(String value) {
        this.width = value;
    }
    private String height;
    public string getHeight() {
        return this.height;
    }
    public void setHeight(String value) {
        this.height = value;
    }

    /**
     *  Get a value from a fellow child component with the same parent controller
     *
     *  @param key - The key for the child component that the value is coming from
     */
    public String getParentValue(String key) {

        String value = '';
        if (this.getParentComponentController() != null) {
             value = this.getParentComponentController().getParameter(key + this.getSectionKey());
        }
        return value;
    }

    /**
     *  Add a value to the parents parameterMap if a parent exists
     */
    public void addParameterToParent(String value) {

        if (this.getParentComponentController() != null) {
            this.getParentComponentController().addParameter(getKey(), value);
        }
    }

    /**
     * Add a parameter for any key
     */
    public void addGeneralParamter(String key, String value) {
        if (this.getParentComponentController() != null) {
            this.getParentComponentController().addParameter(key, value);
        }
    }

    /**
     *  Get the key for the parent
     */
    public String getParentKey() {

        String value = '';
        if (this.getParentComponentController() != null) {
             value = this.getParentComponentController().getKey();
        }
        return value;
    }

    /**
     *  Default method that returns an empty string. Override in entending class to
     *  getValues from the object needed.
     */
    public virtual String getFieldValue(String fieldApiName) {

        if (this.fieldMap == null) {
            initFieldMap(this.sObjectName);
        }
        if (!this.fieldMap.containsKey(fieldApiName)) {
            System.debug(LoggingLevel.INFO, 'NO Field with api Name: ' + fieldApiName);
            return '';
        }
        Schema.DescribeFieldResult field = this.fieldMap.get(fieldApiName).getDescribe();

        String value = '';
        if (String.valueOf(field.getType()).equals('DATE')) {
            Date output = (Date)this.sObjectRecord.get(fieldApiName);
            value = output.year() + '==' + output.month() + '==' + output.day();
        }
        else {
            value = String.valueOf(this.sObjectRecord.get(fieldApiName));
        }
        return value;
    }

    // Load the sObject api field map
    public Map<String, Schema.SObjectField> fieldMap;
    public void initFieldMap(String sObjectName) {

        Schema.sObjectType sObjectTypeMain = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult sObjectResultMain =  sObjectTypeMain.getDescribe();
        this.fieldMap = sObjectResultMain.fields.getMap();
    }

    /**
     * Default to return a blank String i.e. nothing gets refreshed when the component is chaged
     */
    public virtual String getRefreshList() {
        return '';
    }

    /**
     *  Default to return blank string so the controller doesn't add to the parameters
     *  really should be overriden by the extending class to allow the component to work as it should
     */
    public virtual String getValues() {
        return '';
    }

    /**
     * Dummy method that allows an actionFunction to call it so that the component can be reRendered
     */
    public virtual PageReference refreshData() {
        return null;
    }

    /**
     * Dummy method that allows an actionFunction to call it so that the component value can be added
     */
    public virtual PageReference setData() {
        return null;
    }

    public PageReference bounce() {
        return null;
    }
}