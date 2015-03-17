public with sharing class LacPpiProbabilityGenerator {
	
	private static final Map<Integer,Double> ppProbabilityLessThanOneAndQuarter;
	private static final Map<Integer, Double> ppProbabilityLessThanTwoAndHalf;
	private static final Map<Integer, Double> ppProbabilityLessThanThreeAndThreeQuarter;
	private static final Map<Integer, Double> ppProbabilityLessThanFive;
	
	static {
		ppProbabilityLessThanOneAndQuarter = new Map<Integer, Double>();
		ppProbabilityLessThanTwoAndHalf = new Map<Integer, Double>();
		ppProbabilityLessThanThreeAndThreeQuarter = new Map<Integer, Double>();
		ppProbabilityLessThanFive = new Map<Integer, Double>();
		
		initPpProbabilityForLessThanTwoAndHalf();
		initPpProbabilityForLessThanOneAndQuarter();
		initPpProbabilityForLessThanThreeAndThreeQuarter();
		initPpProbabilityForLessThanFive();
	}
	
	private static void initPpProbabilityForLessThanFive() {
		ppProbabilityLessThanFive.put(0, 100);
		ppProbabilityLessThanFive.put(5, 99.9);
		ppProbabilityLessThanFive.put(10, 98.7);
		ppProbabilityLessThanFive.put(15, 99.2);
		ppProbabilityLessThanFive.put(20, 97.2);
		ppProbabilityLessThanFive.put(25, 92.4);
		ppProbabilityLessThanFive.put(30, 82.9);
		ppProbabilityLessThanFive.put(35, 69);
		ppProbabilityLessThanFive.put(40, 52.2);
		ppProbabilityLessThanFive.put(45, 35.2);
		ppProbabilityLessThanFive.put(50, 18.7);
		ppProbabilityLessThanFive.put(55, 10.2);
		ppProbabilityLessThanFive.put(60, 5.3);
		ppProbabilityLessThanFive.put(65, 2.3);
		ppProbabilityLessThanFive.put(70, 1.1);
		ppProbabilityLessThanFive.put(75, 0.7);
		ppProbabilityLessThanFive.put(80, 0.5);
		ppProbabilityLessThanFive.put(85, 0.1);
		ppProbabilityLessThanFive.put(90, 0);
		ppProbabilityLessThanFive.put(95, 0);
		ppProbabilityLessThanFive.put(100, 0);
	}
	
	private static void initPpProbabilityForLessThanThreeAndThreeQuarter() {
		ppProbabilityLessThanThreeAndThreeQuarter.put(0, 100);
		ppProbabilityLessThanThreeAndThreeQuarter.put(5, 99.1);
		ppProbabilityLessThanThreeAndThreeQuarter.put(10, 97.6);
		ppProbabilityLessThanThreeAndThreeQuarter.put(15, 97.1);
		ppProbabilityLessThanThreeAndThreeQuarter.put(20, 91.5);
		ppProbabilityLessThanThreeAndThreeQuarter.put(25, 83.1);
		ppProbabilityLessThanThreeAndThreeQuarter.put(30, 69.6);
		ppProbabilityLessThanThreeAndThreeQuarter.put(35, 51.2);
		ppProbabilityLessThanThreeAndThreeQuarter.put(40, 35);
		ppProbabilityLessThanThreeAndThreeQuarter.put(45, 20);
		ppProbabilityLessThanThreeAndThreeQuarter.put(50, 8.8);
		ppProbabilityLessThanThreeAndThreeQuarter.put(55, 4.4);
		ppProbabilityLessThanThreeAndThreeQuarter.put(60, 2.5);
		ppProbabilityLessThanThreeAndThreeQuarter.put(65, 0.9);
		ppProbabilityLessThanThreeAndThreeQuarter.put(70, 0.6);
		ppProbabilityLessThanThreeAndThreeQuarter.put(75, 0.2);
		ppProbabilityLessThanThreeAndThreeQuarter.put(80, 0.4);
		ppProbabilityLessThanThreeAndThreeQuarter.put(85, 0);
		ppProbabilityLessThanThreeAndThreeQuarter.put(90, 0);
		ppProbabilityLessThanThreeAndThreeQuarter.put(95, 0);
		ppProbabilityLessThanThreeAndThreeQuarter.put(100, 0);
	}
	
	private static void initPpProbabilityForLessThanOneAndQuarter() {
		ppProbabilityLessThanOneAndQuarter.put(0, 81.1);
		ppProbabilityLessThanOneAndQuarter.put(5, 71.6);
		ppProbabilityLessThanOneAndQuarter.put(10, 64.4);
		ppProbabilityLessThanOneAndQuarter.put(15, 45.7);
		ppProbabilityLessThanOneAndQuarter.put(20, 33.7);
		ppProbabilityLessThanOneAndQuarter.put(25, 24.7);
		ppProbabilityLessThanOneAndQuarter.put(30, 15.9);
		ppProbabilityLessThanOneAndQuarter.put(35, 8.9);
		ppProbabilityLessThanOneAndQuarter.put(40, 6.1);
		ppProbabilityLessThanOneAndQuarter.put(45, 3.2);
		ppProbabilityLessThanOneAndQuarter.put(50, 1.3);
		ppProbabilityLessThanOneAndQuarter.put(55, 0.8);
		ppProbabilityLessThanOneAndQuarter.put(60, 0.5);
		ppProbabilityLessThanOneAndQuarter.put(65, 0.1);
		ppProbabilityLessThanOneAndQuarter.put(70, 0.1);
		ppProbabilityLessThanOneAndQuarter.put(75, 0);
		ppProbabilityLessThanOneAndQuarter.put(80, 0.1);
		ppProbabilityLessThanOneAndQuarter.put(85, 0);
		ppProbabilityLessThanOneAndQuarter.put(90, 0);
		ppProbabilityLessThanOneAndQuarter.put(95, 0);
		ppProbabilityLessThanOneAndQuarter.put(100, 0);
	}
	
	private static void initPpProbabilityForLessThanTwoAndHalf() {
		ppProbabilityLessThanTwoAndHalf.put(0, 100);
		ppProbabilityLessThanTwoAndHalf.put(5, 97.7);
		ppProbabilityLessThanTwoAndHalf.put(10, 93.8);
		ppProbabilityLessThanTwoAndHalf.put(15, 87.9);
		ppProbabilityLessThanTwoAndHalf.put(20, 74);
		ppProbabilityLessThanTwoAndHalf.put(25, 60.7);
		ppProbabilityLessThanTwoAndHalf.put(30, 42.6);
		ppProbabilityLessThanTwoAndHalf.put(35, 26.7);
		ppProbabilityLessThanTwoAndHalf.put(40, 16.8);
		ppProbabilityLessThanTwoAndHalf.put(45, 9.1);
		ppProbabilityLessThanTwoAndHalf.put(50, 3.6);
		ppProbabilityLessThanTwoAndHalf.put(55, 2.1);
		ppProbabilityLessThanTwoAndHalf.put(60, 1.1);
		ppProbabilityLessThanTwoAndHalf.put(65, 0.4);
		ppProbabilityLessThanTwoAndHalf.put(70, 0.4);
		ppProbabilityLessThanTwoAndHalf.put(75, 0.1);
		ppProbabilityLessThanTwoAndHalf.put(80, 0.3);
		ppProbabilityLessThanTwoAndHalf.put(85, 0);
		ppProbabilityLessThanTwoAndHalf.put(90, 0);
		ppProbabilityLessThanTwoAndHalf.put(95, 0);
		ppProbabilityLessThanTwoAndHalf.put(100, 0);	
	}
	
	public static Double getPpProbabilityForLessThanTwoAndHalf(Integer ppiScore){
		Integer lowerLimit = getPpiLowerLimitValue(ppiScore);
		return ppProbabilityLessThanTwoAndHalf.get(lowerLimit);
	}


	public static Double getPpProbabilityForLessThanOneAndQuarter(Integer ppiScore) {
		Integer lowerLimit = getPpiLowerLimitValue(ppiScore);
		return ppProbabilityLessThanOneAndQuarter.get(lowerLimit);		
	}
	
	public static Double getPpProbabilityForLessThanThreeAndThreeQuarter(Integer ppiScore) {
		Integer lowerLimit = getPpiLowerLimitValue(ppiScore);
		return 	ppProbabilityLessThanThreeAndThreeQuarter.get(lowerLimit);
	}
	
	public static Double getPpProbabilityForLessThanFive(Integer ppiScore) {
		Integer lowerLimit = getPpiLowerLimitValue(ppiScore);
		return ppProbabilityLessThanFive.get(lowerLimit);
	}
	
	/**
	 * gets the lower limit of the ppi score in it's index.
	 * e.g. a value of 3 will get the lower limit of 0 because the ppi index for this 
	 * score is 0 - 4 with 4 being the higher limit.
	 */
	private static Integer getPpiLowerLimitValue(Integer ppiScore) {
		if (ppiScore >= 0 && ppiScore <= 4) {
			return 0;
		} else if (ppiScore >= 5 && ppiScore <= 9) {
			return 5;
		} else if (ppiScore >= 10 && ppiScore <= 14) {
			return 10;
		} else if (ppiScore >= 15 && ppiScore <= 19) {
			return 15;
		} else if (ppiScore >= 20 && ppiScore <= 24) {
			return 20;
		} else if (ppiScore >= 25 && ppiScore <= 29) {
			return 25;
		} else if (ppiScore >= 30 && ppiScore <= 34) {
			return 30;
		} else if (ppiScore >= 35 && ppiScore <= 39) {
			return 35;
		} else if (ppiScore >= 40 && ppiScore <= 44) {
			return 40;
		} else if (ppiScore >= 45 && ppiScore <= 49) {
			return 45;
		} else if (ppiScore >= 50 && ppiScore <= 54) {
			return 50;
		} else if (ppiScore >= 55 && ppiScore <= 59) {
			return 55;
		} else if (ppiScore >= 60 && ppiScore <= 64) {
			return 60;
		} else if (ppiScore >= 65 && ppiScore <= 69) {
			return 65;
		} else if (ppiScore >= 70 && ppiScore <= 74) {
			return 70;
		} else if (ppiScore >= 75 && ppiScore <= 75) {
			return 75;
		} else if (ppiScore >= 80 && ppiScore <= 84) {
			return 80;
		} else if (ppiScore >= 85 && ppiScore <= 89) {
			return 85;
		} else if (ppiScore >= 90 && ppiScore <= 94) {
			return 90;
		} else if (ppiScore >= 95 && ppiScore <= 99) {
			return 95;
		} else if (ppiScore >= 100) {
			return 100;
		}
		
		return -1;
	}
}