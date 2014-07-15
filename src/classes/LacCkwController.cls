public with sharing class LacCkwController {

    private List<List<String>> farmerGPSAddresses = new List<List<String>>();
    private List<LAC_Farmer_Details__c> ckwFarmers = new List<LAC_Farmer_Details__c>();
    private Contact contact;
    private Person__c person;
    private LAC_Farmer_Details__c lacFarmer;
    private CKW__c ckw;
    private ApexPages.StandardController stdController;

    public LacCkwController(ApexPages.StandardController controller) {
        this.stdController = controller;
        ckw = (CKW__c)stdController.getRecord();
        ckw = [Select Id, Person__c from CKW__c where Id =:ckw.Id];
        person = [Select id, First_Name__c, Contact__c, Contact__r.gfsurveys__mobilesurveys_Status__c 
            from Person__c where Id=:ckw.Person__c ];
        lacFarmer = [Select Id, 
                        Contact__c,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.Birthdate,
                        Contact__r.gfsurveys__mobilesurveys_Id__c,
                        Name,
                        Country__c,
                        Community__c,
                        Department__c,
                        District__c,
                        Gender__c,
                        Municipality__c,
                        Farmer_Cooperative__c,
                        Entrance_Into_Programme__c,
                        Has_Cellphone__c,
                        Has_Data_Plan__c,
                        Latitude__c,
                        Longitude__c,
                        Cell_Phone_Number__c
                    from LAC_Farmer_Details__c
                    where Contact__c=:person.Contact__c];
    }

    public LAC_Farmer_Details__c getLacFarmer() {
        return this.lacFarmer;
    }

    public Person__c getPerson() {
        return this.person;
    }

    public List<List<String>> getAssignedFarmers() {
        if (person == null) {
            person = [Select id, First_Name__c, Contact__c, Contact__r.gfsurveys__mobilesurveys_Status__c
                from Person__c where Id=:ckw.Person__c];
        }
        LAC_Farmer_Details__c[] farmers = [Select Id,
                                                    Contact__c,
                                                    Contact__r.FirstName,
                                                    Contact__r.LastName,
                                                    Name,
                                                    Farmer_code__c,
                                                    Registered_By__c,
                                                    Latitude__c,
                                                    Longitude__c
                                            FROM LAC_Farmer_Details__c
                                            WHERE Registered_By__c=:person.Contact__c];
        ckwFarmers = farmers;
        farmerGPSAddresses.add(new String[]{ String.valueOf(lacFarmer.Latitude__c), String.valueOf(lacFarmer.Longitude__c)});
        for (LAC_Farmer_Details__c farmer : farmers) {
            String[] addressList = new String[]{ String.valueOf(farmer.Latitude__c), String.valueOf(farmer.Longitude__c)};
            farmerGPSAddresses.add(addressList);
        }
        return farmerGPSAddresses;
    }

    public DateTime getEnrollmentDate() {
        Contact[] contact = [Select CreatedDate from Contact where Id =:person.Contact__c];
        return contact[0].CreatedDate;
    }
    
    public DateTime getLastSurveyDate(){
        gfsurveys__Submission__c submission = [Select CreatedDate from gfsurveys__Submission__c where 
            gfsurveys__Surveyor__c=:person.Contact__c order by CreatedDate desc limit 1];
        return submission.CreatedDate;
    }

    public Integer getNumberOfAssignedFarmers() {
        LAC_Farmer_Details__c[] farmers = [Select Id,
                                                Contact__c,
                                                Contact__r.FirstName,
                                                Contact__r.LastName,
                                                Name,
                                                Farmer_code__c,
                                                Registered_By__c,
                                                Latitude__c,
                                                Longitude__c,
                                                Municipality__c,
                                                Community__c
                                        FROM LAC_Farmer_Details__c
                                        WHERE Registered_By__c=:person.Contact__c];
        ckwFarmers = farmers;
        return farmers.size();
    }

    public Integer getAssignedCommunities() {
        Set<String> communities = new Set<String>();
        for (LAC_Farmer_Details__c farmer : ckwFarmers) {
            communities.add(farmer.Community__c);
        }
        return communities.size();
    }

    public Integer getAssignedMunicipalities() {
        Set<String> municipalities = new Set<String>();
        for (LAC_Farmer_Details__c farmer : ckwFarmers) {
            municipalities.add(farmer.Municipality__c);
        }
        return municipalities.size();
    }

    public List<LAC_Farmer_Details__c> getCkwFarmers() {
        getNumberOfAssignedFarmers();
        return ckwFarmers;
    }

}