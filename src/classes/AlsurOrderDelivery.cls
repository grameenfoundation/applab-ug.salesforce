public class AlsurOrderDelivery {   
public String asociation {get; set;}
public String nameQuery {get; set;}
public List<CPA_Order_Allocation__c> orders {get; set;}
public Association_CPA_Order_Delivery__c allocation { get; set; }

public PageReference executeSearch() {
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
          where Id = :nameQuery];       
  return null;
}

public AlsurOrderDelivery(){
  
}

public List<SelectOption> getAssociationItems() {
  Set<ID> del1 = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deli1 : [select CPA_Order_Allocation__c 
                                                  from Association_CPA_Order_Delivery__c]){ 
    del1.add(deli1.CPA_Order_Allocation__c);
  }
  Set<ID> aso= new Set<ID>();
  for (CPA_Order_Allocation__c asos : [select Association__c 
                                        from CPA_Order_Allocation__c 
                                        where Id != :del1]){ 
    aso.add(asos.Association__c);
  }
  list<Association__c> associations = [Select Name 
                                        from Association__c 
                                        where Id = :aso];
  List<SelectOption> options = new List<SelectOption>();
  for (Association__c asociation : associations) {
    options.add(new SelectOption(asociation.Name, asociation.Name));
  }
  return options;
}

public List<SelectOption> getclientItems() {
  Set<ID> del = new Set<ID>();
  for (Association_CPA_Order_Delivery__c deli : [select CPA_Order_Allocation__c 
                                                  from Association_CPA_Order_Delivery__c]){ 
    del.add(deli.CPA_Order_Allocation__c);
  }
  List<SelectOption> options = new List<SelectOption>();
  List<CPA_Order_Allocation__c> clients = new List<CPA_Order_Allocation__c>();
  if (asociation == null || String.isEmpty(asociation)) {
    options.add(new SelectOption('NoClientSelected', 'Seleccione una asociación primero'));
  }
  else {
    clients =  [Select Id, Client__c from CPA_Order_Allocation__c where Association__r.Name = :asociation and Id != :del ];
  }
  for (CPA_Order_Allocation__c nameQuery : clients) {
    options.add(new SelectOption(nameQuery.Id, nameQuery.Client__c));
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