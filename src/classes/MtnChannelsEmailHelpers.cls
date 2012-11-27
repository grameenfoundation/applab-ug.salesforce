public with sharing class MtnChannelsEmailHelpers {

    private static Map<String, Map<String, MtnChannelsEmailHelpers.DailyStaffStats>> regionStats;
    private static Map<String, List<String>> regionStaffOrder;

    /**
     * Generate the daily emails
     *
     * @param emailAdresses - A map of lists of email address. The key to the map is the region displayName
     * @param staffNames    - A list of the ids for the staff members to fetch data about
     * @param startDate     - The date that the email is to be generated for.
     */
    public static void generateDailyEmails(Map<String, List<String>> emailAddresses, List<String> staffName, Date startDate) {

        Boolean sendAll = false;
        List<String> regionsToIncludeInAll = new List<String>();
        if (getDailyEmailData(staffName, startDate)) {

            // Create the email for each region specified
            for (String key : emailAddresses.keySet()) {
                if (key.equals('all')) {
                    sendAll = true;
                    continue;
                }
                regionsToIncludeInAll.add(key);

                String html = getRegionHtml(key);

                String subject = getSubject(key, startDate, false, false);
                Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get(key), subject, html);
                EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
            }
        }

        if (sendAll) {
            String html = '';
            for (String key : regionsToIncludeInAll) {
                html += '<div>' + key + '</div>';
                html += getRegionHtml(key);
            }
            String subject = getSubject('', startDate, true, false);
            Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get('all'), subject, html);
            EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
        }

        // Send out all the personal emails as well
        for (String regionKey : regionStats.keySet()) {
            for (String key : regionStats.get(regionKey).keySet()) {
                sendPersonalEmail(regionStats.get(regionKey).get(key), startDate);
            }
        }
    }

    private static void sendPersonalEmail(MtnChannelsEmailHelpers.DailyStaffStats asr, Date startDate) {

        // Check that the ASR has an email address set
        if (asr.getEmailAddress() == null) {
            return;
        }
        String html = '<div style="' + getBackgroundColour() + getFullWidth() + '">';
        html += getPerfomanceHeader();
        html += asr.getPerformance();
        html += '</table>';

        // Create the sotck section
        html += getStockHeader();
        html += asr.getStockHtml();
        html += '</table>';

        // Create the competition section
        html += getCompHeader();
        html += asr.getPersonalComp();
        html += '</table>';
        html += '</div>';

        String subject = 'Performance for: ' + startDate;
        List<String> emailAddress = new List<String>();
        emailAddress.add(asr.getEmailAddress());
        Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddress, subject, html);
        EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
    }

    private static String getSubject(String regionName, Date startDate, Boolean isForAll, Boolean isQuarterly) {

        String subject = 'Staff productivity summary for ';
        if (isQuarterly) {
            subject += MetricHelpers.createDispRollOverString(startDate, 'Quarterly') + ' ';
        }
        else {
            subject += startDate + ' ';
        }
        if (isForAll) {
            subject += ' country wide';
        }
        else {
            subject += ' for the ' + regionName + ' region';
        }
        return subject;
    }

    private static String getRegionHtml(String regionName) {

        String html = '<div style="' + getBackgroundColour() + getFullWidth() + '">';

        // Create the performance section
        html += getPerfomanceHeader();
        html += getPerformanceTotal(regionName);
        html += getPerfomanceStaff(regionName);
        html += '</table>';

        // Create the sotck section
        html += getStockHeader();
        html += getStockTotal(regionName);
        html += getStockStaff(regionName);
        html += '</table>';

        // Create the competition section
        html += getCompHeader();
        html += getComp(regionName);
        html += '</table>';
        html += '</div>';
        return html;
    }

    private static String getPerfomanceHeader() {
        return
            '<div style="' + getTitleStyle() + '">' +
                'Performance' +
            '</div>' +
            '<table style="' + getTableStyle() + '" cellpadding="3">' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '"></td>' +
                    '<td style="' + getTdOtherWidth() + '">Outlets Visited</td>' +
                    '<td style="' + getTdOtherWidth() + '">Target</td>' +
                    '<td style="' + getTdOtherWidth() + '">% of target reached</td>' +
                    '<td style="' + getTdOtherWidth() + '">Total New Outlets Visited</td>' +
                    '<td style="' + getTdOtherWidth() + '">Time Worked</td>' +
                '</tr>';
    }

    private static String getPerformanceTotal(String regionName) {

        Map<String, MtnChannelsEmailHelpers.DailyStaffStats> stats = regionStats.get(regionName);
        Decimal visits = 0.0;
        Decimal targets = 0.0;
        Decimal totalNew = 0.0;
        for (String key : stats.keySet()) {
            MtnChannelsEmailHelpers.DailyStaffStats staff = stats.get(key);
            visits += staff.getOutletsVisited();
            targets += staff.getTarget();
            totalNew += staff.getNewOutletsVisited();
        }
        Decimal percent = 0.0;
        if (targets == 0.0) {
            percent = 100.0;
        }
        else if (visits == 0.0) {
            percent = 0.0;
        }
        else {
            percent = (visits / targets) * 100;
        }
        return
            '<tr align="left" valign="middle">' +
                '<td style="' + getTdNameWidth() + '">Total</td>' +
                '<td style="' + getTdOtherWidth() + '">' + visits + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + targets + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + percent.setScale(1) + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + totalNew + '</td>' +
                '<td style="' + getTdOtherWidth() + '">N/A</td>' +
            '</tr>';
    }

    private static String getPerfomanceStaff(String regionName) {

        Map<String, MtnChannelsEmailHelpers.DailyStaffStats> stats = regionStats.get(regionName);
        String html = '';
        for (String key : stats.keySet()) {
            html += stats.get(key).getPerformance();
        }
        return html;
    }

    private static String getStockHeader() {
        return
            '<div style="' + getTitleStyle() + '">Stock</div>' +
                '<table style="' + getTableStyle() + '" cellpadding="3">' +
                    '<tr align="left" valign="middle" >' +
                        '<td style="' + getTdNameWidth() + '"></td>' +
                        '<td style="' + getTdOtherWidth() + '">Total Available Stock (UGX)</td>' +
                        '<td style="' + getTdOtherWidth() + '">Easy Load total Stock (UGX)</td>' +
                        '<td style="' + getTdOtherWidth() + '">Scratch Card total Stock (UGX)</td>' +
                        '<td style="' + getTdOtherWidth() + '">Sim total Stock (UGX)</td>' +
                        '<td style="' + getTdOtherWidth() + '">% receiving stock from DSD</td>' +
                    '</tr>';
    }

    private static String getStockTotal(String regionName) {

        Map<String, MtnChannelsEmailHelpers.DailyStaffStats> stats = regionStats.get(regionName);
        Decimal totalStock = 0.0;
        Decimal easyLoad = 0.0;
        Decimal scratchCard = 0.0;
        Decimal sim = 0.0;
        Decimal dsd = 0.0;
        Decimal nonDsd = 0.0;
        for (String key : stats.keySet()) {
            MtnChannelsEmailHelpers.DailyStaffStats staff = stats.get(key);
            totalStock += staff.getTotalStock();
            easyLoad += staff.getEasyLoad();
            scratchCard += staff.getScratchCards();
            sim += staff.getSims();
            dsd += staff.getDsd();
            nonDsd += staff.getNonDsd();
        }

        Decimal percent;
        if (dsd + nonDsd == 0) {
            percent = 0;
        }
        else {
            percent = (dsd / (dsd + nonDsd)) * 100;
        }

        return
            '<tr align="left" valign="middle">' +
                '<td style="' + getTdOtherWidth() + '">Total</td>' +
                '<td style="' + getTdOtherWidth() + '">' + totalStock + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + easyLoad + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + scratchCard + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + sim + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + percent.setScale(1) + '</td>' +
            '</tr>';
    }

    private static String getStockStaff(String regionName) {

        Map<String, MtnChannelsEmailHelpers.DailyStaffStats> stats = regionStats.get(regionName);
        String html = '';
        for (String key : stats.keySet()) {
            html += stats.get(key).getStockHtml();
        }
        return html;
    }

    private static String getCompHeader() {
        return
            '<div style="' + getTitleStyle() + '">Competition</div>' +
                '<table style="' + getTableStyle() + '" cellpadding="3">' +
                    '<tr align="left" valign="middle" >' +
                        '<td style="' + getTdNameWidth() + '"></td>' +
                        '<td style="' + getTdOtherWidth() + '">Outlets with airtime</td>' +
                        '<td style="' + getTdOtherWidth() + '">Oulet with merchandise</td>' +
                        '<td style="' + getTdOtherWidth() + '">% of outlets that have competitor</td>' +
                    '</tr>';
    }

    private static String getComp(String regionName) {

        Map<String, MtnChannelsEmailHelpers.DailyStaffStats> stats = regionStats.get(regionName);
        Decimal allAir = 0.0;
        Decimal allMerch = 0.0;
        Decimal airAir = 0.0;
        Decimal airMerch = 0.0;
        Decimal warAir = 0.0;
        Decimal warMerch = 0.0;
        Decimal oraAir = 0.0;
        Decimal oraMerch = 0.0;
        Decimal utlAir = 0.0;
        Decimal utlMerch = 0.0;
        Decimal otherAir = 0.0;
        Decimal otherMerch = 0.0;
        Decimal total = 0.0;
        Decimal totalAir = 0.0;
        Decimal totalMerch = 0.0;

        for (String key : stats.keySet()) {
            MtnChannelsEmailHelpers.DailyStaffStats staff = stats.get(key);
            airAir += staff.getAirtime('Airtel');
            airMerch += staff.getMerchandise('Airtel');
            warAir += staff.getAirtime('Warid');
            warMerch += staff.getMerchandise('Warid');
            oraAir += staff.getAirtime('Orange');
            oraMerch += staff.getMerchandise('Orange');
            utlAir += staff.getAirtime('UTL');
            utlMerch += staff.getMerchandise('UTL');
            otherAir += staff.getAirtime('Other');
            otherMerch += staff.getMerchandise('Other');
            totalAir += staff.getAirtime('Total');
            totalMerch += staff.getMerchandise('Total');
            total += staff.getOutletsVisited();
        }

        Decimal totalComp = 0.0;
        if (totalAir != 0.0) {
            totalComp = (totalAir / total) * 100;
        }
        Decimal airComp = 0.0;
        if (airAir != 0.0) {
            airComp = (airAir / total) * 100;
        }
        Decimal oraComp = 0.0;
        if (oraAir != 0.0) {
            oraComp = (oraAir / total) * 100;
        }
        Decimal warComp = 0.0;
        if (warAir != 0.0) {
            warComp = (warAir / total) * 100;
        }
        Decimal utlComp = 0.0;
        if (utlAir != 0.0) {
            utlComp = (utlAir / total) * 100;
        }
        Decimal otherComp = 0.0;
        if (otherAir != 0.0) {
            otherComp = (otherAir / total) * 100;
        }

        String html = '<tr align="left" valign="middle" >' +
            '<tr>' +
                '<td style="' + getTdNameWidth() + '">Total</td>' +
                '<td style="' + getTdOtherWidth() + '">' + totalAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + totalMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + totalComp.setScale(1) + '</td>' +
            '<tr align="left" valign="middle" >' +
                '<td style="' + getTdNameWidth() + '">Airtel</td>' +
                '<td style="' + getTdOtherWidth() + '">' + airAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + airMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + airComp.setScale(1) + '</td>' +
            '<tr>' +
            '<tr align="left" valign="middle" >' +
                '<td style="' + getTdNameWidth() + '">Orange</td>' +
                '<td style="' + getTdOtherWidth() + '">' + oraAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + oraMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + oraComp.setScale(1) + '</td>' +
            '<tr>' +
            '<tr align="left" valign="middle" >' +
                '<td style="' + getTdNameWidth() + '">Warid</td>' +
                '<td style="' + getTdOtherWidth() + '">' + warAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + warMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + warComp.setScale(1) + '</td>' +
            '<tr>' +
            '<tr align="left" valign="middle" >' +
                '<td style="' + getTdNameWidth() + '">UTL</td>' +
                '<td style="' + getTdOtherWidth() + '">' + utlAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + utlMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + utlComp.setScale(1) + '</td>' +
            '<tr>' +
            '<tr align="left" valign="middle" >' +
                '<td style="' + getTdNameWidth() + '">Other</td>' +
                '<td style="' + getTdOtherWidth() + '">' + otherAir + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + otherMerch + '</td>' +
                '<td style="' + getTdOtherWidth() + '">' + otherComp.setScale(1) + '</td>' +
            '<tr>';
        return html;
    }

    private static Boolean getDailyEmailData(List<String> staffNames, Date startDate) {

        initRegionStats();
        Boolean noRecords = true;
        for (MTN_Channels_Activity__c[] results : Database.query(getDailyEmailQueryString(staffNames, startDate))) {
            noRecords = false;
            for (MTN_Channels_Activity__c result : results) {
                Map<String, MtnChannelsEmailHelpers.DailyStaffStats> regionMap = regionStats.get(result.Person__r.Region__r.Display_Name__c);
                MtnChannelsEmailHelpers.DailyStaffStats staff = regionMap.get(result.Person__c);
                List<String> staffList = regionStaffOrder.get(result.Person__r.Region__r.Display_Name__c);
                if (staff == null) {
                    staff = new MtnChannelsEmailHelpers.DailyStaffStats(
                        result.Person__c,
                        result.Person__r.First_Name__c,
                        result.Person__r.Last_Name__c,
                        result.Person__r.Email_Address__c,
                        result.Person__r.Region__r.Display_Name__c
                    );
                    staffList.add(result.Person__c);
                }
                if (result.Activity_Type__c.equals('New Outlet')) {
                    staff.setNewOutletsVisited(1.0);
                }
                staff.setOutletsVisited(1.0);
                staff.setTotalStock(
                    result.AS_Easy_Load__c +
                    result.AS_Modems__c +
                    result.AS_Phones__c +
                    result.AS_Scratch_Cards__c +
                    result.AS_Sim_Packs__c
                );
                staff.setEasyLoad(result.AS_Easy_Load__c);
                staff.setScratchCards(result.AS_Scratch_Cards__c);
                staff.setSims(result.AS_Sim_Packs__c);
                staff.setDsd(result.Get_Stock_DSD__c);
                staff.setNonDsd(result.Get_Stock_Self__c);
                staff.addAirtime('Airtel', result.Sell_Airtel__c);
                staff.addAirtime('Orange', result.Sell_Orange__c);
                staff.addAirtime('Warid', result.Sell_UTL__c);
                staff.addAirtime('UTL', result.Sell_Warid__c);
                staff.addAirtime('Other', result.Sell_Other__c);
                staff.addMerchandise('Airtel', result.Merch_Airtel__c);
                staff.addMerchandise('Orange', result.Merch_Orange__c);
                staff.addMerchandise('Warid', result.Merch_UTL__c);
                staff.addMerchandise('UTL', result.Merch_Warid__c);
                staff.addMerchandise('Other', result.Merch_Other__c);
                if (result.Sell_Airtel__c == 1 ||
                        result.Sell_Orange__c == 1 ||
                        result.Sell_UTL__c == 1 ||
                        result.Sell_Warid__c == 1 ||
                        result.Sell_Other__c == 1
                ) {
                    staff.addAirtime('Total', 1.0);
                }
                if (result.Merch_Airtel__c == 1 ||
                        result.Merch_Orange__c == 1 ||
                        result.Merch_UTL__c == 1 ||
                        result.Merch_Warid__c == 1 ||
                        result.Merch_Other__c == 1
                ) {
                    staff.addMerchandise('Total', 1.0);
                }

                regionStaffOrder.put(result.Person__r.Region__r.Display_Name__c, staffList);
                regionMap.put(result.Person__c, staff);
                regionStats.put(result.Person__r.Region__r.Display_Name__c, regionMap);
            }
        }

        if (noRecords) {
            return false;
        }

        // Add the targets and the start and end time
        for (MTN_Channels_Daily_Sumary__c[] summaries : Database.query(getDailyTargetQueryString(staffNames, startDate))) {
            for (MTN_Channels_Daily_Sumary__c summary : summaries) {
                Map<String, MtnChannelsEmailHelpers.DailyStaffStats> regionMap = regionStats.get(summary.Person__r.Region__r.Display_Name__c);
                MtnChannelsEmailHelpers.DailyStaffStats staff = regionMap.get(summary.Person__c);
                staff.setTarget(summary.Outlet_Visit_Target__c);
                staff.setStartTime(summary.Work_Start_Time__c);
                staff.setEndTime(summary.Work_End_Time__c);
                regionMap.put(summary.Person__c, staff);
                regionStats.put(summary.Person__r.Region__r.Display_Name__c, regionMap);
            }
        }
        return true;
    }

    /**
     * Initialise the region maps. One for each region
     */
    private static void initRegionStats() {

        regionStats = new Map<String, Map<String, MtnChannelsEmailHelpers.DailyStaffStats>>();
        regionStaffOrder = new Map<String, List<String>>();

        Region__c[] regions =
            [SELECT
                Display_Name__c
            FROM
                Region__c
            WHERE
                Id IN (
                    SELECT
                        Region__c
                    FROM
                        Person__c
                    WHERE
                        Type__c = 'MTN Channel Staff'
                )
        ];
        for (Region__c region : regions) {
            regionStats.put(region.Display_Name__c, new Map<String, MtnChannelsEmailHelpers.DailyStaffStats>());
            regionStaffOrder.put(region.Display_Name__c, new List<String>());
        }
    }

    private static String getDailyEmailQueryString(List<String> staffName, Date startDate) {

        String query =
            'SELECT ' +
                'Person__r.Region__r.Display_Name__c, ' +
                'Activity_Type__c, ' +
                'Person__c, ' +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Email_Address__c, ' +
                'AS_Easy_Load__c, ' +
                'AS_Modems__c, ' +
                'AS_Phones__c, ' +
                'AS_Scratch_Cards__c, ' +
                'AS_Sim_Packs__c, ' +
                'Get_Stock_DSD__c, ' +
                'Get_Stock_Self__c, ' +
                'Sell_Airtel__c, ' +
                'Sell_Orange__c, ' +
                'Sell_UTL__c, ' +
                'Sell_Warid__c, ' +
                'Sell_Other__c, ' +
                'Merch_Airtel__c, ' +
                'Merch_Orange__c, ' +
                'Merch_UTL__c, ' +
                'Merch_Warid__c, ' +
                'Merch_Other__c ' +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
            'WHERE ' + 
                '(Activity_Type__c = \'Existing Outlet\' ' +
                'OR Activity_Type__c = \'New Outlet\') ' +
                ' AND Person__c IN (' + MetricHelpers.generateCommaSeperatedString(staffName, true) + ') ' +
                ' AND ' + SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate), true), false) + 
                ' AND ' + SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(startDate), true), false) + 
            ' ORDER BY ' +
                'Person__r.Region__r.Display_Name__c';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private static String getDailyTargetQueryString(List<String> staffName, Date startDate) {

        String query =
            'SELECT ' +
                'Person__c ,' +
                'Person__r.Region__r.Display_Name__c, ' +
                'Outlet_Visit_Target__c, ' +
                'Work_Start_Time__c, ' +
                'Work_End_Time__c ' +
            'FROM ' +
                'MTN_Channels_Daily_Sumary__c ' +
            'WHERE ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(staffName, true) + ') ' +
                ' AND ' + SoqlHelpers.buildStandardWhereClause('>=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate), true), false) + 
                ' AND ' + SoqlHelpers.buildStandardWhereClause('<=', 'Start_Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(startDate), true), false) + 
            ' ORDER BY ' +
                'Person__r.Name, ' +
                'Start_Date__c';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private class DailyStaffStats {

        private String id;
        private String firstName;
        private String lastName;
        private String emailAddress;
        private String regionName;

        private Decimal outletsVisited;
        private Decimal target;
        private Decimal newOutletsVisited;
        private DateTime startTime;
        private DateTime endTime;

        private Decimal totalStock;
        private Decimal easyLoad;
        private Decimal scratchCards;
        private Decimal sims;

        private Decimal dsd;
        private Decimal nonDsd;

        private Map<String, Decimal> airtime;
        private Map<String, Decimal> merchandise;

        public DailyStaffStats(String id, String firstName, String lastName, String emailAddress, String regionName) {
            this.id = id;
            this.firstName = firstName;
            this.lastName = lastName;
            this.emailAddress = emailAddress;
            this.regionName = regionName;
            this.outletsVisited = 0.0;
            this.target = 0.0;
            this.newOutletsVisited = 0.0;
            this.totalStock = 0.0;
            this.easyLoad = 0.0;
            this.scratchCards = 0.0;
            this.sims = 0.0;
            this.dsd = 0.0;
            this.nonDsd = 0.0;
            this.airtime = generateCompMap();
            this.merchandise = generateCompMap();
        }

        public String getId() {
            return this.id;
        }

        public String getFirstName() {
            return this.firstName;
        }

        public String getLastName() {
            return this.lastName;
        }

        public String getEmailAddress() {
            return this.emailAddress;
        }

        public String getRegionName() {
            return this.regionName;
        }

        public Decimal getOutletsVisited() {
            return this.outletsVisited;
        }
        public void setOutletsVisited(Decimal value) {
            this.outletsVisited += value;
        }

        public Decimal getTarget() {
            return this.target;
        }
        public void setTarget(Decimal value) {
            this.target += value;
        }

        public Decimal getNewOutletsVisited() {
            return this.newOutletsVisited;
        }
        public void setNewOutletsVisited(Decimal value) {
            this.newOutletsVisited += value;
        }

        public Decimal getPercentTarget() {
            if (this.getTarget() == this.getOutletsVisited()) {
                return 100.0;
            }
            else if (this.getTarget() == 0.0) {
                return 0.0;
            }
            else {
                return (this.getOutletsVisited() / this.getTarget()) * 100;
            }
        }

        public Decimal getTotalStock() {
            return this.totalStock;
        }
        public void setTotalStock(Decimal value) {
            this.totalStock += value;
        }

        public Decimal getEasyLoad() {
            return this.easyLoad;
        }
        public void setEasyLoad(Decimal value) {
            this.easyLoad += value;
        }

        public Decimal getScratchCards() {
            return this.scratchCards;
        }
        public void setScratchCards(Decimal value) {
            this.scratchCards += value;
        }

        public Decimal getSims() {
            return this.sims;
        }
        public void setSims(Decimal value) {
            this.sims += value;
        }

        public DateTime getStartTime() {
            return this.startTime;
        }
        public void setStartTime(DateTime value) {
            this.startTime = value;
        }

        public DateTime getEndTime() {
            return this.endTime;
        }
        public void setEndTime(DateTime value) {
            this.endTime = value;
        }

        public String calculateTimeWorked() {
            Decimal timeDifference = 0;
            Decimal minutesDifference = 0;
            Decimal hoursDifferent = 0;
            Decimal minutes = 0;
            if (getStartTime() != null && getEndTime() != null) {
                timeDifference = Decimal.valueOf(getEndTime().getTime() - getStartTime().getTime());
                minutesDifference = timeDifference.divide(60000, 0, System.RoundingMode.CEILING);
                hoursDifferent = minutesDifference.divide(60, 0, System.RoundingMode.FLOOR);
                minutes = minutesDifference - (hoursDifferent * 60);
            }
            return hoursDifferent.intValue() + ' ' + minutes;
        }

        public Decimal getDsd() {
            return this.dsd;
        }
        public void setDsd(Decimal value) {
            this.dsd += value;
        }

        public Decimal getNonDsd() {
            return this.nonDsd;
        }
        public void setNonDsd(Decimal value) {
            this.nonDsd += value;
        }

        public Decimal calculateDsd() {
            if (this.getDsd() == 0) {
                return 0.0;
            }
            return (this.getDsd() / (this.getDsd() + this.getNonDsd())) * 100;
        }

        public void addAirtime(String company, Decimal value) {
            this.airtime.put(company, this.airtime.get(company) + value);
        }
        public Decimal getAirtime(String company) {
            return this.airtime.get(company);
        }

        public void addMerchandise(String company, Decimal value) {
            this.merchandise.put(company, this.merchandise.get(company) + value);
        }
        public Decimal getMerchandise(String company) {
            return this.merchandise.get(company);
        }

        public String getNameTableData() {
            return '<td style="' + getTdNameWidth() + '">' + this.getLastName() + ' ' + this.getFirstName() + '</td>';
        }

        public String getPerformance() {
            return
                '<tr align="left" valign="middle">' +
                    getNameTableData() +
                    '<td style="' + getTdOtherWidth() + '">' + this.getOutletsVisited() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getTarget() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getPercentTarget().setScale(1) + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getNewOutletsVisited() + '</td>' +
                    '<td>' + this.calculateTimeWorked() + '</td>' +
                '</tr>';
        }

        public String getStockHtml() {
            return
                '<tr align="left" valign="middle">' +
                    getNameTableData() +
                    '<td style="' + getTdOtherWidth() + '">' + this.getTotalStock() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getEasyLoad() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getScratchCards() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.getSims() + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + this.calculateDsd().setScale(1) + '</td>' +
                '</tr>';
        }

        public String getPersonalComp() {

            Decimal allAir = 0.0;
            Decimal allMerch = 0.0;
            Decimal airAir = this.getAirtime('Airtel');
            Decimal airMerch = this.getMerchandise('Airtel');
            Decimal warAir = this.getAirtime('Warid');
            Decimal warMerch = this.getMerchandise('Warid');
            Decimal oraAir = this.getAirtime('Orange');
            Decimal oraMerch = this.getMerchandise('Orange');
            Decimal utlAir = this.getAirtime('UTL');
            Decimal utlMerch = this.getMerchandise('UTL');
            Decimal otherAir = this.getAirtime('Other');
            Decimal otherMerch = this.getMerchandise('Other');
            Decimal totalAir = this.getAirtime('Total');
            Decimal totalMerch = this.getMerchandise('Total');
            Decimal total = this.getOutletsVisited();

            Decimal totalComp = 0.0;
            Decimal airComp = 0.0;
            Decimal oraComp = 0.0;
            Decimal warComp = 0.0;
            Decimal utlComp = 0.0;
            Decimal otherComp = 0.0;
            if (total != 0.0) {
                if (totalAir != 0.0) {
                    totalComp = (totalAir / total) * 100;
                }
                if (airAir != 0.0) {
                    airComp = (airAir / total) * 100;
                }
                if (oraAir != 0.0) {
                    oraComp = (oraAir / total) * 100;
                }
                if (warAir != 0.0) {
                    warComp = (warAir / total) * 100;
                }
                if (utlAir != 0.0) {
                    utlComp = (utlAir / total) * 100;
                }
                if (otherAir != 0.0) {
                    otherComp = (otherAir / total) * 100;
                }
            }

            String html = '<tr align="left" valign="middle" >' +
                '<tr>' +
                    '<td style="' + getTdNameWidth() + '">Total</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + totalAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + totalMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + totalComp.setScale(1) + '</td>' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '">Airtel</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + airAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + airMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + airComp.setScale(1) + '</td>' +
                '<tr>' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '">Orange</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + oraAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + oraMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + oraComp.setScale(1) + '</td>' +
                '<tr>' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '">Warid</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + warAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + warMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + warComp.setScale(1) + '</td>' +
                '<tr>' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '">UTL</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + utlAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + utlMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + utlComp.setScale(1) + '</td>' +
                '<tr>' +
                '<tr align="left" valign="middle" >' +
                    '<td style="' + getTdNameWidth() + '">Other</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + otherAir + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + otherMerch + '</td>' +
                    '<td style="' + getTdOtherWidth() + '">' + otherComp.setScale(1) + '</td>' +
                '<tr>';
            return html;
        }

        private Map<String, Decimal> generateCompMap() {
            return new Map<String, Decimal> {
                'Airtel' => 0.0,
                'Orange' => 0.0,
                'Warid' => 0.0,
                'UTL' => 0.0,
                'Other' => 0.0,
                'Total' => 0.0
            };
        }
    }

    // Methods that return the CSS that is inlive to the emails
    private static String getBackgroundColour() {
        return 'background-color:#FFFFFF;';
    }
    private static String getTableBackgroundColour() {
        return 'background-color:#FFCC33;';
    }
    private static String getLargeFont() {
        return 'font-size:30pt;';
    }
    private static String getMediumFont() {
        return 'font-weight:bold;';
    }
    private static String getSmallFont() {
        return 'font-size:10pt;';
    }
    private static String getBoldFont() {
        return 'font-weight=bold;';
    }
    private static String getEvenBackgroundColour() {
        return getBackgroundColour();
    }
    private static String getOddBackgroundColour() {
        return 'background-color:#FFCC33;';
    }
    private static String getCenter() {
        return 'vertical-align: center;';
    }
    private static String getTdNameWidth() {
        return 'width:25%; padding-left:5px;';
    }
    private static String getTdOtherWidth() {
        return 'width:15%; padding-left:5px;;';
    }
    private static String getFullWidth() {
        return 'width:100%;';
    }
    private static String getWideWidth() {
        return 'width:600px;';
    }
    private static String getSumaryWidth() {
        return 'width:96%;';
    }
    private static String getCellAlignment() {
        return 'align="center" valign="middle"';
    }
    private static String getSummaryPadding() {
        return 'padding:0% 2% 2% 2%;';
    }
    private static String getTitleStyle() {
        return 'font-size:20pt; font-family: Trebuchet MS, sans-serif; font-weight: bold; padding-bottom: 5px;' + 
            'text-shadow: 0 0 1px rgba(0, 0, 0, 0.3); -webkit-font-smoothing: subpixel-antialiased; font-smooth: always;';
    }
    private static String getTableStyle(){
        return 'table-layout: fixed; background-color:#FFCC33; width:100%; alignment-adjust:auto;';
    }
    private static String getTableHeaderStyle(){
        return 'font-size:12px; font-family: Trebuchet MS, sans-serif; word-wrap: break-word; background-color:#FFC600;' +
            'font-weight:bold; text-shadow: 0 0 1px rgba(0, 0, 0, 0.1); -webkit-font-smoothing: antialiased; font-smooth: always;';
    }
    private static String getTableBodyStyle() {
        return 'white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space:-o-pre-wrap; white-space: pre-wrap; word-wrap: break-word;'+
            'font-size:13px; font-family: arial, sans-serif; background-color:#FFFFFF; -webkit-font-smoothing: antialiased; font-smooth: always;';
    }

}