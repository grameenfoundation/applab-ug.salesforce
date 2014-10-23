var idStore = new Object();

var anchorId;

var showBarChart = false;
var showTopTwelveOne = false;
var showTopTwelveTwo = false;
var showTrendGraph = false;

function setFocus() {
   document.getElementById(idPrefix + 'country').focus();
}

function setPageLayoutOptions(id, ids) {
    idStore[id] = ids;
}

function getPageLayoutOptions(id) {
    return idStore[id];
}

function toggleDisable(bool) {

    var ids = idStore['ALL'].split(',');
    for (var i = 0; i < ids.length; i++) {
        var elem = document.getElementById(idPrefix + ids[i]);
        if (elem != null) {
            elem.disabled = bool;
        }
    }

    // Have to do the submit button separetly due to SF fun way of identifying dom elements
    document.getElementById('submit').disabled = bool;
    document.getElementById('setDefaultTargets').disabled = bool;
    document.getElementById('setTdrTargets').disabled = bool;
}

function alterDates(elem) {

    // Check that we are looking at the weekly figures if so then change the date
    if (!document.getElementById(idPrefix + 'showWeekly').checked || elem.value == '') {
        return;
    }
    var dateParts = elem.value.split('/');
    var enteredDate = new Date();
    enteredDate.setMonth(parseInt(dateParts[0]) - 1);
    enteredDate.setDate(parseInt(dateParts[1]));
    enteredDate.setDate(parseInt(dateParts[1]));
    enteredDate.setYear(parseInt(dateParts[2]));
    enteredDate.setDate(enteredDate.getDate() - enteredDate.getDay());
    var month = enteredDate.getMonth() + 1;
    elem.value = month + '/' + enteredDate.getDate() + '/' + enteredDate.getFullYear();
}

function showTopTwelveComparisonDiv(elem) {
    if (elem.checked) {
        document.getElementById('radioButtonsWrapper').style.display = 'block';
        document.getElementById('topTwelveComparision').style.display = 'inline';
    }
    else {
        document.getElementById('radioButtonsWrapper').style.display = 'none';
        document.getElementById('topTwelveComparision').style.display = 'none';
        document.getElementById(idPrefix + 'showTopTwelveComparison').checked = false;
    }
    toggleClass(j$('#radionButtonsTopTwelve'), 'tableRowNoBoarder');
    toggleClass(j$('#radionButtonsTopTwelve'), 'tableRow');
}

var topTwelveType = 1;
function setTopTwelveType(elem) {
    if (elem.checked) {
        topTwelveType = elem.value;
    }
}

function getTopTwelveSelectorValue() {

    if (!document.getElementById(idPrefix + 'showTopTwelve').checked) {
        return '1';
    }
    return topTwelveType;
}

// Validate the selector form. Add the errors if needed and show them if required
function validateForm() {

    //Make sure an option is ticked
    var validateFormSuccess = true;
    if (!document.getElementById(idPrefix + 'showBarGraph').checked
            && !document.getElementById(idPrefix + 'showTopTwelve').checked
            && !document.getElementById(idPrefix + 'showDailyActivityReport').checked
    ) {
        addError("Please select at least one of the commands");
        validateFormSuccess = false;
    }

    // Validate if the bar graph is to be displayed
    if (document.getElementById(idPrefix + 'showBarGraph').checked) {

        // There needs to be at least one of the date fields selected
        // Or if a month is selected there must be a year selected
        if (document.getElementById(idPrefix + 'weekRangeStart').value == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'month')) == ''
        ) {
            addError("You must select a year, month or start date to see the bar graph");
            validateFormSuccess = false;
        }
        else if (getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'month')) != ''
        ) {
            addError("If you select a month, you must select a year");
            validateFormSuccess = false;
        }
    }

    // Validate if the daily records are to be shown
    //|| document.getElementById(idPrefix + 'showActivitySummary').checked
    if (document.getElementById(idPrefix + 'showDailyActivityReport').checked) {

        // There needs to be at least one of the date fields selected
        // Or if a month is selected there must be a year selected
        if (document.getElementById(idPrefix + 'weekRangeStart').value == '') {
            addError("Select a date or date range to see the daily activities");
            validateFormSuccess = false;
        }
    }

    // Validate if the top twelve graphs are to be shown
    if (document.getElementById(idPrefix + 'showTopTwelve').checked) {

        // There needs to be at least one of the date fields selected
        // Or if a month is selected there must be a year selected
        if (document.getElementById(idPrefix + 'weekRangeStart').value == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'month')) == ''
        ) {
            addError("You must select a year, month or start date to see the top twelve graph");
            validateFormSuccess = false;
        }
        else if (getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
                && getSingleSelectValue(document.getElementById(idPrefix + 'month')) != ''
        ) {
            addError("If you select a month, you must select a year");
            validateFormSuccess = false;
        }

        // Check if looking at the comparison
        if (document.getElementById(idPrefix + 'showTopTwelveComparison').checked) {
            if (document.getElementById(idPrefix + 'weekRangeStart').value == ''
                    || document.getElementById(idPrefix + 'weekRangeEnd').value == ''
            ) {
                addError("Please select and start and end date to see the comparison graph");
                validateFormSuccess = false;
            }
        }
    }
    return validateFormSuccess;
}

function submitForm() {

    if (!validateForm()) {
        addErrorViaSF();
        return false;
    }

    var weekRangeStart = document.getElementById(idPrefix + 'weekRangeStart').value == null ? '' : document.getElementById(idPrefix + 'weekRangeStart').value;
    var weekRangeEnd = document.getElementById(idPrefix + 'weekRangeEnd').value == null ? '' : document.getElementById(idPrefix + 'weekRangeEnd').value;
    var barGraph = document.getElementById(idPrefix + 'showBarGraph').checked ? 'true' : 'false';
    var topTwelve = document.getElementById(idPrefix + 'showTopTwelve').checked ? 'true' : 'false';
    var topTwelveComparison = document.getElementById(idPrefix + 'showTopTwelveComparison').checked ? 'true' : 'false';
    var showDailyActivityReport = document.getElementById(idPrefix + 'showDailyActivityReport').checked ? 'true' : 'false';
    //var showActivitySummary = document.getElementById(idPrefix + 'showActivitySummary').checked ? 'true' : 'false';
    var showActivitySummary = 'false';
    var showWeekly = document.getElementById(idPrefix + 'showWeekly').checked ? 'true' : 'false';

    // Decide which anchor to jump to. As all Graphs could be show just take the first one. Default to itself.
    anchorId = 'selectorFormAnchor';
    if (barGraph == 'true') {
        anchorId = 'barGraphAnchor';
    }
    else if (topTwelve == 'true') {
        anchorId = 'topTwelveAnchor';
    }
    else if (showDailyActivityReport == 'true') {
        anchorId = 'dailyReportsAnchor';
    }
    openModal('dialog', 'Fetching new values. Please wait');
    clearErrorsFromPage();
    submitRequest (
        getSingleSelectValue(document.getElementById(idPrefix + 'country')),
        getSingleSelectValue(document.getElementById(idPrefix + 'region')),
        getMultipleSelectValue(document.getElementById(idPrefix + 'tdrs')),
        getSingleSelectValue(document.getElementById(idPrefix + 'year')),
        getSingleSelectValue(document.getElementById(idPrefix + 'month')),
        weekRangeStart,
        weekRangeEnd,
        barGraph,
        topTwelve,
        topTwelveComparison,
        getTopTwelveSelectorValue(),
        showWeekly,
        showDailyActivityReport,
        showActivitySummary
    );
}

        // Reset the parameters that control the chart drawing. Needed as the variable substitution is
        // not redone each ajax call in the JS
        function setShowCharts(barChart, topTwelveOne, topTwelveTwo) {
            showBarChart = barChart;
            showTopTwelveOne = topTwelveOne;
            showTopTwelveTwo = topTwelveTwo;
        }

        function toggleCheckBox(id) {
            elem = document.getElementById(id);
            if (elem.checked) {
                elem.checked = false;
            }
            else {
                elem.checked = true;
            }
        }

        function changePageRows() {
            openModal('dialog', 'Getting new page. Please wait');
            changePageNumbers(getSingleSelectValue(document.getElementById(paginationPrefix + ':' + 'pageNumbers')));
        }


        // Load the Visualization API and the piechart package.
        google.load('visualization', '1.1', {packages: ['controls']});
        //google.load('visualization', '1', {'packages':['corechart']});

        // Set a callback to run when the Google Visualization API is loaded.
        google.setOnLoadCallback(drawChart);

        function drawChart() {
            if (showBarChart) {
                drawBarChart();
            }
            if (showTopTwelveOne) {
                drawTopTwelveOneChart();
            }
            if (showTopTwelveTwo) {
                drawTopTwelveTwoChart();
            }
            if (showTrendGraph) {
                drawTrendChart();
            }
        }

        // Draw the bar chart
        var barGraphDataJson = '';
        var barChartHeader = '';
        var scope = '';
        var showAgentBase = false;
        var chart;
        var dashboard;
        function getWidth() {
            return document.getElementById('bodyTable').offsetWidth - 40;
        }

        function drawBarChart() {

            var barData = new google.visualization.DataTable(barGraphDataJson, 0.6);

            // Set the title for the graph
            if (scope == 'COUNTRY') {
                showAgentBase = true;
                barTitle = 'Region';
            }
            else {
                showAgentBase = false;
                barTitle = 'TDR Name';
            }
            chart = new google.visualization.ChartWrapper({
                chartType: 'ColumnChart',
                containerId: 'bar_div',
                dataTable : barData,
                options : {
                    'width': getWidth(),
                    'height': 450,
                    'hAxis': {title: barTitle, titleTextStyle: {color: '#FF001C'}},
                    'title': 'Showing Full Reports for ' + barChartHeader,
                    'titleTextStyle' : {color: '#00467E'},
                    'legendTextStyle' : {color: '#00467E'}
                },
                view: {'columns': [0, 1, 2]}
            });

            google.visualization.events.addListener(chart, 'ready', barChartReady);

            if (showAgentBase) {
                chart.setView({columns: [0, 1, 2, 12]});
            }
            setSeries(false, showAgentBase);
            chart.draw();
        }

        function setSeries(isFull, isAgent) {

            if (isAgent) {
                if (isFull) {
                    chart.setOption('series', {
                        0:{color: '#00467E'},
                        1:{color: '#FFC600'},
                        2:{color: '#00467E'},
                        3:{color: '#FFC600'},
                        4:{color: '#00467E'},
                        5:{color: '#FFC600'},
                        6:{color: '#00467E'},
                        7:{color: '#FFC600'},
                        8:{color: '#00467E'},
                        9:{color: '#00467E'},
                        10:{color: '#00467E'},
                        11:{color: '#FF001C'}
                    });
                }
                else {
                    chart.setOption('series', {0:{color: '#00467E'},
                        1:{color: '#FFC600'},
                        2:{color: '#FF001C'}
                    });
                }
            }
            else {
                if (isFull) {
                    chart.setOption('series', {
                        0:{color: '#00467E'},
                        1:{color: '#FFC600'},
                        2:{color: '#00467E'},
                        3:{color: '#FFC600'},
                        4:{color: '#00467E'},
                        5:{color: '#FFC600'},
                        6:{color: '#00467E'},
                        7:{color: '#FFC600'},
                        8:{color: '#00467E'},
                        9:{color: '#00467E'},
                        10:{color: '#00467E'},
                    });
                }
                else {
                    chart.setOption('series', {
                        0:{color: '#00467E'},
                        1:{color: '#FFC600'}
                    });
                }
            }
        }

        function barChartReady() {

            // Once the chart is ready add the onlick function to the check boxes that control the display
            document.getElementById('showAllBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]});
                }
                else {
                    chart.setView({columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]});
                }
                setSeries(true, showAgentBase);
                chart.setOption('title', 'Showing all activities for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showLongReportsBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 1, 2, 12]});
                }
                else {
                    chart.setView({columns: [0, 1, 2]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing Full Reports for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showShortReportsBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 3, 4, 12]});
                }
                else {
                    chart.setView({columns: [0, 3, 4]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing Short Reports for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showCorporateSalesCallBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 5, 6, 12]});
                }
                else {
                    chart.setView({columns: [0, 5, 6]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing Corporate Sales Calls for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showSchoolSalesCallBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 7, 8, 12]});
                }
                else {
                    chart.setView({columns: [0, 7, 8]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing School Sales Calls for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showCustomerSupportBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 9, 12]});
                }
                else {
                    chart.setView({columns: [0, 9]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing Customer Support for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showMarketingEventBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 10, 12]});
                }
                else {
                    chart.setView({columns: [0, 10]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing Marketing Events for ' + barChartHeader);
                chart.draw();
            };
            document.getElementById('showOtherBarControl').onclick = function() {
                if (showAgentBase) {
                    chart.setView({columns: [0, 11, 12]});
                }
                else {
                    chart.setView({columns: [0, 11 ]});
                }
                setSeries(false, showAgentBase);
                chart.setOption('title', 'Showing other activities for ' + barChartHeader);
                chart.draw();
            };
            scrollTo(anchorId);
        }

        // Draw the top twelve chart
        var topTwelveOneJson;
        var topTwelveOneHeader;
        var topTwelveHAxis;
        var topTwelveHAxisSize;
        function drawTopTwelveOneChart() {

            var topTweleveOneData = new google.visualization.DataTable(topTwelveOneJson, 0.6);

            // Calculate the width of this chart. full width if just one. half if to
            var topTwelveOneWidth = getWidth();
            if (showTopTwelveTwo) {
               topTwelveOneWidth = parseInt(topTwelveOneWidth / 2);
            }
            var topTweleveOneChart = new google.visualization.ChartWrapper({
                chartType: 'BarChart',
                containerId: 'top_twelve_one_div',
                dataTable : topTweleveOneData,
                options : {
                    'width'  : topTwelveOneWidth,
                    'height' : 450,
                    'hAxis': {title: topTwelveHAxis, titleTextStyle: {color: 'FF001C'}, maxValue: parseInt(topTwelveHAxisSize)},
                    'vAxis': {title: 'TDR Name', titleTextStyle: {color: '00467E'}},
                    'title' : topTwelveOneHeader,
                    'titleTextStyle' : {color: '00467E'},
                    'legendTextStyle' : {color: '00467E'},
                    'series' : {0:{color: 'FFC600'}}
                }
           });
            google.visualization.events.addListener(topTweleveOneChart, 'ready', topTwelveReady);
            topTweleveOneChart.draw();
        }

        // Draw the top twelve chart
        var topTwelveTwoJson;
        var topTwelveTwoHeader;
        function drawTopTwelveTwoChart() {

            var topTwelveTwoData = new google.visualization.DataTable(topTwelveTwoJson, 0.6);

            var topTwelveTwoChart = new google.visualization.ChartWrapper({
                chartType: 'BarChart',
                containerId: 'top_twelve_two_div',
                dataTable : topTwelveTwoData,
                options : {
                    'width'  : parseInt(getWidth() / 2),
                    'height' : 450,
                    'hAxis': {title: topTwelveHAxis, titleTextStyle: {color: 'FF001C'}, maxValue: parseInt(topTwelveHAxisSize)},
                    'vAxis': {title: 'TDR Name', titleTextStyle: {color: '00467E'}},
                    'title' : topTwelveTwoHeader,
                    'titleTextStyle' : {color: '00467E'},
                    'legendTextStyle' : {color: '00467E'},
                    'series' : {0:{color: 'FFC600'}}
                }
           });

            google.visualization.events.addListener(topTwelveTwoChart, 'ready', topTwelveReady);
            topTwelveTwoChart.draw();
        }

        function topTwelveReady() {
            scrollTo(anchorId);
        }

