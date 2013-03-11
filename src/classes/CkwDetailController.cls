public class CkwDetailController {
	private CKW__c obj;

	public CkwDetailController(ApexPages.StandardController controller) {
		this.obj = (CKW__c)controller.getRecord();
	}

	public static testMethod void test() {
		CKW__c obj = new CKW__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(obj);
		CkwDetailController c = new CkwDetailController(sc);
	}
}