public class BlackBeansSaleFarmerAssociationCreator{
     //Method to fetch the Black Beans Association details of the black beans sale association that was created
     public static void getSaleFarmerDetails(Ewarehouse_Sale_Black__c[] black_bean_association) {
         //Variable to hold the FCI ID's from the Maize association record
         List<String> ewarehouse_id= new List<String>();
         for(Ewarehouse_Sale_Black__c black_bean_associations : black_bean_association){
             if(black_bean_associations.Farmer_FCI_ID__c != null){
                 ewarehouse_id.add(black_bean_associations.Farmer_FCI_ID__c);
             }
         }  
         //The Variable object to fetch the Ewarehouse Farmer ID to be used to create a new Ewarehouse Sale Farmer Association Record
         Ewarehouse_Farmer__c[] existing_farmer = [SELECT Ewarehouse_Farmer__c.Id FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c IN : ewarehouse_id];   
         //Create a variable to hold the new Sale Farmer Association records
         Sale_Farmer_Associations__c[] newFarmerAssociations = new List<Sale_Farmer_Associations__c>();
         for(Ewarehouse_Sale_Black__c black_bean_associations : black_bean_association){
             for(Ewarehouse_Farmer__c existing_farmers : existing_farmer ){
                 if(black_bean_associations.Farmer_FCI_ID__c == existing_farmers.Auto_Generated_Farmer_ID__c){
                     newFarmerAssociations.add(new Sale_Farmer_Associations__c (Ewarehouse_Sale__c = black_bean_associations.Ewarehouse_Sale__c,Ewarehouse_Sale_Black_Beans_Association__c = black_bean_associations.Id,Dolichos_Moisture_Content__c=black_bean_associations.Moisture_Content__c,Dolichos_Number_of_90kg_Bags__c=black_bean_associations.Total_Bags_Sold__c,Ewarehouse_Farmer__c = existing_farmers.Id,Sale_Farmer_Unique_ID__c = ''+ black_bean_associations.Ewarehouse_Sale__c + ''+ existing_farmers.Id ));
                     break;
                 }else{
                     
                 }
             }
         }
         //Check that the array object variable for insertion is not empty
         if(newFarmerAssociations.size() > 0) {
           //insert newFarmerAssociations;
           upsert newFarmerAssociations Sale_Farmer_Unique_ID__c;
         } 
     } 
}