//Namespace class for the classes that generate the markers for all the NAADS map parameters
public with sharing class NaadsMapMarkerSources {

    //Returns a list of the AASPs
    public with sharing class AASPs implements MapComponentController.IMapMarkerSource {
        
        // Variables that deal with setting the colours of the map markers
        private   Map<String, String> defaultColourMap;
        Transient Map<String, String> colourMap = new Map<String, String>();
        Transient Map<String, String> usedColourMapTypes = new Map<String, String>();
        Transient Map<String, String> usedColourMapNames  = new Map<String, String>();
        Transient Set<String> usedColours;    
        
        /**
         * Generates the collection of map markers that will be displayed on the map
         *
         * @param parameters - The map of parameters that was passed in to the page where the key is the parameter name
         *
         * @return - A List of map markers to be displayed on the map
        */
        public List<MapMarkers> loadMapMarkers(Map <String, String> parameters) {
            //List of where clauses that will be used to modify the select query
            List<String> whereClauses = new List<String>();
            String whereClause;
            //This variable will be set when one AASP has been selected to be the focus of the map.
            String focus = parameters.get('focus');
            
            Map<String, MapMarkers> markers = new Map<String, MapMarkers>();
            
            //Initialise the map of available colours
            setDefaultColourMap();
            
            String baseQuery = 
                    'SELECT ' +
                        'Id, '   +
                        'Name, ' +
                        'Gender__c,'    +
                        'Parish__c, '  +
                        'Village__c, ' +
                        'District__r.Name, ' +
                        'Subcounty__r.Display_Name__c, ' +
                        'GPS_Location_N__c,' + 
                        'GPS_Location_E__c ' +
                    'FROM ' +
                        'Person__c ';
            
            whereClauses.add(SoqlHelpers.addInWhereClause('Type__c', false, 'AASP', null, true));
            
            if(String.isNotEmpty(focus)) {
                whereClauses.add(SoqlHelpers.addInWhereClause('Id', false, focus, null, true));
            }
            if (whereClauses.size() > 0) {
                whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
            }
            
            String query = baseQuery + whereClause;
            System.debug(LoggingLevel.INFO, query);
            
            Person__c[] persons = database.query(query);
            
            for (Person__c person : persons) {
                // Dont include if we are missing the location
                if (person.GPS_Location_N__c == null || person.GPS_Location_E__c == null) {
                    continue;
                }
                
                //Create the marker
                NaadsMapMarkers.NaadsAaspMarker marker = new NaadsMapMarkers.NaadsAaspMarker(person);
                marker.generateMarkerName('Gender');
                marker.setMarkerColour(getColour(marker.getColour(), marker.getMarkerName()));
                markers.put(person.Id, marker);
            }
            persons.clear();
            
            //Add the client locations for the AASP if the focus is defined
            if(String.isNotEmpty(focus)) {
                Client_Location__c[] locations = Database.query(getClientLocationMarkersQuery(focus));
                for (Client_Location__c location : locations) {
                    //Skip the location if it doesn't have GPS co-ordinates defined
                    if (location.Latitude__c == null || location.Longitude__c == null) {
                        continue;
                    }
                
                    //Create the marker and add it to the marker map
                    ClientLocationMapMarker marker = new ClientLocationMapMarker(location);
                    marker.generateMarkerName(location.Type__c);
                    marker.setMarkerColour(getColour(marker.getColour(), marker.getMarkerName()));
                    markers.put(location.Id, marker);
                }
                locations.clear();
            }
            return markers.values();
        }
        
        /**
         * Generates the SOQL query used to retrieve the client locations
         *
         * @param focus - The ID of the Person__c whose Client_Locations__c are required
         *
         * @return - A SOQL query that can be used to retrieve the required locations
        */
         private String getClientLocationMarkersQuery(String focus) {
    
            String baseQuery = 
                    'SELECT ' +
                        'Name, '             +
                        'Id, '               +
                        'Display_Name__c, '  +
                        'Description__c, '   +
                        'Latitude__c, '      +
                        'Longitude__c, '     +
                        'Type__c, '          +
                        'District__r.Name, ' +
                        'Account__r.Name, '  +
                        'Person__c, '        +
                        'Person__r.First_Name__c, ' +
                        'Person__r.Last_Name__c, ' +
                        'Person__r.Subcounty__r.Display_Name__c ' +
                    'FROM ' +
                        'Client_Location__c ';
    
            List<String> whereClauses = new List<String>();
            whereClauses.add(SoqlHelpers.addInWhereClause('Person__r.Id', false, focus, null, true));
            String whereClause = '';
            
            if (whereClauses.size() > 0) {
                whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
            }
            
            String query = baseQuery + whereClause;
            System.debug(LoggingLevel.INFO, query);
            return query;
        }
        
         // Set the colours up that can be used for dynamic assignment of map markers. Will override the default colour if that colour is already in use
        // by another category of map marker
        private void setDefaultColourMap() {
    
            this.usedColourMapTypes = new Map<String, String>();
            this.usedColourMapNames = new Map<String, String>();
            this.defaultColourMap = new Map<String, String>();
            this.colourMap = new Map<String, String>();
            this.defaultColourMap.put('Black', '000000');
            this.defaultColourMap.put('Grey', '999999');
            this.defaultColourMap.put('Light_Grey', 'CCCCCC');
            this.defaultColourMap.put('White', 'FFFFFF');
            this.defaultColourMap.put('Pink', 'FF6699');
            this.defaultColourMap.put('Red', 'FF0000');
            this.defaultColourMap.put('Orange', 'FF6600');
            this.defaultColourMap.put('Yellow', 'FFFF00');
            this.defaultColourMap.put('Green', '00CC00');
            this.defaultColourMap.put('Blue', '000099');
            this.defaultColourMap.put('Purple', '990099');
            this.defaultColourMap.put('Light_Green', '00FF00');
            this.defaultColourMap.put('Light_Blue', '0000FF');
            this.defaultColourMap.put('Dark_Green', '009900');
            this.defaultColourMap.put('Dark_Blue', '000033');
        }
    
        /**
         *  Get the colour for a marker. If the marker doesn't have the colour set already then try to assign it
         *  the ideal colour or set it to the next available colour
         *
         *  @param colourType - The ideal colour
         *  @param markerName - The name of the marker
         *
         *  @return - The hex value for the colour that has been assigned
         */
        private String getColour(String colourType, String markerName) {
    
            if ((colourMap.isEmpty()) || (colourMap.get(markerName) == null)) {
                return setColour(colourType, markerName);
            }
            return colourMap.get(markerName);
        }
    
        /**
         *  Set a colour in the colour maps. Need to check that the desired colour isn't used already
         *  If it is then set it to the next available colour of set it to brown
         *
         *  @param colourType - The ideal colour
         *  @param markerName - The name of the marker
         *
         *  @return - The hex value for the colour that has been assigned
         */
        private String setColour(String colourType, String markerName) {
    
            // Desired colour has not been assigned so assign it
            String hexCode = '';
            Boolean isNonDefault = true;
            if ((this.usedColourMapTypes.isEmpty()) || (!this.usedColourMapTypes.keySet().contains(colourType))) {
                hexCode = this.defaultColourMap.get(colourType);
            }
            else {
    
                // If all the colours are used up the assign brown
                if (this.defaultColourMap.keySet().size() == 0) {
                    hexCode = '663300';
                    isNonDefault = false;
                }
    
                // Get an unassigned colour for the marker.
                Integer i = 0;
                for (String colour : this.defaultColourMap.keySet()) {
                    if (i == 1) {
                        break;
                    }
                    hexCode = this.defaultColourMap.get(colour);
                    colourType = colour;
                }
            }
            assignColour(colourType, markerName, hexCode, isNonDefault);
            return hexCode;
        }
    
        private void assignColour(String colourType, String markerName, String hexCode, Boolean isNonDefault) {
    
            if (isNonDefault) {
                this.defaultColourMap.remove(colourType);
            }
            this.usedColourMapTypes.put(colourType, markerName);
            this.usedColourMapNames.put(markerName, colourType);
            this.colourMap.put(markerName, hexCode);
        }    
    }
}