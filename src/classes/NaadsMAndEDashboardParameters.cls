public class NaadsMAndEDashboardParameters {

    /**
     *  This class generates the parameters for Naads Dashboard.  There is a lot of hardcoding here
     *  but the idea is that we set these up along with the M_E_Metric objects and then we don't have to do
     *  much work again unless a new metric is added and then we create the parameter and M_E_Metric object
     *  and away you go
     */
    public static Map<String, MetricDataCalculationParameters> getParameters(Boolean isTest) {

        Map<String, MetricDataCalculationParameters> parameters = new Map<String, MetricDataCalculationParameters>();

        // Create a Map of all the surveys that are linked to the Naads account
        Map<String, Survey__c> surveys = new Map<String, Survey__c>();
        for (Survey__c survey : Utils.loadSurveysByOrgName('NAADS')) {
            surveys.put(survey.Name, survey);
        }

        // Check that there are some surveys. Otherwise no point in carrying on
        if (surveys.isEmpty() && !isTest) {
            return parameters;
        }

        // Now the hardcoding begins. I am sorry about this but you gotta do what you gotta do. Think of it
        // as a config file if it helps you get over the uglyness
        List<String> groupBy = new List<String>();
        groupBy.add('District__r.Name');

        // Parameters based on the M&E Baseline survey
        Survey__c survey = surveys.get('2011060136');
        if (isTest) {
            survey = null;
        }
        MetricDataCalculationParameters param = new MetricDataCalculationParameters(
                'NAADS_services_past_six_months',
                'boolean',
                'percentage',
                'q38',
                survey,
                groupBy);
        parameters.put('NAADS_services_past_six_months', param);

        param = new MetricDataCalculationParameters(
                'NAADS_village_fora_members',
                'boolean',
                'percentage',
                'q28',
                survey,
                groupBy);
        parameters.put('NAADS_village_fora_members', param);

        param = new MetricDataCalculationParameters(
                'NAADS_trained_by_fid',
                'multiSelect',
                'percentage',
                'q29',
                survey,
                groupBy);
        param.setSelectOptions('1');
        parameters.put('NAADS_trained_by_fid', param);

        param = new MetricDataCalculationParameters(
                'NAADS_money_advandced_to_farmers',
                'boolean',
                'percentage',
                'q48',
                survey,
                groupBy);
        parameters.put('NAADS_money_advandced_to_farmers', param);

        param = new MetricDataCalculationParameters(
                'NAADS_farmers_registered_hlfo',
                'boolean',
                'percentage',
                'q42',
                survey,
                groupBy);
        parameters.put('NAADS_farmers_registered_hlfo', param);

        param = new MetricDataCalculationParameters(
                'NAADS_farmer_adoption',
                'boolean',
                'percentage',
                'q22',
                survey,
                groupBy);
        parameters.put('NAADS_farmer_adoption', param);

/* DONT SUPPORT THE RELIANT QUESTIONS YET
        param = new MetricDataCalculationParameters(
                'NAADS_positive_adoption',
                'boolean',
                'percentage',
                'q24',
                survey,
                groupBy);
        parameters.put('NAADS_positive_adoption', param);
*/
        param = new MetricDataCalculationParameters(
                'NAADS_active_groups',
                'singleSelect',
                'percentage',
                'q17',
                survey,
                groupBy);
        param.setSelectOptions('1 2 3');
        parameters.put('NAADS_active_groups', param);

        param = new MetricDataCalculationParameters(
                'NAADS_farmer_enterprise_groups',
                'singleSelect',
                'percentage',
                'q18',
                survey,
                groupBy);
        param.setSelectOptions('1 3 4');
        parameters.put('NAADS_farmer_enterprise_groups', param);

        param = new MetricDataCalculationParameters(
                'NAADS_group_savers',
                'boolean',
                'percentage',
                'q25',
                survey,
                groupBy);
        parameters.put('NAADS_group_savers', param);

        param = new MetricDataCalculationParameters(
                'NAADS_positive_market_price_info',
                'boolean',
                'percentage',
                'q40',
                survey,
                groupBy);
        parameters.put('NAADS_positive_market_price_info', param);

        param = new MetricDataCalculationParameters(
                'NAADS_increased_participation',
                'boolean',
                'percentage',
                'q44',
                survey,
                groupBy);
        parameters.put('NAADS_increased_participation', param);

        param = new MetricDataCalculationParameters(
                'NAADS_farmer_increase_due_to_participation',
                'singleSelect',
                'percentage',
                'q45',
                survey,
                groupBy);
        param.setSelectOptions('1');
        parameters.put('NAADS_farmer_increase_due_to_participation', param);

        // Parameters based on the sub-county returns
        survey = surveys.get('2011060138');
            if (isTest) {
                survey = null;
            }
        param = new MetricDataCalculationParameters(
                'NAADS_groups_mobilised_per_subcounty',
                'number',
                'average',
                'q19',
                survey,
                groupBy);
        parameters.put('NAADS_groups_mobilised_per_subcounty', param);

        param = new MetricDataCalculationParameters(
                'NAADS_numbers_of_aasps',
                'number',
                'sum',
                'q7',
                survey,
                groupBy);
        parameters.put('NAADS_numbers_of_aasps', param);

        param = new MetricDataCalculationParameters(
                'NAADS_trained_by_aasps',
                'number',
                'average',
                'q8',
                survey,
                groupBy);
        parameters.put('', param);

        param = new MetricDataCalculationParameters(
                'NAADS_functional_parish_coordinators',
                'number',
                'sum',
                'q18',
                survey,
                groupBy);
        parameters.put('NAADS_functional_parish_coordinators', param);

        param = new MetricDataCalculationParameters(
                'NAADS_tech_demo_packs',
                'number',
                'average',
                'q2',
                survey,
                groupBy);
        parameters.put('NAADS_tech_demo_packs', param);

        param = new MetricDataCalculationParameters(
                'NAADS_total_food_security_farmers',
                'number',
                'sum',
                'q11',
                survey,
                groupBy);
        parameters.put('NAADS_total_food_security_farmers', param);

        param = new MetricDataCalculationParameters(
                'NAADS_market_farmers_supported',
                'number',
                'sum',
                'q12',
                survey,
                groupBy);
        parameters.put('NAADS_market_farmers_supported', param);

        return parameters;
    }

    static testMethod void testParamGeneration() {

        Map<String, MetricDataCalculationParameters> parameters = getParameters(true);
        System.assertEquals(parameters.size(), 19);
    }
}