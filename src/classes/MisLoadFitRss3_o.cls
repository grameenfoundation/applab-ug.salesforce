/**
*
* Copyright (c) 2015 AppLab, Grameen Foundation
*
*  This class reads the FIT RSS feeds, picks out the latest price changes
*  and saves them into salesforce for 3.0 Search
*  It is batcheable since there is inevitable SOSQL limitations in importBackEndKeywords
**/
global class MisLoadFitRss3_o implements Database.batchable<MisLoadFitRss3_o.Item>, Database.AllowsCallouts {
    static final String ATTRIBUTION = 'Information provided by FIT Uganda';
    static final String BASEKEYWORD = 'Market_Prices';
    static final String CATEGORY = 'Market_Information';
    static final String MENU_NAME = 'CKW 3.0 Search';
    static final String SECONDARY_MENU_NAME = 'CKW Test';
    private Datetime changeDate = datetime.now();
    private String url = '';
    global String notificationContent = '';

    public MisLoadFitRss3_o() {
        System.debug(Logginglevel.INFO, 'MIS: Loading FIT feeds started');
        FIT_RSS_Import_Settings__c settings = FIT_RSS_Import_Settings__c.getValues('mis_fit_settings');
        System.debug(Logginglevel.INFO, 'SETTINGS' + settings);
        if (Test.isRunningTest()) {
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
    global Iterable<MisLoadFitRss3_o.Item> start(Database.BatchableContext info) {
        System.debug(Logginglevel.INFO, 'MIS: Loading data for batching');
        //MisLoadFitRss3_o.Rss data = loadRssFeed();
        MisLoadFitRss3_o.Rss data = loadAgRssFeed(); //Call via new implementation since the xml from fit changed
        notificationContent += 'Items loaded from feed = ' + data.items.size();
        notificationContent += '\n Markets in feed missing in Salesforce = ' + data.missingMarkets.size();
        System.debug(Logginglevel.INFO, 'Noti... ' + notificationContent);
        System.debug(Logginglevel.INFO, ' Items loaded from fit ' + data.items);
        return data.items;
    }

    /**
    *   called when a batch is to be processed
    *   @param scope    the records to be processed in one batch
    */
    global void execute(Database.BatchableContext info, List<MisLoadFitRss3_o.Item> scope) {
        List<ImportBackendKeywordsNew.MenuItemAdapter> menuItemAdapters = generateItemAdapters(scope);
        boolean result2 = ImportBackendKeywordsNew.importBackendKeywords(menuItemAdapters, MENU_NAME);
        notificationContent += '\n Batch processing = ' + scope.size()
                               + '. ItemAdapters = ' + menuItemAdapters.size()
                               + '. Returned=>' + result2;
        System.debug(Logginglevel.INFO, 'Noti... ' + notificationContent);

        menuItemAdapters = generateItemAdapters(scope);
        boolean result = ImportBackendKeywordsNew.importBackendKeywords(menuItemAdapters, SECONDARY_MENU_NAME);
        notificationContent += '\n Batch processing = ' + scope.size()
                               + '. ItemAdapters = ' + menuItemAdapters.size()
                               + '. Returned=>' + result;
        System.debug(Logginglevel.INFO, 'Noti... ' + notificationContent);

    }

    /**
    *   Informs on status of processing
    */
    global void finish(Database.BatchableContext info) {
        notificationContent += '\n Processing completed successfully';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'hkalule@grameenfoundation.org'});
        mail.setReplyTo('noreply@applab.org');
        mail.setSenderDisplayName('Batch Process');
        mail.setSubject('Batch Process Load FIT Prices 3.0 Search');
        mail.setPlainTextBody(notificationContent);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            //organisation may not have mail sending capability
        }
    }

    /*
    *   creates web request, querries rss feeds endpoint and loads
    *   market-price items
    *   @return RSS Object containing list of market price items
    This will parse using the new format
    */
    public Rss loadAgRssFeed() {

        //current location http://mis.infotradeuganda.com/feed';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setCompressed(true);

        Dom.Document doc = new Dom.Document();
        Http http = new Http();

        try {
            if (!Test.isRunningTest()) {
                doc = http.send(req).getBodyDocument();
                System.debug(Logginglevel.INFO, 'MIS: Document acquired');
            } else {
                Test.setMock(HttpCalloutMock.class, new MisLoadFitRss3_oTest());
                HttpResponse res = http.send(req);
                String xmlString = res.getBody();
                doc.load(xmlString);
            }
        } catch (Exception ex) {
            System.debug(Logginglevel.INFO, 'MIS: erroring calling RSS Feed: ' + ex.getMessage());
        }

        Dom.XMLNode rss = doc.getRootElement();

        if (rss == null) {
            System.debug(Logginglevel.INFO, 'MIS: RSS XML returned empty');
            return null;
        }

        //first child element of rss feed is always channel
        Dom.XMLNode channel = rss.getChildElements()[0];

        //create a map of regions for easy lookup
        Map<String, String> regionMap = new Map<String, String>();
        for (List<Market__c> markets : [SELECT m.Market__c, m.Region__c FROM Market__c m]) {
            for (Market__c m : markets) {
                regionMap.put(m.Market__c, m.Region__c);
            }
        }

        Rss result = new Rss();

        for (Dom.XMLNode items : channel.getChildElements()) {
            if ('item' == items.getName()) {
                String commodity = items.getChildElement('commodity', null).getText();
                String datecollected = items.getChildElement('datecollected', null).getText();
                String unit = items.getChildElement('unit', null).getText();

                System.debug('commodity is ' + commodity);
                //For each market, parse the xml
                for (Dom.XMLNode elements : items.getChildElements()) {
                    if ('market' == elements.getName()) {
                        //for each node inside item
                        //System.debug('Processing market');
                        Item rssItem = new Item();
                        for (Dom.XMLNode xmlItem : elements.getChildElements()) {
                            rssItem.productName = commodity;
                            rssItem.unit = unit;
                            rssItem.recordDate = datecollected + ' 23:59:59';
                            if ('name' == xmlItem.getName()) {
                                rssItem.marketName = xmlItem.getText();
                            }
                            if ('retailprice' == xmlItem.getName()) {
                                rssItem.retailPrice = xmlItem.getText().replaceAll(',', '');
                                if (''.equals(rssItem.retailPrice)) rssItem.retailPrice = '0';
                            }
                            if ('wholesaleprice' == xmlItem.getName()) {
                                rssItem.wholeSalePrice = xmlItem.getText().replaceAll(',', '');
                                if (''.equals(rssItem.wholeSalePrice)) rssItem.wholeSalePrice = '0';
                            }
                        }
                        if (regionMap.containsKey(rssItem.marketName)) {
                            rssItem.region = regionMap.get(rssItem.marketName);
                            rssItem.keyword = rssItem.generateKeyword();
                            if (rssItem.keyword != null) {
                                System.debug(rssItem.keyword);
                                result.items.add(rssItem);
                            }
                        } else {
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
    public List<ImportBackendKeywordsNew.MenuItemAdapter> generateItemAdapters(List<Item> keywords) {
        integer updatableKeyWordsCount = 0;
        System.debug(Logginglevel.INFO, 'MIS: Generating itemAdapters for ' + changeDate);
        List<ImportBackendKeywordsNew.MenuItemAdapter> adapters = new List<ImportBackendKeywordsNew.MenuItemAdapter>();
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
                System.debug(Logginglevel.INFO, 'MIS: adding adapter ' + i + ' prev & current mapped ' + previousPath + ' ' + currentPath);

                // Make sure that there is no 'similar' adapter already loaded
                if (!existsInAdaptersList(adapters, currentPath)) {
                    ImportBackendKeywordsNew.MenuItemAdapter adapter = new ImportBackendKeywordsNew.MenuItemAdapter();
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
                    System.debug(Logginglevel.INFO, 'MIS: adding adapter ' + i + ' built and added label = ' + adapter.Label);
                    adapters.add(adapter);
                }
            }
            //}
            //else
            //    System.debug(Logginglevel.INFO,'MIS: SKIPPING adapter ' + keywords.get(i).keyword);
        }
        System.debug(Logginglevel.INFO, 'MIS: adding adapter completed with updatable keywords = ' + updatableKeyWordsCount);
        System.debug(Logginglevel.INFO, 'MIS: adding adapter completed with ' + adapters.size());
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
    private boolean existsInAdaptersList(List<ImportBackendKeywordsNew.MenuItemAdapter> adapters, String path) {
        for (ImportBackendKeywordsNew.MenuItemAdapter adapter : adapters) {
            if (adapter.MenuPath.Equals(path)) {
                return true;
            }
        }
        return false;
    }

    /**
    *   This class holds two lists
    *   a list of market price items imported and a list of missing markets
    */
    public class Rss {
        public List<Item> items {get; set;}
        public Set<String> missingMarkets {get; set;}
        public Rss() {
            items = new List<Item>();
            missingMarkets = new Set<String>();
        }
    }

    /**
    *   This class holds market price data for an item
    */
    global class Item {
        public String marketName {get; set;}
        public String productName {get; set;}
        public String unit {get; set;}
        public String recordDate {get; set;}
        public String retailPrice {get; set;}
        public String wholeSalePrice {get; set;}
        public String region {get; set;}
        public String keyword {get; set;}

        public String generateKeyword() {
            if (region == null) return null;
            String keyword = '';
            keyword += MisLoadFitRss3_o.CATEGORY;
            keyword += ' ';
            keyword += MisLoadFitRss3_o.BASEKEYWORD;
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
            if (this.retailPrice == null && this.wholeSalePrice == null) {
                return null;
            } else if (this.retailPrice == null || this.retailPrice == '') {
                return getWholesaleContent();
            } else if (this.wholeSalePrice == null || this.wholeSalePrice == '') {
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
            if (this.wholesalePrice != null) {
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
            List<String> args = new String[] {'0', 'number', '###,###,###'};
            return String.format(num.format(), args);
        }
    }
}