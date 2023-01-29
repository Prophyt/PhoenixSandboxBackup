@isTest
public class CorrigoAPITest 
{
    @testSetup
    public static void runSetup()
    {
        Corrigo_Settings__c settings = new Corrigo_Settings__c();
        settings.SetupOwnerId = [SELECT Id FROM Organization].Id;
        settings.Endpoint_URL__c = 'https://www.test.com';
        settings.Client_ID__c = 'TEST';
        settings.Client_Secret__c = 'TEST';
        settings.OAuth_URL__c = 'https://www.test.com';
        insert settings;
    }
    public static testMethod void runTest()
    {
        
        MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = '{"body":"test"}';
        mock.statusCode = 200;
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        CorrigoAPI.authenticate();
        Test.stopTest();
    }
}