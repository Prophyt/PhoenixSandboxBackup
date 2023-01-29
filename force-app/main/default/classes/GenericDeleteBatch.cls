global class GenericDeleteBatch implements Database.Batchable<sObject>
{
    private static Log logger = Log.get();
    public string query {get;set;}
    public GenericDeleteBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<sObject> scope)
    {
        Database.DeleteResult[] results = database.delete(scope, false);
        for(Database.DeleteResult dr : results)
        {
            if(!dr.isSuccess())
            {
                for(Database.Error e : dr.getErrors())
                {
                    system.debug(e.getMessage());
                }
            }
        }
    }
    global void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running GenericDeleteBatch at ' + now);
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