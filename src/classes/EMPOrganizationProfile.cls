public class EMPOrganizationProfile {
	public ApexPages.StandardController stdController;
    public EMP_Organization__c organization;
    public EMP_Organization__c organizationId;
    public List<EMP_Farm_BPA_Checklist__c> bpaCheckList;
    public List<AggregateResult> socios;
    public List<AggregateResult> sociosQuantity;
    public EMP_Farm_Baseline__c[] farmBaseline = new List<EMP_Farm_Baseline__c>();
    public List<AggregateResult> replicaActiva;
    public List<AggregateResult> replicaInactiva;
    public List<AggregateResult> inscripcionTraining;
    public List<AggregateResult> trainingAssitance;
    public List<AggregateResult> trainingAssitanceSocio;
    public List<Id> orgConsultants = new List<Id>();
    public List<Id> trainingsIds = new List<Id>();
     
	public EMPOrganizationProfile(ApexPages.StandardController controller) {
		this.stdController = controller;
        this.organization= (EMP_Organization__c)controller.getRecord();  
        EMP_Organization__c [] organizationIds = [Select Id, Organization_Name__c, RUT__c From EMP_Organization__c Where Id =:organization.Id];
        if (organizationIds.size() > 0) {
	        organizationId = organizationIds[0];
            getOrgConsultant();
            getTraining();
	    }
	}

	public EMP_Organization__c getOrganizationId() {
	    return organizationId;
	}

	public List<EMP_Farm_BPA_Checklist__c> getBpaCheckList() {
        List<EMP_Farm_BPA_Checklist__c> bpaCheckList = [Select mayores__c, menores__c, fundamentales__c, Mayores_cumplidas__c, Menores_cumplidas__C, Fundamentales_cumplidas__c
                                                                    From EMP_Farm_BPA_Checklist__c
                                                                    where EMP_Farm_BPA_Checklist__r.EMP_Farm__r.EMP_Organization__c = :organizationId.Id and EMP_Farm_BPA_Checklist__r.EMP_Farm__r.deseaRegistrarReplicaParcela__c = 'Parcela de aprendizaje'];
    	return bpaCheckList ;
    }

    public List<Data> getParcelaData(){
    	List<Data> data = new List<Data>();
	    for (EMP_Farm_BPA_Checklist__c ar : getBpaCheckList()) {
	        data.add(new Data('Fundamentales',(Integer) ar.fundamentales__c,(Integer) ar.Fundamentales_cumplidas__c));
	        data.add(new Data('Mayores',(Integer) ar.mayores__c,(Integer) ar.Mayores_cumplidas__c));
	        data.add(new Data('Menores',(Integer) ar.menores__c,(Integer) ar.Menores_cumplidas__c));
	    }
	    return data;
	}

    public class Data {
        public String name { get; set; }
        public Integer total { get; set; }
        public Integer cumplidas { get; set; }
        public Data(String name, Integer total, Integer cumplidas) {
            this.name = name;
            this.total = total;
            this.cumplidas = cumplidas;
        }
    }

	public List<AggregateResult> getSocios() {
		List<AggregateResult> socios = [Select Count (Id) i, Gender__c nm
                                                                    From EMP_Organization_Member_Beneficiary__c
                                                                    where Organization_Member__r.EMP_Organization__c =:organizationId.Id 
                                                                    and Is_member__c = 'Sí'
                                                                    group by  Gender__c];
		return socios;
    }

    public List<SociosData> getSociosData(){
	    List<SociosData> data = new List<SociosData>();
		for (AggregateResult ar : getSocios()) {
	        data.add(new SociosData((String) ar.get('nm'),(Integer) ar.get('i')));
	    }
	    return data;
	}

	public class SociosData{

        public String name { get; set; }
        public Integer data { get; set; }
        public SociosData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }

    public List<AggregateResult> getSociosQuantity() {
        List<AggregateResult> sociosQuantity = [Select Count (Id) i
                                                                    From EMP_Organization_Member_Beneficiary__c
                                                                    where Organization_Member__r.EMP_Organization__c =:organizationId.Id 
                                                                    and Is_member__c = 'Sí'];
       	return sociosQuantity;
    }

    public List<SociosQuantityData> getSociosQuantityData(){
	    List<SociosQuantityData> data = new List<SociosQuantityData>();
		for (AggregateResult ar : getSociosQuantity()) {
	        data.add(new SociosQuantityData('Cantidad Socios',(Integer) ar.get('i')));
	    }
	    return data;
	}

	public class SociosQuantityData {

        public String name { get; set; }
        public Integer data { get; set; }
        public SociosQuantityData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }

    public List<EMP_Farm_Baseline__c> getBaseline() {
		if (organization != null) {
        	List<EMP_Farm_Baseline__c> farmBaseline = [Select Id, EMP_Farm_Baseline__c, Reference_Total_Area__c, Sowing_Area__c, Total_Cultivated_Area__c
                                                                    From EMP_Farm_Baseline__c
                                                                    where EMP_Farm_Baseline__r.EMP_Farm__r.EMP_Organization__c =:organizationId.Id  and EMP_Farm_Baseline__r.EMP_Farm__r.deseaRegistrarReplicaParcela__c = 'Parcela de aprendizaje'];
    		if (farmBaseline.size() > 0) {
	       		return farmBaseline;
	   		}
		}
		return null;
	}
	public List<AggregateResult> getReplicaActiva() {
        List<AggregateResult> replicaActiva = [Select Count (Id) i
                                                                    From EMP_Organization_Member__c
                                                                    where EMP_Organization__c =:organizationId.Id 
                                                                    and deseaRegistrarReplicaParcela__c != 'Parcela de aprendizaje'
                                                                    and reasonToRetire__c = 'Activo'];
       	return replicaActiva;
    }
    public List<AggregateResult> getReplicaInactiva() {
        List<AggregateResult> replicaInactiva = [Select Count (Id) i
                                                                    From EMP_Organization_Member__c
                                                                    where EMP_Organization__c =:organizationId.Id 
                                                                    and deseaRegistrarReplicaParcela__c != 'Parcela de aprendizaje'
                                                                    and reasonToRetire__c != 'Activo'];
       	return replicaInactiva;
    }

    public List<ReplicaData> getReplicaData(){
	    List<ReplicaData> data = new List<ReplicaData>();
		for (AggregateResult activos : getReplicaActiva()) {
			for(AggregateResult inactivos : getReplicaInactiva()){
	        	data.add(new ReplicaData('Activas',(Integer) activos.get('i')));
	        	if(inactivos.get('i')!=0){
	        		data.add(new ReplicaData('Inactivas',(Integer) inactivos.get('i')));
	        	}
	    	}
	    }
	    return data;
	}

	public class ReplicaData {
        public String name { get; set; }
        public Integer data { get; set; }
        public ReplicaData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }

    public List<AggregateResult> getInscripcionTraining() {
        List<AggregateResult> inscripcionTraining = [Select Count (Id) i, EMP_Training_Enrollment__r.Consultant_Name__c nm
                                                                    From EMP_Training_Enrollment__c
                                                                    where EMP_Training_Enrollment__c in (Select EMP_Consultant__c From EMP_organization_consultant__c Where EMP_Organization__c= :organizationId.Id)
                                                                    group by EMP_Training_Enrollment__r.Consultant_Name__c];
    	return inscripcionTraining ;
    }

    public List<InscripcionTrainingData> getInscripcionTrainingData(){
	    List<InscripcionTrainingData> data = new List<InscripcionTrainingData>();
		for (AggregateResult ar : getInscripcionTraining()) {
	        data.add(new InscripcionTrainingData((String) ar.get('nm'),(Integer) ar.get('i')));
	    }
	    return data;
	}

	public class InscripcionTrainingData {

        public String name { get; set; }
        public Integer data { get; set; }
        public InscripcionTrainingData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }

    public List<Id> getOrgConsultant() {
        List<EMP_organization_consultant__c> orgConsultant = [Select EMP_Consultant__c
                                                                    From EMP_organization_consultant__c
                                                                    Where EMP_Organization__c = :organizationId.Id];
        for(EMP_organization_consultant__c orgc :orgConsultant){
            orgConsultants.add(orgc.EMP_Consultant__c);
        }
        return orgConsultants;
    }

    public List<EMP_Training__c> getTraining() {
        List<EMP_Training__c> trainings = [Select Id From EMP_Training__c
                                                                    Where EMP_Training__c in :orgConsultants];
        for(EMP_Training__c tr : trainings){
            trainingsIds.add(tr.Id);
        }
        return trainings;
    }
//falta agregar el Where
    public List<AggregateResult> getTrainingAsistance() {
        List<AggregateResult> trainingAssitance = [Select Count (Id) i, EMP_Training_Assistant__r.Training_Name__c nm
                                                                    From EMP_Training_Assistant__c
                                                                    Where EMP_Training_Assistant__c in: trainingsIds
                                                                    group by  EMP_Training_Assistant__r.Training_Name__c];
        return trainingAssitance;
    }

    public List<AggregateResult> getTrainingAssitanceSocio() {
        List<AggregateResult> trainingAssitanceSocio = [Select Count (Id) i
                                                                    From EMP_Training_Assistant__c
                                                                    Where EMP_Training_Assistant__c in :trainingsIds and EMP_Organization_Member_Beneficiary__r.Is_member__c = 'Sí'
                                                                    group by  EMP_Training_Assistant__r.Training_Name__c];
        return trainingAssitanceSocio;
    }

     public List<TrainingAsistanceData> getTrainingAsistanceData(){
        List<TrainingAsistanceData> data = new List<TrainingAsistanceData>();
        for (AggregateResult  tA : getTrainingAsistance()) {
            for (AggregateResult tAS : getTrainingAssitanceSocio()) {
                data.add(new TrainingAsistanceData((String) tA.get('nm'),(Integer) tA.get('i'),(Integer) tAS.get('i')));
            }
        }
        return data;
    }

    public class TrainingAsistanceData{
        public String name { get; set; }
        public Integer total_Asistentes { get; set; }
        public Integer socios_Asistentes { get; set; }
        public TrainingAsistanceData(String name, Integer total_Asistentes, Integer socios_Asistentes) {
            this.name = name;
            this.total_Asistentes = total_Asistentes;
            this.socios_Asistentes = socios_Asistentes;
        }
    }
}