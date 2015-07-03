/**
*
* Copyright (c) 2015 AppLab, Grameen Foundation
*
* TestClass for UpdateNewSearchWeatherTest Updates CKW 3.0 Search
* 
**/

@isTest
private class UpdateNewSearchWeatherTest {
    
  static testMethod void testUpdateWeather() {
      
      Menu__c ckwSearch= new Menu__c();
      ckwSearch.Label__c = 'CKW Search';
      insert(ckwSearch);
      
      Menu_Item__c dailyForecast = new Menu_Item__c();
      dailyForecast.Label__c = 'Daily and 5 day Forecast';
      dailyForecast.Menu__c = ckwSearch.Id;
      insert(dailyForecast);
      
      Menu_Item__c easternUganda = new Menu_Item__c();
      easternUganda.Label__c = 'Eastern Uganda';
      easternUganda.Menu__c = ckwSearch.Id;
      easternUganda.Parent_Item__c= dailyForecast.Id;
      insert(easternUganda);
      
      Menu_Item__c Iganga = new Menu_Item__c();
      Iganga.Label__c = 'Iganga';
      Iganga.Menu__c = ckwSearch.Id;
      Iganga.Parent_Item__c= easternUganda.Id;
      insert(Iganga);
      
      Menu_Item__c Bukanga = new Menu_Item__c();
      Bukanga.Label__c = 'Bukanga';
      Bukanga.Menu__c = ckwSearch.Id;
      Bukanga.Parent_Item__c= Iganga.Id;
      Bukanga.Attribution__c = 'Information provided by the ICON Weather Feed Service';
      Bukanga.Content__c = 'Weather: Today Friday 01/05/2015, cloudy. Temperatures  : Low - High = 18.0C - 28.0C. Saturday 02/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 28.0C. There is a high chance of rain.      Sunday 03/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 29.0C. There is a high chance of rain.      Monday 04/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 29.0C. There is a high chance of rain.      Tuesday 05/05/2015, rainy and windy. Temperatures : Low - High = 17.0C - 28.0C. There is a high chance of rain.      Wednesday 06/05/2015, rainy. Temperatures : Low - High = 17.0C - 27.0C. There is a high chance of rain.';
      insert(Bukanga);
      
      Menu__c newSearch= new Menu__c();
      newSearch.Label__c = 'CKW 3.0 Search';
      insert(newSearch);
      
      Menu_Item__c dailyForecast2 = new Menu_Item__c();
      dailyForecast2.Label__c = 'Daily and 5 day Forecast';
      dailyForecast2.Menu__c = newSearch.Id;
      insert(dailyForecast2);
      
      Menu_Item__c easternUganda2 = new Menu_Item__c();
      easternUganda2.Label__c = 'Eastern Uganda';
      easternUganda2.Menu__c = newSearch.Id;
      easternUganda2.Parent_Item__c= dailyForecast2.Id;
      insert(easternUganda2);
      
      Menu_Item__c Iganga2 = new Menu_Item__c();
      Iganga2.Label__c = 'Iganga';
      Iganga2.Menu__c = newSearch.Id;
      Iganga2.Parent_Item__c= easternUganda2.Id;
      insert(Iganga2);
      
      Menu_Item__c Bukanga2 = new Menu_Item__c();
      Bukanga2.Label__c = 'Bukanga';
      Bukanga2.Menu__c = newSearch.Id;
      Bukanga2.Parent_Item__c= Iganga2.Id;
      Bukanga2.Attribution__c = 'Information provided by the ICON Weather Feed Service';
      Bukanga2.Content__c = '########Weather: Today Friday 01/05/2015, cloudy. Temperatures  : Low - High = 18.0C - 28.0C. Saturday 02/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 28.0C. There is a high chance of rain.      Sunday 03/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 29.0C. There is a high chance of rain.      Monday 04/05/2015, rainy and windy. Temperatures : Low - High = 18.0C - 29.0C. There is a high chance of rain.      Tuesday 05/05/2015, rainy and windy. Temperatures : Low - High = 17.0C - 28.0C. There is a high chance of rain.      Wednesday 06/05/2015, rainy. Temperatures : Low - High = 17.0C - 27.0C. There is a high chance of rain.';
      insert(Bukanga2);     
      
      System.debug('ckw search 3.0 '+ Bukanga2.Content__c);
      Bukanga2.Content__c=Bukanga.Content__c;
      UpdateNewSearchWeather.updateWeather();
           
      System.debug('ckw search '+ Bukanga.Content__c);
      System.debug('ckw search 3.0 '+ Bukanga2.Content__c);
      System.assertEquals(Bukanga.Content__c,Bukanga2.Content__c);
      
  }
    
}