/**
 * The controller for the naads dashboard
 */
public with sharing class NaadsDashboardController extends DynamicDashboardBaseController {

        public NaadsDashboardController () {
        setDashboardName('NAADS Dashboard');
        setSections(loadSections());
    }
}