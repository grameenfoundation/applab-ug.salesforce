global class ScheduledAverageMarketPricesCaculator implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        MisSubcountyMarketPrices.computeAllPrices();
        
    }
}