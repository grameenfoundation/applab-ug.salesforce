public class EMPReplicantProfile {

	public ApexPages.StandardController stdController;
    public EMP_Organization_Member__c organizationMember;
    public EMP_Farm_Diagnostic_and_Targets__c[] farmTargetsDiagnostics = new List<EMP_Farm_Diagnostic_and_Targets__c>();
    public EMP_Farm_Follow_Up__c[] farmFollowUps = new List<EMP_Farm_Follow_Up__c>();
    public EMP_Technical_Assistance__c[] farmTechnicalAssistance = new List<EMP_Technical_Assistance__c>();
    public EMP_Farm_Baseline__c[] farmBaseline = new List<EMP_Farm_Baseline__c>();
    public EMP_Organization_Member__c organizationMemberId;
    public List<EMP_Farm_BPA_Checklist__c> bpaCheckList;

	public EMPReplicantProfile(ApexPages.StandardController controller) {
		this.stdController = controller;
        this.organizationMember= (EMP_Organization_Member__c)controller.getRecord();  
        EMP_Organization_Member__c [] organizationMemberIds = [Select Id From EMP_Organization_Member__c Where Id =:organizationMember.Id];
        if (organizationMemberIds.size() > 0) {
	        organizationMemberId = organizationMemberIds[0];
	    }
    }

    public EMP_Organization_Member__c getOMId() {
	    return organizationMemberId;
	}

    public List<EMP_Farm_Diagnostic_and_Targets__c> getTargetDiagnostic() {
    	if (organizationMember != null) {
        	EMP_Farm_Diagnostic_and_Targets__c[] farmTargetsDiagnostics = [Select Id, Beans_To_Be_Harvested_Kg__c, BPA_Not_Implemented__c, Commercialization_to_date__c, Commercialized_Kg__c, Commitment_Agri_Input_Storage__c, Commitment_Agrochem_Management__c, Commitment_Registration__c, Commitment_Soil_Water_Analysis__c, Crop_Area__c, Crop_Stage__c, Farmer_signature__c, Green_Dried_Beans__c, kilos_plant_replica__c, kilos_will_plant_replica__c, Number_of_plots__c, Other_Destination_Sold_Product__c, Other_Reason_Agri_Input_Storage__c, Other_Reason_Agrochem_Management__c, Other_Reason_Not_Registration__c, Other_Reason_Soil_Water_Analysis__c, Other_Use_of_Resources__c, plant_spacing_cm__c, Price_Kg__c, Price_per_Kg_to_date__c, Production_Commercialized__c, Production_Kg__c, Production_to_date_Kg__c, Productive_sector__c, Reason_Agri_Input_Storage__c, Reason_Agrochem_Management__c, Reason_Registration__c, Reason_Soil_Water_Analysis__c, Requires_Org_Resources__c, row_spacing_cm__c, Use_of_Resources__c, Visit_Date__c, Visit_Number__c
                                                                    From EMP_Farm_Diagnostic_and_Targets__c
                                                                    where Farm__r.EMP_Farm__c =:organizationMemberId.Id ]; 
	        if (farmTargetsDiagnostics.size() > 0) {
	            return farmTargetsDiagnostics;
	        }
	    }
	    return null;
	}

	public List<EMP_Farm_Follow_Up__c> getFollowUp() {
		if (organizationMember != null) {
        	EMP_Farm_Follow_Up__c[] farmFollowUps = [Select Id, Agri_Input_Area_Locked__c, Agri_Input_ICA_Certified__c, Agri_Input_Storage__c, Beans_To_Be_Harvested_Kg__c, Commercialization_Registration__c, Commercialization_to_date__c, Commercialized_Kg__c, Criteria_accomplishment_Facilities__c, Criteria_accomplishment_Register__c, Criteria_accomplishment_Soil_and_Water__c, Criteria_accomplisment_Agrochemical__c, Crop_Area__c, Crop_Stage__c, Destination_Sold_Product__c, Dose_Area_Marked__c, Empty_Containers_Properly_Disposed__c, Existing_Soil_Analysis__c, Farm_diagnosis_and_targets__c, Farmer_Signature__c, Fertilizers_Use_Registration__c, Fire_Extinguisher_Visible__c, First_Aid_Kit__c, Green_Dried_Beans__c, Harvest_Registration__c, Input_Spill_Kit__c, Kilos_plant_replica__c, Kilos_will_plant__c, Labor_Registration__c, Other_Destination_Sold_Product__c, Other_Use_of_Resources__c, Percentage_of_compliance_Agrochemicals__c, Percentage_of_compliance_Facilities__c, Percentage_of_compliance_Register__c, Percentage_of_compliance_Soil_and_Water__c, Personal_Protection_Equipment__c, Pesticide_Separated_From_Fertilizers__c, Pesticide_Use_Registration__c, Photo_visit__c, plant_spacing_cm__c, Price_Kg__c, Price_per_Kg_to_date__c, Production_Commercialized__c, Production_Kg__c, Production_to_date_Kg__c, Productive_sector__c, Requires_Org_Resources__c,Row_spacing_cm__c, Soil_Analysis_Interpreted_for_Fert_Plan__c, Soil_Conservancy_Practices__c, Surveyor_Signature__c, Use_of_Resources__c, Visit_Date__c, Visit_Number__c, Water_Quality_Evaluated__c
                                                                    From EMP_Farm_Follow_Up__c
                                                                    where Farm_diagnosis_and_targets__r.Farm__r.EMP_Farm__c =:organizationMemberId.Id];
    		if (farmFollowUps.size() > 0) {
	         	return farmFollowUps;
	        }
	    }
	    return null;
	}

	public List<EMP_Technical_Assistance__c> getTechnicalAssistance() {
		if (organizationMember != null) {
        	EMP_Technical_Assistance__c[] farmTechnicalAssistance = [Select Date__c, EMP_Technical_Assistance__c, EMP_Technical_Assistance_Consultant__c, Identification_Number__c, NIT__c, Organization_Name__c, Productive_Sector__c, Recommendations_Next_Visit__c, Situation_Property__c, Visit_Number__c, Visit_To__c, Which__c
                                                                    From EMP_Technical_Assistance__c
                                                                    where EMP_Technical_Assistance__r.EMP_Farm__c =:organizationMemberId.Id];
    		if (farmTechnicalAssistance.size() > 0) {
	       		return farmTechnicalAssistance;
	   		}
		}
		return null;
	}

	public List<EMP_Farm_Baseline__c> getBaseline() {
		if (organizationMember != null) {
        	List<EMP_Farm_Baseline__c> farmBaseline = [Select Agrochemicals_Disposal__c, Amount__c, BPA_Certified__c, Children_Participation__c, Commercialization_Agreements__c, Commercialization_Location__c, Crop_Product__c, Crop_Rotation__c, Cycle_Applications__c, Economic_Activity__c, EMP_Farm_Baseline__c, Employees__c, Employees_Training__c, Growing_Infrastructure__c, Income_Composition__c, Institution_Type__c, Irrigation_System__c, Irrigation_System_Origin__c, Minimal_Tillage__c, Mobile_Phone__c, Monthly_Income__c, Num_Employees__c, Organization_Name__c, Packages__c, Permanent_Employees__c, Population_Type__c, Price_Kilo__c, Processing_Product__c, Processing_Product_Commercialization__c, Processing_Product_Location__c, Processing_Type__c, Production_Costs__c, Productive_Sector__c, Products_Traded__c, Reference_Total_Area__c, Requires_Credit__c, Scholarship_Level__c, Slope_Planting__c, Sowing_Area__c, Temporary_Employees__c, Total_Cultivated_Area__c, Triple_Washed__c, Under_Eighteen__c, User_Credit__c, Vulnerable_population__c, Wastewater_Management__c, Water_Concession__c
                                                                    From EMP_Farm_Baseline__c
                                                                    where EMP_Farm_Baseline__r.EMP_Farm__c =:organizationMemberId.Id ];
    		if (farmBaseline.size() > 0) {
	       		return farmBaseline;
	   		}
		}
		return null;
	}

	public List<EMP_Farm_BPA_Checklist__c> getBpaCheckList() {
        List<EMP_Farm_BPA_Checklist__c> bpaCheckList = [Select mayores__c, menores__c, fundamentales__c, Mayores_cumplidas__c, Menores_cumplidas__C, Fundamentales_cumplidas__c
                                                                    From EMP_Farm_BPA_Checklist__c
                                                                    where EMP_Farm_BPA_Checklist__r.EMP_Farm__c =:organizationMemberId.Id ];
                                                                    
    return bpaCheckList ;
    }

    public List<Data> getPieData(){

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
}