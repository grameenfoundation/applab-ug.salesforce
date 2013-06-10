public with sharing class LacPpiProbabilityGenerator {
	
	private static final Map<Integer,Double> ppProbabilityLessThanOneAndQuarter;
	private static final Map<Integer, Double> ppProbabilityLessThanTwoAndHalf;
	private static final Map<Integer, Double> ppProbabilityLessThanThreeAndThreeQuarter;
	private static final Map<Integer, Double> ppProbabilityLessThanFive;
	
	static {
		initPpProbabilityForLessThanTwoAndHalf();
		initPpProbabilityForLessThanOneAndQuarter();
		initPpProbabilityForLessThanThreeAndThreeQuarter();
		initPpProbabilityForLessThanFive();
	}
	
	private static void initPpProbabilityForLessThanFive() {
		ppProbabilityLessThanFive = new Map<Integer, Double>();
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
		ppProbabilityLessThanThreeAndThreeQuarter = new Map<Integer, Double>();
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
		ppProbabilityLessThanOneAndQuarter = new Map<Integer, Double>();
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
		ppProbailityLessThanTwoAndHalf = new Map<Integer, Double>();
		ppProbailityLessThanTwoAndHalf.put(0, 100);
		ppProbailityLessThanTwoAndHalf.put(5, 97.7);
		ppProbailityLessThanTwoAndHalf.put(10, 93.8);
		ppProbailityLessThanTwoAndHalf.put(15, 87.9);
		ppProbailityLessThanTwoAndHalf.put(20, 74);
		ppProbailityLessThanTwoAndHalf.put(25, 60.7);
		ppProbailityLessThanTwoAndHalf.put(30, 42.6);
		ppProbailityLessThanTwoAndHalf.put(35, 26.7);
		ppProbailityLessThanTwoAndHalf.put(40, 16.8);
		ppProbailityLessThanTwoAndHalf.put(45, 9.1);
		ppProbailityLessThanTwoAndHalf.put(50, 3.6);
		ppProbailityLessThanTwoAndHalf.put(55, 2.1);
		ppProbailityLessThanTwoAndHalf.put(60, 1.1);
		ppProbailityLessThanTwoAndHalf.put(65, 0.4);
		ppProbailityLessThanTwoAndHalf.put(70, 0.4);
		ppProbailityLessThanTwoAndHalf.put(75, 0.1);
		ppProbailityLessThanTwoAndHalf.put(80, 0.3);
		ppProbailityLessThanTwoAndHalf.put(85, 0);
		ppProbailityLessThanTwoAndHalf.put(90, 0);
		ppProbailityLessThanTwoAndHalf.put(95, 0);
		ppProbailityLessThanTwoAndHalf.put(100, 0);	
	}
	
	public static Double getPpProbabilityForLessThanTwoAndHalf(Integer ppiScore){
		return ppProbabilityLessThanOneAndQuarter.get(ppiScore);
	}


	public static Double getPpProbabilityForLessThanOneAndQuarter(Integer ppiScore) {
		return ppProbailityLessThanTwoAndHalf.get(ppiScore);		
	}
	
	public static Double getPpProbabilityForLessThanThreeAndThreeQuarter(Integer ppiScore) {
		return 	ppProbabilityLessThanThreeAndThreeQuarter.get(ppiScore);
	}
	
	public static Double getPpProbabilityForLessThanFive(Integer ppiScore) {
		return ppProbabilityLessThanFive.get(ppiScore);
	}
}