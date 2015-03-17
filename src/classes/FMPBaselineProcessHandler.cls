public with sharing class FMPBaselineProcessHandler { 

	Date today = Date.today();
	CBL_Farm__c farm;
	
	public FMPBaselineProcessHandler(CBL_Farm__c f) {
		farm = f;
	}	
	
	public void handle() {
		/*
		List<PMF_Finca_Categoria_1__c> cats1 = new List<PMF_Finca_Categoria_1__c>();
		List<PMF_Finca_Categoria_2__c> cats2 = new List<PMF_Finca_Categoria_2__c>();
		List<PMF_Finca_Categoria_3__c> cats3 = new List<PMF_Finca_Categoria_3__c>();
		List<PMF_Finca_Categoria_4__c> cats4 = new List<PMF_Finca_Categoria_4__c>();		
		List<PMF_Finca_Categoria_5_MIPE__c> cats5 = new List<PMF_Finca_Categoria_5_MIPE__c>();
		List<PMF_Finca_Categoria_6_Control_malezas__c> cats6 = new List<PMF_Finca_Categoria_6_Control_malezas__c>();
		List<PMF_Finca_Categoria_7_Manejo_plaguicid__c> cats7 = new List<PMF_Finca_Categoria_7_Manejo_plaguicid__c>();
		List<PMF_Finca_Categoria_8_Gestion_ambienta__c> cats8 = new List<PMF_Finca_Categoria_8_Gestion_ambienta__c>();
		List<PMF_Finca_Categ_9_Cosecha_PostCosecha__c> cats9 = new List<PMF_Finca_Categ_9_Cosecha_PostCosecha__c>();
		List<PMF_Finca_Categoria_10_Lotes__c> cats10 = new List<PMF_Finca_Categoria_10_Lotes__c>();		
		List<PMF_Finca_Categoria_11_Alm_cigo__c> cats11 = new List<PMF_Finca_Categoria_11_Alm_cigo__c>();
		List<PMF_Finca_Cat_12_Seguridad_alimentaria__c> cats12 = new List<PMF_Finca_Cat_12_Seguridad_alimentaria__c>();				
		*/
			    
        //Get the Mills for that farm
        CBL_WetMill__c[] mills = [Select Id, canSeparateByLot__c, classifiesInputCoffeeQuality__c, 
                                  pulpingMachinesStatus__c, separatedGrainsProcessedAppart__c, 
                                  fermentationTanksStatus__c, coffeWashMeans__c, washInfrastructureStatus__c, 
                                  pulpManagement__c, residualWaterDisposal__c, patioAndMecanicDryerStatus__c,
                                  storageCleanlinessStatus__c, baseUsedForStorage__c,
                                  hasPestControl__c, humidityRisk__c, contaminationRisk__c, protectsTransport__c, 
                                  transportWithChemicals__c, majorNonCompliance__c, 
                                  pulpingMachineWashedBeforeUse__c   
                                   from CBL_WetMill__c where Baseline__c = :farm.Baseline__c];

        //Create the FMP for each farm
        Farm_Management_Plan__c fmp = new Farm_Management_Plan__c();   
        fmp.Farm__c = farm.Id;
        fmp.Year__c = String.valueOf(today.year());
        insert fmp;
        
        //******** 1st CATEGORY: Registro - Registries ********
        PMF_Finca_Categoria_1__c fmpcat1 = new PMF_Finca_Categoria_1__c();
        fmpcat1.Tipo__c = 'Línea base';
        fmpcat1.Fecha__c = today;
        fmpcat1.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //1 Indicator: Registro de labores (Jornales) - Wages registration
        fmpcat1.Registro_de_labores_Jornales__c = farm.hires_RegistersTempStaff__c;
        //2 Indicator: Registro aplicación de pesticidas - Pesticide application registration
        fmpcat1.Registro_aplicacion_de_pesticidas__c = farm.registersPlague_DiseaseCtrlSupplies__c;
        //3 Indicator: Registro compra de insumos - Inputs purchase registration
        if (farm.farmManagmtDocuments__c != null) {
        	String farmDocsText = String.valueOf(farm.farmManagmtDocuments__c);
        	if (farmDocsText.length() > 255) { 
        		if (farmDocsText.contains('Registro de insumos')) {
					fmpcat1.Registro_compra_de_insumos__c = 'Registro de insumos';
        		}
        	} else {
        		fmpcat1.Registro_compra_de_insumos__c = farm.farmManagmtDocuments__c;
        	}
        }         
        	
		//4 Indicator: Registro ventas Café Pergamino Seco (CPS) - Sales registration
        fmpcat1.Registro_ventas_CPS__c = farm.coffeeInvoicesRegistered__c;
		//5 Indicator: Registro recolección - Pickup registration
        fmpcat1.Registro_recoleccion__c = farm.identifiesHarvestedCoffee__c;

        //******** 2nd CATEGORY: Beneficio - Mill ********
        PMF_Finca_Categoria_2__c fmpcat2 = new PMF_Finca_Categoria_2__c();
        fmpcat2.Tipo__c = 'Línea base';
        fmpcat2.Fecha__c = today;
        fmpcat2.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //6 Indicator: Lista de chequeo - Checklist
        //Empty, value is not included in baseline           
        
        //7 Indicator: Separación de café por lote - Separation of coffee per lot
        for (CBL_WetMill__c mill : mills) {
            if (mill.canSeparateByLot__c != null) {
                fmpcat2.Separacion_de_cafe_por_lote__c = mill.canSeparateByLot__c;
                break;
            }
        }
                    
        //8 Indicator: Separación de café por calidad - Separation of coffee per quality
		for (CBL_WetMill__c mill : mills) {
            if (mill.classifiesInputCoffeeQuality__c != null) {
                fmpcat2.Separacin_de_cafe_por_calidad__c = mill.classifiesInputCoffeeQuality__c; 
                break;
            }
        }
            
        //9 Indicator: Maquina despulpadora en buen estado - Pulper machine in good conditions
		for (CBL_WetMill__c mill : mills) {
            if (mill.pulpingMachinesStatus__c != null) {
                fmpcat2.Maquina_despulpadora_en_buen_estado__c = mill.pulpingMachinesStatus__c;
                break;
            }
        }
        
        //10 Indicator: Zaranda en buen estado - Screen in good conditions
		for (CBL_WetMill__c mill : mills) {
            if (mill.separatedGrainsProcessedAppart__c != null) {
                fmpcat2.Zaranda_en_buen_estado__c = mill.separatedGrainsProcessedAppart__c;
                break;
            }
        }	
        
        //11 Indicator: Tanques de fermenación en buen estado - Fermentation tanks in good conditions
		for (CBL_WetMill__c mill : mills) {
            if (mill.fermentationTanksStatus__c != null) {
                fmpcat2.Tanques_de_fermenaci_n_en_buen_estado__c = mill.fermentationTanksStatus__c; 
                break;
            }
        }	
        
        //12 Indicator: Tanques de desmucilaginadora buen estado - Mucilage remover machine in good conditions
        for (CBL_WetMill__c mill : mills) {
            if (mill.coffeWashMeans__c != null && mill.coffeWashMeans__c.contains('Desmucilaginadora')) {
                fmpcat2.Tanques_de_desmucilaginadora_buen_estado__c = mill.washInfrastructureStatus__c;
                break;
            }
        }	
        
        //13 Indicator: Canales de correteo en buen estado - Scamper channels in good conditions
        for (CBL_WetMill__c mill : mills) {
            if (mill.coffeWashMeans__c != null && mill.coffeWashMeans__c.contains('Canal de correteo')) {
                fmpcat2.Canales_de_correteo_en_buen_estado__c = mill.washInfrastructureStatus__c;
                break;
            }
        }	
        
        //14 Indicator: Fosa de compostaje de pulpa - Composting trench in good conditions
        for (CBL_WetMill__c mill : mills) {
            if (mill.pulpManagement__c != null) {
                fmpcat2.Fosa_de_compostaje_de_pulpa__c = mill.pulpManagement__c;
                break;
            }
        }	

        //15 Indicator: Tanque de tratamiento de agua miel - Sewage treatment tank
        for (CBL_WetMill__c mill : mills) {
            if (mill.residualWaterDisposal__c != null) {
                fmpcat2.Tanque_de_tratamiento_de_agua_miel__c = mill.residualWaterDisposal__c;
                break;
            }
        }

        //16 Indicator: Sistema de secado de café en buen estado (mecánico, marquesina, casa Elda, carros) - Coffee drying system in good conditions
		for (CBL_WetMill__c mill : mills) {
            if (mill.patioAndMecanicDryerStatus__c != null) {
                fmpcat2.Sistema_de_secado_de_caf_en_buen_estado__c = mill.patioAndMecanicDryerStatus__c;
                break;
            }
        }
            
        //17 Indicator: Empaques de café (limpio, seco, buen estado) - Coffee packages (clean, dry, good conditions)
		fmpcat2.Empaques_caf_limpio_seco_buen_estado__c = farm.cleanTransportContainers__c; 
        
        //18 Indicator: Almacenamiento de café adecuado (bodega limpia, estibas, sin roedores e insectos, aislado) - Proper coffee storage
        for (CBL_WetMill__c mill : mills) {
			if (
				mill.storageCleanlinessStatus__c != null && mill.baseUsedForStorage__c != null && 
                mill.hasPestControl__c != null && mill.humidityRisk__c != null && 
                mill.contaminationRisk__c != null && 
            	mill.storageCleanlinessStatus__c.contains('Buenas condiciones de limpieza') && 
				mill.baseUsedForStorage__c.contains('Sobre madera o estibas') &&
				mill.hasPestControl__c.contains('Adecuado control de plagas y roedodres') &&
				mill.humidityRisk__c.contains('No presenta riesgos de humedad') && 
				mill.contaminationRisk__c.contains('No hay riesgos de contaminación') 
            ){
				fmpcat2.Almacenamiento_de_caf_adecuado__c = 'Cumple';
				break;
            } else {
                fmpcat2.Almacenamiento_de_caf_adecuado__c = 'No cumple';
            }
        }
            
        //19 Indicator: Transporte adecuado (protegido de humedad, quimicos y otros) - Proper transportation (Protected from humidity, chemichals and others)
		for (CBL_WetMill__c mill : mills) {
            if (mill.protectsTransport__c != null && mill.transportWithChemicals__c != null && 
            	mill.protectsTransport__c == 'Sí' && mill.transportWithChemicals__c == 'No') {
				fmpcat2.Transporte_adecuado__c = 'Cumple';
				break;
            } else {
                fmpcat2.Transporte_adecuado__c = 'No cumple';
            }
        }
        
        //******** 3rd CATEGORY: ********
        PMF_Finca_Categoria_3__c fmpcat3 = new PMF_Finca_Categoria_3__c();
        fmpcat3.Tipo__c = 'Línea base';
        fmpcat3.Fecha__c = today;
        fmpcat3.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //20 Indicator: Identificación de zonas erosionadas - Identification of erosion areas
		fmpcat3.Identificacion_de_zonas_erosionadas__c = farm.erosionZonesIdentified__c;
        
        //21 Indicator: Recuperación de zonas erosionadas - Recovery of eroded areas
		fmpcat3.Recuperacion_de_zonas_erosionadas__c = farm.soilConservationPractices__c;
        
        //22 Indicator: Reforestación con especies nativas - Reforestation with native species
		fmpcat3.Reforestacion_con_especies_nativas__c = farm.biologicalDiversityContrib__c;
        
        //******** 4th CATEGORY: ********
		PMF_Finca_Categoria_4__c fmpcat4 = new PMF_Finca_Categoria_4__c();
        fmpcat4.Tipo__c = 'Línea base';
        fmpcat4.Fecha__c = today;
        fmpcat4.Plan_de_Manejo_de_Finca__c = fmp.Id;
            
        //23 Indicator: Uso de especies nativas como sombrio - Use of native species as shadow
		fmpcat4.Uso_de_especies_nativas_como_sombrio__c = farm.percShadeNativeSpecies__c;
        
        //24 Indicator: Regulación de sombra - Shadow regulation
		fmpcat4.Regulacion_de_sombra__c = farm.percentageShade__c;
        
        //******** 5th CATEGORY: ********
		PMF_Finca_Categoria_5_MIPE__c fmpcat5 = new PMF_Finca_Categoria_5_MIPE__c();
        fmpcat5.Tipo__c = 'Línea base';
        fmpcat5.Fecha__c = today;
        fmpcat5.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //25 Indicator: Registro de monitoreo de Plagas y Enfermedades - Registration of plagues and sicknesses monitoring
		//Empty, value is not included in baseline
        
        //26 Indicator: Realización de monitoreo de Plagas y enfermedades - Monitors plagues and sicknesses
		fmpcat5.Realizacion_monitoreo_Plagas_y_enfermeda__c = farm.doesPlagues_DiseaseSampling__c;
            
        //27 Indicator: Control de acuerdo al resultado del monitoreo - Controls according to monitoring results
		//Empty, value is not included in baseline
        
        //28 Indicator: Evaluación post-control - Post control evaluation
		//Empty, value is not included in baseline
        
        //29 Indicator: Uso de metodos de control para PyE - Use of methods for plagues and sicknesses control
		if (farm.howDoesDiseaseControl__c != null && !farm.howDoesDiseaseControl__c.contains('No las controla') 
            && farm.howDoesPlagueControl__c != null && !farm.howDoesPlagueControl__c.contains('No hace nada para controlarlas')) {
			fmpcat5.Uso_de_metodos_de_control_para_PyE__c = 'Controla plagas y enfermedades';
        } else {
			fmpcat5.Uso_de_metodos_de_control_para_PyE__c = 'No controla plagas y enfermedades';
        }
        
        //******** 6th CATEGORY: ********
		PMF_Finca_Categoria_6_Control_malezas__c fmpcat6 = new PMF_Finca_Categoria_6_Control_malezas__c();
        fmpcat6.Tipo__c = 'Línea base';
        fmpcat6.Fecha__c = today;
        fmpcat6.Plan_de_Manejo_de_Finca__c = fmp.Id;
            
        //30 Indicator: Uso de metodos amigables para reducción de herbicidas - Use of friendly methods for herbicide reduction
		fmpcat6.Metodos_amigables_reduccion_herbicidas__c = farm.weedsControlMethods__c;
        
        //******** 7th CATEGORY: ********
		PMF_Finca_Categoria_7_Manejo_plaguicid__c fmpcat7 = new PMF_Finca_Categoria_7_Manejo_plaguicid__c();
        fmpcat7.Tipo__c = 'Línea base';
        fmpcat7.Fecha__c = today;
        fmpcat7.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //31 Indicator: Posee equipos de protección - Has protection equipment
        if (farm.useOfProtApplicationDangSubstances__c == 'Sí, siempre' ||
            farm.useOfProtApplicationDangSubstances__c == 'Sí, algunas veces' ||
           	farm.useOfProtApplicationDangSubstances__c == 'No, pero si hay equipo de protección' 
           ) {
            fmpcat7.Posee_equipos_de_proteccion__c = 'Sí tiene equipos de protección';   
        } else {
            fmpcat7.Posee_equipos_de_proteccion__c = 'No tiene equipos de protección';
        }
            
        //32 Indicator: Usa equipos de protección - Uses protection equipment
        fmpcat7.Usa_equipos_de_proteccion__c = farm.useOfProtApplicationDangSubstances__c;

        //33 Indicator: Registra las aplicaciones (agroquimicos) - Registers ago chemicals application
		fmpcat7.Registra_las_aplicaciones_agroquimicos__c = farm.registersPlague_DiseaseCtrlSupplies__c;
        
        //34 Indicator: Capacita el personal en manejo de agroquimicos - Train personnel in agro chemicals management
		fmpcat7.Capacita_personal_manejo_de_agroquimicos__c = farm.dangSubstancesManipulatorsTrained__c;
        
        //******** 8th CATEGORY: ********
		PMF_Finca_Categoria_8_Gestion_ambienta__c fmpcat8 = new PMF_Finca_Categoria_8_Gestion_ambienta__c();
        fmpcat8.Tipo__c = 'Línea base';
        fmpcat8.Fecha__c = today;
        fmpcat8.Plan_de_Manejo_de_Finca__c = fmp.Id;
        
        //35 Indicator: Manejo de aguas residuales (hogar/beneficio) - Sewage management (Home/mill)
		for (CBL_WetMill__c mill : mills) {
            if (mill.residualWaterDisposal__c != null) {
                fmpcat8.Manejo_aguas_residuales_hogar_benef__c = mill.residualWaterDisposal__c;
                break;
            }
        }
                
        //36 Indicator: Manejo alternativo para aguas de beneficio - Alternative management for mill water
		for (CBL_WetMill__c mill : mills) {
            if (mill.residualWaterDisposal__c != null) {
                fmpcat8.Manejo_alternativo_aguas_de_beneficio__c = mill.residualWaterDisposal__c;
                break;
            }
        }
        
        //37 Indicator: Transformación de pulpas para uso en cultivo (compost, lombricultivo, bocashi) - Pulp processing for use in crop (Compost, vermiculture, bocashi)
		for (CBL_WetMill__c mill : mills) {
            if (mill.pulpManagement__c != null) {
                fmpcat8.Transformaci_n_pulpas_uso_en_cultivo__c = mill.pulpManagement__c;
                break;
            }
        }
            
        //38 Indicator: Implementación de Plan de Consevación y Recuperación de Fauna/Flora Silvestre. - Flora and fauna conservation plan
		fmpcat8.Plan_Consevaci_n_y_Recuper_Flora_y_Fauna__c = farm.promotesFloraAndFaunaPreservation__c;
        
        //******** 9th CATEGORY: ********
		PMF_Finca_Categ_9_Cosecha_PostCosecha__c fmpcat9 = new PMF_Finca_Categ_9_Cosecha_PostCosecha__c();
        fmpcat9.Tipo__c = 'Línea base';
        fmpcat9.Fecha__c = today;
        fmpcat9.Plan_de_Manejo_de_Finca__c = fmp.Id;            
        
        //39 Indicator: Registro de recolección - Pickup registration
		fmpcat9.Registro_de_recoleccion__c = farm.identifiesHarvestedCoffee__c;
        
        //40 Indicator: Evaluación de recolección - Pickup evaluation
		//Empty, value is not included in baseline
            
        //41 Indicator: Inocuidad del beneficio - Mill safety
        for (CBL_WetMill__c mill : mills) {
            if (mill.majorNonCompliance__c != null) {
                fmpcat9.Inocuidad_del_beneficio__c = mill.majorNonCompliance__c;
                break;
            }
        }
        
        //42 Indicator: Inocuidad bodegas - Warehouse safety
        for (CBL_WetMill__c mill : mills) {
            if (mill.storageCleanlinessStatus__c != null) {
                fmpcat9.Inocuidad_bodegas__c = mill.storageCleanlinessStatus__c;
                break;
            }
        }
        
        //43 Indicator: Evaluación del despulpado - Pulping evaluation
        for (CBL_WetMill__c mill : mills) {
            if (mill.pulpingMachineWashedBeforeUse__c == 'Se limpia antes de cada proceso' && 
               mill.pulpingMachinesStatus__c == 'Granos enteros y limpios'
               ) {
					fmpcat9.Evaluacion_del_despulpado__c = 'Despulpadora limpia y en buen estado';  
					break; 
               } else {
                   if (fmpcat9.Evaluacion_del_despulpado__c != 'Despulpadora limpia y en buen estado') {
						fmpcat9.Evaluacion_del_despulpado__c = 'No se limpia la despulpadora o no está en buen estado';
                   }
               }
        }
            
        //******** 10th CATEGORY: ********
        PMF_Finca_Categoria_10_Lotes__c fmpcat10 = new PMF_Finca_Categoria_10_Lotes__c();
        fmpcat10.Tipo__c = 'Línea base';
        fmpcat10.Fecha__c = today;
        fmpcat10.Plan_de_Manejo_de_Finca__c = fmp.Id;  
        
        //44 Indicator: Mapa de la finca - Farm map
		//Empty, value is not included in baseline
        
        //45 Indicator: Conocimiento de áreas de lotes - Knowledge of lots areas
		//Empty, value is not included in baseline
        
        //46 Indicator: Registro de arboles y variedades por lote - Registration of trees and varieties per lot
		CBL_Lot__c[] lots = [Select Id, lotCoffeeVariety__c, lotNumberOfPlants__c
                           from CBL_Lot__c where Farm__c = :farm.Id];
        Boolean lotRegistrationComplete = true;
        for (CBL_Lot__c lot : lots) {
            if (lot.lotCoffeeVariety__c == null || lot.lotCoffeeVariety__c == '' || lot.lotNumberOfPlants__c == 0) {
                lotRegistrationComplete = false;
                break;
            }
        }
        if (lotRegistrationComplete) {
            fmpcat10.Registro_rboles_y_variedades_por_lotes__c = 'Tiene registro completo de árboles y variedades por lote';
        } else {
            fmpcat10.Registro_rboles_y_variedades_por_lotes__c = 'El registro de árboles y variedades por lote no está completo';
        }
        
        //47 Indicator: Registro de labores por lote - Registration of work per lot
		//Empty, value is not included in baseline
        
        //******** 11th CATEGORY: ********
        PMF_Finca_Categoria_11_Alm_cigo__c fmpcat11 = new PMF_Finca_Categoria_11_Alm_cigo__c();
        fmpcat11.Tipo__c = 'Línea base';
        fmpcat11.Fecha__c = today;
        fmpcat11.Plan_de_Manejo_de_Finca__c = fmp.Id;  
        
        //48 Indicator: Implemetación de Plan de Establecimiento de Almácigo - Implementation of plan to establish seedbed
        if (farm.farmManagmtDocuments__c != null) {
        	String farmDocsText = String.valueOf(farm.farmManagmtDocuments__c);
        	if (farmDocsText.length() > 255) { 
        		if (farmDocsText.contains('Plan de Manejo de Almácigos')) {
					fmpcat11.Plan_de_Establecimiento_Almacigo__c = 'Plan de Manejo de Almácigos';
        		}
        	} else {
        		fmpcat11.Plan_de_Establecimiento_Almacigo__c = farm.farmManagmtDocuments__c;
        	}
        }         
		
        
        //49 Indicator: Preparación adecuada de sustratos - Proper preparation of substrates
		//Empty, value is not included in baseline
        
        //******** 12th CATEGORY: ********
        /*
        PMF_Finca_Cat_12_Seguridad_alimentaria__c fmpcat12 = new PMF_Finca_Cat_12_Seguridad_alimentaria__c();
        fmpcat12.Tipo__c = 'Línea base';
        fmpcat12.Fecha__c = today;
        fmpcat12.Plan_de_Manejo_de_Finca__c = fmp.Id;  
        */
        //50 Indicator: Realización de Huerta Casera (Pan-Coger) - Backyard garden
		//Empty, value is not included in baseline
	
		/*                        
        cats1.add(fmpcat1);
        cats2.add(fmpcat2);
        cats3.add(fmpcat3);
        cats4.add(fmpcat4);
        cats5.add(fmpcat5);
        cats6.add(fmpcat6);
        cats7.add(fmpcat7);
        cats8.add(fmpcat8);
        cats9.add(fmpcat9);
        cats10.add(fmpcat10);
        cats11.add(fmpcat11);
        cats12.add(fmpcat12);
        */
  
	    insert fmpcat1;
	    insert fmpcat2;
	    insert fmpcat3;
	    insert fmpcat4;
	    insert fmpcat5;
	    insert fmpcat6;
	    insert fmpcat7;
	    insert fmpcat8;
	    insert fmpcat9;
	    insert fmpcat10;
	    insert fmpcat11;
	    //insert fmpcat12;
	}

}