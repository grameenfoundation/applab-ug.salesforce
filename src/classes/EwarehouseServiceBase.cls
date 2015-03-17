global virtual with sharing class EwarehouseServiceBase {
    
    public static EwarehouseDataSource.IEwarehouseDataSource dataSource = new EwarehouseDataSource();
    
    public static void setDataSource(EwarehouseDataSource.IEwarehouseDataSource sDataSource){
        dataSource = sDataSource;
    }
    
    global abstract with sharing class ServiceResultResponse {
        public String code;
        public String description;
    }
    
    global class SuccessResponse extends ServiceResultResponse {
        
        public SuccessResponse(String description){
            this.code = '200';
            this.description = description;
        }
    }


    global class ErrorResponse extends ServiceResultResponse {
        
        public ErrorResponse(String description){
            this.code = '400';
            this.description = description;
        }
    }

    global class ErrorMapResponse extends ServiceResultResponse {
        
        public ErrorMapResponse(String description, Map<String, String> objects){
            this.code = '400';
            this.description = description;
            this.objects = objects;
        }
        
        public Map<String, String> objects;
    }
    
    global class ExceptionResponse extends ServiceResultResponse {
        
        public ExceptionResponse(Exception e){
            this.code = '500';
            this.description = 'EXCEPTION: ' + e;
        }
    }
    
    
    // do not know how to get the DmlException, bad for testing, good in general
    global class DmlErrorResponse extends ServiceResultResponse {
        
        public DmlErrorResponse(String description, Database.Error[] errors){
            this.code = '400';
            this.description = description;
            this.errors = errors;
        }
        
        public Database.Error[] errors;
    }
    
    
    public static String getParameter(Map<String, String> parameters, String key){
        String value = null;
        if(parameters.containsKey(key)){
            value = parameters.get(key);
            return value;
        }
    
        System.debug(LoggingLevel.Error, 'ERROR: request param ['+key+'] cannot be found');
        return null;
    }
}