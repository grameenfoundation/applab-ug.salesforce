global class PulseController {
	private final static String NAMESPACE = 'http://schemas.applab.org/2010/08/pulse';
	private final static String REQUEST_ELEMENT_NAME = 'GetTabsRequest';
	private final static String RESPONSE_ELEMENT_NAME = 'GetTabsResponse';
	private final static String TAB_ELEMENT_NAME = 'Tab';
	private final static String NAME_ATTRIBUTE = 'name';
	private final static String HASH_ATTRIBUTE = 'hash';
	private final static String HAS_CHANGED_ATTRIBUTE = 'hasChanged';
	private static CKW__c cachedCkwObject; // Help cache the Ckw Object
	private static Person__c cachedPersonObject; // Help cache the Person Object
	public static String language {get; set;}
	public String submissionResult {get; set;}

	public PulseController() {
		setLanguage();
	}

	// given a post body like:
	// <?xml version='1.0'?>
	// <GetTabsRequest xmlns='http://schemas.applab.org/2010/08/pulse'>
	// <Tab name='Messages' hash='xvq85dcvsjw' />
	// <Tab name='Performance' hash='ov9rdcvaccw' />
	// </GetTabsRequest>
	//
	// returns a response like:
	// <?xml version='1.0'?>
	// <GetTabsResponse xmlns='http://schemas.applab.org/2010/08/pulse' hasChanged='true'>
	// <Tab name='Messages' hash='updated_hash'>updated tab content</Tab>
	// <Tab name='Performance' hasChanged='false' />
	// ...
	// </GetTabsResponse>
	public String getResponseXml() {
		DOM.Document requestXml = new DOM.Document(); 
		String requestXmlData = ApexPages.currentPage().getParameters().get('data');
		if(requestXmlData == null) {
			return getErrorResponse(Label.Error_Malformed_Xml);
		}
		requestXml.load(requestXmlData);
		GetTabsRequest parsedRequest = new GetTabsRequest();
		parsedRequest.parseRequest(requestXml);

		// Get the new tabs
		String handsetId = getHandsetId();
		if (handsetId == null) {
			return getErrorResponse(Label.Error_HandsetId_Not_In_Header);
		}
		System.debug(handsetId);

		List<TabInfo> updatedTabs = generateTabs(handsetId);

		// And run a change comparison to determine the updates
		boolean haveChanges = false;
		for (TabInfo tab : updatedTabs) {
			String tabName = tab.getName();
			String oldHash = parsedRequest.getHash(tabName);
			if (tab.checkIfChanged(oldHash)) {
				haveChanges = true;
			}
		}

		String response = '';
		if (!haveChanges) {
			response += '<' + RESPONSE_ELEMENT_NAME + ' xmlns="' + NAMESPACE + '" ' + HAS_CHANGED_ATTRIBUTE + '="false"></' + RESPONSE_ELEMENT_NAME + '>';
		} else {
			response += '<' + RESPONSE_ELEMENT_NAME + ' xmlns="' + NAMESPACE + '">';
			for (TabInfo tab : updatedTabs) {
				if(tab.getHasChanged()) {
					response += '<' + TAB_ELEMENT_NAME + ' ' + NAME_ATTRIBUTE + '="' + tab.getName() + '" '+ HASH_ATTRIBUTE + '="' + tab.getHash() + '">';
					response += escapeText(tab.getContent());
				} else {
					response += '<' + TAB_ELEMENT_NAME + ' ' + NAME_ATTRIBUTE + '="' + tab.getName() + '" '+ HASH_ATTRIBUTE + '="' + tab.getHash() + '" ' + HAS_CHANGED_ATTRIBUTE + '="false">';
				}
				response += '</' + TAB_ELEMENT_NAME + '>';
			}
			response += '</' + RESPONSE_ELEMENT_NAME + '>';
		} 

		return response;
	}

	private static String escapeText(String rawText) {
		String escapedText = '';
		for(Integer i = 0; i < rawText.length(); i++) {
			String currentCharacter = rawText.substring(i, i+1);
			if(currentCharacter.equals('<')) {
				escapedText += '&lt;';
			} else if(currentCharacter.equals('>')) {
				escapedText += '&gt;';
			} else if(currentCharacter.equals('"')) {
				escapedText += '&quot;';
			} else if(currentCharacter.equals('\'')) {
				escapedText += '&apos;';
			} else if(currentCharacter.equals('&')) {
				escapedText += '&amp;';
			} else { 
				escapedText += currentCharacter;
			}
		}
		return escapedText;
	}

	private static List<TabInfo> generateTabs(String handsetId) {
		List<TabInfo> tabs = new List<TabInfo>();

		// TODO: update this code to dynamically get the tabs from Salesforce
		TabInfo messagesInfo = getMessagesTab(handsetId);
		if (null != messagesInfo) {
			tabs.add(messagesInfo);
		}

		TabInfo performanceInfo = getPerformanceTab(handsetId);
		if (null != performanceInfo) {
			tabs.add(performanceInfo);
		}

		TabInfo supportInfo = getSupportTab(handsetId);
		if (null != supportInfo) {
			tabs.add(supportInfo);
		}

		TabInfo profileInfo = getProfileTab(handsetId);
		if (null != profileInfo) {
			tabs.add(profileInfo);
		}

		return tabs;
	}

	private static TabInfo getMessagesTab(String handsetId) {
		return new TabInfo(Label.Pulse_Messages_Tab, PulseMessagesTab.getMessageListHtml(handsetId));
	}

	private static TabInfo getPerformanceTab(String handsetId) {
		String tabContent = '';
		List<String> performanceReplacements = new List<String>();
		CKW__c ckw = getCkw(handsetId);
		if(ckw == null) {
			tabContent = Label.Error_No_Ckw_For_Handset;
		} else {
			if(null == ckw.Current_Performance_Review__c) {
				tabContent = Label.Error_No_Performance_Record;
			} else {
				CKW_Performance_Review__c performance = ckw.Current_Performance_Review__r;
				performanceReplacements.add(String.valueOf((Object)performance.Total_Surveys_Submitted__c));
				performanceReplacements.add(String.valueOf((Object)performance.Surveys_Approved__c));
				performanceReplacements.add(String.valueOf((Object)performance.Surveys_Rejected__c));
				performanceReplacements.add(String.valueOf((Object)performance.Surveys_Not_Reviewed__c));
				
				Decimal totalSearches = (performance.Total_Searches__c == null)?0:performance.Total_Searches__c;
				Decimal totalInvalidSearches = (performance.Number_Of_Invalid_Searches_Running_Total__c == null)?0:performance.Number_Of_Invalid_Searches_Running_Total__c;
				Decimal totalTestSearches = (performance.Number_Of_Test_Searches_Running_Total__c == null)?0:performance.Number_Of_Test_Searches_Running_Total__c;
				
				performanceReplacements.add(String.valueOf(totalSearches + totalInvalidSearches + totalTestSearches));
				performanceReplacements.add(String.valueOf(totalSearches));
				performanceReplacements.add(String.valueOf(totalInvalidSearches));
				performanceReplacements.add(String.valueOf(totalTestSearches));
				performanceReplacements.add(String.valueOf((Object)performance.Farmers_Registered__c));

				// Days remaining
				if(Date.today().daysBetween(Date.today().addMonths(1).toStartOfMonth()) > 7) {
					performanceReplacements.add(String.valueOf((Date.today().daysBetween(Date.today().addMonths(1).toStartOfMonth()) / 7.0).setScale(2)) + ' weeks');
				} else {
					performanceReplacements.add(String.valueOf(Date.today().daysBetween(Date.today().addMonths(1).toStartOfMonth())) + ' days');
				}

				tabContent = String.format(Label.Pulse_Performance_Tab_Content, performanceReplacements);
			}
		}
		return new TabInfo(Label.Pulse_Performance_Tab, tabContent + PulseEmbeddedBrowserHelpers.getPageLoadCompleteString());
	}

	private static TabInfo getSupportTab(String handsetId) {
		return new TabInfo(Label.Pulse_Support_Tab, PulseSupportTab.getSupportFormHtml(handsetId, Site.getCurrentSiteUrl()));
	}

	public void processSubmission() {
		String imei = getHandsetId();
		String type = ApexPages.currentPage().getParameters().get('supportType');
		String message = ApexPages.currentPage().getParameters().get('supportText');
		Person__c person = getPerson(imei);

		if(person == null) {
			this.submissionResult = PulseSupportTab.getSubmissionResponse(imei, Label.Error_No_Person_For_Handset, true, Site.getCurrentSiteUrl());
			return;
		}

		if(message == null || message.equals('')) {
			this.submissionResult = PulseSupportTab.getSubmissionResponse(imei, Label.Error_Invalid_Pulse_Support_Input, true, Site.getCurrentSiteUrl());
			return;
		}

		this.submissionResult = PulseSupportTab.processSubmission(imei, type, message, person, Site.getCurrentSiteUrl());
	}

	private static TabInfo getProfileTab(String handsetId) {
		String tabContent = '';
		List<String> profileReplacements = new List<String>();
		CKW__c ckw = getCkw(handsetId);
		Person__c person = getPerson(handsetId);

		if(person == null) {
			tabContent = Label.Error_No_Person_For_Handset;
		} else {
			// ID:
				if(ckw != null) {
					profileReplacements.add(ckw.Name);
				} else {
					profileReplacements.add(person.Name);
				}

				// Name:
				profileReplacements.add(person.First_Name__c + ' ' + person.Last_Name__c);

				// Location
				profileReplacements.add(person.Subcounty__c + ', ' + person.Parish__c + ', ' + person.Village__c);

				// Phone Id
				profileReplacements.add(person.Handset__r.IMEI__c);

				// Phone number
				if(null != person.Handset__r.SIM__r) {
					profileReplacements.add(person.Handset__r.SIM__r.Name);
				} else {
					profileReplacements.add(' ');
				}

				tabContent = String.format(Label.Pulse_Profile_Tab_Content, profileReplacements);
		}

		return new TabInfo(Label.Pulse_Profile_Tab, tabContent + PulseEmbeddedBrowserHelpers.getPageLoadCompleteString());
	}

	private static CKW__c getCkw(String handsetId) {
		if(cachedCkwObject == null) {
			CKW__c[] ckws = [Select Name, Id, Person__r.First_Name__c, 
			                 Current_Performance_Review__r.Total_Surveys_Submitted__c, 
			                 Current_Performance_Review__r.Surveys_Approved__c, 
			                 Current_Performance_Review__r.Surveys_Rejected__c,
			                 Current_Performance_Review__r.Surveys_Not_Reviewed__c,
			                 Current_Performance_Review__r.Total_Searches__c,
			                 Current_Performance_Review__r.Number_Of_Invalid_Searches_Running_Total__c,
			                 Current_Performance_Review__r.Number_Of_Test_Searches_Running_Total__c,
			                 Current_Performance_Review__r.Farmers_Registered__c
			                 from CKW__c WHERE Person__r.Handset__r.IMEI__c =: handsetId];
			if(ckws.size() > 0) {
				cachedCkwObject = ckws[0];
			}
		}
		return cachedCkwObject;
	}

	private static Person__c getPerson(String handsetId) {
		if(cachedPersonObject == null) {
			Person__c[] people = [Select Name, Id, First_Name__c, Last_Name__c, Parish__c, Village__c, Subcounty__c, Handset__r.IMEI__c, Handset__r.SIM__r.Name from Person__c WHERE Handset__r.IMEI__c =: handsetId];
			if(people.size() > 0) {
				cachedPersonObject = people[0];
			}
		}
		return cachedPersonObject;
	}

	private void setLanguage() {
		language = ApexPages.currentPage().getHeaders().get('x-lang');
		if(language == null) {
			language = ApexPages.currentPage().getParameters().get('lang');
			if(language == null) {
				language =  'en';
			}
		}

		System.debug('Language:');
		System.debug(language);
	}

	private string getErrorResponse(String responseText) {
		return '<GetTabsResponse xmlns=\'http://schemas.applab.org/2010/08/pulse\' hasChanged=\'true\'><Tab name=\'' + Label.Pulse_Error_Tab + '\' hash=\'updated_hash\'>' + responseText + '</Tab></GetTabsResponse>';
	}

	private static String getHandsetId() {
		Map<String, String> headers = ApexPages.currentPage().getHeaders();
		if(headers.containsKey('x-Imei')) {
			return headers.get('x-Imei');
		}

		if(headers.containsKey('handsetId')) {
			return headers.get('handsetId');
		}

		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		if(parameters.containsKey('handsetId')) {
			return parameters.get('handsetId');
		}

		return null;
	}

	private class GetTabsRequest {
		// mapping from tab name to hash value
		private Map<String, String> tabHashes;

		private GetTabsRequest() {
			this.tabHashes = new Map<String, String>();
		}

		public String getHash(String tabName) {
			return this.tabHashes.get(tabName);
		}

		public GetTabsRequest parseRequest(DOM.Document requestXml) {
			System.assert (requestXml != null);
			GetTabsRequest getTabsRequest = null;

			// <GetTabsRequest xmlns='http://schemas.applab.org/2010/08/pulse'>
			DOM.XMLNode rootNode = requestXml.getRootElement();
			if (NAMESPACE.equals(rootNode.getNamespace()) && REQUEST_ELEMENT_NAME.equals(rootNode.getName())) {
				getTabsRequest = new GetTabsRequest();

				// parse the collection of Tabs
				for (DOM.XMLNode childNode: rootNode.getChildElements()) {
					String tabName = '';
					String tabHash = '';
					if (childNode.getNodeType() == DOM.XMLNodeType.ELEMENT && NAMESPACE.equals(childNode.getNamespace())) {
						if (TAB_ELEMENT_NAME.equals(childNode.getName())) {
							// <Tab name='Performance' hash='ov9rdcvaccw' />
							DOM.XMLNode tabElement = childNode;
							if (childNode.getAttributeCount() > 0) {
								for (Integer i = 0; i< childNode.getAttributeCount(); i++ ) {        
									if(childNode.getAttributeKeyAt(i).equals(NAME_ATTRIBUTE)) {
										tabName = childNode.getAttributeValue(childNode.getAttributeKeyAt(i), childNode.getAttributeKeyNsAt(i));
									}

									if(childNode.getAttributeKeyAt(i).equals(HASH_ATTRIBUTE)) {
										tabHash = childNode.getAttributeValue(childNode.getAttributeKeyAt(i), childNode.getAttributeKeyNsAt(i));
									}
								}
							}
							getTabsRequest.tabHashes.put(tabName, tabHash);
						}
					}
				}
			}
			return getTabsRequest;
		}
	}

	static testMethod void testPulseController() { 
		PulseController ctrl = new PulseController();
		ctrl.getResponseXml();
		ApexPages.currentPage().getParameters().put('data', '<GetTabsRequest xmlns=\'http://schemas.applab.org/2010/08/pulse\' hasChanged=\'true\'></GetTabsRequest>');
		ctrl.getResponseXml();
		ApexPages.currentPage().getParameters().put('handsetId', '1234567890');
		ctrl.getResponseXml();
		ApexPages.currentPage().getParameters().put('data', '<GetTabsRequest xmlns=\'http://schemas.applab.org/2010/08/pulse\' hasChanged=\'false\'></GetTabsRequest>');
		ctrl.getResponseXml();
		
		Phone__c handset = new Phone__c();
		handset.IMEI__c ='1234567890';
		handset.Serial_Number__c = '123';
		handset.Purchase_Value_USD__c = 0;
		insert handset;
		
		Person__c person = new Person__c();
		person.First_Name__c = 'Test';
		person.Last_Name__C = 'Person';
		person.Handset__c = handset.Id;
		insert person;
		
		CKW__c ckw = new CKW__c();
		ckw.Person__c = person.Id;
		insert ckw;
		
		CKW_Performance_Review__c pr = new CKW_Performance_Review__c();
		pr.CKW_c__c = ckw.Id;
		pr.Start_Date__c = Date.today();
		insert pr;
		
		ckw.Current_Performance_Review__c = pr.Id;
		update ckw;
		
		ctrl.getResponseXml();
		
		ctrl.processSubmission();
	}

	/**
	 * Represents a Pulse Tab, including the name, content, and hash
	 * 
	 */
	private class TabInfo {
		private final String errorContent = 'There was a problem accessing this tab content. Please try again later or contact an administrator.';
		private String name;
		private String content;
		private String hash;
		private boolean hasChanged;

		public TabInfo(String name, String content) {
			this.name = name;
			this.content = content;
		}

		public String getName() {
			return this.name;
		}

		public String getHash() {
			if (this.hash == null) {
				//TODO: Move to a helper. There are so many of them though!
				Blob prehash = Blob.valueOf(this.getContent());
			Blob sig = Crypto.generateDigest('SHA1', prehash ); 
			this.hash = EncodingUtil.base64Encode(sig);
			}

			return this.hash;
		}

		public String getContent() {
			if (this.content == null) {
				return this.errorContent;
			}
			else {
				return this.content;
			}
		}

		public boolean getHasChanged() {
			return this.hasChanged;
		}

		public boolean checkIfChanged(String oldHash) {
			// assume we've changed by default
			this.hasChanged = true;

			// we haven't changed if there was already content
			if (oldHash != null) {
				// AND we either had an error downloading new content
				// OR it's the same as the new content
				if (this.content == null || this.getHash().equalsIgnoreCase(oldHash)) {
					this.hasChanged = false;
				}
			}

			return this.hasChanged;
		}
	}
}