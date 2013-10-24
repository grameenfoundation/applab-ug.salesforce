global class UpdateKeywordsFromCache {    
    /**
    * Get keywords as document cache
    */
    webservice static String getCachedKeywords(String documentName) {
        
        documentName = documentName.trim();
        // check for default
        if (documentName.length() == 0) {
            documentName = 'CKWSearch';
        }
        
        Document doc = 
            [
             SELECT 
                 Id,
                 Body
             FROM 
                 Document
             WHERE
                 Name = :documentName
             LIMIT 1
             ];
         return doc.Body.toString();
    }
}