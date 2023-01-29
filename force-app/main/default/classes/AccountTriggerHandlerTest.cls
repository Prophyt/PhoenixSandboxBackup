@isTest
public class AccountTriggerHandlerTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        
        Account a2 = new Account();
        a2.Name = 'TestCoSecond';
        a2.Warranty_Expiration_Date__c = date.today().addDays(-2);
        a2.Under_Warranty__c = true;
        insert a2;
        
        Test.startTest();
        a.Closed_Date__c = date.today();
        a.Under_Warranty__c = true;
        a.Warranty_Expiration_Date__c = date.today();
        update a;
        
        a2.Warranty_Expiration_Date__c = date.today().addDays(1);
        update a2;
        Test.stopTest();
    }
    public static testMethod void runRelatedContactTestNew()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.AccountId = a.Id;
        insert c;
        
        Contact c2 = new Contact();
        c2.FirstName = 'Test2';
        c2.LastName = 'Test2';
        c2.AccountId = a.Id;
        insert c2;
        
        
        /*
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = a.Id;
        acr.ContactId = c.Id;
        acr.IsActive = true;
        acr.StartDate = date.today();
        insert acr;
        */
        system.assert([SELECT Id FROM AccountContactRelation].size() == 2);
        
        List<Account> accounts = new List<Account>();
        Test.startTest();
        Account a2 = new Account();
        a2.Name = 'TestCo 2';
        a2.ParentId = a.Id;
        accounts.add(a2);
        Account a3 = new Account();
        a3.Name = 'TestCo 3';
        a3.ParentId = a.Id;
        accounts.add(a3);
        insert accounts;
        Test.stopTest();
        system.assert([SELECT Id FROM AccountContactRelation].size() == 6);
            
        
    }
    public static testMethod void runRelatedContactTestSync()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.AccountId = a.Id;
        insert c;
        
        Contact c2 = new Contact();
        c2.FirstName = 'Test2';
        c2.LastName = 'Test2';
        c2.AccountId = a.Id;
        insert c2;
        
        Account a2 = new Account();
        a2.Name = 'TestCo 2';
        a2.ParentId = a.Id;
        insert a2;
                
        Test.startTest();
        Contact c3 = new Contact();
        c3.FirstName = 'Test2';
        c3.LastName = 'Test2';
        c3.AccountId = a.Id;
        insert c3;

        
        a2.Name = 'TestCo Update';
        update a2;
        //does the contact relation sync

        Test.stopTest();
        system.assert([SELECT Id FROM AccountContactRelation].size() == 6);
    } 

}