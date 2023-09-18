public class NPSServiceImpl implements NPSService {

    // Get the NPS API endpoint, username and password from custom metadata NPS__mdt
    private static String NPS_API_ENDPOINT = NPS__mdt.getInstance('Orders').Endpoint__c;
    private static String USERNAME = NPS__mdt.getInstance('Orders').Username__c;
    private static String PASSWORD = NPS__mdt.getInstance('Orders').Password__c;

    @Future(callout=true)
    public static void sendNPSData(String orderPayloadsJSON) {
        // Deserialize the JSON string into a list of OrderPayload objects
        List<NPSUtils.OrderPayload> orderPayloads = (List<NPSUtils.OrderPayload>) JSON.deserialize(orderPayloadsJSON, List<NPSUtils.OrderPayload>.class);

        // Construct the HTTP request with the static variables
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NPS_API_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' + createBasicAuthHeader(USERNAME, PASSWORD));
        request.setBody(JSON.serialize(orderPayloads));

        // Perform the HTTP callout
        HttpResponse response = new Http().send(request);

        // If successful, update orders checkbox SentToNPSService__c to true
        if (response.getStatusCode() == 200) {
            setNPSSent(orderPayloads);
        }
    }

    private static String createBasicAuthHeader(String username, String password) {
        Blob headerValue = Blob.valueOf(username + ':' + password);
        return EncodingUtil.base64Encode(headerValue);
    }

    private static void setNPSSent(List<NPSUtils.OrderPayload> orderPayloads) {
        List<Order> ordersToUpdate = new List<Order>();
        for (NPSUtils.OrderPayload orderPayload : orderPayloads) {
            ordersToUpdate.add(new Order(
                Id = orderPayload.sfId,
                SentToNPSService__c = true
            ));
        }
        update ordersToUpdate;
    }
}