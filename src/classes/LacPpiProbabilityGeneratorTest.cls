/**
 * This class contains unit tests for validating the behavior of the LacPpiProbabilityGenerator
 *
 */
@isTest
private class LacPpiProbabilityGeneratorTest {

    static testMethod void test() {
		Integer ppiScore = 2;
		
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanOneAndQuarter(ppiScore), 81.1);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanTwoAndHalf(ppiScore), 100);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanThreeAndThreeQuarter(ppiScore), 100);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanFive(ppiScore), 100);
		
		ppiScore = 5;
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanOneAndQuarter(ppiScore), 71.6);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanTwoAndHalf(ppiScore), 97.7);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanThreeAndThreeQuarter(ppiScore), 99.1);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanFive(ppiScore), 99.9);
		
		ppiScore = 45;
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanOneAndQuarter(ppiScore), 3.2);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanTwoAndHalf(ppiScore), 9.1);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanThreeAndThreeQuarter(ppiScore), 20);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanFive(ppiScore), 35.2);
		
		ppiScore = 100;
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanOneAndQuarter(ppiScore), 0);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanTwoAndHalf(ppiScore), 0);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanThreeAndThreeQuarter(ppiScore), 0);
		system.assertEquals(LacPpiProbabilityGenerator.getPpProbabilityForLessThanFive(ppiScore), 0);
    }
}