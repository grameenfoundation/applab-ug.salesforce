public with sharing class LacPublicDashboardController {

	/* OPS TAB */
	public List<SampleDataTable> getOpsData() {
        List<SampleDataTable> data = new List<SampleDataTable>();
        
        addData(data, 'Number of farmers reached', '400', '203', '100');
        addData(data, 'Number of interactions', '1,000,000', '700,000', '200,000');
        addData(data, '% Active users', '30%', '32%', '24%');
        addData(data, 'Number of CKWs', '350', '452', '130');
        addData(data, 'Number of mobile-enabled extension agents', '100', '73', '26');
        addData(data, '% CKWs in high performance category', '50%', '34%', '40%');
        
        return data;
    }
    
	/* FAIRTRADE TAB */
	public List<SampleDataTable> getFairtradeData() {
        List<SampleDataTable> data = new List<SampleDataTable>();
        
        addData(data, 'Number of coops served', '40', '23', '10');
        addData(data, 'Total capital deployed to coops', '450,000', '244,000', '50,000');
        addData(data, 'Number of loans disbursed to farmers', '350', '452', '130');
        addData(data, 'Number of loans disbursed to farmers', '350', '452', '130');
        addData(data, 'Average loan size', '3000', '1350', '1350');
        return data;
    }
    
	/* CERT PROD TAB */
    public List<SampleDataTable> getCertProdData() {
        List<SampleDataTable> data = new List<SampleDataTable>();
        
        addData(data, 'Average certification score (cumulative through previous quarter)', '78', '34', '23', '11');
        addData(data, 'Number of farmers certified (cumulative through previous quarter)', '145', '345', '234', '125');
        addData(data, ' - Fairtrade', '70', '60', '50', '65');
        addData(data, ' - Global gap', '30', '78', '23', '12');
        addData(data, ' - Rainforest', '25', '13', '42', '14');
        addData(data, ' - Starbucks practices', '10', '23', '1', '87');
        addData(data, ' - UTZ', '10', '78', '12', '90');
        addData(data, 'Average % increase in coop sales in Kgs (per quarter)', '34%', '30%', '56%', '29%');
        addData(data, 'Average increase in revenue from sales due to certification premium (YTD)', '12%', '32%', '10%', '40%');
        addData(data, 'Average kilos produced by farmer (for that quarter)', '3,400', '5,600', '1,000', '2,200');
        addData(data, 'Price differential for certified vs. non-certified crop (daily)', '500', '230', '735', '200');
        return data;
    }


    /* SOCIAL IMPACT TAB */
    public class SampleDataTable {
        Public String name {get;set;}
        Public String value1 {get;set;}
        Public String value2 {get;set;}
        Public String value3 {get;set;}
        Public String value4 {get;set;}
    }
    
    public List<SampleDataTable> getSocialImpactData() {
        List<SampleDataTable> data = new List<SampleDataTable>();
        
        addData(data, '% Farmers reporting adoption', '3%', '3%', '2%');
        addData(data, '% Families moving out of poverty', '0.5%', '1%', '0%');
        addData(data, '% Families improving food security', '3%', '2%', '1.5%');
        return data;
    }

    public void addData(List<SampleDataTable> data, String name, String target, String actual, String previous) {
        addData(data, name, target, actual, previous, null);
    }
    
    public void addData(List<SampleDataTable> data, String name, String value1, String value2, String value3, String value4) {
    	SampleDataTable item = new SampleDataTable();
        item.name = name;
        item.value1 = value1;
        item.value2 = value2;
        item.value3 = value3;
        item.value4 = value4;
        data.add(item);	
    }
    
    /* HOME TAB: SUMMARY TABLE */
    public List<SampleDataTable> getHomepageSummaryData() {
        List<SampleDataTable> data = new List<SampleDataTable>();
        
        addData(data, 'Total farmers reached', '200');
        addData(data, 'Total interactions', '2,300');
        addData(data, 'Total number of trusted intermediaries', '30');
        addData(data, 'Total number of coops', '4');
        addData(data, 'Total capital deployed', '$45,000');
        addData(data, '% Adoption - current quarter', '10.4%');
        addData(data, '% Certification - current quarter', '23%');
        return data;
    }

    public void addData(List<SampleDataTable> data, String name, String value) {
        addData(data, name, value, null, null, null);
    }
}