@isTest
public class CreatingWOTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    static void setup() {
        case caserec = new case(Priority='Normal',
                                Status='New',
                                Origin='Email',
                                Subject='Test Subject',
                                Description='Testing Problem Description');
        insert caserec;
    }
    static testMethod void test() {
        test.startTest();
        case caseRecord = [select id,Description from case];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CreatingWO.CreateWorkOrder(caseRecord.Id);
        List<String> Ids = new List<String>();
        Ids.add(caseRecord.Id);
        CreatingWO.CreateWorkOrderWithFlow(Ids);
        test.stopTest();
    }
}