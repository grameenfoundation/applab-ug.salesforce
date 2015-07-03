public with sharing class LacFarmerProfilePageController {
    public LAC_Farmer_Details__c lacFarmer;
    public CBL_CoffeeBaseline__c coffeeBaseline;
    public CBL_SocioEconomic__c socioEconomic; 
    public CBL_Commercialization__c cblCommercialization;
    public CBL_Farm__c[] cblFarms = new CBL_Farm__c[]{};
    public CBL_Farm__c signatureFarm;
    public CBL_Lot__c[] cblLots = new List<CBL_Lot__c>();
    public CBL_FoodSecurity__c[] foodSecs = new List<CBL_FoodSecurity__c>();
    public ApexPages.StandardController stdController;
    public boolean showSignaturePage = false;
    public String certifications = '';
    public CBL_Farm__c certificationFarm = new CBL_Farm__c();
    public String coffeeVarieties = '';
        
    public String getPageLanguage() {
        return UserInfo.getLanguage();
    }
    
    public CBL_Farm__c getCertificationFarm() {
        return certificationFarm;
    }
    
    public LacFarmerProfilePageController(ApexPages.StandardController controller) {
       this.stdController = controller;
       this.lacFarmer = (LAC_Farmer_Details__c)controller.getRecord();
       
       CBL_CoffeeBaseline__c[] coffeeBaselines = [Select Id, Total_Farm_Area__c, Productivity__c From CBL_CoffeeBaseline__c 
            where Farmer__c=:lacFarmer.id];
        if (coffeeBaselines.size() > 0) {
            coffeeBaseline = coffeeBaselines[0];
        }
    }
    
    public boolean getShowSignaturePage() {
        return showSignaturePage;
    }
    
    public CBL_CoffeeBaseline__c getCoffeeBaseline() {
        return coffeeBaseline;
    }
    
    public CBL_CoffeeBaseline__c[] getCoffeeBaselines() {
        CBL_CoffeeBaseline__c[] coffeeBaselines = [Select Id, baselineName__c, Sbux_Segment__c, Sbux_Segment_Probability__c From CBL_CoffeeBaseline__c where Farmer__c=:lacFarmer.id];      
        return coffeeBaselines;
    }
    
    public CBL_SocioEconomic__c getSocioEconomic() {
        if (coffeeBaseline != null) {
            CBL_SocioEconomic__c[] socioEconomic = [Select Id,
                                                            personsInHousehold__c,
                                                            homeOwnerShip__c,
                                                            waterSupply__c,
                                                            sewageDisposalSystem__c,
                                                            electricEnergy__c,
                                                            knowsHowToReadWrite__c,
                                                            schoolingYears__c,
                                                            householdIncomeSources__c,
                                                            percentageOfIncomeCoffee__c,
                                                            otherAgriculturalActivities__c,
                                                            savingsWay__c,
                                                            bankAccount__c,
                                                            debts__c,
                                                            debtsFinancingSource__c,
                                                            creditDestination__c,
                                                            populationGroup__c,
                                                            socialSecutiryProgram__c
                                                     from CBL_SocioEconomic__c
                                                     where Baseline__c=:coffeeBaseline.id];
            if (socioEconomic.size() > 0) {
                return socioEconomic[0];
            }
        }
        return null;
    }
    
    public CBL_Commercialization__c getCblCommercialization() {
        if (coffeeBaseline != null) {
            CBL_Commercialization__c[] cblCommercializations = [Select Id,
                                                                        producedCoffeeDestiny__c,
                                                                        lastHarvestPercCoffeeSoldToCoop__c,
                                                                        statusSoldCoffee__c,
                                                                        buysCoffee__c
                                                               From CBL_Commercialization__c
                                                               Where Baseline__c=:coffeeBaseline.id];
           if (cblCommercializations.size() > 0) {
            cblCommercialization = cblCommercializations[0];
           }
           return cblCommercialization;
       }
       return null;
    }

    public List<CBL_Farm__c> getCblFarms() {
        if (null != coffeeBaseline) {
            CBL_Farm__c[] cblFarmz = [Select Id, farmName__c, prodLastHarvestUnits__c, productionLastHarvest__c, coffeePlantedArea__c, coffeePlantedAreaUnits__c, 
            signature__c, coffeProcessingPlace__c, farmCertifications__c, totalFarmArea__c, Coffee_planted_area_Ha__c,
                Production_last_year_Kg__c from CBL_Farm__c
                                        where Baseline__c=:coffeeBaseline.id];
            if (cblFarmz.size() > 0) {
                signatureFarm = cblFarmz[0];
                cblFarms = cblFarmz;
                List<String> farmIds = new List<String>();
                Map<String, String> certs = new Map<String, String>();
                
                for (CBL_Farm__c cblFarm : cblFarms) {
                    farmIds.add(cblFarm.Id);
                    if (cblFarm.farmCertifications__c != null) {
                        String[] cblCerts = cblFarm.farmCertifications__c.split(';');
                        if (cblCerts.size() > 0) {
                            for (String cblCert : cblCerts) {
                                certs.put(cblCert, cblCert);
                            }
                        }
                    }
                }
                for (String key : certs.keySet()) {
                    certifications = certifications + ';' + key;
                }
                if (certifications != null && certifications.length() > 0) {
                    certifications = certifications.substring(1);
                }
                certificationFarm.farmCertifications__c = certifications;
                CBL_Lot__c [] cblLotz = [Select Id, lotCoffeeVariety__c from CBL_Lot__c where Farm__c in:farmIds];
                cblLots = cblLotz;
            }
        }
        return cblFarms;
    }

    public CBL_Farm__c getSignatureFarm() {
        if (coffeeBaseline != null) {
            CBL_Farm__c signatureFarm = [Select Id, farmName__c, signature__c, 
                                            coffeProcessingPlace__c, farmCertifications__c,
                                            Production_last_year_Kg__c
                                         from CBL_Farm__c
                                        where Baseline__c=:coffeeBaseline.id];
                                        
            if (signatureFarm != null) {
                showSignaturePage = true;
            }
                                        
            return signatureFarm;
        }
        return null;
    }

    public List<CBL_Lot__c> getCblLots() {
        if (cblLots.size() > 0) {
            return cblLots;
        }
        else {
            getCblFarms();
            return cblLots;
        }
    }
    
    public List<CBL_FoodSecurity__c> getFoodSecs() {
        CBL_CoffeeBaseline__c[] bls = [Select Id from CBL_CoffeeBaseline__c where CBL_CoffeeBaseline__c.Farmer__r.Id=:lacFarmer.id];
        CBL_FoodSecurity__c[] foodSecuritiesTmp = new List<CBL_FoodSecurity__c>(); 
        for (CBL_CoffeeBaseline__c bl : bls) {          
            CBL_FoodSecurity__c[] fss = [Select Id, CreatedDate, Food_security_status_chronic__c, FS_Chronic_score__c, FS_Prevalence_score__c, Food_security_status_prevalence__c from CBL_FoodSecurity__c where Baseline__c = :bl.Id];             
            for (CBL_FoodSecurity__c fs : fss) {
                foodSecuritiesTmp.add(fs);      
            }           
        }
        foodSecs = foodSecuritiesTmp;
        return foodSecs;
    } 
    
    public List<FMP_Diagnostic__c> getFamManagementPlansResults() {
        List<String> farmIds = new List<string>();
        CBL_Farm__c[] cblFms = [Select Id from CBL_Farm__c where Farmer__c=:lacFarmer.id];
        for (CBL_Farm__c farm : cblFms) {
            farmIds.add(farm.Id);
        }
       
       List<FMP_Diagnostic__c> fmpDg = [Select Id, PMF_Farm__r.farmName__c, fmp_Agrochemicals_Score__c, fmp_Environment_Score__c, fmp_Harvest_Score__c, fmp_Lot_Score__c, fmp_MIPE_Score__c, fmp_Record_score__c, fmp_Seedbed_Score__c, fmp_Shadow_Score__c, fmp_Soil_Score__c, fmp_Weeds_Score__c, fmp_Wetmill_Score__c, fmp_Total_Score__c from FMP_Diagnostic__c where PMF_Farm__c in :farmIds];
        return fmpDg;
    }
 
    
    public String getCoffeeVarieties( ) {
        String vars = '';
        List<CBL_Lot__c> lots = getCblLots();
        List<String> varieties = new List<String>();
        for (CBL_Lot__c lot : lots) {
            String[] lotVars = getLotVarieties(lot);
            for (String variety : lotVars) {
                if (!listContainsString(varieties, variety)) {
                    varieties.add(variety);
                }
            }
        }
        if (varieties.size() > 0) {
            for (String var : varieties) {
                if (vars.equals('')) {
                    vars += var;
                } else {
                    vars += ', ' + var;
                }
            }
        }
        return vars;
    }    
    
    public String[] getLotVarieties(CBL_Lot__c lot) {
        String[] varieties = new String[]{};
        if (lot.lotCoffeeVariety__c != null && !lot.lotCoffeeVariety__c.equals('')) {
            if (lot.lotCoffeeVariety__c.indexOf(';') == -1) { 
                varieties.add(lot.lotCoffeeVariety__c);
            } else {
                varieties = lot.lotCoffeeVariety__c.split(';', 0);
            }
        }
        return varieties;
    }
    
    public String getProductivity() {       
        Double production = 0;
        Double area = 0;
        List<CBL_Farm__c> farms = getCblFarms();
        for (CBL_Farm__c farm : farms) {
            production += getProductionLastYearKg(farm);
            area += getCoffeePlantedAreaHa(farm);
        }
        if (area == 0) {
            return 'N/A';
        }
        Decimal productivity = production / area;
        return '' + productivity.setScale(2);
    }   
    
    private Double getProductionLastYearKg(CBL_Farm__c farm) {
        Double factor = 0;
        if (farm.prodLastHarvestUnits__c == null) {
            return 0;
        } 
        if (farm.prodLastHarvestUnits__c.equals('Quintales')) {
            factor = 45.3592;
        } else if (farm.prodLastHarvestUnits__c.equals('Arrobas')) {
            factor = 11.5;
        } else if (farm.prodLastHarvestUnits__c.equals('Libras')) {
            factor = 0.453597024;
        } else if (farm.prodLastHarvestUnits__c.equals('Kilogramos')) {
            factor = 1;
        }
        return farm.productionLastHarvest__c * factor;      
    }
    
    private Double getCoffeePlantedAreaHa(CBL_Farm__c farm) {
        Double factor = 1;
        if (farm.coffeePlantedAreaUnits__c == null) {
            return 0;
        }
        if (farm.coffeePlantedAreaUnits__c .equals('Hect�reas')) {
            factor = 1;
        } else if (farm.coffeePlantedAreaUnits__c.equals('Cuadras')) {
            factor = 1.5625;
        } else if (farm.coffeePlantedAreaUnits__c .equals('Manzanas')) {
            factor = 0.6988;
        } else if (farm.coffeePlantedAreaUnits__c .equals('Cuerdas (25x25)')) {
            factor = 22.89;
        } else if (farm.coffeePlantedAreaUnits__c .equals('Cuerdas (40x40)')) {
            factor = 8.94;
        }
        return farm.coffeePlantedArea__c * factor;          
    }
    
    public Double getProduction() {     
        Double production = 0;
        List<CBL_Farm__c> farms = getCblFarms();
        for (CBL_Farm__c farm : farms) {
            production += getProductionLastYearKg(farm);
        }
        return production;
    }   
    
    public Double getCoffeePlantedArea() {      
        Double area = 0;
        List<CBL_Farm__c> farms = getCblFarms();
        for (CBL_Farm__c farm : farms) {
            area += getCoffeePlantedAreaHa(farm);
        }
        return area;
    }  
    
    public String getCertifications( ) {
        String certifications = '';
        List<CBL_Farm__c> farms = getCblFarms();
        List<String> certs = new List<String>();
        for (CBL_Farm__c farm : farms) {
            String[] farmCerts = getFarmCertifications(farm);
            for (String cert : farmCerts) {
                if (!listContainsString(certs, cert)) {
                    certs.add(cert);
                }
            }
        }
        if (certs.size() > 0) {
            for (String cer : certs) {
                if (certifications.equals('')) {
                    certifications += cer;
                } else {
                    certifications += ', ' + cer;
                }
            }
        }
        return certifications;
    }
    
    private Boolean listContainsString(List<String> stringList, String stringToLookFor) {
        for (String str : stringList) {
            if (str.equals(stringToLookFor)) {
                return true;
            }
        }
        return false;
    }
    
    public String[] getFarmCertifications(CBL_Farm__c farm) {
        String[] certs = new String[]{};
        if (farm.farmCertifications__c != null && !farm.farmCertifications__c.equals('')) {
            if (farm.farmCertifications__c.indexOf(';') == -1) { 
                certs.add(farm.farmCertifications__c);
            } else {
                certs = farm.farmCertifications__c.split(';', 0);
            }
        }
        return certs;
    }
    
}