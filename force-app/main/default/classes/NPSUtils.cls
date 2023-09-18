public class NPSUtils {

    // Define OrderPayload as a shared data structure
    public class OrderPayload {
        public String sfId;
        public String orderNumber;
        public String customerEmail;

        public OrderPayload(String sfId, String orderNumber, String customerEmail) {
            this.sfId = sfId;
            this.orderNumber = orderNumber;
            this.customerEmail = customerEmail;
        }
    }
}