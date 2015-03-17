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

    //there is only so much you can display on a VF page. we are going to set a limit of
    //MAX_TREE_DEPTH nodes to plot. we expect not to reach this before hitting governor limits
    private static Integer MAX_TREE_DEPTH = 200;
    private static List<Cluster> clusters_parent_with_children = new List<Cluster>();
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
        //top menu and its children (forms the first cluster)
        MenuItem topItem = new MenuItem(menuLabel, null);
        List<Menu_Item__c> topMenuChildren = [SELECT Id, Label__c, Menu__c FROM Menu_Item__c WHERE Is_Active__c = true AND Parent_Item__c = null AND Menu__r.Id = :menuId];
         
        clusters_parent_with_children.add(new Cluster(topItem, wrapMenuItems(topMenuChildren), menuId));
        buildClusters();
        return new List<MenuItem>{ buildNodes(clusters_parent_with_children.get(0)) };
    }
    
    /**
    * Takes one cluster and recursively builds more clusters from child nodes
    * @param  Cluster   the top cluster
    * @return MenuItem  a top level node with all its child nodes inside it
    */
    private static MenuItem buildNodes(Cluster cluster){
        if(cluster == null) {
            return null;
        }
        MenuItem node = cluster.node;
        if(cluster.children != null){
            for(MenuItem child : cluster.children){
                node.addChild(buildNodes(getCluster(child)));
            }
        }
        if(node.children != null && node.children.size() == 0){
            node.setChildren(null);
        }
        return node;
    }

    /**
    * All the clusters we keep building are kept in a list. This method
    * helps search a retrieve a given cluster based on its parent node
    * @param  MenuItem  a node whose cluster we are looking up
    * @return Cluster   a cluster found in our pile of all clusters
    */
    private static Cluster getCluster(MenuItem parent){
        Cluster item = null;
        for(Cluster c : clusters_parent_with_children){
            if(c.id == parent.id){
                item = c;
            }
        }
        return item;
    }

    /**
    * We only start with the top level cluster (i.e menu and its children)
    * this method reads the n-children in this cluster and creates n more 
    * clusters, adding them to the same general collection of clusters.
    * The process is repeated for the newly created clusters' children
    */
    private static void buildClusters(){
        Boolean stop = false;
        for(Integer i = 0; i < MAX_TREE_DEPTH; i++) {
            System.debug(LoggingLevel.INFO, 'processing cluster number ' + i + ' of ' + clusters_parent_with_children.size());
            if(clusters_parent_with_children.size() > i){
                Cluster cluster = clusters_parent_with_children.get(i);
                if(cluster.children != null){
                    for(MenuItem child : cluster.children){
                        if(Limits.getQueries() < Limits.getLimitQueries()) {
                            List<Menu_Item__c> childsChildren = [SELECT Id, Label__c, Menu__c FROM Menu_Item__c WHERE Is_Active__c = true AND Parent_Item__c = :child.id];
                            clusters_parent_with_children.add(new Cluster(child, wrapMenuItems(childsChildren), child.id));
                        } else {
                            System.debug(LoggingLevel.WARN, i + ' breaking, clusters too many');
                            stop = true;
                            break;
                        }
                    }
                } else {
                    System.debug(LoggingLevel.INFO, i + ' there were no children in cluster');
                }
                if(stop){
                    break;
                }
            } else {
                System.debug(LoggingLevel.WARN, i + ' no more clusters to process');
                stop = true;
                break;
            }
        }
    }
    
    /**
    * wraps items of SObjects into MenuItem wrappers which is what the VF page
    * requires for visualization
    * @param  List of menu items SObjects
    * @return List of MenuItems
    */
    private static List<MenuItem> wrapMenuItems(List<Menu_Item__c> menuItems){
        List<MenuItem> items = new List<MenuItem>();
        for(Menu_Item__c m : menuItems){
            items.add(new MenuItem(m.Label__c, null, String.valueOf(m.Id)));
        }
        if(menuItems.size() == 0){
            return null;
        }
        return items;
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
        MAX_TREE_DEPTH = val;
    }

    /**
    *   Wrapper class that will be used serialized to json and used by the d3 library
    *   to plot a parent-child tree. One instance of this class will be equivalent to
    *   one node in the tree
    */
    global class MenuItem {
        private String name;
        private List<MenuItem> children;
        public String id { get; set; }
        
        public MenuItem(){
            this.children = new List<MenuItem>();
        }

        public MenuItem(String name, List<MenuItem> children){
            this.name = name;
            this.children = children == null ? new List<MenuItem>() : children;
        }

        public MenuItem(String name, List<MenuItem> children, String id){
            this.name = name;
            this.id = id;
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

    /**
     * a wrapper class for a cluster:
     * a cluster is a group consisting of a parent node and all its children
     * this should help us pass the nodes around 
     */
    global class Cluster {
        public Cluster(MenuItem parent, List<MenuItem> children, String id){
            this.node = parent;
            this.children = children;
            this.id = id;
        }
        public MenuItem node { get; set; }
        public List<MenuItem> children { get; set; }
        public String id { get; set; }
    }    
}