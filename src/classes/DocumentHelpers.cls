public class DocumentHelpers {

    /**
     *  A static class to deal with document and attachment manipulation
     */

    /**
     *  Create an attachment to a record
     *
     *  @param contents - The body of the document as a string
     *  @param parentId - The id of the record that this is attached to
     *  @param fileName - The name of the file that is being attachecd
     *  @param ownerId  - The id of the record that this is attached to
     *
     *  @return - A list with the following format
     *          - Element 1 - 1|0 indicating success
     *          - Element 2 - Id|Error Message - depending on success
     */
    public static List<String> createNewAttachment(
            String contents,
            String parentId,
            String fileName,
            String ownerId
    ) {

        List<String> returnList = new List<String>();

        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(encodeContents(contents));
        attachment.ContentType = '.xml';
        if (ownerId == null) {
            attachment.OwnerId = UserInfo.getUserId();
        }
        else {
            attachment.OwnerId = ownerId;
        }
        attachment.IsPrivate = true;
        attachment.ParentId = parentId;
        attachment.Name = fileName;

        // Save the attachment to the database
        try {
            insert attachment;
        }
        catch (DMLException e) {

            returnList.add('0');
            returnList.add('Failed to save the attachment to the database');
            return returnList;
        }
        returnList.add('1');
        returnList.add((String)attachment.Id);
        return returnList;
    }

    /**
     *  Get an attachment from its fileName
     *
     *  @param fileName - The name of the file that is being attachecd
     *
     *  @return - The attachment or null if it does not exist
     */
    public static Attachment getAttachment(String fileName) {

        Attachment[] attachment =
            [SELECT
                Id,
                Name,
                Body,
                BodyLength,
                ContentType,
                ParentId,
                OwnerId,
                IsPrivate
            FROM
                Attachment
            WHERE
                Name = :fileName];

        if (attachment.size() == 0) {
            return null;
        }
        return attachment[0];
    }

    /**
     *  update an attachment to a record
     *
     *  @param contents - The body of the document as a string
     *  @param fileName - The name of the file that is being attachecd
     *
     *  @return - A list with the following format
     *          - Element 1 - 1|0 indicating success
     *          - Element 2 - Id|Error Message - depending on success
     */
    public static List<String> updateAttachmentContents(String contents, String fileName) {

        List<String> returnList = new List<String>();
        Attachment attachment = getAttachment(fileName);
        if (attachment == null) {
            returnList.add('0');
            returnList.add('Attachment ' + fileName + ' does not exist');
        }
        else {
            attachment.Body = Blob.valueOf(encodeContents(contents));
            try {
                update attachment;
            }
            catch (DMLException e) {

                returnList.add('0');
                returnList.add('Failed to update the attachment ' + fileName + ' to the database');
                return returnList;
            }
            returnList.add('1');
            returnList.add((String)attachment.Id);
        }
        return returnList;
    }

    public static String getContent(Attachment attachment) {
        return decodeContents(attachment.Body.toString());
    }

    public static String createSurveyFileName(String surveyName) {
        return surveyName + '_form_xml';
    }

    public static String escapeAnswerText(String text) {

        if (text == null) {
            return '';
        }
        return '"' + text.replace('"', '""') + '"';
    }

    private static String encodeContents(String contents) {

        return EncodingUtil.base64Encode(Blob.valueOf(contents));
    }

    private static String decodeContents(String contents) {

        return EncodingUtil.base64Decode(contents).toString();
    }

    static testMethod void testAttachments() {

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);
        Survey__c survey2 = [SELECT Name FROM Survey__c WHERE Id = :survey.Id];

        String content = 'Hello my name is Earl, how are you doing?';
        String attachmentName = createSurveyFileName(survey2.Name);
        List<String> createResults = createNewAttachment(content, (String)survey.Id, attachmentName, null);
        System.assert(createResults.get(0).equals('1'));

        Attachment attachment = getAttachment(attachmentName);
        System.assertEquals(decodeContents(attachment.Body.toString()), content);

        // Update the content
        String newContent = 'Hello my name is now Simon, how are you doing?';
        List<String> updateResults = updateAttachmentContents(newContent, attachmentName);
        System.assert(updateResults.get(0).equals('1'));
        Attachment changedAttachment = getAttachment(attachmentName);
        System.assertEquals(decodeContents(changedAttachment.Body.toString()), newContent);

        // Update a attachment that does not exist
        List<String> failedUpdateResults = updateAttachmentContents(newContent, 'Yo');
        System.assert(failedUpdateResults.get(0).equals('0'));
    }
}