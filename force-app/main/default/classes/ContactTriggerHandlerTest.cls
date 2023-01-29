@isTest
public class ContactTriggerHandlerTest 
{
	public static testMethod void RunTest()
    {
        Account a = new Account();
        a.Name = 'Test Parent';
        a.RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Corporate Client').getRecordTypeId();
        insert a;
        
        Account a1 = new Account();
        a1.Name = 'Test Child';
        a1.ParentId = a.Id;
        a1.RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Store Location').getRecordTypeId();
        insert a1;
        
        
        List<Contact> contacts = new List<Contact>();
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.Phone = '1231231234';
        c.Email = 'test@test.com';
        c.Contact_Type__c = 'Corporate';
        //insert c;
        contacts.add(c);
        
        Contact c2 = new Contact();
        c2.AccountId = a.Id;
        c2.FirstName = 'Test';
        c2.LastName = 'Test';
        c2.Phone = '1231231234';
        c2.Email = 'test@test.com';
        c2.Contact_Type__c = 'Corporate';
        //insert c2;
        contacts.add(c2);
        
        insert contacts;
        
        Test.startTest();
        List<AccountContactRelation> acrs = [SELECT Id FROM AccountContactRelation];
        system.assert(acrs.size() == 4);
        c2.LastName = 'Update';
        update c2;
        Test.stopTest();
    }
}