/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 * 
 * Unfortunately, you cannot have more than 5 batch classes execute at a go hence this class
 * Tests for this class are in CompileGapsDiscussionsTests class
 **/
global class CompileGapsDiscussionsScheduler2 implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CompileGapsDiscussionsSearchLogs(), 50);
        Database.executeBatch(new CompileGapsDiscussionsSms(), 50);
        Database.executeBatch(new CompileGapsDiscussionsCalls(), 50);
    }
}