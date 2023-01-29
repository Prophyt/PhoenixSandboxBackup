@isTest
public class CustomLookupControllerTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.name = 'Test';
        insert a;
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.AccountId = a.Id;
        insert c;
        
        CustomLookupController.getContactFilteredResults('Contact','Name','test',a.Id);
        CustomLookupController.getResults('Account','Name','test');
    }
}