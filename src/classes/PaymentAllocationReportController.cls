public with sharing class PaymentAllocationReportController {
	public Contact objectWithDate {get; set;}
	private String gfAccountNo = 'ABC';
	/* 
	Sale:
	1% e-Warehouse Fee
	
	o National ID
	o SMEP Client ID
	o Loan account number (DDA)
	o Savings account number
	o GF’s fees account number
	o Amount to be credited to GF’s SMEP account (1% of total sale)
	o Amount to be credited to loan account (to pay off loan balance)
	o Amount to be credited to savings account (balance of total sale minus loan repayment and e-warehouse fee)
	
	
	Sale_Farmer_Association.Amount_Applied__c per farmer what he gets for sale
	*/
	
	public DateTime startDate { get; set; }
	public String formDate { get; set; }
	
    public PaymentAllocationReportController() {
    	objectWithDate = new Contact();
    	formDate = Date.today().format();
    }
    
    public String currentDate{
    	get { return formDate; } 
    	set { formDate = value;}
    	
    }
    
    public List<PaymentAllocation> getPayments(){
    	List<PaymentAllocation> payments = new List<PaymentAllocation>();
    	
    	// if date is given in form, use that date
    	if(formDate != null){
    		try{
    			startDate = Date.parse(formDate);
    		}
    		catch(Exception e){
    			return payments;
    		}
    	}
    	   
    	// default date is today
    	if(startDate == null)
    	   startDate = Date.today();
    	
    	String query = 'SELECT Name, Person__r.First_Name__c, Person__r.Middle_Name__c, Person__r.Last_Name__c, Person__r.ID_Number__c, ' +
                       'Registered_By__r.First_Name__c, Registered_By__r.Middle_Name__c, Registered_By__r.Last_Name__c, ' +
                       '(SELECT Name, Balance__c, Loan_Account_No__c, Saving_Account_No__c FROM Loans__r), ' +
                       '(SELECT Id, Name, Amount_Applied__c, Fee_Due__c, Sale__r.Id, Sale__r.Name, Sale__r.Sale_Date__c, Sale__r.Total_Amount__c, Farmer__r.Name FROM Sale_Farmer_Associations__r WHERE Sale__r.Sale_Date__c = ' + startDate.format('yyyy-MM-dd') + ') ' + 
                       'FROM Farmer__c ' +
                       'WHERE Id IN (SELECT Farmer__c FROM Sale_Farmer_Association__c WHERE Sale__r.Sale_Date__c = ' + startDate.format('yyyy-MM-dd') + ')  ';
        
        List<Farmer__c> items = Database.query(query);
        
        for(Farmer__c f : items){
            String name = f.Person__r.First_Name__c + (f.Person__r.Middle_Name__c != null ? ' ' + f.Person__r.Middle_Name__c : '') + ' ' + f.Person__r.Last_Name__c;
            String vkw = '';
            if(f.Registered_By__r != null)
            	vkw = f.Registered_By__r.First_Name__c + (f.Registered_By__r.Middle_Name__c != null ? ' ' + f.Registered_By__r.Middle_Name__c : '') + ' ' + f.Registered_By__r.Last_Name__c;
            String nationalID = f.Person__r.ID_Number__c;
            String loanBalance = 'N/A';
            String loanAccount = 'N/A';
            String savingAccount = 'N/A';
            
            if(f.Loans__r.size() > 0){
                loanBalance = String.valueOf(f.Loans__r[0].Balance__c);
                loanAccount = String.valueOf(f.Loans__r[0].Loan_Account_No__c);
                savingAccount = String.valueOf(f.Loans__r[0].Saving_Account_No__c);
            }
            
            for(Sale_Farmer_Association__c sfa : f.Sale_Farmer_Associations__r){
                PaymentAllocation p = new PaymentAllocation();
                p.Name = name;
                p.FciID = f.Name;
                p.Vkw = vkw;
                p.SaleID = sfa.Sale__r.Name;
                p.SaleRefID = sfa.Sale__r.Id;
                p.SaleFarmerID = sfa.Name;
                p.SaleFarmerRefID = sfa.Id;
                p.NationalID = nationalID;
                //p.LoanBalance = loanBalance;
                //p.SavingAccountNo = savingAccount;
                //p.LoanAccountNo = savingAccount;
                //Integer amount = sfa.Amount_Applied__c.intValue();
                //Integer fee = ((Decimal)amount * 0.01).intValue();
                //Integer clientAmount = amount;// - fee;
                //p.GFAccountNo = gfAccountNo;
                p.FarmerAmount = String.valueOf( sfa.Amount_Applied__c.intValue());
                p.TotalAmount = String.valueOf(sfa.Sale__r.Total_Amount__c.intValue());
                //p.CreditGFFee = String.valueOf(fee);
                //p.CreditAccounts = String.valueOf(clientAmount);
                payments.add(p);
            }
            
        }
        System.debug('payments: ' + payments);
        
    	return payments;
    }
    
    public PageReference refresh(){
        return null;
    }
     
    public PageReference exportPage(){
        PageReference newPage = new PageReference('/apex/PaymentAllocationExport');
        return newPage;
    }
    
    public String getFileName(){
        return 'payment-allocation-' + DateTime.now().format('yyyyMMddHHmmss');
    }
    
    public class PaymentAllocation {
    	public String Name { get; set; }
    	public String FciID { get; set; }
        public String NationalID { get; set; }
        public String Vkw {get; set; }
        public String SaleID { get; set; }
        public String SaleRefID { get; set; }
        public String SaleFarmerID { get; set; }
        public String SaleFarmerRefID { get; set; }
        public String LoanBalance { get; set; }
        public String LoanAccountNo { get; set; }
    	public String SavingAccountNo { get; set; }
    	public String GFAccountNo { get; set; }
    	public String FarmerAmount { get; set; }
        public String TotalAmount { get; set; }
        public String CreditGFFee { get; set; }
    	public String CreditAccounts { get; set; }
    }
    
    
    
}