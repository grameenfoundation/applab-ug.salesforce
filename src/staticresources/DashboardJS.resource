        function openEditWindow(recordId) {
             popup = window.open("{!$Page.MetricEdit}?quarter={!quarter}&sfdc.tabName={!tabName}&recordId=" + recordId,"lookup","width=600,height=200");
             popup.focus(); 
        };

        function openGraph(recordId) {
             popup = window.open("{!$Page.MetricGraph}?metricId=" + recordId,"lookup","width=710,height=310");
             popup.focus(); 
        };

        function closeEditPopup() {
            if(null != popup) {
                popup.close()
                popup = null;
                window.location.reload();
            }
        };

        function injectOnclickJs(iframe, type,nameVar) {
            iframe.contentWindow.document.body.onclick=function() { openMap(type, nameVar, null, null, null, null, null, null, null); }
        }

        // objectType must be present. The rest can be null
        function openMap(objectType, type, ckws, farmers, incFarmers, incSearches, incSearchLocations, keyword, surveyName) {

             if (objectType == null) {
                 return false;
             }
             var url = "{!$Page.MetricMap}?mapObject=" + objectType + "&quarter={!quarter}";
             if (type != null) {
                 url = url + "&colourType=" + type;
             }
             if (ckws != null) {
                 url = url + "&ckws=" + ckws;
             }
             if (farmers != null) {
                 url = url + "&farmers=" + farmers;
             }
             if (incFarmers != null) {
                 url = url + "&incFarmers=" + incFarmers;
             }
             if (incSearches != null) {
                 url = url + "&incSearches=" + incSearches;
             }
             if (incSearchLocations != null) {
                 url = url + "&incSeachSubLoc=" + incSearchLocations;
             }
             if (keyword != null) {
                 url = url + "&keyword=" + keyword;
             }
             if (surveyName != null) {
                 url = url + "&surveyName=" + surveyName;
             }

             popup = window.open(url,"lookup");
             popup.focus(); 
        };

        // Must include atleast one of the vars, rest can be null
        function openGraph(ckws, farmers, keyword) {

             if (ckws == null && farmers == null && keyword == null) {
                return;
             }
             var url = "{!$Page.Graphs}?";
             if (ckws != null) {
                 url = url + "&ckws=" + ckws;
             }
             if (farmers != null) {
                 url = url + "&farmers=" + farmers;
             }
             if (keyword != null) {
                 url = url + "&keyword=" + keyword;
             }
             popup = window.open(url,"lookup");
             popup.focus(); 
        };

        // Must include atleast one of the vars, rest can be null
        function openTagCloud(ckws, farmers, keyword) {

             if (ckws == null && farmers == null && keyword == null) {
                return;
             }
             var url = "{!$Page.TagCloud}?";
             if (ckws != null) {
                 url = url + "&ckws=" + ckws;
             }
             if (farmers != null) {
                 url = url + "&farmers=" + farmers;
             }
             if (keyword != null) {
                 url = url + "&keyword=" + keyword;
             }
             popup = window.open(url,"lookup");
             popup.focus(); 
        };
