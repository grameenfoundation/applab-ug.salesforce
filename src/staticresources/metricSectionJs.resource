var updateIds = [];
var updateMetricIds = [];
var inUpdateMode = false;

function enableEditMode(force) {

    if (force) {
        inUpdateMode = false;
    }

    // Loop through all the metric ids and toggle the visibility
    var metricLength = updateMetricIds.length
    if (metricLength == 0) {
        addError('No metrics are displayed on this page so you cannot enter Update Mode');
        addErrorViaSF();
        return;
    }
    for (var i = 0; i < metricLength; i++) {
        if (inUpdateMode) {
            j$('#' + updateMetricIds[i]).css('visibility', 'hidden');
        }
        else {
            j$('#' + updateMetricIds[i]).css('visibility', 'visible');
        }
    }

    // Loop through the update links and change their text
    var updateLength = updateIds.length
    for (var i = 0; i < updateLength; i++) {
        if (inUpdateMode) {
            j$('#' + updateIds[i] + '_update').html('Enter Update Mode');
        }
        else {
            j$('#' + updateIds[i] + '_update').html('Leave Update Mode');
        }
    }

    // Indicate the mode now in
    inUpdateMode = !inUpdateMode;
    return false;
};

// Open the page to show the break down of a metric
function openBreakDownWindow(url, id, currentDate) {
    url = url + '?currentDate=' + currentDate + '&id=' + id;
    openNewWindow(url);
};

// Show the modal
function openUpdateModal(modalId, id, refreshAction) {

    // Use javascript remoting to get the metric details
    UpdateMetricComponentController.getMetricData(id, function(result, event) {
        if (event.status) {
            j$('#updateModalProjectedValue').val(result.Projected_Value__c);
            j$('#updateModalManualValue').val(result.Manual_Value__c);
            j$('#updateModalMetricId').val(result.Id);
            j$('#updateModalRefreshSection').val(refreshAction + '_Table');
            j$('#updateModalComment').html(result.Comment__c);
        }
        else if (event.type === 'exception') {
            addError(event.message);
            addErrorViaSF();
        } else {
            addError(event.message);
            addErrorViaSF();
        }
    }, {escape:true});

    // Get the y axis scroll bar offest
    var yOffset = window.pageYOffset;
 
    //Get the screen height and width
    var maskHeight = j$('#bodyTable').height();
    var maskWidth = j$('#bodyTable').width();

    // Set height and width to mask to fill up the whole screen
    j$('#updateMask').css({'width':maskWidth,'height':maskHeight});

    // Transition effect
    j$('#updateMask').fadeIn("fast");
    j$('#updateMask').fadeTo("fast",1);

    // Get the window height and width
//  var winH = j$(window).height();
//  var winW = j$(window).width();
    var bodyTableHeight = j$('#bodyTable').height();
    var winH = j$(window).height();
    if (bodyTableHeight < winH) {
        winH = bodyTableHeight;
    }
    var winW = j$('#bodyTable').width();

    var topPoint = ((winH/2)+yOffset)-j$('#' + modalId).height()/2;
    if ((topPoint + j$('#' + modalId).height()) > winH) {
        topPoint = ((winH/2)+yOffset-100)-j$('#' + modalId).height()/2;
    }

    // Set the popup window to center
    j$('#' + modalId).css("position","absolute");
    j$('#' + modalId).css('top',  topPoint);
    j$('#' + modalId).css('left', winW/2-j$('#' + modalId).width()/2);

    // Transition effect
    j$('#' + modalId).fadeIn("fast"); 
};

// Close the modal
function closeUpdateModal() {
    j$('#updateMask').hide();
    j$('.window').hide();
};

function assignUpdateModalFunctions() {




    // If save button is clicked
    j$('#updateSaveButton').click(function (e) {

        closeUpdateModal();
        openGenericModal('genericDialog', 'Saving updated metric, please wait');

        //Cancel the link behavior
        e.preventDefault();

        // Validate the input
        var valid = true;
        var comment = j$('#updateModalComment').html();
        var man = j$('#updateModalManualValue').val();
        if (man != '' && isNaN(man)) {
            addError('Manual Value must be a valid integer or left blank');
            valid = false;
        }
        var proj = j$('#updateModalProjectedValue').val();
        if (proj != '' && isNaN(proj)) {
            addError('Target Value must be a valid integer or left blank');
            valid = false;
        }
        if (!valid) {
            addErrorViaSF();
            closeUpdateModal();
            closeGenericModal();
            return false;
        }

        // Use javascript remoting to save the metric details
        UpdateMetricComponentController.saveMetricData(
            j$('#updateModalMetricId').val(),
            comment,
            man,
            proj,
            function(result, event) {
                if (event.status) {

                    // Call refresh on the section that needs refreshing
                    var func = window[j$('#updateModalRefreshSection').val()];
                    func();
                }
                else if (event.type === 'exception') {
                    addError(event.message);
                    addErrorViaSF()
                } else {
                    addError(event.message);
                    addErrorViaSF()
                }
            },
            {escape:true}
        );
    });

    // If close button is clicked
    j$('#updateCloseButton').click(function (e) {

        //Cancel the link behavior
        e.preventDefault();
        closeUpdateModal();
    });

    // If updateMask is clicked
    //j$('#updateMask').click(function () {
    //    j$(this).hide();
    //    j$('.window').hide();
    //});
};

// Open Edit modal for a metric
function openEditWindow(id, refreshAction) {
    openUpdateModal('updateDialog', id, refreshAction);
};

// Open a window to a standard sObject tab
function openNewWindow(url) {
    popup = window.open(url,"_blank");
    popup.focus();
};