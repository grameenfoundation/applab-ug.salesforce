/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Contains tests for the following classes:
 *      - VisualKeywordsController
 **/
@isTest
private class VisualKeywordsControllerTest {
    
    @isTest
    static void testAll(){
    
        Account acc = Utils.createTestOrganisation('CKW');
        insert acc;
        
        //create top menu
        Menu__c menu = new Menu__c();
        menu.Label__c = 'Top';
        menu.Account__c = acc.Id;
        insert menu;

        //create first level child
        Menu_Item__c item = new Menu_Item__c();
        item.Label__c = 'Child';
        item.Menu__c = menu.Id;
        item.Parent_Item__c = null;
        insert item;
        
        //create first level child who is inactive - this should not appear
        Menu_Item__c item0 = new Menu_Item__c();
        item0.Label__c = 'Child 2 (Inactive)';
        item0.Menu__c = menu.Id;
        item0.Parent_Item__c = null;
        item0.Is_Active__c = false;
        insert item0;

        //create a second leve child under first level child
        Menu_Item__c item1 = new Menu_Item__c();
        item1.Label__c = 'Grand Child';
        item1.Menu__c = menu.Id;
        item1.Parent_Item__c = item.Id;
        insert item1;

        //create a second grand child
        Menu_Item__c item2 = new Menu_Item__c();
        item2.Label__c = 'Grand Child 2';
        item2.Menu__c = menu.Id;
        item2.Parent_Item__c = item.Id;
        insert item2;

        //create a greate grand child
        Menu_Item__c item11 = new Menu_Item__c();
        item11.Label__c = 'Great Grand Child';
        item11.Menu__c = menu.Id;
        item11.Parent_Item__c = item1.Id;
        insert item11;
        
        //instantiate controller and set the label (as would be with selection a menu in VF)
        VisualKeywordsController controller = new VisualKeywordsController();
        controller.selectedTopMenu = menu.Label__c;
        
        //we set the query limit to 87, at 90, building the tree stops
        controller.setLimit(87);

        //call the remote action passing the name and id of top menu whose tree we are building
        //here, we expect one item back
        //we also expect that item to have only one child (the second child is inactive and is this not returned)
        LIST<VisualKeywordsController.MenuItem> top = VisualKeywordsController.getKeywords(menu.Id, menu.Label__c);
        System.assert(top.size() == 1);   
        System.assert(top[0].getChildrenCount() == 1);     
        
        //test to see if a would-be VF menu selection passed
        List<SelectOption> menus = controller.getTopMenus();
        System.assert(menus.size() == 1);
        
        //test if on creatio of a wrapper, the default child count is zero, no null pointers
        VisualKeywordsController.MenuItem wrapper = new VisualKeywordsController.MenuItem();
        System.assert(wrapper.getChildrenCount() == 0);
    }   
    
}