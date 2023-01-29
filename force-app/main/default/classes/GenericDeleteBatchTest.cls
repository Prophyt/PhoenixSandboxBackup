@isTest
public class GenericDeleteBatchTest 
{
	public static testMethod void RunTest()
    {
        Lead l = new Lead();
        l.FirstName = 'Test';
        l.LastName = 'Test';
        l.Company = 'Test';
        l.Phone = '1231231234';
        l.LeadSource = 'Test';
        insert l;
        
        Test.startTest();
        GenericDeleteBatch b = new GenericDeleteBatch('SELECT Id FROM Lead WHERE LastName = \'Test\'');
        database.executeBatch(b);
        Test.stopTest();
    }
}