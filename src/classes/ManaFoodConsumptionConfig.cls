public virtual class ManaFoodConsumptionConfig {
    public static String Source_Barter = 'Barter';
    public static String Source_Other = 'Other (gift-donation)';
    public static String Source_Production = 'Production';
    public static String Source_Purchase = 'Purchase';
    
    public static Map<String, Id> foodMap = new Map<String, Id> {
<<<<<<< HEAD
            'acelga' => 'a2h70000000L8RFAA0',
			'ahuyama' => 'a2h70000000L8RGAA0',
			'aji' => 'a2h70000000L8RHAA0',
			'apio' => 'a2h70000000L8RIAA0',
			'arveja' => 'a2h70000000L8RJAA0',
			'berenjena' => 'a2h70000000L8RKAA0',
			'brocoli' => 'a2h70000000L8RLAA0',
			'cebhuevo' => 'a2h70000000L8RMAA0',
			'cebrama' => 'a2h70000000L8RNAA0',
			'cidra' => 'a2h70000000L8ROAA0',
			'cilantro' => 'a2h70000000L8RPAA0',
			'colcomun' => 'a2h70000000L8RQAA0',
			'coliflor' => 'a2h70000000L8RRAA0',
			'espinaca' => 'a2h70000000L8RSAA0',
			'habichuela' => 'a2h70000000L8RTAA0',
			'lechuga' => 'a2h70000000L8RUAA0',
			'pepino' => 'a2h70000000L8RVAA0',
			'perejil' => 'a2h70000000L8RWAA0',
			'pimenton' => 'a2h70000000L8RXAA0',
			'rabano' => 'a2h70000000L8RYAA0',
			'remolacha' => 'a2h70000000L8RZAA0',
			'repollo' => 'a2h70000000L8RaAAK',
			'tomatealino' => 'a2h70000000L8RbAAK',
			'zanahoria' => 'a2h70000000L8RcAAK',
			'zukini' => 'a2h70000000L8RdAAK',
			'anon' => 'a2h70000000L8ReAAK',
			'badea' => 'a2h70000000L8RfAAK',
			'banano' => 'a2h70000000L8RgAAK',
			'borojo' => 'a2h70000000L8RhAAK',
			'brevas' => 'a2h70000000L8RiAAK',
			'carambolo' => 'a2h70000000L8RjAAK',
			'chontaduro' => 'a2h70000000L8RkAAK',
			'ciruela' => 'a2h70000000L8RlAAK',
			'curuba' => 'a2h70000000L8RmAAK',
			'fresas' => 'a2h70000000L8RnAAK',
			'granadilla' => 'a2h70000000L8RoAAK',
			'guanabana' => 'a2h70000000L8RpAAK',
			'guayaba' => 'a2h70000000L8RqAAK',
			'higo' => 'a2h70000000L8RrAAK',
			'limon' => 'a2h70000000L8RsAAK',
			'lulo' => 'a2h70000000L8RtAAK',
			'mamey' => 'a2h70000000L8RuAAK',
			'mandarina' => 'a2h70000000L8RvAAK',
			'mangocomun' => 'a2h70000000L8RwAAK',
			'manzana' => 'a2h70000000L8RxAAK',
			'maracuya' => 'a2h70000000L8RyAAK',
			'melon' => 'a2h70000000L8RzAAK',
			'mora' => 'a2h70000000L8S0AAK',
			'naranja' => 'a2h70000000L8S1AAK',
			'n’spero' => 'a2h70000000L8S2AAK',
			'papaya' => 'a2h70000000L8S3AAK',
			'papayuela' => 'a2h70000000L8S4AAK',
			'pera' => 'a2h70000000L8S5AAK',
			'pina' => 'a2h70000000L8S6AAK',
			'pitaya' => 'a2h70000000L8S7AAK',
			'sandia' => 'a2h70000000L8S8AAK',
			'tomatearbol' => 'a2h70000000L8S9AAK',
			'uchuva' => 'a2h70000000L8SAAA0',
			'uva' => 'a2h70000000L8SBAA0',
			'zapote' => 'a2h70000000L8SCAA0',
			'arroz' => 'a2h70000000L8SDAA0',
			'maiz' => 'a2h70000000L8SEAA0',
			'frijol' => 'a2h70000000L8SFAA0',
			'carneres' => 'a2h70000000L8SGAA0',
			'carnecerdo' => 'a2h70000000L8SHAA0',
			'pollogallina' => 'a2h70000000L8SIAA0',
			'pescado' => 'a2h70000000L8SJAA0',
			'huevogallina' => 'a2h70000000L8SKAA0',
			'otro' => 'a2h70000000L8SLAA0',
			'lecheliquida' => 'a2h70000000L8SMAA0',
			'lechepolvo' => 'a2h70000000L8SNAA0',
			'quesos' => 'a2h70000000L8SOAA0',
			'yogur' => 'a2h70000000L8SPAA0'
=======
            'acelga' => 'a2u70000000TS8QAAW',
            'ahuyama' => 'a2u70000000TS8RAAW',
            'aji' => 'a2u70000000TS8SAAW',
            'apio' => 'a2u70000000TS8TAAW',
            'arveja' => 'a2u70000000TS8UAAW',
            'berenjena' => 'a2u70000000TS8VAAW',
            'brocoli' => 'a2u70000000TS8WAAW',
            'cebhuevo' => 'a2u70000000TS8XAAW',
            'cebrama' => 'a2u70000000TS8YAAW',
            'cidra' => 'a2u70000000TS8ZAAW',
            'cilantro' => 'a2u70000000TS8aAAG',
            'colcomun' => 'a2u70000000TS8bAAG',
            'coliflor' => 'a2u70000000TS8cAAG',
            'espinaca' => 'a2u70000000TS8dAAG',
            'habichuela' => 'a2u70000000TS8eAAG',
            'lechuga' => 'a2u70000000TS8fAAG',
            'pepino' => 'a2u70000000TS8gAAG',
            'perejil' => 'a2u70000000TS8hAAG',
            'pimenton' => 'a2u70000000TS8iAAG',
            'rabano' => 'a2u70000000TS8jAAG',
            'remolacha' => 'a2u70000000TS8kAAG',
            'repollo' => 'a2u70000000TS8lAAG',
            'tomatealino' => 'a2u70000000TS8mAAG',
            'zanahoria' => 'a2u70000000TS8nAAG',
            'zukini' => 'a2u70000000TS8oAAG',
            'anon' => 'a2u70000000TS8pAAG',
            'badea' => 'a2u70000000TS8qAAG',
            'banano' => 'a2u70000000TS8rAAG',
            'borojo' => 'a2u70000000TS8sAAG',
            'brevas' => 'a2u70000000TS8tAAG',
            'carambolo' => 'a2u70000000TS8uAAG',
            'chontaduro' => 'a2u70000000TS8vAAG',
            'ciruela' => 'a2u70000000TS8wAAG',
            'curuba' => 'a2u70000000TS8xAAG',
            'fresas' => 'a2u70000000TS8yAAG',
            'granadilla' => 'a2u70000000TS8zAAG',
            'guanabana' => 'a2u70000000TS90AAG',
            'guayaba' => 'a2u70000000TS91AAG',
            'higo' => 'a2u70000000TS92AAG',
            'limon' => 'a2u70000000TS93AAG',
            'lulo' => 'a2u70000000TS94AAG',
            'mamey' => 'a2u70000000TS95AAG',
            'mandarina' => 'a2u70000000TS96AAG',
            'mangocomun' => 'a2u70000000TS97AAG',
            'manzana' => 'a2u70000000TS98AAG',
            'maracuya' => 'a2u70000000TS99AAG',
            'melon' => 'a2u70000000TS9AAAW',
            'mora' => 'a2u70000000TS9BAAW',
            'naranja' => 'a2u70000000TS9CAAW',
            'n’spero' => 'a2u70000000TS9DAAW',
            'papaya' => 'a2u70000000TS9EAAW',
            'papayuela' => 'a2u70000000TS9FAAW',
            'pera' => 'a2u70000000TS9GAAW',
            'pina' => 'a2u70000000TS9HAAW',
            'pitaya' => 'a2u70000000TS9IAAW',
            'sandia' => 'a2u70000000TS9JAAW',
            'tomatearbol' => 'a2u70000000TS9KAAW',
            'uchuva' => 'a2u70000000TS9LAAW',
            'uva' => 'a2u70000000TS9MAAW',
            'zapote' => 'a2u70000000TS9NAAW',
            'arroz' => 'a2u70000000TS9OAAW',
            'maiz' => 'a2u70000000TS9PAAW',
            'frijol' => 'a2u70000000TS9QAAW',
            'carneres' => 'a2u70000000TS9RAAW',
            'carnecerdo' => 'a2u70000000TS9SAAW',
            'pollogallina' => 'a2u70000000TS9TAAW',
            'pescado' => 'a2u70000000TS9UAAW',
            'huevogallina' => 'a2u70000000TS9VAAW',
            'otro' => 'a2u70000000TS9WAAW',
            'lecheliquida' => 'a2u70000000TS9XAAW',
            'lechepolvo' => 'a2u70000000TS9YAAW',
            'quesos' => 'a2u70000000TS9ZAAW',
            'yogur' => 'a2u70000000TS9aAAG'
>>>>>>> origin/ci
            };
    
    public static Map<String, String> sourcePrefixMap = new Map<String, String> {
                Source_Purchase => 'prd_02_52',
                Source_Barter => 'prd_02_53',
                Source_Production => 'prd_02_54',
                Source_Other => 'prd_02_55'
            };
    
    // Exceptions (These don't have codes, so just ignore the code values - consider only the amount. The amount is already in the desired units)
    public static Map<String, Id> foodExceptions = new Map<String, Id> {
<<<<<<< HEAD
	            'arroz' => 'a2h70000000L8SDAA0',
				'maiz' => 'a2h70000000L8SEAA0',
				'frijol' => 'a2h70000000L8SFAA0',
				'carneres' => 'a2h70000000L8SGAA0',
				'carnecerdo' => 'a2h70000000L8SHAA0',
				'pollogallina' => 'a2h70000000L8SIAA0',
				'pescado' => 'a2h70000000L8SJAA0',
				'huevogallina' => 'a2h70000000L8SKAA0',
				'otro' => 'a2h70000000L8SLAA0',
				'lecheliquida' => 'a2h70000000L8SMAA0',
				'lechepolvo' => 'a2h70000000L8SNAA0',
				'quesos' => 'a2h70000000L8SOAA0',
				'yogur' => 'a2h70000000L8SPAA0'
            };
    
    // This will be a table that contains each food Id as the index, and a map of codes => Ids, as it's values
   	public Map<Id, Map<String, Id>> codeLookupTable = new Map<Id, Map<String, Id>>();
   	
    public ManaFoodConsumptionConfig() {
         // create the code lookup table
         for (Mana_Food_Quantity_Code__c[] codes: [Select Food__r.Id, Code__c, Id from Mana_Food_Quantity_Code__c]) {
         	for(Mana_Food_Quantity_Code__c code: codes) {
         		Map<String, Id> codeMap = null;
         		if (this.codeLookupTable.containsKey(code.Food__r.Id)) {
         			codeMap = this.codeLookupTable.get(code.Food__r.Id);
         		} else {
         			codeMap = new Map<String, Id>();
         		}
         		
         		codeMap.put(code.Code__c, code.Id);
         		this.codeLookupTable.put(code.Food__r.Id, codeMap);
         	}
         }
    }
    
    public String getAmountBinding(String sourcePrefix, String foodName) {
        return sourcePrefix + 'a_' + foodName.toLowerCase(); 
    }
    
    public String getCodeBinding(String sourcePrefix, String foodName) {
        return sourcePrefix + 'b_' + foodName.toLowerCase(); 
    }
=======
                'arroz' => 'a2u70000000TS9OAAW',
                'maiz' => 'a2u70000000TS9PAAW',
                'frijol' => 'a2u70000000TS9QAAW',
                'carneres' => 'a2u70000000TS9RAAW',
                'carnecerdo' => 'a2u70000000TS9SAAW',
                'pollogallina' => 'a2u70000000TS9TAAW',
                'pescado' => 'a2u70000000TS9UAAW',
                'huevogallina' => 'a2u70000000TS9VAAW',
                'otro' => 'a2u70000000TS9WAAW',
                'lecheliquida' => 'a2u70000000TS9XAAW',
                'lechepolvo' => 'a2u70000000TS9YAAW',
                'quesos' => 'a2u70000000TS9ZAAW',
                'yogur' => 'a2u70000000TS9aAAG'
            };
    
    // This will be a table that contains each food Id as the index, and a map of codes => Ids, as it's values
    public Map<Id, Map<String, Id>> codeLookupTable = new Map<Id, Map<String, Id>>();
    
    public ManaFoodConsumptionConfig() {
         // create the code lookup table
         for (Mana_Food_Quantity_Code__c[] codes: [Select Food__r.Id, Code__c, Id from Mana_Food_Quantity_Code__c]) {
            for(Mana_Food_Quantity_Code__c code: codes) {
                Map<String, Id> codeMap = null;
                if (this.codeLookupTable.containsKey(code.Food__r.Id)) {
                    codeMap = this.codeLookupTable.get(code.Food__r.Id);
                } else {
                    codeMap = new Map<String, Id>();
                }
                
                codeMap.put(code.Code__c, code.Id);
                this.codeLookupTable.put(code.Food__r.Id, codeMap);
            }
         }
    }
>>>>>>> origin/ci
}