trigger CreateSpecificMaizeAdoptions on Maize_GAPs_Adoption__c (after insert) {

    List<Maize_GAPs_Adoption__c> maizeGAPsAdoptions = trigger.new;
    List<Maize_GAP_Adoption__c> specificAdoptions = new List<Maize_GAP_Adoption__c>();
    
    for (Maize_GAPs_Adoption__c maizeAdoption : maizeGAPsAdoptions) {
        if (maizeAdoption.Land_Preparation_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 1 Land Preparation';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Proper_Planting_Full_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 2 Proper Planting';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Proper_Seed_Selection_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 3 Proper Seed Selection';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Proper_Soil_Fertility_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 4 Proper Soil Fertility Management';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Pest_Disease_Identification_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 5 Pest and Disease Identification';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.GAP_6_Full_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 6 Proper Harvesting and Post Harvest Handling';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Bulking_and_Marketing_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 7 Bulking and Marketing';
            specificAdoptions.add(specificAdoption);
        }
        if (maizeAdoption.Proper_Record_Keeping_Adoption__c == 'Yes') {
            Maize_GAP_Adoption__c specificAdoption = new Maize_GAP_Adoption__c();
            specificAdoption.Adoption_Date__c = maizeAdoption.Date__c;
            specificAdoption.Maize_GAPs_Adoption__c = maizeAdoption.id;
            specificAdoption.Maize_Farmer__c = maizeAdoption.Maize_Farmer__c;
            specificAdoption.Contact__c = maizeAdoption.CKW_Contact_Id__c;
            specificAdoption.GAP_Adopted__c = 'GAP 8 Proper Record Keeping';
            specificAdoptions.add(specificAdoption);
        }
    }
    insert specificAdoptions;
}