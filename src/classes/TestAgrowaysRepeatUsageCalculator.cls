@isTest
public class TestAgrowaysRepeatUsageCalculator {

    static TestMethod void testAgrowaysRepeatUsage() {
    
        M_E_Metric__c repeatUsage = new M_E_Metric__c(Name='Agroways Repeat Usage');
        repeatUsage.Label__c = 'Agroways Repeat Usage';
        insert repeatUsage;
        M_E_Metric_Data__c rptData = new M_E_Metric_Data__c();
        rptData.Actual_Value__c = 0.0;
        rptData.M_E_Metric__c = repeatUsage.Id;
        rptData.Date__c = date.today().addMonths(-1).toStartOfMonth();
        insert rptData;

        Group__c agrowaysGroup = new Group__c(Name='Agroways VACs');
        insert agrowaysGroup;
        Person__c agrowaysCkw = new Person__c();
        agrowaysCkw.First_Name__c = 'Agro';
        agrowaysCkw.Last_Name__c = 'Ways';
        insert agrowaysCkw;
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Person__c = agrowaysCkw.Id;
        pga.Group__c = agrowaysGroup.Id;
        insert pga;

        // Create some farmers
        Person__c person1 = new Person__c();
        person1.First_Name__c = 'p1';
        insert person1;
        Farmer__c farmer1 = new Farmer__c(Name='UGR123');
        farmer1.Person__c = person1.Id;
        farmer1.Crops__c = 'Maize;Beans';
        farmer1.Registered_By__c = agrowaysCkw.Id;
        farmer1.Registered_Date__c = date.today().addMonths(-1);
        insert farmer1;

        Person__c person2 = new Person__c();
        person2.First_Name__c = 'p2';
        insert person2;
        Farmer__c farmer2 = new Farmer__c(Name='UGR124');
        farmer2.Person__c = person2.Id;
        farmer2.Crops__c = 'Maize';
        farmer2.Registered_By__c = agrowaysCkw.Id;
        farmer2.Registered_Date__c = date.today().addMonths(-1);
        insert farmer2;

        // Create some search logs
        Search_Log__c searchLog1 = new Search_Log__c();
        searchLog1.Interviewee__c = person1.Id;
        searchLog1.Interviewer__c = agrowaysCkw.Id;
        searchLog1.Handset_Submit_Time__c = date.today().addMonths(-1);
        searchLog1.Handset_Submit_Time__c = date.today().addMonths(-1);
        insert searchLog1;

        Search_Log__c searchLog2 = new Search_Log__c();
        searchLog2.Interviewee__c = person1.Id;
        searchLog2.Interviewer__c = agrowaysCkw.Id;
        searchLog2.Handset_Submit_Time__c = date.today().addMonths(-1);
        searchLog2.Server_Entry_Time__c = date.today().addMonths(-1);
        insert searchLog2;

        Search_Log__c searchLog3 = new Search_Log__c();
        searchLog3.Interviewee__c = person2.Id;
        searchLog3.Interviewer__c = agrowaysCkw.Id;
        searchLog3.Handset_Submit_Time__c = date.today().addMonths(-1);
        searchLog3.Server_Entry_Time__c = date.today().addMonths(-1);
        insert searchLog3;

        Search_Log__c searchLog4 = new Search_Log__c();
        searchLog4.Interviewee__c = person2.Id;
        searchLog4.Interviewer__c = agrowaysCkw.Id;
        searchLog4.Handset_Submit_Time__c = date.today().addMonths(-1);
        searchLog4.Server_Entry_Time__c = date.today().addMonths(-1);
        insert searchLog4;

        test.startTest();
        String farmerQuery =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Person__c, '           +
                'Person__r.Gender__c, ' +
                'Person__r.Village__c ' +
            'FROM '                     +
                'Farmer__c '            +
            'WHERE '                    +
                'Person__r.First_Name__c != \'Not Registered\' ' +
                'AND Name LIKE \'U%\' ' +
                ' AND Performance_Date__c = LAST_MONTH' +
                ' AND Registered_By__c IN (SELECT ' +
                ' Person__c FROM Person_Group_Association__c ' +
                'WHERE group__r.Name = \'Agroways VACs\')';

        ID batchprocessid = Database.executeBatch(new AgrowaysRepeatUsageCalculator(farmerQuery));
        test.stopTest();
    }
}