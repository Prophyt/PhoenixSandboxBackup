@isTest
public class AlertBarControllerTest 
{
	public static testMethod void RunTest()
    {
        Account a = new Account();
        a.Name = 'Office Depot';
        insert a;
        
        Account ab = new Account();
        ab.Name = 'TestChild';
        ab.ParentId = a.ID;
        insert ab;
        
        Case c = new Case();
        c.AccountId = ab.Id;
        insert c;
        
        Client_Alert__c ca = new Client_Alert__c();
        ca.Start_Date__c = Date.today();
        ca.Pop_on_Case__c = 'Yes';
        ca.Alert_Applies_to__c = 'This Store Only';
        ca.Account__c = ab.Id;
        ca.Message__c = 'Test';
        ca.Status__c = 'Active';
        insert ca;
        
        Client_Alert__c ca2 = new Client_Alert__c();
        ca2.Start_Date__c = Date.today();
        ca2.Pop_on_Case__c = 'Yes';
        ca2.Alert_Applies_to__c = 'Corporate Account and ALL its Stores';
        ca2.Account__c = ab.Id;
        ca2.Message__c = 'Test 2';
        ca2.Status__c = 'Active';
        insert ca2;
        
        Test.startTest();
        AlertBarController.getAlerts(c.Id);
        AlertBarController.getAlerts(ab.Id);
        Test.stopTest();
        
    }
}