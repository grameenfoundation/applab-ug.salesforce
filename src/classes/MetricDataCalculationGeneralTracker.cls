global class MetricDataCalculationGeneralTracker {

    private Decimal totalActivePeople;
    private Decimal totalFemalePeople;
    private Decimal sumPovertyScore;

    global MetricDataCalculationGeneralTracker() {
        this.totalActivePeople = 0.0;
        this.totalFemalePeople = 0.0;
        this.sumPovertyScore = 0.0;
    }

    public Decimal getTotalActivePeople() {
        return this.totalActivePeople;
    }

    public void setTotalActivePeople(Decimal value) {
        this.totalActivePeople += value;
    }

    public Decimal getTotalFemalePeople() {
        return this.totalFemalePeople;
    }

    public void setTotalFemalePeople(Decimal value) {
        this.totalFemalePeople += value;
    }

    public Decimal getSumPovertyScore() {
        return this.sumPovertyScore;
    }

    public void setSumPovertyScore(Decimal value) {
        this.sumPovertyScore += value;
    }


    static testMethod void testConstruction() {
        MetricDataCalculationGeneralTracker tracker = new MetricDataCalculationGeneralTracker();
        tracker.setTotalActivePeople(3);
        System.assertEquals(tracker.getTotalActivePeople(), 3.0);
        tracker.setTotalFemalePeople(3);
        System.assertEquals(tracker.getTotalFemalePeople(), 3.0);
        tracker.setSumPovertyScore(3.0);
        System.assertEquals(tracker.getSumPovertyScore(), 3.0);
    }
}