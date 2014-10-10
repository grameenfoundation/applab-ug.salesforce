public with sharing class MbugoHelpers {

	public static final String ORG_NAME = 'MBUGO';


	public static String getSubcounties(){
        String inclause =
                ' AND '                                             +
                    'District__c IN ('                              +
                        'SELECT '                                   +
                            'District__c '                          +
                        'FROM '                                     +
                            'Organisation_District_Association__c ' +
                        'WHERE '                                    +
                            'Organisation__r.Name = \'MBUGO\''       +
                    ') ';
        return 'SELECT Id, '                    +
                    'Display_Name__c, '         +
                    'District__c '              +
                'FROM Subcounty__c '            +
                'WHERE District__c != NULL '    +
                '   AND  District__c != \'\' '  +
                    inclause                    +
                'ORDER BY Display_Name__c ';
    }





    public static List<MetricDataWrapper> getFarmersReachedData()
    {
        List<MetricDataWrapper> farmersReachedData = new List<MetricDataWrapper>();

        M_E_Metric_Data__c metricData;
       
        
        Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'Mbugo CKWs\' and Person__r.Type__c=\'CKW\'');

        List<String> personIds = new List<String>();
        for(Person_Group_Association__c p : associations) {
            personIds.add(p.Person__r.Id);
        }

        //These are the ckw person ids

    List<Farmer__c> farmersRegisteredByMbugoCkws = [select Registered_by__C, Person__r.id, Person__r.Gender__c, Person__r.First_Name__c, Person__r.Last_Name__c from Farmer__c where Registered_by__C in :personIds and Person__r.First_Name__c<>'Not Registered'  limit 10000];

    MetricDataWrapper farmersReachedMetricWrapper = new MetricDataWrapper();
    farmersReachedMetricWrapper.setLabel('Total Farmers Reached');
    farmersReachedMetricWrapper.setCurrentRealValue(0);


    MetricDataWrapper maleFarmersReachedMetricWrapper = new MetricDataWrapper();
    maleFarmersReachedMetricWrapper.setLabel('Total Male Farmers Reached');
    maleFarmersReachedMetricWrapper.setCurrentRealValue(0);


    MetricDataWrapper femaleFarmersReachedMetricWrapper = new MetricDataWrapper();
    femaleFarmersReachedMetricWrapper.setLabel('Total Female Farmers Reached');
    femaleFarmersReachedMetricWrapper.setCurrentRealValue(0);

    Decimal totalFarmerCount = 0;
    Decimal totalMaleFarmerCount = 0;
    Decimal totalFemaleFarmerCount = 0;

    for(Farmer__c farmer : farmersRegisteredByMbugoCkws)
    {
        totalFarmerCount += 1;

        if('male'.equalsIgnoreCase(farmer.Person__r.Gender__c))
        {
            totalMaleFarmerCount += 1;
        }
        else {
            totalFemaleFarmerCount += 1;
        }
    }

    farmersReachedMetricWrapper.setCurrentRealValue(totalFarmerCount);
    maleFarmersReachedMetricWrapper.setCurrentRealValue(totalMaleFarmerCount);
    femaleFarmersReachedMetricWrapper.setCurrentRealValue(totalFemaleFarmerCount);

    List<MetricDataWrapper> wrapper = new List<MetricDataWrapper> {farmersReachedMetricWrapper, maleFarmersReachedMetricWrapper, femaleFarmersReachedMetricWrapper};
    
    return wrapper;
    }



    public static MetricMapWrapper[] getFOMapMarkers()
    {
    	//Field officers
    	Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
            Mbugo_Field_Officer__c[] fieldOfficers = [SELECT Person__r.Id, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c, Person__r.First_Name__c, Person__r.Last_Name__c from Mbugo_Field_Officer__C];
            for (Mbugo_Field_Officer__c fo : fieldOfficers) {

                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('CKW', '00FF11', fo.Person__r.Id, true);
                marker.gpsLatitude = fo.Person__r.GPS_Location_N__c;
                marker.gpsLongitude = fo.Person__r.GPS_Location_E__c;
                
                
                String profile = '<div width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden">Field Officer Name: '+fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c+'<br/>';
                    //Show CKWs under this field officer
                    Mbugo_CKW__c[] mbugoCkws = [SELECT Person__r.First_Name__c, Person__r.Last_Name__c from Mbugo_CKW__c where Mbugo_Field_Officer__r.Person__r.Id =:fo.Person__r.Id];
                    if(mbugoCkws.size() == 0) {
                        profile += 'Field officer has no CKWs attached';
                    }
                    else {
                        profile += '<hr><b>Ckws attached to FO</b><br/>';
                        for (Mbugo_CKW__c gckw : mbugoCkws) {
                            profile += gckw.Person__r.First_Name__c + ' '+ gckw.Person__r.Last_Name__c +'<br/>';

                        }
                    }
                    profile += '</div>';
                
                marker.addName(profile);
                marker.markerTitle = fo.Person__r.First_Name__c+' '+fo.Person__r.Last_Name__c;
                markers.put(fo.Person__r.Id, marker);
            }

            return markers.values();
    }



    public static MetricMapWrapper[] getCKWMapMarkers()
    {
      Map<String, MetricMapWrapper> markers = new Map<String, MetricMapWrapper>();
      Person_Group_Association__c[] associations = Database.query('select id, Person__c, Group__c,  Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c  from Person_Group_Association__c where Group__r.Name=\'Mbugo Ckws\' and Person__r.Type__c=\'CKW\'');
        List<String> personIds = new List<String>();
        for(Person_Group_Association__c assoc : associations) {
            personIds.add(assoc.Person__r.Id);
        }

        
        CKW__c[] ckws = [SELECT id, Name, Person__r.First_Name__c, Person__r.Last_Name__c, Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c from CKW__c where Person__r.Id in :personIds];
            for (CKW__c ckw : ckws) {
                MetricMapWrapper marker = null;
                marker = new MetricMapWrapper('CKW', '0000FF', ckw.Id, true);
                marker.gpsLatitude = ckw.Person__r.GPS_Location_N__c;
                marker.gpsLongitude = ckw.Person__r.GPS_Location_E__c;
                
                PageReference ref = new PageReference('/apex/CkwDetailMini?id='+ckw.Id);
                String content = '<iframe src="'+ ref.getUrl()+'" frameBorder="0" width="304px" height="500px" scrolling="no" seamless="seamless" style="overflow:hidden"></iframe>';

                
                marker.addName(content);
                marker.markerTitle = ckw.Person__r.First_Name__c+' '+ckw.Person__r.Last_Name__c;
                markers.put(ckw.Id, marker);

            }


            
            System.debug(markers.size()+' map markers found'); 
            return markers.values();
    }

}