<<<<<<< HEAD
/**
 * Javascript used by the components that make up the selectors for the dashboards amongst other things
 */

var refreshStore = new Object();
var actionStore = new Object();

function addRefreshVariable(id, value) {

    // Deals with removing a selection
    if (value == "") {
        value = "NO_VALUE";
    }
    refreshStore[id] = value;
}

// Generates a string that contains all the variables that have been set by this selector
function generateRefreshList(id) {
    return refreshStore[id];
}

// Refresh all the components that are related to the component that has been changed
function refreshComponents(id, value) {

    openGenericModal('genericDialog', 'Updating values in the selectors. Please wait');
    clearErrorsFromPage();

    // Dig out all the component ids that need refreshing
    var ids = generateRefreshList(id).split(",");

    // for each component id call the action function that is associated with it.
    for (var i = 0, length = ids.length; i < length; i++) {
        if (ids[i] == "NO_VALUE") {
            continue;
        }
        var func = window[getActionFunction(ids[i])];
        if (typeof(func) == 'undefined') {
            continue;
        }
        func();
    }
}

function addActionFunction(id, value) {

    // Deals with removing a selection
    if (value == "") {
        value = "NO_VALUE";
    }
    actionStore[id] = value;
}

// Generates a string that contains all the variables that have been set by this selector
function getActionFunction(id) {
    return actionStore[id];
=======
/**
 * Javascript used by the components that make up the selectors for the dashboards amongst other things
 */

var refreshStore = new Object();
var actionStore = new Object();

function addRefreshVariable(id, value) {

    // Deals with removing a selection
    if (value == "") {
        value = "NO_VALUE";
    }
    refreshStore[id] = value;
}

// Generates a string that contains all the variables that have been set by this selector
function generateRefreshList(id) {
    return refreshStore[id];
}

// Refresh all the components that are related to the component that has been changed
function refreshComponents(id, value) {

    openGenericModal('genericDialog', 'Updating values in the selectors. Please wait');
    clearErrorsFromPage();

    // Dig out all the component ids that need refreshing
    var ids = generateRefreshList(id).split(",");

    // for each component id call the action function that is associated with it.
    for (var i = 0, length = ids.length; i < length; i++) {
        if (ids[i] == "NO_VALUE") {
            continue;
        }
        var func = window[getActionFunction(ids[i])];
        if (typeof(func) == 'undefined') {
            continue;
        }
        func();
    }
}

function addActionFunction(id, value) {

    // Deals with removing a selection
    if (value == "") {
        value = "NO_VALUE";
    }
    actionStore[id] = value;
}

// Generates a string that contains all the variables that have been set by this selector
function getActionFunction(id) {
    return actionStore[id];
>>>>>>> origin/ci
}