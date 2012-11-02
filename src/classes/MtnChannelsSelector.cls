public with sharing class MtnChannelsSelector extends ParentComponentBase {

    private Boolean selectorLoaded = false;

    // The selector object that controls the display
    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {

        if (!this.selectorLoaded) {
            this.selector = [
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
                    Show_Data_Validator__c,
                    Show_CKW__c,
                    Show_Farmer__c,
                    Show_Field_Officer__c,
                    Show_MTN_Chan__c,
                    Date_Period__c,
                    Show_Submit_Button__c,
                    Start_Date__c
                FROM
                    Dashboard_Selector__c
                WHERE
                    Dashboard_Section__r.Dashboard__r.Name = 'MTN Channels'
            ];
        }
        return this.selector;
    }

    // Get the parameters out from the selector on the page
    public override void rebuildParameters() {
        this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
        this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
        addParameter('outletTypekey', this.getOutletType());
        addParameter('stockTypekey', this.getStockType());
        addParameter('merchandiseTypekey', this.getMerchandiseType());
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
        options.add(new SelectOption('', '---All---'));
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
        options.add(new SelectOption('', '---All---'));
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
        options.add(new SelectOption('', '---All---'));
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

    // Booleans to indicate the graphs that should be show
    private Boolean showOutlet;
    public Boolean getShowOutlet() {
        return this.showOutlet;
    }
    public void setShowOutlet(Boolean value) {
        this.showOutlet = value;
    }

    private Boolean showPromotion;
    public Boolean getShowPromotion() {
        return this.showPromotion;
    }
    public void setShowPromotion(Boolean value) {
        this.showPromotion = value;
    }

    private Boolean showStockGraph;
    public Boolean getShowStockGraph() {
        return this.showStockGraph;
    }
    public void setShowStockGraph(Boolean value) {
        this.showStockGraph = value;
    }

    private Boolean showDSD;
    public Boolean getShowDSD() {
        return this.showDSD;
    }
    public void setShowDSD(Boolean value) {
        this.showDSD = value;
    }

    private Boolean showCompetitorGraph;
    public Boolean getShowCompetitorGraph() {
        return this.showCompetitorGraph;
    }
    public void setShowCompetitorGraph(Boolean value) {
        this.showCompetitorGraph = value;
    }

    private Boolean showCompetitorStockGraph;
    public Boolean getShowCompetitorStockGraph() {
        return this.showCompetitorStockGraph;
    }
    public void setShowCompetitorStockGraph(Boolean value) {
        this.showCompetitorStockGraph = value;
    }

    private String xAxisType;
    public String getxAxisType() {
        return this.xAxisType;
    }
    public void setxAxisType(String value) {
        this.xAxisType = value;
    }

    /**
     * Refresh all the graphs on the dashboard
     */
    public PageReference refreshAll() {

        this.setShowOutlet(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showOutlet')));
        this.setShowPromotion(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showPromotion')));
        this.setShowStockGraph(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showStockGraph')));
        this.setShowDSD(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showDSD')));
        this.setShowCompetitorGraph(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showCompetitorGraph')));
        this.setShowCompetitorStockGraph(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showCompetitorStockGraph')));
        this.setOutletType(Apexpages.currentPage().getParameters().get('outletType'));
        this.setStockType(Apexpages.currentPage().getParameters().get('stockType'));
        this.setMerchandiseType(Apexpages.currentPage().getParameters().get('merchandiseType'));
        this.setxAxisType(Apexpages.currentPage().getParameters().get('xAxisType'));
        return null;
    }
    
    static testmethod void testAll() {
        MtnChannelsSelector controller = new MtnChannelsSelector();
        //controller.refreshAll();
        controller.getStockTypes();
        controller.getStockType();
        controller.getMerchandiseTypes();
        controller.getMerchandiseType();
        controller.getShowDSD();
        controller.getShowOutlet();
        controller.getShowCompetitorGraph();
        controller.getxAxisType();
    }
}