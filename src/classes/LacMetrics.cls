// Luke: creating nested classes allows us to have pseudo namespaces. So, the same metric can exist for CKW and CKW can use this same Metric storage/caching framework if it wants
// It is also better than prefixing because it allows us to have longer metric names
// The downside is that this file can potentially grow pretty big

public with sharing class LacMetrics {
	
	public with sharing class TotalFarmers implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.TotalFarmers', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from LAC_Farmer_Details__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
	    }
	}

	public with sharing class TotalOrganizations implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.TotalOrganizations', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from Account where createdDate <=: quarterEndDate and Country__r.Name = 'Colombia']);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from Account where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and Country__r.Name = 'Colombia'];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
	    }
	}
	
	public with sharing class TotalCkws  implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterCkws = LacMetricManager.getSavedValue('LacMetrics.TotalCkws', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterCkws == null) {
	        	return String.valueOf([SELECT count() from CKW__c where createdDate <=: quarterEndDate and Person__r.Country__r.Name = 'Colombia']);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterCkws = [SELECT count() from CKW__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and Person__r.Country__r.Name = 'Colombia'];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterCkws) + thisQuarterCkws);
	        }
		 }
	}
	
	public with sharing class FemaleCkws  implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.FemaleCkws', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from CKW__c where Person__r.Gender__c = 'Female' and createdDate <=: quarterEndDate and Person__r.Country__r.Name = 'Colombia']);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from CKW__c where Person__r.Gender__c = 'Female' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and Person__r.Country__r.Name = 'Colombia'];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
		 }
	}
	
	public with sharing class TotalHouseholds implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterHH = LacMetricManager.getSavedValue('LacMetrics.TotalHouseholds', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterHH == null) {
	        	return String.valueOf([SELECT count() from LAC_Household__c where createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterHH = [SELECT count() from LAC_Household__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterHH) + thisQuarterHH);
	        }
	    }
	}
	
	/**
	* Using the 1.25 line, if you have a score of under 5, then you're over 50% likely of being under this line
	**/
	public with sharing class PoorHouseholds implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterPoorHouseholds = LacMetricManager.getSavedValue('LacMetrics.PoorHouseholds', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterPoorHouseholds == null) {
	        	return String.valueOf([SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 5 and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterPoorHouseholds = [SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 5 and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterPoorHouseholds) + thisQuarterPoorHouseholds);
	        }
	    }
	}
	
	public with sharing class PoorHouseholdsPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        // Get total households
	        String totalHouseholds = LacMetricManager.getValue('LacMetrics.TotalHouseholds', dateInQuarter, '0');
	        
	        // Get poor households
	        String poorHouseholds = LacMetricManager.getValue('LacMetrics.PoorHouseholds', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalHouseholds != '0') {
	        	return String.valueOf((Decimal.valueOf(poorHouseholds) * 100 / Decimal.valueOf(totalHouseholds)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	/**
	* If PPI score is under 25, then you're over 50% likely of being under the USAID line
	* Note, this is also true for the 2.50 line, so we'll use this metric for the $2.50 line as well
	**/
	public with sharing class PovertyLineUsaid implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.PovertyLineUsaid', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 25 and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 25 and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
	    }
	}
	
	public with sharing class PovertyLineUsaidPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        // Get total households
	        String totalHouseholds = LacMetricManager.getValue('LacMetrics.TotalHouseholds', dateInQuarter, '0');
	        
	        // Get poor households
	        String poorHouseholds = LacMetricManager.getValue('LacMetrics.PovertyLineUsaid', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalHouseholds != '0') {
	        	return String.valueOf((Decimal.valueOf(poorHouseholds) * 100 / Decimal.valueOf(totalHouseholds)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	/**
	* If PPI score is under 35, then you're over 50% likely of being under the $3.75 line
	**/
	public with sharing class PovertyLine375 implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.PovertyLine375', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 35 and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 35 and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
	    }
	}
	
	public with sharing class PovertyLine375Percent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        // Get total households
	        String totalHouseholds = LacMetricManager.getValue('LacMetrics.TotalHouseholds', dateInQuarter, '0');
	        
	        // Get poor households
	        String poorHouseholds = LacMetricManager.getValue('LacMetrics.PovertyLine375', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalHouseholds != '0') {
	        	return String.valueOf((Decimal.valueOf(poorHouseholds) *100 / Decimal.valueOf(totalHouseholds)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	/**
	* If PPI score is under 40, then you're over 50% likely of being under the $5 line
	**/
	public with sharing class PovertyLine5 implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarter = LacMetricManager.getSavedValue('LacMetrics.PovertyLine5', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarter == null) {
	        	return String.valueOf([SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 40 and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarter = [SELECT count() from LAC_Household__c where Registration_PPI_Score__c < 40 and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarter) + thisQuarter);
	        }
	    }
	}
	
	public with sharing class PovertyLine5Percent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        // Get total households
	        String totalHouseholds = LacMetricManager.getValue('LacMetrics.TotalHouseholds', dateInQuarter, '0');
	        
	        // Get poor households
	        String poorHouseholds = LacMetricManager.getValue('LacMetrics.PovertyLine5', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalHouseholds != '0') {
	        	return String.valueOf((Decimal.valueOf(poorHouseholds) * 100 / Decimal.valueOf(totalHouseholds)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	public with sharing class TotalInteractions implements LacMetricManager.ILacMetricCalculator {
	    public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // Searches + Surveys + Messages
	        Integer searches = Integer.valueOf(LacMetricManager.getValue('LacMetrics.TotalSearches', dateInQuarter, '0'));
	        Integer surveys = Integer.valueOf(LacMetricManager.getValue('LacMetrics.TotalSurveys', dateInQuarter, '0'));
	        Integer messages = Integer.valueOf(LacMetricManager.getValue('LacMetrics.TotalMessages', dateInQuarter, '0'));
	        
	        return String.valueOf(searches + surveys + messages);
	    }
	}
	
	public with sharing class TotalSearches implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // Get previous quarter value
	        String previousValue = LacMetricManager.getSavedValue('LacMetrics.TotalSearches', quarterStartDate.addDays(-7), null);
	        
	        if(previousValue == null) {
	        	// Get all the data
	        	return String.valueOf([SELECT count() from Search_Log__c where createdDate <=: quarterEndDate and Interviewer__r.Country__r.Name = 'Colombia']);
	        } else {
	        	Integer currentValue = [SELECT count() from Search_Log__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and Interviewer__r.Country__r.Name = 'Colombia'];
	        	return String.valueOf(Integer.valueOf(previousValue) + currentValue);
	        }
		}
	}
	
	public with sharing class TotalSearchesPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        String total = LacMetricManager.getValue('LacMetrics.TotalInteractions', dateInQuarter, '0');
	        String searches = LacMetricManager.getValue('LacMetrics.TotalSearches', dateInQuarter, '0');
	        
	        // Return percentage
	        if(total != '0') {
	        	return String.valueOf((Decimal.valueOf(searches) * 100 / Decimal.valueOf(total)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	public with sharing class TotalCkwSurveys implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // Get previous quarter value
	        String previousValue = LacMetricManager.getSavedValue('LacMetrics.TotalCkwSurveys', quarterStartDate.addDays(-7), null);
	        
	        if(previousValue == null) {
	        	AggregateResult ckwSurveysResult = [SELECT SUM(Total_Surveys__c) total from CKW_Performance_Review__c where createdDate <=: quarterEndDate and CKW_c__r.Person__r.Country__r.Name = 'Colombia'];
	        	return String.valueOf(ckwSurveysResult.get('total'));
	        } else {
	        	AggregateResult ckwSurveysResult = [SELECT SUM(Total_Surveys__c) total from CKW_Performance_Review__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and CKW_c__r.Person__r.Country__r.Name = 'Colombia'];
	        	Integer currentValue = Integer.valueOf(ckwSurveysResult.get('total'));
	        	
	        	return String.valueOf(Integer.valueOf(previousValue) + currentValue);
	        }
		}
	}
	
	public with sharing class TotalCkwSurveysPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        String total = LacMetricManager.getValue('LacMetrics.TotalInteractions', dateInQuarter, '0');
	        String surveys = LacMetricManager.getValue('LacMetrics.TotalCkwSurveys', dateInQuarter, '0');
	        
	        // Return percentage
	        if(total != '0') {
	        	return String.valueOf((Decimal.valueOf(surveys) * 100 / Decimal.valueOf(total)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	public with sharing class TotalSurveys implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
	        String totalIbtSurveys = LacMetricManager.getValue('LacMetrics.TotalIbtSurveys', dateInQuarter, '0');
	        String totalCkwSurveys = LacMetricManager.getValue('LacMetrics.TotalCkwSurveys', dateInQuarter, '0');
	        
	        // Return total
	        return String.valueOf(Integer.valueOf(totalIbtSurveys) + Integer.valueOf(totalCkwSurveys));
		 }
	}
	
	public with sharing class TotalIbtSurveys implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // Get previous quarter value
	        String previousValue = LacMetricManager.getSavedValue('LacMetrics.TotalIbtSurveys', quarterStartDate.addDays(-7), null);
	        
	        if(previousValue == null) {
	        	return String.valueOf([SELECT count() from gfsurveys__Submission__c where createdDate <=: quarterEndDate and gfsurveys__Submission__c.gfsurveys__Surveyor__r.Country__r.Name = 'Colombia']);
	        } else {
	        	Integer currentValue = [SELECT count() from gfsurveys__Submission__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and gfsurveys__Submission__c.gfsurveys__Surveyor__r.Country__r.Name = 'Colombia'];
	        	
	        	return String.valueOf(Integer.valueOf(previousValue) + currentValue);
	        }
		}
	}
	
	public with sharing class TotalIbtSurveysPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        String total = LacMetricManager.getValue('LacMetrics.TotalInteractions', dateInQuarter, '0');
	        String surveys = LacMetricManager.getValue('LacMetrics.TotalIbtSurveys', dateInQuarter, '0');
	        
	        // Return percentage
	        if(total != '0') {
	        	return String.valueOf((Decimal.valueOf(surveys) * 100 / Decimal.valueOf(total)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	public with sharing class TotalMessages implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
	        Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // Get previous quarter value
	        String previousValue = LacMetricManager.getSavedValue('LacMetrics.TotalMessages', quarterStartDate.addDays(-7), null);
	        
	        if(previousValue == null) {
	        	return String.valueOf([SELECT count() from Message__c where createdDate <=: quarterEndDate and Recipient__r.Country__r.Name = 'Colombia']);
	        } else {
	        	Integer currentValue = [SELECT count() from Message__c where createdDate >=: quarterStartDate and createdDate <=: quarterEndDate and Recipient__r.Country__r.Name = 'Colombia'];
	        	
	        	return String.valueOf(Integer.valueOf(previousValue) + currentValue);
	        }
		}
	}
	
	public with sharing class TotalMessagesPercent implements LacMetricManager.ILacMetricCalculator {
		 public string calculate(Date dateInQuarter) {
	        String total = LacMetricManager.getValue('LacMetrics.TotalInteractions', dateInQuarter, '0');
	        String messages = LacMetricManager.getValue('LacMetrics.TotalMessages', dateInQuarter, '0');
	        
	        // Return percentage
	        if(total != '0') {
	        	return String.valueOf((Decimal.valueOf(messages) * 100 / Decimal.valueOf(total)).setScale(1));
	        }
	        
	        return '0';
		 }
	}
	
	public with sharing class IndigoPercent implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			// Get total farmers
	        String totalFarmers = LacMetricManager.getValue('LacMetrics.TotalFarmers', dateInQuarter, '0');
	        
	        // Get indigo farmers
	        String indigoFarmers = LacMetricManager.getValue('LacMetrics.IndigoFarmers', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalFarmers != '0') {
	        	return String.valueOf((Decimal.valueOf(indigoFarmers) * 100 / Decimal.valueOf(totalFarmers)).setScale(1));
	        }
	        
	        return '0';
		}	
	}
	
	public with sharing class IndigoFarmers implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterFarmers = LacMetricManager.getSavedValue('LacMetrics.IndigoFarmers', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterFarmers == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Indigena' and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterFarmers = [SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Indigena' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterFarmers) + thisQuarterFarmers);
	        }
		}	
	}
	
	public with sharing class AfroColombianoPercent implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			// Get total farmers
	        String totalFarmers = LacMetricManager.getValue('LacMetrics.TotalFarmers', dateInQuarter, '0');
	        
	        // Get afro farmers
	        String afroFarmers = LacMetricManager.getValue('LacMetrics.AfroColombianoFarmers', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalFarmers != '0') {
	        	return String.valueOf(( Decimal.valueOf(afroFarmers) * 100 / Decimal.valueOf(totalFarmers)).setScale(1));
	        }
	        
	        return '0';
		}	
	}
	
	public with sharing class AfroColombianoFarmers implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterFarmers = LacMetricManager.getSavedValue('LacMetrics.AfroColombianoFarmers', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterFarmers == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where Ethnicity__c = 'AfroColombiano' and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterFarmers = [SELECT count() from LAC_Farmer_Details__c where Ethnicity__c = 'AfroColombiano' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterFarmers) + thisQuarterFarmers);
	        }
		}	
	}
	
	public with sharing class FemaleHeadedPercent implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			// Get total households
	        String totalHouseholds = LacMetricManager.getValue('LacMetrics.TotalHouseholds', dateInQuarter, '0');
	        
	        // Get female headed households
	        String femaleHeaded = LacMetricManager.getValue('LacMetrics.FemaleHeadedHouseholds', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalHouseholds != '0') {
	        	return String.valueOf(( Decimal.valueOf(femaleHeaded) * 100 / Decimal.valueOf(totalHouseholds)).setScale(1));
	        }
	        
	        return '0';
		}	
	}
	
	public with sharing class FemaleHeadedHouseholds implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterFarmers = LacMetricManager.getSavedValue('LacMetrics.FemaleHeadedHouseholds', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterFarmers == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where Gender__c = 'Mujer' and Household_Head__c = 'Si' and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterFarmers = [SELECT count() from LAC_Farmer_Details__c where Gender__c = 'Mujer' and Household_Head__c = 'Si' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterFarmers) + thisQuarterFarmers);
	        }
		}	
	}
	
	public with sharing class DisplacedPercent implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			// Get total households
	        String totalFarmers = LacMetricManager.getValue('LacMetrics.TotalFarmers', dateInQuarter, '0');
	        
	        // Get required
	        String displaced = LacMetricManager.getValue('LacMetrics.DisplacedFarmers', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalFarmers != '0') {
	        	return String.valueOf((Decimal.valueOf(displaced) * 100 / Decimal.valueOf(totalFarmers)).setScale(1));
	        }
	        
	        return '0';
		}	
	}
	
	public with sharing class DisplacedFarmers implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterFarmers = LacMetricManager.getSavedValue('LacMetrics.DisplacedFarmers', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterFarmers == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Desplazado' and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterFarmers = [SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Desplazado' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterFarmers) + thisQuarterFarmers);
	        }
		}	
	}
	
	public with sharing class ElderlyPercent implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			// Get total households
	        String totalFarmers = LacMetricManager.getValue('LacMetrics.TotalFarmers', dateInQuarter, '0');
	        
	        // Get required
	        String elderly = LacMetricManager.getValue('LacMetrics.ElderlyFarmers', dateInQuarter, '0');
	        
	        // Return percentage
	        if(totalFarmers != '0') {
	        	return String.valueOf((Decimal.valueOf(elderly) * 100 / Decimal.valueOf(totalFarmers)).setScale(1));
	        }
	        
	        return '0';
		}	
	}
	
	public with sharing class ElderlyFarmers implements LacMetricManager.ILacMetricCalculator {
		public string calculate(Date dateInQuarter) {
			Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	        Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
	        
	        // To prevent hitting a governor limit, first check if we have cached data for last quarter
	        String lastQuarterFarmers = LacMetricManager.getSavedValue('LacMetrics.ElderlyFarmers', quarterStartDate.addDays(-7), null);
	        
	        // There is no saved data from the last quarter, so we have to get all the data
	        if(lastQuarterFarmers == null) {
	        	return String.valueOf([SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Adulto mayor' and createdDate <=: quarterEndDate]);
	        } else {
	        	// Only get this quarter's data and add it to last quarters data
		        Integer thisQuarterFarmers = [SELECT count() from LAC_Farmer_Details__c where Marginalized_Type__c = 'Adulto mayor' and createdDate >=: quarterStartDate and createdDate <=: quarterEndDate];
		        
		        return String.valueOf(Integer.valueOf(lastQuarterFarmers) + thisQuarterFarmers);
	        }
		}	
	}
	
	static testMethod void testAll() {
		Date current = Date.today();
		
		Set<String> metrics = LacMetricManager.metrics.keySet();
		for(String metric : metrics) {
			LacMetricManager.ILacMetricCalculator calculator = LacMetricManager.getCalculatorClass(metric);
			calculator.calculate(current);
		}
	}
}