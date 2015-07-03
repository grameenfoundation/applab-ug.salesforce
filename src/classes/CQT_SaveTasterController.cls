public class CQT_SaveTasterController {
	
    ApexPages.StandardController con;
    
    public CQT_SaveTasterController(ApexPages.StandardController controller){
       con = controller;
    }
    
	public pagereference save(){
		con.save(); 
        return new pagereference(page.CQT_TasterEditDeletePage.getUrl());
    }
    
    public pagereference cancel(){
		return new pagereference(page.CQT_TasterEditDeletePage.getUrl());
    }
}