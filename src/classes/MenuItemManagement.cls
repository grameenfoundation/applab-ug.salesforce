public with sharing class MenuItemManagement {
    public Menu_Item__c currentMenuItem {get; set;}
    
    public MenuItemManagement(ApexPages.StandardController controller) {
        this.currentMenuItem = this.loadCurrentMenuItem();
    }
    
    public MenuItemManagement() {
        this.currentMenuItem = this.loadCurrentMenuItem();
    }

    public Menu_Item__c[] getSubMenuItems() {
        return [Select Id, Name, Article_Id__c, Content__c, Position__c, Label__c from Menu_Item__c where Parent_Item__c = :System.currentPageReference().getParameters().get('id') order by Position__c ASC, Label__c ASC];
    }
    
    private Menu_Item__c loadCurrentMenuItem() {
        return this.loadMenuItemFromId(System.currentPageReference().getParameters().get('id'));
    }
    
    public String getPath() {
        return this.getParentPath(this.currentMenuItem) + ' > <a href="/apex/MenuItemManagement?id=' + this.currentMenuItem.Id + '" target="_top">' + this.currentMenuItem.Label__c  + '</a>' ;
    }
    
    private String getParentPath(Menu_Item__c menuItem) {
        if(null == menuItem.Parent_Item__c) {
            if(null == menuItem.Menu__c) {
                return 'Orphaned Item (Has No Menu)!';
            } else {
                return '<a href="/apex/MenuManagement?id=' + menuItem.Menu__r.Id + '" target="_top">' + menuItem.Menu__r.Label__c + '</a>';
            }
        } else {
            Menu_Item__c parent = loadMenuItemFromId(menuItem.Parent_Item__c);
            return getParentPath(parent) + ' > <a href="/apex/MenuItemManagement?id=' + parent.Id+ '" target="_top">' + parent.Label__c  + '</a>' ;
        }
    }
    
    private Menu_Item__c loadMenuItemFromId(String Id) {
        return [Select Id, Name, Label__c, Article_Id__c, Content__c, Parent_Item__c, Menu__c, Menu__r.Name, Menu__r.Id, Menu__r.Label__c from Menu_Item__c where Id = :Id limit 1];
    }
    
    public List<ArticleNameValueMap> getArticleInfo() {
        List<ArticleNameValueMap> info = new List<ArticleNameValueMap>();
        if(null == this.currentMenuItem.Article_Id__c || this.currentMenuItem.Article_Id__c == '') {
            info.add(this.createNameValueMap('No article', 'No article to display'));
            return info;
        } else {
            String articleId = this.currentMenuItem.Article_Id__c;
            
            KnowledgeArticle article = [Select Id from KnowledgeArticle WHERE ArticleNumber = :this.currentMenuItem.Article_Id__c limit 1];
            info.add(this.createNameValueMap('Article Id', articleId + ' (' + article.Id + ')'));
            
            KnowledgeArticleVersion[] articleVersion = [Select KnowledgeArticleId, Title, Summary, PublishStatus from KnowledgeArticleVersion WHERE PublishStatus='Online' AND KnowledgeArticleId = :article.Id limit 1];
            if(articleVersion.size() > 0) {
                info.add(this.createNameValueMap('Status', 'Published'));
                info.add(this.createNameValueMap('Title', '<a href="/knowledge/publishing/articleOnlineDetail.apexp?id=' + articleVersion[0].KnowledgeArticleId + '" target="_top">' + articleVersion[0].Title + '</a>'));
            } else {
                articleVersion = [Select KnowledgeArticleId, Title, Summary, PublishStatus from KnowledgeArticleVersion WHERE PublishStatus='Draft' AND KnowledgeArticleId = :article.Id limit 1];
                if(articleVersion.size() > 0) {
                    info.add(this.createNameValueMap('Status', 'Draft'));
                    info.add(this.createNameValueMap('Title', '<a href="/knowledge/publishing/articleDraftDetail.apexp?id=' + articleVersion[0].KnowledgeArticleId + '" target="_top">' + articleVersion[0].Title + '</a>'));
                } else {
                    articleVersion = [Select KnowledgeArticleId, Title, Summary, PublishStatus from KnowledgeArticleVersion WHERE PublishStatus='Archived' AND KnowledgeArticleId = :article.Id limit 1];
                    if(articleVersion.size() > 0) {
                        info.add(this.createNameValueMap('Status', 'Archived'));
                        info.add(this.createNameValueMap('Title', '<a href="/knowledge/publishing/articleArchivedDetail.apexp?id=' + articleVersion[0].KnowledgeArticleId + '" target="_top">' + articleVersion[0].Title + '</a>'));
                    } else {
                        info.add(this.createNameValueMap('Error', '<strong><font color="red">Cannot load article details</font>'));
                    }
                }
            }
            
            if(articleVersion.size() > 0 && null != articleVersion[0].Summary) {
               info.add(this.createNameValueMap('Summary', ((articleVersion[0].Summary.length() > 30)?articleVersion[0].Summary.substring(0,31) + '...':articleVersion[0].Summary)));
            }
            return info;
        }
    }
    
    private ArticleNameValueMap createNameValueMap(String name, String value) {
        ArticleNameValueMap myMap = new ArticleNameValueMap();
        myMap.Name = name;
        myMap.Value = value;
        return myMap;
    }
    
    static testMethod void testMenuItemManagement() {
        Menu__c testMenu = new Menu__c();
        testMenu.Label__c = 'test';
        database.insert(testMenu);
        
        Menu_Item__c testItem = new Menu_Item__c();
        testItem.Label__c = 'test';
        testItem.Menu__c = testMenu.Id;
        database.insert(testItem);
        
        Menu_Item__c testItem2 = new Menu_Item__c();
        testItem2.Label__c = 'test2';
        testItem2.Parent_Item__c = testItem.Id;
        database.insert(testItem2);
        
        System.currentPageReference().getParameters().put('id', testItem.Id);
        MenuItemManagement md = new MenuItemManagement ();
        md.loadCurrentMenuItem();
        md.getSubMenuItems();
        md.getPath();
        md.getArticleInfo();
        md.createNameValueMap('Test', 'Test');
    }
    
    class ArticleNameValueMap {
        public String Name {get; set;}
        public String Value {get; set;}
    }
}