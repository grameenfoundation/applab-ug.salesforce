/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Tests are in SearchServerTests class
 **/
public class SearchGetImagesHelper {

    /**
     * Given a JSON containing Image Ids, 
     * Will return a JSON with the corresponding image data as base64
     * The client side should rebuild the image data from the base64 encoded data
    */
    public static String getImages(String jsonRequestString) {
        
        //Create the response wrapper for this request
        ImageResponseWrapper responseWrapper = new ImageResponseWrapper();
        
        //Build the request object
        ImageRequestWrapper request = null;
        try {
            request = (ImageRequestWrapper) JSON.deserialize(jsonRequestString, ImageRequestWrapper.class);
        }
        catch(Exception e) {
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Request could not be decoded';
            return JSON.serializePretty(responseWrapper);
        }
        List<String> imageIds = request.imageIds;
        List<Attachment> imageAttachments  = [
                SELECT
                    Id,
                    ParentId,
                    IsDeleted,
                    Body
                FROM
                    Attachment
                WHERE
                    Id IN :imageIds
                    AND
                    Name LIKE '%.jp%g'
                ALL ROWS];
        if(imageAttachments.size() == 0) {
            //No images found matching these ids
            responseWrapper.resultCode = '0';
            responseWrapper.resultMessage = 'No Images found';
            responseWrapper.imageResults = new List<ImageData>();
            return JSON.serializePretty(responseWrapper);
        }
         
        //Build the imageData List to return 
        List<ImageData> imageDataList = new List<ImageData>();      
        for(Attachment attachment : imageAttachments) {
            ImageData tempImageData = new ImageData();
            tempImageData.imageId = attachment.Id;
            tempImageData.imageData = EncodingUtil.base64Encode(attachment.Body);
            imageDataList.add(tempImageData);
        }
         
        responseWrapper.resultCode = '0';
        responseWrapper.resultMessage = 'Images found';
        responseWrapper.imageResults = imageDataList;
        responseWrapper.total = imageDataList.size();

        return JSON.serializePretty(responseWrapper);
    }

    /*Wrapper class for the json requests*/
    class ImageRequestWrapper {
        String request {get;set;}
        String imei {get;set;}
        List<String> imageIds {get;set;}
    }
    
    /*Wrapper class for image data in response
    has the 
    1.salesforce id
    2.image data string encoded as base64
    */
    class ImageData {
        String imageId {get;set;}
        String imageData {get;set;}
    }
    
    /**
     * Wrapper class for image request response has
     * String resultcode
     * String resultmessage
     * List<ImageData> imageResults
    */
    class ImageResponseWrapper {
        String resultCode {get;set;}
        String resultMessage {get;set;}
        Integer total {get; set;}
        List<ImageData> imageResults {get;set;}
        
        //Constructor to create an empty list
        public ImageResponseWrapper() {
            this.resultCode = '0';
            this.resultMessage = 'Operation succesful';
            this.imageResults = new List<ImageData>();
        }
    }
}