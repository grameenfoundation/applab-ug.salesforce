@RestResource(urlMapping='/Marketlink/*')
global with sharing class MarketLinkSync {

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String personid = 'Person-133800';
        Person__c result = [SELECT Id, Name, First_Name__c FROM Person__c WHERE Name = :personid];
        return result.First_Name__c;
    }
}