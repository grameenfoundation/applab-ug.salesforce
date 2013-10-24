@isTest
private class TestBVATContentDetails {

    static testMethod void testCreateContentDetails() {
        BVATContentDetails bvat = new BVATContentDetails();
        List<BVATContentDetails.ContentDetails> contentDetails = bvat.createContentDetails();
        System.assert(contentDetails != null);
    }
    
    static testMethod void testGetLoadDateoptions() {
        BVATContentDetails bvat = new BVATContentDetails();
        List<SelectOption> options = bvat.getLoadDateoptions();
        System.assert(options != null);
    }
    

    static testMethod void testLoadNameFromCIW() {
        Person__c person = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
        database.insert(person);
        CIW__c ciw = new CIW__c();
        ciw.Person__c = person.Id;
        ciw.Joining_Year__c = 2013;
        database.insert(ciw);
        BVATContentDetails bvat = new BVATContentDetails();
        String ciw2 = bvat.loadNameFromCIW(ciw.Id);
        System.assert(ciw2 != null);
    }
    
    static testMethod void testGetDisplayDate() {
        BVATContentDetails bvat = new BVATContentDetails();
        System.assert(bvat.getDisplayDate() != null); 
    }
    
    static testMethod void testContentDetailsConstructor() {
        BVATContentDetails bvat = new BVATContentDetails();
        BVATContentDetails.ContentDetails vv = new BVATContentDetails.ContentDetails();
        System.assert(vv != null);
        System.assert(vv.getCIWName()== '');
        System.assert(vv.getOtherInfoNeeds()=='');
        System.assert(vv.getCreatedDate() == date.today());
    }
    
    static testMethod void testGetContentDetails() {
        BVATContentDetails bvat = new BVATContentDetails();
        List<BVATContentDetails.ContentDetails> contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Jan2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Feb2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Mar2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Apr2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Jun2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Jul2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Aug2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Sep2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Oct2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Nov2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'Dec2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
        bvat.selectedDate = 'May2013';
        contentDetails = bvat.getContentDetails();
        System.assert(contentDetails != null);
    }
}