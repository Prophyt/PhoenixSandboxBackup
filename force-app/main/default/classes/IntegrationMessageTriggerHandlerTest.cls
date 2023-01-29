@isTest
public class IntegrationMessageTriggerHandlerTest 
{
    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    public static void setup() 
    {
        SMS_Assist_Settings__c settings = new SMS_Assist_Settings__c();
        settings.Username__c = 'test';
        settings.Password__c = 'test';
        settings.Staging_Username__c = 'test';
        settings.Staging_Password__c = 'test';
        settings.SetupOwnerId = [SELECT Id FROM Organization LIMIT 1].Id;
        insert settings;

        Integration_Message__c serviceChannelMsg = new Integration_Message__c();
        serviceChannelMsg.Integration_Source__c ='ServiceChannel';
        
        serviceChannelMsg.Package__c = '{"Object":{"Id":188802391,"Number":"188802391","PurchaseNumber":"188802391",'+
            '"SubscriberId":2014917018,"ProviderId":2000019310,"ProviderName":"Phoenix Energy Technologies, Inc.",'+
            '"LocationId":2005948844,"LocationName":"Phoenix-XML","LocationStoreId":"Phoenix-XML",'+
            '"Status":{"Primary":"COMPLETED","Extended":"CANCELLED"},'+
            '"Caller":"caller","CreatedBy":"caller","CallDate":"2021-09-30T03:52:00",'+
            '"Priority":"Sev 3","Trade":"SITECOMPLI","ScheduledDate":"2021-10-07T03:52:00",'+
            '"UpdatedDate":"2021-09-30T13:02:35.873","ScheduledDate_DTO":"2021-10-07T03:52:00-04:00",'+
            '"CompletedDate":"2021-09-30T12:37:47","ExpirationDate":"2021-10-07T03:52:00",'+
            '"Description":"Testing Problem Description","Category":"SITECOMPLI","Nte":0.0,'+
            '"CurrencyAlphabeticalCode":"USD","Source":"Web Request",'+
            '"Notes":[{"Id":1150632204,"Number":18,"NoteData":"GL Code has been changed from 12 to 111.",'+
            '"DateCreated":"2021-09-30T13:03:00","ScheduledDate":"2021-10-07T03:52:00",'+
            '"ActionRequired":false,"MailedTo":"","CreatedBy":"PhoenixXML",'+
            '"CreatedByUser":{"UserName":"PhoenixXML1","FullName":"PhoenixXML","SubscriberId":2014917018}}],'+
            '"Attachments":[],'+ 
            '"IssueTicketInfo": {"Id": 0,"AreaId": 0,"AreaName": "string","ProblemGroup": "string","Equipment": "string","ProblemCode": "string","TicketType": "string","SetupId": 0},' +
            '"LinkedWorOrderIds":[]},"Type":"WoRootNotification",'+
            '"Action":"UPDATE","EventType":"WorkOrderNoteAdded","Version":1}';


        insert serviceChannelMsg;        
        serviceChannelMsg.Header__c = 'SignData';
        update serviceChannelMsg;
        
        Case c = new case(Priority='Normal',
                          Status='CANCELLED',
                          Origin='Email',
                          Customer_WO__c='188802391',
                          Subject='Test Subject',
                          X3rd_Party_WO_Id__c='188802391',
                          Description='Testing Problem Description');
        insert c;
    }
    public static testMethod void IntegrationWarningEmailTest()
    {
        Integration_Message__c serviceChannelMsg = new Integration_Message__c();
        serviceChannelMsg.Integration_Source__c ='ServiceChannel';
        serviceChannelMsg.Header__c = 'SignData';
        serviceChannelMsg.Package__c = '{"Object":{"Id":123456,"Number":"188802391","PurchaseNumber":"188802391",'+
            '"SubscriberId":2014917018,"ProviderId":2000019310,"ProviderName":"Phoenix Energy Technologies, Inc.",'+
            '"LocationId":2005948844,"LocationName":"Phoenix-XML","LocationStoreId":"Phoenix-XML",'+
            '"Status":{"Primary":"COMPLETED","Extended":"CANCELLED"},'+
            '"Caller":"caller","CreatedBy":"caller","CallDate":"2021-09-30T03:52:00",'+
            '"Priority":"Sev 3","Trade":"SITECOMPLI","ScheduledDate":"2021-10-07T03:52:00",'+
            '"UpdatedDate":"2021-09-30T13:02:35.873","ScheduledDate_DTO":"2021-10-07T03:52:00-04:00",'+
            '"CompletedDate":"2021-09-30T12:37:47","ExpirationDate":"2021-10-07T03:52:00",'+
            '"Description":"Testing Problem Description","Category":"SITECOMPLI","Nte":0.0,'+
            '"CurrencyAlphabeticalCode":"USD","Source":"Web Request",'+
            '"Notes":[{"Id":1150632204,"Number":18,"NoteData":"GL Code has been changed from 12 to 111.",'+
            '"DateCreated":"2021-09-30T13:03:00","ScheduledDate":"2021-10-07T03:52:00",'+
            '"ActionRequired":false,"MailedTo":"","CreatedBy":"PhoenixXML",'+
            '"CreatedByUser":{"UserName":"PhoenixXML1","FullName":"PhoenixXML","SubscriberId":2014917018}}],'+
            '"Attachments":[],"LinkedWorOrderIds":[]},"Type":"WoRootNotification",'+
            '"Action":"NEW","EventType":"WorkOrderNoteAdded","Version":1}';
        insert serviceChannelMsg;  
        serviceChannelMsg = [SELECT Id,Name,Package__c,Integration_Source__c FROM Integration_Message__c WHERE Id = :serviceChannelMsg.Id LIMIT 1];
        Test.startTest();
        IntegrationMessageTriggerHandler.sendWarningEmail(serviceChannelMsg);
        Test.stopTest();
            
    }
    public static testMethod void IntegrationMessageServiceChannelNewTest() 
    {
       
        Case c = new Case();
        c.X3rd_Party_WO_Id__c = '123456';
        c.Priority = 'Normal';
        c.Status = 'New';
        c.Origin = 'Email';
        c.Customer_WO__c ='123456';
        c.Subject='Test Subject';
        c.Description='Testing Problem Description';
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Integration_Message__c serviceChannelMsg = new Integration_Message__c();
        serviceChannelMsg.Integration_Source__c ='ServiceChannel';
        serviceChannelMsg.Header__c = 'SignData';
        serviceChannelMsg.Package__c = '{"Object":{"Id":123456,"Number":"188802391","PurchaseNumber":"188802391",'+
            '"SubscriberId":2014917018,"ProviderId":2000019310,"ProviderName":"Phoenix Energy Technologies, Inc.",'+
            '"LocationId":2005948844,"LocationName":"Phoenix-XML","LocationStoreId":"Phoenix-XML",'+
            '"Status":{"Primary":"COMPLETED","Extended":"CANCELLED"},'+
            '"Caller":"caller","CreatedBy":"caller","CallDate":"2021-09-30T03:52:00",'+
            '"Priority":"Sev 3","Trade":"SITECOMPLI","ScheduledDate":"2021-10-07T03:52:00",'+
            '"UpdatedDate":"2021-09-30T13:02:35.873","ScheduledDate_DTO":"2021-10-07T03:52:00-04:00",'+
            '"CompletedDate":"2021-09-30T12:37:47","ExpirationDate":"2021-10-07T03:52:00",'+
            '"Description":"Testing Problem Description","Category":"SITECOMPLI","Nte":0.0,'+
            '"CurrencyAlphabeticalCode":"USD","Source":"Web Request",'+
            '"Notes":[{"Id":1150632204,"Number":18,"NoteData":"GL Code has been changed from 12 to 111.",'+
            '"DateCreated":"2021-09-30T13:03:00","ScheduledDate":"2021-10-07T03:52:00",'+
            '"ActionRequired":false,"MailedTo":"","CreatedBy":"PhoenixXML",'+
            '"CreatedByUser":{"UserName":"PhoenixXML1","FullName":"PhoenixXML","SubscriberId":2014917018}}],'+
            '"Attachments":[],"LinkedWorOrderIds":[]},"Type":"WoRootNotification",'+
            '"Action":"NEW","EventType":"WorkOrderNoteAdded","Version":1}';
        insert serviceChannelMsg;        

        Test.stopTest();
    }
    public static testMethod void IntegrationMessageServiceChannelUpdateTest() 
    {
       
        Case c = new Case();
        c.X3rd_Party_WO_Id__c = '123456';
        c.Priority = 'Normal';
        c.Status = 'New';
        c.Origin = 'Email';
        c.Customer_WO__c ='123456';
        c.Subject='Test Subject';
        c.Description='Testing Problem Description';
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Integration_Message__c serviceChannelMsg = new Integration_Message__c();
        serviceChannelMsg.Integration_Source__c ='ServiceChannel';
        serviceChannelMsg.Header__c = 'SignData';
        serviceChannelMsg.Package__c = '{"Object":{"Id":123456,"Number":"188802391","PurchaseNumber":"188802391",'+
            '"SubscriberId":2014917018,"ProviderId":2000019310,"ProviderName":"Phoenix Energy Technologies, Inc.",'+
            '"LocationId":2005948844,"LocationName":"Phoenix-XML","LocationStoreId":"Phoenix-XML",'+
            '"Status":{"Primary":"COMPLETED","Extended":"CANCELLED"},'+
            '"Caller":"caller","CreatedBy":"caller","CallDate":"2021-09-30T03:52:00",'+
            '"Priority":"Sev 3","Trade":"SITECOMPLI","ScheduledDate":"2021-10-07T03:52:00",'+
            '"UpdatedDate":"2021-09-30T13:02:35.873","ScheduledDate_DTO":"2021-10-07T03:52:00-04:00",'+
            '"CompletedDate":"2021-09-30T12:37:47","ExpirationDate":"2021-10-07T03:52:00",'+
            '"Description":"Testing Problem Description","Category":"SITECOMPLI","Nte":0.0,'+
            '"CurrencyAlphabeticalCode":"USD","Source":"Web Request",'+
            '"Notes":[{"Id":1150632204,"Number":18,"NoteData":"GL Code has been changed from 12 to 111.",'+
            '"DateCreated":"2021-09-30T13:03:00","ScheduledDate":"2021-10-07T03:52:00",'+
            '"ActionRequired":false,"MailedTo":"","CreatedBy":"PhoenixXML",'+
            '"CreatedByUser":{"UserName":"PhoenixXML1","FullName":"PhoenixXML","SubscriberId":2014917018}}],'+
            '"Attachments":[],"LinkedWorOrderIds":[]},"Type":"WoRootNotification",'+
            '"Action":"UPDATE","EventType":"WorkOrderNoteAdded","Version":1}';
        insert serviceChannelMsg;        

        Test.stopTest();
    }    
    public static testMethod void IntegrationMessageSMSAssistExisting() 
    {
        Account acc = new Account(Name='Test',Third_Party_FM_Id__c ='123');
        insert acc;
        
        Case c = new case(Priority='Normal',
                          Status='New',
                          Origin='Email',
                          Customer_WO__c='B7267123',
                          Subject='Test Subject',
                          X3rd_Party_WO_Id__c='B7267123',
                          Description='Testing SMS Problem Description');
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        Integration_Message__c msg = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"On Site"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist');
        insert msg;
        
        Test.stopTest();
    }
    public static testMethod void IntegrationMessageSMSAssistExistingNotNew() 
    {
        Account acc = new Account(Name='Test',Third_Party_FM_Id__c ='123');
        insert acc;
        
        Case c = new case(Priority='Normal',
                          Status='Accepted',
                          Origin='Email',
                          Customer_WO__c='B7267123',
                          Subject='Test Subject',
                          X3rd_Party_WO_Id__c='B7267123',
                          Description='Testing SMS Problem Description');
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        Integration_Message__c msg = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"On Site"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist');
        insert msg;
        
        Test.stopTest();
    }    
    public static testMethod void IntegrationMessageSMSAssistNewCase() 
    {
        Account acc = new Account(Name='Test',Third_Party_FM_Id__c ='123');
        insert acc;
        
        Case c = new case(Priority='Normal',
                          Status='Accepted',
                          Origin='Email',
                          Customer_WO__c='B555555',
                          Subject='Test Subject',
                          X3rd_Party_WO_Id__c='B555555',
                          Description='Testing SMS Problem Description');
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        Integration_Message__c msg = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"On Site"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist');
        insert msg;
        
        Test.stopTest();
    }   
    public static testMethod void runPetcoTest()
    {
        Account a = new Account();
        a.Name = 'Petco';
        a.Site_Number__c = '123';
        insert a;
        
        Case c = new Case();
        c.Customer_WO__c = 'TEST123';
        c.Subject = 'Test Case';
        c.Description = 'PHOENIX Created Case: Test Case';
        c.AccountId = a.Id;
        c.Status = 'New';
        insert c;

        
        Test.setMock(HttpCalloutMock.class, new IntegrationMessageTriggerHandlerTest.MockHttpResponseGenerator());
        Test.startTest();

        c = [SELECT Id, CaseNumber, Integration_Message__c,X3rd_Party_System__c FROM Case WHERE Id = :c.Id];
        system.assert(c.X3rd_Party_System__c == null);
        
        Integration_Message__c serviceChannelMsg = new Integration_Message__c();
        serviceChannelMsg.Integration_Source__c ='ServiceChannel';
        
        serviceChannelMsg.Package__c = '{"Object":{"Id":188802391,"Number":"TEST123","PurchaseNumber":"188802391",'+
            '"SubscriberId":2014917018,"ProviderId":2000019310,"ProviderName":"Phoenix Energy Technologies, Inc.",'+
            '"LocationId":2005948844,"LocationName":"Petco","LocationStoreId":"Petco-123",'+
            '"Status":{"Primary":"COMPLETED","Extended":"CANCELLED"},'+
            '"Caller":"caller","CreatedBy":"caller","CallDate":"2021-09-30T03:52:00",'+
            '"Priority":"Sev 3","Trade":"SITECOMPLI","ScheduledDate":"2021-10-07T03:52:00",'+
            '"UpdatedDate":"2021-09-30T13:02:35.873","ScheduledDate_DTO":"2021-10-07T03:52:00-04:00",'+
            '"CompletedDate":"2021-09-30T12:37:47","ExpirationDate":"2021-10-07T03:52:00",'+
            '"Description":"Testing Problem Description","Category":"SITECOMPLI","Nte":0.0,'+
            '"CurrencyAlphabeticalCode":"USD","Source":"Web Request",'+
            '"Notes":[{"Id":1150632204,"Number":18,"NoteData":"GL Code has been changed from 12 to 111.",'+
            '"DateCreated":"2021-09-30T13:03:00","ScheduledDate":"2021-10-07T03:52:00",'+
            '"ActionRequired":false,"MailedTo":"","CreatedBy":"PhoenixXML",'+
            '"CreatedByUser":{"UserName":"PhoenixXML1","FullName":"PhoenixXML","SubscriberId":2014917018}}],'+
            '"Attachments":[],"LinkedWorOrderIds":[]},"Type":"WoRootNotification",'+
            '"Action":"UPDATE","EventType":"WorkOrderNoteAdded","Version":1}';
        
        
        insert serviceChannelMsg;        
        serviceChannelMsg.Header__c = 'SignData';
        update serviceChannelMsg;
        Test.stopTest();
        
        List<Case> cases = [SELECT Id,Customer_WO__c FROM Case WHERE Customer_WO__c = 'TEST123'];
        system.assert(cases.size() == 1);
    }    
}