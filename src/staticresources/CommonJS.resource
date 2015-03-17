/**
 *  The common javascript shared by visualforce pages
 *  Name of file in salesforce common.js
 */
function countMultipleSelectEntries(field) {

    val = 0;
    for (i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            val++;
        }
    }
    return val;
}

function getMultipleSelectValue(field) {

    val = null;
    for (i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            if(val == null) {
                val = field[i].value;
            }
            else {
                val += ',';
                val += field[i].value;
            }
        }
    }
    return val;
}

function getMultipleSelectText(field) {

    val = null;
    for (i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            if (val == null) {
                val = field[i].text;
            }
            else {
                val += ',';
                val += field[i].text;
            }
        }
    }
    return val;
}
<<<<<<< HEAD

function getMultipleSelectValue(field) {

    val = null;
    for (i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            if(val == null) {
                val = field[i].value;
            }
            else {
                val += ',';
                val += field[i].value;
            }
        }
    }
    return val;
}

function getMultipleSelectText(field) {

    val = null;
    for (i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            if (val == null) {
                val = field[i].text;
            }
            else {
                val += ',';
                val += field[i].text;
            }
        }
    }
    return val;
}

function getSingleSelectValue(field) {

    for(i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            return field[i].value;
        }
    }
    return null;
}

function getSingleSelectText(field) {

    for(i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            return field[i].text;
        }
    }
    return null;
}

function showErrorMsg(msg, bool) {

    var div = document.getElementById('infoRow');
    var elem = document.getElementById('errorMsg');

    // Show the error msg
    if (bool) {
        elem.innerHTML = msg;
        elem.className = 'errorMessage';
        toggleDisplay(div, 'block');
    }
    else {
        elem.innerHTML = '';
        elem.className = '';
        toggleDisplay(div, 'none');
    }
}

function toggleDisplay(elem, style) {
    elem.style.display = style;
}

function scrollTo(hash) {
    location.hash = "#" + hash;
}

function toggleClass(elem, classToAdd) {
    if (elem != null) {
        elem.toggleClass(classToAdd);
    }
}

function addClassToStart(elem, classToAdd) {
    var existingClasses = elem.className;
    elem.className = classToAdd + ' ' + existingClasses;
}

function makeStringJQueryOK(string) {
    return string.replace(/:/g, '\\:');
}

// Open the standard page for a Salesforce Record using the ID
function openStandardPage(id, newTab) {

    var type = "_parent";
    if (newTab) {
        type = "_blank";
    }
    popup = window.open("/" + id, type);
    popup.focus();
}

function validateNumber(elem) {

    var target = elem.value;
    if (target == '' || isNaN(target)) {
        return false;
    }
    return true;
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

// Remove conflict for jQuery
=======

function getSingleSelectValue(field) {

    for(i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            return field[i].value;
        }
    }
    return null;
}

function getSingleSelectText(field) {

    for(i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            return field[i].text;
        }
    }
    return null;
}

function showErrorMsg(msg, bool) {

    var div = document.getElementById('infoRow');
    var elem = document.getElementById('errorMsg');

    // Show the error msg
    if (bool) {
        elem.innerHTML = msg;
        elem.className = 'errorMessage';
        toggleDisplay(div, 'block');
    }
    else {
        elem.innerHTML = '';
        elem.className = '';
        toggleDisplay(div, 'none');
    }
}

function toggleDisplay(elem, style) {
    elem.style.display = style;
}

function scrollTo(hash) {
    location.hash = "#" + hash;
}

function toggleClass(elem, classToAdd) {
    if (elem != null) {
        elem.toggleClass(classToAdd);
    }
}

function addClassToStart(elem, classToAdd) {
    var existingClasses = elem.className;
    elem.className = classToAdd + ' ' + existingClasses;
}

function makeStringJQueryOK(string) {
    return string.replace(/:/g, '\\:');
}

// Open the standard page for a Salesforce Record using the ID
function openStandardPage(id, newTab) {

    var type = "_parent";
    if (newTab) {
        type = "_blank";
    }
    popup = window.open("/" + id, type);
    popup.focus();
}

function validateNumber(elem) {

    var target = elem.value;
    if (target == '' || isNaN(target)) {
        return false;
    }
    return true;
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

// Remove conflict for jQuery
>>>>>>> origin/ci
var j$ = jQuery.noConflict();