@isTest
public class TestUpdateCkwPerformance {
    /** @isTest static void testUpdatePerformance() {
    
        User ckwadmin = [Select Id from User where alias = 'ckwadmin'];
        Contact ckwContact = new Contact(FirstName='Ckw',LastName='C3P0');
        ckwContact.ownerId = ckwadmin.id;
        insert ckwContact;
        District__c district = new District__c(Name='Test');
        insert district;
        Person__c ckwPerson = new Person__c();
        ckwPerson.First_Name__c = 'Kintu';
        ckwPerson.Last_Name__c = 'Gipiri';
        ckwPerson.Gender__c = 'Male';
        ckwPerson.District__c = district.Id;
        ckwPerson.Contact__c = ckwContact.id;
        insert ckwPerson;
        gfsurveys__Mobile_User__c mobileUser = new gfsurveys__Mobile_User__c();
        mobileUser.gfsurveys__Contact__c = ckwContact.Id;
        mobileUser.gfsurveys__Password__c = 'c3p0';
        mobileUser.gfsurveys__Username__c = 'c3po';
        mobileUser.gfsurveys__Status__c = 'Active';
        insert mobileUser;

        // Create an FO
        Contact foContact = new Contact(FirstName='c3po', LastName='fo');
        insert foContact;

        // Create a farmer
        Person__c farmerPerson = new Person__c();
        farmerPerson.Type__c = 'Focus Farmer';
        farmerPerson.Gender__c = 'Female';
        farmerPerson.First_Name__c = 'C3P0';
        farmerPerson.Last_Name__c = 'Gates';
        insert farmerPerson;
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = farmerPerson.Id;
        focusFarmer.Farmer_Type__c = 'Banana';
        insert focusFarmer;

        // Create a Search Log
        Search_Log__c searchLog = new Search_Log__c();
        searchLog.Interviewer_Contact__c = ckwContact.Id;
        searchLog.Interviewer__c = ckwPerson.Id;
        searchLog.Interviewee__c = farmerPerson.Id;
        searchLog.Category__c = 'Banana Gaps';
        insert searchLog;

        // Create search performance log object
        C3P0_Farmer_Visit__c visit = new C3P0_Farmer_Visit__c();
        visit.Contact__c = ckwContact.Id;
        visit.Person__c = farmerPerson.Id;
        visit.Search_Log__c = searchLog.Id;
        visit.Visit_Date__c = date.today();
        insert visit;

        // Create farmer cluster performance object
        Farmer_Cluster_Meeting__c farmerCluster = new Farmer_Cluster_Meeting__c();
        farmerCluster.Contact__c = ckwContact.Id;
        farmerCluster.Focus_Farmer__c = focusFarmer.Id;
        farmerCluster.Date__c = date.today();
        insert farmerCluster;

        // Create ckw fo cluster performance object
        Monthly_CKW_Visit__c foCluster = new Monthly_CKW_Visit__c();
        foCluster.FO__c = foContact.id;
        foCluster.CKW__c = ckwContact.Id;
        foCluster.Visit_Date__c = date.today();

        Test.startTest();
        
        UpdateCkwPerformance.updatePerformance();
        List<C3P0_CKW_Performance__c> performance = [Select Id, Unique_Searches__c from C3P0_CKW_Performance__c];
        System.assertEquals(1, performance.size());
        
        System.assertEquals(performance[0].Unique_Searches__c, 1);
        //}
        Test.stopTest();
    } **/
    
    @isTest static void testUpdatePerformanceBatched() {
    
        User ckwadmin = [Select Id from User where alias = 'ckwadmin'];
        Contact ckwContact = new Contact(FirstName='Ckw',LastName='C3P0');
        ckwContact.ownerId = ckwadmin.id;
        insert ckwContact;
        District__c district = new District__c(Name='Test');
        insert district;
        Person__c ckwPerson = new Person__c();
        ckwPerson.First_Name__c = 'Kintu';
        ckwPerson.Last_Name__c = 'Gipiri';
        ckwPerson.Gender__c = 'Male';
        ckwPerson.District__c = district.Id;
        ckwPerson.Contact__c = ckwContact.id;
        insert ckwPerson;
        gfsurveys__Mobile_User__c mobileUser = new gfsurveys__Mobile_User__c();
        mobileUser.gfsurveys__Contact__c = ckwContact.Id;
        mobileUser.gfsurveys__Password__c = 'c3p0';
        mobileUser.gfsurveys__Username__c = 'c3po';
        mobileUser.gfsurveys__Status__c = 'Active';
        insert mobileUser;

        // Create an FO
        Contact foContact = new Contact(FirstName='c3po', LastName='fo');
        insert foContact;

        // Create a farmer
        Person__c farmerPerson = new Person__c();
        farmerPerson.Type__c = 'Focus Farmer';
        farmerPerson.Gender__c = 'Female';
        farmerPerson.First_Name__c = 'C3P0';
        farmerPerson.Last_Name__c = 'Gates';
        insert farmerPerson;
        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = farmerPerson.Id;
        focusFarmer.Farmer_Type__c = 'Banana';
        insert focusFarmer;

        // Create a Search Log
        Search_Log__c searchLog = new Search_Log__c();
        searchLog.Interviewer_Contact__c = ckwContact.Id;
        searchLog.Interviewer__c = ckwPerson.Id;
        searchLog.Interviewee__c = farmerPerson.Id;
        searchLog.Category__c = 'Banana Gaps';
        insert searchLog;

        // Create search performance log object
        C3P0_Farmer_Visit__c visit = new C3P0_Farmer_Visit__c();
        visit.Contact__c = ckwContact.Id;
        visit.Person__c = farmerPerson.Id;
        visit.Search_Log__c = searchLog.Id;
        visit.Visit_Date__c = date.today();
        insert visit;

        // Create farmer cluster performance object
        Farmer_Cluster_Meeting__c farmerCluster = new Farmer_Cluster_Meeting__c();
        farmerCluster.Contact__c = ckwContact.Id;
        farmerCluster.Focus_Farmer__c = focusFarmer.Id;
        farmerCluster.Date__c = date.today();
        insert farmerCluster;

        // Create ckw fo cluster performance object
        Monthly_CKW_Visit__c foCluster = new Monthly_CKW_Visit__c();
        foCluster.FO__c = foContact.id;
        foCluster.CKW__c = ckwContact.Id;
        foCluster.Visit_Date__c = date.today();

        Test.startTest();
        Database.executeBatch(new UpdateCkwPerformanceBatched(), 50);
        Test.stopTest();
        
        List<C3P0_CKW_Performance__c> performance = [Select Id, Unique_Searches__c from C3P0_CKW_Performance__c];
        System.assertEquals(1, performance.size()); 
        if (date.today().day() != 1 && date.today().day() != 2) {       
            System.assertEquals(performance[0].Unique_Searches__c, 1);
        }
    }
}