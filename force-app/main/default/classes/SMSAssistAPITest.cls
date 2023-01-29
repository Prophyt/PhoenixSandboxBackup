@isTest
public class SMSAssistAPITest 
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
	public static testMethod void runNewDescriptionTest()
    {
        Case c = new Case();
        c.Customer_WO__c = 'B123123';
        c.Description = 'xyz';
        insert c;
        
        string workOrderNumber = 'B123123';
		MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        mock.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SMSAssistAPI.getWorkOrderDetails(workOrderNumber);
		Test.stopTest();
    }
	public static testMethod void runExistingDescriptionTest()
    {
        Case c = new Case();
        c.Customer_WO__c = 'B123123';
        c.Description = 'The unit is blowing cool air. Appears to be working as the ac unit is on not the heat. ';
        insert c;
        
        string workOrderNumber = 'B123123';
		MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        mock.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SMSAssistAPI.getWorkOrderDetails(workOrderNumber);
		Test.stopTest();
    }    
    public static testMethod void runOldMethods()
    {
        Case c = new Case();
        c.Customer_WO__c = 'B123123';
        insert c;
        
        string workOrderNumber = 'B123123';
        MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = '{}';
        mock.statusCode = 200;
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SMSAssistAPI.CaseStatusAcceptAPI(new List<string>{c.Customer_WO__c});
        Test.stopTest();
    }
	public static testMethod void runCheckInTest()
    {
        Case c = new Case();
        c.Customer_WO__c = 'B123123';
        insert c;
        
        string workOrderNumber = 'B123123';
		MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        mock.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SMSAssistAPI.checkInWorkOrder(new List<string>{workOrderNumber});
		Test.stopTest();
    }
    public static testMethod void getDefaultAccountTest()
    {
        SMSAssistAPI.getDefaultAccountId();
    }
	public static testMethod void runCheckOutTest()
    {
        Case c = new Case();
        c.Status = 'Closed';
        c.Resolution__c = 'Dispatched to Vendor';
        c.Customer_WO__c = 'B123123';
        insert c;
        
        string workOrderNumber = 'B123123';
		MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        mock.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SMSAssistAPI.checkOutWorkOrder(new List<string>{workOrderNumber});
		Test.stopTest();
    }
    public static testMethod void runSMSAssistScheduler()
    {
        integer intervalMinutes = 5;
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        Test.startTest();
        SMSAssistWorkOrderScheduler sched = new SMSAssistWorkOrderScheduler(intervalMinutes);
        system.schedule('Test SMS Assist Sched',cronString, sched);
        Test.stopTest();
    }
    public static testMethod void runSMSAssistQueueable()
    {
        SMSAssistWorkOrderQueueable q = new SMSAssistWorkOrderQueueable('');
        MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        system.enqueueJob(q);
        Test.stopTest();
    }
    public static testMethod void runSMSAssistQueueableDuplicateTest()
    {
        Account a = new Account();
        a.Name = 'Petco Test';
        a.Third_Party_FM_Id__c = 'PET111';
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'Test';
        c.X3rd_Party_System__c = 'SMS Assist';
        c.Customer_WO__c = 'TEST123';
        c.X3rd_Party_Issue_Type__c = 'Unit';
        c.X3rd_Party_Priority__c = '4 h response';
        c.X3rd_Party_Problem__c = 'Air Conditioning/Heating';
        c.Status = 'Closed';
        c.Resolution__c = 'No Longer in Alarm';
        c.Accepted_Date_Time__c = datetime.now();
        c.Has_Been_Accepted__c = true;
        insert c;
        
        SMSAssistWorkOrderQueueable q = new SMSAssistWorkOrderQueueable('');
        MockHttpResponseDynamic mock = new MockHttpResponseDynamic();
        mock.jsonBody = ReactiveWorkOrderListTest.json;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        system.enqueueJob(q);
        Test.stopTest();
    }
}