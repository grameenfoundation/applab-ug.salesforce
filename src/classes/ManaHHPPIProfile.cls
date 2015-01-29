public class ManaHHPPIProfile {

public ApexPages.StandardController stdController;
public Mana_Household__c houseHold;
public Mana_Household__c houseHoldName;
public gfsurveys__SubmissionPPIValue__c[]  ppiValue = new List<gfsurveys__SubmissionPPIValue__c >();

public ManaHHPPIProfile(ApexPages.StandardController controller) {
    this.stdController = controller;
    this.houseHold = (Mana_Household__c)controller.getRecord();   
                                                 
      Mana_Household__c[] houseHoldNames = [Select Name From Mana_Household__c Where Id =:houseHold.Id];
        if (houseHoldNames.size() > 0) {
            houseHoldName = houseHoldNames[0];
        }
        }

    public Mana_Household__c getHouseHoldName() {
        return houseHoldName;
    }
   
     public  List<gfsurveys__SubmissionPPIValue__c> getPpi() {
        if (houseHoldName!= null) {
        gfsurveys__SubmissionPPIValue__c[] ppiValue = [Select PPI_Table_Used__c, Probability_from_Line__c
                                                     from gfsurveys__SubmissionPPIValue__c
                                                     where gfsurveys__Submission__c in (Select gfsurveys__Submission__c from gfsurveys__Answer__c where gfsurveys__Submission__r.gfsurveys__Survey__r.Name like '%PPI%' and gfsurveys__Value__c =:houseHoldName.Name)];
            if (ppiValue.size() > 0) {
                return ppiValue;
            }
        }                                             
        return null;
    }
}