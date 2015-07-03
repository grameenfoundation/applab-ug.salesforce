/**
* Copyright (c) 2015 AppLab, Grameen Foundation
*
* Two classes are tested herein for Aggroways Search;
* MisLoadFitRssAggroways in which we test Loading of the RSS XML
* ScheduledMisLoadFitRssAggroways where we test the scheduling
* Class List
* MisLoadFitRssAggroways,
* ScheduledMisLoadFitRssAggroways
*/
@isTest
global class MisLoadFitRssAggrowaysTest implements HttpCalloutMock
{
    static MisLoadFitRssAggroways batchKeywordsExporter = new MisLoadFitRssAggroways();
    
    // Implementatio of interface method for mock object
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://mis.infotradeuganda.com/feed/', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        req = new HttpRequest();
        req.setEndpoint('http://mis.infotradeuganda.com/feed/');
        req.setMethod('GET');
        req.setCompressed(true);
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        System.debug(Logginglevel.INFO, 'MIS: Acquiring Test RSS XML');
        datetime todayDate = datetime.now().addDays(-1);
        String dDate = todayDate.format('yyyy-MM-dd');
        String xmlString = '<?xml version="1.0" encoding="utf-8" ?> <rss version="2.0"><channel><title>Latest Prices - July 9, 2013 12:33 pm</title><link>http://infotradeuganda.com/feed/</link><description>The latest retail and wholesale prices for commodities in Uganda provided by infotradeuganda.com</description><language>en-us</language><copyright>Copyright (C) 2010 infotradeuganda.com</copyright><item><market>AmuruMarket</market><product>Agwedde Beans</product><unit>Kg</unit><date>{0}</date><retailPrice></retailPrice><wholesalePrice>1100</wholesalePrice></item><item><market>AmuruMarket</market><product>Beef</product><unit>Kg</unit><date>2013-07-25</date><retailPrice>8500</retailPrice><wholesalePrice>8000</wholesalePrice></item><item><market>AmuruMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice></wholesalePrice></item><item><market>UnknownMarket</market><product>Cassava Flour</product><unit>Kg</unit><date>{1}</date><retailPrice>1000</retailPrice><wholesalePrice>900</wholesalePrice></item>{2}</channel></rss>';
        xmlString = '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>INFOTRADE - Latest Prices as at July 14, 2014</title><link>https://agmis.infotradeuganda.com/feed/index/user/grameen</link><description>The latest Retail and Wholesale Prices provided by Infotrade Uganda. View source code for details.</description><language>en-us</language><copyright>Copyright (C) 2014 Infotrade Uganda</copyright></channel><?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>INFOTRADE - Latest Prices as at July 14, 2014</title><link>https://agmis.infotradeuganda.com/feed/index/user/grameen</link><description>The latest Retail and Wholesale Prices provided by Infotrade Uganda. View source code for details.</description><language>en-us</language><copyright>Copyright (C) 2014 Infotrade Uganda</copyright><item><id>5</id><datecollected>2014-07-16</datecollected><commodity>Agwedde Beans</commodity><unit>kg</unit><category>Pulses</category><retailprice_avg>1,750</retailprice_avg><wholesaleprice_avg>1,500</wholesaleprice_avg><market><id>2</id><name>Kalerwe Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>5</id><name>Nakasero Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>9</id><name>Nakawa Market</name><district>Kampala</district><retailprice>2,000</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>10</id><name>Owino Market</name><district>Kampala</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>151</id><name>Mutukula Market</name><district>Rakai</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>166</id><name>Kayunga Market</name><district>Kayunga</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>19</id><name>Kiboga Market</name><district>Kiboga</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>21</id><name>Luwero Market</name><district>Luwero</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>22</id><name>Masaka Market</name><district>Masaka</district><retailprice>1,800</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>148</id><name>Mubende Market</name><district>Mubende</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>15</id><name>Jinja Market</name><district>Jinja</district><retailprice>2,000</retailprice><wholesaleprice>1,900</wholesaleprice></market><market><id>16</id><name>Kapchorwa Market</name><district>Kapchorwa</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>3</id><name>Mbale Market</name><district>Mbale</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>6</id><name>Soroti Market</name><district>Soroti</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>7</id><name>Busia Market</name><district>Busia</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>147</id><name>Kamuli Market</name><district>Kamuli</district><retailprice>1,600</retailprice><wholesaleprice>1,400</wholesaleprice></market><market><id>14</id><name>Iganga Market</name><district>Iganga</district><retailprice>1,500</retailprice><wholesaleprice>1,250</wholesaleprice></market><market><id>1</id><name>Arua Market</name><district>Arua</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>153</id><name>Koboko Market</name><district>Koboko</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>20</id><name>Lira Market</name><district>Lira</district><retailprice>1,800</retailprice><wholesaleprice>1,750</wholesaleprice></market><market><id>129</id><name>Nwoya Market</name><district>Nwoya</district><retailprice>1,500</retailprice><wholesaleprice>1,400</wholesaleprice></market><market><id>132</id><name>Kitgum Market</name><district>Kitgum</district><retailprice>2,200</retailprice><wholesaleprice>2,000</wholesaleprice></market><market><id>133</id><name>Amuru Market</name><district>Amuru</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>134</id><name>Abim Market</name><district>Abim</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>11</id><name>Gulu Market</name><district>Gulu</district><retailprice>1,500</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>152</id><name>Katuna Market</name><district>Kabale</district><retailprice>1,500</retailprice><wholesaleprice>1,300</wholesaleprice></market><market><id>17</id><name>Kasese Market</name><district>Kasese</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>165</id><name>Isingiro Market</name><district>Isingiro</district><retailprice>1,800</retailprice><wholesaleprice>1,200</wholesaleprice></market><market><id>18</id><name>Kisoro Market</name><district>Kisoro</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>4</id><name>Mbarara Market</name><district>Mbarara</district><retailprice>2,000</retailprice><wholesaleprice>1,550</wholesaleprice></market><market><id>179</id><name>Kigumba Market</name><district>Kiryandongo</district><retailprice>1,700</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>8</id><name>Fort Portal Market</name><district>Kabarole</district><retailprice>2,000</retailprice><wholesaleprice>1,500</wholesaleprice></market><market><id>12</id><name>Kabale Market</name><district>Kabale</district><retailprice>1,700</retailprice><wholesaleprice>1,600</wholesaleprice></market><market><id>149</id><name>Mpondwe Market</name><district>Kasese</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>13</id><name>Hoima Market</name><district>Hoima</district><retailprice></retailprice><wholesaleprice></wholesaleprice></market><market><id>150</id><name>Masindi Market</name><district>Masindi</district><retailprice>1,600</retailprice><wholesaleprice>1,200</wholesaleprice></market></item></channel></rss>';
        res.setBody(xmlString);
        
        return res; 
    }
    
    /**
    *   tests scheduling of the data loading operation*/

    static testmethod void testBatchScheduling(){
        //test scheduling
        String cronID = System.scheduleBatch(batchKeywordsExporter, 'Batch Load FIT Prices', 1);
        CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime
                            FROM CronTrigger 
                            WHERE Id = :cronID];
        System.assertEquals(0, ct.TimesTriggered);
        System.debug('Next fire time: ' + ct.NextFireTime);
    }
    
    static testmethod void testBatchDataLoading(){
        Test.startTest();
       
        Menu__c menu = null;
        Integer result = [SELECT Count() FROM Menu__c WHERE Label__c = 'Agroways'];
        if(result == 0){
            menu = new Menu__c(Label__c = 'Agroways');
            insert(menu);
        }
        else{
            menu = [SELECT Id, Label__c FROM Menu__c WHERE Label__c = 'Agroways'];
        }
        Country__c country = new Country__c();
        insert(country);
        Region__c region = new Region__c(Country__c=country.Id, Display_Name__c='North_Region');
        insert(region);
        Market__c market = new Market__c(Market__c='AmuruMarket', Region__c='North_Region');
        insert(market);
        Database.executeBatch(batchKeywordsExporter, 53);
        System.debug(LoggingLevel.DEBUG, 'New Menu Label '+menu.Label__c);  
        Test.stopTest();        
    }
}