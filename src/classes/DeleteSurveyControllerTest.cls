@isTest
public class DeleteSurveyControllerTest {

    // Objects needed for testing
    static Surveyor mobileUser;
    static List<SurveyWrapper> surveyWrappers;

    /**
     * Create the objects needed to run the tests.
     * This includes:
     *    - Two gfsurveys__Surveys
     *    - Two gfsurveys__SurveyVersions for each survey
     *    - Two gfsurveys__Question for each gfsurveys__SurveyVersion
     *    - A submission for each gfsurveys__SurveyVersion
     *    - gfsurveys__Answer for each gfsurveys__Submission
     */
    private static void prepareTest() {

        surveyWrappers = new List<SurveyWrapper>();

        // Create a MobileUser to submit the gfsurvey__Submission
        Contact c = new Contact( LastName = 'LastNameDSC' );
        insert c;
        gfsurveys__Mobile_User__c mUser = new gfsurveys__Mobile_User__c(
            gfsurveys__Contact__c = c.Id,
            gfsurveys__Username__c = 'UsernameDSC',
            gfsurveys__Password__c = 'PasswordDSC'
        );
        insert mUser;
        mobileUser = new Surveyor(mUser, c);

        // Create the first gfsurvey__Survey
        gfsurveys__Survey__c survey1 = new gfsurveys__Survey__c(
            Name = 'TestSurveyDSC1'
        );
        insert survey1;

        SurveyWrapper wrapper1 = new SurveyWrapper(survey1);

        // Get the version that was created automatically and close it
        gfsurveys__SurveyVersion__c v1 = [
            SELECT
                gfsurveys__Status__c
            FROM
                gfsurveys__SurveyVersion__c
            WHERE
                gfsurveys__Survey__c = :survey1.Id
        ];

        // Add a couple of questions to the survey
        gfsurveys__Question__c s1 = addQuestion(
            survey1.Id,
            null,
            'Section',
            'S1',
            1,
            true
        );
        gfsurveys__Question__c q1 = addQuestion(
            survey1.Id,
            s1.Id,
            'Text',
            'T1',
            1,
            false
        );
        gfsurveys__Question__c q2 = addQuestion(
            survey1.Id,
            s1.Id,
            'Text',
            'T2',
            2,
            false
        );
        insert new List<gfsurveys__Question__c>{q1, q2};

        v1.gfsurveys__Status__c = 'Published';
        update v1;
        wrapper1.addVersion(v1);

        // Create 2nd gfsurveys__SurveyVersion and publish it
        gfsurveys__SurveyVersion__c v2 = new gfsurveys__SurveyVersion__c(
                gfsurveys__Survey__c = survey1.Id,
                gfsurveys__Status__c = 'Draft',
                gfsurveys__Version__c = 2
        );
        insert v2;
        wrapper1.addVersion(v2);

        // Add a couple of submissions
        gfsurveys__Submission__c sub1 = createSubmission(
            mobileUser.getContact(), survey1, v1, true
        );

        // Add the answers to the submission
        insert new List<gfsurveys__Answer__c>{
            createAnswer(sub1, q1, 'A1', false),
            createAnswer(sub1, q2, 'A2', false)
        };
        wrapper1.addSubmission(sub1);

        gfsurveys__Submission__c sub2 = createSubmission(
            mobileUser.getContact(), survey1, v1, true
        );

        // Add the answers to the submission
        insert new List<gfsurveys__Answer__c>{
            createAnswer(sub2, q1, 'A1', false),
            createAnswer(sub2, q2, 'A2', false)
        };
        wrapper1.addSubmission(sub2);
        surveyWrappers.add(wrapper1);

        // Create the second gfsurvey__Survey
        gfsurveys__Survey__c survey2 = new gfsurveys__Survey__c(
            Name = 'TestSurveyDSC2',
            gfsurveys__Status__c = 'Draft',
            gfsurveys__Version__c = 1
        );
        insert survey2;

        SurveyWrapper wrapper2 = new SurveyWrapper(survey2);

        // Add a couple of questions to the survey
        gfsurveys__Question__c s2 = addQuestion(
            survey2.Id,
            null,
            'Section',
            'S2',
            1,
            true
        );
        gfsurveys__Question__c q3 = addQuestion(
            survey2.Id,
            s2.Id,
            'Text',
            'T3',
            1,
            false
        );
        gfsurveys__Question__c q4 = addQuestion(
            survey2.Id,
            s2.Id,
            'Text',
            'T4',
            2,
            false
        );
        insert new List<gfsurveys__Question__c>{q3, q4};

        // Get the version that was created automatically and close it
        gfsurveys__SurveyVersion__c v3 = [
            SELECT
                gfsurveys__Status__c
            FROM
                gfsurveys__SurveyVersion__c
            WHERE
                gfsurveys__Survey__c = :survey2.Id
        ];
        v3.gfsurveys__Status__c = 'Closed';
        update v3;
        wrapper2.addVersion(v3);

        // Create 2nd gfsurveys__SurveyVersion and publish it
        gfsurveys__SurveyVersion__c v4 = new gfsurveys__SurveyVersion__c(
                gfsurveys__Survey__c = survey2.Id,
                gfsurveys__Status__c = 'Draft',
                gfsurveys__Version__c = 2
        );
        insert v4;

        // Publish the survey
        v4.gfsurveys__Status__c = 'Published';
        update v4;
        wrapper2.addVersion(v4);

        // Add a couple of submissions
        gfsurveys__Submission__c sub3 = createSubmission(
            mobileUser.getContact(), survey2, v4, true
        );

        // Add the answers to the submission
        insert new List<gfsurveys__Answer__c>{
            createAnswer(sub3, q3, 'A3', false),
            createAnswer(sub3, q4, 'A4', false)
        };
        wrapper1.addSubmission(sub1);
        gfsurveys__Submission__c sub4 = createSubmission(
            mobileUser.getContact(), survey2, v4, true
        );

        // Add the answers to the submission
        insert new List<gfsurveys__Answer__c>{
            createAnswer(sub4, q3, 'A3', false),
            createAnswer(sub4, q4, 'A4', false)
        };
        wrapper1.addSubmission(sub4);
        surveyWrappers.add(wrapper2);
    }

    /**
     * Create a question for a survey
     *
     * @param surveyId       - Survey that the question belongs to
     * @param parentId       - The id of the parent question
     * @param questionType   - Type of question
     * @param questionName   - Name and caption for the survey
     * @param position       - Postion of the question in the survey
     * @param insertQuestion - Boolean indicating if the question should be
     *                           inserted before being returned
     * @return - The question
     */
    static gfsurveys__Question__c addQuestion(
            Id surveyId,
            Id parentId,
            String questionType,
            String questionName,
            Integer position,
            Boolean insertQuestion
    ) {

        gfsurveys__Question__c question = new gfsurveys__Question__c(
            gfsurveys__Survey__c = surveyId,
            gfsurveys__Parent__c = parentId,
            gfsurveys__Type__c = questionType,
            gfsurveys__Caption__c = questionName,
            Name = questionName,
            gfsurveys__Position__c = position
        );
        if (insertQuestion) {
            insert question;
        }
        return question;
    }

    /**
     * Create a submission
     *
     * @param contact          - The contact who conducted the submission
     * @param survey           - The survey the submission is for
     * @param version          - The version of the survey the submission is for
     * @param insertSubmission - Boolean to indicate if the submission should
                                  be inserted before return
     *
     * @return - The submission
     */
    static gfsurveys__Submission__c createSubmission(
            Contact contact,
            gfsurveys__Survey__c survey,
            gfsurveys__SurveyVersion__c version,
            Boolean insertSubmission
    ) {

        gfsurveys__Submission__c submission = new gfsurveys__Submission__c(
            gfsurveys__Surveyor__c = contact.Id,
            gfsurveys__Survey__c = survey.Id,
            gfsurveys__SurveyVersion__c = version.Id
        );
        if (insertSubmission) {
            insert submission;
        }
        return submission;
    }

    /**
     * Create an answer
     *
     * @param submission - The submission the Answer belongs to
     * @param question   - The question the Answer is for
     * @param value      - Value for the Answer
     * @param insertAnswer - Boolean to indicate if the answer should
                               be inserted before return
     *
     * @return - The Answer
     */
    static gfsurveys__Answer__c createAnswer(
            gfsurveys__Submission__c submission,
            gfsurveys__Question__c question,
            String value,
            Boolean insertAnswer
    ) {

        gfsurveys__Answer__c answer = new gfsurveys__Answer__c(
            gfsurveys__Submission__c = submission.Id,
            gfsurveys__Question__c = question.Id,
            gfsurveys__TextValue__c = value
        );
        if (insertAnswer) {
            insert answer;
        }
        return answer;
    }

    /**
     * Create a JSON string of all the SurveyWrappers for the survey versions found
     *
     * @param versions - The survey versions
     *
     * @return - The JSON String
     */
    static String createWrapperJSON(List<gfsurveys__SurveyVersion__c> versions) {

        // Create the wrappers
        List<DeleteSurveyController.SurveyWrapper> wrappers =
            new List<DeleteSurveyController.SurveyWrapper>();
        for (gfsurveys__SurveyVersion__c version : versions) {
             wrappers.add(
                new DeleteSurveyController.SurveyWrapper(
                    version.gfsurveys__Survey__c,
                    version.Id
                )
            );
        }
        return JSON.serialize(wrappers);
    }

    /**
     * Test the RemoteAction that gets a list of surveys that are not in draft status
     */
    static testMethod void testGetSurveys() {

        prepareTest();
        List<gfsurveys__SurveyVersion__c> versions =
            DeleteSurveyController.getLatestSurveyVersion();
        System.assertEquals(2, versions.size());

        // Check that the correct versions have been fetched
        for (gfsurveys__SurveyVersion__c version : versions) {
            System.assert(
                (
                    version.gfsurveys__Survey__r.Name.equals(
                        surveyWrappers.get(0).getSurvey().Name
                    ) &&
                    version.gfsurveys__Version__c == 1
                ) ||
                (
                    version.gfsurveys__Survey__r.Name.equals(
                        surveyWrappers.get(1).getSurvey().Name
                    ) &&
                    version.gfsurveys__Version__c == 2
                )
            );
        }
    }

    /**
     * Test deleting the two created submissions. This should behave with a scorched earth
     * policy and remove everything attached to the surveys due to the m-d relationships
     */
    static testMethod void testDeleteSurvey() {

        prepareTest();
        DeleteSurveyController.deleteSurveys(createWrapperJSON(DeleteSurveyController.getLatestSurveyVersion()), true);

        // Check that everything has been deleted
        System.assertEquals(0, database.countquery('SELECT COUNT() FROM gfsurveys__Survey__c'));
        System.assertEquals(0, database.countquery('SELECT COUNT() FROM gfsurveys__SurveyVersion__c'));
        System.assertEquals(0, database.countquery('SELECT COUNT() FROM gfsurveys__Question__c'));
        System.assertEquals(0, database.countquery('SELECT COUNT() FROM gfsurveys__Submission__c'));
        System.assertEquals(0, database.countquery('SELECT COUNT() FROM gfsurveys__Answer__c'));
    }

    /**
     * Test deleting just a survey version
     * This should only remove the two version objects and nothing else
     * NOT IMPLEMENTED YET AS NO VERSIONING. THIS IS THE TEST THAT WILL HAVE TO PASS WHEN IT IS
     *
    static testMethod void testDeleteVersion() {

        prepareTest();
        DeleteSurveyController.deleteSurveys(createWrapperJSON(DeleteSurveyController.getLatestSurveyVersion()), false);
        System.assertEquals(2, database.countquery('SELECT COUNT() FROM gfsurveys__Survey__c'));
        System.assertEquals(2, database.countquery('SELECT COUNT() FROM gfsurveys__SurveyVersion__c'));
        System.assertEquals(6, database.countquery('SELECT COUNT() FROM gfsurveys__Question__c'));
        System.assertEquals(4, database.countquery('SELECT COUNT() FROM gfsurveys__Submission__c'));
        System.assertEquals(8, database.countquery('SELECT COUNT() FROM gfsurveys__Answer__c'));
    }
    */

    /**
     * Wrapper class for a survey that includes the versions and the submissions
     * for it.
     */
    private class SurveyWrapper {

        private gfsurveys__Survey__c survey;
        private List<gfsurveys__SurveyVersion__c> versions;
        private List<gfsurveys__Submission__c> submissions;

        public SurveyWrapper(gfsurveys__Survey__c survey) {
            this.survey = survey;
            this.versions = new List<gfsurveys__SurveyVersion__c>();
            this.submissions = new List<gfsurveys__Submission__c>();
        }

        /**
         * Getter for the survey
         */
        public gfsurveys__Survey__c getSurvey() {
            return this.survey;
        }

        /**
         * Add a survey version to the wrapper
         *
         * @param version - The version being added
         */
        public void addVersion(gfsurveys__SurveyVersion__c version) {
            this.versions.add(version);
        }

        /**
         * Get a specific survey version
         *
         * @param index - The index that the SurveyVersion is on the list
         *
         * @return - The survey version or null if the index is out of bounds
         */
        public gfsurveys__SurveyVersion__c getVersion(Integer index) {

            // Check the index is not out of bounds
            if (index > this.versions.size() - 1) {
                return null;
            }

            return this.versions[index];
        }

        /**
         * Add a submission to the wrapper
         *
         * @param submission - The submission being added to the wrapper
         */
        public void addSubmission(gfsurveys__Submission__c submission) {
            this.submissions.add(submission);
        }

        /**
         * Get a specific submission
         *
         * @param index - The index that the submission is in the submissions list
         *
         * @return - The submission or null if the index is out of bounds
         */
        public gfsurveys__Submission__c getSubmission(Integer index) {

            // Check the index is not out of bounds
            if (index > this.submissions.size() - 1) {
                return null;
            }

            return this.submissions[index];
        }
    }

    /**
     * Wrapper class for a surveyor 
     */
    private class Surveyor {
        private gfsurveys__Mobile_User__c mUser;
        private Contact contact;

        public Surveyor(gfsurveys__Mobile_User__c mUser, Contact contact) {
            this.mUser = mUser;
            this.contact = contact;
        }

        /**
         * Get the contact for the Surveyor
         */
        public Contact getContact() {
            return this.contact;
        }
    }
}