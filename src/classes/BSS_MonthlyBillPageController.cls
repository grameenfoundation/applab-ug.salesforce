public class BSS_MonthlyBillPageController {

	private ApexPages.StandardController stdCtrl {get; set;}
	public BSS_Monthly_Bill_Header__c monthlyBill {get; set;}
	public BSS_CKW_Project__c monthlyBillDetails {get; set;}
	public List<BSS_Monthly_Bill_Detail__c> monthlySurveysDetails {get; set;}
	  
	public BSS_MonthlyBillPageController(ApexPages.StandardController std){
		stdCtrl=std;
		setupmonthlyBill();
	}
	  
	private void setupmonthlyBill(){
		monthlyBill=[Select Id, BSS_CKW_Project__c, Month__c, LastDayBill__c, Total_discounts__c, Bill_Subtotal__c, Total_value__c, Notes__c, CKW_signature__c, Bill_approval__c, Bill_paid__c From BSS_Monthly_Bill_Header__c where Id =:stdCtrl.getId()];
		
		monthlyBillDetails = [Select Id, Organization__c, CKW_Name__c, National_ID__c, ID_expedition_place__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank__c, Bank_Account_Holder__c, Bank_Account_Holder_Id__c, Account_Place__c, Discount_obs__c, Project__r.Name__c
                                                                    From BSS_CKW_Project__c
                                                                    where Id =:monthlyBill.BSS_CKW_Project__c ];
		
		monthlySurveysDetails = [Select Id, Survey_Name__c, Quantity__c, Notes__c
        	                                                        From BSS_Monthly_Bill_Detail__c
                                                                    where BSS_Monthly_Bill_Header__c =:monthlyBill.Id ];
	}

}