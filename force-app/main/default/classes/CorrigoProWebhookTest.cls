@isTest
public class CorrigoProWebhookTest 
{
	public static testMethod void runTest()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/CorrigoPro/webhook'; //Request URL
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        req.addHeader('Event-Type','CheckOut');
        req.requestBody = Blob.valueOf('{"example":"test"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CorrigoProWebhook.receiveMessage();
        Test.stopTest();
    }
}