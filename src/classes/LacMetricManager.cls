/**
* This class provides interfaces and base methods for calculating LAC metrics.
* 
* Metrics are calculated on demand
* Metric values are ownes by "Users" and the same metric can have different values for the different users based on the heirarchy and sharing of the related data objects used to calculate the metric
* However, once the quarter ends (plus overlap period for "late" data), then the value will be saved to the Metric Value table
* If a metric value doesn't exist, then it'll be calculated on demand, otherwise, the existing value will be used
**/
public with sharing class LacMetricManager {
	// The LAC User Admin Id. Used for metric value and target querying if a Guest User is logged in. Otherwise, we use UserInfo.getUserId();
	public static final Id LacUserId = '00570000001fHbB';
	
	// LAC Metric names
	// Format (name=>description)
	// Keys and descriptions should be as descriptive as possible
	// Note: Keys must be unique, non-unique keys will overwrite previous keys, which can be hard to debug
	// Note: Keys must correspond to the name of the ILacMetricCalculator class used to calculate the metric
	//       The ILacMetricCalcultor class is in the format LacMetricCalculator_<Metric name>
	// Note: Be careful when changing the name of the metric because it is stored in the metric_name column of the objects that store the values and targets for the metric
	public static Map<String, String> metrics = new Map<String, String>{
		'LacMetrics.TotalFarmers'=>'Total Farmers Registered (Cumulative)',
		'LacMetrics.TotalHouseholds'=>'Total Households Registered (Cumulative)', //
		'LacMetrics.PoorHouseholds'=>'Households with 50% likelihood of being under the $1.25 line',
		'LacMetrics.PoorHouseholdsPercent'=>'PoorHouseholds %',
		'LacMetrics.PovertyLineUsaid'=>'Households with 50% likelihood of being under the USAID and $2.5 line',
		'LacMetrics.PovertyLineUsaidPercent'=>'PovertyLineUsaid %',
		'LacMetrics.PovertyLine375'=>'Households with 50% likelihood of being under the $3.75 line',
		'LacMetrics.PovertyLine375Percent'=>'PovertyLine375 %',
		'LacMetrics.PovertyLine5'=>'Households with 50% likelihood of being under the $5 line',
		'LacMetrics.PovertyLine5Percent'=>'PovertyLine5 %',
		'LacMetrics.TotalInteractions' => 'Total Interactions (Cumulative)',
		'LacMetrics.TotalSearches' => 'Total Searches (Cumulative)',
		'LacMetrics.TotalSearchesPercent' => 'Total Searches %',
		'LacMetrics.TotalCkwSurveys' => 'Total Ckw Surveys (Cumulative)',
		'LacMetrics.TotalCkwSurveysPercent' => 'Total Ckw Surveys %',
		'LacMetrics.TotalIbtSurveys' => 'Total IBT Surveys (Cumulative)',
		'LacMetrics.TotalIbtSurveysPercent' => 'Total IBT Surveys %',
		'LacMetrics.TotalMessages' => 'Total Messages (Cumulative)',
		'LacMetrics.TotalMessagesPercent' => 'Total Messages %',
		'LacMetrics.TotalCkws' => 'Total CKWs (Cumulative)',
		'LacMetrics.FemaleCkws' => 'Female CKWs (Cumulative)',
		'LacMetrics.TotalOrganizations' => 'Total Organizations (Cooperatives)',
		'LacMetrics.IndigoFarmers' => 'Total Indigo Farmers',
		'LacMetrics.IndigoPercent' => 'Percentage of Indigo Farmers',
		'LacMetrics.AfroColombianoFarmers' => 'Total Afro Farmers',
		'LacMetrics.AfroColombianoPercent' => 'Percentage of Afro Farmers',
		'LacMetrics.FemaleHeadedHouseholds' => 'Total Female Headed Households',
		'LacMetrics.FemaleHeadedPercent' => 'Percentage of Female Headed Households',
		'LacMetrics.DisplacedFarmers' => 'Total Displaced Farmers',
		'LacMetrics.DisplacedPercent' => 'Percentage of Displaced Farmers',
		'LacMetrics.ElderlyFarmers' => 'Total Elderly Farmers',
		'LacMetrics.ElderlyPercent' => 'Percentage of Elderly Farmers'
	};
	
	// Cache Objects.
	// Metrics may use other metrics, so
	// getValue, getSavedValue, getLatestTarget and getTarget cache data during each session and always first check the cashe
	private static Map<String, String> valueCache = new Map<String, String>();
	private static Map<String, String> savedValueCache = new Map<String, String>();
	private static Map<String, String> targetCache = new Map<String, String>();
	private static Map<String, String> latestTargetCache = new Map<String, String>();
	
	// LAC Metric Calculator Interface
    public interface ILacMetricCalculator { 
    	String calculate(Date dateInQuarter);
    }

    // Base class for common calculator methods
    public virtual class LacMetricCalculatorBase {
    	
    }
    
    // LacMetricManagerException
    public class LacMetricManagerException extends Exception {}
    
    public LacMetricManager(){}

    // Return a calculator class from the classname
    public static ILacMetricCalculator getCalculatorClass(String metric) {
        Type t = Type.forName(metric);
        if(t != null) {
        	return (ILacMetricCalculator) t.newInstance();
        }
        
        throw new LacMetricManagerException('Metric calculator class for ' + metric + ' does not exist!');
    }
    
    public static boolean checkMetric(String metric) {
    	if(!metrics.containsKey(metric)) {
    		throw new LacMetricManagerException('Metric ' + metric + ' does not exist!');
    	}
    	return true;
    }
    
    public static String getValue(String metric, Date dateInQuarter) {
    	Map<String, String> values = getValues(new List<String>{metric}, dateInQuarter);
    	return values.get(metric);
    }
    
    public static Map<String, String> getValues(List<String> metricList, Date dateInQuarter) {
    	Map<String, String> results = new Map<String, String>();
    	List<String> noCachedValues = new List<String>();
    	
    	// Check for metric validity, and get cached results if available
    	for(String metric: metricList) {
    		checkMetric(metric);
    		
    		String cachedValue = getCachedValue(valueCache, metric, dateInQuarter);
    		if(cachedValue != null) {
    			results.put(metric, cachedValue);
    		} else {
    			noCachedValues.add(metric);
    		}
    	}	
    	
    	// Get saved results for the metrics that do not have cached results
    	if(noCachedValues.size() > 0) {
	    	Map<String, String> savedValues = getSavedValues(noCachedValues, dateInQuarter);
	    	Map<String, String> calculatedValues = new Map<String, String>();
	    	
	    	for(String metric: noCachedValues) {
	    		if(savedValues.containsKey(metric) && savedValues.get(metric) != null) {
	    			results.put(metric, savedValues.get(metric));
	    		} else {
	    			ILacMetricCalculator calculator = getCalculatorClass(metric);
	    			String calculatedValue = calculator.calculate(dateInQuarter);
	    			results.put(metric, calculatedValue);
	    			calculatedValues.put(metric, calculatedValue);
	    		}
	    		
	    		setCachedValue(valueCache, metric, dateInQuarter, results.get(metric));
	    	}
	    	
	    	// If the quarter is passed, then we persist the values
	    	Date currentQuarterStartDate = MetricHelpers.getQuarterFirstDay(Date.today());
	    	Date requestedQuarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
	    	if (currentQuarterStartDate > requestedQuarterStartDate) {
	    		//setCalculatedValues(calculatedValues, dateInQuarter);
	    	}
    	}
    	
    	return results;
    }
    
    public static String getCachedValue(Map<String, String> cacheObject, String metric, Date dateInQuarter) {
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	if(cacheObject.containsKey(metric + quarterStartDate.format())) {
    		return cacheObject.get(metric + quarterStartDate.format());
    	}
    	return null;
    }
    
    public static void setCachedValue(Map<String, String> cacheObject, String metric, Date dateInQuarter, String value) {
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	cacheObject.put(metric + quarterStartDate.format(), value);
    }
    
    public static Map<String, String> getSavedValues(List<String> metricList, Date dateInQuarter) {
    	return getSavedValues(metricList, dateInQuarter, null);
    }
    
    public static Map<String, String> getSavedValues(List<String> metricList, Date dateInQuarter, String defaultValue) {
    	Map<String, String> results = new Map<String, String>();
    	List<String> noCachedValues = new List<String>();
    	
    	// Check for metric validity, and get cached results if available
    	for(String metric: metricList) {
    		checkMetric(metric);
    		
    		String cachedValue = getCachedValue(savedValueCache, metric, dateInQuarter);
    		if(cachedValue != null) {
    			results.put(metric, cachedValue);
    		} else {
    			noCachedValues.add(metric);
    		}
    	}	
    	
    	if(noCachedValues.size() > 0) {
    		Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    		Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    		
    		for(LAC_Metric_Value__c[] savedValues : [SELECT Metric__c, Calculated_Value__c, Manual_Value__c from LAC_Metric_Value__c where Date__c >=: quarterStartDate and Date__c <=: quarterEndDate and OwnerId =: getUserId() and Metric__c IN :noCachedValues]) {
    			for (LAC_Metric_Value__c savedValue : savedValues) {
	    			String value = null;
	    			if(savedValue.Manual_Value__c != null && savedValue.Manual_Value__c != '') {
		    			value = savedValue.Manual_Value__c;
		    		} else if(savedValue.Calculated_Value__c != null && savedValue.Calculated_Value__c != '') {
		    			value = savedValue.Calculated_Value__c;
		    		}
		    		
		    		if(value != null) {
		    			setCachedValue(savedValueCache, savedValue.Metric__c, dateInQuarter, value);
		    			results.put(savedValue.Metric__c, value);
		    		}
    			}
    		}
    	}
    	
    	for(String metric: metricList) {
    		if(!results.containsKey(metric)) {
    			results.put(metric, defaultValue);
    		}
    	}
    	
    	return results;
    }
    
    public static String getValue(String metric, Date dateInQuarter, String defaultValue) {
    	Map<String, String> values = getValues(new List<String>{metric}, dateInQuarter);
    	
    	if(values.get(metric) == null) {
    		return defaultValue;
    	}
    	
    	return values.get(metric);
    }
    
    public static String getSavedValue(String metric, Date dateInQuarter, String defaultValue) {
    	Map<String, String> savedValues = getSavedValues(new List<String>{metric}, dateInQuarter);
    	
    	if(savedValues.get(metric) == null) {
    		return defaultValue;
    	}
    	
    	return savedValues.get(metric);
    }
    
    public static String getSavedValue(String metric, Date dateInQuarter) {
    	return getSavedValue(metric, dateInQuarter, null);
    }
    
    public static void setManualValue(String metric, String value, Date dateInQuarter) {
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    	LAC_Metric_Value__c[] oldValue = [SELECT Manual_Value__c from LAC_Metric_Value__c where Metric__c =: metric and Date__c >=: quarterStartDate and Date__c <=: quarterEndDate and OwnerId =: getUserId() limit 1];
    	if(oldValue.size() > 0) {
    		oldValue[0].Manual_Value__c = value;
    		update oldValue[0];
    	} else {
    		LAC_Metric_Value__c newValue = new LAC_Metric_Value__c();
    		newValue.Metric__c = metric;
    		newValue.Manual_Value__c = value;
    		newValue.Date__c = dateInQuarter;
    		insert newValue;
    	}
    }
    
    
    public static void setCalculatedValues(Map<String, String> calculatedValues, Date dateInQuarter) {
    	Map<String, LAC_Metric_Value__c> metricsToUpdate = new Map<String, LAC_Metric_Value__c>();
    	Map<String, LAC_Metric_Value__c> metricsToInsert = new Map<String, LAC_Metric_Value__c>();
    	
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    	for (LAC_Metric_Value__c[] oldValues : [SELECT Metric__c, Calculated_Value__c from LAC_Metric_Value__c where Metric__c IN : calculatedValues.keySet() and Date__c >=: quarterStartDate and Date__c <=: quarterEndDate and OwnerId =: getUserId()]) {
    		for(LAC_Metric_Value__c oldValue : oldValues) {
    			oldValue.Calculated_Value__c = calculatedValues.get(oldValue.Metric__c);
    			metricsToUpdate.put(oldValue.Metric__c, oldValue);
    		}
    	}
    	
    	for(String metric: calculatedValues.keySet()) {
    		if(!metricsToUpdate.containsKey(metric)) {
    			LAC_Metric_Value__c newValue = new LAC_Metric_Value__c();
	    		newValue.Metric__c = metric;
	    		newValue.Calculated_Value__c = calculatedValues.get(metric);
	    		newValue.Date__c = quarterStartDate;
	    		metricsToInsert.put(metric, newValue);
    		}
    	}
    	
    	/*if(metricsToUpdate.size() > 0) {
    		update metricsToUpdate.values();
    	}
    	
    	if(metricsToInsert.size() > 0) {
    		update metricsToInsert.values();
    	}*/
    }
    
    public static String getTarget(String metric, Date dateInQuarter, String defaultValue) {
    	// Check if the metric exists
    	checkMetric(metric);
    	String cachedValue = getCachedValue(targetCache, metric, dateInQuarter);
    	if(cachedValue != null) {
    		return cachedValue;
    	}
    	
    	String targetValue = defaultValue;
    	
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    	LAC_Metric_Target__c[] target = [SELECT Value__c from LAC_Metric_Target__c where Metric__c =: metric and Date__c >=: quarterStartDate and Date__c <=: quarterEndDate and OwnerId =: getUserId() order by Date__c ASC limit 1];
    	
    	if(target.size() > 0) {
    		targetValue = target[0].Value__c;
    	}
    	
    	setCachedValue(targetCache, metric, dateInQuarter, targetValue);
    	return targetValue;
    }
    
    public static Map<String, String> getLatestTargets(List<String> metricList, Date dateInQuarter, String defaultValue) {
    	Map<String, String> results = new Map<String, String>();
    	List<String> noCachedValues = new List<String>();
    	
    	// Check for metric validity, and get cached results if available
    	for(String metric: metricList) {
    		checkMetric(metric);
    		
    		String cachedValue = getCachedValue(latestTargetCache, metric, dateInQuarter);
    		if(cachedValue != null) {
    			results.put(metric, cachedValue);
    		} else {
    			noCachedValues.add(metric);
    		}
    	}	
    	
    	if(noCachedValues.size() > 0) {
    		Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    		Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    		
    		for(LAC_Metric_Target__c[] targets : [SELECT Metric__c, Value__c from LAC_Metric_Target__c where Metric__c IN :noCachedValues and Date__c <=: quarterEndDate and OwnerId =: getUserId() order by Date__c DESC]) {
    			for (LAC_Metric_Target__c target: targets) {
    				
    				if(target.Value__c != null) {
		    			setCachedValue(latestTargetCache, target.Metric__c, dateInQuarter, target.Value__c);
		    			results.put(target.Metric__c, target.Value__c);
		    		}
    			}
    		}
    	}
    	
    	for(String metric: metricList) {
    		if(!results.containsKey(metric)) {
    			results.put(metric, defaultValue);
    		}
    	}
    	
    	return results;
    }
    
    // Sets the target for a specific quarter
    public static void setTarget(String metric, String value, Date dateInQuarter) {
    	Date quarterStartDate = MetricHelpers.getQuarterFirstDay(dateInQuarter);
    	Date quarterEndDate = MetricHelpers.getQuarterLastDay(dateInQuarter);
    	LAC_Metric_Target__c[] oldTarget = [SELECT Value__c from LAC_Metric_Target__c where Metric__c =: metric and Date__c >=: quarterStartDate and Date__c <=: quarterEndDate and OwnerId =: getUserId() limit 1];
    	if(oldTarget.size() > 0) {
    		oldTarget[0].Value__c = value;
    		update oldTarget[0];
    	} else {
    		LAC_Metric_Target__c newTarget = new LAC_Metric_Target__c();
    		newTarget.Metric__c = metric;
    		newTarget.Value__c = value;
    		newTarget.Date__c = dateInQuarter;
    		insert newTarget;
    	}
    }
    
    // Sets the target for the current quarter
    public static void setTarget(String metric, String value) {
    	setTarget(metric, value, Date.today());	
    }
    
    // Return the current user id unless it's the guest user
    // For Guest users, return the admin user id (LAC User)
    // The reason is that metrics, targets and values are explicitly selected on a per-user basis so that we do not select the wrong one based on heirarchical rules
    // especially when deciding whether to create a new object or to select one 
    private static Id getUserId() {
		if(UserInfo.getUserType().equalsIgnoreCase('Guest')) {
			return LacUserId;
		}   	
		
		return UserInfo.getUserId();
    }
    
    static testMethod void testAll() {
		Date current = Date.today();
		
		for(String metric : metrics.keySet()) {
			LacMetricManager.getValue(metric, current);
		}
	}
}