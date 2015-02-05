public with sharing class SBuxSegmentationProcessHandler_CBL2 {

  //private CBL_CoffeeBaseline__c cbl;
  private CBL2_Farmer__c cbl2;
  
  private Integer maxIndex;
  
  private Integer[] scores = new Integer[10];
  
  private Double probability;
  
  private String segment;
  
  public SBuxSegmentationProcessHandler_CBL2(CBL2_Farmer__c baseline) {
    this.cbl2 = baseline;
  }
  
  public void handle() {
    calculateSegmentAndProbability();
  }  
  
  private Integer scoreIndicator(String answer) {
    if (answer == null || answer.trim().equals('')) {
      return 0;
    }
    if (answer.equals('Muy en desacuerdo')) {
      return 1;
    } else if (answer.equals('De algún modo en desacuerdo')) {
      return 2;
    } else if (answer.equals('Ni de acuerdo o en desacuerdo')) {
      return 3;
    } else if (answer.equals('De algún modo de acuerdo')) {
      return 4;
    } else if (answer.equals('Muy de acuerdo')) { 
      return 5;
    } else {
      return 0;
    }
  }
  
  private Integer scoreIndicatorReverse(String answer) {
    if (answer == null || answer.trim().equals('')) {
      return 0;
    }
    if (answer.equals('Muy en desacuerdo')) {
      return 5;
    } else if (answer.equals('De algún modo en desacuerdo')) {
      return 4;
    } else if (answer.equals('Ni de acuerdo o en desacuerdo')) {
      return 3;
    } else if (answer.equals('De algún modo de acuerdo')) {
      return 2;
    } else if (answer.equals('Muy de acuerdo')) { 
      return 1;
    } else {
      return 0;
    }    
  }
  
  private List<List<Double>> getCoefficients() {
    List<List<Double>> coefficientList = new List<List<Double>>(); 

    List<Double> firstRow = new List<Double>();
    //c(0, 1) = -29.854: c(0, 2) = -28.347: c(0, 3) = -31.021: c(0, 4) = -28.265: c(0, 5) = -30.672: c(0, 6) = -19.531
    firstRow.add(-29.854);
    firstRow.add(-28.347);
    firstRow.add(-31.021);
    firstRow.add(-28.265);
    firstRow.add(-30.672);
    firstRow.add(-19.531);
    coefficientList.add(firstRow);
    
    //c(1, 1) = 1.537: c(1, 2) = 2.365: c(1, 3) = -0.256: c(1, 4) = 2.51: c(1, 5) = 1.514: c(1, 6) = 0.391
    List<Double> secondRow = new List<Double>();
    secondRow.add(1.537);
    secondRow.add(2.365);
    secondRow.add(-0.256);
    secondRow.add(2.51);
    secondRow.add(1.514);
    secondRow.add(0.391);
    coefficientList.add(secondRow);
    
    //c(2, 1) = 1.741: c(2, 2) = 2.583: c(2, 3) = -0.149: c(2, 4) = 2.459: c(2, 5) = 1.067: c(2, 6) = 0.594
    List<Double> thirdRow = new List<Double>();
    thirdRow.add(1.741);
    thirdRow.add(2.583);
    thirdRow.add(-0.149);
    thirdRow.add(2.459);
    thirdRow.add(1.067);
    thirdRow.add(0.594);
    coefficientList.add(thirdRow);
    
    //c(3, 1) = 1.436: c(3, 2) = 2.323: c(3, 3) = 0.004: c(3, 4) = 2.55: c(3, 5) = 1.261: c(3, 6) = 0.527
    List<Double> fourthRow = new List<Double>();
    fourthRow.add(1.436);
    fourthRow.add(2.323);
    fourthRow.add(0.004);
    fourthRow.add(2.55);
    fourthRow.add(1.261);
    fourthRow.add(0.527);
    coefficientList.add(fourthRow);
    
    //c(4, 1) = 1.843: c(4, 2) = 0.909: c(4, 3) = 2.677: c(4, 4) = -0.252: c(4, 5) = 1.708: c(4, 6) = 0.453
    List<Double> fifthRow = new List<Double>();
    fifthRow.add(1.843);
    fifthRow.add(0.909);
    fifthRow.add(2.677);
    fifthRow.add(-0.252);
    fifthRow.add(1.708);
    fifthRow.add(0.453);
    coefficientList.add(fifthRow);
    
    //c(5, 1) = 2.646: c(5, 2) = 1.318: c(5, 3) = 3.753: c(5, 4) = -0.599: c(5, 5) = 1.882: c(5, 6) = 0.739
    List<Double> sixthRow = new List<Double>();
    sixthRow.add(2.646);
    sixthRow.add(1.318);
    sixthRow.add(3.753);
    sixthRow.add(-0.599);
    sixthRow.add(1.882);
    sixthRow.add(0.739);
    coefficientList.add(sixthRow);
    
    //c(6, 1) = 2.176: c(6, 2) = 1.238: c(6, 3) = 2.868: c(6, 4) = 0.326: c(6, 5) = 2.008: c(6, 6) = 1.127
    List<Double> seventhRow = new List<Double>();
    seventhRow.add(2.176);
    seventhRow.add(1.238);
    seventhRow.add(2.868);
    seventhRow.add(0.326);
    seventhRow.add(2.008);
    seventhRow.add(1.127);
    coefficientList.add(seventhRow);
    
    //c(7, 1) = 1.174: c(7, 2) = 1.233: c(7, 3) = 1.499: c(7, 4) = 2.001: c(7, 5) = 1.96: c(7, 6) = 1.819        
    List<Double> eighthRow = new List<Double>();
    eighthRow.add(1.174);
    eighthRow.add(1.233);
    eighthRow.add(1.499);
    eighthRow.add(2.001);
    eighthRow.add(1.96);
    eighthRow.add(1.819);
    coefficientList.add(eighthRow);
    
    //c(8, 1) = 2.364: c(8, 2) = 1.937: c(8, 3) = 2.296: c(8, 4) = 1.592: c(8, 5) = 1.541: c(8, 6) = 2.351
    List<Double> ninthRow = new List<Double>();
    ninthRow.add(2.364);
    ninthRow.add(1.937);
    ninthRow.add(2.296);
    ninthRow.add(1.592);
    ninthRow.add(1.541);
    ninthRow.add(2.351);
    coefficientList.add(ninthRow);
    
    //c(9, 1) = 0.865: c(9, 2) = 1.13: c(9, 3) = 1.172: c(9, 4) = 1.924: c(9, 5) = 1.623: c(9, 6) = 2.25
    List<Double> tenthRow = new List<Double>();
    tenthRow.add(0.865);
    tenthRow.add(1.13);
    tenthRow.add(1.172);
    tenthRow.add(1.924);
    tenthRow.add(1.623);
    tenthRow.add(2.25);
    coefficientList.add(tenthRow);
    
    //c(10, 1) = 1.306: c(10, 2) = 1.449: c(10, 3) = 2.05: c(10, 4) = 2.569: c(10, 5) = 2.196: c(10, 6) = 2.422
    List<Double> eleventhRow = new List<Double>();
    eleventhRow.add(1.306);
    eleventhRow.add(1.449);
    eleventhRow.add(2.05);
    eleventhRow.add(2.569);
    eleventhRow.add(2.196);
    eleventhRow.add(2.422);
    coefficientList.add(eleventhRow);
    
    return coefficientList;          
  }
  
  private void calculateSegmentAndProbability() {
    //try {
      /*
      CBL_Attitude__c attitude = [Select Id, wishChildrenBecomeFarmers__c, farmersLifeWillBeBetter__c, chooseToBeFarmer__c, 
        worthInvestingMoneyTimeAgr__c, destinedToBeFarmer__c, happyToBeFarmer__c, effortInAgriculturePays__c, takeAdvise__c, 
        discussMethodsWOthers__c, payForAgriAdvise__c from CBL_Attitude__c where Baseline__c = :cbl.Id];
      */  
      CBL2_Farmer__c attitude = [Select Id, attitude_wishChildrenBecomeFarmers__c, attitude_farmersLifeWillBeBetter__c, attitude_chooseToBeFarmer__c, 
        attitude_worthInvestingMoneyTimeAgr__c, attitude_destinedToBeFarmer__c, attitude_happyToBeFarmer__c, attitude_effortInAgriculturePays__c, attitude_takeAdvise__c, 
        attitude_discussMethodsWOthers__c, attitude_payForAgriAdvise__c from CBL2_Farmer__c where Id = :cbl2.Id];
        
      if (attitude != null) {
        System.debug('Attitude not null, starting process...');
        scores[0] = scoreIndicatorReverse(attitude.attitude_wishChildrenBecomeFarmers__c);
        scores[1] = scoreIndicatorReverse(attitude.attitude_farmersLifeWillBeBetter__c);
        scores[2] = scoreIndicatorReverse(attitude.attitude_chooseToBeFarmer__c);
        scores[3] = scoreIndicator(attitude.attitude_worthInvestingMoneyTimeAgr__c);
        scores[4] = scoreIndicator(attitude.attitude_destinedToBeFarmer__c);
        scores[5] = scoreIndicator(attitude.attitude_happyToBeFarmer__c);
        scores[6] = scoreIndicator(attitude.attitude_effortInAgriculturePays__c);
        scores[7] = scoreIndicatorReverse(attitude.attitude_takeAdvise__c);
        scores[8] = scoreIndicator(attitude.attitude_discussMethodsWOthers__c);
        scores[9] = scoreIndicator(attitude.attitude_payForAgriAdvise__c);
        if (allScoresCompleteForSegmentation(scores)) {
          calculateSegmentation();
          cbl2.sbuxSegment__c = segment;
          cbl2.sbuxSegmentProbability__c = probability;
          update cbl2;
        }
      }  
    //} catch(Exception e) {
      
    //}
  }  
  
  private Boolean allScoresCompleteForSegmentation(Integer[] scores) {
    for (Integer score : scores) {
      if (score == 0) {
        return false;
      }
    }
    return true;
  }
  
  private void calculateSegmentation() {
    List<List<Double>> coefficients = getCoefficients();
    Double[] s = new Double[7];
    for (Integer i = 0; i < 6; i++) {
      s[i] = coefficients.get(0).get(i);
      for (Integer j = 0; j < 10; j++) {
        s[i] = s[i] + ( scores[j] * coefficients.get(j+1).get(i));
      }
    }
    
    Double max = -100000;
    for (Integer i = 0; i < 6; i++) {
      if (s[i] > max) {
        maxIndex = i + 1;
        max = s[i];
      }
    }
    
    Double v = s[maxIndex -1];
    for (Integer i = 0; i < 6; i++) {
      s[i] = s[i] - v;
    }
    
    max = 0;
    for (Integer i = 0; i < 6; i++) {
      s[i] = Math.exp(s[i]);
      max = max + s[i];
    }
    for (Integer i = 0; i < 6; i++) {
      s[i] = s[i] / max;
    }
    
    probability = Math.round(s[maxIndex - 1] * 100);
    segment = getSegmentFromIndex(maxIndex);
    
  }
  
  private String getSegmentFromIndex(Integer index) {
    String[] segments = new String[]{'Tradicionalistas', 'Atrapados', 'Dependientes Conformes', 'Escapistas frustrados', 'Optimistas Competentes', 'Independientes'};
    return segments[index - 1];
  }
  
}