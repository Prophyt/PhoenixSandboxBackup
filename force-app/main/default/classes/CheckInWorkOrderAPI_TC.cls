@isTest
public class CheckInWorkOrderAPI_TC {
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"status": "active"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void checkInAPItest() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Integration_Message__c IntegrationMessage = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"12345","WoId":"123","Priority":"Normal","TradeName":"Test"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist'
        );
        insert IntegrationMessage;
        
        Case cas = new Case();
        cas.AccountId = acc.Id;
        cas.Customer_WO__c = 'B7262414';
        cas.status = 'Closed';
        cas.Integration_Message__c= IntegrationMessage.Id;
        insert cas;
        
        list<String> caseList = new list<String>();
        caseList.add(cas.Id);
        
        SMS_Assist_Settings__c SAsettings = new SMS_Assist_Settings__c();
        SAsettings.Username__c = 'test1';
        SAsettings.Password__c = 'dfl';
        insert SAsettings;

        CheckInWorkOrderAPI.CheckInAPI(caseList);
        test.stopTest();
    }
}