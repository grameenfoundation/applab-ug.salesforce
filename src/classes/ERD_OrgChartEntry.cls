public class ERD_OrgChartEntry {
	public String label { get; set; } 
	
	public Integer row { get; set; }
	
	public Integer column { get; set; }
	
	public List<ERD_FieldWrapper> fields {get; set;}
	
	testMethod static void testLabel() {
		ERD_OrgChartEntry oce = new ERD_OrgChartEntry();
		oce.label = 'test';
		System.assert(oce.label == 'test');
	}
}