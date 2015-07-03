/*
  Class for computing all MIS Subcounty Market Prices
  MisSubcountyMarketPricesTest contains all tests for this class 
*/
public class MisSubcountyMarketPrices {
	
    public MisSubcountyMarketPrices() {
        
    }
    private static boolean  validationStatus=false;
    
    public static boolean applyMasindiGPSValidation(Market_Masindi__c mrkt,C3P0_Market__c c) {
        Double baselineMrktSize =c.Market_Size__c;
        Double baselineLatitude =c.Market_Gps__Latitude__s;
        Double baselineLongitude =c.Market_Gps__Longitude__s;
        Double newlatitude=mrkt.GPS_Location__Latitude__s;
        Double newLongitude=mrkt.GPS_Location__Longitude__s; 
        
        //Compare locations using haversine formula
        if(DistanceCalculatorMrkt.calculateDistance(baselineLatitude, baselineLongitude, newlatitude, newLongitude)<=baselineMrktSize){
            System.debug('Gps within Range ');
            MisSubcountyMarketPrices.validationStatus=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Gps out of Range ');
            }
        return MisSubcountyMarketPrices.validationStatus;
    }
    
    public static boolean applyKaseseGPSValidation(Market_Kasese__c mrkt,C3P0_Market__c c) {
        Double baselineMrktSize =c.Market_Size__c;
        Double baselineLatitude =c.Market_Gps__Latitude__s;
        Double baselineLongitude =c.Market_Gps__Longitude__s;
        Double newlatitude=mrkt.GPS_Location__Latitude__s;
        Double newLongitude=mrkt.GPS_Location__Longitude__s; 
        
        //Compare locations using haversine formula
        if(DistanceCalculatorMrkt.calculateDistance(baselineLatitude, baselineLongitude, newlatitude, newLongitude)<=baselineMrktSize){
            System.debug('Gps within Range ');
            MisSubcountyMarketPrices.validationStatus=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Gps out of Range ');
            }
        return MisSubcountyMarketPrices.validationStatus;
    }
    
    public static boolean applyBushenyiGPSValidation(Market_Bushenyi__c mrkt,C3P0_Market__c c) {
        Double baselineMrktSize =c.Market_Size__c;
        Double baselineLatitude =c.Market_Gps__Latitude__s;
        Double baselineLongitude =c.Market_Gps__Longitude__s;
        Double newlatitude=mrkt.GPS_Location__Latitude__s;
        Double newLongitude=mrkt.GPS_Location__Longitude__s; 
        
        //Compare locations using haversine formula
        if(DistanceCalculatorMrkt.calculateDistance(baselineLatitude, baselineLongitude, newlatitude, newLongitude)<=baselineMrktSize){
            System.debug('Gps within Range ');
            MisSubcountyMarketPrices.validationStatus=true;                  
            }else{
                System.debug(loggingLevel.Error, 'Gps out of Range ');
            }
        return MisSubcountyMarketPrices.validationStatus;
    }

    @future (callout=false)
    public static void computeAllPrices(){
        List<Market_Masindi__c> submissions = [
            SELECT 
                Name 
            FROM 
                Market_Masindi__c 
            WHERE 
                Date_of_capture__c = YESTERDAY ];
                    
        for (Market_Masindi__c submission : submissions){
            String marketName = [
                SELECT 
                    X3_0_Market__r.Name 
                FROM 
                    Market_Masindi__c
                WHERE 
                    Name = : submission.Name ].X3_0_Market__r.Name;
                    
            computeMasindiMaizePriceAverages(marketName);
            computeMasindiSunflowerPriceAverages(marketName);
            computeMasindiCassavaPriceAverages(marketName);
            computeMasindiKBeansPriceAverages(marketName);
            computeMasindiNambaleBeansPriceAverages(marketName);
            computeMasindiSweetPotatoesPriceAverage(marketName);
            computeMasindiBananaAverage(marketName);
            computeMasindiCoffeePriceAverage(marketName);
        
        }
        
        List<Market_Kasese__c> kaseseSubmissions = [
            SELECT 
                Name 
            FROM 
                Market_Kasese__c 
            WHERE 
                Date_of_capture__c = YESTERDAY ];
    
        for (Market_Kasese__c kaseseSubmission : kaseseSubmissions){
        	String marketName = [
        	SELECT
        	    X3_0_Market__r.Name 
        	FROM 
        	    Market_Kasese__c 
        	WHERE 
        	    Name = : kaseseSubmission.Name ].X3_0_Market__r.Name;
        	    
        	computeKaseseMaizePriceAverages(marketName);
        	computeKaseseCoffeePriceAverages(marketName);
        	computeKaseseGnutsPriceAverages(marketName);
        	computeKaseseKBeansPriceAverages(marketName);
        	computeKaseseNambaleBeansPriceAverages(marketName);
        	computeKaseseBananaPriceAverage(marketName);
    	
        }
        
        List<Market_Bushenyi__c> bushenyiSubmissions = [
            SELECT 
                Name 
            FROM 
                Market_Bushenyi__c 
            WHERE 
                Date_of_capture__c = YESTERDAY ];
    
        for (Market_Bushenyi__c bushenyiSubmission : bushenyiSubmissions){
        	String marketName = [
        	    SELECT 
        	        X3_0_Market__r.Name 
        	    FROM 
        	        Market_Bushenyi__c 
        	    WHERE 
        	        Name = : bushenyiSubmission.Name ].X3_0_Market__r.Name;
        	    
        	computeBushenyiMaizePriceAverages(marketName);
        	computeBushenyiCoffeePriceAverages(marketName);
        	computeBushenyiCassavaPriceAverages(marketName);
        	computeBushenyiKBeansPriceAverages(marketName);
        	computeBushenyiSweetPotatoesPriceAverages(marketName);
        	computeBushenyiBananaPriceAverage(marketName);
        	computeBushenyiNambalePriceAverage(marketName);
        	computeBushenyiMilletPriceAverage(marketName);
    	
        }
        
    }
    
    public static void computeMasindiMaizePriceAverages(String marketName) {
        //computes average retail and wholesale prices per Kg of maize
        AggregateResult[] maizeResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_Mazie_grain_at_retail_price__c)retail, 
                AVG(A_Kg_of_Mazie_grain_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Masindi_Maize__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ];   
                
        List<Menu_Item__c> maizeMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Maize'];
        if(maizeMenuItems.size() > 0 && maizeResult.size() > 0) {
        	Menu_Item__c maizeMenuItem = maizeMenuItems[0];           
            if(String.valueOf(maizeResult[0].get('retail')) != null && String.valueOf(maizeResult[0].get('wholesale')) != null){
                Integer averageRetailPrice = Integer.valueOf(maizeResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(maizeResult[0].get('wholesale'));
            
                maizeMenuItem.Content__c = 'Average Retail Price '+averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                maizeMenuItem.Last_Modified_Date__c = datetime.now();
                update maizeMenuItem;
            } 
        }

    }
    
    public static void computeMasindiSunflowerPriceAverages(String marketName) {
        //Average retail and wholesale prices per Kg of Sunflower
        AggregateResult[] sunflowerResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_Sunflower_at_retail_price__c)retail, 
                AVG(A_Kg_of_Sunflower_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Masindi_Sunflower__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ]; 
            //List of Sunflower Menu Items
        List<Menu_Item__c> sunflowerMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Sunflower'];
        //Check whether the Menu Item exists
        if(sunflowerMenuItems.size() > 0 && sunflowerResult.size() > 0) {
            Menu_Item__c sunflowerMenuItem = sunflowerMenuItems[0];        
            //Check whether the aggregate result has both retail and wholesales prices
        	if (String.valueOf(sunflowerResult[0].get('retail')) != null && String.valueOf(sunflowerResult[0].get('wholesale')) != null){   
                Integer averageRetailPrice = Integer.valueOf(sunflowerResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(sunflowerResult[0].get('wholesale'));
                sunflowerMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                sunflowerMenuItem.Last_Modified_Date__c = datetime.now();
                update sunflowerMenuItem;
            }    
        }
    }
    
    public static void computeMasindiCassavaPriceAverages(String marketName) {
        //computes average retail and wholesale prices per Kg of Cassava
        AggregateResult[] cassavaResult = [
            SELECT
                Market_Masindi__r.Id,
                AVG(A_Kg_of_fresh_Cassava_at_retail_price__c)retail, 
                AVG(A_Kg_of_fresh_Cassava_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Masindi_Cassava__c 
            WHERE 
                Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                Market_Masindi__r.Id
            ORDER BY 
                Market_Masindi__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> cassavaMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Cassava'];
       if(cassavaMenuItems.size() > 0 && cassavaResult.size() > 0) {
           Menu_Item__c cassavaMenuItem = cassavaMenuItems[0]; 
           if(String.valueOf(cassavaResult[0].get('retail')) !=null && String.valueOf(cassavaResult[0].get('wholesale')) !=null) {     
               Integer averageRetailPrice = Integer.valueOf(cassavaResult[0].get('retail'));
               Integer averageWholesalePrice = Integer.valueOf(cassavaResult[0].get('wholesale'));
               cassavaMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                cassavaMenuItem.Last_Modified_Date__c = datetime.now();
                update cassavaMenuItem;
           }
       }
    }
    
    public static void computeMasindiKBeansPriceAverages(String marketName) {
        //Computes average retail and wholesale prices per Kg of K312 Beans
        AggregateResult[] kBeansResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_K132_beans_at_retail_price__c)retail, 
                AVG(A_Kg_of_K132_beans_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Masindi_K132_Beans__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> kBeansMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='K132 Beans'];
                
        if(kBeansMenuItems.size() > 0 && kBeansResult.size() > 0){
        	Menu_Item__c kBeansMenuItem = kBeansMenuItems[0];
            if(String.valueOf(kBeansResult[0].get('retail')) != null && String.valueOf(kBeansResult[0].get('wholesale')) != null){  
                Integer averageRetailPrice = Integer.valueOf(kBeansResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(kBeansResult[0].get('wholesale'));
                kBeansMenuItem.Content__c = 'Average Retail Price ' +averageRetailPrice+ ' Per Kg'+
                '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                kBeansMenuItem.Last_Modified_Date__c = datetime.now();
                update kBeansMenuItem;
            }
        }
    }
    
    public static void computeMasindiNambaleBeansPriceAverages(String marketName) {
        //computes average retail and wholesale prices per Kg of Dry Nambale Beans
        AggregateResult[] nambaleBeansResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_Dry_Nambale_beans_at_retail_pric__c)retail, 
                AVG(A_Kg_of_Dry_Nambale_beans_at_wholesale__c)wholesale
            FROM 
                X3_0_Masindi_Nambale_Beans__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ]; 
                
        List<Menu_Item__c> nambaleBeansMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Dry Nambale Beans'];
            
        if(nambaleBeansMenuItems.size() > 0 && nambaleBeansResult.size() > 0){
            Menu_Item__c nambaleBeansMenuItem = nambaleBeansMenuItems[0];                
            if (String.valueOf(nambaleBeansResult[0].get('retail')) != null){    
                Integer averageRetailPrice = Integer.valueOf(nambaleBeansResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(nambaleBeansResult[0].get('wholesale'));
                nambaleBeansMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
            nambaleBeansMenuItem.Last_Modified_Date__c = datetime.now();
            update nambaleBeansMenuItem;
            }
        }
    }
    
    public static void computeMasindiBananaAverage(String marketName) {
        //computes average retail and wholesale prices per Kg of Sweet Potatoes
        AggregateResult[] bananaResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_bunch_of_bananas_at_retail_price__c)retail, 
                AVG(A_bunch_of_bananas_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Masindi_Banana__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> bananaMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Banana'];
        if(bananaMenuItems.size() > 0 && bananaResult.size() > 0){
        	Menu_Item__c bananaMenuItem = bananaMenuItems[0];
            if (String.valueOf(bananaResult[0].get('retail')) != null && String.valueOf(bananaResult[0].get('wholesale')) != null) {
                Integer averageRetailPrice = Integer.valueOf(bananaResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(bananaResult[0].get('wholesale'));
                bananaMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                bananaMenuItem.Last_Modified_Date__c = datetime.now();
                update bananaMenuItem;
            }
        }
    }
    
    public static void computeMasindiCoffeePriceAverage(String marketName) {
        //computes average retail and wholesale prices per Kg of Sweet Potatoes
        AggregateResult[] coffeeResult = [
            SELECT
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_Robusta_Coffee_at_retail_price__c)retail, 
                AVG(A_Kg_of_Robusta_coffee_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Masindi_Robusta_Coffee__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> coffeeMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c  
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Coffee'];
        if(coffeeMenuItems.size() > 0 && coffeeResult.size() > 0){
        	Menu_Item__c coffeeMenuItem = coffeeMenuItems[0];
            if (String.valueOf(coffeeResult[0].get('retail')) != null && String.valueOf(coffeeResult[0].get('wholesale')) != null) {
                Integer averageRetailPrice = Integer.valueOf(coffeeResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(coffeeResult[0].get('wholesale'));
                coffeeMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                coffeeMenuItem.Last_Modified_Date__c = datetime.now();
                update coffeeMenuItem;
            }
        }
    }
    
    public static void computeMasindiSweetPotatoesPriceAverage(String marketName) {
        //computes average retail and wholesale prices per Kg of Sweet Potatoes
        AggregateResult[] sweetPotatoesResult = [
            SELECT 
                X3_0_Market_Masindi__r.Id,
                AVG(A_Kg_of_Sweet_Potatoes_at_retail_price__c)retail, 
                AVG(A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Masindi_Sweet_Potatoes__c 
            WHERE 
                X3_0_Market_Masindi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Masindi__r.Id
            ORDER BY 
                X3_0_Market_Masindi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> sweetPotatoesMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Sweet Potatoes'];
        if(sweetPotatoesMenuItems.size() > 0 && sweetPotatoesResult.size() > 0) {
        	Menu_Item__c sweetPotatoesMenuItem = sweetPotatoesMenuItems[0];
            if (String.valueOf(sweetPotatoesResult[0].get('retail')) != null && String.valueOf(sweetPotatoesResult[0].get('wholesale')) != null) {
                Integer averageRetailPrice = Integer.valueOf(sweetPotatoesResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(sweetPotatoesResult[0].get('wholesale')); 
                sweetPotatoesMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                sweetPotatoesMenuItem.Last_Modified_Date__c = datetime.now();
                update sweetPotatoesMenuItem;
            }
        }
    }

    public static void computeKaseseMaizePriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of maize
    	AggregateResult[] maizeResult = [
            SELECT 
                X3_0_Market_Kasese__r.Id,
                AVG(A_Kg_of_Mazie_grain_at_retail_price__c)retail, 
                AVG(A_Kg_of_Mazie_grain_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Kasese_Maize__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ];   
                
        List<Menu_Item__c> maizeMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Maize'];
        if(maizeMenuItems.size() > 0 && maizeResult.size() > 0){
        	Menu_Item__c maizeMenuItem = maizeMenuItems[0];
            if(String.valueOf(maizeResult[0].get('retail')) != null && String.valueOf(maizeResult[0].get('wholesale')) != null){
            	Integer averageRetailPrice = Integer.valueOf(maizeResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(maizeResult[0].get('wholesale'));
                maizeMenuItem.Content__c = 'Average Retail Price '+averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                maizeMenuItem.Last_Modified_Date__c = datetime.now();
                update maizeMenuItem;
            } 
        }
    }
    
    public static void computeKaseseCoffeePriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sunflower
    	AggregateResult[] coffeeResult = [
            SELECT 
                X3_0_Market_Kasese__r.Id,
                AVG(A_Kg_of_Robusta_Coffee_at_retail_price__c)retail, 
                AVG(A_Kg_of_Robusta_coffee_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Kasese_Coffee__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ]; 
                
            List<Menu_Item__c> coffeeMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Coffee'];
        if(coffeeMenuItems.size() > 0 && coffeeResult.size() > 0){
        	Menu_Item__c coffeeMenuItem = coffeeMenuItems[0];
            if (String.valueOf(coffeeResult[0].get('retail')) != null && String.valueOf(coffeeResult[0].get('wholesale')) != null){   
                Integer averageRetailPrice = Integer.valueOf(coffeeResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(coffeeResult[0].get('wholesale'));
                coffeeMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg'; 
            coffeeMenuItem.Last_Modified_Date__c = datetime.now();
            update coffeeMenuItem;
            }   
        }
    }
    //check
    public static void computeKaseseGnutsPriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Cassava
    	AggregateResult[] cassavaResult = [
            SELECT
                X3_0_Market_Kasese__r.Id, 
                AVG(A_Kg_of_shelled_gnuts_at_retail_price__c)retail, 
                AVG(A_Kg_of_shelled_gnuts_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Kasese_Gnuts__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> gnutsMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Gnuts'];
       if(gnutsMenuItems.size() > 0 && cassavaResult.size() >0){
           Menu_Item__c gnutsMenuItem = gnutsMenuItems[0];
           if(String.valueOf(cassavaResult[0].get('retail')) !=null && String.valueOf(cassavaResult[0].get('wholesale')) !=null) {     
               Integer averageRetailPrice = Integer.valueOf(cassavaResult[0].get('retail'));
               Integer averageWholesalePrice = Integer.valueOf(cassavaResult[0].get('wholesale'));
               gnutsMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                gnutsMenuItem.Last_Modified_Date__c = datetime.now();
                update gnutsMenuItem;
           }
       }
    }
    
    public static void computeKaseseKBeansPriceAverages(String marketName) {
    	//Computes average retail and wholesale prices per Kg of K312 Beans
    	AggregateResult[] kBeansResult = [
            SELECT 
                X3_0_Market_Kasese__r.Id,
                AVG(A_Kg_of_K132_beans_at_retail_price__c)retail, 
                AVG(A_Kg_of_K132_beans_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Kasese_K132_Beans__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> kBeansMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='K132 Beans'];
        if(kBeansMenuItems.size() > 0 && kBeansResult.size() > 0) {
        	Menu_Item__c kBeansMenuItem = kBeansMenuItems[0];
            if(String.valueOf(kBeansResult[0].get('retail')) != null && String.valueOf(kBeansResult[0].get('wholesale')) != null){  
                Integer averageRetailPrice = Integer.valueOf(kBeansResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(kBeansResult[0].get('wholesale'));
                kBeansMenuItem.Content__c = 'Average Retail Price ' +averageRetailPrice+ ' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                kBeansMenuItem.Last_Modified_Date__c = datetime.now();
                update kBeansMenuItem;
            }
        }
    }
    
    public static void computeKaseseNambaleBeansPriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Dry Nambale Beans
    	AggregateResult[] nambaleBeansResult = [
            SELECT 
                X3_0_Market_Kasese__r.Id,
                AVG(A_Kg_of_Dry_Nambale_beans_at_retail_pric__c)retail, 
                AVG(A_Kg_of_Dry_Nambale_beans_at_wholesale_p__c)wholesale
            FROM 
                X3_0_Kasese_Nambale_Beans__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ]; 
                
        List<Menu_Item__c> nambaleBeansMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Dry Nambale Beans'];
        if(nambaleBeansMenuItems.size() > 0 && nambaleBeansResult.size() > 0){
        	Menu_Item__c nambaleBeansMenuItem = nambaleBeansMenuItems[0];
            if (String.valueOf(nambaleBeansResult[0].get('retail')) != null){    
                Integer averageRetailPrice = Integer.valueOf(nambaleBeansResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(nambaleBeansResult[0].get('wholesale'));
                nambaleBeansMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                nambaleBeansMenuItem.Last_Modified_Date__c = datetime.now();
                update nambaleBeansMenuItem;
            }
        }
    }
    
    public static void computeKaseseBananaPriceAverage(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sweet Potatoes
    	AggregateResult[] bananaResult = [
            SELECT
                X3_0_Market_Kasese__r.Id,
                AVG(A_bunch_of_bananas_at_retail_price__c)retail, 
                AVG(A_bunch_of_bananas_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Kasese_Banana__c 
            WHERE 
                X3_0_Market_Kasese__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Kasese__r.Id
            ORDER BY 
                X3_0_Market_Kasese__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> bananaMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Banana'];
        if(bananaMenuItems.size() > 0 && bananaResult.size() > 0) {
        	Menu_Item__c bananaMenuItem = bananaMenuItems[0];
            if (String.valueOf(bananaResult[0].get('retail')) != null && String.valueOf(bananaResult[0].get('wholesale')) != null) {
        	    Integer averageRetailPrice = Integer.valueOf(bananaResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(bananaResult[0].get('wholesale'));
                bananaMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                bananaMenuItem.Last_Modified_Date__c = datetime.now();
                update bananaMenuItem;
            }
        }
    }
    
    public static void computeBushenyiMaizePriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of maize
    	AggregateResult[] maizeResult = [
            SELECT 
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_Mazie_grain_at_retail_price__c)retail, 
                AVG(A_Kg_of_Mazie_grain_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Bushenyi_Maize__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];   
                
        List<Menu_Item__c> maizeMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Maize'];
        if(maizeMenuItems.size() > 0 && maizeResult.size() > 0){
            Menu_Item__c maizeMenuItem = maizeMenuItems[0];   
            if(String.valueOf(maizeResult[0].get('retail')) != null && String.valueOf(maizeResult[0].get('wholesale')) != null){
        	    Integer averageRetailPrice = Integer.valueOf(maizeResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(maizeResult[0].get('wholesale'));
                maizeMenuItem.Content__c = 'Average Retail Price '+averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                maizeMenuItem.Last_Modified_Date__c = datetime.now();
                update maizeMenuItem;
            } 
        }
    }
    
    public static void computeBushenyiCoffeePriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sunflower
    	AggregateResult[] coffeeResult = [
            SELECT
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_Robusta_Coffee_at_retail_price__c)retail, 
                AVG(A_Kg_of_Robusta_coffee_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Bushenyi_Robusta_Coffee__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ]; 
                
            List<Menu_Item__c> coffeeMenuItems = [
            SELECT  
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Coffee'];
        if(coffeeMenuItems.size() > 0 && coffeeResult.size() > 0) {
            Menu_Item__c coffeeMenuItem = coffeeMenuItems[0];
            if (String.valueOf(coffeeResult[0].get('retail')) != null && String.valueOf(coffeeResult[0].get('wholesale')) != null){   
                Integer averageRetailPrice = Integer.valueOf(coffeeResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(coffeeResult[0].get('wholesale'));
                coffeeMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                coffeeMenuItem.Last_Modified_Date__c = datetime.now();
                update coffeeMenuItem;
            }  
        }  
    }
    
    public static void computeBushenyiCassavaPriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Cassava
    	AggregateResult[] cassavaResult = [
            SELECT 
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_fresh_Cassava_at_retail_price__c)retail, 
                AVG(A_Kg_of_fresh_Cassava_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Bushenyi_Cassava__c
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> cassavaMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Cassava'];
       if(cassavaMenuItems.size() > 0 && cassavaResult.size() > 0){
           Menu_Item__c cassavaMenuItem = cassavaMenuItems[0];
           if(String.valueOf(cassavaResult[0].get('retail')) !=null && String.valueOf(cassavaResult[0].get('wholesale')) !=null) {     
               Integer averageRetailPrice = Integer.valueOf(cassavaResult[0].get('retail'));
               Integer averageWholesalePrice = Integer.valueOf(cassavaResult[0].get('wholesale'));
               cassavaMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice+' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice+' Per Kg';
                cassavaMenuItem.Last_Modified_Date__c = datetime.now();
                update cassavaMenuItem;
           }
       }
    }
    
    public static void computeBushenyiKBeansPriceAverages(String marketName) {
    	//Computes average retail and wholesale prices per Kg of K312 Beans
    	AggregateResult[] kBeansResult = [
            SELECT 
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_K132_beans_at_retail_price__c)retail, 
                AVG(A_Kg_of_K132_beans_at_wholesale_price__c)wholesale
            FROM 
                X3_0_Bushenyi_K132_Beans__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];
                
        List<Menu_Item__c> kBeansMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='K132 Beans'];
        if(kBeansMenuItems.size() > 0 && kBeansResult.size() > 0){ 
        	Menu_Item__c kBeansMenuItem = kBeansMenuItems[0];
            if(String.valueOf(kBeansResult[0].get('retail')) != null && String.valueOf(kBeansResult[0].get('wholesale')) != null){  
                Integer averageRetailPrice = Integer.valueOf(kBeansResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(kBeansResult[0].get('wholesale'));
                kBeansMenuItem.Content__c = 'Average Retail Price ' +averageRetailPrice+ ' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                kBeansMenuItem.Last_Modified_Date__c = datetime.now();
                update kBeansMenuItem;
            }
        }
    }
    
    public static void computeBushenyiSweetPotatoesPriceAverages(String marketName) {
    	//computes average retail and wholesale prices per Kg of Dry Nambale Beans
    	AggregateResult[] sweetPotatoesResult = [
            SELECT
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_Sweet_Potatoes_at_retail_price__c)retail, 
                AVG(A_Kg_of_Sweet_Potatoes_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Bushenyi_Sweet_Potatoes__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ]; 
                
        List<Menu_Item__c> sweetPotatoesMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c  
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Sweet Potatoes'];
                
        if(sweetPotatoesMenuItems.size() > 0 && sweetPotatoesResult.size() > 0) {
            Menu_Item__c sweetPotatoesMenuItem = sweetPotatoesMenuItems[0];      
            if (String.valueOf(sweetPotatoesResult[0].get('retail')) != null){    
                Integer averageRetailPrice = Integer.valueOf(sweetPotatoesResult[0].get('retail'));
                Integer averageWholesalePrice = Integer.valueOf(sweetPotatoesResult[0].get('wholesale'));
                sweetPotatoesMenuItem.Content__c = 'Average Retail Price '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                sweetPotatoesMenuItem.Last_Modified_Date__c = datetime.now();
                update sweetPotatoesMenuItem;
            }
        }
    }
    
    public static void computeBushenyiBananaPriceAverage(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sweet Potatoes
    	AggregateResult[] bananaResult = [
            SELECT 
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_bunch_of_Bananas_at_retail_price__c)retail, 
                AVG(A_bunch_of_Bananas_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Bushenyi_Banana__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> bananaMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Banana'];
        if(bananaMenuItems.size() > 0 && bananaResult.size() > 0){
        	Menu_Item__c bananaMenuItem = bananaMenuItems[0];
            if (String.valueOf(bananaResult[0].get('retail')) != null && String.valueOf(bananaResult[0].get('wholesale')) != null) {
        	    Integer averageRetailPrice = Integer.valueOf(bananaResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(bananaResult[0].get('wholesale'));
                bananaMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                bananaMenuItem.Last_Modified_Date__c = datetime.now();
                update bananaMenuItem;
            }
        }
    }
    
    public static void computeBushenyiNambalePriceAverage(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sweet Potatoes
    	AggregateResult[] nambaleResult = [
            SELECT 
                X3_0_Market_Bushenyi__r.Id,
                AVG(A_Kg_of_Dry_Nambale_beans_at_retail_pric__c)retail, 
                AVG(A_Kg_of_Dry_Nambale_beans_at_wholesale__c)wholesale
            FROM 
                X3_0_Bushenyi_Nambale_Beans__c 
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> nambaleMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Dry Nambale Beans'];
        if(nambaleMenuItems.size() > 0 && nambaleResult.size() > 0){
        	Menu_Item__c nambaleMenuItem = nambaleMenuItems[0];
            if (String.valueOf(nambaleResult[0].get('retail')) != null && String.valueOf(nambaleResult[0].get('wholesale')) != null) {
        	    Integer averageRetailPrice = Integer.valueOf(nambaleResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(nambaleResult[0].get('wholesale'));
                nambaleMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
            nambaleMenuItem.Last_Modified_Date__c = datetime.now();
            update nambaleMenuItem;
            }
        }
    }
    
    public static void computeBushenyiMilletPriceAverage(String marketName) {
    	//computes average retail and wholesale prices per Kg of Sweet Potatoes
    	AggregateResult[] milletResult = [
            SELECT
                X3_0_Market_Bushenyi__r.Id, 
                AVG(A_Kg_of_Millet_at_retail_price__c)retail, 
                AVG(A_Kg_of_Millet_at_wholesale_pric__c)wholesale
            FROM 
                X3_0_Bushenyi_Millet__c
            WHERE 
                X3_0_Market_Bushenyi__r.Date_of_capture__c = YESTERDAY
            GROUP BY
                X3_0_Market_Bushenyi__r.Id
            ORDER BY 
                X3_0_Market_Bushenyi__r.Id
            DESC LIMIT 1 ];
              
        List<Menu_Item__c> milletMenuItems = [
            SELECT 
                Label__c, 
                Parent_Item__r.Label__c 
            FROM 
                Menu_item__c 
            WHERE 
                Parent_Item__r.Label__c = : marketName
            AND 
                Label__c='Millet'];
                
        if(milletMenuItems.size() > 0 && milletResult.size() > 0) {
        	Menu_Item__c milletMenuItem = milletMenuItems[0];
            if (String.valueOf(milletResult[0].get('retail')) != null && String.valueOf(milletResult[0].get('wholesale')) != null) {
        	    Integer averageRetailPrice = Integer.valueOf(milletResult[0].get('retail'));
        	    Integer averageWholesalePrice = Integer.valueOf(milletResult[0].get('wholesale'));
                milletMenuItem.Content__c = 'Average Retail Price is '+ averageRetailPrice +' Per Kg'+
                    '\N Average Wholesale Price '+ averageWholesalePrice +' Per Kg';
                milletMenuItem.Last_Modified_Date__c = datetime.now();
                update milletMenuItem;
            }
        }
    }
        
}