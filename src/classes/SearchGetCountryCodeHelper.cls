/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Tests are in SearchServerTests class 
 **/
 public class SearchGetCountryCodeHelper {
 
    public static String getCountryCode(String jsonString) {
        // The response wrapper
        CountryCodeResponseWrapper response = new CountryCodeResponseWrapper();
        
        // Build the request object
        CountryCodeRequestWrapper request = null;
        try {
            request = (CountryCodeRequestWrapper)JSON.deserialize(jsonString, CountryCodeRequestWrapper.class);
            String countryCode = getPersonCountryCode(request);
            response.resultCode = '0';
            response.resultMessage = 'Country Code found';
            response.countryCode = countryCode;
            return JSON.serializePretty(response);
        }
        catch(Exception e) {
            response.resultCode = '10';
            response.resultMessage = 'Request could not be decoded';
            return JSON.serializePretty(response);
        }
    }
    
    private static String getPersonCountryCode(CountryCodeRequestWrapper request) {
        List<Person__c> people = new List<Person__c>();
        people = [Select Country__r.ISO_Standard_Code__c from Person__c where Handset__r.IMEI__c =:request.imei];
        if (people.size() > 0) {System.debug('countrycode='+people[0].Country__r.ISO_Standard_Code__c);
            String countryCode = people[0].Country__r.ISO_Standard_Code__c;
            if (countryCode == null) {
                return 'UG';
            }
            return countryCode;
        }
        else {
            // No person found, return UG by default
            return 'UG';
        }
    }
    
    class CountryCodeRequestWrapper {
        String request {get; set;}
        String imei {get; set;}
    }
    
    class CountryCodeResponseWrapper {
        String resultCode {get;set;}
        String resultMessage {get;set;}
        String countryCode {get; set;}
    }
 }