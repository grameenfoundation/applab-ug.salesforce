public with sharing class EMPTrainingasistantHandler {

	public EMP_Training_Assistant__c empTA;

	public EMPTrainingasistantHandler(EMP_Training_Assistant__c et) {
		empTA = et;

	}

	public void Handle(){
		for(List<EMP_Organization_Member_Beneficiary__c> beneficiaries : [SELECT Id, Organization_Member__c, Organization_Member__r.Id, ID_Number__c FROM EMP_Organization_Member_Beneficiary__c WHERE ID_Number__c like :empTA.Identification_Number__c]){
			for(EMP_Organization_Member_Beneficiary__c beneficiary : beneficiaries){
				empTA.EMP_Organization_Member_Beneficiary__c = beneficiary.Id;
				empTA.EMP_Training_Assistant_Member__c = beneficiary.Organization_Member__c;
				update empTA;
			}
		}
	}
}