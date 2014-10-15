public class AlsurOrderDelivery {   
public String nameQuery {get; set;}
public List<CPA_Order_Allocation__c> orders {get; set;}
  
public PageReference executeSearch()
 {
  String queryStr='%' + nameQuery + '%';
  orders=[select Id,
                   Association__c,
                   Association__r.Name,
                   Number_of_Units_of_Presentation__c,
                   Number_of_Kilos__c,
                   Expected_Delivery_Date__c
            from CPA_Order_Allocation__c
            where Association__r.Name like :queryStr];
            
  return null;
}
  
public AlsurOrderDelivery(){
  // if query appears in URL, execute it
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
}