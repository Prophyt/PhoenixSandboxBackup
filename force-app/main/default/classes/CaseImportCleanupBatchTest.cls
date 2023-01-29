@isTest
public class CaseImportCleanupBatchTest 
{

    @testSetup
    public static void setup()
    {
        Case c = new Case();
        c.Status ='NeedsReview';
        insert c;
        
        Case c2 = new Case();
        c2.Status = 'Dispatched to Vendor';
        insert c2;
        
        Case c3 = new Case();
        c3.Status = 'Work Deferred';
        insert c3;
        
        Account a = new Account();
        a.Name = 'Placeholder Account (no match on API create)';
        insert a;
        
        Case c4 = new Case();
        c4.AccountId = a.Id;
        c4.OwnerId = [SELECT Id FROM User WHERE Name = 'Admin User' LIMIT 1].Id;
        insert c4;
    }
    public static testMethod void runTest()
    {
        test.startTest();
        string q = 'SELECT Id,Status,AccountId,Account.Name,OwnerId,Owner.Name FROM Case';
        CaseImportCleanupBatch b = new CaseImportCleanupBatch(q);
        database.executeBatch(b);
        test.stopTest();
    }
}