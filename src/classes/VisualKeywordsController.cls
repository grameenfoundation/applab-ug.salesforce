/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This is the controller class for VisualKeywords page
 *  It defines a wrapper class that will represent the tree structure (nodes) and
 *  also esposes a remote action method that will be called to fetch the tree structure
 *  of any given menu
 *  Its test methods are in the VisualKeywordsTest class 
 **/
global class VisualKeywordsController {

    //we are using recursion - meaning we have to keep querying as we descend down the 
    //tree, this will hit governor limits hence the control variable "limit"
    private static Integer limit_val = 0;
    public String selectedTopMenu { get; set; }
    
    public VisualKeywordsController() {
    }

    /**
     * remote so that it can be called from VF using javascript
     * @param   menuId      the id of the menu whose tree is to be built
     * @param   menuLabel   the lable of the menu whose tree is to be built
     */
    @remoteAction
    global static List<MenuItem> getKeywords(String menuId, String menuLabel){
        String json_string = '';
        MenuItem topItem = new MenuItem(menuLabel, null);
        List<Menu_Item__c> topMenuChildren = [SELECT Id, Label__c, Menu__c FROM Menu_Item__c WHERE Is_Active__c = true AND Parent_Item__c = null AND Menu__r.Id = :menuId];
        limit_val++;
        for(Menu_Item__c item : topMenuChildren){
            topItem.addChild(getChildItems(item));
        } 
        return new List<MenuItem> { topItem };
    }

    /**
     * Recursively returns all child menu items of a given menu item following the parent-child
     * relationships.
     * During recursion, a new wrapper (MenuItem) is created for each menu item (node).
     * @return MenuItem a wrapper for the passed menu item
     */
    public static MenuItem getChildItems(Menu_Item__c currentLevel){
        MenuItem currentItemWrapper = new MenuItem(currentLevel.Label__c, null);
        List<Menu_Item__c> currentLevelChildren = [SELECT Id, Label__c, Menu__c FROM Menu_Item__c WHERE Is_Active__c = true AND Parent_Item__c = :currentLevel.Id];
        limit_val++;
        for(Menu_Item__c item : currentLevelChildren){
            if(limit_val == 80) {
                System.debug(LoggingLevel.WARN, 'Building Tree is stopping ascent due to the tree being too long');
                break;
            } else {
                currentItemWrapper.addChild(getChildItems(item));
            }
        }
        currentLevelChildren.clear();
        if(currentItemWrapper.getChildrenCount() == 0) {
            currentItemWrapper.setChildren(null);
        }
        return currentItemWrapper;  
    }

    /**
     * used by the UI to fetch top menu items. These will the the 
     * menus whose trees will be build
     * @returns List<SelectOption> a list of SelectOptions for visualforce rendering
     */
    public List<SelectOption> getTopMenus(){
        List<SelectOption> menus = new List<SelectOption>();
        for(Menu__c menu : [SELECT Id, Label__c, Name FROM Menu__c]){
            menus.add(new SelectOption(menu.Id, menu.Label__c));
        }
        return menus;
    }
    
    //set query limit - we will use this in tests only
    public void setLimit(Integer val){
        limit_val = val;
    }

    /**
    *   Wrapper class that will be used serialized to json and used by the d3 library
    *   to plot a parent-child tree. One instance of this class will be equivalent to
    *   one node in the tree
    */
    global class MenuItem {
        private String name;
        private List<MenuItem> children;
        
        public MenuItem(){
            this.children = new List<MenuItem>();
        }

        public MenuItem(String name, List<MenuItem> children){
            this.name = name;
            this.children = children == null ? new List<MenuItem>() : children;
        }
        
        public void addChild(MenuItem child){
            children.add(child);
        }
        
        public Integer getChildrenCount(){
            return children == null ? 0 : children.size();
        }
        
        public void setChildren(List<MenuItem> children){
            this.children = children;
        }
    }       
}