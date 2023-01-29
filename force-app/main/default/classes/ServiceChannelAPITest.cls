@isTest
public class ServiceChannelAPITest 
{
    public static string getJSON()
    {
        string json = '{';
        json += '    "Object": {';
        json += '        "Id": 193183038,';
        json += '        "Number": "193183038",';
        json += '        "PurchaseNumber": "193183038",';
        json += '        "SubscriberId": 2000060222,';
        json += '        "ProviderId": 2000019310,';
        json += '        "ProviderName": "Phoenix Energy Technologies, Inc.",';
        json += '        "LocationId": 2005403869,';
        json += '        "LocationName": "Olympia",';
        json += '        "LocationStoreId": "839",';
        json += '        "Status": {';
        json += '            "Primary": "IN PROGRESS",';
        json += '            "Extended": "DISPATCH CONFIRMED"';
        json += '        },';
        json += '        "Caller": "Leanthony Ferrell",';
        json += '        "CreatedBy": "Leanthony Ferrell",';
        json += '        "CallDate": "2021-12-09T13:15:56",';
        json += '        "Priority": "Standard-2 Business days",';
        json += '        "Trade": "HVAC REPAIRS",';
        json += '        "ScheduledDate": "2021-12-11T13:34:59",';
        json += '        "UpdatedDate": "2021-12-09T16:43:14.697",';
        json += '        "ScheduledDate_DTO": "2021-12-11T16:34:59-05:00",';
        json += '        "ExpirationDate": "2021-12-11T13:34:00",';
        json += '        "Description": "Big description here",';
        json += '        "Category": "BUILDING AUTOMATION SYSTEM",';
        json += '        "Nte": 750,';
        json += '        "CurrencyAlphabeticalCode": "USD",';
        json += '        "ProblemCode": "Temperature issue",';
        json += '        "AssetId": 637515,';
        json += '        "Source": "dashboard179"';
        json += '    },';
        json += '    "Type": "WoRootNotification",';
        json += '    "Action": "NEW",';
        json += '    "EventType": "WorkOrderNoteAdded",';
        json += '    "Version": 1';
        json += '}';
        return json;
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(getJSON());
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    public static void setup() 
    {
        Integration_Message__c msg = new Integration_Message__c();
        msg.Integration_Source__c = 'ServiceChannel';
        msg.Package__c = getJSON();
        insert msg;
        
        Account a = new Account();
        a.Name = 'Petco';
        insert a;
        
        Case c = new Case(Priority='Normal',
                          Status='Accepted',
                          Origin='Email',
                          Subject='Test Subject',
                          Description='Testing Problem Description',
                          AccountId = a.Id,
                          Integration_Message__c = msg.Id,
                          OwnerId=UserInfo.getUserId());
        insert c;
        
        c.OwnerId = UserInfo.getUserId();
        update c;
    }
    public static testMethod void runPetcoAccepted() 
    {
        Case c = [SELECT Id,
                  AccountId,
                  Parent_Account__c,
                  Description,
                  Integration_Message__c
                  FROM Case
                  ORDER BY CreatedDate DESC LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        ServiceChannelAPI.updateWorkOrder(c.Id);        
        Test.stopTest();
    }
    public static testMethod void runPetcoRemotelyResolved() 
    {
        Case c = [SELECT Id,
                  AccountId,
                  Parent_Account__c,
                  Description,
                  Integration_Message__c,
                  Resolution__c
                  FROM Case
                  ORDER BY CreatedDate DESC LIMIT 1];
        
        c.Resolution__c = 'Remotely Resolved';
        c.Status = 'Closed';
        c.OwnerId = UserInfo.getUserId();
        update c;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        ServiceChannelAPI.updateWorkOrder(c.Id);        
        Test.stopTest();
    }    
    public static testMethod void runPetcoDispatchedToVendor() 
    {
        Case c = [SELECT Id,
                  AccountId,
                  Parent_Account__c,
                  Description,
                  Integration_Message__c,
                  Resolution__c
                  FROM Case
                  ORDER BY CreatedDate DESC LIMIT 1];
        
        c.Resolution__c = 'Dispatched to Vendor';
        c.Status = 'Closed';
        c.OwnerId = UserInfo.getUserId();
        update c;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        ServiceChannelAPI.updateWorkOrder(c.Id);        
        Test.stopTest();
    }        
    public static testMethod void runUpdateWorkOrderTest1() 
    {
        Case c = [SELECT Id,
                  AccountId,
                  Parent_Account__c,
                  Description,
                  Integration_Message__c
                  FROM Case
                  ORDER BY CreatedDate DESC LIMIT 1];
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ServiceChannelAPI.updateWorkOrder(c.Id);
        Test.startTest();
        c.Status = 'Completed';
        c.Resolution__c = 'Remotely Resolved';
        update c;
        ServiceChannelAPI.updateWorkOrder(c.Id);        
        Test.stopTest();
    }
    public static testMethod void runUpdateWorkOrderTest2() 
    {
        Integration_Message__c msg = new Integration_Message__c();
        msg.Integration_Source__c = 'ServiceChannel';
        string json = getJSON();
        json = json.replace('"Action": "NEW"', '"Action": "UPDATE"');
        msg.Package__c = json;
        insert msg;
        
        Test.startTest();
        
        Case c = new Case(Priority='Normal',
                          Status='Closed',
                          Resolution__c = 'Dispatched to Vendor',
                          Origin='Email',
                          Subject='Test Subject',
                          Description='Testing Problem Description',
                          Integration_Message__c = msg.Id,
                          OwnerId=UserInfo.getUserId());
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ServiceChannelAPI.updateWorkOrder(c.Id);
        Test.stopTest();
    }
}