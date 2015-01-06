public class LacFarmerPPIProfile {

public ApexPages.StandardController stdController;
public LAC_Farmer_Details__c farmer;
public LAC_Farmer_Details__c farmerName;
public gfsurveys__SubmissionPPIValue__c[]  ppiValue = new List<gfsurveys__SubmissionPPIValue__c >();

public LacFarmerPPIProfile(ApexPages.StandardController controller) {
    this.stdController = controller;
    this.farmer = (LAC_Farmer_Details__c)controller.getRecord();   
                                                 
      LAC_Farmer_Details__c[] farmerNames = [Select Name From LAC_Farmer_Details__c Where Id =:farmer.Id];
        if (farmerNames.size() > 0) {
            farmerName = farmerNames[0];
        }
        }

    public LAC_Farmer_Details__c getLacfdName() {
        return farmerName;
    }
   
     public  List<gfsurveys__SubmissionPPIValue__c> getPpi() {
        if (farmerName!= null) {
        gfsurveys__SubmissionPPIValue__c[] ppiValue = [Select PPI_Table_Used__c, Probability_from_Line__c
                                                     from gfsurveys__SubmissionPPIValue__c
                                                     where gfsurveys__Submission__c in (Select gfsurveys__Submission__c from gfsurveys__Answer__c where gfsurveys__Submission__r.gfsurveys__Survey__r.Name like '%PPI%' and gfsurveys__Value__c =:farmerName.Name)];
            if (ppiValue.size() > 0) {
                return ppiValue;
            }
        }                                             
        return null;
    }
}