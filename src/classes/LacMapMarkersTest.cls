@isTest
public with sharing class LacMapMarkersTest {
	
	public static testMethod void testMapMarkers() {
		 LacMapMarkerSources.Farmers farmers = new LacMapMarkerSources.Farmers();
		farmers.loadMapMarkers(new Map<String, String>());
		
		LacMapMarkerSources.CKWs ckws = new LacMapMarkerSources.CKWs();
		ckws.loadMapMarkers(new Map<String, String>());
		
		LacMapMarkerSources.AllPeople allPeople = new LacMapMarkerSources.AllPeople();
		allPeople.loadMapMarkers(new Map<String, String>());
		
		Contact contact = new Contact();
		contact.FirstName = 'Luke';
		contact.LastName = 'Kyohere';
		insert contact;
		
		Person__c person = new Person__c();
		person.Contact__c = contact.Id;
		person.First_Name__c = contact.FirstName;
		person.Last_Name__c = contact.LastName;
		insert person;
		
		LAC_Farmer_Details__c farmer = new LAC_Farmer_Details__c();
		
		farmer.Person__c = person.Id;
		farmer.Contact__c = contact.Id;
		insert farmer;
		
		new LacMapMarkers.LacFarmerMarker(farmer);
		
		Contact contact2 = new Contact();
		contact2.FirstName = 'Luke2';
		contact2.LastName = 'Kyohere2';
		insert contact2;
		
		Person__c person2 = new Person__c();
		person2.Contact__c = contact2.Id;
		person2.First_Name__c = contact2.FirstName;
		person2.Last_Name__c = contact2.LastName;
		insert person2;
		
		CKW__c ckw = new CKW__c();
		ckw.Person__c = person2.Id;
		insert ckw;
		
		new LacMapMarkers.LacCkwMarker(ckw);
	}
}