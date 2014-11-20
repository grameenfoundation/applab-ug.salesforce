public class AlsurOrderDelivery {   
public String association {get; set;}
public String nameQuery {get; set;}
public List<CPA_Order_Allocation__c> orders {get; set;}
public Association_CPA_Order_Delivery__c allocation { get; set; }

public PageReference executeSearch() {
  Set<ID> delivery = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deliveries : [select CPA_Order_Allocation__c 
                                                        from Association_CPA_Order_Delivery__c]){ 
    delivery.add(deliveries.CPA_Order_Allocation__c);
  }
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
          where Client__c = :nameQuery
          and Association__r.Name =:association
          and Id != :delivery];       
  return null;
}

public AlsurOrderDelivery(){
  
}

public List<SelectOption> getAssociationItems() {
  Set<ID> delivery1 = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deliveries1 : [select CPA_Order_Allocation__c 
                                                  from Association_CPA_Order_Delivery__c]){ 
    delivery1.add(deliveries1.CPA_Order_Allocation__c);
  }
  Set<ID> association1= new Set<ID>();
  for (CPA_Order_Allocation__c associations1 : [select Association__c 
                                        from CPA_Order_Allocation__c 
                                        where Id != :delivery1]){ 
    association1.add(associations1.Association__c);
  }
  list<Association__c> associations = [Select Name 
                                        from Association__c 
                                        where Id = :association1];
  List<SelectOption> options = new List<SelectOption>();
  for (Association__c association : associations) {
    options.add(new SelectOption(association.Name, association.Name));
  }
  return options;
}

public List<SelectOption> getclientItems() {
  Set<ID> delivery2 = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deliveries2 : [select CPA_Order_Allocation__c 
                                                  from Association_CPA_Order_Delivery__c]){ 
    delivery2.add(deliveries2.CPA_Order_Allocation__c);
  }
  Set<String> client = new Set<String>();
  for (CPA_Order_Allocation__c clients2 : [select Client__c
                                        from CPA_Order_Allocation__c 
                                        where Id != :delivery2]){ 
    client.add(clients2.Client__c);
  }
  List<SelectOption> options = new List<SelectOption>();
  List<Client__c> clients = new List<Client__c>();
  if (association == null || String.isEmpty(association)) {
    options.add(new SelectOption('NoClientSelected', 'Seleccione una asociación primero'));
  }
  else {
    clients =  [Select Name from Client__c where Name = :client];
  }
  for (Client__c nameQuery : clients) {
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