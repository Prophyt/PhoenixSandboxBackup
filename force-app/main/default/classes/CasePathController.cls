public without sharing class CasePathController 
{
    @AuraEnabled
    public static boolean IsNonAPICustomer(string recordId)
    {
        Set<string> nonApiCustomers = new Set<string>();
        nonApiCustomers.add('HSBC Bank');
        nonApiCustomers.add('Office Depot');
        nonApiCustomers.add('Dollar Tree');
        nonApiCustomers.add('Cinemark');
        nonApiCustomers.add('Albertsons');
        
        Case c = [SELECT Id,
                  AccountId,
                  Parent_Account__c,
                  Parent_Account__r.Name
                  FROM Case
                  WHERE Id = :recordId];
        
        if(c.Parent_Account__c != null && nonApiCustomers.contains(c.Parent_Account__r.Name))
        {
            system.debug(c.Parent_Account__r.Name);
            return true;            
        }
        else
        {
            return false;            
        }

    }
	@AuraEnabled
    public static string getRecordTypeId(string recordId)
    {
        return [SELECT RecordTypeId FROM Case WHERE Id = :recordId].RecordTypeId;
    }
}