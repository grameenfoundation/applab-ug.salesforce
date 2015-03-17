<<<<<<< HEAD
function setFocus() {
   document.getElementById(idPrefix + 'outletType').focus();
}

var xAxis = 1;
function setXAxisType(elem) {
    if (elem.checked) {
        xAxis = elem.value;
    }
}

// Validate the selector form. Add the errors if needed and show them if required
function validateForm() {

    // Check that the graphs api has loaded
    if (!allowSubmission) {
        addError("Please wait for graph api to load");
        validateFormSuccess = false;
    }

    //Make sure an option is ticked
    var validateFormSuccess = true;
    if (!document.getElementById(idPrefix + 'showOutlet').checked
            && !document.getElementById(idPrefix + 'showPromotion').checked
            && !document.getElementById(idPrefix + 'showStockGraph').checked
            && !document.getElementById(idPrefix + 'showDSD').checked
            && !document.getElementById(idPrefix + 'showCompetitorGraph').checked
            && !document.getElementById(idPrefix + 'showCompetitorStockGraph').checked    ) {
        addError("Please select at least one of the commands");
        validateFormSuccess = false;
    }
    return validateFormSuccess;
}

// Submit form
function submitForm() {

    if (!validateForm()) {
        addErrorViaSF();
        return false;
    }

    var showOutlet = document.getElementById(idPrefix + 'showOutlet').checked ? 'true' : 'false';
    var showPromotion = document.getElementById(idPrefix + 'showPromotion').checked ? 'true' : 'false';
    var showStockGraph = document.getElementById(idPrefix + 'showStockGraph').checked ? 'true' : 'false';
    var showDSD = document.getElementById(idPrefix + 'showDSD').checked ? 'true' : 'false';
    var showCompetitorGraph = document.getElementById(idPrefix + 'showCompetitorGraph').checked ? 'true' : 'false';
    var showCompetitorStockGraph = document.getElementById(idPrefix + 'showCompetitorStockGraph').checked ? 'true' : 'false';

    openGenericModal('genericDialog', 'Rebuilding Dashboard. Please wait');
    clearErrorsFromPage();
    refreshAllGraphs(
        showOutlet,
        showPromotion,
        showStockGraph,
        showDSD,
        showCompetitorGraph,
        showCompetitorStockGraph,
        getSingleSelectValue(document.getElementById(idPrefix + 'outletType')),
        getSingleSelectValue(document.getElementById(idPrefix + 'stockType')),
        getSingleSelectValue(document.getElementById(idPrefix + 'merchandiseType')),
        xAxis
    );
};

var sectionRefreshStore = new Object();

function addSectionRefreshStore(sectionKey, key) {

    var items = sectionRefreshStore[sectionKey];
    if (typeof items == "undefined") {
        sectionRefreshStore[sectionKey] = key;
    }
    else {
        sectionRefreshStore[sectionKey] = items + '_int_' + key;
    }
};

function refreshDashboardSection(sectionKey) {

    clearErrorsFromPage();
    var idList = sectionRefreshStore[sectionKey];
    if (typeof idList == "undefined") {
        return;
    }
    var ids = idList.split('_int_');
    for (var i = 0, length = ids.length; i < length; i++) {
        refreshComponent(ids[i]);
    }
};

function refreshComponent(key) {
    openGenericModal('genericDialog', 'Refreshing component. Please wait');
    outletType = getSingleSelectValue(document.getElementById(idPrefix + 'outletType'));
    stockType = getSingleSelectValue(document.getElementById(idPrefix + 'stockType'));
    merchandiseType = getSingleSelectValue(document.getElementById(idPrefix + 'merchandiseType'));
    xAxisType = xAxis;
    var func = window[key](outletType, stockType, merchandiseType, xAxisType);
    func();
};

function openGraphInNewWindow(url, id) {
    url = url + '?type=graph&id=' + id;
    popup = window.open(url,"_blank");
    popup.focus();
=======
function setFocus() {
   document.getElementById(idPrefix + 'outletType').focus();
}

var xAxis = 1;
function setXAxisType(elem) {
    if (elem.checked) {
        xAxis = elem.value;
    }
}

// Validate the selector form. Add the errors if needed and show them if required
function validateForm() {

    // Check that the graphs api has loaded
    if (!allowSubmission) {
        addError("Please wait for graph api to load");
        validateFormSuccess = false;
    }

    //Make sure an option is ticked
    var validateFormSuccess = true;
    if (!document.getElementById(idPrefix + 'showOutlet').checked
            && !document.getElementById(idPrefix + 'showPromotion').checked
            && !document.getElementById(idPrefix + 'showStockGraph').checked
            && !document.getElementById(idPrefix + 'showDSD').checked
            && !document.getElementById(idPrefix + 'showCompetitorGraph').checked
            && !document.getElementById(idPrefix + 'showCompetitorStockGraph').checked    ) {
        addError("Please select at least one of the commands");
        validateFormSuccess = false;
    }
    return validateFormSuccess;
}

// Submit form
function submitForm() {

    if (!validateForm()) {
        addErrorViaSF();
        return false;
    }

    var showOutlet = document.getElementById(idPrefix + 'showOutlet').checked ? 'true' : 'false';
    var showPromotion = document.getElementById(idPrefix + 'showPromotion').checked ? 'true' : 'false';
    var showStockGraph = document.getElementById(idPrefix + 'showStockGraph').checked ? 'true' : 'false';
    var showDSD = document.getElementById(idPrefix + 'showDSD').checked ? 'true' : 'false';
    var showCompetitorGraph = document.getElementById(idPrefix + 'showCompetitorGraph').checked ? 'true' : 'false';
    var showCompetitorStockGraph = document.getElementById(idPrefix + 'showCompetitorStockGraph').checked ? 'true' : 'false';

    openGenericModal('genericDialog', 'Rebuilding Dashboard. Please wait');
    clearErrorsFromPage();
    refreshAllGraphs(
        showOutlet,
        showPromotion,
        showStockGraph,
        showDSD,
        showCompetitorGraph,
        showCompetitorStockGraph,
        getSingleSelectValue(document.getElementById(idPrefix + 'outletType')),
        getSingleSelectValue(document.getElementById(idPrefix + 'stockType')),
        getSingleSelectValue(document.getElementById(idPrefix + 'merchandiseType')),
        xAxis
    );
};

var sectionRefreshStore = new Object();

function addSectionRefreshStore(sectionKey, key) {

    var items = sectionRefreshStore[sectionKey];
    if (typeof items == "undefined") {
        sectionRefreshStore[sectionKey] = key;
    }
    else {
        sectionRefreshStore[sectionKey] = items + '_int_' + key;
    }
};

function refreshDashboardSection(sectionKey) {

    clearErrorsFromPage();
    var idList = sectionRefreshStore[sectionKey];
    if (typeof idList == "undefined") {
        return;
    }
    var ids = idList.split('_int_');
    for (var i = 0, length = ids.length; i < length; i++) {
        refreshComponent(ids[i]);
    }
};

function refreshComponent(key) {
    openGenericModal('genericDialog', 'Refreshing component. Please wait');
    outletType = getSingleSelectValue(document.getElementById(idPrefix + 'outletType'));
    stockType = getSingleSelectValue(document.getElementById(idPrefix + 'stockType'));
    merchandiseType = getSingleSelectValue(document.getElementById(idPrefix + 'merchandiseType'));
    xAxisType = xAxis;
    var func = window[key](outletType, stockType, merchandiseType, xAxisType);
    func();
};

function openGraphInNewWindow(url, id) {
    url = url + '?type=graph&id=' + id;
    popup = window.open(url,"_blank");
    popup.focus();
>>>>>>> origin/ci
};