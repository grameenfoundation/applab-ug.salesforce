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

function getSingleSelectValue(field) {

    for(i = 0; i < field.length; i++) {
        if(field[i].checked || field[i].selected) {
            return field[i].value;
        }
    }
    return null;
}

function showErrorMsg(msg, bool) {

    div = document.getElementById('info');
    elem = document.getElementById('errorMsg');

    // Show the error msg
    if (bool) {
        elem.innerHTML = msg;
        toggleDisplay(div, 'block');
    }
    else {
        elem.innerHtml = '';
        toggleDisplay(div, 'none');
    }
}

function toggleDisplay(elem, style) {
    elem.style.display = style;
}