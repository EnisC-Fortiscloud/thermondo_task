@isTest
public class NPSServiceTest {
    
    @TestSetup
    static void makeData() {
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Contract c = new Contract(
            AccountId = a.Id,
            StartDate = Date.today(),
            ContractTerm = 12,
            Status = 'Draft'
        );
        insert c;

        Product2 p = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Insert 31 Orders each with 1 OrderItem
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 31; i++) {
            orders.add(new Order(
                AccountId = a.Id,
                ContractId = c.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = Test.getStandardPricebookId()
            ));
        }
        insert orders;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order o : orders) {
            orderItems.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 100
            ));
        }
        insert orderItems;           
    }

    @isTest
    static void testSendNPS() {
        // Get List<List<Id>> orderIds from querying for Orders
        List<List<Id>> orderIds = new List<List<Id>>();
        for (Order o : [SELECT Id FROM Order]) {
            orderIds.add(new List<Id>{o.Id});
        }
        
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new NPSServiceTest.MockHttpResponseGenerator());

        // Call InvocableMethod
        Test.startTest();
        NPSInvocable.sendNPS(orderIds);
        Test.stopTest();

        // Assert that the Order.SentToNPSService__c field is set to true
        for (Order o : [SELECT Id, SentToNPSService__c FROM Order]) {
            System.assertEquals(true, o.SentToNPSService__c);
        }
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message": "Success"}');
            res.setStatusCode(200);
            return res;
        }
    }

}