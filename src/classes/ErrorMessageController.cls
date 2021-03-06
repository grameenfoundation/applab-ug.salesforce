public class ErrorMessageController {

    /**
     * This controller is for the ErrorMessage component
     */

    /**
     *  Add a list of errors to a page
     */
    public PageReference addError() {

        String[] messages = Apexpages.currentPage().getParameters().get('errorParam').split('_splitter_');
        for (String message : messages) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
        }
        return null;
    }

    /**
     *  Clear the errors from the page
     */
    public PageReference clearErrors() {

        ApexPages.getMessages().clear();
        return null;
    }

    static testMethod void testController() {

        PageReference pageRef = Page.UDoM_Dashboard;
        pageRef.getParameters().put('errorParam', 'ROCK_splitter_LOBSTER');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ErrorMessageController controller = new ErrorMessageController();
        controller.addError();
        controller.clearErrors();
    }

}