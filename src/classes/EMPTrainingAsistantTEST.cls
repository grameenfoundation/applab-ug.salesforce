@isTest
private class EMPTrainingAsistantTEST {
	
	@isTest static void test_EMPTrainingAsistantBatchJob() {

		//create contact
		Contact contact = new Contact(LastName = 'Perez');
		insert contact;

		//create consultant
		EMP_Consultant__c consultor = new EMP_Consultant__c();
		consultor.EMP_Consultant_contact__c = contact.Id;
		consultor.Consultant_Name__c = 'Pepito Perez';
		insert consultor;

		EMP_Organization__c organizacion = new EMP_Organization__c();
		organizacion.Organization_Name__c = 'La organziación';
		insert organizacion;

		EMP_Organization_Member__c miembro = new EMP_Organization_Member__c();
		miembro.EMP_Organization__c = organizacion.Id;
		miembro.EMP_Organization_Member_Consultant__c = consultor.Id;
		insert miembro;

		EMP_Organization_Member_Beneficiary__c beneficiario = new EMP_Organization_Member_Beneficiary__c();
		beneficiario.Organization_Member__c = miembro.Id;
		beneficiario.ID_Number__c = '123';
		insert beneficiario;

		EMP_Organization_Member_Beneficiary__c beneficiario2 = new EMP_Organization_Member_Beneficiary__c();
		beneficiario2.Organization_Member__c = miembro.Id;
		beneficiario2.ID_Number__c = '12345';
		insert beneficiario2;

		EMP_Training__c training = new EMP_Training__c();
		training.EMP_Training__c = consultor.Id;
		training.Training_Name__c = 'Plantulación';
		insert training;

		EMP_Training_Assistant__c asistencia1 = new EMP_Training_Assistant__c();
		asistencia1.EMP_Training_Assistant__c = training.Id;
		asistencia1.Identification_Number__c = '123';
		asistencia1.Organization_Name__c = 'el plan';
		insert asistencia1;

		EMP_Training_Assistant__c asistencia2 = new EMP_Training_Assistant__c();
		asistencia2.EMP_Training_Assistant__c = training.Id;
		asistencia2.Identification_Number__c = '123';
		asistencia2.EMP_Organization_Member_Beneficiary__c = beneficiario.Id;
		asistencia2.EMP_Training_Assistant_Member__c = miembro.Id;
		asistencia2.Organization_Name__c = 'el plan';
		insert asistencia2;

		EMP_Training_Assistant__c asistencia3 = new EMP_Training_Assistant__c();
		asistencia3.EMP_Training_Assistant__c = training.Id;
		asistencia3.Identification_Number__c = '12345';
		asistencia3.Organization_Name__c = 'el plan';
		insert asistencia3;

		EMPTrainingAsistantBatchJob emptraining = new EMPTrainingAsistantBatchJob();

		Test.startTest();

		EMPTrainingAsistantBatchJob c = new EMPTrainingAsistantBatchJob();
       	Database.executeBatch(c);

        Test.stopTest();

	}
	
}