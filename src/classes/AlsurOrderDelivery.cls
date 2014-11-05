public class AlsurOrderDelivery {   
public String nameQuery {get; set;}
public List<CPA_Order_Allocation__c> orders {get; set;}
public Association_CPA_Order_Delivery__c allocation { get; set; }

public PageReference executeSearch() {
  Set<ID> del = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deli : [select CPA_Order_Allocation__c from Association_CPA_Order_Delivery__c]){ 
    del.add(deli.CPA_Order_Allocation__c);
  }
  String queryStr='%' + nameQuery + '%';
  orders=[select Id,
                Number_of_Units_of_Presentation__c,
                Number_of_Kilos__c,
                Expected_Delivery_Date__c,
                CPA_Order__r.Presentacion__c,
                CPA_Order__r.Unit_of_Presentation__c,
                Client__c,
                Product_Name__c,
                Price_per_Kilo__c,
                Order_Code__c,
                Number_of_Baskets__c
          from CPA_Order_Allocation__c
          where Association__r.Name like :queryStr 
          and Id != :del];       
  return null;
}

public AlsurOrderDelivery(){
  String urlQuery=ApexPages.currentPage().getParameters().get('query');
  if ( (null!=urlQuery) && (0!=urlQuery.length()) )
  {
   nameQuery=urlQuery;
   executeSearch();
  }
}

public List<SelectOption> getAssociationItems() {
  list<Association__c> associations = [Select Id, Name from Association__c];
    List<SelectOption> options = new List<SelectOption>();
    for (Association__c nameQuery : associations) {
      options.add(new SelectOption(nameQuery.Name, nameQuery.Name));
    }
  return options;
}
public PageReference save() {
  for (CPA_Order_Allocation__c ord: orders){ 
    Association_CPA_Order_Delivery__c allocation = new Association_CPA_Order_Delivery__c(
    CPA_Order_Allocation__c = ord.Id,
    Number_of_Kilos__c = ord.Number_of_Kilos__c,
    Number_of_Units_of_Presentation__c = ord.Number_of_Units_of_Presentation__c,
    Delivery_Date__c = ord.Expected_Delivery_Date__c,
    Unit_of_Presentation__c = ord.CPA_Order__r.Unit_of_Presentation__c,
    Number_of_Baskets__c = ord.Number_of_Baskets__c,
    Delivery_Receipt_Number__c = '0');
  insert allocation;
  }
  PageReference currentPage = ApexPages.currentPage();
  currentPage.setRedirect(true);
  return currentPage;
}
}
