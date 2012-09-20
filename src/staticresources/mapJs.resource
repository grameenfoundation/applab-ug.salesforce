/*
 *  The java script that is used with the map component.
 */

var mapParameters = new Object();


function initialize() {

    this.addMapOption('zoom', this.zoom);
    this.addMapOption('center', new google.maps.LatLng(this.startLat, this.startLong));

    // Calculate the position of the key
    var keyLatLng;
    if (this.zoom == 7) {
        keyLatLng = new google.maps.LatLng(0.5, 33.25);
    }
    else {
        keyLatLng = new google.maps.LatLng(this.startLat - 0.2, this.startLong + 0.2);
    }

    // Disable Zoom controls if requested
    if(this.disableControls) {
        this.addMapOption('disableDoubleClickZoom', true);
        this.addMapOption('mapTypeControl', false);
        this.addMapOption('zoomControl', false);
    }

    this.map = new google.maps.Map(document.getElementById(this.mapId), this.options);
    for (i = 0; i < this.markers.length; i++) {
        var markerUrl = "https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=" + this.markers[i].markerLabel + "|" + this.markers[i].markerColour + "|000000"
        var markerImage = new google.maps.MarkerImage(markerUrl);
        var marker = new google.maps.Marker({
            position: this.markers[i].markerCoordinates, 
            map: this.map, 
            title: this.markers[i].markerTitle,
            icon: markerImage
        });

        if(!this.disableInfoWindows) {
            attachInfoWindow(marker, this.markers[i].infoWindowContentString, this.map);
        }
    };

    if(this.keyText != "" && !this.disableKey) {
        var boxText = document.createElement("div");
        boxText.style.cssText = "opacity:0.75;width:200px;background:#FFFFFF;fontFamily:Verdana;padding:5px;fontSize:9pt;textAlign:left;border:1px solid #A8B8CF;";
        boxText.innerHTML = this.keyText  + '<br/>' + this.stats + '<br />Double click any part of the map to zoom in';
        var myOptions = {
            content: boxText,
            disableAutoPan: true,
            pixelOffset: new google.maps.Size(-25, 0),
            infoBoxClearance: new google.maps.Size(1, 1),
            position: keyLatLng,
            closeBoxURL: "",
            isHidden: false,
            pane: "mapPane",
            enableEventPropagation: true,
            alignBottom: true,
            boxStyle: {
                width:"210px",
                height:"100%"
            }
        };
        var infoLabel = new InfoBox(myOptions);
        infoLabel.open(this.map);
    }
}

function addMapMarker(marker) {
    this.markers.push(marker);
}

function addMapInfoWindow(infoWindow) {
    this.infoWindow.push(infoWindow);
}

function addMapOption(key, value) {
    this.options[key] = value;
}

// Class that represents a instance of a map
function mapDetails(mapId, lat, long, zoom, disableControls, disableInfoWindows, keyText, stats, disableKey) {

    this.mapId = mapId;
    this.markers = [];
    this.infoWindows = [];
    this.startLat = parseFloat(lat);
    this.startLong = parseFloat(long);
    this.zoom = parseFloat(zoom);
    this.disableControls = disableControls;
    this.disableInfoWindows = disableInfoWindows;
    this.keyText = keyText;
    this.stats = stats;
    this.disableKey = disableKey;
    this.map = null;
    this.options = {
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    this.initialize = initialize;
    this.addMapMarker = addMapMarker;
    this.addMapInfoWindow = addMapInfoWindow;
    this.addMapOption = addMapOption;
    this.attachInfoWindow = attachInfoWindow;
    this.setCloseWindow = setCloseWindow;
    this.setCloseWindow = setCloseWindow;
}

function addMap(key, value) {
    mapParameters[key] = value;
}

function getMap(key) {
    return mapParameters[key];
}

function addMarkerToMap(key, marker) {
    var map = getMap(key);
    map.addMapMarker(marker);
}

function attachInfoWindow(marker, contentString) {
    var infoWindow = new google.maps.InfoWindow({ content: contentString });
    google.maps.event.addListener(marker, 'click', function() {
        infoWindow.open(this.map, marker);
    });
    this.setCloseWindow(infoWindow);
};

function setCloseWindow(infoWindow) {
    google.maps.event.addListener(infoWindow, 'closeclick', this.closeMarker);
}

function closeMarker() {
    if (this.map.getZoom() <= 7) {
        this.map.panTo(new google.maps.LatLng(this.startLat, this.startLong));
    }
}

// Class that holds the data for each map marker
function markerData(gpsLatitude, gpsLongitude, title, colour, contentString, label) {

    this.markerCoordinates = new google.maps.LatLng(gpsLatitude, gpsLongitude);
    this.markerTitle = title;
    this.markerColour = colour;
    this.infoWindowContentString = contentString
    this.markerLabel = label
};

function initializeAll(extended) {
    for (var key in mapParameters) {
        if (mapParameters.hasOwnProperty(key)) {
            initializeMap(key, extended);
        }
    }
};

function initializeMap(key, extended) {
    mapParameters[key].initialize();

    // If this is for the extended page then centralise the map
    if (extended == 'true') {
        var winW= j$('#mapExtendedDiv').width();
        j$('#' + mapParameters[key].mapId).css('left', winW/2-j$('#' + mapParameters[key].mapId).width()/2);
        j$('#mapRefresh').css('margin-left', '45%');
    }
}

function getWindowDimensions() {

    var myWidth = 0, myHeight = 0;
    if (typeof(window.innerWidth) == 'number') {

        //Non-IE
        myWidth = window.innerWidth;
        myHeight = window.innerHeight;
    }
    else if (document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {

        //IE 6+ in 'standards compliant mode'
        myWidth = document.documentElement.clientWidth;
        myHeight = document.documentElement.clientHeight;
    }
    else if(document.body && (document.body.clientWidth || document.body.clientHeight)) {

        //IE 4 compatible.
        myWidth = document.body.clientWidth;
        myHeight = document.body.clientHeight;
    }
    return myHeight + ":" + myWidth;
};

function getUrlParam(name) {
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( window.location.href );
    if ( results == null ) {
        return "";
    }
    else {
        return results[1];
    }
}

// This specifically converts kapchorwa data to dd
// From Example: N01 23.2345 (NDD MM SS.SSSSS...)
// Note: this function assumes all the data is unsigned and represents positive numbers
// Converts gps from Degress, Minutes, Seconds format to the Decimal format that google maps api expects
function dmsToDd(dmsString) {

    // Try to split into Degrees, Minutes, Seconds
    // Trim
    dmsString = dmsString.replace(/^\s+|\s+$/g,'');

    // 1. Get rid of E or N
    dmsString = dmsString.replace('E','');
    dmsString = dmsString.replace('N','');

    // Split on decimal space
    dmsStringParts = dmsString.split('.');

    var seconds = '';
    if(!isNaN(dmsStringParts[1])) {

        // We've got seconds. Insert a decimal point after the first two characters 
        seconds = dmsStringParts[1].substr(0,2);
        secondsDecimalPoints = dmsStringParts[1].substring(2,dmsStringParts.length - 1);
        seconds = seconds + '.' + secondsDecimalPoints;
    }

    var degrees = '';
    var minutes = '';
    dmsStringParts[0] = dmsStringParts[0].replace(/^\s+|\s+$/g,'');

    // Make the last two the minutes and the rest the degrees
    minutes = dmsStringParts[0].substring(dmsStringParts[0].length - 2, dmsStringParts[0].length - 1);
    degrees = dmsStringParts[0].substring(0, dmsStringParts[0].length - 2);

    // Now do the converstion
    var degrees = parseFloat(degrees.replace(/^\s+|\s+$/g,''));
    var minutes = parseFloat(minutes.replace(/^\s+|\s+$/g,''));
    var seconds = parseFloat(seconds.replace(/^\s+|\s+$/g,''));
    var dd;
    if(!isNaN(degrees) && !isNaN(minutes) && !isNaN(seconds)) {
        dd = degrees + (minutes / 60) + (seconds / 3600)
    }

    return dd + '';
}

function openMapInNewWindow(url, id) {
    url = url + '?type=map&id=' + id;
    popup = window.open(url,"_blank");
    popup.focus();
}