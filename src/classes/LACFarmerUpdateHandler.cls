public with sharing class LACFarmerUpdateHandler {

	public void handle(Contact c){
		c.Department = null;
		update c;
	} 

}