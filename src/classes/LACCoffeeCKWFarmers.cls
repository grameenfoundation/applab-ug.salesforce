public class LACCoffeeCKWFarmers {

public ApexPages.StandardController stdController;
public LAC_Coffee_CKW__c coffeeCKW;
public LAC_Farmer_Details__c[] farmers = new List<LAC_Farmer_Details__c>();
public LAC_Coffee_CKW__c ckwId;

public LACCoffeeCKWFarmers(ApexPages.StandardController controller) {
    this.stdController = controller;
    this.coffeeCKW = (LAC_Coffee_CKW__c)controller.getRecord();   
                                                 
    LAC_Coffee_CKW__c[] ckwIds = [Select contact__c From LAC_Coffee_CKW__c Where Id =:coffeeCKW.Id];
    if (ckwIds.size() > 0) {
        ckwId = ckwIds[0];
    }
}

public LAC_Coffee_CKW__c getCkwId() {
    return ckwId;
}


public  List<LAC_Farmer_Details__c> getFarmers() {
    if (coffeeCKW != null) {
        LAC_Farmer_Details__c[] farmers = [Select Contact__r.Contact_Full_Name__c,Name
                                                     from LAC_Farmer_Details__c
                                                     where interviewer__c=:ckwId.contact__c];
        if (farmers.size() > 0) {
            return farmers;
        }
    }
    return null;
}
}