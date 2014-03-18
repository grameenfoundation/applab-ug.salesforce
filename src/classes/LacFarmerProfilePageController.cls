public with sharing class LacFarmerProfilePageController {
    private LAC_Farmer_Details__c lacFarmer;
    private CBL_CoffeeBaseline__c coffeeBaseline;
    private CBL_SocioEconomic__c socioEconomic;
    private CBL_Commercialization__c cblCommercialization;
    private CBL_Farm__c[] cblFarms;
    private CBL_Farm__c signatureFarm;
    private CBL_Lot__c[] cblLots = new List<CBL_Lot__c>();
    private ApexPages.StandardController stdController;
    private boolean showSignaturePage = false;
    private String certifications = '';
    private CBL_Farm__c certificationFarm = new CBL_Farm__c();
    
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
            return socioEconomic[0];
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
           cblCommercialization = cblCommercializations[0];
           return cblCommercialization;
       }
       return null;
    }

    public List<CBL_Farm__c> getCblFarms() {
        if (null != coffeeBaseline) {
            CBL_Farm__c[] cblFarmz = [Select Id, farmName__c, signature__c, coffeProcessingPlace__c, farmCertifications__c from CBL_Farm__c
                                        where Baseline__c=:coffeeBaseline.id];
            if (cblFarmz.size() > 0) {
                signatureFarm = cblFarmz[0];
                cblFarms = cblFarmz;
                List<String> farmIds = new List<String>();
                Map<String, String> certs = new Map<String, String>();
                
                for (CBL_Farm__c cblFarm : cblFarms) {
                    farmIds.add(cblFarm.Id);
                    String[] cblCerts = cblFarm.farmCertifications__c.split(';');
                    if (cblCerts.size() > 0) {
                        for (String cblCert : cblCerts) {
                            certs.put(cblCert, cblCert);
                        }
                    }
                }
                for (String key : certs.keySet()) {
                    certifications = certifications + ';' + key;
                }
                certifications =certifications.substring(1);
                certificationFarm.farmCertifications__c = certifications;
                CBL_Lot__c [] cblLotz = [Select Id, lotCoffeeVariety__c from CBL_Lot__c where Farm__c in:farmIds];
                cblLots = cblLotz;
                return cblFarms;
            }
        }
        return null;
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
    
}