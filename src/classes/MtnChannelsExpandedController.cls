public with sharing class MtnChannelsExpandedController extends ParentComponentBase {


    public MtnChannelsExpandedController() {
        PageReference pageRef = ApexPages.currentPage();
        this.graph = pageRef.getParameters().get('id');
        String typeOfPage = pageRef.getParameters().get('type');

        if (this.graph == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An id has not been provided so cannot display a visual'));
            System.debug(LoggingLevel.INFO, 'No id provided so cannot continue');
        }
        else {

            if (typeOfPage.equals('graph')) {
                loadGraph();
            }
            else {
                System.debug(LoggingLevel.INFO, 'Unrecognised type: ' + typeOfPage);
            }
            loadSelector();
            setxAxisType('1');
        }
    }

    public String graph { get; set; }

    public Dashboard_Selector__c selector { get; set; }
    private String sectionId;

    public override void rebuildParameters() {
        this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
        this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
        addParameter('outletType' + getSectionKey(), this.getOutletType());
        addParameter('stockType' + getSectionKey(), this.getStockType());
        addParameter('merchandiseType' + getSectionKey(), this.getMerchandiseType());
    }

    // Store the selected outlet type
    private String outletType;
    public String getOutletType() {
        return this.outletType;
    }
    public void setOutletType(String value) {
        this.outletType = value;
    }

    // Get the available outlet types
    private List<SelectOption> outletTypes;
    public List<SelectOption> getOutletTypes() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---All--'));
        Schema.DescribeFieldResult field = MTN_Channels_Activity__c.Outlet_Type__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()) {
            options.add(new SelectOption(f.getLabel(), f.getLabel()));
        }
        return options;
    }

    // Store the selected stock type
    private String stockType;
    public String getStockType() {
        return this.stockType;
    }
    public void setStockType(String value) {
        this.stockType = value;
    }

    // Get the available types of stock
    private List<SelectOption> stockTypes;
    public List<SelectOption> getStockTypes() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---All--'));
        options.add(new SelectOption('Modems', 'Modems'));
        options.add(new SelectOption('Phones', 'Phones'));
        options.add(new SelectOption('Easy_Load', 'Easy Load'));
        options.add(new SelectOption('Scratch_Cards', 'Scratch Cards'));
        options.add(new SelectOption('Sim_Packs', 'SIM Packs'));
        return options;
    }

    // Store the selected merchandise type
    private String merchandiseType;
    public String getMerchandiseType() {
        return this.merchandiseType;
    }
    public void setMerchandiseType(String value) {
        this.merchandiseType = value;
    }

    // Get the available types of merchandise
    private List<SelectOption> merchandiseTypes;
    public List<SelectOption> getMerchandiseTypes() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---All--'));
        options.add(new SelectOption('Poster', 'Poster'));
        options.add(new SelectOption('Placard', 'Placards'));
        options.add(new SelectOption('SIM', 'SIM Pack Holder'));
        options.add(new SelectOption('Light_Box', 'Light Box'));
        options.add(new SelectOption('Co_Brand', 'Co-branded Box'));
        options.add(new SelectOption('Wall', 'Wall Branding'));
        options.add(new SelectOption('Dangler', 'Dangler'));
        options.add(new SelectOption('Other', 'Other'));
        options.add(new SelectOption('None', 'None'));
        return options;
    }

    private String xAxisType;
    public String getxAxisType() {
        return this.xAxisType;
    }
    public void setxAxisType(String value) {
        this.xAxisType = value;
    }

    public sObject graphParameter { get; set; }
    public Boolean showGraph { get; set; }

    private String accountName;
    public String getAccountName() {
        return this.accountName;
    }
    private void setAccountName(String value) {
        this.accountName = value;
    }

    private void loadGraph() {

        Graph_Parameter__c loadedGraphParameter = [SELECT
                Id,
                Name,
                Title__c,
                Title_Color__c,
                Legend_Color__c,
                Type_Of_Graph__c,
                xAxis_Series__c,
                xAxis_Title__c,
                xAxis_Color__c,
                yAxis_Color__c,
                yAxis_Title__c,
                Date_Period__c,
                Default_Show__c,
                Show_Data_Inline__c,
                Dashboard_Section__r.Has_Selector__c,
                Dashboard_Section__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name
            FROM 
                Graph_Parameter__c
            WHERE
                xAxis_Title__c = :this.graph];
        this.accountName = loadedGraphParameter.Dashboard_Section__r.Dashboard__r.Account__r.Name;
        this.graphParameter = loadedGraphParameter;
        this.sectionId = loadedGraphParameter.Dashboard_Section__c;
        this.showGraph = true;
    }

    private void loadSelector() {

        Dashboard_Selector__c[] selectors = [
            SELECT
                Name,
                Id,
                Show_Dates__c,
                Show_Metric_Date_Selector__c,
                Show_Country__c,
                Show_Region__c,
                Show_District__c,
                Show_Subcounty__c,
                Show_Person__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Show_Submit_Button__c,
                Start_Date__c
            FROM
                Dashboard_Selector__c
            WHERE
                Dashboard_Section__c = :this.sectionId];

        if (selectors.size() != 0) {
            this.selector = selectors[0];
        }
    }

    /**
     * Refresh all the graphs on the dashboard
     */
    public PageReference refreshAll() {

        this.setOutletType(Apexpages.currentPage().getParameters().get('outletType'));
        this.setStockType(Apexpages.currentPage().getParameters().get('stockType'));
        this.setMerchandiseType(Apexpages.currentPage().getParameters().get('merchandiseType'));
        this.setxAxisType(Apexpages.currentPage().getParameters().get('xAxisType'));
        return null;
    }
}