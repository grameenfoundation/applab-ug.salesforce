public with sharing class UpdatedReviewFigures {

    public String id;
    public CKW_Performance_Review__c currentReview { get; set; }
    public Integer newFarmersRegistered { get; set; }
    public Integer newValidSearches { get; set; }
    public Integer newTestSearches { get; set; }
    public Integer newInvalidSearches { get; set; }
    public String typeOfReview { get; set; }

    public UpdatedReviewFigures (String id, CKW_Performance_Review__c currentReview) {
        this.id = id;
        this.currentReview = currentReview;
        this.newFarmersRegistered = 0;
        this.newValidSearches = 0;
        this.newTestSearches = 0;
        this.newInvalidSearches = 0;
        this.typeOfReview = 'Not Set';
    }

    public void addType(String newType) {
        this.typeOfReview = newType;
    }

    static testMethod void testConstruction() {
        UpdatedReviewFigures review = new UpdatedReviewFigures('ME', null);
        System.assert(review.id.equals('ME'));
        System.assert(review.newFarmersRegistered == 0);
        System.assert(review.typeOfReview.equals('Not Set'));
        review.addType('New');
        System.assert(review.typeOfReview.equals('New'));
    }
}