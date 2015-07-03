/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Compiles the call center call related to GAPs in an effort
 * to calculate the top 5 most discussed GAPs
 *
 * Tests are in CompileGapsDiscussionsTests 
 */
global class CompileGapsDiscussionsCalls implements Database.batchable<sObject>, Database.Stateful {
    
    global String query;
    global Map<String, X3_0_Top_GAPs__c> discussionsCount = new Map<String, X3_0_Top_GAPs__c>();
    
    global CompileGapsDiscussionsCalls() {
        query = date.today().day() == 1 ?
            'SELECT '                                        +
                'Id,'                                        +
                'Category__c,'                               +
                'CreatedDate '                               +
            'FROM '                                          +
                'Case '                                      +
            'WHERE '                                         +
                'CreatedDate = LAST_MONTH' :
            'SELECT '                                        +
                'Id,'                                        +
                'Category__c,'                               +
                'CreatedDate '                               +
            'FROM '                                          +
                'Case '                                      +
            'WHERE '                                         +
                'CreatedDate = THIS_MONTH';
         
         String countersQuery = date.today().day() == 1 ?
            'SELECT '                                +
                'Id, '                               +
                'Crop__c,'                           +
                'GAP__c,'                            +
                'Call_center__c,'                    +
                'Ckw_group_meetings__c,'             +
                'Ckw_searches__c,'                   +
                'Farmer_group_meetings__c,'          +
                'SMS__c '                            +
            'FROM '                                  +
                'X3_0_Top_GAPs__c '                  +
            'WHERE '                                 +
                'Month__c = ' + date.today().addMonths(-1).toStartOfMonth() + ' ' :
            'SELECT '                                +
                'Id, '                               +
                'Crop__c,'                           +
                'GAP__c,'                            +
                'Call_center__c,'                    +
                'Ckw_group_meetings__c,'             +
                'Ckw_searches__c,'                   +
                'Farmer_group_meetings__c,'          +
                'SMS__c '                            +
            'FROM '                                  +
                'X3_0_Top_GAPs__c '                  +
            'WHERE '                                 +
                'Month__c = ' + String.valueOf(date.today().toStartOfMonth());

        List<X3_0_Top_GAPs__c> gapDiscussionsCounters = database.query(countersQuery);
        for(X3_0_Top_GAPs__c gap : gapDiscussionsCounters) {
            gap.Call_center__c = 0;//we are recalculating this
            discussionsCount.put(gap.GAP__c.substring(0, gap.GAP__c.indexOf(':') + 1), gap);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases) {
        
        for(Case message : cases) {
            if(message.Category__c != null) {
                //banana gap
                if(message.Category__c.startsWithIgnoreCase(bgap1)) {
                    X3_0_Top_GAPs__c gap1 = getGapRecord(bgap1, message.Category__c);
                    gap1.Call_center__c++;
                    discussionsCount.put(bgap1, gap1);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap2)) {
                    X3_0_Top_GAPs__c gap2 = getGapRecord(bgap2, message.Category__c);
                    gap2.Call_center__c++;
                    discussionsCount.put(bgap2, gap2);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap3)) {
                    X3_0_Top_GAPs__c gap3 = getGapRecord(bgap3, message.Category__c);
                    gap3.Call_center__c++;
                    discussionsCount.put(bgap3, gap3);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap4)) {
                    X3_0_Top_GAPs__c gap4 = getGapRecord(bgap4, message.Category__c);
                    gap4.Call_center__c++;
                    discussionsCount.put(bgap4, gap4);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap5)) {
                    X3_0_Top_GAPs__c gap5 = getGapRecord(bgap5, message.Category__c);
                    gap5.Call_center__c++;
                    discussionsCount.put(bgap5, gap5);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap6)) {
                    X3_0_Top_GAPs__c gap6 = getGapRecord(bgap6, message.Category__c);
                    gap6.Call_center__c++;
                    discussionsCount.put(bgap6, gap6);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap7)) {
                    X3_0_Top_GAPs__c gap7 = getGapRecord(bgap7, message.Category__c);
                    gap7.Call_center__c++;
                    discussionsCount.put(bgap7, gap7);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap8)) {
                    X3_0_Top_GAPs__c gap8 = getGapRecord(bgap8, message.Category__c);
                    gap8.Call_center__c++;
                    discussionsCount.put(bgap8, gap8);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap9)) {
                    X3_0_Top_GAPs__c gap9 = getGapRecord(bgap9, message.Category__c);
                    gap9.Call_center__c++;
                    discussionsCount.put(bgap9, gap9);
                }
                else if(message.Category__c.startsWithIgnoreCase(bgap10)) {
                    X3_0_Top_GAPs__c gap0 = getGapRecord(bgap10, message.Category__c);
                    gap0.Call_center__c++;
                    discussionsCount.put(bgap10, gap0);
                }
                
                //coffee gap                
                else if(message.Category__c.startsWithIgnoreCase(cgap1)) {
                    X3_0_Top_GAPs__c gap11 = getGapRecord(cgap1, message.Category__c);
                    gap11.Call_center__c++;
                    discussionsCount.put(cgap1, gap11);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap2)) {
                    X3_0_Top_GAPs__c gap22 = getGapRecord(cgap2, message.Category__c);
                    gap22.Call_center__c++;
                    discussionsCount.put(cgap2, gap22);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap3)) {
                    X3_0_Top_GAPs__c gap33 = getGapRecord(cgap3, message.Category__c);
                    gap33.Call_center__c++;
                    discussionsCount.put(cgap3, gap33);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap4)) {
                    X3_0_Top_GAPs__c gap44 = getGapRecord(cgap4, message.Category__c);
                    gap44.Call_center__c++;
                    discussionsCount.put(cgap4, gap44);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap5)) {
                    X3_0_Top_GAPs__c gap55 = getGapRecord(cgap5, message.Category__c);
                    gap55.Call_center__c++;
                    discussionsCount.put(cgap5, gap55);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap6)) {
                    X3_0_Top_GAPs__c gap66 = getGapRecord(cgap6, message.Category__c);
                    gap66.Call_center__c++;
                    discussionsCount.put(cgap6, gap66);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap7)) {
                    X3_0_Top_GAPs__c gap77 = getGapRecord(cgap7, message.Category__c);
                    gap77.Call_center__c++;
                    discussionsCount.put(cgap7, gap77);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap8)) {
                    X3_0_Top_GAPs__c gap88 = getGapRecord(cgap8, message.Category__c);
                    gap88.Call_center__c++;
                    discussionsCount.put(cgap8, gap88);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap9)) {
                    X3_0_Top_GAPs__c gap99 = getGapRecord(cgap9, message.Category__c);
                    gap99.Call_center__c++;
                    discussionsCount.put(cgap9, gap99);
                }
                else if(message.Category__c.startsWithIgnoreCase(cgap10)) {
                    X3_0_Top_GAPs__c gap00 = getGapRecord(cgap10, message.Category__c);
                    gap00.Call_center__c++;
                    discussionsCount.put(cgap10, gap00);
                }
                
                //maize gap                
                else if(message.Category__c.startsWithIgnoreCase(mgap1)) {
                    X3_0_Top_GAPs__c gap111 = getGapRecord(mgap1, message.Category__c);
                    gap111.Call_center__c++;
                    discussionsCount.put(mgap1, gap111);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap2)) {
                    X3_0_Top_GAPs__c gap222 = getGapRecord(mgap2, message.Category__c);
                    gap222.Call_center__c++;
                    discussionsCount.put(mgap2, gap222);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap3)) {
                    X3_0_Top_GAPs__c gap333 = getGapRecord(mgap3, message.Category__c);
                    gap333.Call_center__c++;
                    discussionsCount.put(mgap3, gap333);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap4)) {
                    X3_0_Top_GAPs__c gap444 = getGapRecord(mgap4, message.Category__c);
                    gap444.Call_center__c++;
                    discussionsCount.put(mgap4, gap444);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap5)) {
                    X3_0_Top_GAPs__c gap555 = getGapRecord(mgap5, message.Category__c);
                    gap555.Call_center__c++;
                    discussionsCount.put(mgap5, gap555);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap6)) {
                    X3_0_Top_GAPs__c gap666 = getGapRecord(mgap6, message.Category__c);
                    gap666.Call_center__c++;
                    discussionsCount.put(mgap6, gap666);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap7)) {
                    X3_0_Top_GAPs__c gap777 = getGapRecord(mgap7, message.Category__c);
                    gap777.Call_center__c++;
                    discussionsCount.put(mgap7, gap777);
                }
                else if(message.Category__c.startsWithIgnoreCase(mgap8)) {
                    X3_0_Top_GAPs__c gap888 = getGapRecord(mgap8, message.Category__c);
                    gap888.Call_center__c++;
                    discussionsCount.put(mgap8, gap888);
                }
            }
        }
    }
    
    private X3_0_Top_GAPs__c  getGapRecord(String category, String value) {
        for(X3_0_Top_GAPs__c gap : discussionsCount.values()) {
            if(gap.GAP__c.startsWithIgnoreCase(category)) {
                return gap;
            }
        }
        return new X3_0_Top_GAPs__c(
            Crop__c = category.split(' ')[0], 
            Gap__c = value, 
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
    
    String bgap1 = 'Banana GAP1:';
    String bgap2 = 'Banana GAP2:';
    String bgap3 = 'Banana GAP3:';
    String bgap4 = 'Banana GAP4:';
    String bgap5 = 'Banana GAP5:';
    String bgap6 = 'Banana GAP6:';
    String bgap7 = 'Banana GAP7:';
    String bgap8 = 'Banana GAP8:';
    String bgap9 = 'Banana GAP9:';
    String bgap10 = 'Banana GAP10:';
    
    String cgap1 = 'Coffee GAP1:';
    String cgap2 = 'Coffee GAP2:';
    String cgap3 = 'Coffee GAP3:';
    String cgap4 = 'Coffee GAP4:';
    String cgap5 = 'Coffee GAP5:';
    String cgap6 = 'Coffee GAP6:';
    String cgap7 = 'Coffee GAP7:';
    String cgap8 = 'Coffee GAP8:';
    String cgap9 = 'Coffee GAP9:';
    String cgap10 = 'Coffee GAP10:';
    
    String mgap1 = 'Maize GAP1:';
    String mgap2 = 'Maize GAP2:';
    String mgap3 = 'Maize GAP3:';
    String mgap4 = 'Maize GAP4:';
    String mgap5 = 'Maize GAP5:';
    String mgap6 = 'Maize GAP6:';
    String mgap7 = 'Maize GAP7:';
    String mgap8 = 'Maize GAP8:';
}