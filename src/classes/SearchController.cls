/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Controller class for CKW Search 3.0 client web calls
 *  Tests are in SearchServerTests class
 **/
global class SearchController {

    public String getCountryCode() {
        String jsonString = ApexPages.currentPage().getParameters().get('data');
        return SearchGetCountryCodeHelper.getCountryCode(jsonString);
    }
    
    public String getKeywords() {
        String jsonString = ApexPages.currentPage().getParameters().get('data');
        return SearchGetKeywordsHelper.updateKeywords(jsonString);
    }
    
    public String getImages() {
        String jsonString = ApexPages.currentPage().getParameters().get('data');
        return SearchGetImagesHelper.getImages(jsonString);
    }
    
    public String getFarmers() {
        String jsonString = ApexPages.currentPage().getParameters().get('data');
        return SearchGetFarmersHelper.getFarmers(jsonString);
    }

    public String getData() {
        String jsonString = ApexPages.currentPage().getParameters().get('data');
        String requestType = ApexPages.currentPage().getParameters().get('method');
        
        if(requestType != null ) {
            if (requestType.equals('countryCode')) {
                String response = SearchGetCountryCodeHelper.getCountryCode(jsonString);
                System.debug(response);
                return response;
            }
            else if (requestType.equals('images')) {
                String response = SearchGetImagesHelper.getImages(jsonString);
                System.debug(response);
                return response;
            }
            else if (requestType.equals('keywords')) {
                String response = SearchGetKeywordsHelper.updateKeywords(jsonString);
                System.debug(response);
                return response;
            }
            else if (requestType.equals('farmers')) {
                String response = SearchGetFarmersHelper.getFarmers(jsonString);
                System.debug(response);
                return response;
            }
            else if (requestType.equals('searchLogs')) {
                String response = SearchCreateLogs.createSearchLogs(jsonString);
                System.debug(response);
                return response;
            }
            else if (requestType.equals('images')) {
                String response = SearchGetImagesHelper.getImages(jsonString);
                System.debug(response);
                return response;
            }
        }
        return '';
    }
    
    public String submissionResult {get; set;}
    
    //due to DML not allowed issues, search logs creation is handled separately through this method
    public void submitLogs(){
        String response = SearchCreateLogs.createSearchLogs(String.valueOf(ApexPages.currentPage().getParameters().get('data')));
        System.debug(response);
        submissionResult = response;
    }
}