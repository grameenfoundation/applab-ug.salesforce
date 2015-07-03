/* 
 * 
 * Contains tests for importBackendKeywordsNew class 
 * 
 */
@isTest
private class ImportBackendKeywordsNewTest {

    static testmethod void testAll() {
        Menu__c menu = new Menu__c();
        menu.Label__c = 'CKW 3.0 Search';
        database.insert(menu);

        System.assert(null != ImportBackendKeywordsNew.getMenuByLabel('CKW 3.0 Search'));

        Menu_Item__c menuItem1 = new Menu_Item__c();
        menuItem1.Menu__c = menu.Id;
        menuItem1.Label__c = 'First One1';
        menuItem1.Content__c = 'Content';
        database.insert(menuItem1);

        ImportBackendKeywordsNew.MenuItemAdapter adapter1 = new ImportBackendKeywordsNew.MenuItemAdapter();
        adapter1.PreviousItemPath = '';
        adapter1.Label = 'First One1';
        adapter1.Content = 'New stuff';
        adapter1.Attribution = ' billy new';
        adapter1.IsActive = true;
        adapter1.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter1.MenuPath = 'First_One1';

        ImportBackendKeywordsNew.MenuItemAdapter adapter2 = new ImportBackendKeywordsNew.MenuItemAdapter();
        adapter1.PreviousItemPath = 'First_One1';
        adapter2.Label = 'Second1';
        adapter2.Content = 'New stuff';
        adapter2.Attribution = ' billy new';
        adapter2.IsActive = false;
        adapter2.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter2.MenuPath = 'First_One1 Second1';

        ImportBackendKeywordsNew.MenuItemAdapter adapter3 = new ImportBackendKeywordsNew.MenuItemAdapter();
        adapter1.PreviousItemPath = 'First_One1 Second1';
        adapter3.Label = 'Third';
        adapter3.Content = 'New stuffs';
        adapter3.Attribution = ' billy new';
        adapter3.IsActive = true;
        adapter3.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter3.MenuPath = 'First_One1 Second1 Third';

        // set up doubly-linked list
        adapter1.PreviousItemPath = '';
        adapter2.PreviousItemPath = adapter1.MenuPath;
        adapter3.PreviousItemPath = adapter2.MenuPath;

        List<importBackendKeywordsNew.MenuItemAdapter> adapters = new List<importBackendKeywordsNew.MenuItemAdapter>();
        adapters.add(adapter1);
        adapters.add(adapter2);
        adapters.add(adapter3);

        boolean done = ImportBackendKeywordsNew.importBackendKeywords(adapters, 'CKW 3.0 Search');
        boolean failed = ImportBackendKeywordsNew.importBackendKeywords(null, 'CKW 3.0 Search');
        System.assert(!failed);
        System.assert(done);
    }
}