trigger CBL_FoodSecurity_UpdateDataCbl2 on CBL_FoodSecurity__c (after insert) {
    Set<Id> food_Ids = new Set<Id>();
    Set<Id> cbl_Ids = new Set<Id>();
    
    //get a list with Baseline id related to food security rows inserted
    for (CBL_FoodSecurity__c newRow : Trigger.new) {
        food_Ids.add(newRow.Id);
            cbl_Ids.add(newRow.Baseline__c);
    }

    //get a list with food security rows completed (field Baseline__r.Farmer__c)
    for(List<CBL_FoodSecurity__c> foods : [SELECT Id, Baseline__c, Baseline__r.Farmer__c, ateTheSameLackMoney__c, howOftenAteLessFood__c, howOftenAteTheSame__c, howOftenHungryDidntAte__c, howOftenLessFood__c, howOftenSkippedMeals__c, howOftenStoppedEating__c, howOftenWorried__c, howOfterNotEnoughFood__c, hungryDidnEatLackMoney__c, lessFoodLackMoney__c, lostWeightLackMoney__c, notEnoughFoodLackMoney__c, skippedMealsLackMoney__c, stoppedEatingLackMoney__c, thinkAteLessFood__c, worriedBuyingFood__c, Submission__c
                FROM CBL_FoodSecurity__c  WHERE Id IN :food_Ids]){
        //get the farmers2 to update only the food security data
        for(List<CBL2_Farmer__c> farmers : [SELECT Id, food_ateTheSameLackMoney__c, food_howOftenAteLessFood__c, food_howOftenAteTheSame__c, food_howOftenHungryDidntAte__c, food_howOftenLessFood__c, food_howOftenSkippedMeals__c, food_howOftenStoppedEating__c, food_howOftenWorried__c, food_howOfterNotEnoughFood__c, food_hungryDidnEatLackMoney__c, food_lessFoodLackMoney__c, food_lostWeightLackMoney__c, food_notEnoughFoodLackMoney__c, food_skippedMealsLackMoney__c, food_stoppedEatingLackMoney__c, food_thinkAteLessFood__c, food_worriedBuyingFood__c, LAC_Farmer_Details__c, Submission_SegAlim__c 
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN (SELECT Farmer__c FROM CBL_CoffeeBaseline__c WHERE Id IN: cbl_Ids)]){
            for(CBL_FoodSecurity__c food: foods ){
                for(CBL2_Farmer__c farmer: farmers){
                    //update if the LAC_Farmer_Details are the same
                    if(farmer.LAC_Farmer_Details__c == food.Baseline__r.Farmer__c){
                        farmer.food_ateTheSameLackMoney__c=food.ateTheSameLackMoney__c;
                        farmer.food_howOftenAteLessFood__c=food.howOftenAteLessFood__c;
                        farmer.food_howOftenAteTheSame__c=food.howOftenAteTheSame__c;
                        farmer.food_howOftenHungryDidntAte__c=food.howOftenHungryDidntAte__c;
                        farmer.food_howOftenLessFood__c=food.howOftenLessFood__c;
                        farmer.food_howOftenSkippedMeals__c=food.howOftenSkippedMeals__c;
                        farmer.food_howOftenStoppedEating__c=food.howOftenStoppedEating__c;
                        farmer.food_howOftenWorried__c=food.howOftenWorried__c;
                        farmer.food_howOfterNotEnoughFood__c=food.howOfterNotEnoughFood__c;
                        farmer.food_hungryDidnEatLackMoney__c=food.hungryDidnEatLackMoney__c;
                        farmer.food_lessFoodLackMoney__c=food.lessFoodLackMoney__c;
                        farmer.food_lostWeightLackMoney__c=food.lostWeightLackMoney__c;
                        farmer.food_notEnoughFoodLackMoney__c=food.notEnoughFoodLackMoney__c;
                        farmer.food_skippedMealsLackMoney__c=food.skippedMealsLackMoney__c;
                        farmer.food_stoppedEatingLackMoney__c=food.stoppedEatingLackMoney__c;
                        farmer.food_thinkAteLessFood__c=food.thinkAteLessFood__c;
                        farmer.food_worriedBuyingFood__c=food.worriedBuyingFood__c;
                        farmer.Submission_SegAlim__c= food.Submission__c; 
                    }                                      
                }
            }
            //update all the farmers with new food security data
            try{
                update farmers;
            }
            catch(system.Exception e){
                system.debug (e);
            }
        }
    }
}