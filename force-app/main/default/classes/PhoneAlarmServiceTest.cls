@isTest
public class PhoneAlarmServiceTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.Name = 'Test';
        a.Site_Number__c = 'Test123';
        insert a;
        
        string jsonBody = '{"alarmType":"Severity 1","store":"Test123"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/PhoneAlarmService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        
        RestContext.request = req;
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.response = res;
        
        Test.startTest();
        PhoneAlarmService.createTicket();
        Test.stopTest();
    }  
}