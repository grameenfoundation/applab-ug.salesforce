global class SaveSurveyForm {

    global class SaveSurveyXML {

        webservice String surveyName;
        webservice String contents;
        webservice Boolean isNew;

        webservice Boolean success;
        webservice String errorMessage;
    }


    webservice static SaveSurveyXML saveSurveyXML(SaveSurveyXML saveSurveyXML) {

        if (saveSurveyXML.surveyName == null || saveSurveyXML.surveyName.equals('')) {
            saveSurveyXML.success = false;
            saveSurveyXML.errorMessage = 'Survey.Name provided is invalid';
            return saveSurveyXML;
        }

        // Load the relevant survey
        Survey__c survey = Utils.loadSurvey(saveSurveyXML.surveyName);
        if (survey == null) {
            saveSurveyXML.success = false;
            saveSurveyXML.errorMessage = 'Survey ' + saveSurveyXML.surveyName + ' does not exist';
            return saveSurveyXML;
        }

        // Check that this survey is to be save to Salesforce.
        if (!survey.Save_To_Salesforce__c) {
            saveSurveyXML.success = true;
            saveSurveyXML.errorMessage = 'Survey ' + saveSurveyXML.surveyName + ' does not need to be saved to Salesforce';
            return saveSurveyXML;
        }

        // Get the fileName for the survey
        String fileName = DocumentHelpers.createSurveyFileName(saveSurveyXML.surveyName);

        // Get the owner Id for this survey
        String ownerId = Utils.getOwnerId(survey.Account__r.Name);

        List<String> results;
        if (saveSurveyXML.isNew || DocumentHelpers.getAttachment(fileName) == null) {
            results = DocumentHelpers.createNewAttachment(saveSurveyXML.contents, (String)survey.Id, fileName, ownerId);
        }
        else {
            results = DocumentHelpers.updateAttachmentContents(saveSurveyXML.contents, fileName);
        }
        if (results.get(0).equals('0')) {
            saveSurveyXML.success = false;
            saveSurveyXML.errorMessage = results.get(1);
        }
        else {
            saveSurveyXML.success = true;
        }
        return saveSurveyXML;
    }

    static testMethod void testSaveXML() {

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        survey.Save_To_Salesforce__c = true;
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        SaveSurveyXML newXML = new SaveSurveyXML();
        newXML.contents = 'Yo whats up';
        newXML.isNew = true;
        newXML.surveyName = survey2.Name;

        // Test save a new attachment
        SaveSurveyXML savedXML = saveSurveyXML(newXML);
        System.assert(savedXML.success);

        // Test updating an attachment
        newXML.isNew = false;
        newXML.contents = 'Yo now whats up';
        SaveSurveyXML updatedXML = saveSurveyXML(newXML);
        System.assert(updatedXML.success);

        SaveSurveyXML fail = new SaveSurveyXML();
        SaveSurveyXML failResult1 = saveSurveyXML(fail);
        System.assertEquals(failResult1.success, false);

        fail.surveyName = 'Not Going To Be In There';
        SaveSurveyXML failResult2 = saveSurveyXML(fail);
        System.assertEquals(failResult2.success, false);
    }
}