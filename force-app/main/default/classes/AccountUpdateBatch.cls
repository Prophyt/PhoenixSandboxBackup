public class AccountUpdateBatch implements Database.Batchable<sObject>
{
    public string query {get;set;}
    public AccountUpdateBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Account> scope)
    {
        Date today = Date.today();
        List<Account> items = new List<Account>();
        for(Account a : scope)
        {
            if(a.Closed_Date__c != null && a.Closed_Date__c <= today && a.Location_Status__c != 'Inactive')
            {
                a.Location_Status__c = 'Inactive';
                items.add(a);
            }
        }
        update items;
    }
    public void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running AccountUpdateBatch at ' + now);
        AsyncApexJob a = [SELECT Id, 
                          Status,
                          ExtendedStatus,
                          NumberOfErrors, 
                          JobItemsProcessed,
                          TotalJobItems, 
                          CreatedBy.Email    
                          FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        system.debug(a);        
    }
}