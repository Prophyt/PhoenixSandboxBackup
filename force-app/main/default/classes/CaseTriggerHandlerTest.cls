@isTest
public class CaseTriggerHandlerTest 
{
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
        
        
        Account parent = new Account();
        parent.Name = 'Parent Petco Account';
        insert parent;
        
        SLAProcess s = [SELECT Id 
                        FROM SLAProcess
                        WHERE SObjectType = 'Case' 
                        LIMIT 1];
        
        
        Entitlement e = new Entitlement();
        e.AccountId = parent.Id;
        e.SlaProcessId = s.Id;
        e.Name = 'Silver';
        e.StartDate = date.today().addDays(-1);
        insert e;
    }
    public static testMethod void runIntegrationMessageTest()
    {
        Integration_Message__c i = new Integration_Message__c();
        i.Integration_Source__c = 'SMS Assist';
        i.Package__c = '{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"Pending Vendor Acceptance"}';
        insert i;
        
        Test.setMock(HttpCalloutMock.class, new IntegrationMessageTriggerHandlerTest.MockHttpResponseGenerator());
        Test.startTest();
        Case c = new Case();
        insert c;
        
        c.Integration_Message__c = i.Id;
        update c;
        Test.stopTest();
    }
    public static testMethod void runSMSAssistMessageTest()
    {
        Integration_Message__c msg = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"Pending Vendor Acceptance"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist');
        insert msg;
        
        Case c = [SELECT Id,
                  Status,
                  Customer_WO__c,
                  X3rd_Party_System__c,
                  Has_Been_Accepted__c
                  FROM Case 
                  WHERE Integration_Message__c = :msg.Id];
        
        c.Customer_WO__c = '';
        system.debug(c);
        Test.setMock(HttpCalloutMock.class, new IntegrationMessageTriggerHandlerTest.MockHttpResponseGenerator());
        Test.startTest();

        c.Status = 'New';
        c.Subject = 'test';
        c.Customer_WO__c = 'B7267123';
        update c;
        

        Test.stopTest();
    }    
    public static testMethod void runSMSAssistAcceptedMessageTest()
    {
        Integration_Message__c msg = new Integration_Message__c(
            Package__c='{"LocationId":"123","WorkOrderNumber":"B7267123","WoId":"123","Priority":"Normal","TradeName":"Test","AfterStatus":"Pending Vendor Acceptance"}',
            Header__c='SignData',
            Integration_Source__c ='SMS Assist');
        insert msg;
        
        Case c = [SELECT Id,
                  Status,
                  Customer_WO__c,
                  X3rd_Party_System__c,
                  Has_Been_Accepted__c
                  FROM Case 
                  WHERE Integration_Message__c = :msg.Id];
        
        c.Status = 'Accepted';
        c.Has_Been_Accepted__c = true;
        c.Accepted_Date_Time__c = DateTime.now();
        update c;
        
        c = [SELECT Id,
             Status,
             Customer_WO__c,
             X3rd_Party_System__c,
             Has_Been_Accepted__c
             FROM Case 
             WHERE Integration_Message__c = :msg.Id];
        
        system.debug(c);
        
        Test.setMock(HttpCalloutMock.class, new IntegrationMessageTriggerHandlerTest.MockHttpResponseGenerator());
        Test.startTest();
		c.Resolution__c = 'Dispatched to Vendor';
        c.Status = 'Closed';
        update c;
        Test.stopTest();
    } 
    public static testMethod void runReminderTest()
    {
        Account pa = new Account();
        pa.Name = 'TestCo';
        insert pa;
        Account a = new Account();
        a.Name = 'TestCo 123';
        a.ParentId = pa.Id;
        insert a;
        Case c = new Case();
        c.Subject = 'test';
        c.Description = 'Test';
        c.AccountId = a.Id;
        c.Parent_Account__c = pa.Id;
        insert c;
        
        Test.startTest();
        c.Reminder_Date_Time__c = DateTime.now();
        c.Reminder_Note__c = 'Test Note';
        update c;
        Test.stopTest();
        
        c = [SELECT Id,Reminder_Date_Time__c,Reminder_Note__c FROM Case WHERE Id = :c.ID];
        system.assert(c.Reminder_Date_Time__c == null);
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatID = :c.Id];
        system.assert(tasks.size() == 1);
            
    }
    public static testMethod void flowConversionTest()
    {
        Map<string, MilestoneType> milestoneTypeMap = CaseTriggerHandler.milestoneTypeMap;
        Account pa = [SELECT Id FROM Account WHERE Name = 'Parent Petco Account'];
        
        Account a = new Account();
        a.Name = 'petco 123';
        a.ParentId = pa.Id;
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'test';
        c.Description = 'Test';
        c.Case_Comment__c = '';
        insert c;
        
        Test.startTest();
        c.AccountId = a.Id;
        c.Priority = 'Emergency';
        c.Escalate_To__c = 'Account Lead';
        c.Case_Comment__c = 'testing';
        c.Resolution__c = 'Dispatched to Vendor';
        c.Resolution_Note__c = 'Testing';
        update c;
        
        Test.stopTest();
    }
    public static testMethod void escalateEngineerTest()
    {
        Account pa = [SELECT Id FROM Account WHERE Name = 'Parent Petco Account'];
        
        Account a = new Account();
        a.Name = 'petco 123';
        a.ParentId = pa.Id;
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'test';
        c.Description = 'Test';
        c.Case_Comment__c = '';
        insert c;
        
        Test.startTest();
        c.AccountId = a.Id;
        c.Priority = 'Emergency';
        c.Escalate_To__c = 'Tech Lead / Engineer';
        update c;
        Test.stopTest();
    }  
    public static testMethod void escalateSupervisorTest()
    {
        Account pa = [SELECT Id FROM Account WHERE Name = 'Parent Petco Account'];
        
        Account a = new Account();
        a.Name = 'petco 123';
        a.ParentId = pa.Id;
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'test';
        c.Description = 'Test';
        c.Case_Comment__c = '';
        insert c;
        
        Test.startTest();
        c.AccountId = a.Id;
        c.Priority = 'Emergency';
        c.Escalate_To__c = 'Supervisor';
        update c;
        Test.stopTest();
    }  
}