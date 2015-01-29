public with sharing class contactProcessHandler { 
	Contact cont;
	public contactProcessHandler(Contact c) {
    	 cont = c;
  	}
	public void handle() {
	cont.Department = null;
   	update cont;
	}

}