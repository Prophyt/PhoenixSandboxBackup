@isTest
public class WebhookListnerTest {
    @isTest
    static void testHttpPost() {        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Webhook'; //Request URL
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.addHeader('Sign-Data','kliKv8NcMdOYUg39//w9rRivkirGVqITACYhK2I60Rw=');
        req.requestBody = Blob.valueOf('{"example":"test"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        WebhookListner.handlePost();
        Test.stopTest();
    }
}