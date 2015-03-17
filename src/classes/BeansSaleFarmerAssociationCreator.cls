public class BeansSaleFarmerAssociationCreator{
     //Method to fetch the Bean Association details of the bean sale association that was created
     public static void getSaleFarmerDetails(Ewarehouse_Sale_Beans_Association__c[] bean_association) {
         //Variable to hold the FCI ID's from the Bean association record
         List<String> ewarehouse_id= new List<String>();
         for(Ewarehouse_Sale_Beans_Association__c bean_associations : bean_association){
             if(bean_associations.Farmer_FCI_ID__c != null){
                 ewarehouse_id.add(bean_associations.Farmer_FCI_ID__c);
             }
         }  
         //The Variable object to fetch the Ewarehouse Farmer ID to be used to create a new Ewarehouse Sale Farmer Association Record
         Ewarehouse_Farmer__c[] existing_farmer = [SELECT Ewarehouse_Farmer__c.Id, Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c, Ewarehouse_Farmer__c.Status__c FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c IN : ewarehouse_id];   
         for(Ewarehouse_Farmer__c farmer_details : existing_farmer){
             if(farmer_details.Status__c == 'New Farmer'){
                 farmer_details.Status__c = 'New';
             }             
         }
         update existing_farmer;
         
         //Create a variable to hold the new Sale Farmer Association records
         Sale_Farmer_Associations__c[] newFarmerAssociations = new List<Sale_Farmer_Associations__c>();
         for(Ewarehouse_Sale_Beans_Association__c bean_associations : bean_association){
             for(Ewarehouse_Farmer__c existing_farmers : existing_farmer ){
                 if(bean_associations.Farmer_FCI_ID__c == existing_farmers.Auto_Generated_Farmer_ID__c){
                     newFarmerAssociations.add(new Sale_Farmer_Associations__c (Ewarehouse_Sale__c = bean_associations.Ewarehouse_Sale__c,Ewarehouse_Sale_Beans_Association__c = bean_associations.Id,Beans_Moisture_Content__c=bean_associations.Moisture_Content__c,Beans_Number_of_90kg_Bags__c=bean_associations.Total_Bags_Sold__c,Ewarehouse_Farmer__c = existing_farmers.Id,Sale_Farmer_Unique_ID__c = ''+bean_associations.Ewarehouse_Sale__c+''+existing_farmers.Id ));
                     break;
                 }else{
                     
                 }
             }
         }
         //Check that the array object variable for insertion is not empty
         if(newFarmerAssociations.size() > 0) {
             upsert newFarmerAssociations Sale_Farmer_Unique_ID__c;
         } 
     } 
}