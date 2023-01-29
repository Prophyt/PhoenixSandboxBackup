@isTest
public class IntegrationUtillitiesTest 
{
    @TestSetup
    public static void setup()
    {
        SMS_Assist_Settings__c setting = new SMS_Assist_Settings__c();
        setting.ClientId__c = 'test';
        setting.Username__c = 'test';
        setting.Password__c = 'test';
        setting.SetupOwnerId = UserInfo.getOrganizationId();
        insert setting;
    }
	public static testMethod void runSandboxTest()
    {
        IntegrationUtilities.IsSandbox();
    }
    public static testMethod void getBaseUrlTest()
    {
        IntegrationUtilities.getBaseUrl();
    }
    public static testMethod void runHttpRequestTest()
    {   
        IntegrationUtilities.requestBuilder('GET','http://www.google.com','SMS Assist','');
    }
    public static testMethod void runCronTest()
    {
        IntegrationUtilities.getCRONExpression(DateTime.now());
    }
}