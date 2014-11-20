public with sharing class LacFarmerProfilePageController {
    private LAC_Farmer_Details__c lacFarmer;
    private CBL_CoffeeBaseline__c coffeeBaseline;
    private CBL_SocioEconomic__c socioEconomic; 
    private CBL_Commercialization__c cblCommercialization;
    private CBL_Farm__c[] cblFarms = new CBL_Farm__c[]{};
    private CBL_Farm__c signatureFarm;
    private CBL_Lot__c[] cblLots = new List<CBL_Lot__c>();
    private CBL_FoodSecurity__c[] foodSecs = new List<CBL_FoodSecurity__c>();
    private ApexPages.StandardController stdController;
    private boolean showSignaturePage = false;
    private String certifications = '';
    private CBL_Farm__c certificationFarm = new CBL_Farm__c();
    private String coffeeVarieties = '';
        
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
    
 
   public List<FMP_Farm_Scores__c> getFMPFarmScores() {
     List<FMP_Farm_Scores__c> scores = new List<FMP_Farm_Scores__c>();
     List<String> farmIds = new List<string>();
     CBL_Farm__c[] cblFms = [Select Id from CBL_Farm__c where Farmer__c=:lacFarmer.id];
     for (CBL_Farm__c farm : cblFms) {
       farmIds.add(farm.Id);
     }
     Farm_Management_Plan__c[] fmps = [Select Id, Farm_Name__c, Year__c from Farm_Management_Plan__c where Farm__c in :farmIds];
     for (Farm_Management_Plan__c fmp : fmps) {
       FMP_Farm_Scores__c score = new FMP_Farm_Scores__c();
       PMF_Finca_Categoria_1__c registriesCat = [Select Nivel_categor_a__c, Tipo__c from PMF_Finca_Categoria_1__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_2__c millCat = [Select Nivel_categor_a__c from PMF_Finca_Categoria_2__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_3__c soilConservationCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_3__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_4__c shadowMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_4__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_5_MIPE__c MIPECat = [Select Nivel_categoria__c from PMF_Finca_Categoria_5_MIPE__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_6_Control_malezas__c undergrowthCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_6_Control_malezas__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_7_Manejo_plaguicid__c pesticideMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_7_Manejo_plaguicid__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_8_Gestion_ambienta__c envMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_8_Gestion_ambienta__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categ_9_Cosecha_PostCosecha__c harvestPostHarvestCat = [Select Nivel_categoria__c from PMF_Finca_Categ_9_Cosecha_PostCosecha__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_10_Lotes__c lotsCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_10_Lotes__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_11_Alm_cigo__c seedbedCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_11_Alm_cigo__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       score.Farm_Name__c = fmp.Farm_Name__c;
       score.Registries_Score__c = registriesCat.Nivel_categor_a__c.substring(3).trim();
      score.Mill_Score__c = millCat.Nivel_categor_a__c.substring(3).trim();
      score.Soil_Conservation_Score__c = soilConservationCat.Nivel_categoria__c.substring(3).trim();
      score.Shadow_Management_Score__c = shadowMgmtCat.Nivel_categoria__c.substring(3).trim();
      score.MIPE_Score__c = MIPECat.Nivel_categoria__c.substring(3).trim();
      score.Undergrowth_Control_Score__c = undergrowthCat.Nivel_categoria__c.substring(3).trim();
      score.Pesticide_Management_Score__c = pesticideMgmtCat.Nivel_categoria__c.substring(3).trim();
      score.Enviromental_Management_Score__c = envMgmtCat.Nivel_categoria__c.substring(3).trim();
      score.Harvest_and_Post_Harvest_Score__c = harvestPostHarvestCat.Nivel_categoria__c.substring(3).trim();
      score.Lots_Score__c = lotsCat.Nivel_categoria__c.substring(3).trim();
      score.Seedbed_Score__c = seedbedCat.Nivel_categoria__c.substring(3).trim();
      score.Year__c = fmp.Year__c; 
      score.Type__c = registriesCat.Tipo__c;
       scores.add(score);
     } 
     return scores;
   }
   
   public List<FMP_Farm_Scores__c> getFamManagementPlansResults() {
     List<FMP_Farm_Scores__c> scores = new List<FMP_Farm_Scores__c>();
     List<String> farmIds = new List<string>();
     CBL_Farm__c[] cblFms = [Select Id from CBL_Farm__c where Farmer__c=:lacFarmer.id];
     for (CBL_Farm__c farm : cblFms) {
       farmIds.add(farm.Id);
     }
     Farm_Management_Plan__c[] fmps = [Select Id, Farm_Name__c from Farm_Management_Plan__c where Farm__c in :farmIds];
     for (Farm_Management_Plan__c fmp : fmps) {
      FMP_Farm_Scores__c score = new FMP_Farm_Scores__c();
      PMF_Finca_Categoria_1__c registriesCat = [Select Nivel_categor_a__c, Fecha__c from PMF_Finca_Categoria_1__c where Plan_de_Manejo_de_Finca__c = :fmp.Id order by Fecha__c];
       PMF_Finca_Categoria_2__c millCat = [Select Nivel_categor_a__c from PMF_Finca_Categoria_2__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_3__c soilConservationCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_3__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_4__c shadowMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_4__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_5_MIPE__c MIPECat = [Select Nivel_categoria__c from PMF_Finca_Categoria_5_MIPE__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_6_Control_malezas__c undergrowthCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_6_Control_malezas__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_7_Manejo_plaguicid__c pesticideMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_7_Manejo_plaguicid__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_8_Gestion_ambienta__c envMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_8_Gestion_ambienta__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categ_9_Cosecha_PostCosecha__c harvestPostHarvestCat = [Select Nivel_categoria__c from PMF_Finca_Categ_9_Cosecha_PostCosecha__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_10_Lotes__c lotsCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_10_Lotes__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_11_Alm_cigo__c seedbedCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_11_Alm_cigo__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       score.Farm_Name__c = fmp.Farm_Name__c;
       score.Registries_Score__c = registriesCat.Nivel_categor_a__c;
      score.Mill_Score__c = millCat.Nivel_categor_a__c;
      score.Soil_Conservation_Score__c = soilConservationCat.Nivel_categoria__c;
      score.Shadow_Management_Score__c = shadowMgmtCat.Nivel_categoria__c;
      score.MIPE_Score__c = MIPECat.Nivel_categoria__c;
      score.Undergrowth_Control_Score__c = undergrowthCat.Nivel_categoria__c;
      score.Pesticide_Management_Score__c = pesticideMgmtCat.Nivel_categoria__c;
      score.Enviromental_Management_Score__c = envMgmtCat.Nivel_categoria__c;
      score.Harvest_and_Post_Harvest_Score__c = harvestPostHarvestCat.Nivel_categoria__c;
      score.Lots_Score__c = lotsCat.Nivel_categoria__c;
      score.Seedbed_Score__c = seedbedCat.Nivel_categoria__c; 
       scores.add(score);
     }     
     return scores;
   }
 
    public List<FMPCategoryResultsGroup> getFMPCategoryResultsGroup() {
      List<FMPCategoryResultsGroup> results = new List<FMPCategoryResultsGroup>();
      List<FMP_Farm_Scores__c> scores = new List<FMP_Farm_Scores__c>();
     List<String> farmIds = new List<string>();
     CBL_Farm__c[] cblFms = [Select Id from CBL_Farm__c where Farmer__c=:lacFarmer.id];
     for (CBL_Farm__c farm : cblFms) {
       farmIds.add(farm.Id);
     }
     Farm_Management_Plan__c[] fmps = [Select Id, Farm_Name__c from Farm_Management_Plan__c where Farm__c in :farmIds];
     for (Farm_Management_Plan__c fmp : fmps) {
      FMPCategoryResultsGroup resultsGroup = new FMPCategoryResultsGroup();
          
      PMF_Finca_Categoria_1__c registriesCat = [Select Nivel_categor_a__c, Fecha__c, Tipo__c, Nombre_categoria__c from PMF_Finca_Categoria_1__c where Plan_de_Manejo_de_Finca__c = :fmp.Id order by Fecha__c];
      FMPCategoryResult res1 = new FMPCategoryResult();
      res1.setLevel(registriesCat.Nivel_categor_a__c);
      res1.setResultDate(registriesCat.Fecha__c);
      res1.setResultType(registriesCat.Tipo__c);
      
      resultsGroup.resultsDate = registriesCat.Fecha__c;
      resultsGroup.categoryName = registriesCat.Nombre_categoria__c;
            
       PMF_Finca_Categoria_2__c millCat = [Select Nivel_categor_a__c, Tipo__c, Fecha__c from PMF_Finca_Categoria_2__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       FMPCategoryResult res2 = new FMPCategoryResult();
      res2.setLevel(millCat.Nivel_categor_a__c);
      res2.setResultDate(millCat.Fecha__c);
      res2.setResultType(millCat.Tipo__c);
        
      resultsGroup.addResultGroup(res1);
      resultsGroup.addResultGroup(res2);
      /*              
       PMF_Finca_Categoria_3__c soilConservationCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_3__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_4__c shadowMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_4__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_5_MIPE__c MIPECat = [Select Nivel_categoria__c from PMF_Finca_Categoria_5_MIPE__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_6_Control_malezas__c undergrowthCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_6_Control_malezas__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_7_Manejo_plaguicid__c pesticideMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_7_Manejo_plaguicid__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_8_Gestion_ambienta__c envMgmtCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_8_Gestion_ambienta__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categ_9_Cosecha_PostCosecha__c harvestPostHarvestCat = [Select Nivel_categoria__c from PMF_Finca_Categ_9_Cosecha_PostCosecha__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_10_Lotes__c lotsCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_10_Lotes__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       PMF_Finca_Categoria_11_Alm_cigo__c seedbedCat = [Select Nivel_categoria__c from PMF_Finca_Categoria_11_Alm_cigo__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
       */
       results.add(resultsGroup);
     } 
    return results;   
    }
    /*
    public String getCoffeeVarieties( ) {
     if (coffeeVarieties == null || coffeeVarieties.equals('')) {
       coffeeVarieties = '';
       List<CBL_Lot__c> lots = getCblLots();
       for (CBL_Lot__c lot : lots) {
        if (lot.lotCoffeeVariety__c != null && !lot.lotCoffeeVariety__c.equals('')) {
          if (coffeeVarieties.equals('')) {
            coffeeVarieties = coffeeVarieties + lot.lotCoffeeVariety__c; 
          } else {
            coffeeVarieties = coffeeVarieties + ', ' + lot.lotCoffeeVariety__c;
          }
        }                   
       }         
     }
     return coffeeVarieties;
    }
    */
    
    public String getCoffeeVarieties() {
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
