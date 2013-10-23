/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This is class provides assistance to the EADD Dashboard controller
 *  Its test methods are in the EADDDashboardTests class 
 **/
 public with sharing class EADDHelpers {
 	 	
 	/*
 	 * Metrics related to EADD Hub survey.
 	 *
 	 * business-performance section metrics */
 	public static final String NUMBER_OF_FARMERS_SUPPLYING_MILK = 'EADD_farmers_supplying_milk';
 	public static final String MILK_VOLUME_BULKED = 'EADD_milk_volume_bulked';
 	public static final String REVENUE_RAISED_FROM_MILK_SALES = 'EADD_revenue_from_milk_sales';
 	public static final String PROFIT_RAISED_FROM_MILK_SALES = 'EADD_profit_from_milk_sales';
 	
 	/*
 	 * Metrics related to EADD Farmer reg extra info survey
 	 *
 	 * famers-reached section metrics */
 	public static final String AVERAGE_NUMBER_OF_FARMERS_REACHED = 'EADD_average_farmers_reached';
 	public static final String FEMALE_NUMBER_OF_FARMERS_REACHED = 'EADD_female_farmers_reached';
 	public static final String MALE_NUMBER_OF_FARMERS_REACHED = 'EADD_male_farmers_reached';
 	public static final String YOUTH_NUMBER_OF_FARMERS_REACHED = 'EADD_youth_farmers_reached';
 	
 	/* metrics for 	access-to-business-dev't-services section */
 	public static final String FARMERS_ACCESSING_INPUTS = 'EADD_farmers_accessing_inputs';
 	public static final String FEMALE_FARMERS_ACCESSING_INPUTS = 'EADD_female_farmers_accessing_inputs';
 	public static final String MALE_FARMERS_ACCESSING_INPUTS = 'EADD_male_farmers_accessing_inputs';
 	public static final String YOUTH_FARMERS_ACCESSING_INPUTS = 'EADD_youth_farmers_accessing_inputs';
 	
 	public static final String FARMERS_ACCESSING_AI = 'EADD_farmers_accessing_ai';
 	public static final String FEMALE_FARMERS_ACCESSING_AI = 'EADD_female_farmers_accessing_ai';
 	public static final String MALE_FARMERS_ACCESSING_AI = 'EADD_male_farmers_accessing_ai';
 	public static final String YOUTH_FARMERS_ACCESSING_AI = 'EADD_youth_farmers_accessing_ai';
	
 	public static final String FARMERS_ACCESSING_HEALTH = 'EADD_farmers_accessing_health';
 	public static final String FEMALE_FARMERS_ACCESSING_HEALTH = 'EADD_female_farmers_accessing_health';
 	public static final String MALE_FARMERS_ACCESSING_HEALTH = 'EADD_male_farmers_accessing_health';
 	public static final String YOUTH_FARMERS_ACCESSING_HEALTH = 'EADD_youth_farmers_accessing_health';

 	public static final String FARMERS_ACCESSING_TRAINING = 'EADD_farmers_accessing_training';
 	public static final String FEMALE_FARMERS_ACCESSING_TRAINING = 'EADD_female_farmers_accessing_training';
 	public static final String MALE_FARMERS_ACCESSING_TRAINING = 'EADD_male_farmers_accessing_training';
 	public static final String YOUTH_FARMERS_ACCESSING_TRAINING = 'EADD_youth_farmers_accessing_training';
 	
 	public static final String FARMERS_ACCESSING_SUPPLIES = 'EADD_farmers_accessing_supplies';
 	public static final String FEMALE_FARMERS_ACCESSING_SUPPLIES = 'EADD_female_farmers_accessing_supplies';
 	public static final String MALE_FARMERS_ACCESSING_SUPPLIES = 'EADD_male_farmers_accessing_supplies';
 	public static final String YOUTH_FARMERS_ACCESSING_SUPPLIES = 'EADD_youth_farmers_accessing_supplies';
 	
 	public static final String FARMERS_ACCESSING_FINANCIAL_SERVICES = 'EADD_farmers_accessing_financial_services';
 	public static final String FEMALE_FARMERS_ACCESSING_FINANCIAL_SERVICES = 'EADD_female_farmers_accessing_financial_services';
 	public static final String MALE_FARMERS_ACCESSING_FINANCIAL_SERVICES = 'EADD_male_farmers_accessing_financial_services';
 	public static final String YOUTH_FARMERS_ACCESSING_FINANCIAL_SERVICES = 'EADD_youth_farmers_accessing_financial_services';
 	
 	public static final String FARMERS_ACCESSING_TRANSPORT = 'EADD_farmers_accessing_transport';
 	public static final String FEMALE_FARMERS_ACCESSING_TRANSPORT = 'EADD_female_farmers_accessing_transport';
 	public static final String MALE_FARMERS_ACCESSING_TRANSPORT = 'EADD_male_farmers_accessing_transport';
 	public static final String YOUTH_FARMERS_ACCESSING_TRANSPORT = 'EADD_youth_farmers_accessing_transport';
 	
 	public static final String FARMERS_ACCESSING_CHECKOFF_SERVICES = 'EADD_farmers_accessing_checkoff_services';
 	public static final String FEMALE_FARMERS_ACCESSING_CHECKOFF_SERVICES = 'EADD_female_farmers_accessing_checkoff_services';
 	public static final String MALE_FARMERS_ACCESSING_CHECKOFF_SERVICES = 'EADD_male_farmers_accessing_checkoff_services';
 	public static final String YOUTH_FARMERS_ACCESSING_CHECKOFF_SERVICES = 'EADD_youth_farmers_accessing_checkoff_services';
 	
 	/* metrics for technology adoption */
 	public static final String FARMERS_USING_AI = 'EADD_farmers_using_ai';
 	public static final String FEMALE_FARMERS_USING_AI = 'EADD_female_farmers_using_ai';
 	public static final String MALE_FARMERS_USING_AI = 'EADD_male_farmers_using_ai';
 	public static final String YOUTH_FARMERS_USING_AI = 'EADD_youth_farmers_using_ai';
 	
 	public static final String FARMERS_USING_DRY_SEASON_FEEDING = 'EADD_farmers_using_dry_season_feeding';
 	public static final String FEMALE_FARMERS_USING_DRY_SEASON_FEEDING = 'EADD_female_farmers_using_dry_season_feeding';
 	public static final String MALE_FARMERS_USING_DRY_SEASON_FEEDING = 'EADD_male_farmers_using_dry_season_feeding';
 	public static final String YOUTH_FARMERS_USING_DRY_SEASON_FEEDING = 'EADD_youth_farmers_using_dry_season_feeding';
 	
 	public static final String FARMERS_USING_SUPPLEMENTARY = 'EADD_farmers_using_supplementary';
 	public static final String FEMALE_FARMERS_USING_SUPPLEMENTARY = 'EADD_female_farmers_using_supplementary';
 	public static final String MALE_FARMERS_USING_SUPPLEMENTARY = 'EADD_male_farmers_using_supplementary';
 	public static final String YOUTH_FARMERS_USING_SUPPLEMENTARY = 'EADD_youth_farmers_using_supplementary';
 	
 	public static final String FARMERS_USING_HIGH_QUALITY = 'EADD_farmers_using_high_quality';
 	public static final String FEMALE_FARMERS_USING_HIGH_QUALITY = 'EADD_female_farmers_using_high_quality';
 	public static final String MALE_FARMERS_USING_HIGH_QUALITY = 'EADD_male_farmers_using_high_quality';
 	public static final String YOUTH_FARMERS_USING_HIGH_QUALITY = 'EADD_youth_farmers_using_high_quality';
 	
	public static String getSubcounties(){
		String inclause =
                ' AND '                                           	+
                    'District__c IN ('                             	+
                        'SELECT '                                   +
                            'District__c '                          +
                        'FROM '                                     +
                            'Organisation_District_Association__c ' +
                        'WHERE '                                    +
                            'Organisation__r.Name = \'EADD\''		+
                    ') ';
		return 'SELECT Id, '					+
					'Display_Name__c, '			+
					'District__c '				+
				'FROM Subcounty__c '			+
				'WHERE District__c != NULL '	+
				'	AND  District__c != \'\' '	+
					inclause					+
				'ORDER BY Display_Name__c ';
	}
    
    public static Map<String, M_E_Metric__c> getAllMetrics(){
		String query = 'SELECT '										+
							'Id, '										+
							'Name, '									+
							'Label__c, '								+
							'Projected_Value__c, '						+
							'Further_Link_Text__c, '					+
							'Further_Link_Url__c '						+
						'FROM '											+
							'M_E_Metric__c ' 							+
						'WHERE '										+
							'Name LIKE \'EADD_%\' ';
		Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();
		for(M_E_Metric__c metric : database.query(query)){
			metricMap.put(metric.Name, metric);
		}
		return metricMap;
    }
    
    public static String getFarmersActualValueQuery(String district, String subcounty, String dateFrom, String dateTo){
    	String query =	getCountAllQuery(district, subcounty, dateFrom, dateTo);
    	System.debug(query);
    	return query;
    }
    
    public static String getGenderFarmersQuery(String district, String subcounty, String dateFrom, String dateTo){
    	return getCountAllByGenderQuery(district, subcounty, dateFrom, dateTo) + 'GROUP BY Gender__c  ORDER BY Gender__c ';
    }    
    
    public static String getYouthFarmersQuery(String district, String subcounty, String dateFrom, String dateTo){
    	return getCountAllQuery(district, subcounty, dateFrom, dateTo) + 'AND Age__c < 45';
    }	
    
    public static String getSuppliersActualValueQuery(String district, String subcounty, String dateFrom, String dateTo){    	
		return getActualValueQuery(district, subcounty, dateFrom, dateTo, 'Farmers_served_by_hub__c');
    }
    
    public static String getVolumesBulkedActualValueQuery(String district, String subcounty, String dateFrom, String dateTo){    	
		return getActualValueQuery(district, subcounty, dateFrom, dateTo, 'Milk_volumes_bulked__c');
    }
    
    public static String getRevenueActualValueQuery(String district, String subcounty, String dateFrom, String dateTo){    	
		return getActualValueQuery(district, subcounty, dateFrom, dateTo, 'Milk_sale_revenue__c');
    }
    
    public static String getProfitActualValueQuery(String district, String subcounty, String dateFrom, String dateTo){    	
		return getActualValueQuery(district, subcounty, dateFrom, dateTo, 'Milk_sale_profits__c');
    }
    
    public static String getGenderActualValueQuery(String district, String subcounty, String dateFrom, String dateTo, String column){
    	return	getCountAllByGenderQuery(district, subcounty, dateFrom, dateTo) +
    			'AND ' + column + ' = TRUE ' +
    			'GROUP BY Gender__c  ORDER BY Gender__c ';
    }
    
    public static String getYouthActualValueQuery(String district, String subcounty, String dateFrom, String dateTo, String column){
    	return	getCountAllQuery(district, subcounty, dateFrom, dateTo) + 
    			'AND ' + column + ' = TRUE ' +
    			'AND Age__c < 45';
    }
    
    /*
     * There are many normal queries you cant run in SOQL
     * That being said, we have to get the Ids of the most
     * recent metric since a new metric is created monthly.
     * Then we return a query sum suppliers
     *
     * @param district	- district if not null then filter by
     * @param subcounty	- subcounty if not null then filter by
     * @param dateFrom	- filter start date
     * @param dateTo	- filter end date
     * @param column	- the column whose aggregate to return
     * @return querry 	- string querry
     */
    public static String getActualValueQuery(String district, String subcounty, String dateFrom, String dateTo, String column){
    	
		String ids = getIdsOfLatestHubInformation();
		String inClause = '';
		if(ids != ''){
			inClause = 	'Id IN ('		+
								ids		+
							') '		+
						'AND ';
		}
							
		String query = 	'SELECT '								+
							'SUM(' + column + ') '				+
						'FROM '									+
						'EADD_Hub__c '							+
						'WHERE '								+
								inClause						+ 
							'District__c != NULL '				+ 
							'AND Subcounty__c != NULL '			+
							getDistrictAndSubcountyClause(district, subcounty, dateFrom, dateTo);
    	
    	return query;
    }
    
    /*
    * a hub can have multiple details, we always want the latest information
    */
    public static String getIdsOfLatestHubInformation(){
		String ids = '';
		String recordIds = 	'SELECT Id, MAX(Date__c) ' 	+
		    				'FROM EADD_Hub__c '			+
		    				'GROUP BY Id ';
		for(AggregateResult[] results : database.query(recordIds)){
		    for(AggregateResult result : results){
		        if(ids == ''){
		            ids = '\'' + (String)result.get('Id') + '\'';
		        }else{
		            ids += ',\'' + (String)result.get('Id') + '\'';
		        }
		    }
		}
		return ids;
    }
    
    public static String getCountAllQuery(String district, String subcounty, String dateFrom, String dateTo){
    	return	'SELECT '						+
					'COUNT(Id) '				+
				'FROM '							+
					'EADD_Farmer_extra_info__c '+ 
				'WHERE '						+
					'District__c != NULL '		+ 
					'AND Subcounty__c != NULL '	+
					getDistrictAndSubcountyClause(district, subcounty, dateFrom, dateTo) + ' ';
    }
       
    public static String getCountAllByGenderQuery(String district, String subcounty, String dateFrom, String dateTo){
    	return	'SELECT '						+
					'COUNT(Id), Gender__c '		+
				'FROM '							+
					'EADD_Farmer_extra_info__c '+ 
				'WHERE '						+
					'District__c != NULL '		+ 
					'AND Subcounty__c != NULL '	+
					getDistrictAndSubcountyClause(district, subcounty, dateFrom, dateTo) + ' ';
    }
    
    public static String getDistrictAndSubcountyClause(String district, String subcounty, String dateFrom, String dateTo){
        // Check to see if we have a district and subcounty to check.
        String districtNameClause = 'null';
        String subcountyNameClause = 'null';
        String query = '';
        if (district != null && !district.equals('')) {
            query += ' AND District__r.Name = \'' + district + '\' ';
        }
        if (subcounty != null && !subcounty.equals('')) {
            query += 'AND Subcounty__r.Display_Name__c = \'' + subcounty + '\' ';
        }
		
		if(dateFrom != null && !dateFrom.equals('')){
			query += ' AND Date__c >= ' + dateFrom + ' ';
		}
		if(dateTo != null && !dateTo.equals('')){
			query += ' AND Date__c <= ' + dateTo + ' ';
		}
		return query;
    }
}