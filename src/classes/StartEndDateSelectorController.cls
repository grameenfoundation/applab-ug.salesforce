/**
 *  Controller for the component that controls the date pickers.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class StartEndDateSelectorController extends ChildComponentBase {

    public StartEndDateSelectorController() {
        this.datePicker = new Date_Picker__c();
        this.datePicker.Start_Date__c = null;
        this.datePicker.End_Date__c = null;
    }

    public Date_Picker__c datePicker;
    public Date_Picker__c getDatePicker() {
        return this.datePicker;
    }
    public void setDatePicker(Date_Picker__c value) {
        this.datePicker = value;
        addParameterToParent(getValues());
    }

    // Override the method that gets the values
    public override String getValues() {
        String values = '';
        if (getDatePicker().Start_Date__c == null) {
            values += 'start_date_int_NONE';
        }
        else {
            values += 'start_date_int_' + String.valueOf(MetricHelpers.convertToStartDate(getDatePicker().Start_Date__c).getTime());
        }
        values += '_ext_';
        if (getDatePicker().End_Date__c == null) {
            values += 'end_date_int_NONE';
        }
        else {
            values += 'end_date_int_' + String.valueOf(MetricHelpers.convertToEndDate(getDatePicker().End_Date__c).getTime());
        }
        System.debug(LoggingLevel.INFO, values);
        return values;
    }

    static testMethod void testController() {

        StartEndDateSelectorController controller = new StartEndDateSelectorController();
        System.assert(controller.getValues().equals('start_date_int_NONE_ext_end_date_int_NONE'));
        controller.datePicker.Start_Date__c = Date.today();
        System.assert(controller.getValues().equals('start_date_int_' + String.valueOf(MetricHelpers.convertToStartDate(controller.getDatePicker().Start_Date__c).getTime()) + '_ext_end_date_int_NONE'));
        controller.datePicker.End_Date__c = Date.today();
        System.assert(controller.getValues().equals('start_date_int_' + String.valueOf(MetricHelpers.convertToStartDate(controller.getDatePicker().Start_Date__c).getTime()) + '_ext_end_date_int_' + String.valueOf(MetricHelpers.convertToEndDate(controller.getDatePicker().End_Date__c).getTime()) + ''));
    }
}