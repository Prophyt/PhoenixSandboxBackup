@isTest
public class GenericDeleteDuplicateBatchTest 
{
	@testSetup
    public static void setup()
    {
        /*
        string q = 'SELECT Id, Call_Manager_Case__c, CreatedById, OwnerId, CreatedDate, LastModifiedDate FROM Case WHERE Call_Manager_Case__c != null AND Call_Manager_Case__c != \'\' AND Owner.name = \'Call Manager Import\' ORDER BY Call_Manager_Case__c, LastModifiedDate DESC';
        GenericDeleteDuplicateBatch b = new GenericDeleteDuplicateBatch(q);
        database.executeBatch(b,1);
		*/
        
        Id ownerId = [SELECT Id FROM User WHERE Name = 'Call Manager Import' LIMIT 1].Id;
        
        Case c = new Case();
        c.Call_Manager_Case__c = 'TESTX';
        c.OwnerId = ownerId;
        insert c;
        
        Case c2 = new Case();
        c2.Call_Manager_Case__c = 'TESTX';
        c2.OwnerId = ownerId;
        insert c2;
        
        Case c3 = new Case();
        c3.Call_Manager_Case__c = 'TESTX';
        c3.OwnerId = ownerId;
        insert c3;
    }
    public static testMethod void runTest()
    {

        
        List<Case> cases = [SELECT Id, OwnerId,Owner.Name,Call_Manager_Case__c FROM Case];
        system.debug(cases);
        Test.startTest();
        
        string q = 'SELECT Id, Call_Manager_Case__c, CreatedById, OwnerId, CreatedDate, LastModifiedDate FROM Case ';
        q += ' ORDER BY Call_Manager_Case__c, LastModifiedDate DESC LIMIT 200';
        GenericDeleteDuplicateBatch b = new GenericDeleteDuplicateBatch(q);
        Database.executeBatch(b, 200);
        Test.stopTest();
        
        system.assertEquals(1, [SELECT Id FROM Case].size());
    }
}