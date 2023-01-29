@IsTest
public class EDXLocationBatchTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.Name = 'Test';
        a.Site_Number__c = '12345';
        insert a;
        
        EDX_Location__c e = new EDX_Location__c();
        e.Name = 'Test';
        e.Customer_Name__c = 'Test';
        e.Site_Number__c = '12345';
        e.EDX_ID__c = '555555';
        insert e;
        
        Test.startTest();
        EDXLocationBatch b = new EDXLocationBatch('');
        database.executeBatch(b);
        Test.stopTest();
        
    }
}