// The purpose of this trigger is to prevent a Survey's status from being changed under certain conditions.
// If a Survey's status is Published, this trigger only allows the status to be changed to Completed.
// If a Survey's status is Completed, this trigger only allows the status to be changed to Published.
trigger OnSurveyStatusEdit on Survey__c (before update) {

    Survey__c survey = trigger.old[0];
    Survey__c updatedSurvey = trigger.new[0];
    if (survey.Survey_Status__c == 'Published' && updatedSurvey.Survey_Status__c != 'Published'
        && updatedSurvey.Survey_Status__c != 'Completed') {
            trigger.new[0].addError('This survey is already published and can only be changed to Completed!'+
                 ' It can be cloned in Salesforce, and a new copy made using the original Survey XML');
    }
    else {
        if (survey.Survey_Status__c == 'Completed' && updatedSurvey.Survey_Status__c != 'Completed' 
            && updatedSurvey.Survey_Status__c != 'Published') {
                trigger.new[0].addError('This survey is already Completed and can only be changed to Published!'+
                    ' It can be cloned in Salesforce, and a new copy made using the original Survey XML');
        }
    }
}