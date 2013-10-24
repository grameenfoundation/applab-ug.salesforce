global class SyncMarketLinkTransactions {

  webservice static String syncMarketlinkTransaction(String selectedDistrict, String selectedCrop) {
    selectedDistrict = selectedDistrict.trim();
    selectedCrop = selectedCrop.trim();
    List<BuyerObject> buyers = findBuyers(selectedDistrict, selectedCrop);
    String buyersJSON = JSON.serialize(buyers);
    
    return buyersJSON;
  }
  
  private static List<BuyerObject> findBuyers(String selectedDistrict, String selectedCrop) {
    List<BuyerObject> foundBuyers = new List<BuyerObject>();
    
    String cropPattern = '(?i).+'+selectedCrop+'.*';
    Pattern searchCrop = Pattern.compile(cropPattern);
    
    String buyerPattern = '([a-zA-Z\\.\\, ]+)\\s*Location:\\s*([a-zA-Z \\.\\,]+)\\s*Contacts:\\s*(\\d{9}|\\d{12})\\s*';
    Pattern searchBuyer = Pattern.compile(buyerPattern);

    for (Menu_Item__c menuItems: [
      SELECT 
        Content__c 
      FROM
        Menu_Item__c 
      WHERE 
        (Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Buyers Directory' OR Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Buyers Directory') 
      AND 
        Parent_Item__r.Parent_Item__r.Label__c = :selectedDistrict 
      AND 
        Menu__r.Label__c='CKW Search']) {
          if (null != menuItems.Content__c) {
          List<String> buyers = menuItems.Content__c.split('\n');
        for (String buyer: buyers) {
              Matcher matchCrop = searchCrop.matcher(buyer);
              if (matchCrop.matches()) {
                  Matcher matchBuyer = searchBuyer.matcher(buyer);
                  if(matchBuyer.find()) {
                    foundBuyers.add(new BuyerObject(matchBuyer.group(1), matchBuyer.group(2), matchBuyer.group(3)));
                  }
            }
        }
          }
    }
    
    return foundBuyers;
  }
    
  global class BuyerObject {
    String Name;
    String Location;
    String Contact;
    
    BuyerObject (String Name, String Location, String Contact) {
      this.Name = Name;
      this.Location = Location;
      this.Contact = Contact;
    }
  }
  
}