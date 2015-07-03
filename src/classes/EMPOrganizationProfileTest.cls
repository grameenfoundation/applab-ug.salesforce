@isTest
private class EMPOrganizationProfileTest {
    
    @isTest static void test_method_one() {
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

        EMP_organization_consultant__c consultororg = new EMP_organization_consultant__c();
        consultororg.EMP_Consultant__c = consultor.Id;
        consultororg.EMP_Organization__c = organizacion.Id;
        insert consultororg;

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

        EMPOrganizationProfile op = new EMPOrganizationProfile(new ApexPages.StandardController(organizacion));

        op.getOrganizationId();
        System.assert(op.organizationId != null);

        op.getBpaCheckList();
        System.assert(op.bpaCheckList == null);

        op.getSocios();
        System.assert(op.socios == null);

        op.getSociosQuantity();
        System.assert(op.sociosQuantity == null);

        op.getBaseline();
        System.assert(op.farmBaseline != null);

        op.getReplicaActiva();
        System.assert(op.replicaActiva == null);

        op.getReplicaInactiva();
        System.assert(op.replicaInactiva == null);

        op.getInscripcionTraining();
        System.assert(op.inscripcionTraining == null);

        op.getOrgConsultant();
        System.assert(op.orgConsultants.size() > 0);

        //op.getTraining();
        //System.assert(op.trainings != null);

        op.getTrainingAsistance();
        System.assert(op.trainingAssitance == null);

        op.getTrainingAssitanceSocio();
        System.assert(op.trainingAssitanceSocio == null);

        String testName = 'test';
        Integer testSize = 1000;
        Integer testSize2 = 1000;

        EMPOrganizationProfile.Data innerClass = new EMPOrganizationProfile.Data(testName, testSize, testSize2);
        List<EMPOrganizationProfile.Data> testList = op.getParcelaData();
        System.assert(testList != null);

        //EMPOrganizationProfile.PieWedgeData innerClass2 = new EMPOrganizationProfile.PieWedgeData(testName, testSize);
        //List<EMPOrganizationProfile.PieWedgeData> testList2 = op.getPieWedgeData();
        //System.assert(testList2 != null);

        EMPOrganizationProfile.SociosQuantityData innerClass3 = new EMPOrganizationProfile.SociosQuantityData(testName, testSize);
        List<EMPOrganizationProfile.SociosQuantityData> testList3 = op.getSociosQuantityData();
        System.assert(testList3 != null);

        EMPOrganizationProfile.ReplicaData innerClass4 = new EMPOrganizationProfile.ReplicaData(testName, testSize);
        List<EMPOrganizationProfile.ReplicaData> testList4 = op.getReplicaData();
        System.assert(testList4 != null);

        EMPOrganizationProfile.InscripcionTrainingData innerClass5 = new EMPOrganizationProfile.InscripcionTrainingData(testName, testSize);
        List<EMPOrganizationProfile.InscripcionTrainingData> testList5 = op.getInscripcionTrainingData();
        System.assert(testList5 != null);

        EMPOrganizationProfile.TrainingAsistanceData innerClass6 = new EMPOrganizationProfile.TrainingAsistanceData(testName, testSize, testSize);
        List<EMPOrganizationProfile.TrainingAsistanceData> testList6 = op.getTrainingAsistanceData();
        System.assert(testList6 != null);

    }
    
}