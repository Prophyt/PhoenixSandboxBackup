public class ClientAlertBatch implements Database.Batchable<sObject>
{
    public string query {get;set;}
    public ClientAlertBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Client_Alert__c> scope)
    {
        Date today = Date.today();
        List<Client_Alert__c> items = new List<Client_Alert__c>();
        for(Client_Alert__c c : scope)
        {
            if(c.End_Date__c != null && c.End_Date__c < today)
            {
                c.Status__c = 'Inactive';
                c.Pop_on_Case__c  = 'No';
                items.add(c);
            }
        }
        update items;
    }
    public void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running ClientAlertBatch at ' + now);
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