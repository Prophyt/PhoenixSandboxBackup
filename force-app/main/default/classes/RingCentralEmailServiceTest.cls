@isTest
public class RingCentralEmailServiceTest 
{
    @TestSetup
    public static void setup()
    {
        Account a = new Account();
        a.Name = 'Test';
        a.Site_Number__c = 'Test123';
        insert a;
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'Test';
        c.X3rd_Party_WO_Id__c = 'TEST123';
        c.Customer_WO__c = 'TEST123';
        insert c;
    }
    public static testMethod void paramTest()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RingCentralEmailService';  
        req.addParameter('WorkOrderNumber', 'TEST123');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RingCentralEmailService.getLinkForWorkOrder();
    }
	public static testMethod void runTest()
    {
        string jsonBody = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RingCentralEmailService?WorkOrderNumber=TEST123';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(jsonBody);
        
        RestContext.request = req;
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.response = res;
        
        Test.startTest();
        RingCentralEmailService.getLinkForWorkOrder();
        Test.stopTest();
    }  
}