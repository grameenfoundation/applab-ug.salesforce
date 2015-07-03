public class ERD_OrgChart {
	public String title { get; set; }
	public List<ERD_OrgChartEntry> entries { get; set; }
	
	private Integer entryCount;
	
	public Integer getEntryCount() {
		return entryCount;
	}
	
	public void setEntryCount(Integer el) {
		entryCount = el;
	}
	
	testMethod static void testTitle() {
		ERD_OrgChart oc = new ERD_OrgChart();
		oc.title = 'test';
		oc.setEntryCount(1);
		System.assert(oc.title == 'test');
		System.assert(oc.getEntryCount() == 1);
	}
}