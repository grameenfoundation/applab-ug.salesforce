public with sharing class BSS_SurveyPageController {
	public String project {get; set;}
	public BSS_Project__c projectLabel {get; set;}
	public String ckw {get; set;}
	public BSS_CKW_Project__c  ckwLabel {get; set;}
	public Set<ID> billHeader= new Set<ID>();
	public List<BSS_Monthly_Bill_Detail__c> details {get; set;}
	public List<BSS_Monthly_Bill_Header__c> billHeaders { get; set; }


	
	public BSS_SurveyPageController() {
		
	}

	//get active project list to display on VFP
	public List<SelectOption> getBSSProjects() {
		list<BSS_Project__c> projects = [Select Id, Name__c
                                        From BSS_Project__c
                                        Where End_Date__c >= LAST_MONTH limit 150];
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('NoProject', 'Seleccione un Proyecto'));
		for (BSS_Project__c projc : projects) {
			
			options.add(new SelectOption(projc.Id, projc.Name__c));
		}
		return options;
	}

	//get active CKWs related to project selected list to display on VFP
	public List<SelectOption> getProjectsCKW() {
		List<SelectOption> option = new List<SelectOption>();
		List<BSS_CKW_Project__c> pjCKWs = new List<BSS_CKW_Project__c>();
		if (project == null || String.isEmpty(project)) {
			option.add(new SelectOption('NoProjectSelected', 'Seleccione un Proyecto primero'));
		}
		else {
			pjCKWs = [Select Id, CKW_Name__c 
						From BSS_CKW_Project__c 
						Where Project__c =:project and Status__c = 'Activo'];
		}
		option.add(new SelectOption('Todos los líderes', 'Seleccione un Líder'));
		for (BSS_CKW_Project__c lider : pjCKWs) {
			
			option.add(new SelectOption(lider.Id, lider.CKW_Name__c));
		}
		return option;

	}
	public PageReference executeSearch() {
		billHeader= new Set<ID>();
		//get bill headers to search the details
		if(ckw != 'Todos los líderes') {
			billHeaders = [Select Id, Bill_approval__c, BSS_CKW_Project__c
	                                            From BSS_Monthly_Bill_Header__c 
	                                            Where BSS_CKW_Project__c =:ckw and Month__c = LAST_MONTH and Bill_approval__c = False];
			for (BSS_Monthly_Bill_Header__c billH : billHeaders){ 
				billHeader.add(billH.Id);
			}

		}
		else{
			billHeaders = [Select Id, Bill_approval__c, BSS_CKW_Project__c
	                                            From BSS_Monthly_Bill_Header__c 
	                                            Where BSS_CKW_Project__r.Project__c =:project and Month__c = LAST_MONTH and Bill_approval__c = False];
			for (BSS_Monthly_Bill_Header__c billH : billHeaders){ 
				billHeader.add(billH.Id);
			}
		}
		//get details 
		details = [Select Survey_Name__c, Quantity__c, BSS_Monthly_Bill_Header__r.BSS_CKW_Project__r.CKW_Name__c, Survey__r.Survey__c, BSS_Monthly_Bill_Header__r.BSS_CKW_Project__r.Project__r.Name__c
		          From BSS_Monthly_Bill_Detail__c 
		          Where BSS_Monthly_Bill_Header__c in:billHeader and BSS_Monthly_Bill_Header__r.Month__c = LAST_MONTH order by BSS_Monthly_Bill_Header__r.BSS_CKW_Project__r.CKW_Name__c ];

		//get project labels to show on page
		if(project != 'NoProjectSelected') {
			projectLabel = [Select Name__c From BSS_Project__c Where Id = :project];
		}
		//get ckw labels to show on page
		if(ckw != 'Todos los líderes') {
			ckwLabel = [Select CKW_Name__c From BSS_CKW_Project__c Where Id = :ckw];
		}

		return null;
	}
	public void save() {

		//update de details modifications
		update details;

		//update field bill approval from monthly bill headers object
		for (BSS_Monthly_Bill_Header__c bill: billHeaders){ 
			bill.Bill_approval__c = True;
  		}
  		update billHeaders;
  		//show succes message
  		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Su revision y aprobacion a sido exitosa'));
	}
}