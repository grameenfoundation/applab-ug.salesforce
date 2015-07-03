/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Contains tests for the following classes:
 * - CompileGapsDiscussionsCalls 
 * - CompileGapsDiscussionsFarmerMeetings 
 * - CompileGapsDiscussionsSearchLogs 
 * - CompileGapsDiscussionsSms 
 * - CompileGapsDiscussionsScheduler
 * - CompileGapsDiscussionsScheduler2
 */
@isTest
public class CompileGapsDiscussionsTests {
     
    static testMethod void testCompileGapsDiscussionsCalls() {
    
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        insert testPerson;
          
        List<Case> cases = new List<Case>();
        
        //banana
        Case callCase = new Case();
        callCase.Category__c = 'Banana GAP1: Soil Fertility';
        callCase.Person__c = testPerson.Id;
        cases.add(callCase);
        
        Case callCaseb2 = new Case();
        callCaseb2.Category__c = 'Banana GAP2: Desuckering, Pruning';
        callCaseb2.Person__c = testPerson.Id;
        cases.add(callCaseb2);
        
        Case callCaseb3 = new Case();
        callCaseb3.Category__c = 'Banana GAP3: Soil and Water Conservation';
        callCaseb3.Person__c = testPerson.Id;
        cases.add(callCaseb3);
        
        Case callCaseb4 = new Case();
        callCaseb4.Category__c = 'Banana GAP4: Support for Banana Plants';
        callCaseb4.Person__c = testPerson.Id;
        cases.add(callCaseb4);
        
        Case callCaseb5 = new Case();
        callCaseb5.Category__c = 'Banana GAP5: Record Keeping';
        callCaseb5.Person__c = testPerson.Id;
        cases.add(callCaseb5);
        
        Case callCaseb6 = new Case();
        callCaseb6.Category__c = 'Banana GAP6: Group Production, Marketing';
        callCaseb6.Person__c = testPerson.Id;
        cases.add(callCaseb6);
        
        Case callCaseb7 = new Case();
        callCaseb7.Category__c = 'Banana GAP7: Weed Control';
        callCaseb7.Person__c = testPerson.Id;
        cases.add(callCaseb7);
        
        Case callCaseb8 = new Case();
        callCaseb8.Category__c = 'Banana GAP8: Pests and Disease';
        callCaseb8.Person__c = testPerson.Id;
        cases.add(callCaseb8);
        
        Case callCaseb9 = new Case();
        callCaseb9.Category__c = 'Banana GAP9: Value Addition';
        callCaseb9.Person__c = testPerson.Id;
        cases.add(callCaseb9);   
             
        Case callCaseb10 = new Case();
        callCaseb10.Category__c = 'Banana GAP10: Agro-inputs';
        callCaseb10.Person__c = testPerson.Id;
        cases.add(callCaseb10);
        
        //coffee
        Case callCasec1 = new Case();
        callCasec1.Category__c = 'Coffee GAP1: Soil Fertility';
        callCasec1.Person__c = testPerson.Id;
        cases.add(callCasec1);
        
        Case callCasec2 = new Case();
        callCasec2.Category__c = 'Coffee GAP2: Desuckering, Pruning';
        callCasec2.Person__c = testPerson.Id;
        cases.add(callCasec2);
        
        Case callCasec3 = new Case();
        callCasec3.Category__c = 'Coffee GAP3: Soil and Water Conservation';
        callCasec3.Person__c = testPerson.Id;
        cases.add(callCasec3);
        
        Case callCasec4 = new Case();
        callCasec4.Category__c = 'Coffee GAP4: Value Addition';
        callCasec4.Person__c = testPerson.Id;
        cases.add(callCasec4);
        
        Case callCasec5 = new Case();
        callCasec5.Category__c = 'Coffee GAP5: Record Keeping';
        callCasec5.Person__c = testPerson.Id;
        cases.add(callCasec5);
        
        Case callCasec6 = new Case();
        callCasec6.Category__c = 'Coffee GAP6: Group Production/ Marketing';
        callCasec6.Person__c = testPerson.Id;
        cases.add(callCasec6);
        
        Case callCasec7 = new Case();
        callCasec7.Category__c = 'Coffee GAP7: Weed Control';
        callCasec7.Person__c = testPerson.Id;
        cases.add(callCasec7);
        
        Case callCasec8 = new Case();
        callCasec8.Category__c = 'Coffee GAP8: Pests and Disease';
        callCasec8.Person__c = testPerson.Id;
        cases.add(callCasec8);
        
        Case callCasec9 = new Case();
        callCasec9.Category__c = 'Coffee GAP9: Processing';
        callCasec9.Person__c = testPerson.Id;
        cases.add(callCasec9);
        
        Case callCasec10 = new Case();
        callCasec10.Category__c = 'Coffee GAP10: Agro-inputs';
        callCasec10.Person__c = testPerson.Id;
        cases.add(callCasec10);
        
        //maize
        Case callCasem1 = new Case();
        callCasem1.Category__c = 'Maize GAP1: Land Preparation';
        callCasem1.Person__c = testPerson.Id;
        cases.add(callCasem1);
        
        Case callCasem2 = new Case();
        callCasem2.Category__c = 'Maize GAP2: Proper Planting';
        callCasem2.Person__c = testPerson.Id;
        cases.add(callCasem2);
        
        Case callCasem3 = new Case();
        callCasem3.Category__c = 'Maize GAP3: Seed Selection';
        callCasem3.Person__c = testPerson.Id;
        cases.add(callCasem3);
        
        Case callCasem4 = new Case();
        callCasem4.Category__c = 'Maize GAP4: Soil Fertility Management';
        callCasem4.Person__c = testPerson.Id;
        cases.add(callCasem4);
        
        Case callCasem5 = new Case();
        callCasem5.Category__c = 'Maize GAP5: Pest and Disease';
        callCasem5.Person__c = testPerson.Id;
        cases.add(callCasem5);
        
        Case callCasem6 = new Case();
        callCasem6.Category__c = 'Maize GAP6: Harvesting';
        callCasem6.Person__c = testPerson.Id;
        cases.add(callCasem6);
        
        Case callCasem7 = new Case();
        callCasem7.Category__c = 'Maize GAP7: Harvesting';
        callCasem7.Person__c = testPerson.Id;
        cases.add(callCasem7);
        
        Case callCasem8 = new Case();
        callCasem8.Category__c = 'Maize GAP8: Record Keeping';
        callCasem8.Person__c = testPerson.Id;
        cases.add(callCasem8);
        
        insert cases;
        
        insert new X3_0_Top_GAPs__c(Crop__c = 'Coffee', Month__c = date.today().toStartOfMonth(), Gap__c = 'Coffee GAP9: Processing');
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsCalls(), 50);
        Test.stopTest();
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, Call_center__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth() AND Crop__c = 'Banana'];
        
        System.assert(stats.size() == 10);
        System.assert(stats.get(0).Call_center__c == 1);
        System.assert(stats.get(9).Call_center__c == 1);
        
        Integer coffeGaps = Database.countQuery('SELECT COUNT() FROM X3_0_Top_GAPs__c WHERE Crop__c = \'Coffee\'');
        Integer maizeGaps = Database.countQuery('SELECT COUNT() FROM X3_0_Top_GAPs__c WHERE Crop__c = \'Maize\'');
        System.assert(coffeGaps == 10);
        System.assert(maizeGaps == 8);
    } 
    
    static testMethod void testCompileGapsDiscussionsFarmerMeetingsBanana() {
    
        Country__c country = new Country__c(
            Name = 'Uganda',
            ISO_Standard_Code__c = 'UG'
        );
        insert country;
        
        Contact contact = new Contact(
            LastName = 'Peter'
        );
        insert contact;
        
        Person__c person = new Person__c(
            First_Name__c = 'Bani'
        );
        insert person;
        
        Focus_Farmer__c ffarmer = new Focus_Farmer__c(
            Person__c = person.Id,
            Farmer_Type__c = 'Banana'
        );
        insert ffarmer;
        
        Banana_Farmer__c bfarmer = new Banana_Farmer__c(
            Focus_Farmer__c = ffarmer.Id,
            Registered_By__c = contact.Id
        );
        insert bfarmer;
        
        Banana_Cluster_Meeting__c meeting = new Banana_Cluster_Meeting__c(
            Banana_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Meeting_Date__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 1: Soil fertility management;GAP 2: Pruning desuckering etc;GAP 3: Soil and water conservation;GAP 4: Support for banana plants;GAP 5: Proper record keeping;GAP 6: Group production and marketing;GAP 7: Proper and timely weed control'
        );
        insert meeting;
        Banana_Cluster_Meeting__c meeting1 = new Banana_Cluster_Meeting__c(
            Banana_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Meeting_Date__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 8: Banana pests and disease control;GAP 9: Banana value addition;GAP 10: Easily access agro-inputs'
        );
        insert meeting1;        
        
        insert new X3_0_Top_GAPs__c(Crop__c = 'Banana', Month__c = date.today().toStartOfMonth(), Gap__c = 'Banana GAP1: Soil fertility management', Farmer_group_meetings__c = 1);
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings('SELECT What_GAPs_were_discussed_at_the_meeting__c, Meeting_Date__c FROM Banana_Cluster_Meeting__c', 'Banana'), 50);
        Test.stopTest();    
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth() AND Crop__c = 'Banana'];
        X3_0_Top_GAPs__c updatedstat = [SELECT Id, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Gap__c LIKE 'Banana GAP1:%'];
        System.assert(updatedstat.Farmer_group_meetings__c == 1);
        
        System.assert(stats.size() == 10);
        System.assert(stats.get(9).Farmer_group_meetings__c > 0);    
    }
    
    static testMethod void testCompileGapsDiscussionsFarmerMeetingsCoffee() {
    
        Country__c country = new Country__c(
            Name = 'Uganda',
            ISO_Standard_Code__c = 'UG'
        );
        insert country;
        
        Contact contact = new Contact(
            LastName = 'Peter'
        );
        insert contact;
        
        Person__c person = new Person__c(
            First_Name__c = 'Bani'
        );
        insert person;
        
        Focus_Farmer__c ffarmer = new Focus_Farmer__c(
            Person__c = person.Id,
            Farmer_Type__c = 'Coffee'
        );
        insert ffarmer;
        
        Coffee_Farmer__c bfarmer = new Coffee_Farmer__c(
            Focus_Farmer__c = ffarmer.Id,
            Registered_By__c = contact.Id
        );
        insert bfarmer;
        
        Coffee_Cluster_Meeting__c meeting = new Coffee_Cluster_Meeting__c(
            Coffee_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Please_add_the_date_of_the_meeting__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 1: Soil fertility management;GAP 2: Desuckering pruning and stumping;GAP 3: Soil and water conservation;GAP 4: On farm coffee value addition;GAP 5: Proper farm record keeping;GAP 6: Group production/ marketing;GAP 7: Proper and timely weed control'
        );
        insert meeting;
        //meeting.What_GAPs_were_discussed_at_the_meeting__c = 'GAP 1: Soil fertility management, GAP 2: Desuckering pruning and stumping, GAP 3: Soil and water conservation, GAP 4: On farm coffee value addition, GAP 5: Proper farm record keeping, GAP 6: Group production/ marketing, GAP 7: Proper and timely weed control';
        //update meeting;
        
        Coffee_Cluster_Meeting__c meeting1 = new Coffee_Cluster_Meeting__c(
            Coffee_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Please_add_the_date_of_the_meeting__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 8: Coffee pests and disease control;GAP 9: Coffee processing;GAP 10: Easily access agro-inputs'
        );
        insert meeting1;  
        //meeting1.What_GAPs_were_discussed_at_the_meeting__c = 'GAP 8: Coffee pests and disease control;GAP 9: Coffee processing;GAP 10: Easily access agro-inputs';
        //update meeting1;              
        
        insert new X3_0_Top_GAPs__c(Crop__c = 'Coffee', Month__c = date.today().toStartOfMonth(), Gap__c = 'Coffee GAP1: Soil fertility management', Farmer_group_meetings__c = 1);
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings('SELECT What_GAPs_were_discussed_at_the_meeting__c, Please_add_the_date_of_the_meeting__c FROM Coffee_Cluster_Meeting__c', 'Coffee'), 50);
        Test.stopTest();    
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth() AND Crop__c = 'Coffee'];
        X3_0_Top_GAPs__c updatedstat = [SELECT Id, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Gap__c LIKE 'Coffee GAP1:%'];
        System.assert(updatedstat.Farmer_group_meetings__c == 1);
        
        System.assert(stats.size() == 10);
        System.assert(stats.get(9).Farmer_group_meetings__c > 0);    
    }    
    
    static testMethod void testCompileGapsDiscussionsFarmerMeetingsMaize() {
    
        Country__c country = new Country__c(
            Name = 'Uganda',
            ISO_Standard_Code__c = 'UG'
        );
        insert country;
        
        Contact contact = new Contact(
            LastName = 'Peter'
        );
        insert contact;
        
        Person__c person = new Person__c(
            First_Name__c = 'Bani'
        );
        insert person;
        
        Focus_Farmer__c ffarmer = new Focus_Farmer__c(
            Person__c = person.Id,
            Farmer_Type__c = 'Maize'
        );
        insert ffarmer;
        
        Maize_Farmer__c bfarmer = new Maize_Farmer__c(
            Focus_Farmer__c = ffarmer.Id,
            Registered_By__c = contact.Id
        );
        insert bfarmer;
        
        Maize_Cluster_Meeting__c meeting = new Maize_Cluster_Meeting__c(
            Maize_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Meeting_Date__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 1: Proper and timely land prep;GAP 2: Proper planting;GAP 3: Proper seed selection;GAP 4: Proper soil fertility management'
        );
        insert meeting;
        Maize_Cluster_Meeting__c meeting1 = new Maize_Cluster_Meeting__c(
            Maize_Farmer__c = bfarmer.Id,
            Contact__c = contact.Id,
            Meeting_Date__c = date.today(),
            What_GAPs_were_discussed_at_the_meeting__c = 'GAP 5: Pest and disease identification;GAP 6: Harvesting and post-harvest;GAP 7: Bulking marketing;GAP 8: Proper record keeping'
        );
        insert meeting1;        
        
        insert new X3_0_Top_GAPs__c(Crop__c = 'Maize', Month__c = date.today().toStartOfMonth(), Gap__c = 'Maize GAP6: Harvesting and post-harvest', Farmer_group_meetings__c = 1);
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings('SELECT What_GAPs_were_discussed_at_the_meeting__c, Meeting_Date__c FROM Maize_Cluster_Meeting__c', 'Maize'), 50);
        Test.stopTest();    
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth() AND Crop__c = 'Maize'];
        X3_0_Top_GAPs__c updatedstat = [SELECT Id, Farmer_group_meetings__c FROM X3_0_Top_GAPs__c WHERE Gap__c LIKE 'Maize GAP6:%'];
        System.assert(updatedstat.Farmer_group_meetings__c == 1);
        
        System.assert(stats.size() == 8);
        System.assert(stats.get(7).Farmer_group_meetings__c > 0);    
    }    
    
    static testMethod void testCompileGapsDiscussionsSearchLogs() {
        
        Person__c person = new Person__c(First_Name__c = 'Bani');
        insert person;
        Person__c person1 = new Person__c(First_Name__c = 'John');
        insert person1;
        
        List<String> queries = new List<String>{
            // banana search logs queries
            'Banana Gaps GAP 1:Soil fertility management Organic Fertilizers Organic manure application',
            'Banana Gaps GAP 1:Soil fertility management Chemical/ inorganic Fertilizers',
            'Banana Gaps GAP 2:Prunning, de suckering, de-leafing, removal of corm and pseudo stems De suckering',
            'Banana Gaps GAP 3:Soil and water conservation Mulching',
            'Banana Gaps GAP 4:Providing support for banana plants',
            'Banana Gaps GAP 5:Proper record keeping importance of record keeping',
            'Banana Gaps GAP 6:Group production and marketing',
            'Banana Gaps GAP 7:Proper and timely weed control Weed control methods Hand /hand hoe Weeding',
            'Banana Gaps GAP 8:Banana pests and disease control Banana diseases and their control Banana bacterial wilt-BBW (Some bananas becoming ripe on young bunch dull green yellow leaves, male flowers drying and shrinking)',
            'Banana Gaps GAP 9:Banana value addition',
            'Banana Gaps GAP 10:Easily access agro-inputs',
            // coffee            
            'Coffee Gaps Gap 1: SOIL FERTILITY MANAGEMENT. Fertilizer application program',
            'Coffee Gaps Gap 2: Coffee de-suckering, pruning and stumping Coffee Pruning',
            'Coffee Gaps GAP 3: Soil and water conservation Contour trenches how to make contours',
            'Coffee Gaps Gap 4:On-farm coffee value addition drying, sorting, grading, bagging,packing and storage ?    Storage',
            'Coffee Gaps Gap 5:Coffee farm record keeping importance of record keeping',
            'Coffee Gaps Gap 6:Group approach to coffee production and marketing',
            'Coffee Gaps Gap 7:proper and timely weed control Chemical weed control',
            'Coffee Gaps Gap 8; Coffee pests and diseases coffee disease of arabica Coffee berry disease',
            'Coffee Gaps Gap 9:coffee processing Wet processing of Arabica coffee',
            'Coffee Gaps GAP 10:Easily access agro-inputs',
            // maize
            'Maize GAPs GAP 1: Proper and timely land preparation 1.Method of land preparation',
            'Maize GAPs GAP 2: Proper planting 2. Spacing and seed rate',
            'Maize GAPs GAP 3: Proper seed selection 2.Selection of own saved or local seed for planting',
            'Maize GAPs GAP 4: Proper soil fertility management 1.Means of soil fertilization (kind of fertilizers used)',
            'Maize GAPs Gap 5:Pest and disease control Common diseases of maize Maize rust',
            'Maize GAPs Gap 6:maize harvesting and post harvest handling Post-harvest handling (Drying, shelling, storage, sorting and grading) Shelling',
            'Maize GAPs Gap 7: Maize marketing',
            'Maize GAPs Gap 8:record keeping Types of records 2.    Input record'
        };
        
        // self search. should be ignored
        Search_Log__c log = new Search_Log__c();
        log.Interviewer__c = person.id;
        log.Interviewee__c = person.Id;
        log.Server_Entry_Time__c = Datetime.now();
        log.Handset_Submit_Time__c = Datetime.now();
        log.Submission_GPS_Timestamp__c = Datetime.now();
        log.Query__c = 'Banana Gaps GAP 1:Soil fertility management Chemical/ inorganic Fertilizers';
        log.Category__c = 'Banana Gaps';
        insert log;
        
        List<Search_Log__c> logs = new List<Search_Log__c>();
        for (Integer i = 0; i < queries.size(); i++) {
            Search_Log__c log1 = new Search_Log__c();
            log1.Interviewer__c = person.id;
            log1.Interviewee__c = person1.Id;
            log1.Server_Entry_Time__c = Datetime.now();
            log1.Handset_Submit_Time__c = Datetime.now();
            log1.Submission_GPS_Timestamp__c = Datetime.now();
            log1.Query__c = queries.get(i);
            if(i <= 10 ) {
                log1.Category__c = 'Banana Gaps';
            }
            else if(i <= 20) {
                log1.Category__c = 'Coffee Gaps';
            }
            else {
                log1.Category__c = 'Maize Gaps';
            }
            logs.add(log1);
        }
        insert logs;
        
        insert new X3_0_Top_GAPs__c(Crop__c = 'Banana', Month__c = date.today().toStartOfMonth(), Gap__c = 'Banana GAP1: Soil fertility management', Ckw_searches__c = 1);
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsSearchLogs(), 50);
        Test.stopTest();    
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, Ckw_searches__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth()];
        X3_0_Top_GAPs__c updatedstat = [SELECT Id, Ckw_searches__c FROM X3_0_Top_GAPs__c WHERE Gap__c LIKE 'Banana GAP1:%'];
        System.assert(updatedstat.Ckw_searches__c == 2);
        
        System.assert(stats.size() == 28);
        System.assert(stats.get(27).Ckw_searches__c > 0);  

    }
    
    static testMethod void testCompileGapsDiscussionsSms() {
        List<String> gaps = new List<String>{
            'Banana GAP1: Soil Fertility',
            'Banana GAP2: Desuckering, Pruning',
            'Banana GAP3: Soil and Water Conservation',
            'Banana GAP4: Support for Banana Plants',
            'Banana GAP5: Record Keeping',
            'Banana GAP6: Group Production, Marketing',
            'Banana GAP7: Weed Control',
            'Banana GAP8: Pests and Disease',
            'Banana GAP9: Value Addition',
            'Banana GAP10: Agro-inputs',
            'Coffee GAP1: Soil Fertility',
            'Coffee GAP2: Desuckering, Pruning',
            'Coffee GAP3: Soil and Water Conservation',
            'Coffee GAP4: Value Addition',
            'Coffee GAP5: Record Keeping',
            'Coffee GAP6: Group Production/ Marketing',
            'Coffee GAP7: Weed Control',
            'Coffee GAP8: Pests and Disease',
            'Coffee GAP9: Processing',
            'Coffee GAP10: Agro-inputs',
            'Maize GAP1: Land Preparation',
            'Maize GAP2: Proper Planting',
            'Maize GAP3: Seed Selection',
            'Maize GAP4: Soil Fertility Management',
            'Maize GAP5: Pest and Disease',
            'Maize GAP6: Harvesting',
            'Maize GAP7: Bulking Marketing',
            'Maize GAP8: Record Keeping'
        };
        List<Message__c> messages = new List<Message__c>();
        for(String gap : gaps) {
            Message__c msge = new Message__c(
                Category__c = gap,
                Type__c = 'SMS',
                Subject__c = 'test'
            );
            messages.add(msge);
        }
        insert messages;
        insert new X3_0_Top_GAPs__c(Crop__c = 'Banana', Month__c = date.today().toStartOfMonth(), Gap__c = 'Banana GAP1: Soil Fertility', SMS__c = 1);
        
        Test.startTest();
        Database.executeBatch(new CompileGapsDiscussionsSms(), 50);
        Test.stopTest();    
        
        List<X3_0_Top_GAPs__c> stats = [SELECT Id, Crop__c, GAP__c, SMS__c FROM X3_0_Top_GAPs__c WHERE Month__c =: date.today().toStartOfMonth()];
        X3_0_Top_GAPs__c updatedstat = [SELECT Id, SMS__c FROM X3_0_Top_GAPs__c WHERE Gap__c LIKE 'Banana GAP1:%'];
        System.assert(updatedstat.SMS__c == 1);
        
        System.assert(stats.size() == 28);
        System.assert(stats.get(27).SMS__c > 0);
    }
    
    static testMethod void testCompileGapsDiscussionsScheduling() {
        Test.startTest();
        String jobId = System.schedule('CompileGapsDiscussionsScheduling', '0 0 4 * * ?', new CompileGapsDiscussionsScheduler());   
        Test.stopTest();   
    }
    
    static testMethod void testCompileGapsDiscussionsScheduling2() {
        Test.startTest();
        String jobId = System.schedule('CompileGapsDiscussionsScheduling2', '0 0 4 * * ?', new CompileGapsDiscussionsScheduler2());   
        Test.stopTest();   
    }
}