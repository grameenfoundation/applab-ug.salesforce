@isTest
public class MisSubcountyMarketPricesTest {
    static testMethod void testValidateMasindiGPSWithinRange() {
        Market_Masindi__c mrktM=new Market_Masindi__c();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktM.GPS_Location__Latitude__s=2;
        mrktM.GPS_Location__Longitude__s=3;        
        system.assert(MisSubcountyMarketPrices.applyMasindiGPSValidation(mrktM,c3po));        
    }
    
    static testMethod void testValidateMasindiGPSOutOfRange() {
        Market_Masindi__c mrktM=new Market_Masindi__c();
        C3P0_Market__c c3po=new C3P0_Market__c();        
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktM.GPS_Location__Latitude__s=3;
        mrktM.GPS_Location__Longitude__s=3;
        system.assertEquals(false, MisSubcountyMarketPrices.applyMasindiGPSValidation(mrktM,c3po));
    }
    
    static testMethod void testValidateKaseseGPSWithinRange() {
        Market_Kasese__c mrktK=new Market_Kasese__c();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktK.GPS_Location__Latitude__s=2;
        mrktK.GPS_Location__Longitude__s=3;        
        system.assert(MisSubcountyMarketPrices.applyKaseseGPSValidation(mrktK,c3po));        
    }
    
    static testMethod void testValidateKaseseGPSOutOfRange() {
        Market_Kasese__c mrktK=new Market_Kasese__c();
        C3P0_Market__c c3po=new C3P0_Market__c();        
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktK.GPS_Location__Latitude__s=3;
        mrktK.GPS_Location__Longitude__s=3;
        system.assertEquals(false, MisSubcountyMarketPrices.applyKaseseGPSValidation(mrktK,c3po));
    }
    
    static testMethod void testValidateBushenyiGPSWithinRange() {        
        Market_Bushenyi__c mrktB=new Market_Bushenyi__c();
        C3P0_Market__c c3po=new C3P0_Market__c();
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktB.GPS_Location__Latitude__s=2;
        mrktB.GPS_Location__Longitude__s=3;        
        system.assert(MisSubcountyMarketPrices.applyBushenyiGPSValidation(mrktB,c3po));        
    }
    
    static testMethod void testValidateBushenyiGPSOutOfRange() {
        Market_Bushenyi__c mrktB=new Market_Bushenyi__c();
        C3P0_Market__c c3po=new C3P0_Market__c();        
        c3po.Market_Size__c=300;
        c3po.Market_Gps__Latitude__s=2;
        c3po.Market_Gps__Longitude__s=3; 
        mrktB.GPS_Location__Latitude__s=3;
        mrktB.GPS_Location__Longitude__s=3;
        system.assertEquals(false, MisSubcountyMarketPrices.applyBushenyiGPSValidation(mrktB,c3po));
    }
         
    static testMethod void masindiMaizeAveragePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Maize__c maizeMasindi = new X3_0_Masindi_Maize__c();
        maizeMasindi.Name_of_trader_in_Maize__c = 'Gabula';
        maizeMasindi.A_Kg_of_Mazie_grain_at_retail_price__c = 1500;
        maizeMasindi.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c =  YESTERDAY LIMIT 1].Id;
        insert maizeMasindi;
        
        X3_0_Masindi_Maize__c maizeMasindi1 = new X3_0_Masindi_Maize__c();
        maizeMasindi1.Name_of_trader_in_Maize__c = 'Gabula1';
        maizeMasindi1.A_Kg_of_Mazie_grain_at_retail_price__c = 1200;
        maizeMasindi1.A_Kg_of_Mazie_grain_at_wholesale_price__c = 900;
        maizeMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c =  YESTERDAY LIMIT 1].Id;
        insert maizeMasindi1;
        
        X3_0_Masindi_Maize__c maizeMasindi2 = new X3_0_Masindi_Maize__c();
        maizeMasindi2.Name_of_trader_in_Maize__c = 'Gabula2';
        maizeMasindi2.A_Kg_of_Mazie_grain_at_retail_price__c = 1800;
        maizeMasindi2.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c =  YESTERDAY LIMIT 1].Id;
        insert maizeMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Maize';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Maize'];
                
        MisSubcountyMarketPrices.computeMasindiMaizePriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Maize' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiSunflowerAveragePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Sunflower__c sunflowerMasindi = new X3_0_Masindi_Sunflower__c();
        sunflowerMasindi.Name_of_trader_in_Sunflower__c = 'Gabula';
        sunflowerMasindi.A_Kg_of_Sunflower_at_retail_price__c = 1500;
        sunflowerMasindi.A_Kg_of_Sunflower_at_wholesale_price__c = 1200;
        sunflowerMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sunflowerMasindi;
        
        X3_0_Masindi_Sunflower__c sunflowerMasindi1 = new X3_0_Masindi_Sunflower__c();
        sunflowerMasindi1.Name_of_trader_in_Sunflower__c = 'Gabula1';
        sunflowerMasindi1.A_Kg_of_Sunflower_at_retail_price__c = 1200;
        sunflowerMasindi1.A_Kg_of_Sunflower_at_wholesale_price__c = 900;
        sunflowerMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sunflowerMasindi1;
        
        X3_0_Masindi_Sunflower__c sunflowerMasindi2 = new X3_0_Masindi_Sunflower__c();
        sunflowerMasindi2.Name_of_trader_in_Sunflower__c = 'Gabula2';
        sunflowerMasindi2.A_Kg_of_Sunflower_at_retail_price__c= 1800;
        sunflowerMasindi2.A_Kg_of_Sunflower_at_wholesale_price__c = 1200;
        sunflowerMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sunflowerMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Sunflower';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Sunflower'];
                
        MisSubcountyMarketPrices.computeMasindiSunflowerPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Sunflower' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiCassavaPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Cassava__c cassavaMasindi = new X3_0_Masindi_Cassava__c();
        cassavaMasindi.Name_of_trader_in_Cassava__c = 'Gabula';
        cassavaMasindi.A_Kg_of_fresh_Cassava_at_retail_price__c = 1500;
        cassavaMasindi.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 1200;
        cassavaMasindi.Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaMasindi;
        
        X3_0_Masindi_Cassava__c cassavaMasindi1 = new X3_0_Masindi_Cassava__c();
        cassavaMasindi1.Name_of_trader_in_Cassava__c = 'Gabula1';
        cassavaMasindi1.A_Kg_of_fresh_Cassava_at_retail_price__c = 1200;
        cassavaMasindi1.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 900;
        cassavaMasindi1.Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaMasindi1;
        
        X3_0_Masindi_Cassava__c cassavaMasindi2 = new X3_0_Masindi_Cassava__c();
        cassavaMasindi2.Name_of_trader_in_Cassava__c = 'Gabula2';
        cassavaMasindi2.A_Kg_of_fresh_Cassava_at_retail_price__c = 1800;
        cassavaMasindi2.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 1200;
        cassavaMasindi2.Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Cassava';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Cassava'];
                
        MisSubcountyMarketPrices.computeMasindiCassavaPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Cassava' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiK132PricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_K132_Beans__c k132Masindi = new X3_0_Masindi_K132_Beans__c();
        k132Masindi.Name_of_trader_in_K132_beans__c = 'Gabula';
        k132Masindi.A_Kg_of_K132_beans_at_retail_price__c = 1500;
        k132Masindi.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        k132Masindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert k132Masindi;
        
        X3_0_Masindi_K132_Beans__c k132Masindi1 = new X3_0_Masindi_K132_Beans__c();
        k132Masindi1.Name_of_trader_in_K132_beans__c = 'Gabula1';
        k132Masindi1.A_Kg_of_K132_beans_at_retail_price__c = 1200;
        k132Masindi1.A_Kg_of_K132_beans_at_wholesale_price__c = 900;
        k132Masindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert k132Masindi1;
        
        X3_0_Masindi_K132_Beans__c k132Masindi2 = new X3_0_Masindi_K132_Beans__c();
        k132Masindi2.Name_of_trader_in_K132_beans__c = 'Gabula2';
        k132Masindi2.A_Kg_of_K132_beans_at_retail_price__c = 1800;
        k132Masindi2.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        k132Masindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert k132Masindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'K132 Beans';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='K132 Beans'];
                
        MisSubcountyMarketPrices.computeMasindiKBeansPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'K132 Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiNambaleBeansPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Nambale_Beans__c nambaleBeansMasindi = new X3_0_Masindi_Nambale_Beans__c();
        nambaleBeansMasindi.Name_of_trader_in_dry_nambale_beans__c = 'Gabula';
        nambaleBeansMasindi.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1500;
        nambaleBeansMasindi.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 1200;
        nambaleBeansMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBeansMasindi;
        
        X3_0_Masindi_Nambale_Beans__c nambaleBeansMasindi1 = new X3_0_Masindi_Nambale_Beans__c();
        nambaleBeansMasindi1.Name_of_trader_in_dry_nambale_beans__c = 'Gabula1';
        nambaleBeansMasindi1.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1200;
        nambaleBeansMasindi1.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 900;
        nambaleBeansMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBeansMasindi1;
        
        X3_0_Masindi_Nambale_Beans__c nambaleBeansMasindi2 = new X3_0_Masindi_Nambale_Beans__c();
        nambaleBeansMasindi2.Name_of_trader_in_dry_nambale_beans__c = 'Gabula2';
        nambaleBeansMasindi2.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1800;
        nambaleBeansMasindi2.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 1200;
        nambaleBeansMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBeansMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Dry Nambale Beans';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Dry Nambale Beans'];
                
        MisSubcountyMarketPrices.computeMasindiNambaleBeansPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Dry Nambale Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiSweetPotatoesPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Sweet_Potatoes__c sweetPotatoesMasindi = new X3_0_Masindi_Sweet_Potatoes__c();
        sweetPotatoesMasindi.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula';
        sweetPotatoesMasindi.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1500;
        sweetPotatoesMasindi.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 1200;
        sweetPotatoesMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesMasindi;
        
        X3_0_Masindi_Sweet_Potatoes__c sweetPotatoesMasindi1 = new X3_0_Masindi_Sweet_Potatoes__c();
        sweetPotatoesMasindi1.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula1';
        sweetPotatoesMasindi1.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1200;
        sweetPotatoesMasindi1.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 900;
        sweetPotatoesMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesMasindi1;
        
        X3_0_Masindi_Sweet_Potatoes__c sweetPotatoesMasindi2 = new X3_0_Masindi_Sweet_Potatoes__c();
        sweetPotatoesMasindi2.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula2';
        sweetPotatoesMasindi2.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1800;
        sweetPotatoesMasindi2.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 1200;
        sweetPotatoesMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Sweet Potatoes';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Sweet Potatoes'];
                
        MisSubcountyMarketPrices.computeMasindiSweetPotatoesPriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Sweet Potatoes' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiBananaPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Banana__c bananaMasindi = new X3_0_Masindi_Banana__c();
        bananaMasindi.Name_of_the_trader_in_banana__c = 'Gabula';
        bananaMasindi.A_bunch_of_bananas_at_retail_price__c = 1500;
        bananaMasindi.A_bunch_of_bananas_at_wholesale_price__c = 1200;
        bananaMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaMasindi;
        
        X3_0_Masindi_Banana__c bananaMasindi1 = new X3_0_Masindi_Banana__c();
        bananaMasindi1.Name_of_the_trader_in_banana__c = 'Gabula1';
        bananaMasindi1.A_bunch_of_bananas_at_retail_price__c = 1200;
        bananaMasindi1.A_bunch_of_bananas_at_wholesale_price__c = 900;
        bananaMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaMasindi1;
        
        X3_0_Masindi_Banana__c bananaMasindi2 = new X3_0_Masindi_Banana__c();
        bananaMasindi2.Name_of_the_trader_in_banana__c = 'Gabula2';
        bananaMasindi2.A_bunch_of_bananas_at_retail_price__c = 1800;
        bananaMasindi2.A_bunch_of_bananas_at_wholesale_price__c = 1200;
        bananaMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaMasindi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Banana';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Banana'];
                
        MisSubcountyMarketPrices.computeMasindiBananaAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Banana' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void masindiCoffeePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = yesterday LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Masindi__c marketXMasindi = new Market_Masindi__c();
        marketXMasindi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXMasindi.GPS_Location__Latitude__s = 0.337352;
        marketXMasindi.GPS_Location__Longitude__s = 32.600415;
        marketXMasindi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXMasindi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXMasindi;
        
        X3_0_Masindi_Robusta_Coffee__c coffeeMasindi = new X3_0_Masindi_Robusta_Coffee__c();
        coffeeMasindi.Name_of_trader_in_Robusta_coffee__c = 'Gabula';
        coffeeMasindi.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1500;
        coffeeMasindi.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeMasindi.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeMasindi;
        
        X3_0_Masindi_Robusta_Coffee__c coffeeMasindi1 = new X3_0_Masindi_Robusta_Coffee__c();
        coffeeMasindi1.Name_of_trader_in_Robusta_coffee__c = 'Gabula1';
        coffeeMasindi1.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1200;
        coffeeMasindi1.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 900;
        coffeeMasindi1.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeMasindi1;
        
        X3_0_Masindi_Robusta_Coffee__c coffeeMasindi2 = new X3_0_Masindi_Robusta_Coffee__c();
        coffeeMasindi2.Name_of_trader_in_Robusta_coffee__c = 'Gabula2';
        coffeeMasindi2.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1800;
        coffeeMasindi2.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeMasindi2.X3_0_Market_Masindi__c = [SELECT Id FROM Market_Masindi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeMasindi2;
        
        Menu_Item__c coffeeParentMenu = new Menu_Item__c();
        coffeeParentMenu.Label__c = 'test Market';
        insert coffeeParentMenu;
        
        Menu_Item__c coffeeMenu = new Menu_Item__c();
        coffeeMenu.Label__c = 'Coffee';
        coffeeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert coffeeMenu;
        
        Menu_Item__c coffeeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Coffee'];
                
        MisSubcountyMarketPrices.computeMasindiCoffeePriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Coffee' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void kaseseBananaPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_Banana__c bananaKasese = new X3_0_Kasese_Banana__c();
        bananaKasese.Name_of_the_trader_in_banana__c = 'Gabula';
        bananaKasese.A_bunch_of_bananas_at_retail_price__c = 1500;
        bananaKasese.A_bunch_of_bananas_at_wholesale_price__c = 1200;
        bananaKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaKasese;
        
        X3_0_Kasese_Banana__c bananaKasese1 = new X3_0_Kasese_Banana__c();
        bananaKasese1.Name_of_the_trader_in_banana__c = 'Gabula1';
        bananaKasese1.A_bunch_of_bananas_at_retail_price__c = 1200;
        bananaKasese1.A_bunch_of_bananas_at_wholesale_price__c = 900;
        bananaKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaKasese1;
        
        X3_0_Kasese_Banana__c bananaKasese2 = new X3_0_Kasese_Banana__c();
        bananaKasese2.Name_of_the_trader_in_banana__c = 'Gabula2';
        bananaKasese2.A_bunch_of_bananas_at_retail_price__c = 1800;
        bananaKasese2.A_bunch_of_bananas_at_wholesale_price__c = 1200;
        bananaKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaKasese2;
        
        Menu_Item__c bananaParentMenu = new Menu_Item__c();
        bananaParentMenu.Label__c = 'test Market';
        insert bananaParentMenu;
        
        Menu_Item__c bananaMenu = new Menu_Item__c();
        bananaMenu.Label__c = 'Banana';
        bananaMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert bananaMenu;
        
        Menu_Item__c bananaMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Banana'];
                
        MisSubcountyMarketPrices.computeKaseseBananaPriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Banana' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void nambaleKasesePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_Nambale_Beans__c nambaleKasese = new X3_0_Kasese_Nambale_Beans__c();
        nambaleKasese.Name_of_trader_in_dry_nambale_beans__c = 'Gabula';
        nambaleKasese.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1500;
        nambaleKasese.A_Kg_of_Dry_Nambale_beans_at_wholesale_p__c = 1200;
        nambaleKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleKasese;
        
        X3_0_Kasese_Nambale_Beans__c nambaleKasese1 = new X3_0_Kasese_Nambale_Beans__c();
        nambaleKasese1.Name_of_trader_in_dry_nambale_beans__c = 'Gabula1';
        nambaleKasese1.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1200;
        nambaleKasese1.A_Kg_of_Dry_Nambale_beans_at_wholesale_p__c = 900;
        nambaleKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleKasese1;
        
        X3_0_Kasese_Nambale_Beans__c nambaleKasese2 = new X3_0_Kasese_Nambale_Beans__c();
        nambaleKasese2.Name_of_trader_in_dry_nambale_beans__c = 'Gabula2';
        nambaleKasese2.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1800;
        nambaleKasese2.A_Kg_of_Dry_Nambale_beans_at_wholesale_p__c = 1200;
        nambaleKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleKasese2;
        
        Menu_Item__c nambaleParentMenu = new Menu_Item__c();
        nambaleParentMenu.Label__c = 'test Market';
        insert nambaleParentMenu;
        
        Menu_Item__c nambaleMenu = new Menu_Item__c();
        nambaleMenu.Label__c = 'Dry Nambale Beans';
        nambaleMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert nambaleMenu;
        
        Menu_Item__c nambaleMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Dry Nambale Beans'];
                
        MisSubcountyMarketPrices.computeKaseseNambaleBeansPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Dry Nambale Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void kaseseKbeansPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_K132_Beans__c kBeansKasese = new X3_0_Kasese_K132_Beans__c();
        kBeansKasese.Name_of_trader_in_K132_beans__c = 'Gabula';
        kBeansKasese.A_Kg_of_K132_beans_at_retail_price__c = 1500;
        kBeansKasese.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        kBeansKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansKasese;
        
        X3_0_Kasese_K132_Beans__c kBeansKasese1 = new X3_0_Kasese_K132_Beans__c();
        kBeansKasese1.Name_of_trader_in_K132_beans__c = 'Gabula1';
        kBeansKasese1.A_Kg_of_K132_beans_at_retail_price__c = 1200;
        kBeansKasese1.A_Kg_of_K132_beans_at_wholesale_price__c = 900;
        kBeansKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansKasese1;
        
        X3_0_Kasese_K132_Beans__c kBeansKasese2 = new X3_0_Kasese_K132_Beans__c();
        kBeansKasese2.Name_of_trader_in_K132_beans__c = 'Gabula2';
        kBeansKasese2.A_Kg_of_K132_beans_at_retail_price__c = 1800;
        kBeansKasese2.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        kBeansKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansKasese2;
        
        Menu_Item__c kBeansParentMenu = new Menu_Item__c();
        kBeansParentMenu.Label__c = 'test Market';
        insert kBeansParentMenu;
        
        Menu_Item__c kBeansMenu = new Menu_Item__c();
        kBeansMenu.Label__c = 'K132 Beans';
        kBeansMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert kBeansMenu;
        
        Menu_Item__c kBeansMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='K132 Beans'];
                
        MisSubcountyMarketPrices.computeKaseseKBeansPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'K132 Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void kaseseCoffeePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_Coffee__c coffeeKasese = new X3_0_Kasese_Coffee__c();
        coffeeKasese.Name_of_trader_in_Robusta_coffee__c = 'Gabula';
        coffeeKasese.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1500;
        coffeeKasese.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeKasese;
        
        X3_0_Kasese_Coffee__c coffeeKasese1 = new X3_0_Kasese_Coffee__c();
        coffeeKasese1.Name_of_trader_in_Robusta_coffee__c = 'Gabula1';
        coffeeKasese1.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1200;
        coffeeKasese1.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 900;
        coffeeKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeKasese1;
        
        X3_0_Kasese_Coffee__c coffeeKasese2 = new X3_0_Kasese_Coffee__c();
        coffeeKasese2.Name_of_trader_in_Robusta_coffee__c = 'Gabula2';
        coffeeKasese2.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1800;
        coffeeKasese2.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeKasese2;
        
        Menu_Item__c coffeeParentMenu = new Menu_Item__c();
        coffeeParentMenu.Label__c = 'test Market';
        insert coffeeParentMenu;
        
        Menu_Item__c coffeeMenu = new Menu_Item__c();
        coffeeMenu.Label__c = 'Coffee';
        coffeeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert coffeeMenu;
        
        Menu_Item__c coffeeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Coffee'];
                
        MisSubcountyMarketPrices.computeKaseseCoffeePriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Coffee' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void kaseseGnutsPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_Gnuts__c gnutsKasese = new X3_0_Kasese_Gnuts__c();
        gnutsKasese.Name_of_the_trader_in_Gnuts__c = 'Gabula';
        gnutsKasese.A_Kg_of_shelled_gnuts_at_retail_price__c = 1500;
        gnutsKasese.A_Kg_of_shelled_gnuts_at_wholesale_price__c = 1200;
        gnutsKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert gnutsKasese;
        
        X3_0_Kasese_Gnuts__c gnutsKasese1 = new X3_0_Kasese_Gnuts__c();
        gnutsKasese1.Name_of_the_trader_in_Gnuts__c = 'Gabula1';
        gnutsKasese1.A_Kg_of_shelled_gnuts_at_retail_price__c = 1200;
        gnutsKasese1.A_Kg_of_shelled_gnuts_at_wholesale_price__c = 900;
        gnutsKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert gnutsKasese1;
        
        X3_0_Kasese_Gnuts__c gnutsKasese2 = new X3_0_Kasese_Gnuts__c();
        gnutsKasese2.Name_of_the_trader_in_Gnuts__c = 'Gabula2';
        gnutsKasese2.A_Kg_of_shelled_gnuts_at_retail_price__c = 1800;
        gnutsKasese2.A_Kg_of_shelled_gnuts_at_wholesale_price__c = 1200;
        gnutsKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert gnutsKasese2;
        
        Menu_Item__c gnutsParentMenu = new Menu_Item__c();
        gnutsParentMenu.Label__c = 'test Market';
        insert gnutsParentMenu;
        
        Menu_Item__c gnutsMenu = new Menu_Item__c();
        gnutsMenu.Label__c = 'Gnuts';
        gnutsMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert gnutsMenu;
        
        Menu_Item__c gnutsMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Gnuts'];
                
        MisSubcountyMarketPrices.computeKaseseGnutsPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Gnuts' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void kaseseMaizePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Kasese__c marketXKasese = new Market_Kasese__c();
        marketXKasese.Date_of_capture__c = system.now().addDays(-1).date();
        marketXKasese.GPS_Location__Latitude__s = 0.337352;
        marketXKasese.GPS_Location__Longitude__s = 32.600415;
        marketXKasese.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXKasese.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXKasese;
        
        X3_0_Kasese_Maize__c maizeKasese = new X3_0_Kasese_Maize__c();
        maizeKasese.Name_of_trader_in_Maize__c = 'Gabula';
        maizeKasese.A_Kg_of_Mazie_grain_at_retail_price__c = 1500;
        maizeKasese.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeKasese.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeKasese;
        
        X3_0_Kasese_Maize__c maizeKasese1 = new X3_0_Kasese_Maize__c();
        maizeKasese1.Name_of_trader_in_Maize__c = 'Gabula1';
        maizeKasese1.A_Kg_of_Mazie_grain_at_retail_price__c = 1200;
        maizeKasese1.A_Kg_of_Mazie_grain_at_wholesale_price__c = 900;
        maizeKasese1.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeKasese1;
        
        X3_0_Kasese_Maize__c maizeKasese2 = new X3_0_Kasese_Maize__c();
        maizeKasese2.Name_of_trader_in_Maize__c = 'Gabula2';
        maizeKasese2.A_Kg_of_Mazie_grain_at_retail_price__c = 1800;
        maizeKasese2.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeKasese2.X3_0_Market_Kasese__c = [SELECT Id FROM Market_Kasese__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeKasese2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Maize';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Maize'];
                
        MisSubcountyMarketPrices.computeKaseseMaizePriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Maize' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiMaizePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Maize__c maizeBushenyi = new X3_0_Bushenyi_Maize__c();
        maizeBushenyi.Name_of_trader_in_Maize__c = 'Gabula';
        maizeBushenyi.A_Kg_of_Mazie_grain_at_retail_price__c = 1500;
        maizeBushenyi.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeBushenyi;
        
        X3_0_Bushenyi_Maize__c maizeBushenyi1 = new X3_0_Bushenyi_Maize__c();
        maizeBushenyi1.Name_of_trader_in_Maize__c = 'Gabula1';
        maizeBushenyi1.A_Kg_of_Mazie_grain_at_retail_price__c = 1200;
        maizeBushenyi1.A_Kg_of_Mazie_grain_at_wholesale_price__c = 900;
        maizeBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeBushenyi1;
        
        X3_0_Bushenyi_Maize__c maizeBushenyi2 = new X3_0_Bushenyi_Maize__c();
        maizeBushenyi2.Name_of_trader_in_Maize__c = 'Gabula2';
        maizeBushenyi2.A_Kg_of_Mazie_grain_at_retail_price__c = 1800;
        maizeBushenyi2.A_Kg_of_Mazie_grain_at_wholesale_price__c = 1200;
        maizeBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert maizeBushenyi2;
        
        Menu_Item__c maizeParentMenu = new Menu_Item__c();
        maizeParentMenu.Label__c = 'test Market';
        insert maizeParentMenu;
        
        Menu_Item__c maizeMenu = new Menu_Item__c();
        maizeMenu.Label__c = 'Maize';
        maizeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert maizeMenu;
        
        Menu_Item__c maizeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Maize'];
                
        MisSubcountyMarketPrices.computeBushenyiMaizePriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Maize' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiBananaPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Banana__c bananaBushenyi = new X3_0_Bushenyi_Banana__c();
        bananaBushenyi.Name_of_the_trader_in_Banana__c = 'Gabula';
        bananaBushenyi.A_bunch_of_Bananas_at_retail_price__c = 1500;
        bananaBushenyi.A_bunch_of_Bananas_at_wholesale_pric__c = 1200;
        bananaBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaBushenyi;
        
        X3_0_Bushenyi_Banana__c bananaBushenyi1 = new X3_0_Bushenyi_Banana__c();
        bananaBushenyi1.Name_of_the_trader_in_Banana__c = 'Gabula1';
        bananaBushenyi1.A_bunch_of_Bananas_at_retail_price__c = 1200;
        bananaBushenyi1.A_bunch_of_Bananas_at_wholesale_pric__c = 900;
        bananaBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaBushenyi1;
        
        X3_0_Bushenyi_Banana__c bananaBushenyi2 = new X3_0_Bushenyi_Banana__c();
        bananaBushenyi2.Name_of_the_trader_in_Banana__c = 'Gabula2';
        bananaBushenyi2.A_bunch_of_Bananas_at_retail_price__c = 1800;
        bananaBushenyi2.A_bunch_of_Bananas_at_wholesale_pric__c = 1200;
        bananaBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert bananaBushenyi2;
        
        Menu_Item__c bananaParentMenu = new Menu_Item__c();
        bananaParentMenu.Label__c = 'test Market';
        insert bananaParentMenu;
        
        Menu_Item__c bananaMenu = new Menu_Item__c();
        bananaMenu.Label__c = 'Banana';
        bananaMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert bananaMenu;
        
        Menu_Item__c bananaMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Banana'];
                
        MisSubcountyMarketPrices.computeBushenyiBananaPriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Banana' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiCoffeePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Robusta_Coffee__c coffeeBushenyi = new X3_0_Bushenyi_Robusta_Coffee__c();
        coffeeBushenyi.Name_of_trader_in_Robusta_coffee__c = 'Gabula';
        coffeeBushenyi.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1500;
        coffeeBushenyi.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeBushenyi;
        
        X3_0_Bushenyi_Robusta_Coffee__c coffeeBushenyi1 = new X3_0_Bushenyi_Robusta_Coffee__c();
        coffeeBushenyi1.Name_of_trader_in_Robusta_coffee__c = 'Gabula1';
        coffeeBushenyi1.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1200;
        coffeeBushenyi1.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 900;
        coffeeBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeBushenyi1;
        
        X3_0_Bushenyi_Robusta_Coffee__c coffeeBushenyi2 = new X3_0_Bushenyi_Robusta_Coffee__c();
        coffeeBushenyi2.Name_of_trader_in_Robusta_coffee__c = 'Gabula2';
        coffeeBushenyi2.A_Kg_of_Robusta_Coffee_at_retail_price__c = 1800;
        coffeeBushenyi2.A_Kg_of_Robusta_coffee_at_wholesale_pric__c = 1200;
        coffeeBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert coffeeBushenyi2;
        
        Menu_Item__c coffeeParentMenu = new Menu_Item__c();
        coffeeParentMenu.Label__c = 'test Market';
        insert coffeeParentMenu;
        
        Menu_Item__c coffeeMenu = new Menu_Item__c();
        coffeeMenu.Label__c = 'Coffee';
        coffeeMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert coffeeMenu;
        
        Menu_Item__c coffeeMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Coffee'];
                
        MisSubcountyMarketPrices.computeBushenyiCoffeePriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Coffee' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiCassavaPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Cassava__c cassavaBushenyi = new X3_0_Bushenyi_Cassava__c();
        cassavaBushenyi.Name_of_trader_in_Cassava__c = 'Gabula';
        cassavaBushenyi.A_Kg_of_fresh_Cassava_at_retail_price__c = 1500;
        cassavaBushenyi.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 1200;
        cassavaBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaBushenyi;
        
        X3_0_Bushenyi_Cassava__c cassavaBushenyi1 = new X3_0_Bushenyi_Cassava__c();
        cassavaBushenyi1.Name_of_trader_in_Cassava__c = 'Gabula1';
        cassavaBushenyi1.A_Kg_of_fresh_Cassava_at_retail_price__c = 1200;
        cassavaBushenyi1.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 900;
        cassavaBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaBushenyi1;
        
        X3_0_Bushenyi_Cassava__c cassavaBushenyi2 = new X3_0_Bushenyi_Cassava__c();
        cassavaBushenyi2.Name_of_trader_in_Cassava__c = 'Gabula2';
        cassavaBushenyi2.A_Kg_of_fresh_Cassava_at_retail_price__c = 1800;
        cassavaBushenyi2.A_Kg_of_fresh_Cassava_at_wholesale_pric__c = 1200;
        cassavaBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert cassavaBushenyi2;
        
        Menu_Item__c cassavaParentMenu = new Menu_Item__c();
        cassavaParentMenu.Label__c = 'test Market';
        insert cassavaParentMenu;
        
        Menu_Item__c cassavaMenu = new Menu_Item__c();
        cassavaMenu.Label__c = 'Cassava';
        cassavaMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert cassavaMenu;
        
        Menu_Item__c cassavaMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Cassava'];
                
        MisSubcountyMarketPrices.computeBushenyiCassavaPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Cassava' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiSweetPotatoesPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Sweet_Potatoes__c sweetPotatoesBushenyi = new X3_0_Bushenyi_Sweet_Potatoes__c();
        sweetPotatoesBushenyi.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula';
        sweetPotatoesBushenyi.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1500;
        sweetPotatoesBushenyi.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 1200;
        sweetPotatoesBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesBushenyi;
        
        X3_0_Bushenyi_Sweet_Potatoes__c sweetPotatoesBushenyi1 = new X3_0_Bushenyi_Sweet_Potatoes__c();
        sweetPotatoesBushenyi1.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula1';
        sweetPotatoesBushenyi1.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1200;
        sweetPotatoesBushenyi1.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 900;
        sweetPotatoesBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesBushenyi1;
        
        X3_0_Bushenyi_Sweet_Potatoes__c sweetPotatoesBushenyi2 = new X3_0_Bushenyi_Sweet_Potatoes__c();
        sweetPotatoesBushenyi2.Name_of_the_trader_in_Sweet_Potatoes__c = 'Gabula2';
        sweetPotatoesBushenyi2.A_Kg_of_Sweet_Potatoes_at_retail_price__c = 1800;
        sweetPotatoesBushenyi2.A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c = 1200;
        sweetPotatoesBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert sweetPotatoesBushenyi2;
        
        Menu_Item__c sweetPotatoesParentMenu = new Menu_Item__c();
        sweetPotatoesParentMenu.Label__c = 'test Market';
        insert sweetPotatoesParentMenu;
        
        Menu_Item__c sweetPotatoesMenu = new Menu_Item__c();
        sweetPotatoesMenu.Label__c = 'Sweet Potatoes';
        sweetPotatoesMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert sweetPotatoesMenu;
        
        Menu_Item__c sweetPotatoesMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Sweet Potatoes'];
                
        MisSubcountyMarketPrices.computeBushenyiSweetPotatoesPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Sweet Potatoes' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiKbeansPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_K132_Beans__c kBeansBushenyi = new X3_0_Bushenyi_K132_Beans__c();
        kBeansBushenyi.Name_of_trader_in_K132_beans__c = 'Gabula';
        kBeansBushenyi.A_Kg_of_K132_beans_at_retail_price__c = 1500;
        kBeansBushenyi.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        kBeansBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansBushenyi;
        
        X3_0_Bushenyi_K132_Beans__c kBeansBushenyi1 = new X3_0_Bushenyi_K132_Beans__c();
        kBeansBushenyi1.Name_of_trader_in_K132_beans__c = 'Gabula1';
        kBeansBushenyi1.A_Kg_of_K132_beans_at_retail_price__c = 1200;
        kBeansBushenyi1.A_Kg_of_K132_beans_at_wholesale_price__c = 900;
        kBeansBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansBushenyi1;
        
        X3_0_Bushenyi_K132_Beans__c kBeansBushenyi2 = new X3_0_Bushenyi_K132_Beans__c();
        kBeansBushenyi2.Name_of_trader_in_K132_beans__c = 'Gabula2';
        kBeansBushenyi2.A_Kg_of_K132_beans_at_retail_price__c = 1800;
        kBeansBushenyi2.A_Kg_of_K132_beans_at_wholesale_price__c = 1200;
        kBeansBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert kBeansBushenyi2;
        
        Menu_Item__c kBeansParentMenu = new Menu_Item__c();
        kBeansParentMenu.Label__c = 'test Market';
        insert kBeansParentMenu;
        
        Menu_Item__c kBeansMenu = new Menu_Item__c();
        kBeansMenu.Label__c = 'K132 Beans';
        kBeansMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert kBeansMenu;
        
        Menu_Item__c kBeansMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='K132 Beans'];
                
        MisSubcountyMarketPrices.computeBushenyiKBeansPriceAverages('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'K132 Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiNambalePricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Nambale_Beans__c nambaleBushenyi = new X3_0_Bushenyi_Nambale_Beans__c();
        nambaleBushenyi.Name_of_trader_in_dry_nambale_beans__c = 'Gabula';
        nambaleBushenyi.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1500;
        nambaleBushenyi.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 1200;
        nambaleBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBushenyi;
        
        X3_0_Bushenyi_Nambale_Beans__c nambaleBushenyi1 = new X3_0_Bushenyi_Nambale_Beans__c();
        nambaleBushenyi1.Name_of_trader_in_dry_nambale_beans__c = 'Gabula1';
        nambaleBushenyi1.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1200;
        nambaleBushenyi1.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 900;
        nambaleBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBushenyi1;
        
        X3_0_Bushenyi_Nambale_Beans__c nambaleBushenyi2 = new X3_0_Bushenyi_Nambale_Beans__c();
        nambaleBushenyi2.Name_of_trader_in_dry_nambale_beans__c = 'Gabula2';
        nambaleBushenyi2.A_Kg_of_Dry_Nambale_beans_at_retail_pric__c = 1800;
        nambaleBushenyi2.A_Kg_of_Dry_Nambale_beans_at_wholesale__c = 1200;
        nambaleBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert nambaleBushenyi2;
        
        Menu_Item__c nambaleParentMenu = new Menu_Item__c();
        nambaleParentMenu.Label__c = 'test Market';
        insert nambaleParentMenu;
        
        Menu_Item__c nambaleMenu = new Menu_Item__c();
        nambaleMenu.Label__c = 'Dry Nambale Beans';
        nambaleMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert nambaleMenu;
        
        Menu_Item__c nambaleMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Dry Nambale Beans'];
                
        MisSubcountyMarketPrices.computeBushenyiNambalePriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Dry Nambale Beans' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    static testMethod void bushenyiMilletPricesTest() {
        
        Contact contact = new Contact();
        contact.FirstName = 'Dan';
        contact.LastName = 'Ssentamu';
        insert contact;
        
        C3P0_Market__c market = new C3P0_Market__c();
        market.Name = 'test Market';
        market.District__c = 'Masindi';
        market.Subcounty__c = 'test subcounty';
        market.Parish__c = 'NA';
        market.Village__c = 'NA';
        market.Market_Size__c = 300;
        market.Peak__c = 'Sunday';//Country__c.Name, 
        market.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        market.Market_Gps__Latitude__s = 0.337231;
        market.Market_Gps__Longitude__s = 32.600702;
        market.Collection_Date__c = system.now().addDays(-1).date();
        insert market;
        String data1 = [SELECT Name FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Name;
        system.assertEquals(data1, 'test Market');
        
        Market_Bushenyi__c marketXBushenyi = new Market_Bushenyi__c();
        marketXBushenyi.Date_of_capture__c = system.now().addDays(-1).date();
        marketXBushenyi.GPS_Location__Latitude__s = 0.337352;
        marketXBushenyi.GPS_Location__Longitude__s = 32.600415;
        marketXBushenyi.Contact__c = [SELECT Id FROM Contact WHERE FirstName = 'Dan' LIMIT 1].Id;
        marketXBushenyi.X3_0_Market__c = [SELECT Id FROM C3P0_Market__c WHERE Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert marketXBushenyi;
        
        X3_0_Bushenyi_Millet__c milletBushenyi = new X3_0_Bushenyi_Millet__c();
        milletBushenyi.Name_of_the_trader_in_Millet__c = 'Gabula';
        milletBushenyi.A_Kg_of_Millet_at_retail_price__c = 1500;
        milletBushenyi.A_Kg_of_Millet_at_wholesale_pric__c = 1200;
        milletBushenyi.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert milletBushenyi;
        
        X3_0_Bushenyi_Millet__c milletBushenyi1 = new X3_0_Bushenyi_Millet__c();
        milletBushenyi1.Name_of_the_trader_in_Millet__c = 'Gabula1';
        milletBushenyi1.A_Kg_of_Millet_at_retail_price__c = 1200;
        milletBushenyi1.A_Kg_of_Millet_at_wholesale_pric__c = 900;
        milletBushenyi1.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert milletBushenyi1;
        
        X3_0_Bushenyi_Millet__c milletBushenyi2 = new X3_0_Bushenyi_Millet__c();
        milletBushenyi2.Name_of_the_trader_in_Millet__c = 'Gabula2';
        milletBushenyi2.A_Kg_of_Millet_at_retail_price__c = 1800;
        milletBushenyi2.A_Kg_of_Millet_at_wholesale_pric__c = 1200;
        milletBushenyi2.X3_0_Market_Bushenyi__c = [SELECT Id FROM Market_Bushenyi__c WHERE X3_0_Market__r.Collection_Date__c = YESTERDAY LIMIT 1].Id;
        insert milletBushenyi2;
        
        Menu_Item__c milletParentMenu = new Menu_Item__c();
        milletParentMenu.Label__c = 'test Market';
        insert milletParentMenu;
        
        Menu_Item__c milletMenu = new Menu_Item__c();
        milletMenu.Label__c = 'Millet';
        milletMenu.Parent_Item__c = [SELECT Id FROM Menu_Item__c LIMIT 1].Id;
        insert milletMenu;
        
        Menu_Item__c milletMenuItem = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : data1
            AND 
                Label__c='Millet'];
                
        MisSubcountyMarketPrices.computeBushenyiMilletPriceAverage('test Market');
        
        String content = [SELECT Content__c FROM Menu_Item__c WHERE Label__c = 'Millet' LIMIT 1].Content__c;
        
        system.assertEquals(content, 'Average Retail Price is 1500 Per Kg'+
                '\N Average Wholesale Price 1100 Per Kg');
                
    }
    
    
}