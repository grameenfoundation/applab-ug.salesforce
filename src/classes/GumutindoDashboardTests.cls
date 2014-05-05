@isTest
public with sharing class GumutindoDashboardTests {
	public GumutindoDashboardTests() {
         createMetrics();
	}
		
    static testMethod void testGumutindoDashboardController() {

        GumutindoDashboardController dashboard = new GumutindoDashboardController();
        MetricHelpers.getQuarterStartMonth(3);
        MetricHelpers.getQuarterEndMonth(3);
        System.assertNotEquals(null, dashboard.getSections());
        //createMetrics();

        
        
    }    
	
    public static void createMetrics() {
         database.saveResult saveResult;
        Account testAccount = Utils.createTestOrganisation('Gumutindo');
        database.insert(testAccount);
        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = testAccount.Id;
        dash.Description__c = 'Gumutindo Dashboard';
        dash.Title__c = 'Gumutindo Dashboard';
        saveResult = database.insert(dash);

        String dashboardId = saveResult.getId();

        Dashboard_Section__C dashboardsection = new Dashboard_Section__C();
        dashboardsection.Display_Order__c=0;
        dashboardsection.Has_Graphs__c=false;
        dashboardsection.Has_Metrics__c=true;
        dashboardsection.Has_Selector__c=true;
        dashboardsection.Has_Maps__c=true;
        dashboardsection.Is_Active__c=true;
        dashboardsection.Title__c='Test section';
        dashboardsection.Dashboard__c = dashboardId;
        saveResult = database.insert(dashboardsection);
        String dashboardsectionId = saveResult.getId();


        //Create selector
Dashboard_Selector__C selector = new Dashboard_Selector__C();
selector.Dashboard_Section__c = dashboardsectionId;
selector.Show_CKW__c = false;
selector.Show_Country__c = false;
selector.Show_Data_Validator__c = false;
selector.Start_Date__c = Date.today();


selector.Show_Dates__c = true;
database.insert(selector);


//Create map parameter for this section
Map_Parameter__C mapparameter = new Map_Parameter__C();
mapparameter.Keyword__c='Location of Gumutindo CKWs';
mapparameter.Dashboard_Section__c=dashboardsectionId;
mapparameter.Type_Of_sObject__c='Custom Class';
mapparameter.Map_Marker_Source_Class__c='GumutindoHelpers.GumutindoCkwCoordinatesProvider';
mapparameter.Zoom__c=6;
mapparameter.Latitude__c='0.5167';
mapparameter.Longitude__c='32.5833';
mapparameter.Title__c='Location of Gumutindo CKWs';



saveResult = database.insert(mapparameter);


//plot test
MapMarkers marker = new MapMarkers();
 

Metric_Section__c metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Farmers Reached by Year';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Farmers  by Year';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Show_Spark_Line__c = true;
metricsection.View_Mode__c='Disaggregated';

//metricsection.View_Mode__c='Disaggregated';
//metricsection.Show_Further_Link__c=true;
//metricsection.Show_Targets__c=true;

saveResult = database.insert(metricsection);

String metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics




M_E_Metric__c metric = new M_E_Metric__c();
metric.Label__c='% of Target farmers reached in Year 1 out of a  Target of 8000';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Name='Gumutindo_target_farmers_reached_in_year_1';



metric.Metric_Section__c=metricSectionId;

saveResult = database.insert(metric);

List<M_E_Metric__C> metr = [select Id from M_E_Metric__C where Name = 'Gumutindo_target_farmers_reached_in_year_1'];
System.debug('We\'ve selected');

M_E_Metric_Data__C metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Target farmers reached in Year 1';
metricdata.Numerator__c=30;
metricdata.Denumerator__c=8000;
metricdata.Date__c = Date.today();
metricdata.Projected_Value__c=85;
// database.insert(metricdata);

metric = new M_E_Metric__c();
metric.Label__c='% of Target farmers reached in Year 2 out of a  Target of 5000';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Projected_Value__c=85;
metric.Name='Gumutindo_target_farmers_reached_in_year_2';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Target farmers reached in Year 2';
metricdata.Numerator__c=0;
metricdata.Denumerator__c=5000;
metricdata.Date__c = Date.today();
// database.insert(metricdata);

metric = new M_E_Metric__c();
metric.Label__c='% of Target farmers reached in Year 3 out of a Target of 3000';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Projected_Value__c=85;
metric.Name='Gumutindo_target_farmers_reached_in_year_3';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Target farmers reached in Year 3';
metricdata.Numerator__c=0;
metricdata.Denumerator__c=2000;
metricdata.Date__c = Date.today();
// database.insert(metricdata);










//Create metric section

metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Services extended to farmers';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Services extended to farmers';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.View_Mode__c='Disaggregated';
saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics




metric = new M_E_Metric__c();
metric.Label__c='% of Target farmers using at least three of the recommended agronomic practices';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices';
saveResult = database.insert(metric);


metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Target farmers using at least three of the recommended agronomic practices';
metricdata.Numerator__c=30;
metricdata.Denumerator__c=50;
metricdata.Date__c = Date.today();
// database.insert(metricdata);



metric = new M_E_Metric__c();
metric.Label__c='% of farmers receive advisory services from CKWs network';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_receive_advisory_services_from_ckw_network';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmers receive advisory services from CKWs network';
metricdata.Numerator__c=0;
metricdata.Denumerator__c=0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




metric = new M_E_Metric__c();
metric.Label__c='% of farmer Groups receive advisory support from CKWs network ';
metric.Is_On_Fly__c=true;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmer_groups_who_receive_support_from_ckw_network';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmer Groups receive advisory support from CKWs network  ';
metricdata.Numerator__c=10;
metricdata.Denumerator__c=50;
metricdata.Date__c = Date.today();
// database.insert(metricdata);









//Dashboard section for agro inputs
//Create dashboard section for first metrics
/*
dashboardsection = new Dashboard_Section__C();
dashboardsection.Display_Order__c=2;
dashboardsection.Has_Graphs__c=false;
dashboardsection.Has_Metrics__c=true;
dashboardsection.Has_Selector__c=false;
dashboardsection.Has_Maps__c=false;
dashboardsection.Is_Active__c=true;
dashboardsection.Title__c='Agro Inputs Usage';
dashboardsection.Dashboard__c = dash;
saveResult = database.insert(dashboardsection);
dashboardsectionId = saveResult.getId();
*/
//Create metric section

metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Purchases';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Purchases';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Allow_Update__c = true;
metricsection.View_Mode__c='Disaggregated';
saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics




metric = new M_E_Metric__c();
metric.Label__c='% of farmers purchase organic fertilizer through GCCE';
metric.Is_On_Fly__c=false;
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_purchase_organic_fertilizer_through_gcce';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmers purchase organic fertilizer through GCCE';
//metricdata.Numerator__c=30;
//metricdata.Denumerator__c=100;
metricdata.Projected_Value__c = 100;
metricdata.Manual_Value__c=0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);


metric = new M_E_Metric__c();
metric.Label__c='% of farmers purchase organic seedlings through GCCE';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_purchase_organic_seedlings_through_gcce';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmers purchase organic seedlings through GCCE';
//metricdata.Numerator__c=30;
//metricdata.Denumerator__c=100;
metricdata.Projected_Value__c = 100;
metricdata.Manual_Value__c=0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);



//Next metric section
metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Coffee & Support Quality';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Coffee & Support Quality';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.View_Mode__c='Disaggregated';
metricsection.Allow_Update__c = true;


saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics

metric = new M_E_Metric__c();
metric.Label__c='% of GCCE farmers deliver 50% of high quality parchment coffee of their total production ';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_deliver_50_percent_of_hi_qual_coffee';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of GCCE farmers deliver 50% of high quality parchment coffee of their total production ';
//metricdata.Numerator__c=35;
//metricdata.Denumerator__c=100;
metricdata.Projected_Value__c = 65;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);


metric = new M_E_Metric__c();
metric.Label__c='% of farmers report satisfaction in the quality of extension support';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_report_satisfaction_quality_of_extension_support';

saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmers report satisfaction in the quality of extension support';
metricdata.Projected_Value__c = 80;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




//Next metric section
metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Financial Services Usage';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Financial Services Usage';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Allow_Update__c = true;
metricsection.View_Mode__c='Disaggregated';

saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics

metric = new M_E_Metric__c();
metric.Label__c='% of the target farmers access agro- input loans through their PS as an investment in agriculture.';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_access_agro_input_loans_through_ps';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of the target farmers access agro- input loans through their PS as an investment in agriculture.';
//metricdata.Numerator__c=20;
//metricdata.Denumerator__c=100;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);



metric = new M_E_Metric__c();
metric.Label__c='% of the target farmers use at least 1 kind of financial services through ICT.';
metric.Is_On_Fly__c=false;
metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_use_atleast_one_kind_of_financial_services';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of the target farmers use at least 1 kind of financial services through ICT.';
metricdata.Date__c = Date.today();
//metricdata.Numerator__c=17;
//metricdata.Denumerator__c=100;
metricdata.Manual_Value__c = 0;
// database.insert(metricdata);




metric = new M_E_Metric__c();
metric.Label__c='% of farmers access available financial services through VSLAs';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=2;
//metric.Projected_Value__c = 75;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_access_financial_services_through_vslas';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of farmers access available financial services through VSLAs';
//metricdata.Numerator__c=47;
//metricdata.Denumerator__c=100;
metricdata.Projected_Value__c = 75;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




//Next metric section
metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Sustainable and Equity services';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Sustainable and Equity services';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Allow_Update__c = true;
metricsection.View_Mode__c='Disaggregated';
saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics


metric = new M_E_Metric__c();
metric.Label__c='% increase in number of farmers that report satisfaction with GCCE services, through their PS from 71% at baseline to 95%';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_report_satisfaction_with_gcce_services';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% increase in number of farmers that report satisfaction with GCCE services, through their PS from 71% at baseline to 95%';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Manual_Value__c = 0;
metricdata.Projected_Value__c = 71;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




metric = new M_E_Metric__c();
metric.Label__c='% increase in number of farmers that report satisfaction with PS services ( 45% baseline to 70%)';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_farmers_who_report_satisfaction_with_ps_services';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% increase in number of farmers that report satisfaction with PS services ( 45% baseline to 70%)';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Manual_Value__c = 0;
metricdata.Projected_Value__c = 45;
metricdata.Date__c = Date.today();
// database.insert(metricdata);



//Next metric section
metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Adherence to policies and procedures';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Adherence to policies and procedures';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Allow_Update__c = true;
metricsection.Show_Targets__c = true;
metricsection.View_Mode__c='Disaggregated';
saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics


metric = new M_E_Metric__c();
metric.Label__c='% adherence to GCCE  established organizational policies and procedures.';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
//metric.Projected_Value__c = 100;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_adherence_to_gcce_policies';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% adherence to GCCE  established organizational policies and procedures.';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Manual_Value__c = 0;
metricdata.Projected_Value__c = 100;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




metric = new M_E_Metric__c();
metric.Label__c='% of PS have established organizational policies and procedures';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
//metric.Projected_Value__c = 100;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_percentage_of_ps_with_established_policied_and_procedures';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of PS have established organizational policies and procedures';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Manual_Value__c = 0;
metricdata.Projected_Value__c = 100;
metricdata.Date__c = Date.today();
// database.insert(metricdata);



metric = new M_E_Metric__c();
metric.Label__c='% of PS compliance to established organisational policies and procedures';
//metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
//metric.Projected_Value__c = 100;
metric.Order__c=2;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_percentage_of_ps_compliant_to_established_policied_and_procedures';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of PS compliance to established organisational policies and procedures';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Projected_Value__c = 100;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




//Next metric section
metricsection = new Metric_Section__c();
metricsection.Dashboard_Section__c = dashboardsectionId;
metricsection.Description__c='Collective procurement of inputs';
metricsection.Is_Active__c=true;
metricsection.RollOver_Time__c='Quarterly';
metricsection.Title__c='Collective procurement of inputs';
metricsection.Start_Date__c=Date.today();
metricsection.Default_Show__c=1;
metricsection.Allow_Update__c = true;
metricsection.View_Mode__c='Disaggregated';
metricsection.Show_Targets__c=true;
saveResult = database.insert(metricsection);

metricSectionId = saveResult.getId(); //The metric section for all subsequent metrics

metric = new M_E_Metric__c();
metric.Label__c='% of Ps do collectively procurement of inputs.';
metric.Is_On_Fly__c=false;

//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=0;
metric.Metric_Section__c=metricSectionId;
metric.Name='Gumutindo_percentage_of_ps_who_collectively_procure_inputs';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Ps do collectively procurement of inputs.';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Projected_Value__c = 60;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);




metric = new M_E_Metric__c();
metric.Label__c='% of Ps do collective payment for inputs deliveries. ';
metric.Is_On_Fly__c=false;
//metric.On_The_Fly_Calculation_Type__c='Percentage';
metric.Order__c=1;
metric.Metric_Section__c=metricSectionId;
//metric.Projected_Value__c = 60;
metric.Name='Gumutindo_percentage_of_ps_who_collectively_pay_for_inputs';
saveResult = database.insert(metric);

metricdata = new M_E_Metric_Data__C();
metricdata.M_E_Metric__c=saveResult.getId();
metricdata.Comment__c = '% of Ps do collective payment for inputs deliveries.';
//metricdata.Numerator__c=0;
//metricdata.Denumerator__c=0;
metricdata.Projected_Value__c = 60;
metricdata.Manual_Value__c = 0;
metricdata.Date__c = Date.today();
// database.insert(metricdata);

    }

	static testMethod void testGumutindoFarmEntranceSurveySubmission()
	{
         
        
        createMetrics();

        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.saveResult saveResult = database.insert(ckw);
        String ckwId = saveResult.getId();
       


        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'gcce test suvey';
        survey.Post_Processing_Method__c = 'GUMUTINDO_GCCE_FARM_ENTRANCE';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        String surveyId = saveResult.getId();
        
        Survey__c survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        CKW__c ckw2 = [Select Id, Person__c, Person__r.Handset__c, Person__r.Handset__r.IMEI__c from CKW__c where Id = :ckw.Id LIMIT 1];


		ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'GM99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '1353423873334';
        surveySubmission.interviewGPSTimestamp = '1353423873334';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        surveySubmission.xml = '<?xml version=\'1.0\' ?><farm_entrance_form id="farm_entrance_form" name="Farm entrance form"><q1>1</q1><q2>Emmanuel Wandega Gilbert</q2><q3>MR/001</q3><q4>Industrial Area</q4><q5>Mbale</q5><q6>1</q6><q7><q8>A</q8><q9>3.0</q9><q10>Coffee</q10><q11>100</q11><q12>2010-09-26</q12><q13>600</q13><q14>Never</q14><q15>1</q15></q7><q16>1</q16><q17><q18>B</q18><q19>2.0</q19><q20>Beans</q20><q21>1</q21><q22>Yams</q22><q23>2</q23><q24>Beans</q24><q25>1</q25></q17><q17><q18>C</q18><q19>2.0</q19><q20>Maize</q20><q21>1</q21><q22>Beans</q22><q23>1</q23><q24>Yams</q24><q25>1</q25></q17><q27>1</q27><q28><q29>Donkey</q29><q30>3</q30><q31>2 3</q31><q32>The place is good</q32></q28><q33>I have inspected the fields and we can have it registered as organic.</q33><q34>1</q34><q35>1</q35><q36>0.33127721 32.57675719 1207.0 12.0</q36><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></farm_entrance_form>';
        surveySubmission.json = 'none';

        ProcessSurveySubmission.SurveySubmission resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);
	}




    static testMethod void testGumutindoGroupSurveySubmission()
    {
         
        
        createMetrics();

        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.saveResult saveResult = database.insert(ckw);
        String ckwId = saveResult.getId();
       


        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'gcce group survey';
        survey.Post_Processing_Method__c = 'GUMUTINDO_GROUP_SURVEY';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        String surveyId = saveResult.getId();
        
        Survey__c survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        CKW__c ckw2 = [Select Id, Person__c, Person__r.Handset__c, Person__r.Handset__r.IMEI__c from CKW__c where Id = :ckw.Id LIMIT 1];


        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'GM99998';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'dr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '1353423873334';
        surveySubmission.interviewGPSTimestamp = '1353423873334';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        //surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><q11>1 2</q11><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><answer><binding>q11</binding><answerText>1 2</answerText><instance>0</instance></answer><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.json = 'none';

        ProcessSurveySubmission.SurveySubmission resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);


        //Check metric data value
        M_E_Metric_Data__c metricData = GumutindoHelpers.getMetricData('Gumutindo_farmer_groups_who_receive_support_from_ckw_network');
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);











        //Test farmer assessment survey
        survey = new Survey__c();
        survey.Survey_Name__c = 'gcce farmer assessment';
        survey.Post_Processing_Method__c = 'GCCE_FARMER_GROUP_ASSESSMENT';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        surveyId = saveResult.getId();
        
        survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        

        surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.surveyId = survey2.Name;


        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        //surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><q11>1 2</q11><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.xml = '<?xml version=\'1.0\' ?><group_farmer_member_assessment id="group_farmer_member_assessment" name="group_farmer_member_assessment"><answer><binding>q13</binding><answerText>1 2 3</answerText><instance>0</instance></answer><answer><binding>q11</binding><answerText>1 2 3</answerText><instance>0</instance></answer><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_farmer_member_assessment>';
        surveySubmission.json = 'none';

        resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);


        //Check metric data value
        metricData = GumutindoHelpers.getMetricData('Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices');
        System.debug(metricData);
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);


        metricData = GumutindoHelpers.getMetricData('Gumutindo_farmers_who_receive_advisory_services_from_ckw_network');
        System.debug(metricData);
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);
    }
}