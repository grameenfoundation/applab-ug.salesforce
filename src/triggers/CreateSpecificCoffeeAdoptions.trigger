trigger CreateSpecificCoffeeAdoptions on Coffee_GAPs_Adoption__c (after insert) {
    List<Coffee_GAPs_Adoption__c> coffeeGAPsAdoptions = trigger.new;
    List<Coffee_GAP_Adoption__c> coffeeGAPAdoptions = new List<Coffee_GAP_Adoption__c>();
    for (Coffee_GAPs_Adoption__c coffeeGAPsAdoption : coffeeGAPsAdoptions) {
        if (coffeeGAPsAdoption.Soil_Fertility_Management_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c soilFertility = new Coffee_GAP_Adoption__c();
            soilFertility.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            soilFertility.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            soilFertility.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            soilFertility.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            soilFertility.GAP_Adopted__c = 'GAP 1 Soil Fertility Management';
            coffeeGAPADoptions.add(soilFertility);
        }
        if (coffeeGAPsAdoption.Desuckering_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c desuckering = new Coffee_GAP_Adoption__c();
            desuckering.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            desuckering.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            desuckering.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            desuckering.GAP_Adopted__c = 'GAP 2 Desuckering';
            desuckering.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(desuckering);
        }
        if (coffeeGAPsAdoption.Pruning_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c pruning = new Coffee_GAP_Adoption__c();
            pruning.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            pruning.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            pruning.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            pruning.GAP_Adopted__c = 'GAP 2 Pruning';
            pruning.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(pruning);
        }
        if (coffeeGAPsAdoption.Stumping_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c pruning = new Coffee_GAP_Adoption__c();
            pruning.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            pruning.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            pruning.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            pruning.GAP_Adopted__c = 'GAP 2 Stumping';
            pruning.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(pruning);
        }
        if (coffeeGAPsAdoption.GAP_3_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c soilWaterConservation = new Coffee_GAP_Adoption__c();
            soilWaterConservation.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            soilWaterConservation.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            soilWaterConservation.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            soilWaterConservation.GAP_Adopted__c = 'GAP 3 Soil & Water Conservation Measures';
            soilWaterConservation.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(soilWaterConservation);
        }
        if (coffeeGAPsAdoption.On_farm_Value_Addition_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c propping = new Coffee_GAP_Adoption__c();
            propping.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            propping.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            propping.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            propping.GAP_Adopted__c = 'GAP 4 On farm Value Addition';
            propping.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(propping);
        }
        if (coffeeGAPsAdoption.Record_Keeping_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c recordKeeping = new Coffee_GAP_Adoption__c();
            recordKeeping.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            recordKeeping.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            recordKeeping.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            recordKeeping.GAP_Adopted__c = 'GAP 5 Record Keeping';
            recordKeeping.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(recordKeeping);
        }
        if (coffeeGAPsAdoption.GAP_6_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c groupProduction = new Coffee_GAP_Adoption__c();
            groupProduction.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            groupProduction.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            groupProduction.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            groupProduction.GAP_Adopted__c = 'GAP 6 Group Production and Marketing';
            groupProduction.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(groupProduction);
        }
        if (coffeeGAPsAdoption.Proper_Weed_Control_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c weedControl = new Coffee_GAP_Adoption__c();
            weedControl.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            weedControl.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            weedControl.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            weedControl.GAP_Adopted__c = 'GAP 7 Proper Weed Control';
            weedControl.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(weedControl);
        }
        if (coffeeGAPsAdoption.Pest_Disease_Control_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c diseaseControl = new Coffee_GAP_Adoption__c();
            diseaseControl.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            diseaseControl.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            diseaseControl.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            diseaseControl.GAP_Adopted__c = 'GAP 8 Pest & Disease Control';
            diseaseControl.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(diseaseControl);
        }
        if (coffeeGAPsAdoption.Value_Addition_Full_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c valueAddition = new Coffee_GAP_Adoption__c();
            valueAddition.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            valueAddition.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            valueAddition.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            valueAddition.GAP_Adopted__c = 'GAP 9 Value Addition';
            valueAddition.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(valueAddition);
        }
        if (coffeeGAPsAdoption.Easy_Access_Agro_Inputs_Adoption__c == 'Yes') {
            Coffee_GAP_Adoption__c agroInputs = new Coffee_GAP_Adoption__c();
            agroInputs.Adoption_Date__c = coffeeGAPsAdoption.Date__c;
            agroInputs.Coffee_Farmer__c = coffeeGAPsAdoption.Coffee_Farmer__c;
            agroInputs.Coffee_GAPs_Adoption__c = coffeeGAPsAdoption.Id;
            agroInputs.GAP_Adopted__c = 'GAP 10 Easy Access Agro Inputs';
            agroInputs.Contact__c = coffeeGAPsAdoption.CKW_Contact_Id__c;
            coffeeGAPAdoptions.add(agroInputs);
        }
    }
    insert coffeeGAPAdoptions;
}