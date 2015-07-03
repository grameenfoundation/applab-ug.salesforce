@isTest
public class TestNaadsMapMarkerSources {

    @isTest static void testLoadMapMarkers() {
        // Create district and Subcounty records
        District__c district = new District__c(Name='AASP District');
        insert district;
        Subcounty__c subcounty = new Subcounty__c(District__c = district.Id, Display_Name__c='AASP Subcounty');
        insert subcounty;
        
        // Create person records
        List<Person__c> persons = new List<Person__c>();
        for (Integer index =0; index < 3; index++) {
            Person__c person = new Person__c();
            person.First_Name__c = 'FirstName'+index;
            person.Last_Name__c = 'LastName'+index;
            person.Gender__c = 'Female';
            person.Type__c = 'AASP';
            person.GPS_Location_E__c = '23.999'+index;
            person.GPS_Location_N__c = index+'.233';
            person.Parish__c = 'parish';
            person.Village__c = 'village';
            person.District__c = district.Id;
            person.Subcounty__c = subcounty.Id;
            persons.add(person);
        }
        insert persons;
        List<Client_Location__c> locations =  new List<Client_Location__c>();
        for (Person__c person : persons) {
            locations.add(new Client_Location__c(Type__c='AASP Visit', Display_Name__c=person.First_Name__c, District__c=person.District__c, Person__c = person.Id, Latitude__c=person.GPS_Location_E__c, Longitude__c=person.GPS_Location_N__c, Description__c='blah blah'));
        }
        insert locations;
        NaadsMapMarkerSources.AASPs aasps = new NaadsMapMarkerSources.AASPs();
        Map <String, String> parameters = new Map <String, String> {'focus' => persons[0].Id};
        Test.startTest();
        System.assert(aasps.loadMapMarkers(parameters).size() > 0);
        Test.stopTest();
    }
}