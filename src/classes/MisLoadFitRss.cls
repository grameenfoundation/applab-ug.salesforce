/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class reads the FIT RSS feeds, picks out the latest price changes
 *  and saves them into salesforce
 *  It is batcheable since there is inevitable SOSQL limitations in importBackEndKeywords 
 **/
global class MisLoadFitRss implements Database.batchable<MisLoadFitRss.Item>, Database.AllowsCallouts{
    static final String ATTRIBUTION = 'Information provided by FIT Uganda';
    static final String BASEKEYWORD = 'Market_Prices';
    static final String CATEGORY = 'Market_Information';
    static final String MENU_NAME = 'CKW Search';
    static final String SECONDARY_MENU_NAME = 'CKW Test';
    private Datetime changeDate = datetime.now();
    private String url = '';
    global String notificationContent = '';
            
    public MisLoadFitRss(){
        System.debug(Logginglevel.INFO,'MIS: Loading FIT feeds started');
        FIT_RSS_Import_Settings__c settings = FIT_RSS_Import_Settings__c.getValues('mis_fit_settings');
        if (Test.isRunningTest()){
            settings = new FIT_RSS_Import_Settings__c();
            settings.url__c = 'http://mis.infotradeuganda.com/feed/';
            settings.Change_Period__c = 1;
        }
        this.url = settings.url__c;
        this.changeDate = this.changeDate.addDays(-1 * integer.valueOf(settings.Change_Period__c));
    }
    
    /**
    *   initialises the records upon which batch processing will be carried out.
    *   @param scope    batch context
    *   @return         list of market items to process    
    */
    global Iterable<MisLoadFitRss.Item> start(Database.BatchableContext info){
        System.debug(Logginglevel.INFO,'MIS: Loading data for batching');
        //MisLoadFitRss.Rss data = loadRssFeed();
        MisLoadFitRss.Rss data = loadAgRssFeed(); //Call via new implementation since the xml from fit changed
        notificationContent += 'Items loaded from feed = ' + data.items.size();
        notificationContent += '\n Markets in feed missing in Salesforce = ' + data.missingMarkets.size();
        return data.items;
    }
    
    /**
    *   called when a batch is to be processed
    *   @param scope    the records to be processed in one batch
    */
    global void execute(Database.BatchableContext info, List<MisLoadFitRss.Item> scope){
        List<ImportBackendServerKeywords.MenuItemAdapter> menuItemAdapters = generateItemAdapters(scope);
        boolean result = ImportBackendServerKeywords.importBackendKeywords(menuItemAdapters, MENU_NAME);
        notificationContent += '\n Batch processing = ' + scope.size() 
                            + '. ItemAdapters = ' + menuItemAdapters.size() 
                            + '. Returned=>' + result;

        boolean result2 = ImportBackendServerKeywords.importBackendKeywords(menuItemAdapters, SECONDARY_MENU_NAME);
        notificationContent += '\n Batch processing = ' + scope.size() 
                            + '. ItemAdapters = ' + menuItemAdapters.size() 
                            + '. Returned=>' + result;
    }
    
    /**
    *   Informs on status of processing
    */
    global void finish(Database.BatchableContext info){
        notificationContent += '\n Processing completed successfully';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'uganda_tech@grameenfoundation.org'});
        mail.setReplyTo('noreply@applab.org');
        mail.setSenderDisplayName('Batch Process');
        mail.setSubject('Batch Process Load FIT Prices');
        mail.setPlainTextBody(notificationContent);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception e){
            //organisation may not have mail sending capability
        }
    }
        
    /*
    *   creates web request, querries rss feeds endpoint and loads 
    *   market-price items
    *   @return RSS Object containing list of market price items
    */
    public Rss loadRssFeed(){
        
        //current location http://mis.infotradeuganda.com/feed';        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setCompressed(true);
         
        Dom.Document doc = new Dom.Document();
        Http http = new Http();
        
        try{
            if (!Test.isRunningTest()){
                doc = http.send(req).getBodyDocument();
                System.debug(Logginglevel.INFO,'MIS: Document acquired');
            } else {
                System.debug(Logginglevel.INFO,'MIS: Acquiring Test RSS XML');
                datetime todayDate = datetime.now().addDays(-1);
                String dDate = todayDate.format('yyyy-MM-dd');
                String xmlString = '<?xml version="1.0" encoding="utf-8" ?> <rss version="2.0"><channel><title>Latest Prices - July 9, 2013 12:33 pm</title><link>http://infotradeuganda.com/feed/</link><description>The latest retail and wholesale prices for commodities in Uganda provided by infotradeuganda.com</description><language>en-us</language><copyright>Copyright (C) 2010 infotradeuganda.com</copyright><item><market>AmuruMarket</market><product>Agwedde Beans</product><unit>Kg</unit><date>{0}</date><retailPrice></retailPrice><wholesalePrice>1100</wholesalePrice></item><item><market>AmuruMarket</market><product>Beef</product><unit>Kg</unit><date>2013-07-25</date><retailPrice>8500</retailPrice><wholesalePrice>8000</wholesalePrice></item><item><market>AmuruMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice></wholesalePrice></item><item><market>UnknownMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice>900</wholesalePrice></item>{2}</channel></rss>';
                String itemTag = '<item><market>AmuruMarket</market><product>{0}</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice>1000</wholesalePrice></item>';
                String itemTags = '';
                for(integer i = 0; i < 50; i++){
                    itemTags += String.format(itemTag, new String[]{String.valueOf(i), dDate}); 
                }
                //String formattedTags = String.format(itemTags, new String[]{dDate});
                String formattedString = String.format(xmlString, new String[]{dDate, dDate, itemTags});
                doc.load(formattedString);
            }
        }catch(Exception ex){
            System.debug(Logginglevel.INFO,'MIS: erroring calling RSS Feed: ' + ex.getMessage());
        }
        
        Dom.XMLNode rss = doc.getRootElement();
        
        if(rss == null){
            System.debug(Logginglevel.INFO,'MIS: RSS XML returned empty');              
            return null;
        }
        
        //first child element of rss feed is always channel
        Dom.XMLNode channel = rss.getChildElements()[0];
        
        //create a map of regions for easy lookup
        Map<String, String> regionMap = new Map<String, String>();
        for(List<Market__c> markets: [SELECT m.Market__c, m.Region__c FROM Market__c m]){
            for(Market__c m: markets){
                regionMap.put(m.Market__c, m.Region__c);
            }
        } 
            
        Rss result = new Rss();
        
        for(Dom.XMLNode elements : channel.getChildElements()){
            if('item' == elements.getName()) {
                Item rssItem = new Item();
                //for each node inside item
                for(Dom.XMLNode xmlItem : elements.getChildElements()) {
                    if('market' == xmlItem.getName()){
                        rssItem.marketName = xmlItem.getText();
                    }
                    if('product' == xmlItem.getName()){
                        rssItem.productName = xmlItem.getText();
                    }
                    if('unit' == xmlItem.getName()){
                        rssItem.unit = xmlItem.getText();
                    }
                    if('date' == xmlItem.getName()){
                        rssItem.recordDate = xmlItem.getText() + ' 23:59:59';
                    }
                    if('retailPrice' == xmlItem.getName()){
                        rssItem.retailPrice = xmlItem.getText();
                    }
                    if('wholesalePrice' == xmlItem.getName()){
                        rssItem.wholeSalePrice = xmlItem.getText();
                    }
                }
                if (regionMap.containsKey(rssItem.marketName)){
                    rssItem.region = regionMap.get(rssItem.marketName);
                    rssItem.keyword = rssItem.generateKeyword();
                    if(rssItem.keyword != null){
                        result.items.add(rssItem);
                    }
                }
                else{
                    result.missingMarkets.add(rssItem.marketName);
                }
            }        
        }
        //insert result.items;
        return result;
    }






    /*
    *   creates web request, querries rss feeds endpoint and loads 
    *   market-price items
    *   @return RSS Object containing list of market price items
    This will parse using the new format
    */
    public Rss loadAgRssFeed(){
        
        //current location http://mis.infotradeuganda.com/feed';        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setCompressed(true);
         
        Dom.Document doc = new Dom.Document();
        Http http = new Http();
        
        try{
            if (!Test.isRunningTest()){
                doc = http.send(req).getBodyDocument();
                System.debug(Logginglevel.INFO,'MIS: Document acquired');
            } else {
                System.debug(Logginglevel.INFO,'MIS: Acquiring Test RSS XML');
                datetime todayDate = datetime.now().addDays(-1);
                String dDate = todayDate.format('yyyy-MM-dd');
                String xmlString = '<?xml version="1.0" encoding="utf-8" ?> <rss version="2.0"><channel><title>Latest Prices - July 9, 2013 12:33 pm</title><link>http://infotradeuganda.com/feed/</link><description>The latest retail and wholesale prices for commodities in Uganda provided by infotradeuganda.com</description><language>en-us</language><copyright>Copyright (C) 2010 infotradeuganda.com</copyright><item><market>AmuruMarket</market><product>Agwedde Beans</product><unit>Kg</unit><date>{0}</date><retailPrice></retailPrice><wholesalePrice>1100</wholesalePrice></item><item><market>AmuruMarket</market><product>Beef</product><unit>Kg</unit><date>2013-07-25</date><retailPrice>8500</retailPrice><wholesalePrice>8000</wholesalePrice></item><item><market>AmuruMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice></wholesalePrice></item><item><market>UnknownMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice>900</wholesalePrice></item>{2}</channel></rss>';
                //String itemTag = '<item><market>AmuruMarket</market><product>{0}</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice>1000</wholesalePrice></item>';
                //String itemTags = '';
                //for(integer i = 0; i < 50; i++){
                //    itemTags += String.format(itemTag, new String[]{String.valueOf(i), dDate}); 
                //}
                //String formattedTags = String.format(itemTags, new String[]{dDate});
                //String formattedString = String.format(xmlString, new String[]{dDate, dDate, itemTags});
                xmlString = '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>INFOTRADE - Latest Prices as at July 14, 2014</title><link>https://agmis.infotradeuganda.com/feed/index/user/grameen</link><description>The latest Retail and Wholesale Prices provided by Infotrade Uganda. View source code for details.</description><language>en-us</language><copyright>Copyright (C) 2014 Infotrade Uganda</copyright></channel><?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>INFOTRADE - Latest Prices as at July 14, 2014</title><link>https://agmis.infotradeuganda.com/feed/index/user/grameen</link><description>The latest Retail and Wholesale Prices provided by Infotrade Uganda. View source code for details.</description><language>en-us</language><copyright>Copyright (C) 2014 Infotrade Uganda</copyright><item><id>5</id><datecollected>2014-07-16</datecollected><commodity>Agwedde Beans</commodity><unit>kg</unit><category>Pulses</category><retailprice_avg>1,750</retailprice_avg><wholesaleprice_avg>1,500</wholesaleprice_avg><market><id>2</id><name>Kalerwe Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>5</id><name>Nakasero Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>9</id><name>Nakawa Market</name><district>Kampala</district><retailprice>2,000</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>10</id><name>Owino Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>151</id><name>Mutukula Market</name><district>Rakai</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>166</id><name>Kayunga Market</name><district>Kayunga</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>19</id><name>Kiboga Market</name><district>Kiboga</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>21</id><name>Luwero Market</name><district>Luwero</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>22</id><name>Masaka Market</name><district>Masaka</district><retailprice>1,800</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>148</id><name>Mubende Market</name><district>Mubende</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>15</id><name>Jinja Market</name><district>Jinja</district><retailprice>2,000</retailprice><wholesaleprice>1,900</wholesaleprice></market><market><id>16</id><name>Kapchorwa Market</name><district>Kapchorwa</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>3</id><name>Mbale Market</name><district>Mbale</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>6</id><name>Soroti Market</name><district>Soroti</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>7</id><name>Busia Market</name><district>Busia</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>147</id><name>Kamuli Market</name><district>Kamuli</district><retailprice>1,600</retailprice><wholesaleprice>1,400</wholesaleprice></market><market><id>14</id><name>Iganga Market</name><district>Iganga</district><retailprice>1,500</retailprice><wholesaleprice>1,250</wholesaleprice></market><market><id>1</id><name>Arua Market</name><district>Arua</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>153</id><name>Koboko Market</name><district>Koboko</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>20</id><name>Lira Market</name><district>Lira</district><retailprice>1,800</retailprice><wholesaleprice>1,750</wholesaleprice></market><market><id>129</id><name>Nwoya Market</name><district>Nwoya</district><retailprice>1,500</retailprice><wholesaleprice>1,400</wholesaleprice></market><market><id>132</id><name>Kitgum Market</name><district>Kitgum</district><retailprice>2,200</retailprice><wholesaleprice>2,000</wholesaleprice></market><market><id>133</id><name>Amuru Market</name><district>Amuru</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>134</id><name>Abim Market</name><district>Abim</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>11</id><name>Gulu Market</name><district>Gulu</district><retailprice>1,500</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>152</id><name>Katuna Market</name><district>Kabale</district><retailprice>1,500</retailprice><wholesaleprice>1,300</wholesaleprice></market><market><id>17</id><name>Kasese Market</name><district>Kasese</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>165</id><name>Isingiro Market</name><district>Isingiro</district><retailprice>1,800</retailprice><wholesaleprice>1,200</wholesaleprice></market><market><id>18</id><name>Kisoro Market</name><district>Kisoro</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>4</id><name>Mbarara Market</name><district>Mbarara</district><retailprice>2,000</retailprice><wholesaleprice>1,550</wholesaleprice></market><market><id>179</id><name>Kigumba Market</name><district>Kiryandongo</district><retailprice>1,700</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>8</id><name>Fort Portal Market</name><district>Kabarole</district><retailprice>2,000</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>12</id><name>Kabale Market</name><district>Kabale</district><retailprice>1,700</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>149</id><name>Mpondwe Market</name><district>Kasese</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>13</id><name>Hoima Market</name><district>Hoima</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>150</id><name>Masindi Market</name><district>Masindi</district><retailprice>1,600</retailprice><wholesaleprice>1,200</wholesaleprice></market></item></channel></rss>';
                doc.load(xmlString);
            }
        }catch(Exception ex){
            System.debug(Logginglevel.INFO,'MIS: erroring calling RSS Feed: ' + ex.getMessage());
        }
        
        Dom.XMLNode rss = doc.getRootElement();
        
        if(rss == null){
            System.debug(Logginglevel.INFO,'MIS: RSS XML returned empty');              
            return null;
        }
        
        //first child element of rss feed is always channel
        Dom.XMLNode channel = rss.getChildElements()[0];
        
        //create a map of regions for easy lookup
        Map<String, String> regionMap = new Map<String, String>();
        for(List<Market__c> markets: [SELECT m.Market__c, m.Region__c FROM Market__c m]){
            for(Market__c m: markets){
                regionMap.put(m.Market__c, m.Region__c);
            }
        } 
            
        Rss result = new Rss();
        
        for(Dom.XMLNode items : channel.getChildElements()){
            if('item' == items.getName()) {
                String commodity = items.getChildElement('commodity', null).getText();
                String datecollected = items.getChildElement('datecollected', null).getText();
                String unit = items.getChildElement('unit', null).getText();

                System.debug('commodity is '+commodity);
                //For each market, parse the xml
                for(Dom.XMLNode elements : items.getChildElements()){
                if('market' == elements.getName()) {
                    //for each node inside item
                    //System.debug('Processing market');
                    Item rssItem = new Item();
                        for(Dom.XMLNode xmlItem : elements.getChildElements()) {
                            rssItem.productName = commodity;
                            rssItem.unit = unit;
                             rssItem.recordDate = datecollected + ' 23:59:59';
                            if('name' == xmlItem.getName()){
                                rssItem.marketName = xmlItem.getText();
                            }
                            if('retailprice' == xmlItem.getName()){
                                rssItem.retailPrice = xmlItem.getText().replaceAll(',', '');
                                if(''.equals(rssItem.retailPrice)) rssItem.retailPrice='0';
                            }
                            if('wholesaleprice' == xmlItem.getName()){
                                rssItem.wholeSalePrice = xmlItem.getText().replaceAll(',', '');
                                if(''.equals(rssItem.wholeSalePrice)) rssItem.wholeSalePrice='0';
                            }
                        }
                        if (regionMap.containsKey(rssItem.marketName)){
                            rssItem.region = regionMap.get(rssItem.marketName);
                            rssItem.keyword = rssItem.generateKeyword();
                            if(rssItem.keyword != null){
                                System.debug(rssItem.keyword);
                                result.items.add(rssItem);
                            }
                        }
                        else{
                            result.missingMarkets.add(rssItem.marketName);
                        }
                }

                
                
            }        
        }
        }
        
        return result;
    }
 




    
    /*
    *   creates MenuItemAdapters for the given market prices passed
    *   @param keywords     a list of market price items to be save to salesforce
    *   @return             List of MenuItemAdapters
    */
    public List<ImportBackendServerKeywords.MenuItemAdapter> generateItemAdapters(List<Item> keywords){
        integer updatableKeyWordsCount = 0;
        System.debug(Logginglevel.INFO,'MIS: Generating itemAdapters for ' + changeDate);        
        List<ImportBackendServerKeywords.MenuItemAdapter> adapters = new List<ImportBackendServerKeywords.MenuItemAdapter>();
        for (Integer i = 0; i < keywords.size(); i++) {
            String recordDate = datetime.valueOf(keywords.get(i).recordDate).format('yyyy-MM-dd');
            //its proved to be too challenging to predict when the feed changes,
            //we consume everything but reduce frequency to a few times a week
            //if(recordDate == changeDate.format('yyyy-MM-dd')){
                updatableKeyWordsCount++; 

                // split keywords breabcrumb to build menu paths for adapters
                keywords.get(i).keyword = keywords.get(i).keyword.trim().replaceAll('\\s+', ' ');
                String[] rawTokens = keywords.get(i).keyword.split(' ');
                String[] tokens = removeUnderscore(keywords.get(i).keyword.split(' '));
    
                // current and previous paths
                String previousPath = '';
                String currentPath = '';
                // loop over all the tokens and build adapters
                for (Integer j = 0; j < tokens.size(); j++) {
                    previousPath = currentPath;
                    currentPath = buildAdapterMenuPath(rawTokens, j);
                    System.debug(Logginglevel.INFO,'MIS: adding adapter ' + i + ' prev & current mapped ' + previousPath + ' ' + currentPath);
    
                    // Make sure that there is no 'similar' adapter already loaded
                    if (!existsInAdaptersList(adapters, currentPath)) {
                        ImportBackendServerKeywords.MenuItemAdapter adapter = new ImportBackendServerKeywords.MenuItemAdapter();
                        adapter.MenuPath = currentPath;
                        adapter.IsActive = true;
                        adapter.LastModifiedDate = datetime.now();
                        adapter.Label = tokens[j];
                        adapter.IsProcessed = false;
    
                        // Fill in content, attribution et al if its the end point item
                        if (j == tokens.size() - 1) {
                            adapter.Content = keywords.get(i).getContent();
                            adapter.Attribution = ATTRIBUTION;
                            adapter.LastModifiedDate = datetime.valueOf(keywords.get(i).recordDate);
                        }
                        adapter.PreviousItemPath = previousPath;
                        System.debug(Logginglevel.INFO,'MIS: adding adapter ' + i + ' built and added label = ' + adapter.Label);
                        adapters.add(adapter);
                    }
                }
            //}
            //else
            //    System.debug(Logginglevel.INFO,'MIS: SKIPPING adapter ' + keywords.get(i).keyword); 
        }
        System.debug(Logginglevel.INFO,'MIS: adding adapter completed with updatable keywords = ' + updatableKeyWordsCount);
        System.debug(Logginglevel.INFO,'MIS: adding adapter completed with ' + adapters.size());
        return adapters;
    }
    
    /**
    *   replaces underscores with spaces
    *   @param tokens   string containing inderscores
    *   @return         string without underscores
    */
    private String[] removeUnderscore(String[] tokens) {
        if (tokens.size() > 0) {
            for (Integer x = 0; x < tokens.size(); x++) {
                String token = tokens[x].trim().replaceAll('_', ' ');
                tokens[x] = token;
            }
        }
        return tokens;
    }
    
    /**
    *   builds a menu path
    *   @param tokens   strings elements in the menu path
    *   @param level    the last level in the menu path
    *   @return         menu path
    */
    private String buildAdapterMenuPath(String[] tokens, Integer level) {
        String path = '';
        for (Integer x = 0; x < tokens.size() && x <= level; x++) {
            String y = tokens[x];
            path = path + ' ' + y;
        }
        return path.trim();
    }
    
    /**
    *   Checks if the keyword already exists in list of adapters
    *   @param adapters     list of adapters
    *   @param path         string path or keyword
    *   @return             true if exists, false otherwise
    */
    private boolean existsInAdaptersList(List<ImportBackendServerKeywords.MenuItemAdapter> adapters, String path) {
        for (ImportBackendServerKeywords.MenuItemAdapter adapter : adapters){
            if (adapter.MenuPath.Equals(path)){
                return true;
            }
        }
        return false;
    }    
    
    /**
    *   This class holds two lists
    *   a list of market price items imported and a list of missing markets
    */
    public class Rss{
        public List<Item> items{get;set;}
        public Set<String> missingMarkets {get;set;}
        public Rss(){
            items = new List<Item>();
            missingMarkets = new Set<String>();
        }
    }
    
    /**
    *   This class holds market price data for an item
    */
    global class Item{
        public String marketName {get;set;} 
        public String productName {get;set;}
        public String unit {get;set;}
        public String recordDate {get;set;}
        public String retailPrice {get;set;}
        public String wholeSalePrice {get;set;}
        public String region {get;set;}
        public String keyword{get;set;}
        
        public String generateKeyword() {
            if (region == null) return null;                    
            String keyword = ''; 
            keyword += MisLoadFitRss.CATEGORY;
            keyword += ' ';
            keyword += MisLoadFitRss.BASEKEYWORD;
            keyword += ' ';
            keyword += this.region;
            keyword += ' ';
            keyword += this.marketName.replace(' ', '_');
            keyword += ' ';
            keyword += this.productName.replace(' ', '_');
            return keyword;
        }
        
        /**
        *   gets the price description in a market item
        *   @return     price content
        */
        public String getContent() {            
            if (this.retailPrice == null && this.wholeSalePrice == null){
                return null;
            }
            else if (this.retailPrice == null || this.retailPrice == ''){
                return getWholesaleContent();
            }
            else if (this.wholeSalePrice == null || this.wholeSalePrice == ''){
                return getRetailContent();
            }
            return getRetailContent() + ' \n' + getWholesaleContent();
        }
    
        /**
        *   gets the retail price in a market item
        *   @return     retail price
        */
        private String getRetailContent() {    
            String price = '';
            if (this.retailPrice != null)
                price = 'Retail Price: ' + formatNumber(Double.valueOf(this.retailPrice)) + ' ' + getUnitSegment() + '.';
            return price;
        }
    
        /**
        *   gets the wholesale price in a market item
        *   @return     wholesale price 
        */
        private String getWholesaleContent() {    
            String price = '';
            if (this.wholesalePrice != null){
                price = 'Wholesale Price: ' + formatNumber(Double.valueOf(this.wholeSalePrice)) + ' ' + getUnitSegment() + '.';
            }
            return price;
        }
    
        /**
        *   gets the units of a market item e.g per Kg
        *   @return     unit
        */
        private String getUnitSegment() {    
            return 'Shs per ' + this.unit;
        }
        
        /**
        *   formats a given number to include commas
        *   @return     formatted number containg commas
        */
        private String formatNumber(Double num) {
            List<String> args = new String[]{'0','number','###,###,###'};
            return String.format(num.format(), args);
        }        
    }
}