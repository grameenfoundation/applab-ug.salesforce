/**
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Compiles the farmer meetings relating to GAPs in an effort
 * to calculate the top 5 most discussed GAPs
 *
 * Tests are in CompileGapsDiscussionsTests 
 */
global class CompileGapsDiscussionsFarmerMeetings implements Database.batchable<sObject>, Database.Stateful {
    
    String banana = 'Banana';
    String coffee = 'Coffee';
    String maize = 'Maize';
    global String query;
    global Map<String, X3_0_Top_GAPs__c> discussionsCount = new Map<String, X3_0_Top_GAPs__c>();
    
    global CompileGapsDiscussionsFarmerMeetings(String query, String crop) {
        this.query = query;
         
        String countersQuery = date.today().day() == 1 ?                                                                 
            'SELECT '                                   +
                'Id, '                                  +
                'Crop__c,'                              +
                'GAP__c,'                               +
                'Call_center__c,'                       +
                'Ckw_group_meetings__c,'                +
                'Ckw_searches__c,'                      +
                'Farmer_group_meetings__c,'             +
                'SMS__c '                               +
            'FROM '                                     +
                'X3_0_Top_GAPs__c '                     +
            'WHERE '                                    +
                'Crop__c = \'' + crop + '\' '           +
                'AND Month__c = ' + String.valueOf(date.today().addMonths(-1).toStartOfMonth()) + ' ' :
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
                'Crop__c = \'' + crop + '\' '        +
                'AND Month__c = ' + String.valueOf(date.today().toStartOfMonth());

        List<X3_0_Top_GAPs__c> gapDiscussionsCounters = database.query(countersQuery);
        for(X3_0_Top_GAPs__c gap : gapDiscussionsCounters) {
            gap.Farmer_group_meetings__c = 0;//we are recalculating this
            discussionsCount.put(gap.GAP__c.substring(0, gap.GAP__c.indexOf(':') + 1), gap);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            if(String.valueOf(scope.get(0).getsobjecttype()).equalsIgnoreCase('Banana_Cluster_Meeting__c')) {
                processBananaGroupMeetings(scope);
            }
            else if(String.valueOf(scope.get(0).getsobjecttype()).equalsIgnoreCase('Coffee_Cluster_Meeting__c')) {
                processCoffeeGroupMeetings(scope);
            }
            else if(String.valueOf(scope.get(0).getsobjecttype()).equalsIgnoreCase('Maize_Cluster_Meeting__c')) {
                processMaizeGroupMeetings(scope);
            }
        }
    }
    
    private void processBananaGroupMeetings(List<Banana_Cluster_Meeting__c> messages) {
        for(Banana_Cluster_Meeting__c meeting: messages) {
            if(meeting.What_GAPs_were_discussed_at_the_meeting__c != null) {
                String message = meeting.What_GAPs_were_discussed_at_the_meeting__c;
                if(message.contains(bgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap1, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap1), gap);
                }
                if(message.contains(bgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap2, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap2), gap);
                }
                if(message.contains(bgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap3, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap3), gap);
                }
                if(message.contains(bgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap4, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap4), gap);
                }
                if(message.contains(bgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap5, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap5), gap);
                }
                if(message.contains(bgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap6, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap6), gap);
                }
                if(message.contains(bgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap7, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap7), gap);
                }
                if(message.contains(bgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap8, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap8), gap);
                }
                if(message.contains(bgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap9, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap9), gap);
                }
                if(message.contains(bgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap10, banana);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(banana, bgap10), gap);
                }
            }
        }    
    }
    
    private void processCoffeeGroupMeetings(List<Coffee_Cluster_Meeting__c> messages) {
        for(Coffee_Cluster_Meeting__c meeting : messages) {
            if(meeting.What_GAPs_were_discussed_at_the_meeting__c != null) { 
                String message = meeting.What_GAPs_were_discussed_at_the_meeting__c;
                if(message.contains(bgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap1, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap1), gap);
                }
                if(message.contains(bgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap2, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap2), gap);
                }
                if(message.contains(bgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap3, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap3), gap);
                }
                if(message.contains(bgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap4, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap4), gap);
                }
                if(message.contains(bgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap5, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap5), gap);
                }
                if(message.contains(bgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap6, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap6), gap);
                }
                if(message.contains(bgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap7, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap7), gap);
                }
                if(message.contains(bgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap8, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap8), gap);
                }
                if(message.contains(bgap9)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap9, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap9), gap);
                }
                if(message.contains(bgap10)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap10, coffee);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap10), gap);
                }
            }
        }    
    }
    
    private void processMaizeGroupMeetings(List<Maize_Cluster_Meeting__c> messages) {
        for(Maize_Cluster_Meeting__c meeting : messages) {
            if(meeting.What_GAPs_were_discussed_at_the_meeting__c != null) {       
                String message = meeting.What_GAPs_were_discussed_at_the_meeting__c;        
                if(message.contains(bgap1)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap1, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap1), gap);
                }
                if(message.contains(bgap2)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap2, maize);
                    gap.Call_center__c++;
                    discussionsCount.put(getKey(maize, bgap2), gap);
                }
                if(message.contains(bgap3)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap3, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap3), gap);
                }
                if(message.contains(bgap4)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap4, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap4), gap);
                }
                if(message.contains(bgap5)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap5, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(coffee, bgap5), gap);
                }
                if(message.contains(bgap6)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap6, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap6), gap);
                }
                if(message.contains(bgap7)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap7, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap7), gap);
                }
                if(message.contains(bgap8)) {
                    X3_0_Top_GAPs__c gap = getGapRecord(bgap8, maize);
                    gap.Farmer_group_meetings__c++;
                    discussionsCount.put(getKey(maize, bgap8), gap);
                }
            }
        }    
    }
    
    private String getKey(String crop, String gapNo) {
        return crop + ' ' + gapNo.replace(' ', '');
    }
    
    private X3_0_Top_GAPs__c  getGapRecord(String gapNo, String crop) {

        for(X3_0_Top_GAPs__c gap : discussionsCount.values()) {
            if(gap.GAP__c.containsIgnoreCase(getKey(crop, gapNo))) {
                return gap;
            }
        }
        return new X3_0_Top_GAPs__c(
            Crop__c = crop, 
            Gap__c = namalisedNamesLink.get(crop + ' ' + gapNo), 
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
    
    String bgap1 = 'GAP 1:';
    String bgap2 = 'GAP 2:';
    String bgap3 = 'GAP 3:';
    String bgap4 = 'GAP 4:';
    String bgap5 = 'GAP 5:';
    String bgap6 = 'GAP 6:';
    String bgap7 = 'GAP 7:';
    String bgap8 = 'GAP 8:';
    String bgap9 = 'GAP 9:';
    String bgap10 = 'GAP 10:';
    
    Map<String, String> namalisedNamesLink = new Map<String, String> {
        banana + ' ' + bgap1 => 'Banana GAP1: Soil Fertility',
        banana + ' ' + bgap2 => 'Banana GAP2: Desuckering, Pruning',
        banana + ' ' + bgap3 => 'Banana GAP3: Soil and Water Conservation',
        banana + ' ' + bgap4 => 'Banana GAP4: Support for Banana Plants',
        banana + ' ' + bgap5 => 'Banana GAP5: Record Keeping',
        banana + ' ' + bgap6 => 'Banana GAP6: Group Production, Marketing',
        banana + ' ' + bgap7 => 'Banana GAP7: Weed Control',
        banana + ' ' + bgap8 => 'Banana GAP8: Pests and Disease',
        banana + ' ' + bgap9 => 'Banana GAP9: Value Addition',
        banana + ' ' + bgap10 => 'Banana GAP10: Agro-inputs',
        
        coffee + ' ' + bgap1 => 'Coffee GAP1: Soil Fertility',
        coffee + ' ' + bgap2 => 'Coffee GAP2: Desuckering, Pruning',
        coffee + ' ' + bgap3 => 'Coffee GAP3: Soil and Water Conservation',
        coffee + ' ' + bgap4 => 'Coffee GAP4: Value Addition',
        coffee + ' ' + bgap5 => 'Coffee GAP5: Record Keeping',
        coffee + ' ' + bgap6 => 'Coffee GAP6: Group Production/ Marketing',
        coffee + ' ' + bgap7 => 'Coffee GAP7: Weed Control',
        coffee + ' ' + bgap8 => 'Coffee GAP8: Pests and Disease',
        coffee + ' ' + bgap9 => 'Coffee GAP9: Processing',
        coffee + ' ' + bgap10 => 'Coffee GAP10: Agro-inputs',
        
        maize + ' ' + bgap1 => 'Maize GAP1: Land Preparation',
        maize + ' ' + bgap2 => 'Maize GAP2: Proper Planting',
        maize + ' ' + bgap3 => 'Maize GAP3: Seed Selection',
        maize + ' ' + bgap4 => 'Maize GAP4: Soil Fertility Management',
        maize + ' ' + bgap5 => 'Maize GAP5: Pest and Disease',
        maize + ' ' + bgap6 => 'Maize GAP6: Harvesting',
        maize + ' ' + bgap7 => 'Maize GAP7: Bulking Marketing',
        maize + ' ' + bgap8 => 'Maize GAP8: Record Keeping'
    };
}