@isTest
public class CheckOutWorkOrderAPI_TC {
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
    static testMethod void checkOutAPItest() {
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
        
        Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMS').getRecordTypeId();

        Case cas = new Case();
        cas.AccountId = acc.Id;
        cas.Customer_WO__c = 'B7262414';
        cas.Status = 'Closed';
        cas.Type = 'Technician';
        cas.Issue_Type__c = 'Service Call';
        cas.Problem__c = 'MCL';
        cas.Resolution__c = 'Dispatched to Vendor';
        cas.Root_Cause__c = 'Controller Not Responding';
        cas.Integration_Message__c = IntegrationMessage.Id;
        cas.RecordTypeId = recordtypeId;
        insert cas;
        
        list<String> caseList = new list<String>();
        caseList.add(cas.Id);
        
        SMS_Assist_Settings__c SAsettings = new SMS_Assist_Settings__c();
        SAsettings.Username__c = 'test1';
        SAsettings.Password__c = 'dfl';
        insert SAsettings;
        
        CheckOutWorkOrderAPI.CheckOutAPI(caseList);
        test.stopTest();
    }
}