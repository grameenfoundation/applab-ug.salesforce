/**
 * Container class that holds the map markers for the NAADS/ATAAS dashboard map parameters
 *
 */
public with sharing class NaadsMapMarkers {

    /**
     * Class that holds the map markers for the NAADS/ATAAS dashboard AASP map parameters
     *
     */
    public with sharing class NaadsAaspMarker extends MapMarkers {
    
        private Person__c NaadsAasp;
        private String parentRegistered;
        
        public String getParentRegistered() {
            return this.parentRegistered;
        }
      
        public void setParentRegistered(String value) {
            this.parentRegistered = value;
        }
      
        public NaadsAaspMarker(Person__c NaadsAasp) {
          this.NaadsAasp = NaadsAasp;
          this.setLatitude(NaadsAasp.GPS_Location_N__c);
          this.setLongitude(NaadsAasp.GPS_Location_E__c);
          this.setMarkerTitle(NaadsAasp.Name);
          this.setDefaultColour('Blue');
        }
        
       /**
        * Return the content string that will be displayed when a user clicks on a marker on the map
        *
        *
        * @ return - A string that is displayed on the map
        */
        public override String getMarkerInfoContentString() {     
            String content = this.NaadsAasp.Name + '<br />' +
                getGender(this.NaadsAasp.Gender__c) + '<br />' +
                getLocation();

            PageReference ref = new PageReference('/apex/ExpandedDashboardVisual?type=map&id='+ApexPages.currentPage().getParameters().get('id')+'&focus='+this.NaadsAasp.Id);
            content += ' <a href="' + ref.getUrl() + '" target="_blank">View areas visited</a>';
            return content;
        }
      
        /**
        * Return the content string that has the parish and village name o
        *
        *
        * @ return - A string that contains the location details of the AASP
        */
        public override String getLocation() {
            String location = '';
            if (this.NaadsAasp.Parish__c != null) {
                location = 'Parish: ' + this.NaadsAasp.Parish__c + '<br />';
            }
            if (this.NaadsAasp.Village__c != null) {
                location = location + 'Village: ' + this.NaadsAasp.Village__c + '<br />';
            }
            if (this.NaadsAasp.Subcounty__r.Display_Name__c != null) {
                location = location + 'Sub-county: ' + this.NaadsAasp.Subcounty__r.Display_Name__c + '<br />';
            }
            if (this.NaadsAasp.District__r.Name != null) {
                location = location + 'District: ' + this.NaadsAasp.District__r.Name + '<br />';
            }
            return location;
        }
      
       /**
        *  Generate the marker name for this map marker
        *  This will also set the colour of the marker if the splitter is of a certain value
        *
        *  @param splitter - The field used to split the markers into different colours
        */
        public override void generateMarkerName(String splitter) {

            String fieldValue = '';
            setColour(getDefaultColour());
    
            // Set the colours for a gender split
            if (splitter.equals('Gender')) {
                fieldValue = this.NaadsAasp.Gender__c;
                setColour('Pink');
                if (fieldValue == null) {
                    setColour('Black');
                    fieldValue = 'Missing';
                }
                else if (fieldValue.equals('Male')) {
                    setColour('Blue');
                }
            }
            setMarkerName(joinMarkerName('', '', fieldValue));
        }
    }
}