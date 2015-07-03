/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Test methods for the following classes; 
 *
 *  - CalculateFarmerInteractions
 *  - ScheduledC3P0FarmerInteractionCalculator
 *  - ScheduledCalculateUniqueOneOnOnes
 *  
 **/
@isTest
public class TestCalculateFarmerInteractions {
    
    @isTest static void testFarmerInteractionsCalculations() {
        
        Integer day = date.today().day();
        
        Test.startTest(); 
        Country__c country = new Country__c();
        country.Name = 'Uganda';
        insert country;
        
        Contact ckwContact = new Contact(FirstName='ckw', LastName='eee');
        insert ckwContact;
        
        Contact ckwContact2 = new Contact(FirstName='ckw', LastName='fff');
        insert ckwContact2;

        Person__c personCkw = new Person__c();
        personCkw.First_Name__c = 'ckw';
        personCkw.Last_Name__c = 'camara';
        personCkw.Type__c = 'CKW';
        personCkw.Gender__c = 'Female';
        personCkw.Contact__c = ckwContact.Id;
        insert personCkw;
        
        Person__c person = new Person__c();
        person.First_Name__c = 'titi';
        person.Last_Name__c = 'camara';
        person.Type__c = 'Focus Farmer';
        person.Gender__c = 'Male';
        insert person;
        
        Person__c person2 = new Person__c();
        person2.First_Name__c = 'jeje';
        person2.Last_Name__c = 'camara';
        person2.Type__c = 'Focus Farmer';
        person2.Gender__c = 'Female';
        insert person2;
        
        Person__c person3 = new Person__c();
        person3.First_Name__c = 'vin';
        person3.Last_Name__c = 'camara';
        person3.Type__c = 'Focus Farmer';
        person3.Gender__c = 'Female';
        insert person3;

        Focus_Farmer__c focusFarmer = new Focus_Farmer__c();
        focusFarmer.Person__c = person.Id;
        focusFarmer.Farmer_Type__c = 'Banana';
        insert focusFarmer;
        
        Focus_Farmer__c focusFarmer2 = new Focus_Farmer__c();
        focusFarmer2.Person__c = person2.Id;
        focusFarmer2.Farmer_Type__c = 'Coffee';
        insert focusFarmer2;
        
        Focus_Farmer__c focusFarmer3 = new Focus_Farmer__c();
        focusFarmer3.Person__c = person3.Id;
        focusFarmer3.Farmer_Type__c = 'Maize';
        insert focusFarmer3;

        Banana_Farmer__c bananaFarmer = new Banana_Farmer__c();
        bananaFarmer.Focus_Farmer__c = focusFarmer.Id;
        bananaFarmer.Registered_By__c = ckwContact.Id;
        insert bananaFarmer;
        
        Coffee_Farmer__c cFarmer = new Coffee_Farmer__c();
        cFarmer.Focus_Farmer__c = focusFarmer2.Id;
        cFarmer.Registered_By__c = ckwContact2.Id;
        insert cFarmer;
        
        Maize_Farmer__c mFarmer = new Maize_Farmer__c();
        mFarmer.Focus_Farmer__c = focusFarmer3.Id;
        mFarmer.Registered_By__c = ckwContact.Id;
        insert mFarmer;
        
        Search_Log__c log = new Search_Log__c();
        log.Interviewer__c = personCkw.Id;
        log.Interviewee__c = person.Id;
        log.Server_Entry_Time__c = day == 1 ? Date.today().addMonths(-1) : Date.today();
        log.Submission_GPS_Timestamp__c = day == 1 ? Date.today().addMonths(-1) : Date.today();
        insert log;

        Message__c message = new Message__c();
        message.Subject__c = 'test message';
        message.Recipient__c = person.Id;
        message.Body__c = 'This is a test message';
        message.Sent_Time__c = day == 1 ? datetime.now().addMonths(-1) : datetime.now();
        message.Type__c = 'SMS';
        insert message;

        Case phoneCall = new Case();
        phoneCall.Person__c = person.Id;
        phoneCall.Origin = 'Phone Call';
        //phoneCall.CreatedDate = day == 1 ? Date.today().addMonths(-1) : Date.today();
        insert phoneCall;     
        
        Banana_Cluster_Meeting__c meeting = new Banana_Cluster_Meeting__c();
        meeting.Banana_Farmer__c = bananaFarmer.Id;
        meeting.Meeting_Date__c = day == 1 ? Date.today().addMonths(-1) : Date.today();
        insert meeting;
         
        //test the schedule class      
        String jobId = System.schedule('ScheduledC3P0FarmerInteractionCalculator',
            ScheduledC3P0FarmerInteractionCalculator.cronExpression, 
            new ScheduledC3P0FarmerInteractionCalculator());
               
        String farmerQuery =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Gender__c, '           +
                'Village__c '           +
            'FROM '                     +
                'Person__c '            +
            'WHERE '                    +
                'Type__c = \'Focus Farmer\' ';
        CalculateFarmerInteractions c = new CalculateFarmerInteractions(farmerQuery);
        Database.executeBatch(c);
        Test.stopTest();
        
        List<C3P0_Farmer_Interaction__c> interactions = [Select Id from C3P0_Farmer_Interaction__c];
        List<C3P0_Farmer_Interaction__c> interaction = [
            Select 
                Id, 
                Number_of_SMS__c, 
                Number_of_Searches__c, 
                Number_of_Calls_to_Call_Centre__c ,
                Number_of_Group_Meetings_Attended__c
            FROM 
                C3P0_Farmer_Interaction__c
            WHERE 
                Focus_Farmer__c = :focusFarmer.Id];
        System.assertEquals(3, interactions.size());
        System.assertEquals(1, interaction.size());
        System.assertEquals(interaction.get(0).Number_of_SMS__c, 1);
        System.assertEquals(interaction.get(0).Number_of_Searches__c, 1);
        System.assertEquals(interaction.get(0).Number_of_Calls_to_Call_Centre__c, day == 1? 0 : 1);
        System.assertEquals(interaction.get(0).Number_of_Group_Meetings_Attended__c, 1);
    }
    
    @isTest static void testCalculateUniqueOneOnOnesMidMonth() {
                 
        Contact ckwContact = new Contact(FirstName='ckw', LastName='eee');
        ckwContact.OwnerId = UserInfo.getUserId();
        insert ckwContact;        
        
        Person__c personCkw = new Person__c();
        personCkw.First_Name__c = 'ckw';
        personCkw.Last_Name__c = 'camara';
        personCkw.Type__c = 'CKW';
        personCkw.Gender__c = 'Female';
        personCkw.Contact__c = ckwContact.Id;
        insert personCkw;
        
        Person__c person = new Person__c();
        person.First_Name__c = 'titi';
        person.Last_Name__c = 'camara';
        person.Type__c = 'Focus Farmer';
        person.Gender__c = 'Male';
        insert person;        
        
        //insert performace record that will be updated
        C3P0_CKW_Performance__c ckwPerformance = new C3P0_CKW_Performance__c();
        ckwPerformance.Contact__c = ckwContact.Id;
        ckwPerformance.Unique_Farmer_Visits__c = 0;
        ckwPerformance.Unique_Searches__c = 0;
        ckwPerformance.Visits_to_F0__c = 0;
        ckwPerformance.CKW_Gender__c = 'Female';
        ckwPerformance.District__c = 'Dinda';
        if (date.today().day() != 1) {
            ckwPerformance.Performance_Date__c = date.today();
        }
        else {
            ckwPerformance.Performance_Date__c = date.today().addDays(-1);
        }
        insert ckwPerformance;
        
        Search_Log__c log = new Search_Log__c();
        log.Interviewer__c = personCkw.Id;
        log.Interviewee__c = person.Id;
        log.Server_Entry_Time__c = ckwPerformance.Performance_Date__c;
        insert log;
        
        C3P0_Farmer_Visit__c visit = new C3P0_Farmer_Visit__c();
        visit.Visit_Date__c = ckwPerformance.Performance_Date__c;
        visit.Person__c = person.Id;
        visit.Contact__c = ckwContact.Id;
        visit.Search_Log__c = log.Id;
        insert visit;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleCalculateUniqueOneOnOnes',
            ScheduledCalculateUniqueOneOnOnes.cronExpression, 
            new ScheduledCalculateUniqueOneOnOnes());
            
        String query = 
            'SELECT '                +
                'Id,'                +
                'Name '              +
            'FROM '                  +
                'Contact '           +
            'WHERE '                 +
                'OwnerId = \'' + UserInfo.getUserId() + '\' ';      
                //+ 'AND Id In (select gfsurveys__Contact__c from gfsurveys__Mobile_User__c where gfsurveys__Status__c = \'Active\')';
            
        ID batchprocessid = Database.executeBatch(new CalculateUniqueOneOnOnes(query), 10);
        CalculateUniqueOneOnOnes c = new CalculateUniqueOneOnOnes(query);
        c.day = 2;
        Database.executeBatch(c);
        Test.stopTest();
        
        //only one record expected
        C3P0_CKW_Performance__c perf = [SELECT Unique_Searches__c, Unique_Farmer_Visits__c, Unique_One_to_One__c FROM C3P0_CKW_Performance__c];
        System.assert(perf.Unique_One_to_One__c == 1);
    }
    
    @isTest static void testCalculateUniqueOneOnOnesMonthDay1() {
                 
        Contact ckwContact = new Contact(FirstName='ckw', LastName='eee');
        ckwContact.OwnerId = UserInfo.getUserId();
        insert ckwContact;        
        
        Person__c personCkw = new Person__c();
        personCkw.First_Name__c = 'ckw';
        personCkw.Last_Name__c = 'camara';
        personCkw.Type__c = 'CKW';
        personCkw.Gender__c = 'Female';
        personCkw.Contact__c = ckwContact.Id;
        insert personCkw;
        
        Person__c person = new Person__c();
        person.First_Name__c = 'titi';
        person.Last_Name__c = 'camara';
        person.Type__c = 'Focus Farmer';
        person.Gender__c = 'Male';
        insert person;        
        
        //insert performace record that will be updated
        C3P0_CKW_Performance__c ckwPerformance = new C3P0_CKW_Performance__c();
        ckwPerformance.Contact__c = ckwContact.Id;
        ckwPerformance.Unique_Farmer_Visits__c = 0;
        ckwPerformance.Unique_Searches__c = 0;
        ckwPerformance.Visits_to_F0__c = 0;
        ckwPerformance.CKW_Gender__c = 'Female';
        ckwPerformance.District__c = 'Dinda';
        ckwPerformance.Performance_Date__c = date.today().addMonths(-1);
        insert ckwPerformance;
        
        Search_Log__c log = new Search_Log__c();
        log.Interviewer__c = personCkw.Id;
        log.Interviewee__c = person.Id;
        log.Server_Entry_Time__c = ckwPerformance.Performance_Date__c;
        insert log;
        
        C3P0_Farmer_Visit__c visit = new C3P0_Farmer_Visit__c();
        visit.Visit_Date__c = ckwPerformance.Performance_Date__c;
        visit.Person__c = person.Id;
        visit.Contact__c = ckwContact.Id;
        visit.Search_Log__c = log.Id;
        insert visit;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleCalculateUniqueOneOnOnes',
            ScheduledCalculateUniqueOneOnOnes.cronExpression, 
            new ScheduledCalculateUniqueOneOnOnes());
            
        String query = 
            'SELECT '                +
                'Id,'                +
                'Name '              +
            'FROM '                  +
                'Contact '           +
            'WHERE '                 +
                'OwnerId = \'' + UserInfo.getUserId() + '\' ';      
                //+ 'AND Id In (select gfsurveys__Contact__c from gfsurveys__Mobile_User__c where gfsurveys__Status__c = \'Active\')';
            
        ID batchprocessid = Database.executeBatch(new CalculateUniqueOneOnOnes(query), 10);
        CalculateUniqueOneOnOnes c = new CalculateUniqueOneOnOnes(query);
        c.day = 1;
        Database.executeBatch(c);
        Test.stopTest();
        
        //only one record expected
        C3P0_CKW_Performance__c perf = [SELECT Unique_Searches__c, Unique_Farmer_Visits__c, Unique_One_to_One__c FROM C3P0_CKW_Performance__c];
        System.assert(perf.Unique_One_to_One__c == 1);
    }
}