public with sharing class EwarehouseFarmer {

	private static ServiceLogger logger = new ServiceLogger();
	
	public String Id { get; set; }
	public String MobilePhone { get; set; }
    public String FirstName { get; set; }
	public String MiddleName { get; set; }
    public String LastName { get; set; }
    public String District { get; set; }
    public String Village { get; set; }
    public String GroupName { get; set; } 
    public String Status { get; set; } 
    public DateTime RegisterDate { get; set; }
    public String FciID { get; set; } 
    
    public static EwarehouseFarmer fromSfObject(Ewarehouse_Farmer__c sfObject){
    	
    	logger.debug('test logger');
    
    	Person__c person = sfObject.Ewarehouse_Person__r;
    	
    	if(person == null)
    		return null;
    	
    	// create new client
        EwarehouseFarmer farmer = new EwarehouseFarmer();
    	farmer.Id = sfObject.Name; 
    	
    	// take the information from the referenced objects when they are available
		farmer.FirstName = person.First_Name__c;
		farmer.MiddleName = person.Middle_Name__c;
	    farmer.LastName = person.Last_Name__c;
	    farmer.MobilePhone = person.Mobile_Number__c;
	    farmer.Village = person.Village__c;
	    
	    farmer.District = sfObject.District__c;
		farmer.Status = sfObject.Status__c;
		farmer.GroupName = sfObject.Commercial_Purchase_Groups__c;
		farmer.RegisterDate = sfObject.Registration_Date__c;
		
		farmer.FciID = sfObject.Auto_Generated_Farmer_ID__c;
		
		logger.debug(farmer);
		
		return farmer;
    }
    
}