// Variables for the actual graphs
var graphParameters = new Object();

// Create the google graph object. Class method for graphDetails.
function generateGraph () {

    this.chart = new google.visualization.ChartWrapper({
        chartType: this.chartType,
        containerId: this.graphId,
        dataTable : this.dataTable,
        options : {
            'width': this.width,
            'height': this.height,
            'hAxis': {title: this.xAxisTitle, titleTextStyle: {color: this.xAxisColor}},
            'vAxis' : {title: this.yAxisTitle, titleTextStyle: {color: this.yAxisColor}},
            'title': this.title,
            'titleTextStyle' : {color: this.titleColor},
            'legendTextStyle' : {color: this.legendColor}
        }
    });
    google.visualization.events.addListener(this.chart, 'ready', chartReady(this.graphId));
    google.visualization.events.addListener(this.chart, 'error', handleError);
};

// Rebuild the data table after a refresh of the json string
function rebuildDataTable() {
    this.dataTable = new google.visualization.DataTable(this.json, 0.6);
    this.chart.setDataTable(this.dataTable);
};

// Draw the graph. Class method for graphDetails.
function drawGraph() {

    var graphWidth = j$('#' + this.graphId).width();
    this.chart.draw();
    if (this.showDataInline) {
        this.drawDataTable();
    }
};

// Pull the data out of the data table and add it to the page
function drawDataTable() {
    var html = '<table class="graphInlineTable ellipsis">';
    for (var i = 0; i < this.dataTable.getNumberOfRows(); i++) {
        var row = '<tr class="graphInlineDataRow">';
        for (j = 0; j < this.dataTable.getNumberOfColumns(); j++) {
            if (i == 0) {
                html = html + '<td class="graphInlineDataCell graphInlineDataHeader ellipsis">' + this.dataTable.getColumnLabel(j) + '</td>';
            }
            row = row + '<td class="graphInlineDataCell ellipsis';
            if (i % 2 == 0 ) {
                row = row + ' graphInlineDataEven"';
            }
            else {
                row = row + ' graphInlineDataOdd"';
            }
            row = row + '>' + this.dataTable.getValue(i, j) + '</td>';
        }
        html = html + row + '</tr>';
    }
    html = html + '</table>';
    document.getElementById(this.graphId + '_dataTable').innerHTML  = html;
};

// Class that represents an instance of a graph
function graphDetails(
        graphId,
        json,
        chartType,
        xAxisTitle,
        xAxisColor,
        yAxisTitle,
        yAxisColor,
        title,
        titleColor,
        legendColor,
        showDataInline,
        height,
        width,
        expanded
) {
    this.graphId = graphId;
    this.json = json;
    this.chartType = chartType;
    this.xAxisTitle = xAxisTitle;
    this.xAxisColor = xAxisColor;
    this.yAxisTitle = yAxisTitle;
    this.yAxisColor = yAxisColor;
    this.title = title;
    this.titleColor = titleColor;
    this.legendColor = legendColor;
    this.showDataInline = showDataInline;
    this.height = height;
    this.width = width;
    this.expanded = expanded;
    this.dataTable = new google.visualization.DataTable(json, 0.6);
    this.chart = null;

    // Add the class methods
    this.generateGraph = generateGraph;
    this.drawGraph = drawGraph;
    this.rebuildDataTable = rebuildDataTable;
    this.drawDataTable = drawDataTable;
}

// Load the Visualization API and the piechart package.
google.load('visualization', '1.1', {packages: ['controls']});

// Set a callback to run when the Google Visualization API is loaded.
google.setOnLoadCallback(drawAllGraphs);

function drawAllGraphs() {
    for (var key in graphParameters) {
        if (graphParameters.hasOwnProperty(key)) {
            graphParameters[key].generateGraph();
            graphParameters[key].drawGraph();
        }
    }
};

function addGraphParameter(id, param) {
    graphParameters[id] = param;
}

function chartReady(key) {
    if (graphParameters[key].expanded) {
        var winW= j$('#graphExtendedDiv').width();
        var graphWidth = graphParameters[key].width;
        j$('#' + key).css('margin-left', (winW/2)-(graphWidth/2));
        j$('#graphRefresh').css('margin-left', '45%');
    }
};

function getGraph(id) {
    return graphParameters[id];
};

function openGraphInNewWindow(url, id) {
    url = url + '?type=graph&id=' + id;
    popup = window.open(url,"_blank");
    popup.focus();
};

function showDataTable(id) {
    getGraph(id).drawDataTable();
};
function handleError(errorId, message) {
    google.visualization.errors.removeAll(google.visualization.errors.getContainer(errorId.id));
}