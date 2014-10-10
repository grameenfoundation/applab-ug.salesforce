public class AlsurOrderAssignment {

    public CPA_Order_Allocation__c allocation { get; set; }
    public List<CPA_Order_Allocation__c> currentAllocations { get; set; }
    public String association { get; set; }
    public String order {get; set;}
    public CPA_Order__c orderObject { get; set; }
    public Map<Id, CPA_Order__c> orderObjects { get; set; }
    
    public AlsurOrderAssignment() {
        allocation = new CPA_Order_Allocation__c(Number_of_Units_of_Presentation__c=0.00);
        orderObjects = new Map<Id, CPA_Order__c>();
    }
    public void findOrder() {
        System.debug(orderObjects.size());
        orderObject = orderObjects.get(order);System.debug('we got here');
        currentAllocations = [Select Id,
                                    Association__c,
                                    Association__r.Name,
                                    Number_of_Units_of_Presentation__c,
                                    Number_of_Kilos__c,
                                    Number_of_Baskets__c
                                From
                                    CPA_Order_Allocation__c
                                where
                                    CPA_Order__c=:order];
    }

    public List<SelectOption> getOrderItems() {

        List<CPA_Order__c> orders = [Select Id,
                                            Client__c,
                                            Product_Name__c,
                                            Unallocated_Units_of_Presentation__c,
                                            Unallocated_Number_of_Kilos__c,
                                            Unallocated_Number_of_Baskets__c,
                                            Client_Product_Association__c,
                                            Order_Code__c,
                                            Expected_Delivery_Date__c,
                                            Unit_of_Presentation__c,
                                            Presentacion__c
                                        from 
                                            CPA_Order__c
                                        where
                                            Expected_Delivery_Date__c = LAST_N_DAYS:5
                                        and 
                                            Unallocated_Units_of_Presentation__c > 0];

        orderObjects.putAll(orders);
        System.debug(orderObjects.size());
        List<SelectOption> options = new List<SelectOption>();
        for (CPA_Order__c order : orders) {
            options.add(new SelectOption(order.Id, order.Order_Code__c));
        }
        return options;
    }
    
    public PageReference saveAllocation() {
        allocation.CPA_Order__c = order;
        allocation.Association__c = association;
        insert allocation;
        PageReference currentPage = ApexPages.currentPage();
        currentPage.setRedirect(true);
        return currentPage;
    }
    public List<SelectOption> getAssociationItems() {
        list<Association__c> associations = [Select Id, Name from Association__c];
        List<SelectOption> options = new List<SelectOption>();
        for (Association__c association : associations) {
            options.add(new SelectOption(association.Id, association.Name));
        }
        return options;
    }
}