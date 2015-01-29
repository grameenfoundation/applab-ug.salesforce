public with sharing class FMPCategoryResultsGroup {

	public String categoryName;
	
	public Date resultsDate;
	
	public List<FMPCategoryResult> results = new List<FMPCategoryResult>();

	public void addResultGroup(FMPCategoryResult res) { 
		results.add(res);
	}
	
	public List<FMPCategoryResult> getCategoryResults() {
		return results;
	}

}