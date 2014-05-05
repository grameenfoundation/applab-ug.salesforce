global class ProcessSurveySubmission {

    global class SurveySubmission {

        webservice String json;
        webservice String xml;
        webservice String imei;
        webservice String farmerId;
        webservice String surveyId;
        webservice String handsetSubmitTime;
        webservice String submissionStartTime;
        webservice String surveySize;
        webservice String resultHash;
        webservice String interviewLatitude;
        webservice String interviewLongitude;
        webservice String interviewAltitude;
        webservice String interviewAccuracy;
        webservice String interviewGPSTimestamp;
        webservice String submissionLatitude;
        webservice String submissionLongitude;
        webservice String submissionAltitude;
        webservice String submissionAccuracy;
        webservice String submissionGPSTimestamp;

        webservice String errorMessage;
        webservice Boolean success;

        Transient Map<String, Id> parentIdMap;
    }

    webservice static SurveySubmission processSurveySubmission(SurveySubmission surveySubmission) {

        surveySubmission.success = true;
        
        // TODO: Delete this after testing the system
        System.debug('XML' + surveySubmission.xml);

        // Load the survey
        Survey__c survey = Utils.loadSurvey(surveySubmission.surveyId);
        if (survey == null) {
            surveySubmission.success = false;
            surveySubmission.errorMessage = 'Survey with id ' + surveySubmission.surveyId + ' does not exist on our system';
            return surveySubmission;
        }

        // Load the person who conducted the survey
        Person__c interviewer = Utils.loadPersonImei(surveySubmission.imei);
        if (interviewer == null) {
            surveySubmission.success = false;
            surveySubmission.errorMessage = 'CKW with the imei: ' + surveySubmission.imei + ' does not exist on our system';
            return surveySubmission;
        }

        // Load the farmer who is being interviewed if we are planning on storing this data
        String intervieweeId = null;
        Person__c interviewee = null;
        if (!survey.Allow_No_Interviewee__c) {
            Farmer__c[] farmers = Utils.loadFarmerFromId(surveySubmission.farmerId);
            if (farmers.size() > 1) {
                surveySubmission.success = false;
                surveySubmission.errorMessage = 'More than one farmer with id ' + surveySubmission.farmerId + ' exists on our system. There are actually ' + farmers.size();
                return surveySubmission;
            }
            else if (farmers.size() == 0) {
                interviewee = Utils.loadTestPerson();
                intervieweeId = (String)interviewee.Id;
            }
            else {
                interviewee = farmers[0].Person__r;
                intervieweeId = (String)farmers[0].Person__c;
            }
        }

        // See if the survey needs to be processed before saving. If this fails we block further
        // saving.
        if (survey.Post_Processing_Method__c != null && !survey.Post_Processing_Method__c.equalsIgnoreCase('None')) {

            // Carry out the additional processing that is required
            List<String> results = additionalProcessing(surveySubmission, survey, interviewer, intervieweeId);

            // Parse the results
            String messageSubject;
            String messageBody;
            if (results.get(0).equals('0')) {
                messageSubject = survey.Survey_Name__c + ' failed to submit';
                surveySubmission.success = false;
            }
            else if (results.get(0).equals('2')) {
                messageSubject = survey.Survey_Name__c + ' failed to submit';
                surveySubmission.success = true;
            }
            else {
                messageSubject = survey.Survey_Name__c + ' submitted successfully';
                surveySubmission.success = true;
            }
            System.debug(results);
            // Send Pulse and SMS feedback to the submitter
            if (!results.get(2).equals('SUPRESSMSG')) {
                messageBody = results.get(2);
                User sender = [
                    SELECT
                        Id,
                        Name
                    FROM
                        User
                    WHERE
                        Name = 'ckw admin'
                ];
                SendSmsHelpers.sendThroughGateways(
                    SendSmsHelpers.generateMessage(
                        new List<Id>{ interviewer.Id }, messageSubject, messageBody, sender.Id, sender.Name, true, false, DateTime.now(), datetime.newInstance(date.today().addDays(10), time.newInstance(23, 59, 59, 0))
                    ), true
                );
            }

            // Return the completed submission
            surveySubmission.errorMessage = results.get(1);

            // If we are not saving the submission or the submission failed return to the client
            if (!survey.Save_To_Salesforce__c || results.get(0).equals('0')) {
                return surveySubmission;
            }
        }

        // Create and save the submission meta data object
        Submission_Meta_Data__c submissionMetaData = new Submission_Meta_Data__c();
        submissionMetaData.Interviewee__c = intervieweeId;
        submissionMetaData.Interviewer__c = interviewer.Id;
        submissionMetaData.Survey__c = survey.Id;
        submissionMetaData.Handset_Submit_Time__c = getTimestamp(surveySubmission.handsetSubmitTime);

        submissionMetaData.Interview_Latitude__c = Decimal.valueOf(surveySubmission.interviewLatitude);
        submissionMetaData.Interview_Longitude__c = Decimal.valueOf(surveySubmission.interviewLongitude);
        submissionMetaData.Interview_Altitude__c = Decimal.valueOf(surveySubmission.interviewAltitude);
        submissionMetaData.Interview_Accuracy__c = Decimal.valueOf(surveySubmission.interviewAccuracy);
        submissionMetaData.Interview_GPS_Timestamp__c = getTimestamp(surveySubmission.interviewGPSTimestamp);

        submissionMetaData.Submission_Latitude__c = Decimal.valueOf(surveySubmission.submissionLatitude);
        submissionMetaData.Submission_Longitude__c = Decimal.valueOf(surveySubmission.submissionLongitude);
        submissionMetaData.Submission_Altitude__c = Decimal.valueOf(surveySubmission.submissionAltitude);
        submissionMetaData.Submission_Accuracy__c = Decimal.valueOf(surveySubmission.submissionAccuracy);
        submissionMetaData.Submission_GPS_Timestamp__c = getTimestamp(surveySubmission.submissionGPSTimestamp);

        submissionMetaData.Submission_Size__c = Decimal.valueOf(surveySubmission.surveySize);
        submissionMetaData.Result_Hash__c = surveySubmission.resultHash;
        if (survey.Survey_Status__c.equals('Draft')) {
            submissionMetaData.Is_Draft__c = true;
        } else {
            submissionMetaData.Is_Draft__c = false;
        }

        // Check if we want to save a link to the current poverty scorecard for the interviewee
        if (survey.Include_Poverty_Scorecard__c) {
            Poverty_Scorecard__c povertyScorecard = Utils.loadCurrentPovertyScorecard(intervieweeId);
            if (povertyScorecard != null) {
                submissionMetaData.Poverty_Scorecard__c = povertyScorecard.Id;
            }
            else {

                // The farmer is yet to be registered. Either reg is still on the phone or it doesn't count.
                // Record the farmer id that was used so we can attempt to clean this up at a later date
                submissionMetaData.Unregistered_Farmer_Id__c = surveySubmission.farmerId;
            }
        }

        Database.SaveResult submissionMetaDataResult = Database.insert(submissionMetaData, false);
        if (!submissionMetaDataResult.isSuccess()) {
            System.debug(LoggingLevel.INFO, submissionMetaDataResult.getErrors()[0].getMessage());
            if (submissionMetaDataResult.getErrors()[0].getMessage().contains('Result_Hash__c duplicates')) {
                surveySubmission.success = true;
                surveySubmission.errorMessage = 'Duplicate submission so allow to save: ' + submissionMetaDataResult.getErrors()[0].getMessage();
            }
            else {
                surveySubmission.success = false;
                surveySubmission.errorMessage = 'Failed to save submissionMetaData object: ' + submissionMetaDataResult.getErrors()[0].getMessage();
            }
            return surveySubmission;
        }

        // Parse the json string into the submission answer objects
        List<List<Submission_Answer__c>> submissionAnswersLists;
        if (surveySubmission.json.equals('none')) {
            submissionAnswersLists = parseXmlString(surveySubmission, submissionMetaDataResult.getId());
        }
        else {
            submissionAnswersLists = parseJsonString(surveySubmission, submissionMetaDataResult.getId());
        }
        surveySubmission.parentIdMap = new Map<String, Id>();

        // Batch the answers into groups of 200 to save them to the DB
        Integer answersAdded = 0;
        Integer currentAnswerNumber = 0;
        List<Submission_Answer__c> submissionBatchAnswers = new List<Submission_Answer__c>();
        String errorMsg = 'Failed to save repeating objects ';

        // Check to see if there are any child answers.
        Boolean hasChildren = false;
        if (submissionAnswersLists.get(1).size() > 0) {
            hasChildren = true;
        }
        // First save all the answers that do not have parents.
        for (Submission_Answer__c submissionAnswer : submissionAnswersLists.get(0)) {
            if (!surveySubmission.success) {
                break;
            }
            submissionBatchAnswers.add(submissionAnswer);
            if (submissionBatchAnswers.size() == 200) {
                surveySubmission = saveBatch(submissionBatchAnswers, surveySubmission, hasChildren);
                answersAdded = answersAdded + submissionBatchAnswers.size();
                submissionBatchAnswers.clear();
            }
        }

        // Add the last batch of top level answers
        if (submissionBatchAnswers.size() > 0) {
            surveySubmission = saveBatch(submissionBatchAnswers, surveySubmission, hasChildren);
            answersAdded = answersAdded + submissionBatchAnswers.size();
            submissionBatchAnswers.clear();
        }

        // Loop through the answers that have parents and add the parent answer Id to them.
        List<Submission_Answer__c> answerLoopList = submissionAnswersLists.get(1).clone();
        List<Submission_Answer__c> answerList = new List<Submission_Answer__c>();
        Integer size = submissionAnswersLists.get(1).size();
        while(size > 0) {
            Integer current = 0;
            for (Submission_Answer__c submissionAnswer : answerLoopList) {
                if (!surveySubmission.success) {
                   break;
                }
                if (surveySubmission.parentIdMap.containsKey(submissionAnswer.Parent_Binding__c + submissionAnswer.Parent_Instance__c)) {
                    submissionAnswer.Parent_Answer__c = surveySubmission.parentIdMap.get(submissionAnswer.Parent_Binding__c + submissionAnswer.Parent_Instance__c);
                    submissionBatchAnswers.add(submissionAnswer);
                }
                else {
                    answerList.add(submissionAnswer);
                }
                if (submissionBatchAnswers.size() == 200) {
                    surveySubmission = saveBatch(submissionBatchAnswers, surveySubmission, hasChildren);
                    answersAdded = answersAdded + submissionBatchAnswers.size();
                    submissionBatchAnswers.clear();
                }
                current++;
            }

            // Save final batch
            surveySubmission = saveBatch(submissionBatchAnswers, surveySubmission, hasChildren);
            answersAdded = answersAdded + submissionBatchAnswers.size();
            submissionBatchAnswers.clear();
            answerLoopList = answerList.clone();
            size = answerList.size();
            answerList.clear();
        }

        // Saving the questions has failed so kick back the error message
        if (!surveySubmission.success) {
            System.debug(LoggingLevel.INFO, errorMsg);
            database.delete(submissionMetaData);
            surveySubmission.errorMessage = errorMsg;
            return surveySubmission;
        }

        System.debug(LoggingLevel.INFO, 'Answers added = ' + answersAdded);

        // If the submitter is a CKW the update their performance record
        CKW__c ckw = Utils.loadCkwFromPersonSalesforceId((String)interviewer.id);
        if (ckw != null) {
            PerformanceReviewHelpers.updatePerformanceRecord(ckw, getTimestamp(surveySubmission.interviewGPSTimestamp).date().toStartOfMonth(), 'Surveys_Not_Reviewed__c', 1.0, false);
        }

        // Survey is fully saved so return a success message.
        surveySubmission.success = true;
        surveySubmission.errorMessage = 'Submission for IMEI: ' + surveySubmission.imei + ' of survey: ' + surveySubmission.surveyId + ' saved to salesforce';
        return surveySubmission;
    }

    /**
     *  Take a batch of submission answers and save them to the Salesforce DB.
     *
     *  @param submissionBatchAnswers - List of answers that need saving.
     *  @param surveySubmission       - The submission webservice object that is being processed
     *  @param hasChildren            - Are there any child answers for this submission
     *
     *  @return - The submission webservice object that is being processed
     */
    private static SurveySubmission saveBatch(List<Submission_Answer__c> submissionBatchAnswers, SurveySubmission surveySubmission, Boolean hasChildren) {

        Integer currentAnswerNumber = 0;
        Database.SaveResult[] answerSaveRepeatResults = database.insert(submissionBatchAnswers);
        for (Database.SaveResult answerSaveRepeatResult : answerSaveRepeatResults) {

            // Check to see if the answer was saved correctly
            if (!answerSaveRepeatResult.isSuccess()) {
                surveySubmission.success = false;
                for (Database.Error error : answerSaveRepeatResult.getErrors()) {

                    // Build up the error message
                    surveySubmission.errorMessage = surveySubmission.errorMessage + error.getMessage();
                }
            }
            else {
 
                // Add answer to the parent map so child answers can be linked back to parent to allow for drilldown
                // through the linked answers
                if (hasChildren) {
                    Submission_Answer__c addedAnswer = submissionBatchAnswers.get(currentAnswerNumber);
                    surveySubmission.parentIdMap.put(addedAnswer.Binding__c + addedAnswer.Instance__c, answerSaveRepeatResult.getId());
                }
            }
            currentAnswerNumber++;
        }
        return surveySubmission;
    }

    /**
     *  Parse an XML string the represents the submission into Submission_Answer__c obects
     *
     *  @param surveySubmission     - The webservice object that is being processed
     *  @param submissionMetaDataId - The id of the submission meta data for these answer objects
     *
     *  @return - A tuple list of lists of the following format
     *                element 1 - The answers that do not have parents
     *                element 2 - The answers that do have parents
     *           The answers are split like this so the links can be made between them to allow for drilldown.
     *           Need to know the SF ids of the parents before saving the child
     */
    private static List<List<Submission_Answer__c>> parseXmlString(SurveySubmission surveySubmission, Id submissionMetaDataId) {

        System.debug(LoggingLevel.INFO, surveySubmission.xml);

        List<List<Submission_Answer__c>> returnValues = new List<List<Submission_Answer__c>>();
        List<Submission_Answer__c> submissionAnswersWithParent = new List<Submission_Answer__c>();
        List<Submission_Answer__c> submissionAnswersWithoutParent = new List<Submission_Answer__c>();

        Dom.Document doc = new Dom.Document();
        doc.load(surveySubmission.xml);

        Dom.Xmlnode rootNode = doc.getRootElement();
        for (Dom.Xmlnode answerNode : rootNode.getChildElements()) {
            if (answerNode.getNodeType() == DOM.XMLNodeType.ELEMENT && answerNode.getName().equals('answer')) {

                // Create the submission answer object.
                Submission_Answer__c submissionAnswer = new Submission_Answer__c();
                submissionAnswer.Submission_Meta_Data__c = submissionMetaDataId;

                for (Dom.Xmlnode answerDetailNode : answerNode.getChildElements()) {
                    if (answerNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                        String detailName = answerDetailNode.getName();
                        if (detailName.equals('binding')) {
                            submissionAnswer.Binding__c = answerDetailNode.getText().trim();
                        }
                        else if (detailName.equals('answerText')) {
                            String answerText = answerDetailNode.getText().trim();
                            submissionAnswer.Answer__c = answerText;

                            // If the answer is short enough put in to the following field. This is so we can do type conversion in SF
                            // as you cannot use a longtext field in a formula.
                            if (answerText.length() < 255) {
                                submissionAnswer.Answer_Short_Text__c = answerText;
                            }
                            else {
                                submissionAnswer.Answer_Short_Text__c = null;
                            }
                        }
                        else if (detailName.equals('instance')) {
                             submissionAnswer.Instance__c = Integer.valueOf(answerDetailNode.getText().trim());
                        }
                        else if (detailName.equals('questionNumber')) {
                             submissionAnswer.Question_Number__c = Integer.valueOf(answerDetailNode.getText().trim());
                        }
                        else if (detailName.equals('questionType')) {
                             submissionAnswer.Type__c = answerDetailNode.getText().trim();
                        }
                        else if (detailName.equals('parentBinding')) {
                             submissionAnswer.Parent_Binding__c = answerDetailNode.getText().trim();
                        }
                        else if (detailName.equals('parentInstance')) {
                             submissionAnswer.Parent_Instance__c = Integer.valueOf(answerDetailNode.getText().trim());
                        }
                    }
                }
                if (submissionAnswer.Parent_Binding__c == null || submissionAnswer.Parent_Binding__c.equals('null')) {
                    submissionAnswersWithoutParent.add(submissionAnswer);
                }
                else {
                    submissionAnswersWithParent.add(submissionAnswer);
                }
            }

        }

        returnValues.add(submissionAnswersWithoutParent);
        returnValues.add(submissionAnswersWithParent);
        return returnValues;
    }

    /**
     *  Parse an JSON string the represents the submission into Submission_Answer__c obects
     *
     *  @param surveySubmission     - The webservice object that is being processed
     *  @param submissionMetaDataId - The id of the submission meta data for these answer objects
     *
     *  @return - A tuple list of lists of the following format
     *                element 1 - The answers that do not have parents
     *                element 2 - The answers that do have parents
     *           The answers are split like this so the links can be made between them to allow for drilldown.
     *           Need to know the SF ids of the parents before saving the child
     */
    public static List<List<Submission_Answer__c>> parseJsonString(SurveySubmission surveySubmission, Id submissionMetaDataId) {

        System.debug(LoggingLevel.INFO, surveySubmission.json);
        JSONObject jsonObject = new JSONObject(surveySubmission.json);
        Integer numberOfAnswers = jsonObject.getValue('answers').values.size();
        List<List<Submission_Answer__c>> returnValues = new List<List<Submission_Answer__c>>();
        List<Submission_Answer__c> submissionAnswersWithParent = new List<Submission_Answer__c>();
        List<Submission_Answer__c> submissionAnswersWithoutParent = new List<Submission_Answer__c>();
        for (Integer i = 0; i < numberOfAnswers; i++) {
            String answerText = jsonObject.getValue('answers').values[i].obj.getValue('answer').str != NULL ? jsonObject.getValue('answers').values[i].obj.getValue('answer').str : 'Unavaliable';

            // Create the submission answer object.
            Submission_Answer__c submissionAnswer = new Submission_Answer__c();
            submissionAnswer.Submission_Meta_Data__c = submissionMetaDataId;
            submissionAnswer.Answer__c = answerText;

            // If the answer is short enough put in to the following field. This is so we can do type conversion in SF
            // as you cannot use a longtext field in a formula.
            if (answerText.length() < 255) {
                submissionAnswer.Answer_Short_Text__c = answerText;
            }
            else {
                submissionAnswer.Answer_Short_Text__c = null;
            }
            submissionAnswer.Binding__c = jsonObject.getValue('answers').values[i].obj.getValue('binding').str;
            submissionAnswer.Type__c = jsonObject.getValue('answers').values[i].obj.getValue('type').str;
            submissionAnswer.Parent_Binding__c = jsonObject.getValue('answers').values[i].obj.getValue('parentBinding').str;
            submissionAnswer.Instance__c = Integer.valueOf(jsonObject.getValue('answers').values[i].obj.getValue('instance').str);
            submissionAnswer.Question_Number__c = Integer.valueOf(jsonObject.getValue('answers').values[i].obj.getValue('questionNumber').str);
            submissionAnswer.Question_Text__c = jsonObject.getValue('answers').values[i].obj.getValue('questionText').str;
            submissionAnswer.Parent_Instance__c = Integer.valueOf(jsonObject.getValue('answers').values[i].obj.getValue('parentInstance').str);
            if (submissionAnswer.Parent_Binding__c.equals('null')) {
                submissionAnswersWithoutParent.add(submissionAnswer);
            }
            else {
                submissionAnswersWithParent.add(submissionAnswer);
            }
        }
        returnValues.add(submissionAnswersWithoutParent);
        returnValues.add(submissionAnswersWithParent);
        return returnValues;
    }

    /**
     *  Parse an submission string into a map of Submission_Answer__c with the binding as the key.
     *
     *  @param surveySubmission - The webservice object that is being processed
     *
     *  @return - The answer map
     */
    public static Map<String, Submission_Answer__c> parseSubmissionToMap(SurveySubmission surveySubmission) {

        Map<String, Submission_Answer__c> answerMap = new Map<String, Submission_Answer__c>();

        List<List<Submission_Answer__c>> parsedAnswers;

        if (surveySubmission.json.equals('none')) {
            parsedAnswers = parseXmlString(surveySubmission, null);
        }
        else {
            parsedAnswers = parseJsonString(surveySubmission, null);
        }


        // Flatten the lists into the Map
        for (Submission_Answer__c answer : parsedAnswers.get(0)) {
            answerMap.put(answer.Binding__c + '_' + answer.Instance__c, answer);
        }
        for (Submission_Answer__c answer : parsedAnswers.get(1)) {
            answerMap.put(answer.Binding__c + '_' + answer.Instance__c, answer);
        }
        return answerMap;
    }

    /**
     *  Perform any additional processing that is required for this survey.
     *
     *  @param surveySubmission - The webservice object that is being processed
     *  @param survey           - The Survey__c object that this submission is for
     *  @param interviewer      - The Person__c object for the interviewer who conducted this survey
     *  @param intervieweeId    - The Id for the interviewee. Can be null if no interviewee required
     *
     *  @return - A tuple list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success, 2 = treat as success but failed)
     *              element 2 - Error message if required
     *              element 3 - Error message to be sent to the submitter
     */
    private static List<String> additionalProcessing(
            SurveySubmission surveySubmission,
            Survey__c survey,
            Person__c interviewer,
            Id intervieweeId
    ) {

        List<String> returnValues = new List<String>();

        Map<String, Submission_Answer__c> answers = parseSubmissionToMap(surveySubmission);

        // Find the name of the method that this survey hooks into to do its post processing
        try {
            if (survey.Post_Processing_Method__c.equalsIgnoreCase('None')) {
                returnValues.add('0');
                returnValues.add('There is no post processing method specified for this survey');
                returnValues.add('SUPRESSMSG');
            }
            else if (survey.Post_Processing_Method__c.equals('CKW_Registration')) {
                return CkwRegistration.processCkwRegistration(answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('CKW_Baseline')) {
                return CkwRegistration.processCkwBaseline(answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('CKW_Staff_Update')) {
                return CkwRegistration.processCkwUpdate(answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('Subcounty_Registration')) {
                return CkwRegistration.processSubcounties(answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('TDR_AGENT_VISIT')) {
                return TdrHelpers.processAgentVisitSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('UDOM_RAIN_GUAGE')) {
                return UDoMSurveyProcessing.processDailyRainGauge(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('UDOM_RAIN_GUAGE_REG')) {
                return UDoMSurveyProcessing.registerRainGauge(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('MTN_CHANNELS')) {
                return MtnChannelsHelpers.processChannelsFFPSSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('FHI_GROUP_REGISTRATION')) {
                return FHISurveysHelpers.processGroupRegistration(surveySubmission, answers, interviewer, survey.Survey_Name__c);
            }
            else if (survey.Post_Processing_Method__c.equals('FHI_HOUSEHOLD_REGISTRATION')) {
                return FHISurveysHelpers.processHouseholdRegistration(surveySubmission, answers, interviewer, survey.Survey_Name__c);
            }
            else if (survey.Post_Processing_Method__c.equals('FIELD_OFFICER_SUPPORT')) {
                return FieldOfficeHelpers.processFoSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('DATA_VALIDATOR_SPOT_CHECK')) {
               return DataValidatorHelpers.processSpotCheck(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('DATA_VALIDATOR_BACK_CHECK')) {
                return DataValidatorHelpers.processBackCheck(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('EQUIPMENT_TRACKING')) {
                return EquipmentTrackingHelpers.processFieldOfficerSubmission(surveySubmission, answers, interviewer);
            }
            if (survey.Post_Processing_Method__c.equals('BVAT_CIW_INFORMATION')) {
                return BvatHelpers.processCiwInformationSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('BVAT_FARMER_REGISTRATION')) {
                return BvatHelpers.processFarmerRegistrationSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('BVAT_CONTENT_SURVEY')) {
                return BvatHelpers.processContentSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('EW_FARMER_REG')) {
                return ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('EW_HARVEST_REG')) {
                return ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(surveySubmission, answers, interviewer);
            }
			else if (survey.Post_Processing_Method__c.equals('EW_SALE_REG')) {
                return ProcessEwarehouseSurveys.processSaleRegistration(answers);
            }
			else if (survey.Post_Processing_Method__c.equals('EADD_FARMER_EXTRA_INFO')) {
                return ProcessEADDSurveys.processEADDFarmerRegistration(surveySubmission, answers, interviewer);
            }
			else if (survey.Post_Processing_Method__c.equals('EADD_HUB')) {
                return ProcessEADDSurveys.processEADDHubRegistration(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('PA_HEALTH_PROGRAMME')) {
                return BracSurveysHelpers.processHealthProgrammeSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('OPPORTUNITY_CLIENT_PROFILE')) {
                return OpportunityProfileSurveyHelpers.processClientProfileSurvey(answers, intervieweeId);
            }
            else if (survey.Post_Processing_Method__c.equals('NAADS_ADVISORY')) {
                return ProcessNaadsSurveys.processAdvisoryServiceSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('TDR_PA_PRODUCTS')) {
                return TdrHelpers.processTdrPaProductsSurvey(surveySubmission, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('MTN_WEEKLY_REPORT')) {
                return TdrHelpers.processWeeklyReportVisit(surveySubmission, answers, interviewer);
            }
        else if (survey.Post_Processing_Method__c.equals('NAADS_BASELINE')) {
                return ProcessNaadsSurveys.processNaadsBaselineSurvey(surveySubmission, answers, interviewer);
            }
            else if (survey.Post_Processing_Method__c.equals('IG_CBT_VISITS')) {
                return ProcessNUSAFSurveys.registerNusafActivityVisit(surveySubmission, answers, interviewer);
            }
            else if(survey.Post_Processing_Method__c.equals('GUMUTINDO_GCCE_FARM_ENTRANCE'))
            {
                return GumutindoHelpers.processGCCEFarmEntranceSurvey(surveySubmission, answers, interviewer);
            }
             else if(survey.Post_Processing_Method__c.equals('GUMUTINDO_GROUP_SURVEY'))
            {
                return GumutindoHelpers.processGumutindoGroupSurvey(surveySubmission, answers, interviewer);
            }
             else if(survey.Post_Processing_Method__c.equals('GCCE_FARMER_GROUP_ASSESSMENT'))
            {
                return GumutindoHelpers.processGroupFarmerMemberAssessmentSurvey(surveySubmission, answers, interviewer);
            }
        }
        catch (Exception e) {
            returnValues.add('0');
            returnValues.add(e.getMessage());
            returnValues.add('An error occured. Please contact support');
        }
        return returnValues;
    }

    public static DateTime getTimestamp(String timeString) {

        Long timeStamp = null;
        if (timeString != null && !timeString.equals('')) {
            timeStamp = Long.valueOf(timeString);
        }
        if (timeStamp == null || timeStamp == 0) {
            return null;
        }
        else {
            return datetime.newInstance(timeStamp);
        }
    }

    /**
     *  Test submission
     */
    static testMethod void testSubmission() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Create povery scorecards
        Poverty_Scorecard__c  povertyScorecard1 = Utils.createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);

        Survey__c survey = new Survey__c();
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        SurveySubmission surveySubmission = new SurveySubmission();
        surveySubmission.imei = ckw.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'OD99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');

        surveySubmission.json = '{ "answers" : [ {"answer":"35","binding":"age","type":"Input","parentBinding":"null","parentInstance":"0","instance":"0","questionNumber":"2","questionText":"Age"}, {"answer":"owen","binding":"name","type":"Input","parentBinding":"null","parentInstance":"0","instance":"0","questionNumber":"1","questionText":"Name"}, {"answer":"2","binding":"gender","type":"Select1","parentBinding":"null","parentInstance":"0","instance":"0","questionNumber":"3","questionText":"Gender"}, {"answer":"0","binding":"kids_age","type":"Input","parentBinding":"kids_details","parentInstance":"0","instance":"0","questionNumber":"6","questionText":"Age"}, {"answer":"Sammy","binding":"kids_name","type":"Input","parentBinding":"kids_details","parentInstance":"0","instance":"0","questionNumber":"5","questionText":"Name"}, {"answer":"null","binding":"kids_details","type":"Repeat","parentBinding":"null","parentInstance":"0","instance":"0","questionNumber":"4","questionText":"Kids Details"}, {"answer":"null","binding":"kids_details","type":"Repeat","parentBinding":"null","parentInstance":"0","instance":"1","questionNumber":"4","questionText":"Kids Details"}, {"answer":"9","binding":"kids_age","type":"Input","parentBinding":"kids_details","parentInstance":"1","instance":"1","questionNumber":"6","questionText":"Age"}, {"answer":"Bobby","binding":"kids_name","type":"Input","parentBinding":"kids_details","parentInstance":"1","instance":"1","questionNumber":"5","questionText":"Name"} ] }';
        SurveySubmission resultSurveySubmission = processSurveySubmission(surveySubmission);
        System.assert(resultSurveySubmission.success);
    }

    static testMethod void testXmlSubmission() {

        // Create a CKW
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Create povery scorecards
        Poverty_Scorecard__c  povertyScorecard1 = Utils.createTestPovertyScorecard('POOR', farmer1.Person__c, false, '');
        database.insert(povertyScorecard1);

        Survey__c survey = new Survey__c();
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        SurveySubmission surveySubmission = new SurveySubmission();
        surveySubmission.imei = ckw.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'OD99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');

        surveySubmission.xml = '<?xml version="1.0"?><answers><answer><binding>subcounty</binding><answerText>Benet</answerText><instance>0</instance><questionNumber>8</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>partner</binding><answerText>WFP NAADS</answerText><instance>0</instance><questionNumber>11</questionNumber><questionType>Select</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>fathers_name</binding><answerText>Bobby</answerText><instance>0</instance><questionNumber>4</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>first_name</binding><answerText>Simon</answerText><instance>0</instance><questionNumber>1</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>village</binding><answerText>There</answerText><instance>0</instance><questionNumber>10</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>district</binding><answerText>Gulu</answerText><instance>0</instance><questionNumber>7</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>gender</binding><answerText>1</answerText><instance>0</instance><questionNumber>5</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>parish</binding><answerText>Here</answerText><instance>0</instance><questionNumber>9</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>last_name</binding><answerText>Cook</answerText><instance>0</instance><questionNumber>3</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>middle_name</binding><answerText>Boris</answerText><instance>0</instance><questionNumber>2</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>dob</binding><answerText>null</answerText><instance>0</instance><questionNumber>6</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer></answers>';
        surveySubmission.json = 'none';
        SurveySubmission resultSurveySubmission = processSurveySubmission(surveySubmission);
        System.assert(resultSurveySubmission.success);
    }

    static testMethod void testAgentVisitSubmission() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);
        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        Survey__c survey = new Survey__c();
        survey.Post_Processing_Method__c = 'TDR_AGENT_VISIT';
        survey.Save_To_Salesforce__c = false;
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        SurveySubmission surveySubmission = new SurveySubmission();
        surveySubmission.imei = person.Handset__r.IMEI__c;
        surveySubmission.farmerId = '';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        surveySubmission.submissionStartTime = Datetime.now().addMinutes(20).getTime().format().replace(',', '');

        surveySubmission.xml = '<?xml version="1.0"?>'       +
            '<answers>'                                      +
                '<answer>'                                   +
                    '<binding>activity</binding>'            +
                    '<answerText>4</answerText>'             +
                    '<instance>0</instance>'                 +
                    '<questionNumber>8</questionNumber>'     +
                    '<questionType>Input</questionType>'     +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
                '<answer>'                                   +
                    '<binding>activity_conducted</binding>'  +
                    '<answerText>Rang Peeps</answerText>'    +
                    '<instance>0</instance>'                 +
                    '<questionNumber>11</questionNumber>'    +
                    '<questionType>Select</questionType>'    +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
                '<answer>'                                   +
                    '<binding>general_comments</binding>'    +
                    '<answerText>Bobby</answerText>'         +
                    '<instance>0</instance>'                 +
                    '<questionNumber>4</questionNumber>'     +
                    '<questionType>Input</questionType>'     +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
                '<answer>'                                   +
                    '<binding>school_name</binding>'         +
                    '<answerText>Lower</answerText>'         +
                    '<instance>0</instance>'                 +
                    '<questionNumber>1</questionNumber>'     +
                    '<questionType>Input</questionType>'     +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
                '<answer>'                                   +
                    '<binding>school_contact_name</binding>' +
                    '<answerText>Simon</answerText>'         +
                    '<instance>0</instance>'                 +
                    '<questionNumber>10</questionNumber>'    +
                    '<questionType>Input</questionType>'     +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
                '<answer>'                                   +
                    '<binding>gps</binding>'                 +
                    '<answerText>0.5 32.0</answerText>'      +
                    '<instance>0</instance>'                 +
                    '<questionNumber>7</questionNumber>'     +
                    '<questionType>Select1</questionType>'   +
                    '<parentBinding>null</parentBinding>'    +
                    '<parentInstance>0</parentInstance>'     +
                '</answer>'                                  +
            '</answers>';
        surveySubmission.json = 'none';
        SurveySubmission resultSurveySubmission = processSurveySubmission(surveySubmission);
    }

}