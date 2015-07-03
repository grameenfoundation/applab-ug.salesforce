public class CQT_TasterEditDeleteController {

	public String editTasterid {get;set;} // commandlink edit property
    public String delTasterid {get;set;} // commandlink delete property
    
    list<CQT_Taster__c> listTasters = new list<CQT_Taster__c>();
   	list<CQT_Taster__c> listTasters1 = new list<CQT_Taster__c>();
    
    // Displaying tasters on vfpage
    public list<CQT_Taster__c> getlistTasters() {
      listTasters = [select Name, firstName__c, lastName__c, phoneNumber__c, eMail__c from CQT_Taster__c];
      return listTasters;
    }
    
     // To redirect to editpage.
     public PageReference editTaster() {
       pagereference ref = new pagereference('/apex/CQT_SaveTasterPage?id='+editTasterid);
       ref.setRedirect(False);
       return ref;   
    }
    
    // to delete the selected record
    public pagereference deleteTaster() {
        listTasters1 = [Select id, Name from CQT_Taster__c where id=: delTasterid];
        delete listTasters1;
        pagereference ref = new pagereference('/apex/CQT_TasterEditDeletePage');
        ref.setredirect(True);
        return ref;   
        //return null;
        //return new pagereference(page.CQT_TasterEditDeletePage.getUrl());
    }
    
    // to redirect to insert page.
    public PageReference insertNewTaster() {
        pagereference ref = new pagereference('/apex/CQT_InsertNewTasterPage');
        ref.setRedirect(True);
        return ref;
    }   
    
}