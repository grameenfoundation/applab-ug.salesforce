public with sharing class FieldListBreakdownController extends ChildComponentBase {

    private String fieldName;
    public String getFieldName() {
        return this.fieldName;
    }
    public void setFieldName(String value) {
        this.fieldName = value;
    }

    private String objectName;
    public String getObjectName() {
        return this.objectName;
    }
    public void setObjectName(String value) {
        this.objectName = value;
    }

    private Integer rowCount;
    public Integer getRowCount() {
        return this.rowCount;
    }
    public void setRowCount(Integer value) {
        this.rowCount = value;
    }

    private Integer pageNumber = 1;
    public Integer getPageNumber() {
        return this.pageNumber;
    }
    public void setPageNumber(Integer value) {
        this.pageNumber = value;
    }

    private Integer totalPageNumber;
    public Integer getTotalPageNumber() {
        return this.totalPageNumber;
    }
    public void setTotalPageNumber(Integer value) {
        this.totalPageNumber = value;
    }

    // Pagination contollers
    private void setPaginationButtons() {

        setDisableFirstButton(false);
        setDisableNextButton(false);
        setDisablePreviousButton(false);
        setDisableLastButton(false);
        if (getTotalPageNumber() == 1) {
            setDisableFirstButton(true);
            setDisableNextButton(true);
            setDisablePreviousButton(true);
            setDisableLastButton(true);
            return;
        }
        if (getPageNumber() == 1) {
            setDisableFirstButton(true);
            setDisablePreviousButton(true);
        }
        else if (getPageNumber() == getTotalPageNumber()) {
            setDisableNextButton(true);
            setDisableLastButton(true);
        }
    }

    public PageReference goToFirstPage() {

        setPageNumber(1);
        loadRowListPage();
        setPaginationButtons();
        return null; 
    }
    public Boolean disableFirstButton;
    public Boolean getDisableFirstButton() {
        return this.disableFirstButton;
    }
    public void setDisableFirstButton(Boolean bool) {
        this.disableFirstButton = bool;
    }

    public PageReference goToNextPage() {

        setPageNumber(getPageNumber() + 1);
        loadRowListPage();
        setPaginationButtons();
        return null; 
    }
    public Boolean disableNextButton;
    public Boolean getDisableNextButton() {
        return this.disableNextButton;
    }
    public void setDisableNextButton(Boolean bool) {
        this.disableNextButton = bool;
    }

    public PageReference goToPreviousPage() {

        setPageNumber(getPageNumber() - 1);
        loadRowListPage();
        setPaginationButtons();
        return null; 
    }
    public Boolean disablePreviousButton;
    public Boolean getDisablePreviousButton() {
        return this.disablePreviousButton;
    }
    public void setDisablePreviousButton(Boolean bool) {
        this.disablePreviousButton = bool;
    }

    public PageReference goToLastPage() {

        setPageNumber(getTotalPageNumber());
        loadRowListPage();
        setPaginationButtons();
        return null; 
    }
    public Boolean disableLastButton;
    public Boolean getDisableLastButton() {
        return this.disableLastButton;
    }
    public void setDisableLastButton(Boolean bool) {
        this.disableLastButton = bool;
    }

    public List<SelectOption> numberOfRows;
    public List<SelectOption> getNumberOfRows() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100', '100'));
        options.add(new SelectOption('200', '200'));
        return options;
    }
    public void setNumberOfRows(List<SelectOption> options) {
        this.numberOfRows = options;
    }

    public PageReference changePageNumber() {

        setRowCount(Integer.valueOf(Apexpages.currentPage().getParameters().get('pageNumberParam')));
        setPageNumber(1);
        loadRowListPage();
        Decimal numberOfPages = 0;
        if (this.allRows != null) {
            numberOfPages = this.allRows.size();
            setTotalPageNumber(numberOfPages.divide((Decimal)getRowCount(), 0, System.RoundingMode.CEILING).intvalue());
            setPaginationButtons();
        }
        return null;
    }

    private List<RowWrapper> allRows;
    private void getAllRows() {

        this.allRows = new List<RowWrapper>();
        String currentName = '';
        for (Field_Officer_Productivity__c[] activityList : database.query(getQuery())) {
            for (Field_Officer_Productivity__c activity : activityList) {
                Boolean isNewName = false;
                String newName = activity.Field_Officer__r.First_Name__c + ' ' + activity.Field_Officer__r.Last_Name__c;
                if (newName.equals(currentName)
                ) {
                    isNewName = true;
                    currentName = newName;
                }
                String intervieweeName = '';
                if (activity.Interviewee__r.Last_Name__c != null) {
                    intervieweeName = activity.Interviewee__r.Last_Name__c + ' ';
                }
                if (activity.Interviewee__r.First_Name__c != null) {
                    intervieweeName += activity.Interviewee__r.First_Name__c;
                }
                RowWrapper wrapper = new RowWrapper(
                    newName,
                    intervieweeName,
                    activity.Additional_Comments__c
                );
                wrapper.changeIsFirstRow(isNewName, false);
                this.allRows.add(wrapper);
            }
        }
        if (this.allRows.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The are no comments for the parameters you have selected'));
            this.allRows = null;
            setTotalPageNumber(0);
        }
        else {
            Decimal numberOfPages = (Decimal)this.allRows.size();
            setTotalPageNumber(numberOfPages.divide((Decimal)getRowCount(), 0, System.RoundingMode.CEILING).intvalue());
        }
        setPaginationButtons();
    }

    private String getQuery() {

        String query = 'SELECT ' +
                'Additional_Comments__c, ' +
                'Field_Officer__c, ' +
                'Field_Officer__r.Last_Name__c, ' +
                'Field_Officer__r.First_Name__c, ' +
                'Interviewee__r.Last_Name__c, ' +
                'Interviewee__r.First_Name__c, ' +
                'Start_Date__c ' +
            'FROM ' +
                'Field_Officer_Productivity__c ' +
            generateWhereClause(true, false) +
            ' ORDER BY ' +
                'Field_Officer__c, ' +
                'Field_Officer__r.Last_Name__c, ' +
                'Field_Officer__r.First_Name__c, ' +
                'Start_Date__c';
        System.debug(LoggingLevel.INFO, query);
        return query;

    }

    private String translateType() {

        Map<String, String> translationMap = new Map<String, String> {
            'one' => 'FO/CKW 1:1',
            'peer' => 'PEER GROUP SESSION',
            'high' => 'HIGH PERFORMER CALLS',
            'farmer' => 'FARMER GROUP SESSION'
        };
        return translationMap.get(this.fieldName);
    }

    /**
     * Generate the where clause from the selectors
     *
     * @param addWhere             - Boolean to indicate that a WHERE should start the returned query.
     *                                  If true ignores startWithAnd as both cannot happen
     * @param startWithAnd         - Boolean to indicate that an AND should start the returned query
     *
     * @return - The where clause
     */
    private String generateWhereClause(Boolean addWhere, Boolean startWithAnd) {

        List<String> clauses = new List<String>();
        if (!getParentValue('Person__c').equals('') && !getParentValue('Person__c').equals('All')) {
            clauses.add('Person__c = \'' + getParentValue('Person__c') + '\'');
        }
        if (getStartDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate()), true), false));
        }
        if (getEndDate() != null) {
            clauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate()), true), false));
        }
        clauses.add('Submission_Type__c = \'' + translateType() + '\'');
        return FieldOfficeHelpers.joinWhereClause(clauses, addWhere, startWithAnd) + ' ';
    }

    public void loadRowListPage() {

        this.rowList = new List<RowWrapper>();
        Integer startPoint = (getPageNumber() - 1) * getRowCount();
        Integer endPoint = startPoint + getRowCount() + 1;
        if (this.allRows == null) {
            return;
        }
        if (endPoint > this.allRows.size()) {
            endPoint = this.allRows.size();
        }

        for (Integer i = startPoint; i < endPoint; i++) {
            this.allRows.get(i).checkIsFromPage();
            rowList.add(this.allRows.get(i));
        }

        // Make sure that the first object is always showing the name
        this.allRows.get(startPoint).changeIsFirstRow(true, true);
        setPaginationButtons();
    }

    private List<RowWrapper> rowList;
    public List<RowWrapper> getRowList() {
        if (this.rowList == null && getFieldName() != null) {
            getAllRows();
            loadRowListPage();
        }
        return this.rowList;
    }
    public void setRowList(List<RowWrapper> values) {
        this.rowList = values;
    }

    public class RowWrapper {
        private String displayName;
        private String displayIntName;
        private String displayValue;

        // Indicate if this is the first row of a person. This means we do not have to show the name again
        public Boolean isFirstRow { get; set; }
        private Boolean isFromPage;

        public RowWrapper(String displayName, String displayIntName, String displayValue) {
            this.displayName = displayName;
            this.displayIntName = displayIntName;
            this.displayValue = displayValue;

            // Default this to false. It will be updated by the controller if required
            this.isFirstRow = false;
            this.isFromPage = false;
        }

        public void changeIsFirstRow(Boolean isFirst, Boolean isFromPage) {

            // If this object is already the first row due to it being the first object of the day
            // then leave that set and dont set isFromPage
            if (this.isFirstRow) {
                return;
            }
            this.isFirstRow = isFirst;
            this.isFromPage = isFromPage;
        }

        /**
         *  Checkt to see if the show name was set from pagination. If it was then remove the bool value
         */
        public void checkIsFromPage() {

            if (!isFromPage) {
                return;
            }
            if (isFromPage) {
                this.isFirstRow = false;
            }
        }

        public String getDisplayName() {
            return this.displayName;
        }
        public void setDisplayName(String value) {
            this.displayName = value;
        }

        public String getDisplayIntName() {
            return this.displayIntName;
        }
        public void setDisplayIntName(String value) {
            this.displayIntName = value;
        }

        public String getDisplayValue() {
            return this.displayValue;
        }
        public void setDisplayValue(String value) {
            this.displayValue = value;
        }
    }

    public override PageReference refreshData() {
        getAllRows();
        loadRowListPage();
        return null;
    }

  /**  static testMethod void testController() {

        Person__c person = Utils.createTestPerson(null, 'Island', false, null, 'Female');
        person.Type__c = 'Field Officer';
        Database.insert(person);

        // Add some data
        Field_Officer_Productivity__c fop1 = new Field_Officer_Productivity__c();
        fop1.Submission_Type__c = 'FO/CKW 1:1';
        fop1.Additional_Comments__c = 'fas';
        fop1.Start_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        fop1.End_Time__c = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMinutes(30);
        fop1.Latitude__c = '2';
        fop1.Longitude__c = '2';
        fop1.Field_Officer__c = person.Id;
        Database.insert(fop1);

        PageReference pageRef = Page.FieldOfficerBreakDown;
        pageRef.getParameters().put('pageNumberParam', '1');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();

        FieldListBreakdownController controller = new FieldListBreakdownController();
        controller.setFieldName('one');
        controller.setObjectName('None');
        controller.getObjectName();
        controller.setRowCount(10);
        controller.getRowList();
        controller.goToFirstPage();
        controller.goToLastPage();
        controller.getNumberOfRows();
        controller.getDisableFirstButton();
        controller.setDisableFirstButton(true);
        controller.getDisableNextButton();
        controller.setDisableNextButton(true);
        controller.getDisablePreviousButton();
        controller.setDisablePreviousButton(false);
        controller.getDisableLastButton();
        controller.setDisableLastButton(false);
        controller.changePageNumber();
    }**/
}