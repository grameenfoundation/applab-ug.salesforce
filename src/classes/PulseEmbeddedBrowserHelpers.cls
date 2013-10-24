// Crude way of passing data back and forth between browser control and android app
// TODO: retry other ways when got more time to find better way
public class PulseEmbeddedBrowserHelpers {
    /**
     * This string is checked to see that the page loaded successfully. If it isn't found, a nice error will be displayed to the user
     * Prevents browser error codes, etc 
     */
    public static String getPageLoadCompleteString() {
        return '<!--[PAGE_LOAD_COMPLETE]!-->';
    }
    
    /**
     * This string is checked to see if the operation completed, if found, the android app can elect to close the browser control and go to the next activity 
     */
    public static String getOperationCompleteString() {
        return '<!--[OPERATION_COMPLETE]!-->';
    }
    
    /**
     * This string is a place holder for the farmer id
     */
    public static String getFarmerIdString() {
        return '<!--[FARMER_ID]!-->';
    }
    
    static testMethod void testHelpers() {
    	getPageLoadCompleteString();
    	getOperationCompleteString();
    	getFarmerIdString();
    }
}