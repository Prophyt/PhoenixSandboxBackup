@isTest
public class SMSAssistSettingsTest 
{
    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test1"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void getWO() 
    {
        SMS_Assist_Settings__c SAsettings = new SMS_Assist_Settings__c();
        SAsettings.Username__c = 'test1';
        SAsettings.Password__c = 'dfl';
        insert SAsettings;
        
        //SMSassistSettings.ReturnAccessToken();
        //SMSassistSettings.getWO();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String strres = SMSassistSettings.ReturnAccessToken();
        SMSassistSettings.getWO();
        
    } 
}