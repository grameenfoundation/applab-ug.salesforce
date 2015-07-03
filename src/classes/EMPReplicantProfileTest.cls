@isTest
private class EMPReplicantProfileTest {
	
	@isTest static void test_EMPReplicantProfile() {
		
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

		EMP_Leader__c lider = new EMP_Leader__c();
		lider.EMP_Leader__c = organizacion.Id;
		lider.EMP_Leader_Consultant__c = consultor.Id;
		insert lider;

		EMP_Farm__c finca = new EMP_Farm__c();
		finca.EMP_Farm__c = miembro.Id;
		finca.EMP_Farm_Leader__c = lider.Id;
		finca.Farm_Name__c = 'La Finquita';
		insert finca;

		EMP_Farm_BPA_Checklist__c bpa = new EMP_Farm_BPA_Checklist__c();
		bpa.EMP_Farm_BPA_Checklist__c = finca.Id;
		bpa.Batch_Inspection__c = 'SI';
		bpa.Batch_Corrective_Actions__c = 'SI';
		bpa.Quality_Seed_Area__c = 'SI';
		insert bpa;

		EMP_Farm_Baseline__c baseline = new EMP_Farm_Baseline__c();
		baseline.EMP_Farm_Baseline__c = finca.Id;
		insert baseline;

		EMP_Farm_Diagnostic_and_Targets__c diagnostic = new EMP_Farm_Diagnostic_and_Targets__c();
		diagnostic.Farm__c = finca.Id;
		insert diagnostic;

		EMP_Farm_Follow_Up__c followup = new EMP_Farm_Follow_Up__c();
		followup.Farm_diagnosis_and_targets__c = diagnostic.Id;
		insert followup;

		EMP_Technical_Assistance__c techAsistance = new EMP_Technical_Assistance__c();
		techAsistance.EMP_Technical_Assistance__c = finca.Id;
		techAsistance.EMP_Technical_Assistance_Consultant__c = consultor.Id;
		insert techAsistance;

		EMPReplicantProfile tp = new EMPReplicantProfile(new ApexPages.StandardController(miembro));

		tp.getOMId();
		System.assert(tp.organizationMemberId != null);

		tp.getTargetDiagnostic();
		System.assert(tp.farmTargetsDiagnostics != null);

		tp.getFollowUp();
		System.assert(tp.farmFollowUps != null);

		tp.getTechnicalAssistance();
		System.assert(tp.farmTechnicalAssistance != null);

		tp.getBaseline();
		System.assert(tp.farmBaseline != null);

		tp.getBpaCheckList();
		System.assert(tp.bpaCheckList == null);

		String testName = 'test';
		Integer testSize = 1000;
		Integer testSize2 = 1000;
		EMPReplicantProfile.Data innerClass = new EMPReplicantProfile.Data(testName, testSize, testSize2);
		List<EMPReplicantProfile.Data> testList = tp.getPieData();

        System.assert(testList != null);

	}
}