public with sharing class AsocatiDashboardProducerController {
	
	//TODO: To check if this variable is needed or the farmer name can be passed directly to the page control.
	private String LacFarmerName = 'No farmer';
	
	 //Property used for the Id entered by the user
	public String farmerId{
		get;
		set;
	}
	
	public AsocatiDashboardProducerController() {
		
		
	}
	
	
		//Event fired by the search button.
	public void onTestSearchButton(){
		
		if(this.farmerId.length()>0)
		{
			//TODO:At the event instead of doing this go and search for the farmer  
			this.setFarmerName('John Angel');			
		}
		else
		{
			this.setFarmerName('No farmer');
		}
	}
	
	//Method used to store the farmer name that will be displayed on the page.
	public void setFarmerName(String name){
		this.LacFarmerName = name;
	}
	
	//Method used by the page to retrieve the farmer name and display it.
	public String getFarmerName(){
		
		//TODO:To delete once the issue with storing the testFarmer is solved.
		return this.LacFarmerName;
		
    }
    
    public List<PieWedgeData> getPieData() {
		List<PieWedgeData> data = new List<PieWedgeData>();
		data.add(new PieWedgeData('Jan', 30));
		data.add(new PieWedgeData('Feb', 15));
		data.add(new PieWedgeData('Mar', 10));
		data.add(new PieWedgeData('Apr', 20));
		data.add(new PieWedgeData('May', 20));
		data.add(new PieWedgeData('Jun', 5));
		return data;
	}
	
	// Wrapper class
	public class PieWedgeData {
		public String name { get; set; }
		public Integer data { get; set; }
		public PieWedgeData(String name, Integer data) {
		this.name = name;
		this.data = data;
	}
}

}