@isTest
public class ProcessServiceChannelRequestTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void ProcessServicetest() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ProcessServiceChannelRequest.ReturnAccessToken();
        ProcessServiceChannelRequest.getWO();
        ProcessServiceChannelRequest.test();
        test.stopTest();
    }
}