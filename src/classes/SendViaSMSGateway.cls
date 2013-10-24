public interface SendViaSMSGateway {

    /**
     * Inteface that needs to be implemented to allow for messages to be sent to a gateway
     * The gateway will also need to have a 
     */

    // Send the messages via the gateway
    String execute(List<Message> inputMessages);

    // Create the body for the message
    String createBody(List<Message> inputMessages, Boolean single);

    // Create the request to send to the gateway
    HttpRequest buildRequest(String body, Boolean single);

    // Send the request to the gateway
    HttpResponse sendRequest(HttpRequest request);

    /**
     * Parse the response from the Gateway.
     *
     * @param results - This should always be the output from execute
     * @param resultMap - Map that is used to pass back the success of each message
     *                      Key = <Person__c.Id>_splitter_<messageHash>
     *
     * @return - The populated result map
     */
    Map<String, Boolean> callback(String results, Map<String, Boolean> resultMap);
}