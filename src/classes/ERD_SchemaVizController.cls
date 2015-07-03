public class ERD_SchemaVizController {	 
	private Map<String, Map<String, Schema.SObjectField>> fieldsByClassName; 
	private Integer cursor;	 
	
	public ERD_SchemaVizController() {
		//build the 1st page of the visualized schema starting the cursor at zero
	 	cursor = 0;
	 	fieldsByClassName = ERD_DescribeSObjects.getAll(cursor);	 	
	}

	public String getOrganizationName() {
		return UserInfo.getOrganizationName();
	}
	
	testMethod static void testERD_SchemaVizController() {
    	ERD_SchemaVizController svc = new ERD_SchemaVizController();
    	System.assert(svc.getOrganizationName() != null);    	    	
    	System.assert(svc.getOrgCharts() != null);
    	System.assert(svc.getClassNames() != null);  
    	System.assert(svc.getClassCount() != null);  	
	}
	
	testMethod static void testERD_SchemaVizControllerTestNavigation() {
		ERD_SchemaVizController svc = new ERD_SchemaVizController();
    	System.assert(svc.nextPage() != null);
	}
	 
	/*
	* Description:  Each Class is visualized via the ERD_OrgChart component of the Google Visualizer API. Each
	* class will have its own chart broken down by CLASS NAME > FIELD DATA TYPE > FIELD LABEL.	  
	*/
	public List<ERD_OrgChart> getOrgCharts() {
		List<ERD_OrgChart> listOfOrgCharts = new List<ERD_OrgChart>();	 	
	 	List<ERD_OrgChartEntry> orgChartEntries = new List<ERD_OrgChartEntry>();	 	
	 	Map<String, List<ERD_FieldWrapper>> fieldListByType = new Map<String, List<ERD_FieldWrapper>>();
	 	ERD_OrgChartEntry oce;
	 	ERD_OrgChart oc;
	 	Schema.SObjectField field;
	 	
	 	//Create an Org Chart for each Class.  
	 	for(String className : fieldsByClassName.keySet()) {
			oc = new ERD_OrgChart();
	 		oc.title = className;
	 		orgChartEntries = new List<ERD_OrgChartEntry>();
	 		Map<String, Schema.SObjectField> fieldMap = fieldsByClassName.get(className);
	 		fieldListByType = new Map<String, List<ERD_FieldWrapper>>();
	 		//Group each classes fields by data type
	 		for(String fieldName : fieldMap.keySet()) {	 			
				field = fieldMap.get(fieldName);
	 			if(field != null) {
	 				Schema.DescribeFieldResult d = field.getDescribe();
	 				Schema.DisplayType dt = d.getType();
	 				ERD_FieldWrapper fw = new ERD_FieldWrapper();
	 				fw.fieldLabel = d.getLabel(); 
	 				fw.fieldType = dt.name();  	 			
	 				//if the field data type has been encountered add to exsiting list otherwise add new entry
	 				if(fieldListByType.containsKey(dt.name())) {
	 					fieldListByType.get(dt.name()).add(fw); 
	 				} else {
	 					List<ERD_FieldWrapper> fws = new List<ERD_FieldWrapper>();
	 					fws.add(fw);
	 					fieldListByType.put(dt.name(), fws);	 					
	 				}	 				
	 			}
	 		}
			/* Convert fieldListByType so that each data type is an ERD_OrgChartEntry, with meta data and it
	 		has a list of FieldWrappers which will be printed as <li> inside the org chart entry */	 		
	 		oc.entries = convertFieldMapToOrgChartEntries(fieldListByType, className);
	 		
	 		/* The entry count is half of the actual size as a row is also maintained for each parent - see
	 		Google's API for more details.  One is added to account for the Class Name, the title of the org
	 		chart */
	 		oc.setEntryCount((oc.entries.size() + 1)/2);
	 		listOfOrgCharts.add(oc);
	 	}	
	 	 	
		return listOfOrgCharts; 		 	
	}
	 
	/*
	* Description:  Display the next page (page size limited by the max # of describe calls allowed) and adjust the cursor accordingly
	*/
	public PageReference nextPage() {
		//System.debug('Cursor:' + cursor + ' Original Fields By Class Name Size:' + fieldsByClassName.size());
		PageReference p = Page.ERD_SchemaViz;
	 	cursor = cursor + ERD_DescribeSObjects.DESCRIBE_CALL_LIMIT;
	 	fieldsByClassName = ERD_DescribeSObjects.getAll(cursor);
	 	if(fieldsByClassName.size() == 0) {
	 		//gone too far no classes left to view
	 		cursor = cursor - ERD_DescribeSObjects.DESCRIBE_CALL_LIMIT;
	 		fieldsByClassName = ERD_DescribeSObjects.getAll(cursor);
	 	}
	 	//System.debug('Cursor:' + cursor + ' New Fields By Class Name Size:' + fieldsByClassName.size());
	 	return p;
	 }
	 
	/*
	* Description:  Display the previous page and adjust the cursor accordingly
	*/
	public PageReference previousPage() {
		PageReference p = Page.ERD_SchemaViz;
	 	
	 	if (cursor - ERD_DescribeSObjects.DESCRIBE_CALL_LIMIT > 0) {
			cursor = cursor - ERD_DescribeSObjects.DESCRIBE_CALL_LIMIT;
	 	} else {
	 		cursor = 0;
	 	}
	 	
	 	fieldsByClassName = ERD_DescribeSObjects.getAll(cursor);
	 	
	 	return p;
	 }
	 
	/*
	* Description:  Convert map of fields grouped by data type to ERD_OrgChartEntry objects 
	* sorted in child-parent order compatible with Google Visualization API
	*/
	private List<ERD_OrgChartEntry> convertFieldMapToOrgChartEntries(Map<String, List<ERD_FieldWrapper>> fieldListByType, String className) {	 		
		List<ERD_OrgChartEntry> orgChartEntries = new List<ERD_OrgChartEntry>();
 		Integer rowCount = 1;
 		//first entry should be the class name
 		ERD_OrgChartEntry oce = new ERD_OrgChartEntry();
 		oce.label = className;
 		oce.column = 0;
 		oce.row = 0;
 		orgChartEntries.add(oce);
 		
 		for(String fieldType : fieldListByType.keyset()) {
 			ERD_OrgChartEntry fieldEntry = new ERD_OrgChartEntry();
 			ERD_OrgChartEntry classEntry = new ERD_OrgChartEntry();
 			
 			fieldEntry.label = fieldType + '<ul class="' + fieldType + '">'+ convertFieldWrapperToHTML(fieldListByType.get(fieldType)) + '</ul>';
 			fieldEntry.row = rowCount;
 			fieldEntry.column = 0;
 			
 			classEntry.label = className;
 			classEntry.row = rowCount;
 			classEntry.column = 1;
 			
 			orgChartEntries.add(fieldEntry);
 			orgChartEntries.add(classEntry);
 			rowCount ++;
 		}
 			
		return orgChartEntries;
	 }
	 
 	/*
	* Description:  Mark up field labels with list item tags.  The List Item tag is the 
	* most versatile of HTML and the user can use CSS to tweak display to their hearts content 
	*/
	private String convertFieldWrapperToHTML(List<ERD_FieldWrapper> fieldList) {
		String html = '';
	 	
	 	for(ERD_FieldWrapper fw: fieldList) {
	 		html += '<li class="ellipsis">' + fw.fieldLabel + '</li>';
	 	}
	 	
	 	return html;
	 }
	 
	 public List<String> getClassNames() {
	 	List<String> classNames = new List<String>();
	 	
	 	for(String className : fieldsByClassName.keySet()) {
	 		classNames.add(className);	 		
	 	} 
	 	
		return classNames;
	 	
	}	
	 
	public Integer getClassCount() { 
		return getClassNames().size();	 	
	}
}