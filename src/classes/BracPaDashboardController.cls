/**
 *  Controller to load the settings for the UDoM dashboard
 */

public with sharing class BracPaDashboardController extends DynamicDashboardBaseController {

    public BracPaDashboardController() {
        setDashboardName('BRAC PA Dashboard');
        setSections(loadSections());
    }
}