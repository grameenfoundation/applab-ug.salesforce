@isTest
public class PigeonPeasSaleFAssociationCreatorTest{
     //Method to fetch the Pigeon Peas Association details of the pigeon peas sale association that was created
     static testMethod void getSaleFarmerDetails() {
      
      Bank_Deposit__c eBankDeposit = new Bank_Deposit__c(Amount__c=4500,Bank_Transaction_Id__c='XYZ123',Commercial_Purchase_Groups__c='KARATHIA WOMEN GROUP',District__c='TIGANIA WEST',Verification_Code__c='Gf003');
      insert eBankDeposit;
      
      Sale_Record__c eSale = new Sale_Record__c(Name='a3Hn00000008X0B',Bank_Deposit__c=eBankDeposit.Id,Beans_Number_of_90kg_Bags__c=3,Beans_Price_per_90kg_Bag__c=650,Commercial_Purchase_Group__c='a1cn00000004RwWAAU a1cn00000004RwXAAU',Commercial_Village__c='ATHWANA',Cow_Peas_Number_of_90kg_Bags__c=5,Cow_Peas_Price_per_90kg_Bag__c=500,District__c='TIGANIA WEST',Division__c='',Dolichos_Number_of_90kg_Bags__c=4,Dolichos_Price_per_90kg_Bag__c=780,Ewarehouse_Sale_Total_Amount__c='4500',Green_Grams_Number_of_90kg_Bags__c=3,Green_Grams_Price_per_90kg_Bag__c=350,Maize_Number_of_90kg_Bags__c=4,Maize_Price_per_90kg_Bag__c=300,Pigeon_Peas_Total_Amount__c=6,Pigeon_Peas_Price_per_90kg_Bag__c=100,Sale_Date__c=date.newInstance(2014, 2, 4),Status__c='Processing',Tigania_East_Commercial_Village__c='',Tigania_West_Commercial_Village__c='ATHWANA',VKW_Name__c='Steven Mugo');
      insert eSale;
      
      Ewarehouse_Sale_Pigeon_Peas_Association__c pigeon_peas_association_records= new Ewarehouse_Sale_Pigeon_Peas_Association__c (Farmer_FCI_ID__c='TW/A4/01/999',Ewarehouse_Sale__c=eSale.Id,Last_3_Digits_of_Farmer_ID__c='999',Moisture_Content__c='Exactly 13.5%',Total_Bags_Sold__c=10);
      insert pigeon_peas_association_records;
      
      Ewarehouse_Sale_Pigeon_Peas_Association__c pigeon_peas_association_1 = [SELECT Bags_Not_Sold__c, Commercial_Purchase_Group__c, Commercial_Purchase_Group_ID__c, Ewarehouse_Sale__c, Farmer_FCI_ID__c, Last_3_Digits_of_Farmer_ID__c, Moisture_Content__c, Reason_For_Not_Selling__c, Total_Bags_Sold__c FROM Ewarehouse_Sale_Pigeon_Peas_Association__c WHERE Id =: pigeon_peas_association_records.Id LIMIT 1];
      pigeon_peas_association_1.Bags_Not_Sold__c=1;
      update pigeon_peas_association_1;
      
      Ewarehouse_Sale_Pigeon_Peas_Association__c [] pigeon_peas_association = [SELECT Bags_Not_Sold__c, Commercial_Purchase_Group__c, Commercial_Purchase_Group_ID__c, Ewarehouse_Sale__c, Farmer_FCI_ID__c, Last_3_Digits_of_Farmer_ID__c, Moisture_Content__c, Reason_For_Not_Selling__c, Total_Bags_Sold__c FROM Ewarehouse_Sale_Pigeon_Peas_Association__c];
         
         
         //Variable to hold the FCI ID's from the Pigeon Peas association record
         List<String> ewarehouse_farmer_fci_ids= new List<String>();
         
         for(Ewarehouse_Sale_Pigeon_Peas_Association__c pigeon_peas_associations : pigeon_peas_association){
             if(pigeon_peas_associations.Farmer_FCI_ID__c != null){
                 ewarehouse_farmer_fci_ids.add(pigeon_peas_associations.Farmer_FCI_ID__c);
             } 
         } 
         
         //The Variable object to fetch the Ewarehouse Farmer ID to be used to create a new Ewarehouse Sale Farmer Association Record
         Ewarehouse_Farmer__c[] existing_farmer = [SELECT Ewarehouse_Farmer__c.Id, Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c FROM Ewarehouse_Farmer__c WHERE Ewarehouse_Farmer__c.Auto_Generated_Farmer_ID__c IN : ewarehouse_farmer_fci_ids];    
         for(Ewarehouse_Farmer__c farmer_details : existing_farmer){
             if(farmer_details.Status__c == 'New Farmer'){
                 farmer_details.Status__c = 'New';
             }             
         }
         
         //Create a variable to hold the new Sale Farmer Association records to be inserted
         Sale_Farmer_Associations__c[] newFarmerAssociations = new List<Sale_Farmer_Associations__c>();
         for(Ewarehouse_Sale_Pigeon_Peas_Association__c pigeon_peas_associations : pigeon_peas_association){
             for(Ewarehouse_Farmer__c existing_farmers : existing_farmer ){
                 if(pigeon_peas_associations.Farmer_FCI_ID__c == existing_farmers.Auto_Generated_Farmer_ID__c){
                     newFarmerAssociations.add(new Sale_Farmer_Associations__c (Ewarehouse_Sale__c = pigeon_peas_associations.Ewarehouse_Sale__c,Ewarehouse_Sale_Pigeon_Peas_Association__c = pigeon_peas_associations.Id,Pigeon_Peas_Moisture_Content__c=pigeon_peas_associations.Moisture_Content__c,Pigeon_Peas_Number_of_90kg_Bags__c=pigeon_peas_associations.Total_Bags_Sold__c,Ewarehouse_Farmer__c = existing_farmers.Id, Sale_Farmer_Unique_ID__c = ''+ pigeon_peas_associations.Ewarehouse_Sale__c + ''+ existing_farmers.Id));
                     break;
                 }else{
                     
                 }
             }             
         }
         //Check that the array object variable for insertion is not empty
         if(newFarmerAssociations.size() > 0) {
           upsert newFarmerAssociations Sale_Farmer_Unique_ID__c ;
         } 
    }
}