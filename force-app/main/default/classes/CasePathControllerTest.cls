@isTest
public class CasePathControllerTest 
{
	public static testMethod void runTest()
    {
        Account parent = new Account();
        parent.Name = 'HSBC Bank';
        parent.RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Corporate Client').getRecordTypeId();
        insert parent;
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.ParentId = parent.Id;
        insert a;
        
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Parent_Account__c = parent.Id;
        insert c;
        
        CasePathController.getRecordTypeId(c.Id);
        CasePathController.IsNonAPICustomer(c.Id);
    }
}