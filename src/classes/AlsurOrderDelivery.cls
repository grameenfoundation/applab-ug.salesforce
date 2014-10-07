public class AlsurOrderDelivery {   

    public List <CPA_Order_Allocation__c> searchlist{set; get;}
    public string selectedDept{set;get;}
    public string productname{ set; get;}
    public string productprice{ set;get;}
    public string productimage{ set;get;}
    
    public string getselectedDept(){
      
       return selecteddept;
       
       }
        public void setselecteddept() {
           this.selecteddept = selecteddept;
    }
   public string deptItems{set; }

   public List<SelectOption> getdeptItems() {
            List<SelectOption> options = new List<SelectOption>();
             Schema.DescribeFieldResult fieldResult =CPA_Order_Allocation__c.Association__c.getDescribe();   
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
          for(Schema.picklistEntry f:ple)   
        {   
            options.add(new selectOption(f.getLabel(),f.getValue()));                   
        }   
        return Options; 
}
    public pagereference search(){
      return null;
      }
 
public List<CPA_Order_Allocation__c> searchproduct(){
        searchlist = [select Expected_Delivery_Date__c,Number_of_Kilos__c,Presentacion__c from CPA_Order_Allocation__c limit 10];
       return searchlist; 
}
}