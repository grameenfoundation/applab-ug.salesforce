trigger CBL_SocioEconomic_UpdateDataCbl2 on CBL_SocioEconomic__c (after insert) {
    Set<Id> socioe_Ids = new Set<Id>();
    Set<Id> cbl_Ids = new Set<Id>();
    
    //get a list with Baseline id related to socio economic rows inserted
    for (CBL_SocioEconomic__c newRow : Trigger.new) {
        socioe_Ids.add(newRow.Id);
        cbl_Ids.add(newRow.Baseline__c);
    }
    //get a list with socio economic rows completed (field Baseline__r.Farmer__c)
    for(List<CBL_SocioEconomic__c> socioes : [SELECT Id, Baseline__c, Baseline__r.Farmer__c, advocadoArea__c, advocadoAreaUnits__c, bananaPlantainArea__c, bananaPlantainAreaUnits__c, bankAccount__c, basicGrainsArea__c, basicGrainsAreaUnits__c, birdsRabbitsGuineaPigs__c, bullsCowsCalfs__c, cardamomArea__c, cardamomAreaUnit__c, childrenStudying__c, citrusArea__c, citrusAreaUnits__c, cocoaArea__c, cocoaAreaUnits__c, creditDestination__c, creditInterestRate__c, daysOfWageAgriculture__c, debtPaymentCapacitySituation__c, debtPaymentSituation__c, debts__c, debtsFinancingSource__c, debtsFinancingSource_contr__c, electricEnergy__c, forestArea__c, forestAreaUnits__c, grassPodderArea__c, grassPodderAreaUnits__c, hives__c, homeOwnerShip__c, horsesMulesDonkeys__c, householdIncomeSources__c, knowsHowToReadWrite__c, landLine__c, lastYearIncomeReduction__c, numberOfBedrooms__c, otherActivities__c, otherAgriculturalActivities__c, pepperArea__c, pepperAreaUnits__c, percentageOfIncomeAgriculture__c, percentageOfIncomeCoffee__c, personsInHousehold__c, pigsSheepsGoatsAlpacas__c, pondSquareMeters__c, populationGroup__c, savingsWay__c, schoolingYears__c, sewageDisposalSystem__c, socialSecutiryProgram__c, sourceOfEnergyCook__c, sugarCainArea__c, sugarCainAreaUnits__c, typeOfStove__c, vegetablesArea__c, vegetablesAreaUnits__c, waterSupply__c, whoDoesntStudy__c, whoRecievesIncomeAndDecides__c, woodStoveLocation__c, Submission__c
                FROM CBL_SocioEconomic__c WHERE Id IN :socioe_Ids]){
        //get the farmers2 to update only the socioeconomic data
        for(List<CBL2_Farmer__c> farmers : [SELECT Id, socioe_advocadoArea__c, socioe_advocadoAreaUnits__c, socioe_bananaPlantainArea__c, socioe_bananaPlantainAreaUnits__c, socioe_bankAccount__c, socioe_basicGrainsArea__c, socioe_basicGrainsAreaUnits__c, socioe_birdsRabbitsGuineaPigs__c, socioe_bullsCowsCalfs__c, socioe_cardamomArea__c, socioe_cardamomAreaUnit__c, socioe_childrenStudying__c, socioe_citrusArea__c, socioe_citrusAreaUnits__c, socioe_cocoaArea__c, socioe_cocoaAreaUnits__c, socioe_creditDestination__c, socioe_creditInterestRate__c, socioe_daysOfWageAgriculture__c, socioe_debtPaymentCapacitySituation__c, socioe_debtPaymentSituation__c, socioe_debts__c, socioe_debtsFinancingSource__c, socioe_debtsFinancingSource_contr__c, socioe_electricEnergy__c, socioe_forestArea__c, socioe_forestAreaUnits__c, socioe_grassPodderArea__c, socioe_grassPodderAreaUnits__c, socioe_hives__c, socioe_homeOwnerShip__c, socioe_horsesMulesDonkeys__c, socioe_householdIncomeSources__c, socioe_knowsHowToReadWrite__c, socioe_landLine__c, socioe_lastYearIncomeReduction__c, socioe_numberOfBedrooms__c, socioe_otherActivities__c, socioe_otherAgriculturalActivities__c, socioe_pepperArea__c, socioe_pepperAreaUnits__c, socioe_percentageOfIncomeAgriculture__c, socioe_percentageOfIncomeCoffee__c, socioe_personsInHousehold__c, socioe_pigsSheepsGoatsAlpacas__c, socioe_pondSquareMeters__c, socioe_populationGroup__c, socioe_savingsWay__c, socioe_schoolingYears__c, socioe_sewageDisposalSystem__c, socioe_socialSecutiryProgram__c, socioe_sourceOfEnergyCook__c, socioe_sugarCainArea__c, socioe_sugarCainAreaUnits__c, socioe_typeOfStove__c, socioe_vegetablesArea__c, socioe_vegetablesAreaUnits__c, socioe_waterSupply__c, socioe_whoDoesntStudy__c, socioe_whoRecievesIncomeAndDecides__c, socioe_woodStoveLocation__c, LAC_Farmer_Details__c, Submission_SocioE__c 
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN (SELECT Farmer__c FROM CBL_CoffeeBaseline__c WHERE Id IN: cbl_Ids)]){
            for(CBL_SocioEconomic__c socio: socioes ){
                for(CBL2_Farmer__c farmer: farmers){
                    //update if the LAC_Farmer_Details are the same
                    if(farmer.LAC_Farmer_Details__c == socio.Baseline__r.Farmer__c){
		            	farmer.socioe_advocadoArea__c=socio.advocadoArea__c;
						farmer.socioe_advocadoAreaUnits__c=socio.advocadoAreaUnits__c;
						farmer.socioe_bananaPlantainArea__c=socio.bananaPlantainArea__c;
						farmer.socioe_bananaPlantainAreaUnits__c=socio.bananaPlantainAreaUnits__c;
						farmer.socioe_bankAccount__c=socio.bankAccount__c;
						farmer.socioe_basicGrainsArea__c=socio.basicGrainsArea__c;
						farmer.socioe_basicGrainsAreaUnits__c=socio.basicGrainsAreaUnits__c;
						farmer.socioe_birdsRabbitsGuineaPigs__c=socio.birdsRabbitsGuineaPigs__c;
						farmer.socioe_bullsCowsCalfs__c=socio.bullsCowsCalfs__c;
						farmer.socioe_cardamomArea__c=socio.cardamomArea__c;
						farmer.socioe_cardamomAreaUnit__c=socio.cardamomAreaUnit__c;
						farmer.socioe_childrenStudying__c=socio.childrenStudying__c;
						farmer.socioe_citrusArea__c=socio.citrusArea__c;
						farmer.socioe_citrusAreaUnits__c=socio.citrusAreaUnits__c;
						farmer.socioe_cocoaArea__c=socio.cocoaArea__c;
						farmer.socioe_cocoaAreaUnits__c=socio.cocoaAreaUnits__c;
						farmer.socioe_creditDestination__c=socio.creditDestination__c;
						farmer.socioe_creditInterestRate__c=socio.creditInterestRate__c;
						farmer.socioe_daysOfWageAgriculture__c=socio.daysOfWageAgriculture__c;
						farmer.socioe_debtPaymentCapacitySituation__c=socio.debtPaymentCapacitySituation__c;
						farmer.socioe_debtPaymentSituation__c=socio.debtPaymentSituation__c;
						farmer.socioe_debts__c=socio.debts__c;
						farmer.socioe_debtsFinancingSource__c=socio.debtsFinancingSource__c;
						farmer.socioe_debtsFinancingSource_contr__c=socio.debtsFinancingSource_contr__c;
						farmer.socioe_electricEnergy__c=socio.electricEnergy__c;
						farmer.socioe_forestArea__c=socio.forestArea__c;
						farmer.socioe_forestAreaUnits__c=socio.forestAreaUnits__c;
						farmer.socioe_grassPodderArea__c=socio.grassPodderArea__c;
						farmer.socioe_grassPodderAreaUnits__c=socio.grassPodderAreaUnits__c;
						farmer.socioe_hives__c=socio.hives__c;
						farmer.socioe_homeOwnerShip__c=socio.homeOwnerShip__c;
						farmer.socioe_horsesMulesDonkeys__c=socio.horsesMulesDonkeys__c;
						farmer.socioe_householdIncomeSources__c=socio.householdIncomeSources__c;
						farmer.socioe_knowsHowToReadWrite__c=socio.knowsHowToReadWrite__c;
						farmer.socioe_landLine__c=socio.landLine__c;
						farmer.socioe_lastYearIncomeReduction__c=socio.lastYearIncomeReduction__c;
						farmer.socioe_numberOfBedrooms__c=socio.numberOfBedrooms__c;
						farmer.socioe_otherActivities__c=socio.otherActivities__c;
						farmer.socioe_otherAgriculturalActivities__c=socio.otherAgriculturalActivities__c;
						farmer.socioe_pepperArea__c=socio.pepperArea__c;
						farmer.socioe_pepperAreaUnits__c=socio.pepperAreaUnits__c;
						farmer.socioe_percentageOfIncomeAgriculture__c=socio.percentageOfIncomeAgriculture__c;
						farmer.socioe_percentageOfIncomeCoffee__c=socio.percentageOfIncomeCoffee__c;
						farmer.socioe_personsInHousehold__c=socio.personsInHousehold__c;
						farmer.socioe_pigsSheepsGoatsAlpacas__c=socio.pigsSheepsGoatsAlpacas__c;
						farmer.socioe_pondSquareMeters__c=socio.pondSquareMeters__c;
						farmer.socioe_populationGroup__c=socio.populationGroup__c;
						farmer.socioe_savingsWay__c=socio.savingsWay__c;
						farmer.socioe_schoolingYears__c=socio.schoolingYears__c;
						farmer.socioe_sewageDisposalSystem__c=socio.sewageDisposalSystem__c;
						farmer.socioe_socialSecutiryProgram__c=socio.socialSecutiryProgram__c;
						farmer.socioe_sourceOfEnergyCook__c=socio.sourceOfEnergyCook__c;
						farmer.socioe_sugarCainArea__c=socio.sugarCainArea__c;
						farmer.socioe_sugarCainAreaUnits__c=socio.sugarCainAreaUnits__c;
						farmer.socioe_typeOfStove__c=socio.typeOfStove__c;
						farmer.socioe_vegetablesArea__c=socio.vegetablesArea__c;
						farmer.socioe_vegetablesAreaUnits__c=socio.vegetablesAreaUnits__c;
						farmer.socioe_waterSupply__c=socio.waterSupply__c;
						farmer.socioe_whoDoesntStudy__c=socio.whoDoesntStudy__c;
						farmer.socioe_whoRecievesIncomeAndDecides__c=socio.whoRecievesIncomeAndDecides__c;
						farmer.socioe_woodStoveLocation__c=socio.woodStoveLocation__c;
		            	farmer.Submission_SocioE__c= socio.Submission__c;  
                    }                                 
                }
            }
            //update all the farmers with new socio economic data
            try{
                update farmers;
            }
            catch(system.Exception e){
                system.debug (e);
            }
        }
    }
}