public class AgrowaysVacsMapController {

	private List<Person__c> agrowaysPersons = new List<Person__c>();

	public AgrowaysVacsMapController() {
		agrowaysPersons = [SELECT Id,
									GPS_Location_E__c,
									GPS_Location_N__c,
									First_Name__c,
									Last_Name__c
								FROM Person__c
								WHERE Id 
								IN (Select Person__c 
									FROM Person_Group_Association__c
									WHERE 
									Group__r.Name ='Agroways VACs')];

	}

	public List<List<String>> getGpsLocations() {
		List<List<String>> gpsLocations = new List<List<String>>();
		for (Person__c person : agrowaysPersons) {
			String[] addressList = new String[] {String.valueOf(person.GPS_Location_E__c), 
												String.valueOf(person.GPS_Location_N__c)};
			gpsLocations.add(addressList);
		}
		return gpsLocations;
	}
}