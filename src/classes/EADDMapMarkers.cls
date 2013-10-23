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
        setColour('Yellow');
    }
    
    // Generate the content string for a Hub
    public override String getMarkerInfoContentString() {  
		String content = 	'<div>'																		+
							'	&nbsp;&nbsp;Hub Details <br/>'											+
							'	Name:&ensp;' + hub.Name__c + '<br/>'									+
							'	Utilization level:&ensp;' + hub.Hub_capacity_utilization__c + '<br/>'	+
							'	Coverage(km):&ensp;' + hub.Radius_Covered__c + '<br/>'					+
							'</div>';
        return content;
    }
}