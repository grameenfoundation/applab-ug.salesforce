/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Batch class to compile stats for top discussed GAPs through SMS
 *
 * Tests for this class are in CompileGapsDiscussionsTests class
 **/
global class CompileGapsDiscussionsSms implements Database.batchable<sObject>, Database.Stateful {
    
    global String query;
    global Map<String, X3_0_Top_GAPs__c> discussionsCount = new Map<String, X3_0_Top_GAPs__c>();
    
    global CompileGapsDiscussionsSms() {
        query = date.today().day() == 1 ?
            'SELECT '                                        +
                'Id,'                                        +
                'Category__c,'                               +
                'CreatedDate'                                +
            'FROM '                                          +
                'Message__c '                                +
            'WHERE '                                         +
                'CreatedDate = LAST_MONTH AND Type__c = \'SMS\'' :
            'SELECT '                                        +
                'Id,'                                        +
                'Category__c,'                               +
                'CreatedDate '                               +
            'FROM '                                          +
                'Message__c '                                +
            'WHERE '                                         +
                'CreatedDate = THIS_MONTH AND Type__c = \'SMS\'';
         
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
                'Month__c = ' + String.valueOf(date.today().addMonths(-1).toStartOfMonth()):
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
            gap.SMS__c = 0;//we are recalculating this
            discussionsCount.put(gap.GAP__c.substring(0, gap.GAP__c.indexOf(':') + 1), gap);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Message__c> messages) {
        
        for(Message__c message : messages) {
            if(message.Category__c != null) {
                //banana gap
                if(message.Category__c.containsIgnoreCase(bgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap1, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap1, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap2, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap2, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap3, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap3, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap4, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap4, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap5, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap5, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap6, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap6, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap7, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap7, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap8, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap8, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap9, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap9, gap);
                }
                else if(message.Category__c.containsIgnoreCase(bgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap10, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(bgap10, gap);
                }
                
                //coffee gap                
                else if(message.Category__c.containsIgnoreCase(cgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap1, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap1, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap2, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap2, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap3, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap3, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap4, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap4, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap5, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap5, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap6, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap6, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap7, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap7, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap8, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap8, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap9, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap9, gap);
                }
                else if(message.Category__c.containsIgnoreCase(cgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(cgap10, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(cgap10, gap);
                }
                
                //maize gap                
                else if(message.Category__c.containsIgnoreCase(mgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap1, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap1, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap2, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap2, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap3, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap3, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap4, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap4, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap5, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap5, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap6, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap6, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap7, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap7, gap);
                }
                else if(message.Category__c.containsIgnoreCase(mgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(mgap8, message.Category__c);
                    gap.SMS__c++;
                    discussionsCount.put(mgap8, gap);
                }
            }
        }
    }
    
    private X3_0_Top_GAPs__c  getGapRecord(String category, String value) {
        for(X3_0_Top_GAPs__c gap : discussionsCount.values()) {
            if(gap.GAP__c.containsIgnoreCase(category)) {
                return gap;
            }
        }
        return new X3_0_Top_GAPs__c(
            Crop__c = category.split(' ')[0], 
            Gap__c = value, 
            Month__c = date.today().toStartOfMonth(), 
            SMS__c = 0,
            Farmer_group_meetings__c = 0, 
            Call_center__c = 0,
            Ckw_searches__c = 0,
            Ckw_group_meetings__c = 0
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