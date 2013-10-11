/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  Holds map markers for the EADD dashboard map parameters
 *
 **/
public with sharing class EADDMapMarkers extends MapMarkers {

	private EADD_Hub__c hub;
	
    public EADDMapMarkers(EADD_Hub__c hub) {
        this.hub = hub;
        this.setLatitude(hub.Latitude__c);
        this.setLongitude(hub.Longitude__c);
        this.setMarkerTitle(hub.Name__c);
        setDefaultColour('Green');
    }
    
    // Generate the content string for a Hub
    public override String getMarkerInfoContentString() {

        String content = 	'<table border="0">'										+
							'	<tr>'													+
							'		<td>Hub Details</td>'								+
							'		<td></td>'											+
							'	</tr>'													+
							'	<tr>'													+
							'		<td>Name:</td>'										+
							'		<td>' + hub.Name__c + '</td>'						+
							'	</tr>'													+
							'	<tr>'													+
							'		<td>Utilization level: </td>'						+
							'		<td>' + hub.Hub_capacity_utilization__c + '</td>'	+
							'	</tr>'													+
							'	<tr>'													+
							'		<td>Coverage(km)</td>'								+
							'		<td>' + hub.Radius_Covered__c + '</td>'				+
							'	</tr>'													+
							'</table>';          
        return content;
    }
}