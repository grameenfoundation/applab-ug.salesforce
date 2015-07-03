global class BSS_MonthlyBill implements Schedulable{
	public Set<ID> activeProject = new Set<ID>();	
    public Date todayDate = Date.today();
    public Date lastDate = todayDate.addMonths(-1);
    public Date ancestorDate = todayDate.addMonths(-2);
    public Date billDate = date.newInstance(lastdate.year(), lastdate.month(), 1);
    public Date lastBillDate = date.newInstance(ancestorDate.year(), ancestorDate.month(), 1);
    Decimal sum = 0;
    
    global void execute(SchedulableContext sc){
        
        //create active project list
        for(BSS_Project__c projects : [select Id From BSS_Project__c Where End_Date__c >= LAST_MONTH] ){
            activeProject.add(projects.Id);
        }
        //create active CKWs list
        for(List<BSS_CKW_Project__c> activeCKW : [Select Id, Monthly_Discount__c, CKW__c, Project__c From BSS_CKW_Project__c Where Project__c in :activeProject and Status__c = 'Activo']) {  
            //insert monthly bill header each ckw active    
            for (BSS_CKW_Project__c ckwPrjIds: activeCKW){ 
                for(List<BSS_Monthly_Bill_Header__c> lastMonthDiscounts : [Select Bill_Subtotal__c, Total_survey__c, Total_discounts__c, Total_value__c From BSS_Monthly_Bill_Header__c Where BSS_CKW_Project__c = :ckwPrjIds.Id and Month__c =:lastBillDate]){ 
                 	Integer size = lastMonthDiscounts.size();
                    if(size == 0){
                        BSS_Monthly_Bill_Header__c monthlyBill = new BSS_Monthly_Bill_Header__c();
                        monthlyBill.BSS_CKW_Project__c = ckwPrjIds.Id;
                        monthlyBill.Month__c = billDate;
                        monthlyBill.Total_discounts__c = ckwPrjIds.Monthly_Discount__c;
                        insert monthlyBill;
                    }
                    else{
                        for(BSS_Monthly_Bill_Header__c lastMonthDiscount : lastMonthDiscounts){
                            BSS_Monthly_Bill_Header__c monthlyBill = new BSS_Monthly_Bill_Header__c();
                            monthlyBill.BSS_CKW_Project__c = ckwPrjIds.Id;
                            monthlyBill.Month__c = billDate;
                            if(lastMonthDiscount.Total_survey__c == 0 ) {
                                Decimal sum = lastMonthDiscount.Total_discounts__c + ckwPrjIds.Monthly_Discount__c;
                                monthlyBill.Total_discounts__c = sum;
                                monthlyBill.Notes__c = 'Se adiciona el descuento del mes anterior'+ lastBillDate +'por un valor de $'+lastMonthDiscount.Total_discounts__c;
                            }
                            else if (lastMonthDiscount.Bill_Subtotal__c < lastMonthDiscount.Total_discounts__c){
                                monthlyBill.Total_discounts__c = lastMonthDiscount.Total_discounts__c-lastMonthDiscount.Bill_Subtotal__c+ckwPrjIds.Monthly_Discount__c;
                                monthlyBill.Notes__c = 'Se adiciona saldo restante del descuento del mes anterior'+ lastBillDate +'por un valor de $'+lastMonthDiscount.Total_value__c;
                            }
                            else{
                                monthlyBill.Total_discounts__c = ckwPrjIds.Monthly_Discount__c;
                            }
                        	insert monthlyBill;
                        }
                    }
                }
                //Create active ckw contact list
                for(List<gfsurveys__Mobile_User__c> ckwContacts : [Select gfsurveys__Contact__c From gfsurveys__Mobile_User__c Where Id = :ckwPrjIds.CKW__c]){
                	for(gfsurveys__Mobile_User__c ckwContact : ckwContacts){
                		//Create active project survey list
                		for(List<BSS_Survey_Value__c> activeSurveys : [Select Id, Survey__c, Survey_value__c From BSS_Survey_Value__c Where Project__c = :ckwPrjIds.Project__c]) {
                			for(BSS_Survey_Value__c activeSurvey : activeSurveys){
                				//create list of survey count records per survey per ckw
                				List<aggregateResult> numberOfSurveys = [Select COUNT(Id) i, gfsurveys__Survey__c, gfsurveys__Surveyor__c surveyor  From gfsurveys__Submission__c Where gfsurveys__Survey__c = :activeSurvey.Survey__c and gfsurveys__Surveyor__c = :ckwContact.gfsurveys__Contact__c and gfsurveys__startDate__c = LAST_MONTH GROUP BY gfsurveys__Surveyor__c, gfsurveys__Survey__c];
                				//create list of Monthly bill headers
                				for(List<BSS_Monthly_Bill_Header__c> monthlyBills : [Select Id From BSS_Monthly_Bill_Header__c Where BSS_CKW_Project__c = :ckwPrjIds.Id and Month__c = :billDate]){
                					//insert monthly bill detail per survey per ckw
                					for(BSS_Monthly_Bill_Header__c monthBills : monthlyBills){
                						for(AggregateResult surveyCount : numberOfSurveys) {
                							if((String)surveyCount.get('surveyor') == ckwContact.gfsurveys__Contact__c){
                                            	BSS_Monthly_Bill_Detail__c monthlyBillDetail = new BSS_Monthly_Bill_Detail__c(
                                                BSS_Monthly_Bill_Header__c = monthBills.Id,
                                                Quantity__c = (Decimal)surveyCount.get('i'),
                                                Survey__c = activeSurvey.Id);
                                                insert monthlyBillDetail;
                                            }
                               			}
                           			}
                       			}
                   			}
               			}
           			}
       			}
            }
        }
    }
}