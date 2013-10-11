public with sharing class BVATContentDetails {

    public List<ContentDetails> getContentDetails() {
        endDate = getEndDate(selectedDate);
        startDate = endDate.toStartOfMonth();
        List<ContentDetails> contentDetails = createContentDetails();
        return contentDetails;
    }
    
    public PageReference getDisplayDate() {
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }
    
       private Date getEndDate(String dateString) {
    
        if (dateString == null) {
            return date.today();
        }
        String month = dateString.substring(0,3);
        String year = dateString.substring(4);
        String endDate = '30';
        String mth = '1';
        String yr = '2013';
        
        if (month.equals('Jan')) {
            mth = '1';
            endDate = '31';
        }
        else if (month.equals('Feb')) {
            mth = '2';
            if (Date.isLeapYear((Integer.valueOf(year)))) {
                endDate = '29';
            }
            else {
                endDate = '28';
            }
        }
        else if (month.equals('Mar')) {
            mth = '3';
            endDate = '31';
        }
        else if (month.equals('Apr')) {
            mth = '4';
            endDate = '30';
        }
        else if (month.equals('May')) {
            mth = '5';
            endDate = '31';
        }
        else if (month.equals('Jun')) {
            mth = '6';
            endDate = '30';
        }
        else if (month.equals('Jul')) {
            mth = '7';
            endDate = '31';
        }
        else if (month.equals('Aug')) {
            mth = '8';
            endDate = '31';
        }
        else if (month.equals('Sep')) {
            mth = '9';
            endDate = '30';
        }
        else if (month.equals('Oct')) {
            mth = '10';
            endDate = '31';
        }
        else if (month.equals('Nov')) {
            mth = '11';
            endDate = '30';
        }
        else if (month.equals('Dec')) {
            mth = '12';
            endDate = '31';
        }
        return date.parse(mth + '/' + endDate + '/'+yr);
    } 

    public String displayDate { get; set; }


    public String selectedDate { get; set; }
    private Date endDate = date.today();
    private Date startDate = date.today();
    
    public List<SelectOption> getLoadDateoptions() {
        Date collectionStartDate = date.parse('10/01/2012');
        List<SelectOption> options = new List<SelectOption>();
        Date startDate = MetricHelpers.getRollOverStartDate(collectionStartDate, 'Monthly');
        Date endDate = MetricHelpers.getRollOverEndDate(Date.today(), 'Monthly');
        while (startDate.daysBetween(endDate) >= 0) {
            String optionString = MetricHelpers.createDispRollOverString(startDate, 'Monthly');
            options.add(new SelectOption(optionString, optionString));
            startDate = MetricHelpers.increaseDateRollOver(startDate, 'Monthly');
        }
        return options;
    }
    
    public List<ContentDetails> createContentDetails() {
        List<ContentDetails> contentDetails = new List<ContentDetails>();
        for (BVAT_Content__c content : [SELECT CIW__c, CreatedDate, Other_Info_Needs__c FROM BVAT_Content__c WHERE CreatedDate <= :endDate AND CreatedDate >= :startDate]) {
            if (content.Other_Info_Needs__c != 'None') {
                ContentDetails contentDetail = new ContentDetails();
                contentDetail.CIWName = loadNameFromCIW(content.CIW__c);
                contentDetail.OtherInfoNeeds = content.Other_Info_Needs__c;
                contentDetail.createdDate = content.CreatedDate;
                contentDetails.add(contentDetail);
            }
        }
        return contentDetails;
    }
    
    public String loadNameFromCIW(String ciwId) {
        CIW__c ciw = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c FROM CIW__c WHERE Id =: ciwId];
        String name = ciw.Person__r.First_Name__c + ' ' + ciw.Person__r.Last_Name__c;
        return name;
    }

    public class ContentDetails {
        String CIWName;
        String OtherInfoNeeds;
        Datetime createdDate;
        
        public ContentDetails () {
            createdDate = date.today();
            CIWName = '';
            OtherInfoNeeds = '';
        }
        
        public String getCIWName() {
            return CIWName;
        }
        
        public Datetime getCreatedDate() {
            return createdDate;
        }
        
        public String getOtherInfoNeeds() {
            return OtherInfoNeeds;
        }
    }  
}