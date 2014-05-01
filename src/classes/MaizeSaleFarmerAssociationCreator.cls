public class MaizeSaleFarmerAssociationCreator{
     //Method to fetch the Maize Association details of the maize sale association that was created
     public static void getSaleFarmerDetails(Ewarehouse_Sale_Maize_Association__c[] maize_association) {
         
         //Variable to hold the FCI ID's from the Maize association record
         List <String> ewarehouse_farmer_fci_ids = new List<String>();
         
         //List Variable to be used to hold the details of the Sale ID's included in the Current Maize Sale Association
         //List <Id> sale_ids = new List <Id> ();
         
         for(Ewarehouse_Sale_Maize_Association__c maize_associations : maize_association){
             if(maize_associations.Farmer_FCI_ID__c != null){
                 ewarehouse_farmer_fci_ids.add(maize_associations.Farmer_FCI_ID__c);
             } 
             //sale_ids.add(maize_associations.Ewarehouse_Sale__c);                   
         } 
         
         //The Variable object to fetch the Ewarehouse Farmer ID to be used to create a new Ewarehouse Sale Farmer Association Record
         Ewarehouse_Farmer__c[] existing_farmer = [SELECT Ewarehouse_Farmer__c.Id, Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c IN : ewarehouse_farmer_fci_ids];    
         
        //Sale_Record__c current_sale_Record = [SELECT Sale_Record__c.Id,Sale_Record__c.Status__c FROM Sale_Record__c WHERE Sale_Record__c.Id IN : sale_ids];
         
         //Create a variable to hold the new Sale Farmer Association records to be inserted
         Sale_Farmer_Associations__c[] newFarmerAssociations = new List<Sale_Farmer_Associations__c>();
         for(Ewarehouse_Sale_Maize_Association__c maize_associations : maize_association){
             for(Ewarehouse_Farmer__c existing_farmers : existing_farmer ){
                 if(maize_associations.Farmer_FCI_ID__c == existing_farmers.Auto_Generated_Farmer_ID__c){
                     newFarmerAssociations.add(new Sale_Farmer_Associations__c (Ewarehouse_Sale__c = maize_associations.Ewarehouse_Sale__c,Ewarehouse_Sale_Maize_Association__c = maize_associations.Id,Maize_Moisture_Content__c=maize_associations.Moisture_Content__c,Maize_Number_of_90kg_Bags__c=maize_associations.Total_Bags_Sold__c,Ewarehouse_Farmer__c = existing_farmers.Id, Sale_Farmer_Unique_ID__c = ''+ maize_associations.Ewarehouse_Sale__c + ''+ existing_farmers.Id));
                     break;
                 }else{
                     
                 }
             }             
         }
         //Check that the array object variable for insertion is not empty
         if(newFarmerAssociations.size() > 0) {
              upsert newFarmerAssociations Sale_Farmer_Unique_ID__c ;
         } else{
             //current_sale_Record.Status__c = 'Rejected';
             //update current_sale_Record;
         }
    }
}