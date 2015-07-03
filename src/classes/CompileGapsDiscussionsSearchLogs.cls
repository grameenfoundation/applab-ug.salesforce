/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Compiles the search relating to GAPs in an effort
 * to calculate the top 5 most discussed GAPs
 *
 * Tests are in CompileGapsDiscussionsTests 
 */
global class CompileGapsDiscussionsSearchLogs implements Database.batchable<sObject>, Database.Stateful {
    
    global String query;
    global Map<String, X3_0_Top_GAPs__c> discussionsCount = new Map<String, X3_0_Top_GAPs__c>();
    
    global CompileGapsDiscussionsSearchLogs() {
        query = date.today().day() == 1 ?
            'SELECT '                                        +
                'Id,'                                        +
                'Query__c,'                                  +
                'Category__c,'                               +
                'Submission_GPS_Timestamp__c '               +
            'FROM '                                          +
                'Search_Log__c '                             +
            'WHERE '                                         +
                'CreatedDate = LAST_MONTH '                  +
                'AND Self_Search__c = FALSE ':
            'SELECT '                                        +
                'Id,'                                        +
                'Query__c,'                                  +
                'Category__c,'                               +
                'Submission_GPS_Timestamp__c '               +
            'FROM '                                          +
                'Search_Log__c '                             +
            'WHERE '                                         +
                'CreatedDate = THIS_MONTH '                  +
                'AND Self_Search__c = FALSE ';
         
         String countersQuery = date.today().day() == 1 ?
            'SELECT '                                +
                'Id, '                               +
                'Crop__c,'                           +
                'GAP__c,'                            +
                'Ckw_searches__c,'                   +
                'Ckw_group_meetings__c,'             +
                'Call_center__c,'                    +
                'Farmer_group_meetings__c,'          +
                'SMS__c '                            +
            'FROM '                                  +
                'X3_0_Top_GAPs__c '                  +
            'WHERE '                                 +
                'Month__c = ' + String.valueOf(date.today().addMonths(-1).toStartOfMonth()) :
            'SELECT '                                +
                'Id, '                               +
                'Crop__c,'                           +
                'GAP__c,'                            +
                'Ckw_searches__c,'                   +
                'Ckw_group_meetings__c,'             +
                'Call_center__c,'                    +
                'Farmer_group_meetings__c,'          +
                'SMS__c '                            +
            'FROM '                                  +
                'X3_0_Top_GAPs__c '                  +
            'WHERE '                                 +
                'Month__c = ' + String.valueOf(date.today().toStartOfMonth());

        List<X3_0_Top_GAPs__c> gapDiscussionsCounters = database.query(countersQuery);
        for(X3_0_Top_GAPs__c gap : gapDiscussionsCounters) {
            gap.Ckw_searches__c = 0;//we are recalculating this
            discussionsCount.put(gap.GAP__c.substring(0, gap.GAP__c.indexOf(':') + 1), gap);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Search_Log__c> logs) {
        
        for(Search_Log__c message : logs) {
            if(message.Query__c != null && message.Category__c != null) {
                //banana gap
                if(message.Query__c.containsIgnoreCase(bgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap1);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap1), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap2);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap2), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap3);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap3), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap4);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap4), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap5);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap5), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap6);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap6), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap7);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap7), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap8);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap8), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap9);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap9), gap);
                }
                else if(message.Query__c.containsIgnoreCase(bgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap10);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(bgap10), gap);
                }
                
                //coffee gap                
                else if(message.Query__c.containsIgnoreCase(cgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap1);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap1), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap2);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap2), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap3);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap3), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap4);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap4), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap5);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap5), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap6);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap6), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap7);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap7), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap8);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap8), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap9);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap9), gap);
                }
                else if(message.Query__c.containsIgnoreCase(cgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap10);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(cgap10), gap);
                }
                
                //maize gap                
                else if(message.Query__c.containsIgnoreCase(mgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap1);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap1), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap2);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap2), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap3);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap3), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap4);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap4), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap5);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap5), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap6);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap6), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap7);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap7), gap);
                }
                else if(message.Query__c.containsIgnoreCase(mgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap8);
                    gap.Ckw_searches__c++;
                    discussionsCount.put(getKey(mgap8), gap);
                }
            }
        }
    }
    
    private String getKey(String category) {
        String gapName = namalisedNamesLink.get(category);
        return gapName.substring(0, gapName.indexOf(':') + 1);        
    }
    
    private X3_0_Top_GAPs__c  getGapRecord(String category) {
        String key = getKey(category);
        for(X3_0_Top_GAPs__c gap : discussionsCount.values()) {
            if(gap.GAP__c.containsIgnoreCase(key)) {
                return gap;
            }
        }
        return new X3_0_Top_GAPs__c(
            Crop__c = key.split(' ')[0], 
            Gap__c = namalisedNamesLink.get(category), 
            Month__c = date.today().toStartOfMonth(), 
            Farmer_group_meetings__c = 0, 
            Call_center__c = 0,
            Ckw_searches__c = 0,
            Ckw_group_meetings__c = 0,
            SMS__c = 0
        );
    }
    
    global void finish(Database.BatchableContext BC) {
        upsert discussionsCount.values();
    }
    
    String bgap1 = 'Banana Gaps GAP 1:';
    String bgap2 = 'Banana Gaps GAP 2:';
    String bgap3 = 'Banana Gaps GAP 3:';
    String bgap4 = 'Banana Gaps GAP 4:';
    String bgap5 = 'Banana Gaps GAP 5:';
    String bgap6 = 'Banana Gaps GAP 6:';
    String bgap7 = 'Banana Gaps GAP 7:';
    String bgap8 = 'Banana Gaps GAP 8:';
    String bgap9 = 'Banana Gaps GAP 9:';
    String bgap10 = 'Banana Gaps GAP 10:';
    
    String cgap1 = 'Coffee Gaps Gap 1:';
    String cgap2 = 'Coffee Gaps Gap 2:';
    String cgap3 = 'Coffee Gaps GAP 3:';
    String cgap4 = 'Coffee Gaps Gap 4:';
    String cgap5 = 'Coffee Gaps Gap 5:';
    String cgap6 = 'Coffee Gaps Gap 6:';
    String cgap7 = 'Coffee Gaps Gap 7:';
    String cgap8 = 'Coffee Gaps Gap 8;';
    String cgap9 = 'Coffee Gaps Gap 9:';
    String cgap10 = 'Coffee Gaps Gap 10:';
    
    String mgap1 = 'Maize GAPs GAP 1:';
    String mgap2 = 'Maize GAPs GAP 2:';
    String mgap3 = 'Maize GAPs GAP 3:';
    String mgap4 = 'Maize GAPs GAP 4:';
    String mgap5 = 'Maize GAPs GAP 5:';
    String mgap6 = 'Maize GAPs GAP 6:';
    String mgap7 = 'Maize GAPs GAP 7:';
    String mgap8 = 'Maize GAPs GAP 8:';
    
    Map<String, String> namalisedNamesLink = new Map<String, String> {
        bgap1 => 'Banana GAP1: Soil Fertility',
        bgap2 => 'Banana GAP2: Desuckering, Pruning',
        bgap3 => 'Banana GAP3: Soil and Water Conservation',
        bgap4 => 'Banana GAP4: Support for Banana Plants',
        bgap5 => 'Banana GAP5: Record Keeping',
        bgap6 => 'Banana GAP6: Group Production, Marketing',
        bgap7 => 'Banana GAP7: Weed Control',
        bgap8 => 'Banana GAP8: Pests and Disease',
        bgap9 => 'Banana GAP9: Value Addition',
        bgap10 => 'Banana GAP10: Agro-inputs',
        
        cgap1 => 'Coffee GAP1: Soil Fertility',
        cgap2 => 'Coffee GAP2: Desuckering, Pruning',
        cgap3 => 'Coffee GAP3: Soil and Water Conservation',
        cgap4 => 'Coffee GAP4: Value Addition',
        cgap5 => 'Coffee GAP5: Record Keeping',
        cgap6 => 'Coffee GAP6: Group Production/ Marketing',
        cgap7 => 'Coffee GAP7: Weed Control',
        cgap8 => 'Coffee GAP8: Pests and Disease',
        cgap9 => 'Coffee GAP9: Processing',
        cgap10 => 'Coffee GAP10: Agro-inputs',
        
        mgap1 => 'Maize GAP1: Land Preparation',
        mgap2 => 'Maize GAP2: Proper Planting',
        mgap3 => 'Maize GAP3: Seed Selection',
        mgap4 => 'Maize GAP4: Soil Fertility Management',
        mgap5 => 'Maize GAP5: Pest and Disease',
        mgap6 => 'Maize GAP6: Harvesting',
        mgap7 => 'Maize GAP7: Bulking Marketing',
        mgap8 => 'Maize GAP8: Record Keeping'
    };
}