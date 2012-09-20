var sectionRefreshStore = new Object();

function addSectionRefreshStore(sectionKey, key) {

    var items = sectionRefreshStore[sectionKey];
    if (typeof items == "undefined") {
        sectionRefreshStore[sectionKey] = key;
    }
    else {
        sectionRefreshStore[sectionKey] = items + '_int_' + key;
    }
}
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
}

function refreshComponent(key) {
    openGenericModal('genericDialog', 'Refreshing component. Please wait');
    var func = window[key];
    func();
}