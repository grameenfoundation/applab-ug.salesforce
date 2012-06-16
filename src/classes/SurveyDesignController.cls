public with sharing class SurveyDesignController {

    public SurveyDesignController(ApexPages.StandardController controller) {

    }
    
    public SurveyDesignController() {

    }

	/**
    * Add the user's locale to the query string
    **/
    public String getLocale() {
        return UserInfo.getLocale();
    } 
    
    /**
    * Add the user's language to the query string
    **/
    public String getLanguage() {
        return UserInfo.getLanguage();
    }
    
    /**
    * Add a random number to prevent browser caching
    **/
    public double getRandom() {
        return Math.random();
    }
    
    static testMethod void testController() {
    	SurveyDesignController controller = new SurveyDesignController();
    	controller.getLocale();
    	controller.getLanguage();
    	controller.getRandom();
    }
}