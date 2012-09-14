function refreshDashboardSection() {
    openGenericModal('genericDialog', 'Refreshing component. Please wait');
    refreshAllGraphs();
}

function setFocus() {
   document.getElementById(idPrefix + 'outletType').focus();
}

function openBreakDown(url, type, id, currentDate, foId, selectorId) {
    currentDate = currentDate.replace(' ', 'sp');
    url = url + '?date=' + currentDate + '&id=' + id + '&type=' + type + '&foId=' + foId + '&selector=' + selectorId;
    openNewWindow(url);
};

// Open a window to a standard sObject tab
function openNewWindow(url) {
    popup = window.open(url,"_blank");
    popup.focus();
};