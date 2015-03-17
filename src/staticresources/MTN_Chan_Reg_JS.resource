<<<<<<< HEAD
function validateNumber(elem) {

    var target = elem.value;
    if (target == '' || isNaN(target)) {
        return false;
    }
    return true;
}

function validateForm() {

    var success = true;
    var length;
    if (getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone')) == 'No') {
        if (!validateNumber(document.getElementById(idPrefix + 'phoneNumber'))) {
            addError('Phone number must be a valid phone number. Do not include country code.');
            success = false;
        }
        else {
            length = document.getElementById(idPrefix + 'phoneNumber').value.length;
            if (length < 10 || length > 12) {
                addError('Phone number needs to be 10 digits long.');
                success = false;
            }
        }
        if (!validateNumber(document.getElementById(idPrefix + 'phoneImei'))) {
            addError('IMEI must be a valid number.');
            success = false;
        }
        else {
            length = document.getElementById(idPrefix + 'phoneImei').value.length;
            if (length != 15) {
                addError('IMEI be 15 digits long.');
                success = false;
            }
        }
        if (!validateNumber(document.getElementById(idPrefix + 'phonePurchaseValue'))) {
            addError('Purchase valse must be in USD and a valid number.');
            success = false;
        }
    }
    if (!success) {
        addErrorViaSF();
    }
    return success;
}

function submitMtnChannelsRegForm() {

    if (!validateForm()) {
        addErrorViaSF();
        return false;
    }
    openModal('dialog', 'Registering ASR');
    clearErrorsFromPage();
    submitForm(
        getSingleSelectValue(document.getElementById(idPrefix + 'region')),
        document.getElementById(idPrefix + 'firstName').value,
        document.getElementById(idPrefix + 'middleName').value,
        document.getElementById(idPrefix + 'lastName').value,
        document.getElementById(idPrefix + 'emailAddress').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'gender')),
        document.getElementById(idPrefix + 'dob').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone')),
        getSingleSelectValue(document.getElementById(idPrefix + 'existingPhone')),
        document.getElementById(idPrefix + 'phoneImei').value,
        document.getElementById(idPrefix + 'phoneNumber').value,
        document.getElementById(idPrefix + 'phoneSerialNumber').value,
        document.getElementById(idPrefix + 'phonePurchaseValue').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'phoneType'))
    );
}

function showPhoneDetails(elem) {

    var value = getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone'));
    if (value == 'Yes') {
        document.getElementById('submitSection').style.display = 'block';
        document.getElementById('existingPhoneFormSection').style.display = 'block';
        document.getElementById('newPhoneFormSection').style.display = 'none';
    }
    else if (value == 'No') {
        document.getElementById('submitSection').style.display = 'block';
        document.getElementById('newPhoneFormSection').style.display = 'block';
        document.getElementById('existingPhoneFormSection').style.display = 'none';
    }
    else {
        addError('You must select if you would like to use an existing phone or not');
        addErrorViaSF();
    }
}
=======
function validateNumber(elem) {

    var target = elem.value;
    if (target == '' || isNaN(target)) {
        return false;
    }
    return true;
}

function validateForm() {

    var success = true;
    var length;
    if (getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone')) == 'No') {
        if (!validateNumber(document.getElementById(idPrefix + 'phoneNumber'))) {
            addError('Phone number must be a valid phone number. Do not include country code.');
            success = false;
        }
        else {
            length = document.getElementById(idPrefix + 'phoneNumber').value.length;
            if (length < 10 || length > 12) {
                addError('Phone number needs to be 10 digits long.');
                success = false;
            }
        }
        if (!validateNumber(document.getElementById(idPrefix + 'phoneImei'))) {
            addError('IMEI must be a valid number.');
            success = false;
        }
        else {
            length = document.getElementById(idPrefix + 'phoneImei').value.length;
            if (length != 15) {
                addError('IMEI be 15 digits long.');
                success = false;
            }
        }
        if (!validateNumber(document.getElementById(idPrefix + 'phonePurchaseValue'))) {
            addError('Purchase valse must be in USD and a valid number.');
            success = false;
        }
    }
    if (!success) {
        addErrorViaSF();
    }
    return success;
}

function submitMtnChannelsRegForm() {

    if (!validateForm()) {
        addErrorViaSF();
        return false;
    }
    openModal('dialog', 'Registering ASR');
    clearErrorsFromPage();
    submitForm(
        getSingleSelectValue(document.getElementById(idPrefix + 'region')),
        document.getElementById(idPrefix + 'firstName').value,
        document.getElementById(idPrefix + 'middleName').value,
        document.getElementById(idPrefix + 'lastName').value,
        document.getElementById(idPrefix + 'emailAddress').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'gender')),
        document.getElementById(idPrefix + 'dob').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone')),
        getSingleSelectValue(document.getElementById(idPrefix + 'existingPhone')),
        document.getElementById(idPrefix + 'phoneImei').value,
        document.getElementById(idPrefix + 'phoneNumber').value,
        document.getElementById(idPrefix + 'phoneSerialNumber').value,
        document.getElementById(idPrefix + 'phonePurchaseValue').value,
        getSingleSelectValue(document.getElementById(idPrefix + 'phoneType'))
    );
}

function showPhoneDetails(elem) {

    var value = getSingleSelectValue(document.getElementById(idPrefix + 'useExistingPhone'));
    if (value == 'Yes') {
        document.getElementById('submitSection').style.display = 'block';
        document.getElementById('existingPhoneFormSection').style.display = 'block';
        document.getElementById('newPhoneFormSection').style.display = 'none';
    }
    else if (value == 'No') {
        document.getElementById('submitSection').style.display = 'block';
        document.getElementById('newPhoneFormSection').style.display = 'block';
        document.getElementById('existingPhoneFormSection').style.display = 'none';
    }
    else {
        addError('You must select if you would like to use an existing phone or not');
        addErrorViaSF();
    }
}
>>>>>>> origin/ci
