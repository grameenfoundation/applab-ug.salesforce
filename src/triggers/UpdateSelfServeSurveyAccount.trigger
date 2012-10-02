trigger UpdateSelfServeSurveyAccount on Survey__c (before insert, before update) {
    Survey__c survey = trigger.new[0];
    if (survey.Owner.Profile.Name == 'Self Serve' || survey.Owner.Profile.Name == 'CKW Self Serve User') {
        User user = [SELECT Id, AccountId FROM User WHERE Id =: survey.OwnerId];
        if (user.AccountId != null && user.AccountId != '') {
            survey.Account__c = user.AccountId;
        }
    }
}