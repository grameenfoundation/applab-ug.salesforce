trigger CreateSpecificBananaAdoptions on Banana_GAPs_Adoption__c (after insert) {

    List<Banana_GAPs_Adoption__c> bananaGAPsAdoptions = trigger.new;
    List<Banana_GAP_Adoption__c> bananaGAPAdoptions = new List<Banana_GAP_Adoption__c>();
    for (Banana_GAPs_Adoption__c bananaGAPsAdoption : bananaGAPsAdoptions) {
        if (bananaGAPsAdoption.Soil_Fertility_Management_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c soilFertility = new Banana_GAP_Adoption__c();
            soilFertility.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            soilFertility.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            soilFertility.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            soilFertility.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            soilFertility.GAP_Adopted__c = 'GAP 1 Soil Fertility Management';
            bananaGAPADoptions.add(soilFertility);
        }
        if (bananaGAPsAdoption.Desuckering_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c desuckering = new Banana_GAP_Adoption__c();
            desuckering.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            desuckering.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            desuckering.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            desuckering.GAP_Adopted__c = 'GAP 2 Desuckering';
            desuckering.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(desuckering);
        }
        if (bananaGAPsAdoption.Pruning_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c pruning = new Banana_GAP_Adoption__c();
            pruning.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            pruning.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            pruning.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            pruning.GAP_Adopted__c = 'GAP 2 Pruning';
            pruning.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(pruning);
        }
        if (bananaGAPsAdoption.GAP_3_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c soilWaterConservation = new Banana_GAP_Adoption__c();
            soilWaterConservation.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            soilWaterConservation.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            soilWaterConservation.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            soilWaterConservation.GAP_Adopted__c = 'GAP 3 Soil and Water Conservation';
            soilWaterConservation.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(soilWaterConservation);
        }
        if (bananaGAPsAdoption.Propping_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c propping = new Banana_GAP_Adoption__c();
            propping.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            propping.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            propping.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            propping.GAP_Adopted__c = 'GAP 4 Providing Support for Banana';
            propping.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(propping);
        }
        if (bananaGAPsAdoption.Proper_Record_Keeping_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c recordKeeping = new Banana_GAP_Adoption__c();
            recordKeeping.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            recordKeeping.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            recordKeeping.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            recordKeeping.GAP_Adopted__c = 'GAP 5 Proper Record Keeping';
            recordKeeping.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(recordKeeping);
        }
        if (bananaGAPsAdoption.GAP_6_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c groupProduction = new Banana_GAP_Adoption__c();
            groupProduction.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            groupProduction.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            groupProduction.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            groupProduction.GAP_Adopted__c = 'GAP 6 Group Production and Marketing';
            groupProduction.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(groupProduction);
        }
        if (bananaGAPsAdoption.Proper_Weed_Control_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c weedControl = new Banana_GAP_Adoption__c();
            weedControl.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            weedControl.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            weedControl.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            weedControl.GAP_Adopted__c = 'GAP 7 Proper Weed Control';
            weedControl.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(weedControl);
        }
        if (bananaGAPsAdoption.Pest_Disease_Control_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c diseaseControl = new Banana_GAP_Adoption__c();
            diseaseControl.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            diseaseControl.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            diseaseControl.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            diseaseControl.GAP_Adopted__c = 'GAP 8 Pest & Disease Control';
            diseaseControl.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(diseaseControl);
        }
        if (bananaGAPsAdoption.Value_Addition_Full_Adoption__c == 'Yes') {
            Banana_GAP_Adoption__c valueAddition = new Banana_GAP_Adoption__c();
            valueAddition.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            valueAddition.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            valueAddition.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            valueAddition.GAP_Adopted__c = 'GAP 9 Value Addition';
            valueAddition.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(valueAddition);
        }
        if (bananaGAPsAdoption.Easy_Access_Agro_Inputs_Adoption__c== 'Yes') {
            Banana_GAP_Adoption__c agroInputs = new Banana_GAP_Adoption__c();
            agroInputs.Adoption_Date__c = bananaGAPsAdoption.Date__c;
            agroInputs.Banana_Farmer__c = bananaGAPsAdoption.Banana_Farmer__c;
            agroInputs.Banana_GAPs_Adoption__c = bananaGAPsAdoption.Id;
            agroInputs.GAP_Adopted__c = 'GAP 10 Easy Access Agro Inputs';
            agroInputs.Contact__c = bananaGAPsAdoption.CKW_Contact_Id__c;
            bananaGAPAdoptions.add(agroInputs);
        }
    }
    insert bananaGAPAdoptions;
}