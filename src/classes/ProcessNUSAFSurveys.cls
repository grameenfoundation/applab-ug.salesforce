/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class carries out the IG/NUSAF Surveys post-processing
 *  Its test methods are in the NUSAFDashboardTests class
 **/
public with sharing class ProcessNUSAFSurveys {
    
    /**
    *  Registers a NUSAF Visit: the location, type of visit,
    *  the date and time of visit and the trainer's name
    *
    *  @param submission - The submission object being processed
    *  @param answers    - A map containing the values for the registration
    *                       The keys are <binding>_<instance> for compatibility
    *  @param person     - The Person__c object of the CKW who submitted the form
    *
    *  @return - A three element list of Strings with the following format
    *              element 1 - Binary indicator of success (0 = fail, 1 = success)
    *              element 2 - Error message if required for the logs and tech team
    *              element 3 - Message body to the CKW if required.
    */    
    public static List<String> registerNusafActivityVisit(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c interviewer) {
        
        String trainersName = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0')).trim();
        System.debug(Logginglevel.INFO, 'Registering a visit by ' + trainersName);
        Date dateOfVisit = Date.valueOf(ProcessSubmissionHelpers.getAnswerString(answers.get('q2_0')));
        String trainingTime = ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')).trim();
        String subRegionSelectedNumber = ProcessSubmissionHelpers.getAnswerString(answers.get('q4_0'));
        
        String districtName = '';        
        //based on the answered sub-region, we get the district's answer
        String subcountySelected = '';
        //based on the answered district, we get the district's selected subcounty answer
        
        //acholi sub-region
        if(subRegionSelectedNumber.equals('1')){
            districtName = acholiDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q5_0'));
            if(districtIndex == '1'){
                //agago
                subcountySelected = agagoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q13_0')));
            } else if(districtIndex == '2'){
                //amuru
                subcountySelected = amuruSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q14_0')));
            }else if(districtIndex == '3'){
                //gulu
                subcountySelected = guluSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q15_0')));
            }else if(districtIndex == '4'){
                //kitgum
                subcountySelected = kitgumSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q16_0')));
            }else if(districtIndex == '5'){
                //lamwo
                subcountySelected = lamwoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q17_0')));
            }else if(districtIndex == '6'){
                //nwoya
                subcountySelected = nwoyaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q18_0')));
            }else if(districtIndex == '7'){
                //pader
                subcountySelected = paderSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q19_0')));
            }            
        } else if(subRegionSelectedNumber.equals('2')){
            //bukedi sub-region
            districtName = bukediDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q6_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q6_0'));
            if(districtIndex == '1'){
                //budaka
                subcountySelected = budakaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q20_0')));
            } else if(districtIndex == '2'){
                //busia
                subcountySelected = busiaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q21_0')));
            }else if(districtIndex == '3'){
                //butaleja
                subcountySelected = butalejaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q22_0')));
            }else if(districtIndex == '4'){
                //kibuku
                subcountySelected = kibukuSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q23_0')));
            }else if(districtIndex == '5'){
                //pallisa
                subcountySelected = pallisaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q24_0')));
            }else if(districtIndex == '6'){
                //tororo
                subcountySelected = tororoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q25_0')));
            }
        } else if(subRegionSelectedNumber.equals('3')){
            //bunyoro sub-region
            districtName = bunyoroDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q7_0'));
            if(districtIndex == '1'){
                //buliisa
                subcountySelected = bulisaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q26_0')));
            } else if(districtIndex == '2'){
                //masindi
                subcountySelected = masindiSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q27_0')));
            }else if(districtIndex == '3'){
                //kiryandongo
                subcountySelected = kiryandongoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q28_0')));
            }
        } else if(subRegionSelectedNumber.equals('4')){
            //elgon sub-region
            districtName = elgonDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q8_0'));
            if(districtIndex == '1'){
                //bududa
                subcountySelected = bududaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q29_0')));
            } else if(districtIndex == '2'){
                //bukwo
                subcountySelected = bukwoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q30_0')));
            }else if(districtIndex == '3'){
                //bulambuli
                subcountySelected = bulambuliSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q31_0')));
            }else if(districtIndex == '4'){
                //kapchorwa
                subcountySelected = kapchorwaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q32_0')));
            }else if(districtIndex == '5'){
                //kween
                subcountySelected = kweenSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q33_0')));
            }else if(districtIndex == '6'){
                //manafwa
                subcountySelected = manafwaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q34_0')));
            }else if(districtIndex == '7'){
                //mbale
                subcountySelected = mbaleSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q35_0')));
            }else if(districtIndex == '8'){
                //sironko
                subcountySelected = sironkoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q36_0')));
            }
        } else if(subRegionSelectedNumber.equals('5')){
            //lanog sub-region
            districtName = langoDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q9_0'));
            if(districtIndex == '1'){
                //aleptong
                subcountySelected = aleptongSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q37_0')));
            } else if(districtIndex == '2'){
                //amolatar
                subcountySelected = amolatarSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q38_0')));
            }else if(districtIndex == '3'){
                //kole
                subcountySelected = koleSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q39_0')));
            }else if(districtIndex == '4'){
                //apac
                subcountySelected = apacSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q40_0')));
            }else if(districtIndex == '5'){
                //dokolo
                subcountySelected = dokoloSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q41_0')));
            }else if(districtIndex == '6'){
                //lira
                subcountySelected = liraSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q42_0')));
            }else if(districtIndex == '7'){
                //otuke
                subcountySelected = otukeSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q43_0')));
            }else if(districtIndex == '8'){
                //oyam
                subcountySelected = oyamSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q44_0')));
            }
        } else if(subRegionSelectedNumber.equals('6')){
            //teso sub-region
            districtName = tesoDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q10_0'));
            if(districtIndex == '1'){
                //amuria
                subcountySelected = amuriaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q45_0')));
            } else if(districtIndex == '2'){
                //bukedea
                subcountySelected = bukedeaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q46_0')));
            }else if(districtIndex == '3'){
                //kaberamaido
                subcountySelected = kaberamaidoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q47_0')));
            }else if(districtIndex == '4'){
                //katakwi
                subcountySelected = katakwiSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q48_0')));
            }else if(districtIndex == '5'){
                //kumi
                subcountySelected = kumiSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q49_0')));
            }else if(districtIndex == '6'){
                //ngora
                subcountySelected = ngoraSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q50_0')));
            }else if(districtIndex == '7'){
                //serere
                subcountySelected = serereSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q51_0')));
            }else if(districtIndex == '8'){
                //soroti
                subcountySelected = sorotiSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q52_0')));
            }
        } else if(subRegionSelectedNumber.equals('7')){
            //west nile sub-region
            districtName = westNileDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q11_0'));
            if(districtIndex == '1'){
                //adjumani
                subcountySelected = adjumaniSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q53_0')));
            } else if(districtIndex == '2'){
                //arua
                subcountySelected = aruaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q54_0')));
            }else if(districtIndex == '3'){
                //koboko
                subcountySelected = kobokoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q55_0')));
            }else if(districtIndex == '4'){
                //maracha
                subcountySelected = marachaSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q56_0')));
            }else if(districtIndex == '5'){
                //moyo
                subcountySelected = moyoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q57_0')));
            }else if(districtIndex == '6'){
                //zombo
                subcountySelected = zomboSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q58_0')));
            }else if(districtIndex == '7'){
                //nebbi
                subcountySelected = nebbiSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q59_0')));
            }else if(districtIndex == '8'){
                //yumbe
                subcountySelected = yumbeSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q60_0')));
            }
        } else if(subRegionSelectedNumber.equals('8')){
            //karamoja sub-region
            districtName = karamojaDistrictsMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0')));
            String districtIndex = ProcessSubmissionHelpers.getAnswerString(answers.get('q12_0'));
            if(districtIndex == '1'){
                //abim
                subcountySelected = abimSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q61_0')));
            } else if(districtIndex == '2'){
                //kaabong
                subcountySelected = kaabongSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q62_0')));
            }else if(districtIndex == '3'){
                //kotido
                subcountySelected = kotidoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q63_0')));
            }else if(districtIndex == '4'){
                //moroto
                subcountySelected = morotoSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q64_0')));
            }else if(districtIndex == '5'){
                //napak
                subcountySelected = napakSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q65_0')));
            }else if(districtIndex == '6'){
                //nakapiripirit
                subcountySelected = nakapiripiritSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q66_0')));
            }else if(districtIndex == '7'){
                //amudat
                subcountySelected = amudatSubcountiesMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q67_0')));
            }
        }
        
        District__c[] district = [SELECT Id, Name FROM District__c WHERE Name = :districtName];
        if(district.isEmpty()){
            return new String[]{ '0', 'The district ' + districtName + ' provided is not in salesforce', 'SUPRESSMSG' };
        }
        Id districtId = district[0].Id;
        Subcounty__c[] subcounty = [SELECT
                                        Id,
                                        Display_Name__c
                                    FROM
                                        Subcounty__c
                                    WHERE
                                        Display_Name__c = :subcountySelected
                                        AND District__c = :districtId
                                    ];
        if(subcounty.isEmpty()){
            return new String[]{ '0', 'The subcounty ' + subcountySelected + ' provided is not in salesforce or the district specified', 'SUPRESSMSG' };
        }
        
        Community_Based_Trainer_Field_Visit__c visit = new Community_Based_Trainer_Field_Visit__c();
        visit.District__c =  districtId;
        visit.Subcounty__c = subcounty[0].Id;
        visit.Subregion__c = northernUgandaSubregions.get(subRegionSelectedNumber);
        visit.Date_of_Visit__c = dateOfVisit;
        visit.Time__c = trainingTime;
        visit.Interview_Latitude__c = submission.interviewLatitude;
        visit.Interview_Longitude__c = submission.interviewLongitude;
        
        Survey__c survey = [SELECT Name FROM Survey__c WHERE Id = :submission.surveyId];
        visit.Type_of_Visit__c = survey.Survey_Name__c;
        visit.Name_of_Trainer__c = trainersName;
        visit.Survey__c = survey.Id;
        visit.Person__c = interviewer.Id; 
        
        insert visit;
                
        return new String[]{ '1', 'IG/NUSAF submission successful for IMEI: ' + submission.imei, 'SUPRESSMSG' };    
    }
    
    /*
    * A map of the IG/NUSAF sub-regions
    * Based on the sub-region (question 4) chosen below, we can determine
    * which one of next questions 5, 6, 7, 8, 9, 10, 11 and 12 was answered
    */
    public static Map<String, String> northernUgandaSubregions = new Map<String, String> {
        '1' => 'Acholi',
        '2' => 'Bukedi',
        '3' => 'Bunyoro',
        '4' => 'Elgon',
        '5' => 'Lango',
        '6' => 'Teso',
        '7' => 'West Nile',
        '8' => 'Karamoja'
    };
    private static Map<String, String> acholiDistrictsMap = new Map<String, String> {
        '1' => 'agago',
        '2' => 'amuru',
        '3' => 'gulu',
        '4' => 'kitgum',
        '5' => 'lamwo',
        '6' => 'nwoya',
        '7' => 'pader'
    };      
    private static Map<String, String> bukediDistrictsMap = new Map<String, String> {
        '1' => 'budaka',
        '2' => 'busia',
        '3' => 'butaleja',
        '4' => 'kibuku',
        '5' => 'pallisa',
        '6' => 'tororo'
    }; 
    private static Map<String, String> bunyoroDistrictsMap = new Map<String, String> {
        '1' => 'bulisa',
        '2' => 'masindi',
        '3' => 'kiryandongo'
    };
    private static Map<String, String> elgonDistrictsMap = new Map<String, String> {
        '1' => 'bududa',
        '2' => 'bukwo',
        '3' => 'bulambuli',
        '4' => 'kapchorwa',
        '5' => 'kween',
        '6' => 'manafwa',
        '7' => 'mbale',
        '8' => 'sironko'
    }; 
    private static Map<String, String> langoDistrictsMap = new Map<String, String> {
        '1' => 'aleptong',
        '2' => 'amolatar',
        '3' => 'kole',
        '4' => 'apac',
        '5' => 'dokolo',
        '6' => 'lira',
        '7' => 'otuke',
        '8' => 'oyam'
    }; 
    private static Map<String, String> tesoDistrictsMap = new Map<String, String> {
        '1' => 'amuria',
        '2' => 'bukedea',
        '3' => 'kaberamaido',
        '4' => 'katakwi',
        '5' => 'kumi',
        '6' => 'ngora',
        '7' => 'serere',
        '8' => 'soroti'
    }; 
    private static Map<String, String> westNileDistrictsMap = new Map<String, String> {
        '1' => 'adjumani',
        '2' => 'arua',
        '3' => 'koboko',
        '4' => 'maracha',
        '5' => 'moyo',
        '6' => 'zombo',
        '7' => 'nebbi',
        '8' => 'yumbe'
    }; 
    private static Map<String, String> karamojaDistrictsMap = new Map<String, String> {
        '1' => 'abim',
        '2' => 'kaabong',
        '3' => 'kotido',
        '4' => 'moroto',
        '5' => 'napak',
        '6' => 'nakapiripirit',
        '7' => 'amudat'
    }; 
    /*
    * A map matching sub-regions to the districts maps
    */
    public static Map<String, Map<String, String>> subregionsDistrictsMap = new Map<String, Map<String, String>>{
        '1' => acholiDistrictsMap,
        '2' => bukediDistrictsMap,
        '3' => bunyoroDistrictsMap,
        '4' => elgonDistrictsMap,
        '5' => langoDistrictsMap,
        '6' => tesoDistrictsMap,
        '7' => westNileDistrictsMap,
        '8' => karamojaDistrictsMap
    };
    
    /*
    * subcounty maps based on district
    */
    private static Map<String, String> agagoSubcountiesMap = new Map<String, String> {
        '1' => 'adilang',
        '2' => 'kalongo',
        '3' => 'lapono',
        '4' => 'lira palwo',
        '5' => 'lokole',
        '6' => 'omot',
        '7' => 'paimol',
        '8' => 'parabongo',
        '9' => 'patongo',
        '10' => 'wol'
    };      
    private static Map<String, String> amuruSubcountiesMap = new Map<String, String> {
        '1' => 'amuru',
        '2' => 'Amuru Town Council',
        '3' => 'atiak',
        '4' => 'lamogi',
        '5' => 'pabbo'
    }; 
    private static Map<String, String> guluSubcountiesMap = new Map<String, String> {
        '1' => 'awach',
        '2' => 'bar-dege',
        '3' => 'bobi',
        '4' => 'bungatira',
        '5' => 'koro',
        '6' => 'lakwana',
        '7' => 'lalogi',
        '8' => 'laroo',
        '9' => 'layibi',
        '10' => 'odek',
        '11' => 'ongako',
        '12' => 'paicho',
        '13' => 'palaro',
        '14' => 'patiko',
        '15' => 'pece'
    };
    private static Map<String, String> kitgumSubcountiesMap = new Map<String, String> {
        '1' => 'akwang',
        '2' => 'amida',
        '3' => 'kitgum matidi',
        '4' => 'kitgum',
        '5' => 'lagoro',
        '6' => 'layamo',
        '7' => 'mucwini',
        '8' => 'namokora',
        '9' => 'omiya anyima',
        '10' => 'orom'
    }; 
    private static Map<String, String> lamwoSubcountiesMap = new Map<String, String> {
        '1' => 'agoro',
        '2' => 'lokung',
        '3' => 'madi opei',
        '4' => 'padibe east',
        '5' => 'padibe west',
        '6' => 'palabek gem',
        '7' => 'palabek kal',
        '8' => 'palabek ogili',
        '9' => 'paloga'
    }; 
    private static Map<String, String> nwoyaSubcountiesMap = new Map<String, String> {
        '1' => 'alero',
        '2' => 'anaka',
        '3' => 'kochgoma',
        '4' => 'purongo'
    }; 
    private static Map<String, String> paderSubcountiesMap = new Map<String, String> {
        '1' => 'acholibur',
        '2' => 'atanga',
        '3' => 'awere',
        '4' => 'laguti',
        '5' => 'lapul',
        '6' => 'pader kilak',
        '7' => 'pader tc',
        '8' => 'pajule',
        '9' => 'puranga'
    }; 
    private static Map<String, String> budakaSubcountiesMap = new Map<String, String> {
        '1' => 'budaka',        
        '2' => 'budaka tc',
        '3' => 'iki-iki',
        '4' => 'kaderuna',
        '5' => 'kameruka',
        '6' => 'kamonkoli',
        '7' => 'lyama',
        '8' => 'naboa'
    };
    private static Map<String, String> busiaSubcountiesMap = new Map<String, String> {
        '1' => 'buhehe',
        '2' => 'bulumbi',
        '3' => 'busia',
        '4' => 'busitema',
        '5' => 'buteba',
        '6' => 'dabani',
        '7' => 'lumino',
        '8' => 'lunyo',
        '9' => 'masaba',
        '10' => 'masafu'
    }; 
    private static Map<String, String> butalejaSubcountiesMap = new Map<String, String> {
        '1' => 'lusamia',
        '2' => 'butaleja',
        '3' => 'butaleja tc',
        '4' => 'himutu',
        '5' => 'kachongha',
        '6' => 'mazimasa',
        '7' => 'naweyo',
        '8' => 'budumba',
        '9' => 'busaba',
        '10' => 'busabi',
        '11' => 'busolwe',
        '12' => 'busolwe tc',
        '13' => 'nawanjofu'
    };  
    private static Map<String, String> kibukuSubcountiesMap = new Map<String, String> {
        '1' => 'bulangira',        
        '2' => 'buseta',
        '3' => 'kadama',
        '4' => 'kagumu',
        '5' => 'kibuku',
        '6' => 'kirika',
        '7' => 'tirinyi',
        '8' => 'naboa'
    };
    private static Map<String, String> pallisaSubcountiesMap = new Map<String, String> {
        '1' => 'agule',
        '2' => 'apopong',
        '3' => 'gogonyo',
        '4' => 'kameke',
        '5' => 'butebo',
        '6' => 'kakoro',
        '7' => 'kibale',
        '8' => 'kabwangasi',
        '9' => 'kamuge',
        '10' => 'kasodo',
        '11' => 'pallisa',
        '12' => 'pallisa tc',
        '13' => 'petete',
        '14' => 'puti puti'
    }; 
    private static Map<String, String> tororoSubcountiesMap = new Map<String, String> {
        '1' => 'kwapa',
        '2' => 'malaba tc',
        '3' => 'mella',
        '4' => 'molo',
        '5' => 'mukuju',
        '6' => 'osukuru',
        '7' => 'eastern division',
        '8' => 'western division',
        '9' => 'nagongera',
        '10' => 'iyolwa',
        '11' => 'kirewa',
        '12' => 'kisoko',
        '13' => 'magola',
        '14' => 'merikit',
        '15' => 'mulanda',
        '16' => 'nabuyoga',
        '17' => 'nagongera',
        '18' => 'paya',
        '19' => 'petta',
        '20' => 'rubongi',
        '21' => 'sopsop'
    }; 
    private static Map<String, String> bulisaSubcountiesMap = new Map<String, String> {
        '1' => 'biiso',
        '2' => 'buliisa tc',
        '3' => 'buliisa'
    }; 
    private static Map<String, String> masindiSubcountiesMap = new Map<String, String> {
        '1' => 'budongo',
        '2' => 'bwijanga',
        '3' => 'karujubu',
        '4' => 'kimengo',
        '5' => 'masindi tc',
        '6' => 'miirya',
        '7' => 'nyangahya',
        '8' => 'pakanyi'
    }; 
    private static Map<String, String> kiryandongoSubcountiesMap = new Map<String, String> {
        '1' => 'kiryandongo',
        '2' => 'kigumba',
        '3' => 'masindi port',
        '4' => 'mutunda'
    }; 
    private static Map<String, String> bududaSubcountiesMap = new Map<String, String> {
        '1' => 'bubiita',
        '2' => 'bududa tc',
        '3' => 'bududa',
        '4' => 'bukalasi',
        '5' => 'bukibokolo',
        '6' => 'bukigai',
        '7' => 'bulucheke',
        '8' => 'bumasheti',
        '9' => 'bumayoka',
        '10' => 'bushika',
        '11' => 'bushiribo',
        '12' => 'bushiyi',
        '13' => 'buwali',
        '14' => 'nabweya',
        '15' => 'nakatsi',
        '16' => 'nalwanza'
    }; 
    private static Map<String, String> bukwoSubcountiesMap = new Map<String, String> {
        '1' => 'bukwo',
        '2' => 'bukwo tc',
        '3' => 'chesower',
        '4' => 'kabei',
        '5' => 'suam'
    };
    private static Map<String, String> bulambuliSubcountiesMap = new Map<String, String> {
        '1' => 'buginyanya',
        '2' => 'bukhalu',
        '3' => 'bulago',
        '4' => 'bulegeni',
        '5' => 'buluganya',
        '6' => 'bunambutye',
        '7' => 'masira',
        '8' => 'muyembe',
        '9' => 'sisiyi'
    }; 
    private static Map<String, String> kapchorwaSubcountiesMap = new Map<String, String> {
        '1' => 'chema',
        '2' => 'gamogo',
        '3' => 'kapchorwa tc',
        '4' => 'kaptanya',
        '5' => 'kaserem',
        '6' => 'kawowo',
        '7' => 'sipi',
        '8' => 'tegeres'
    }; 
    private static Map<String, String> kweenSubcountiesMap = new Map<String, String> {
        '1' => 'benet',
        '2' => 'binyiny',
        '3' => 'kaproron',
        '4' => 'kwanyiy',
        '5' => 'kwosir',
        '6' => 'ngenge'
    }; 
    private static Map<String, String> manafwaSubcountiesMap = new Map<String, String> {
        '1' => 'bubutu',
        '2' => 'bugobero',
        '3' => 'bukokho',
        '4' => 'bukusu',
        '5' => 'bumbo',
        '6' => 'bumwoni',
        '7' => 'bunabwana',
        '8' => 'bupoto',
        '9' => 'busukuya',
        '10' => 'butiru',
        '11' => 'butta',
        '12' => 'buwabwala',
        '13' => 'buwagogo',
        '14' => 'kaato',
        '15' => 'khabutoola',
        '16' => 'lwakhakha tc',
        '17' => 'magale',
        '18' => 'manafwa',
        '19' => 'mukoto',
        '20' => 'namabya',
        '21' => 'namboko',
        '22' => 'sibanga',
        '23' => 'sisuni',
        '24' => 'tsekululu'
    }; 
    private static Map<String, String> mbaleSubcountiesMap = new Map<String, String> {
        '1' => 'bubyangu',
        '2' => 'budwale',
        '3' => 'bufumbo',
        '4' => 'bukasakya',
        '5' => 'bukiende',
        '6' => 'bukonde',
        '7' => 'bumasikye',
        '8' => 'bungokho',
        '9' => 'busano',
        '10' => 'busiu',
        '11' => 'busoba',
        '12' => 'industrial division',
        '13' => 'lukhonje',
        '14' => 'lwasso',
        '15' => 'mutoto',
        '16' => 'nakaloke',
        '17' => 'namanyonyi',
        '18' => 'nyondo',
        '19' => 'wanale',
        '20' => 'northern division',
        '21' => 'wanale division',
        '22' => 'bukasakya',
        '23' => 'bukiende',
        '24' => 'bukonde'
    }; 
    private static Map<String, String> sironkoSubcountiesMap = new Map<String, String> {
        '1' => 'buhugu',
        '2' => 'bukhulo',
        '3' => 'bumasifwa',
        '4' => 'busulani',
        '5' => 'butandiga',
        '6' => 'buwalasi',
        '7' => 'buyobo',
        '8' => 'sironko tc',
        '9' => 'zesui'
    }; 
    private static Map<String, String> aleptongSubcountiesMap = new Map<String, String> {
        '1' => 'abako',
        '2' => 'aloi',
        '3' => 'amugo',
        '4' => 'apala',
        '5' => 'omoro'
    }; 
    private static Map<String, String> amolatarSubcountiesMap = new Map<String, String> {
        '1' => 'amolatar tc',
        '2' => 'aputi',
        '3' => 'awelo',
        '4' => 'muntu',
        '5' => 'namasale'
    }; 
    private static Map<String, String> koleSubcountiesMap = new Map<String, String> {
        '1' => 'aboke',
        '2' => 'akalo',
        '3' => 'alito',
        '4' => 'ayer',
        '5' => 'bala'
    }; 
    private static Map<String, String> apacSubcountiesMap = new Map<String, String> {
        '1' => 'abongomola',
        '2' => 'aduku',
        '3' => 'akokoro',
        '4' => 'apac',
        '5' => 'apac tc',
        '6' => 'chawente',
        '7' => 'chegere',
        '8' => 'ibuje',
        '9' => 'inomo',
        '10' => 'nambieso'
    }; 
    private static Map<String, String> dokoloSubcountiesMap = new Map<String, String> {
        '1' => 'agwata',
        '2' => 'batta',
        '3' => 'dokolo',
        '4' => 'dokolo tc',
        '5' => 'kangai',
        '6' => 'kwera'
    }; 
    private static Map<String, String> liraSubcountiesMap = new Map<String, String> {
        '1' => 'adekokwok',
        '2' => 'amach',
        '3' => 'aromo',
        '4' => 'barr',
        '5' => 'lira tc',
        '6' => 'ogur',
        '7' => 'adyel division',
        '8' => 'central division',
        '9' => 'ojwina division',
        '10' => 'railways division'
    }; 
    private static Map<String, String> otukeSubcountiesMap = new Map<String, String> {
        '1' => 'adwari',
        '2' => 'okwang',
        '3' => 'olilim',
        '4' => 'orum'
    };
    private static Map<String, String> oyamSubcountiesMap = new Map<String, String> {
        '1' => 'aber',
        '2' => 'acaba',
        '3' => 'iceme',
        '4' => 'loro',
        '5' => 'minakulu',
        '6' => 'ngai',
        '7' => 'otwal',
        '8' => 'oyam tc'
    }; 
    private static Map<String, String> amuriaSubcountiesMap = new Map<String, String> {
        '1' => 'abarilela',
        '2' => 'acowa',
        '3' => 'amuria tc',
        '4' => 'asamuk',
        '5' => 'kapelebyong',
        '6' => 'kuju',
        '7' => 'morungatuny',
        '8' => 'obalanga',
        '9' => 'orungo',
        '10' => 'wera'
    }; 
    private static Map<String, String> bukedeaSubcountiesMap = new Map<String, String> {
        '1' => 'bukedea',
        '2' => 'bukedea tc',
        '3' => 'kachumbala',
        '4' => 'kidongole',
        '5' => 'kolir',
        '6' => 'malera'
    };
    private static Map<String, String> kaberamaidoSubcountiesMap = new Map<String, String> {
        '1' => 'alwa',
        '2' => 'anyara',
        '3' => 'bululu',
        '4' => 'kaberamaido',
        '5' => 'kaberamaido tc',
        '6' => 'kalaki',
        '7' => 'kobulubulu',
        '8' => 'ochero',
        '9' => 'otuboi'
    };
    private static Map<String, String> katakwiSubcountiesMap = new Map<String, String> {
        '1' => 'kapujan',
        '2' => 'magoro',
        '3' => 'omodoi',
        '4' => 'toroma',
        '5' => 'katakwi',
        '6' => 'katakwi tc',
        '7' => 'ngariam',
        '8' => 'ongongoja',
        '9' => 'usuk'
    };
    private static Map<String, String> kumiSubcountiesMap = new Map<String, String> {
        '1' => 'atutur',
        '2' => 'kanyum',
        '3' => 'kumi',
        '4' => 'kumi town',
        '5' => 'mukongoro',
        '6' => 'nyero',
        '7' => 'ongiino'
    };
    private static Map<String, String> ngoraSubcountiesMap = new Map<String, String> {
        '1' => 'kapir',
        '2' => 'kobwin',
        '3' => 'mukura',
        '4' => 'ngora'
    };
    private static Map<String, String> serereSubcountiesMap = new Map<String, String> {
        '1' => 'atiira',
        '2' => 'bugondo',
        '3' => 'kadungulu',
        '4' => 'kateta',
        '5' => 'kyere',
        '6' => 'olio',
        '7' => 'pingire',
        '8' => 'serere',
        '9' => 'kasilo',
        '10' => 'labori'
    }; 
    private static Map<String, String> sorotiSubcountiesMap = new Map<String, String> {
        '1' => 'arapai',
        '2' => 'asuret',
        '3' => 'gweri',
        '4' => 'kamuda',
        '5' => 'katine',
        '6' => 'soroti',
        '7' => 'tubur',
        '8' => 'eastern division',
        '9' => 'northern division',
        '10' => 'western division'
    }; 
    private static Map<String, String> adjumaniSubcountiesMap = new Map<String, String> {
        '1' => 'adjumani tc',
        '2' => 'adropi',
        '3' => 'ciforo',
        '4' => 'dzaipi',
        '5' => 'ofua',
        '6' => 'pakelle'
    }; 
    private static Map<String, String> aruaSubcountiesMap = new Map<String, String> {
        '1' => 'adumi',
        '2' => 'aiivu',
        '3' => 'ajia',
        '4' => 'arivu',
        '5' => 'aroi',
        '6' => 'arua hill',
        '7' => 'bileafe',
        '8' => 'dadamu',
        '9' => 'katrini',
        '10' => 'logiri',
        '11' => 'manibe',
        '12' => 'odupi',
        '13' => 'offaka',
        '14' => 'ogoko',
        '15' => 'okollo',
        '16' => 'oli river',
        '17' => 'oluko',
        '18' => 'omugo',
        '19' => 'pajulu',
        '20' => 'rhino camp',
        '21' => 'rigbo',
        '22' => 'ullepi',
        '23' => 'uriama',
        '24' => 'vurra'
    }; 
    private static Map<String, String> kobokoSubcountiesMap = new Map<String, String> {
        '1' => 'abuku',
        '2' => 'dranya',
        '3' => 'koboko tc',
        '4' => 'kuluba',
        '5' => 'lobule',
        '6' => 'ludara',
        '7' => 'midia'
    }; 
    private static Map<String, String> marachaSubcountiesMap = new Map<String, String> {
        '1' => 'kijomoro',
        '2' => 'nyadri',
        '3' => 'oleba',
        '4' => 'oluffe',
        '5' => 'oluvu',
        '6' => 'tara',
        '7' => 'yivu'
    };
    private static Map<String, String> moyoSubcountiesMap = new Map<String, String> {
        '1' => 'aliba',
        '2' => 'dufile',
        '3' => 'gimara',
        '4' => 'itula',
        '5' => 'lefori',
        '6' => 'metu',
        '7' => 'moyo',
        '8' => 'moyo tc'
    }; 
    private static Map<String, String> zomboSubcountiesMap = new Map<String, String> {
        '1' => 'atyak',
        '2' => 'jangokoro',
        '3' => 'kango',
        '4' => 'nyapea',
        '5' => 'paidha sc',
        '6' => 'paidha tc',
        '7' => 'zeu'
    }; 
    private static Map<String, String> nebbiSubcountiesMap = new Map<String, String> {
        '1' => 'akworo',
        '2' => 'erussi',
        '3' => 'kucwiny',
        '4' => 'nebbi sc',
        '5' => 'nebbi tc',
        '6' => 'nyaravur',
        '7' => 'pakwach sc',
        '8' => 'pakwach tc',
        '9' => 'panyango',
        '10' => 'panyimur',
        '11' => 'parombo',
        '12' => 'wadelai'
    }; 
    private static Map<String, String> yumbeSubcountiesMap = new Map<String, String> {
        '1' => 'apo',
        '2' => 'drajini',
        '3' => 'kei',
        '4' => 'kuru',
        '5' => 'midigo',
        '6' => 'odravu',
        '7' => 'romogi',
        '8' => 'yumbe tc'
    }; 
    private static Map<String, String> abimSubcountiesMap = new Map<String, String> {
        '1' => 'nyakwae',
        '2' => 'morulem',
        '3' => 'lotuke',
        '4' => 'alerek',
        '5' => 'abim',
        '6' => 'abim tc'
    }; 
    private static Map<String, String> kaabongSubcountiesMap = new Map<String, String> {
        '1' => 'kaabong tc',
        '2' => 'kaabong',
        '3' => 'kalapata',
        '4' => 'kapedo',
        '5' => 'karenga',
        '6' => 'kathile',
        '7' => 'loyoro',
        '8' => 'sidok',
        '9' => 'lolelia'
    }; 
    private static Map<String, String> kotidoSubcountiesMap = new Map<String, String> {
        '1' => 'kacheri',
        '2' => 'kotido',
        '3' => 'kotido tc',
        '4' => 'nakapelimoru',
        '5' => 'panyangara',
        '6' => 'rengen'
    }; 
    private static Map<String, String> morotoSubcountiesMap = new Map<String, String> {
        '1' => 'northern division',
        '2' => 'southern division',
        '3' => 'rupa',
        '4' => 'nadunget',
        '5' => 'katikekile'
    }; 
    private static Map<String, String> napakSubcountiesMap = new Map<String, String> {
        '1' => 'iriir',
        '2' => 'lokopo',
        '3' => 'lopeei',
        '4' => 'lotome',
        '5' => 'matany',
        '6' => 'ngoleriet'
    }; 
    private static Map<String, String> nakapiripiritSubcountiesMap = new Map<String, String> {
        '1' => 'nabilatuk',
        '2' => 'lorengedwat',
        '3' => 'namalu',
        '4' => 'nakapiripirit tc',
        '5' => 'kakomongole',
        '6' => 'moruita',
        '7' => 'loregae',
        '8' => 'lolachat'
    }; 
    private static Map<String, String> amudatSubcountiesMap = new Map<String, String> {
        '1' => 'amudat',
        '2' => 'karita',
        '3' => 'loroo'
    };
}