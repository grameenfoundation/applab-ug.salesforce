@isTest
public class cooperative_AreaFarmersChartTest {

    static Country__c country;
    static Contact contact1;
    static LAC_Cooperative__c cooperative;
    static LAC_Farmer_Details__c farmer1;
    static LAC_Farmer_Details__c farmer2;
    static cooperative_AreaFarmersChart coopArea;

    /**
    * Create the objects needed to run the tests.
    * This includes:
    *    - One cooperative
    *    - Two LAC_Farmer_Details__c 
    *    
    */
    private static void prepareTest() {
            
        country = new Country__c(
            Name = 'country1',
            ISO_Standard_Code__c = 'COL'
        );
        insert country;
        
        contact1 = new Contact(
            LastName = 'lastname1'
        );
        Insert contact1;
        
        cooperative = new LAC_Cooperative__c(
            Name = 'coop1'
        );
        insert cooperative;
        
        farmer1 = new LAC_Farmer_Details__c(
            Name = 'farm1', 
            Farm_Area__c = 2
        );
        farmer1.cooperativeProfile__c = cooperative.Id;
        farmer1.Contact__c = contact1.Id;
        insert farmer1;
        
        farmer2 = new LAC_Farmer_Details__c(
            Name = 'farm2', 
            Farm_Area__c = 4
        );
        farmer2.cooperativeProfile__c = cooperative.Id;
        farmer2.Contact__c = contact1.Id;
        insert farmer2;
    }
    
    /**
    * Test amount of points to draw and maximum farm area 
    *
    */
    static testMethod void testGetFarmArea() {
        prepareTest();
        //validate farmers y cooperative created
        System.assertEquals(2, database.countquery('SELECT COUNT() FROM LAC_Farmer_Details__c'));
        System.assertEquals(1, database.countquery('SELECT COUNT() FROM LAC_Cooperative__c '));
        //validate farmers with assigned cooperative
        System.assertEquals(2, database.countquery('SELECT COUNT() FROM LAC_Farmer_Details__c where cooperativeProfile__c <> null '));
        coopArea = new cooperative_AreaFarmersChart(null);
        coopArea.cooperativeProp = cooperative;
        coopArea.getMaxFarmArea();
        //validate max farm area
        System.assertEquals(4.0, coopArea.maxFarmArea);
        //validate quantity of farms areas related to cooperative
        System.assertEquals(2, coopArea.getAreaFarmers().size());
        //validate amount of points to draw (barSerieData)
        System.assertEquals(5, coopArea.getCategories().size());
    }

}