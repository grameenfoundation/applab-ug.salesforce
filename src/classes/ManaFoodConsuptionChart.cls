public with sharing class ManaConsuptionChart {

    private Mana_Household__c mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ManaConsuptionChart(ApexPages.StandardController stdController) {
        this.mysObject = (Mana_Household__c)stdController.getRecord();
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }
}