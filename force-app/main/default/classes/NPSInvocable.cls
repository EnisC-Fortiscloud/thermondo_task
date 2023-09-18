public class NPSInvocable {
    /**
     * LIMITATIONS: the logic can handle up to 3000 Orders. After that we exceed the callout request limit of 100. 
     * To solve this a Queueable class could be used.
     * The timeout limit is not considered in the current logic. 
     */

    @InvocableMethod(label='Send NPS Survey')
    public static void sendNPS(List<List<Id>> orderIds) {
        // Flatten the list of lists of Ids into a single list of Ids
        List<Id> flattenedOrderIds = new List<Id>();
        for (List<Id> orderIdList : orderIds) {
            flattenedOrderIds.addAll(orderIdList);
        }
       
        // Query the required records to get the Bill To E-Mail Address (Contact.Email) and OrderNumber (Order.OrderNumber)
        List<Order> orders = getOrders(flattenedOrderIds);

        // Create lists of NPSUtils.OrderPayload objects with max size of 30 objects
        List<List<NPSUtils.OrderPayload>> orderPayloads = new List<List<NPSUtils.OrderPayload>>();
        List<NPSUtils.OrderPayload> orderPayload = new List<NPSUtils.OrderPayload>();
        for (Order order : orders) {
            orderPayload.add(new NPSUtils.OrderPayload(order.Id, order.OrderNumber, order.BillToContact.Email));
            if (orderPayload.size() == 30) {
                orderPayloads.add(orderPayload);
                orderPayload = new List<NPSUtils.OrderPayload>();
            }
        }

        // Add the last list of NPSUtils.OrderPayload objects to the list of listsq
        if (orderPayload.size() > 0) {
            orderPayloads.add(orderPayload);
        }

        // Send the NPS Survey
        for (List<NPSUtils.OrderPayload> payload : orderPayloads) {
            String payloadString = JSON.serialize(payload);
            NPSServiceImpl.sendNPSData(payloadString);
        }
    }

    public static List<Order> getOrders(List<Id> orderIds) {
        return [SELECT Id, Status, BillToContact.Email, OrderNumber FROM Order WHERE Id IN :orderIds];
    }
}