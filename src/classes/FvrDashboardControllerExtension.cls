public class FvrDashboardControllerExtension {

    private DashboardController dashboardController;

    public List<Client_Event__c> radioShows;
    public List<Client_Event__c> getRadioShows() {

        DateTime quarterFirstDay = DateTime.newInstance(MetricHelpers.getQuarterFirstDay(this.dashboardController.quarter), Time.newInstance(00, 00, 00, 00));
        DateTime quarterLastDay = DateTime.newInstance(MetricHelpers.getQuarterLastDay(this.dashboardController.quarter), Time.newInstance(23, 59, 59, 59));
        if ((this.dashboardController.district == null
                || this.dashboardController.district.equals(''))
                && this.dashboardController.getIsCurrentQuarter().equals('true')
        ) {
                quarterLastDay = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 59));
        }
        List<Client_Event__c> shows = Database.query(generateRadioShowQuery());
        if (shows.size() < 1) {
            return null;
        }
        return shows;
    }
    public void setRadioShows(List<Client_Event__c> shows) {
        this.radioShows = shows;
    }

    public FvrDashboardControllerExtension(DashboardController dashboardController) {

        this.dashboardController = dashboardController;
    }

    private String generateRadioShowQuery() {


        String endString;
        String districtString = '';
        if (this.dashboardController.district != null && !this.dashboardController.district.equals('')) {
            districtString = 'AND Client_Location__r.District__r.Name = \'' + this.dashboardController.district + '\'';
            endString = 'AND End_Time__c <= :quarterLastDay ';
        }
        else {
            endString = 'AND Start_Time__c <= :quarterLastDay ';
        }

        String query =
            'SELECT '                                     +
                'Display_Name__c, '                       +
                'Description__c , '                       +
                'Type__c, '                               +
                'Start_Time__c, '                         +
                'End_Time__c, '                           +
                'Client_Location__r.Name, '               +
                'Client_Location__r.Display_Name__c '     +
            'FROM '                                       +
                'Client_Event__c '                        +
            'WHERE '                                      +
                'Type__c = \'Farmer Voice Radio\' '       +
                districtString                            +
                ' AND Start_Time__c >= :quarterFirstDay ' +
                endString                                 +
            'ORDER BY '                                   +
                'Start_Time__c, '                         +
                'Client_Location__r.District__r.Name';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    public static testMethod void testController() {
        FvrDashboardControllerExtension controller = new FvrDashboardControllerExtension(new DashboardController());
        controller.setRadioShows(controller.getRadioShows());
    }
}