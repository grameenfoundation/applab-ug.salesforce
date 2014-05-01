// Functions to deal with target setting
function validateTargets() {

    // Check that we have the minimum inputs
    var showTargetsSuccess = true;
    if (document.getElementById(idPrefix + 'weekRangeStart').value == ''
            && getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
            && getSingleSelectValue(document.getElementById(idPrefix + 'month')) == ''
    ) {
        addError("You must select a year, month or start date to set targets");
        showTargetsSuccess = false;
    }
    else if (getSingleSelectValue(document.getElementById(idPrefix + 'year')) == ''
            && getSingleSelectValue(document.getElementById(idPrefix + 'month')) != ''
    ) {
        addError("If you select a month, you must select a year");
        showTargetsSuccess = false;
    }
    if (getSingleSelectValue(document.getElementById(idPrefix + 'region')) == '') {
        addError("You must at least select a region to set targets");
        showTargetsSuccess = false;
    }

    return showTargetsSuccess;
}

// Generate the display string for target update
function generateDisplayString(type) {

    var display = '<span style="font-weight:bold">Set ';
    if (type == 'DEFAULT') {
        display += 'default targets ';
    }
    else {
        display += 'TDR targets ';
    }
    display += 'for ' + getSingleSelectText(document.getElementById(idPrefix + 'country')) + ' in the ' + getSingleSelectText(document.getElementById(idPrefix + 'region')) + ' region.';
    if (getMultipleSelectText(document.getElementById(idPrefix + 'tdrs')) != null
            && getMultipleSelectText(document.getElementById(idPrefix + 'tdrs')) != ''
            && type != 'DEFAULT'
    ) {
        display += '<br/>';
        display += 'TDRs that are being updated are ';
        var tdr = getMultipleSelectText(document.getElementById(idPrefix + 'tdrs')).split(',');
        var counter = 0;
        for (i = 0; i < tdr.length; i++) {
            display += tdr[i] + '; ';
            if (counter == 5) {
                display += '<br/>';
                counter = 0;
            }
        }
    }
    var yearString = 'NONE';
    var dayString = 'NONE';
    if (document.getElementById(idPrefix + 'weekRangeStart').value != '') {
        if (document.getElementById(idPrefix + 'weekRangeEnd').value != '') {
            if (document.getElementById(idPrefix + 'showWeekly').checked) {
                dayString = 'For each week between the ' + document.getElementById(idPrefix + 'weekRangeStart').value + ' and ' + document.getElementById(idPrefix + 'weekRangeEnd').value + ' inclusive.';
            }
            else {
                dayString = 'For each day between the ' + document.getElementById(idPrefix + 'weekRangeStart').value + ' and ' + document.getElementById(idPrefix + 'weekRangeEnd').value + ' inclusive.';
            }
        }
        else {
            if (document.getElementById(idPrefix + 'showWeekly').checked) {
                dayString = 'For week beginning ' + document.getElementById(idPrefix + 'weekRangeStart').value + '.';
            }
            else {
                dayString = 'For date ' + document.getElementById(idPrefix + 'weekRangeStart').value + '.';
            }
        }
    }
    else {
        yearString = 'For ';
        if (getSingleSelectValue(document.getElementById(idPrefix + 'month')) != '') {
            yearString += getSingleSelectText(document.getElementById(idPrefix + 'month')) + ' ';
        }
        yearString += getSingleSelectText(document.getElementById(idPrefix + 'year'));
    }
    if (dayString  == 'NONE') {
        display += '<br/>' + yearString;
    }
    else {
        display += '<br/>' + dayString;
    }
    return display + '<br/></span>';
}

function cancelTargets(type) {
    redirectToHome();
}

function clearTargets() {
    document.getElementById(targetPrefix + 'longSurveysTargets').value = '';
    document.getElementById(targetPrefix + 'shortSurveysTargets').value = '';
    document.getElementById(targetPrefix + 'corporateSalesCalls').value = '';
    document.getElementById(targetPrefix + 'schoolSalesCalls').value = '';
}

function submitTargets(type) {

    openModal('dialog', generateDisplayString(type));
    var mmLongReports = document.getElementById(targetPrefix + 'longSurveysTargets').value;
    var mmShortReports = document.getElementById(targetPrefix + 'shortSurveysTargets').value;
    var corporateSalesCalls = document.getElementById(targetPrefix + 'corporateSalesCalls').value;
    var schoolSalesCalls = document.getElementById(targetPrefix + 'schoolSalesCalls').value;
    var valid = validateTargets();

    // Check that at least one of the targets have been set and that it is a number
    var allBlank = true;
    if (mmLongReports != '') {
        allBlank = false;
        if (isNaN(mmLongReports)) {
            valid = false;
            addError('Please enter a valid number into the MM Long Reports entry field');
        }
    }
    if (mmShortReports != '') {
        allBlank = false;
        if (isNaN(mmShortReports)) {
            valid = false;
            addError('Please enter a valid number into the MM Short Reports entry field');
        }
    }
    if (corporateSalesCalls != '') {
        allBlank = false;
        if (isNaN(corporateSalesCalls)) {
            valid = false;
            addError('Please enter a valid number into the corporate sales call entry field');
        }
    }
    if (schoolSalesCalls != '') {
        allBlank = false;
        if (isNaN(schoolSalesCalls)) {
            valid = false;
            addError('Please enter a valid number into the School sales call entry field');
        }
    }

    if (allBlank) {
        valid = false;
        addError('Please enter a valid number into at least one of the targets');
    }
    if (!valid) {
        addErrorViaSF();
        closeModal();
        return false;
    }
    clearErrorsFromPage();
    var weekRangeStart = document.getElementById(idPrefix + 'weekRangeStart').value == null ? '' : document.getElementById(idPrefix + 'weekRangeStart').value;
    var weekRangeEnd = document.getElementById(idPrefix + 'weekRangeEnd').value == null ? '' : document.getElementById(idPrefix + 'weekRangeEnd').value;
    var showWeekly = document.getElementById(idPrefix + 'showWeekly').checked ? 'true' : 'false';
    var tdrs = '';
    if (type = 'TDR') {
        tdrs = getMultipleSelectValue(document.getElementById(idPrefix + 'tdrs'));
    }
    submitTargetsFunc (
        getSingleSelectValue(document.getElementById(idPrefix + 'country')),
        getSingleSelectValue(document.getElementById(idPrefix + 'region')),
        tdrs,
        getSingleSelectValue(document.getElementById(idPrefix + 'year')),
        getSingleSelectValue(document.getElementById(idPrefix + 'month')),
        weekRangeStart,
        weekRangeEnd,
        showWeekly,
        mmLongReports,
        mmShortReports,
        corporateSalesCalls,
        schoolSalesCalls
    )
}