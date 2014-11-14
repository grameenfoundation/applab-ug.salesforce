global class DeleteSurveyController {

    /**
     * Get the latest version of each survey
     *
     *@param searchText - a String to make a survey search by name or part of it
     */
    @RemoteAction
    public static gfsurveys__SurveyVersion__c[] getLatestSurveyVersion(String searchText) {

        if(searchText == NULL){
            searchText = '';
        }
        String queryStr = '%' + searchText + '%';
        gfsurveys__SurveyVersion__c [] surveyVersions = [
            SELECT
                Id,
                gfsurveys__Survey__c,
                gfsurveys__Survey__r.Name,
                gfsurveys__Version__c
            FROM
                gfsurveys__SurveyVersion__c
            WHERE
                gfsurveys__Status__c != 'Draft' 
                AND gfsurveys__Survey__r.Name LIKE :queryStr
                ORDER BY gfsurveys__Survey__r.Name ASC NULLS FIRST
        ];

        return surveyVersions;
    }

    /**
     * Delete a list of surveys
     * In the future when versions are implemented it will be possible to delete just a version but for now delete all of the survey
     *
     * @param itemsToDelete - A Json String that contains the survey id and the version id
     */
    @RemoteAction
    public static void deleteSurveys(String itemsToDelete, Boolean deleteWholeSurvey) {

        // Set flag that allows surveys to be deleted
        gfsurveys.SurveyTriggerLogic.setOverrideDeleteChecks(true);

        List<Id> idsToDelete = splitIds((List<SurveyWrapper>)JSON.deserialize(itemsToDelete, List<SurveyWrapper>.class), new List<Id>(), deleteWholeSurvey);
        if (deleteWholeSurvey) {
            deleteSurveys(idsToDelete);
        }
    }

    /**
     * Get the ids for the records being deleted. This could be surveys or versions depending on input
     *
     * @param surveys           - A list of the surveyIds being deleted
     * @param idsToDelete       - The list that contains the ids to be deleted
     * @param deleteWholeSurvey - Boolean indicating if the survey or the versions are being deleted
     *
     * @return - The list of ids to be deleted
     */
    private static List<Id> splitIds(List<SurveyWrapper> surveys, List<Id> idsToDelete, Boolean deleteWholeSurvey) {

        for (SurveyWrapper survey : surveys) {
            if(deleteWholeSurvey) {
                idsToDelete.add(survey.getSurveyId());
            }
            else {
                idsToDelete.add(survey.getVersionId());
            }
        }
        return idsToDelete;
    }

    /**
     * Delete a list of surveys. As we do not really allow versions at the moment just delete the whole survey
     *
     * @param idsToDelete       - The list that contains the ids to be deleted
     */
    private static void deleteSurveys(List<Id> idsToDelete) {

        // Pull all the surveys from the DB
        gfsurveys__Survey__c[] surveys = [
            SELECT
                Id,
                gfsurveys__Status__c,
                gfsurveys__PublishedDate__c
            FROM
                gfsurveys__Survey__c
            WHERE
                Id IN :idsToDelete
        ];


        // Update them so they are not published and the published date is blanked
        // This allows them to be deleted without failing the validation rules
        for (gfsurveys__Survey__c survey : surveys) {
            survey.gfsurveys__Status__c = 'Draft';
            survey.gfsurveys__PublishedDate__c = null;
        }
        update(surveys);

        // Delete the surveys
        delete(surveys);
    }

    /**
     * JSON wrapper class for a survey that contains both the survey id and the survey version id
     */
    public class SurveyWrapper {

        Id surveyId;
        Id versionId;

        public SurveyWrapper(Id surveyId, Id versionId) {
            this.surveyId = surveyId;
            this.versionId = versionId;
        }

        public Id getSurveyId() {
            return this.surveyId;
        }

        public Id getVersionId() {
            return this.versionId;
        }
    }
}