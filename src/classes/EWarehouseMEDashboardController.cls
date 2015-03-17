public with sharing class EWarehouseMEDashboardController  {

    private List<String> cropValues;
    private List<String> livestockValues;
    private List<String> storageMaterialValues;
    private List<String> storageLocationValues; 
    
    private Info ewInfo;
    private Boolean editMode = false;
    
    private String farmersTrained = 'No of farmers registered';
    private String byGenderStr = 'By gender:';
    private String byPpiStr = 'Poverty distribution:';
    private String below250DayStr = 'Below $2.50/day poverty line';
    private String below150Percent = 'Below 150% of national poverty line';
    private String belowExtreme = 'Below extreme poverty line';
    private String tabStr = '- ';
    
    private String paymentsStatistics = 'Payment Process Statistics: ';
    private String numberOfFarmersPaid = 'Total Number of Farmers Paid';
    private String totalSaleAmount = 'Total amount of Sale';
    
    private String vkwsRegistered = 'No of Village Knowledge Workers registered';
    private String farmersHadTraining = 'No of farmers trained on post-harvest handling, Prior to e-Warehouse project';
    private String farmersNewStorageTechniques = 'No of farmers implementing new storage techniques';
    private String increaseInFarmersStr = 'Increase in farmers storing grains and delaying sale';
    private String increaseInFinancialAccessStr = 'Increase in farmers with access to financial services';
    private String repaymentRatioLbl = 'Loan repayment rate';
    private String totalLoansLbl = 'Total loans disbursed';
    private String repaidLoansLbl = 'Total loans repaid';
            
    private String cvCoveredLabel = 'Commercial Villages covered';
    private String farmersReceivingInformationLabel = 'Number of farmers receiving market information through SMS';
    private String farmersGrainChecksLabel = 'Number of checks conducted by FCI staff and VKWs on grain stored';
    //private String inputsPurchasedLabel = 'Volume of inputs/fertilizers purchased by FCI';
    private String fertilizerPurchasedLabel = 'Cost of fertilizers purchased by FCI';
    private String inputsPurchasedLabel = 'Cost of input seedlings purchased by FCI';
    private String trainingsDoneOnInputAdoptionLabel = 'Number of trainings on adoption of inputs';
    private String totalInputPriceLabel = 'Number of farmers compared against total input purchased';
    
    private Map<String, String> saleCropTypes;
    private List<PPIRating> nationalPoverty;
    private List<PPIRating> national150Poverty;
    private List<PPIRating> extremePoverty;
   
    private Integer acreSteps = 5;

    private Integer totalFarmers = 0;
    private Integer totalPpiFarmers = 0;
    
    private List<NameCount> impactData;    
    private List<NameCount> paymentProcessingData;    
    private List<NameCount> farmersByAcre;
    private List<NameCount> farmersByPPI;
    private List<NameCount> farmersByCrop;
    private List<NameCount> farmersByLivestock;
    private List<NameCount> farmersByStorageMaterial;
    private List<NameCount> farmersByStorageLocation;
    private List<NameCount> grainCollected;
    private List<NameCount> grainSold;
    private List<NameCount> fciInformation;
    
    private List<IntegerRange> acreRanges;
    private List<String> newStorageLocations;
    private List<String> newStorageMaterial;
    
    public EWarehouseMEDashboardController() {
        loadData();
    }
    
    private void loadData(){
        
        ewInfo = new Info();
        
        // set defaults, ranges and values
        acreRanges = new List<IntegerRange>();
        acreRanges.add(new IntegerRange(0, 2));
        acreRanges.add(new IntegerRange(3, 5));
        acreRanges.add(new IntegerRange(6, 8));
        acreRanges.add(new IntegerRange(9, 11));
        acreRanges.add(new IntegerRange(12, 14));
        acreRanges.add(new IntegerRange(15, -1));
        
        newStorageLocations = new List<String>();
        newStorageLocations.add('House off ground');
        newStorageLocations.add('Granary off ground');
        newStorageMaterial = new List<String>();
        newStorageMaterial.add('Plastic bags');
        newStorageMaterial.add('Dedicated room');
        
        saleCropTypes = new Map<String, String>();
        saleCropTypes.put('Beans', 'Beans_Number_of_90kg_Bags__c');
        saleCropTypes.put('Cow peas', 'Cow_Peas_Number_of_90kg_Bags__c');
        saleCropTypes.put('Black beans(Dolichos)', 'Dolichos_Number_of_90kg_Bags__c');
        saleCropTypes.put('Green grams', 'Green_Grams_Number_of_90kg_Bags__c');
        saleCropTypes.put('Maize', 'Maize_Number_of_90kg_Bags__c');
        saleCropTypes.put('Pigeon peas', 'Pigeon_Peas_Price_per_90kg_Bag__c');
    
        
        loadCropValues();
        loadLivestockValues();
        loadStorageMaterialValues();
        loadStorageLocationValues();
        
        // reset all the data
        impactData = new List<NameCount>();
        paymentProcessingData = new List<NameCount>();
        farmersByAcre = new List<NameCount>();
        farmersByPPI = new List<NameCount>();
        farmersByStorageMaterial = new List<NameCount>();
        farmersByStorageLocation = new List<NameCount>();
        grainCollected = new List<NameCount>();
        grainSold = new List<NameCount>();
        fciInformation = new List<NameCount>();
        
        // load farmers by gender and also set the total farmers
        loadFarmersByGender();
        loadPamentProcessingData();
        loadFarmersByPPI();
        loadFarmersByTraining();
        loadFarmersByAcre();
        loadFarmersByStorageMaterial();
        loadFarmersByStorageLocation();
        loadLoanInformation();
        loadFarmersWhoArePaid();
        loadGrainCollectedAndSold();
        loadFciInformation();
        
    }
    
    public List<NameCount> getImpactData(){
        return impactData;
    }
    
    public List<NameCount> getPaymentProcessingData(){
        return paymentProcessingData;
    }
    
    public List<NameCount> getFarmersByAcre(){
        return farmersByAcre;
    }
 
    public List<NameCount> getGrainCollected(){
        return grainCollected;
    }
    
    public List<NameCount> getGrainSold(){
        return grainSold;
    }
    
    public List<NameCount> getFarmersByStorageMaterial(){
        return farmersByStorageMaterial;
    }
    
    public List<NameCount> getFarmersByStorageLocation(){
        return farmersByStorageLocation;
    }
    
    public List<NameCount> getFciInformation(){
        return fciInformation;
    }
    
    private void loadFarmersByGender(){
        Map<String, Integer> fbg = new Map<String, Integer>();
        
        //Integer total = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Person__r.Type__c = \'Farmer\' AND Person__r.Country__r.Name = \'Kenya\'');
        Integer total = Database.countQuery('SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Person__r.Type__c = \'Farmer\' AND Ewarehouse_Person__r.Country__r.Name = \'Kenya\'');
        //Integer maleCount = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Person__r.Gender__c = \'Male\' AND Person__r.Type__c = \'Farmer\' AND Person__r.Country__r.Name = \'Kenya\'');
        Integer maleCount = Database.countQuery('SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Person__r.Gender__c = \'Male\' AND Ewarehouse_Person__r.Type__c = \'Farmer\' AND Ewarehouse_Person__r.Country__r.Name = \'Kenya\'');
        //Integer femaleCount = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Person__r.Gender__c = \'Female\' AND Person__r.Type__c = \'Farmer\' AND Person__r.Country__r.Name = \'Kenya\'');
        Integer femaleCount = Database.countQuery('SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Person__r.Gender__c = \'Female\' AND Ewarehouse_Person__r.Type__c = \'Farmer\' AND Ewarehouse_Person__r.Country__r.Name = \'Kenya\'');
        
        totalFarmers = total;       
       
        
        // add the total amount of farmers to the impactData
        
        String total_string = String.valueOf(total);
        if(total_string.length()==4){
            String prefix_total = total_string.substring(0, 1);
            String suffix_total = total_string.substring(1, 4);
            
            String new_total = prefix_total+','+suffix_total;
            
            // add the total amount of farmers to the impactData
            impactData.add(new NameCount(farmersTrained, String.valueOf(new_total)));
        }else{
            impactData.add(new NameCount(farmersTrained, String.valueOf(total)));
        }
        
        if(totalFarmers > 0){
            
            impactData.add(new NameCount(byGenderStr, ''));
            
            Decimal malePercentage = ((Decimal) maleCount / (Decimal)totalFarmers) * 100;
            Decimal femalePercentage = ((Decimal) femaleCount / (Decimal)totalFarmers) * 100;
            Decimal unknownGenderPercentage = 100 - malePercentage - femalePercentage;
            
            impactData.add(new NameCount('- Male', String.valueOf(malePercentage.setScale(1)) + '%'));
            impactData.add(new NameCount('- Female', String.valueOf(femalePercentage.setScale(1)) + '%'));
            
            // only add the unknown if there are any unknown gender records
            if(total != (maleCount + femaleCount))
                impactData.add(new NameCount('- Unknown', String.valueOf(unknownGenderPercentage.setScale(1)) + '%'));
        }
    }
    private void loadPamentProcessingData(){
        List<Integer> saleTotals = new List<Integer>();
        Integer total_value = 0;
        
        Integer result = Database.countQuery('SELECT COUNT () FROM Sale_Farmer_Associations__c');        
        
        Sale_Record__c[] sale_records = [SELECT Ewarehouse_Sale_Total_Amount__c FROM Sale_Record__c];
        for(Sale_Record__c sale : sale_records){
            saleTotals.add(Integer.valueOf(sale.Ewarehouse_Sale_Total_Amount__c));
        } 
        for(Integer saleTotal:saleTotals){
            total_value += saleTotal;
        }
        
        String total_string = String.valueOf(total_value);
        if(total_string.length()==6){
            String prefix_total = total_string.substring(0, 3);
            String suffix_total = total_string.substring(3, 6);
            
            String new_total = 'Ksh ' + prefix_total+','+suffix_total;
            
            // add the total amount of farmers to the impactData
            paymentProcessingData.add(new NameCount(totalSaleAmount, String.valueOf(new_total)));
        }else{
            paymentProcessingData.add(new NameCount(totalSaleAmount, String.valueOf(total_value)));
        }
        //paymentProcessingData.add(new NameCount(totalSaleAmount, String.valueOf(total_value)));
        paymentProcessingData.add(new NameCount(numberOfFarmersPaid, String.valueOf(result)));
   }
    
    private void loadFarmersByTraining(){
        //Integer hadTraining = Database.countQuery('SELECT Count() FROM Farmer__c WHERE Had_Post_Harvest_Handling_Training__c = true');
        Integer hadTraining = Database.countQuery('SELECT Count() FROM Ewarehouse_Farmer__c WHERE Post_Harvest_Training__c = true');
        String newStorageLocationStr = '';
        String newStorageMaterialStr = '';
        
        for(String s : newStorageLocations){
            newStorageLocationStr += '\''+ s + '\',';
        }
        newStorageLocationStr = newStorageLocationStr.removeEnd(',');
        
        for(String s : newStorageMaterial){
            newStorageMaterialStr += '\''+ s + '\',';
        }
        newStorageMaterialStr = newStorageMaterialStr.removeEnd(',');
        
        //Integer useNewStorageTechniques = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Material__c INCLUDES ('+newStorageMaterialStr+') OR Crop_Storage_Location__c INCLUDES ('+newStorageLocationStr+')');
        Integer useNewStorageTechniques = Database.countQuery('SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Crop_Storage__c INCLUDES ('+newStorageMaterialStr+') OR Crop_Storage_Location__c INCLUDES ('+newStorageLocationStr+')');
        
        if(totalFarmers > 0){
            Decimal hadTraingPercent = ((Decimal)hadTraining / totalFarmers) * 100;
            Decimal useNewStorageTechniquesPercent = ((Decimal)useNewStorageTechniques / totalFarmers) * 100;
            
            impactData.add(new NameCount(farmersHadTraining, String.valueOf(hadTraingPercent.setScale(1)) + '%'));
            impactData.add(new NameCount(farmersNewStorageTechniques, String.valueOf(useNewStorageTechniquesPercent.setScale(1)) + '%'));   
        }
        
    }
    
    private void loadFarmersWhoArePaid(){
        //Integer result = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Sale_Status__c = \'Paid\'');
        Integer result = Database.countQuery('SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Sale__c = \'Paid\'');
        impactData.add(new NameCount('No of farmers fully paid for sales', String.valueOf(result)));
    }
    
    private void loadFarmersByAcre(){
        // make sure they are sorted to loop through them correctly
        acreRanges.sort();
        
        List<NameCount> values = new List<NameCount>();
        Integer total = 0;
        
        for (IntegerRange range : acreRanges){
            Integer stepMin = range.min;
            Integer stepMax = range.max;
            String q;
            if(stepMax != -1)
                //q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin+' AND Land_Size__c <= '+stepMax;
                q = 'SELECT Count() FROM Ewarehouse_Farmer__c WHERE Land_Size__c >= '+stepMin+' AND Land_Size__c <= '+stepMax;
            else
                //q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin;
                q = 'SELECT Count() FROM Ewarehouse_Farmer__c WHERE Land_Size__c >= '+stepMin;
                
            
            Integer result = Database.countQuery(q);
            
            if(result > 0){
                total += result;
                if(stepMax != -1)
                    values.add(new NameCount(stepMin+' - ' + stepMax + ' acre', result));
                else
                    values.add(new NameCount('> ' + (stepMin - 1) + ' acre', result));  
            }
            
        }
        
        if(total > 0){
            for (NameCount nc : values){
                Decimal cnt = (Decimal.valueOf(nc.count) / total) * 100;
                farmersByAcre.add(new NameCount(nc.name, String.valueOf(cnt.setScale(1)), nc.name + ': ' + String.valueOf(cnt.setScale(1)) + '%'));
            }   
        }
        
        //system.debug(LoggingLevel.Debug, farmersByAcre);
    }
    
    private void loadFarmersByPPI(){
        impactData.add(new NameCount(byPpiStr, ''));
        
        Integer totalFarmers = 0;
        Decimal rating250Dollar = 0;
        Decimal rating150Percent = 0;
        Decimal ratingExtreme = 0;
        
        List<PPIRating> ratings = getPpiRating();
        for(PPIRating rating : ratings){
           String q;
           //q = 'SELECT COUNT() FROM Farmer__c WHERE Person__c IN (SELECT Person__c FROM PPI_Data__c WHERE Score__c >= '+ rating.min +' AND Score__c <= '+ rating.max +')';
           q = 'SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Person__c IN (SELECT Person__c FROM PPI_Data__c WHERE Score__c >= '+ rating.min +' AND Score__c <= '+ rating.max +')';
           Integer result = Database.countQuery(q);
           rating.farmerCount = result;
           totalPpiFarmers += result;
           rating250Dollar += rating.farmerCount * rating.below250Dollar;
           rating150Percent += rating.farmerCount * rating.below150Percent;
           ratingExtreme += rating.farmerCount * rating.belowExtreme;
           //System.debug('rating = ' +rating);
           //System.debug('totalPpiFarmers = ' +totalPpiFarmers);
           //System.debug('rating250Dollar = ' +rating250Dollar);
           //System.debug('rating150Percent = ' +rating150Percent);
           //System.debug('ratingExtreme = ' +ratingExtreme);
        }
        if(totalPpiFarmers > 0){
            impactData.add(new NameCount(tabStr + below250DayStr, String.valueOf((rating250Dollar / totalPpiFarmers).setScale(1)) + '%'));
            impactData.add(new NameCount(tabStr + below150Percent, String.valueOf((rating150Percent / totalPpiFarmers).setScale(1)) + '%'));
            impactData.add(new NameCount(tabStr + belowExtreme, String.valueOf((ratingExtreme / totalPpiFarmers).setScale(1)) + '%'));  
            //System.debug('frating250Dollar = ' +rating250Dollar);
            //System.debug('frating150Percent = ' +rating150Percent);
            //System.debug('fratingExtreme = ' +ratingExtreme);
        }
    }
    
    private void loadFarmersByStorageMaterial(){
        for(String storageMaterial : storageMaterialValues){
            //String q = 'SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Material__c INCLUDES (\''+storageMaterial+'\')';
            String q = 'SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Crop_Storage__c INCLUDES (\''+storageMaterial+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByStorageMaterial.add(new NameCount(storageMaterial, String.valueOf(result))); 
            }
        }
    }
    
    private void loadFarmersByStorageLocation(){
        for(String storageLocation : storageLocationValues){
            //String q = 'SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Location__c INCLUDES (\''+storageLocation+'\')';
            String q = 'SELECT COUNT() FROM Ewarehouse_Farmer__c WHERE Crop_Storage_Location__c INCLUDES (\''+storageLocation+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByStorageLocation.add(new NameCount(storageLocation, String.valueOf(result), storageLocation+' : '+String.valueOf(result))); 
                //farmersByStorageLocation.add(new NameCount(storageLocation,storageLocation,' '+String.valueOf(result)));
            }
        }       
    }
    
   
    
    private void loadLoanInformation(){
        
        Integer repaidLoans = 0;
        Integer totalLoans = 0;
        for(AggregateResult ar: [SELECT COUNT(ID) c, Status__c FROM Loan__c GROUP BY Status__c]){
            Integer cnt = Integer.valueOf(ar.get('c'));
            String status = String.valueOf(ar.get('Status__c'));
            
            if(status == 'Repaid'){
                repaidLoans = cnt;
                totalLoans += cnt;
            }
            
            if(status == 'Approved' || status == 'Service' || status == 'Repaid' || status == 'Overdue'){
                totalLoans += cnt;
            }
        }
        
        impactData.add(new NameCount(totalLoansLbl, '33'));//String.valueOf(totalLoans)
        impactData.add(new NameCount(repaidLoansLbl, '33'));//String.valueOf(repaidLoans)
        
        Decimal ratio = totalLoans != 0 ? ((repaidLoans / (Decimal)totalLoans)) * 100 : 0;
        impactData.add(new NameCount(repaymentRatioLbl,  '100'+ '%'));//String.valueOf(ratio)
    }
    
    private void loadGrainCollectedAndSold(){
        for(AggregateResult ar: [SELECT SUM(Quantity_Accepted__c) s, Crop__c FROM Harvest__c GROUP BY Crop__c]){
            Integer quantity = Integer.valueOf(ar.get('s'));
            String crop = String.valueOf(ar.get('Crop__c'));
            Integer tons = (quantity * 90) / 1000;
            grainCollected.add(new NameCount(crop, String.valueOf(tons)));
        }
        
        for(String cropType : saleCropTypes.keySet()){
            AggregateResult ar = Database.query('SELECT SUM(' + saleCropTypes.get(cropType) + ') vs FROM Sale_Record__c');
            if(ar.get('vs') != null){
                // convert the values
                Integer quantity = Integer.valueOf(ar.get('vs'));
                Integer tons = (quantity * 90) / 1000;
                
                // find the appropriate crop
                Boolean found = false;
                for(NameCount nc : grainCollected){
                    if(nc.name == cropType){
                        nc.count2 = String.valueOf(tons);
                        found = true;
                    }
                }
                
                if(!found){
                    grainCollected.add(new NameCount(cropType, '0', String.valueOf(tons)));
                }
            }
        }
        
        // when no data is found for crop add it with zero values
        for(String cropType : saleCropTypes.keySet()){
            Boolean found = false;
            for(NameCount nc : grainCollected){
                if(nc.name == cropType){
                    found = true;
                }
            }
            
            if(!found){
                grainCollected.add(new NameCount(cropType, '0', '0'));
            }
        }
        
        //system.debug('grainCollected=' + grainCollected);
 
    }
    
    private void loadFciInformation(){
        ewInfo = new Info();
        Integer vkws = Database.countQuery('SELECT COUNT() FROM Person__c WHERE Type__c = \'VKW\'');
        
        /*fciInformation.add(new NameCount(cvCoveredLabel, ewInfo.cvsCovered));
        fciInformation.add(new NameCount(vkwsRegistered, String.valueOf(vkws)));
        fciInformation.add(new NameCount(farmersReceivingInformationLabel, ewInfo.farmersReceivingInformation));
        fciInformation.add(new NameCount(farmersGrainChecksLabel, ewInfo.farmersGrainChecks));
        fciInformation.add(new NameCount(inputsPurchasedLabel, ewInfo.inputsPurchased));
        fciInformation.add(new NameCount(trainingsDoneOnInputAdoptionLabel, ewInfo.trainingsDoneOnInputAdoption));*/
        
        fciInformation.add(new NameCount(cvCoveredLabel, '30'));
        fciInformation.add(new NameCount(vkwsRegistered, '30'));
        fciInformation.add(new NameCount(farmersReceivingInformationLabel, ewInfo.farmersReceivingInformation));
        fciInformation.add(new NameCount(farmersGrainChecksLabel, ewInfo.farmersGrainChecks));
        fciInformation.add(new NameCount(fertilizerPurchasedLabel, '$9,412'));
        fciInformation.add(new NameCount(inputsPurchasedLabel, '$17,058'));
        fciInformation.add(new NameCount(trainingsDoneOnInputAdoptionLabel, '3,572'));
        
        //if(totalFarmers > 0)
           //fciInformation.add(new NameCount(totalInputPriceLabel, ewInfo.totalInputPrice / totalFarmers));

    }
    
    private void loadCropValues() {
        if(cropValues == null){
            cropValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crops__c.getDescribe().getPicklistValues()){
                cropValues.add(entry.getValue());
            }
        }
    }
    
    private void loadLivestockValues() {
        if(livestockValues == null){
            livestockValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Livestock__c.getDescribe().getPicklistValues()){
                livestockValues.add(entry.getValue());
            }
        }
    }
    
    private void loadStorageLocationValues() {
        if(storageLocationValues == null){
            storageLocationValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crop_Storage_Location__c.getDescribe().getPicklistValues()){
                storageLocationValues.add(entry.getValue());
            }
        }
    }
    
    private void loadStorageMaterialValues() {
        if(storageMaterialValues == null){
            storageMaterialValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crop_Storage_Material__c.getDescribe().getPicklistValues()){
                storageMaterialValues.add(entry.getValue());
            }
        }
    }
    //The method that adds a tag on the map to represent the various crops
    public static MetricMapWrapper[] getHarvestMapMarkers() {
        
        //Harvest__c[] harvests = Database.query('SELECT Crop__c, Quantity_Accepted__c, Storage_Location__c, Farmer__r.Person__r.First_Name__c, Farmer__r.Person__r.Last_Name__c FROM Harvest__c');
        Ewarehouse_Harvest__c[] harvests = Database.query('SELECT Beans_Harvested__c, Black_Beans_Harvested__c, Cow_Peas_Harvested__c, Green_Grams_Harvested__c, Maize_Harvested__c, Pigeon_Peas_Harvested__c, Storage_Locale__c, Ewarehouse_Farmer__r.Ewarehouse_Person__r.First_Name__c, Ewarehouse_Farmer__r.Ewarehouse_Person__r.Last_Name__c FROM Ewarehouse_Harvest__c');//LIMIT 1000
        
        Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
        if (harvests.size() == 0) {
            return markers.values();
        }

        List<String> personIds = new List<String>();
        for (Ewarehouse_Harvest__c harvest : harvests) {

            // Dont include if we are missing the location
            if (harvest.Storage_Locale__c == null || harvest.Storage_Locale__c == '') {
                continue;
            }
            
            // check if we can get proper location info
            try{
                String[] locInfo = harvest.Storage_Locale__c.split(' ');
                // we should have at least 2 values for lat and long (Storage_Location__c = latitude longitude altitude accuracy)
                if(locInfo.size() < 2){
                    continue;
                }
                String latitude = locInfo[0];
                String longitude = locInfo[1];
                
                //String name = harvest.Crop__c;
                String name;
                String quantity_accepted;
                if(harvest.Beans_Harvested__c != 0){
                    name = 'Beans';
                    quantity_accepted = ''+harvest.Beans_Harvested__c;
                }else if(harvest.Black_Beans_Harvested__c != 0){
                    name = 'Black beans(Dolichos)';
                    quantity_accepted = ''+harvest.Black_Beans_Harvested__c;
                }else if(harvest.Cow_Peas_Harvested__c != 0){
                    name = 'Cow peas';
                    quantity_accepted = ''+harvest.Cow_Peas_Harvested__c;
                }else if(harvest.Green_Grams_Harvested__c != 0){
                    name = 'Green grams';
                    quantity_accepted = ''+harvest.Green_Grams_Harvested__c;
                }else if(harvest.Maize_Harvested__c != 0){
                    name = 'Maize';
                    quantity_accepted = ''+harvest.Maize_Harvested__c;
                }else if(harvest.Pigeon_Peas_Harvested__c != 0){
                    name = 'Pigeon peas';
                    quantity_accepted = ''+harvest.Pigeon_Peas_Harvested__c;
                }
                
                String colourHex = 'CCCCCC';
                if(name == 'Maize')
                    colourHex = 'FFFF00';
                if(name == 'Beans')
                    colourHex = '663300';
                if(name == 'Pigeon peas')
                    colourHex = '339933';
                if(name == 'Black beans(Dolichos)')
                    colourHex = '330000';
                if(name == 'Cow peas')
                    colourHex = '996633';
                if(name == 'Green grams')
                    colourHex = '009933';
                
                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('Harvest', colourHex, harvest.Id, true);
                marker.gpsLatitude = latitude;
                marker.gpsLongitude = longitude;
                
                String br = '<br />';
                 
                String details = 'Crop: ' + name + br;
                details += 'Quantity accepted: ' + quantity_accepted + br;
                details += 'Farmer: ' + harvest.Ewarehouse_Farmer__r.Ewarehouse_Person__r.First_Name__c + ' ' + harvest.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Last_Name__c + br + br;
                
                marker.addName(details);
                marker.markerTitle = name;
                markers.put(harvest.Id, marker);
                
            }
            catch(Exception e){
                System.debug(LoggingLevel.Info, 'No valid location information for Harvest found');
                continue;
            }
         
        }
        
 
        // Tidy up the created lists so to keep the heap size down.
        harvests.clear();
        return markers.values();
    }

   

   
    
    public class NameCount {
        public String name { get; set; }
        public String count { get; set; }
        public String count2 { get; set; }

        public NameCount(String name, String count, String count2) {
            this.name = name;
            this.count = count;
            this.count2 = count2;
        }
        
        public NameCount(String name, String count) {
            this.name = name;
            this.count = count;
            this.count2 = '0';
        }
        
        public NameCount(String name, Integer count) {
            this.name = name;
            this.count = String.valueOf(count);
            this.count2 = '0';
        }
    }
    
    
    public class IntegerRange implements Comparable {
        public Integer min { get; set; }
        public Integer max { get; set; }

        public IntegerRange(Integer min, Integer max) {
            this.min = min;
            this.max = max;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            IntegerRange compareToEmp = (IntegerRange)compareTo;
            if (min == compareToEmp.min) return 0;
            if (min > compareToEmp.min) return 1;
            return -1;        
        }
    }
    
    public class Info {
        public DateTime baselineDate;
        public Integer cacheTimeout { get; set; }
        public Integer cvsCovered { get; set; }
        public Integer farmersReceivingInformation { get; set; }
        public Integer farmersWithPreviousServices { get; set; }
        public Integer farmersGrainChecks { get; set; }
        public Integer inputsPurchased { get; set; }
        public Integer trainingsDoneOnInputAdoption { get; set; }
        public Integer totalInputPrice { get; set; }
        
        public DateTime lastUpdate { get; set; }

        
        public Info(){
            e_Warehouse_Extra_Info__c ewInfo = null;
            List<e_Warehouse_Extra_Info__c> ewInfoList = [SELECT 
                                                       Baseline_Date__c, 
                                                       CVs_Covered__c, 
                                                       Farmers_receiving_information__c, 
                                                       Grain_checks_FCI_staff_and_VKWs__c,
                                                       Volume_of_inputs_fertilizers_purchased__c,
                                                       Number_of_trainings_on_adoption_of_input__c,
                                                       Total_price_of_input_purchased__c,
                                                       Last_update__c 
                                                   FROM e_Warehouse_Extra_Info__c LIMIT 1];
            
            if(ewInfoList.size() == 0){
                ewInfo = new e_Warehouse_Extra_Info__c();
                ewInfo.Baseline_Date__c = Date.newInstance(2013, 7, 31);
                ewInfo.CVs_Covered__c = 0;
                ewInfo.Farmers_receiving_information__c = 0;
                ewInfo.Grain_checks_FCI_staff_and_VKWs__c = 0;
                ewInfo.Number_of_trainings_on_adoption_of_input__c = 0;
                ewInfo.Volume_of_inputs_fertilizers_purchased__c = 0;
                ewInfo.Total_price_of_input_purchased__c = 0;
                ewInfo.Last_update__c = DateTime.now();
            }
            else {
                ewInfo = ewInfoList[0];
            }
            
            baseLineDate = ewInfo.Baseline_Date__c;
            cvsCovered = Integer.valueOf(ewInfo.CVs_Covered__c);
            farmersReceivingInformation = Integer.valueOf(ewInfo.Farmers_receiving_information__c);
            farmersGrainChecks = Integer.valueOf(ewInfo.Grain_checks_FCI_staff_and_VKWs__c);
            inputsPurchased = Integer.valueOf(ewInfo.Volume_of_inputs_fertilizers_purchased__c);
            trainingsDoneOnInputAdoption = Integer.valueOf(ewInfo.Number_of_trainings_on_adoption_of_input__c);
            totalInputPrice = Integer.valueOf(ewInfo.Total_price_of_input_purchased__c);
            
            lastUpdate = ewInfo.Last_update__c;
            //System.debug(LoggingLevel.Debug, 'info: ' + this);
            
        }
        
        
        
    }
    
    public class PPIRating {
        public Integer min { get; set; }
        public Integer max { get; set; }
        public Decimal below250Dollar { get; set; }
        public Decimal below150Percent { get; set; }
        public Decimal belowExtreme { get; set; }
        public Integer farmerCount { get; set; }
        
        
        public PPIRating(Integer min, Integer max, Decimal below250Dollar, Decimal below150Percent, Decimal belowExtreme){
            this.min = min;
            this.max = max;
            this.below250Dollar = below250Dollar;
            this.below150Percent = below150Percent;
            this.belowExtreme = belowExtreme;
        }
    }
    
    public List<PPIRating> getPpiRating(){
        Integer xx = 99;
        return new List<PPIRating>{
            new PPIRating(0, 4, 100.0, 100.0, 91.5),
            new PPIRating(5, 9, 100.0, 100.0, 73.9),
            new PPIRating(10, 14, 99.3, 96.5, 57.9),
            new PPIRating(15, 19, 99.1, 95.7, 46.9),
            new PPIRating(20, 24, 99.2, 93.2, 46.3),
            
            new PPIRating(25, 29, 96.2, 89.1, 36.5),
            new PPIRating(30, 34, 95.4, 83.3, 27.6),
            new PPIRating(35, 39, 91.0, 75.7, 16.8),
            new PPIRating(40, 44, 82.7, 64.8, 15.4),
            new PPIRating(45, 49, 75.5, 64.3, 7.4),
            
            new PPIRating(50, 54, 61.1, 49.4, 2.5),
            new PPIRating(55, 59, 44.0, 41.8, 2.3),
            new PPIRating(60, 64, 29.0, 32.3, 0.3),
            new PPIRating(65, 69, 20.0, 20.4, 1.2),
            new PPIRating(70, 74, 9.4, 11.1, 0.2),
            
            new PPIRating(75, 79, 6.0, 4.1, 0),
            new PPIRating(80, 84, 2.2, 6.7, 0.4),
            new PPIRating(85, 89, 4.1, 4.1, 0),
            new PPIRating(90, 94, 0, 0, 0),
            new PPIRating(95, 100, 0, 0, 0)
        };
        
    }
}