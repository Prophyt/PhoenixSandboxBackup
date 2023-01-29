global class GenericDeleteDuplicateBatch implements Database.Batchable<sObject>, Database.Stateful
{
    public Set<string> caseIdsToKeep = new Set<string>();
    public string query {get;set;}
    /*    
    SELECT Id, Call_Manager_Case__c, CreatedById, OwnerId, CreatedDate, LastModifiedDate
    FROM Case
    WHERE Call_Manager_Case__c != null
    AND Call_Manager_Case__c != ''
    AND Owner.name = 'Call Manager Import'
    ORDER BY Call_Manager_Case__c, LastModifiedDate DESC
	*/
    public GenericDeleteDuplicateBatch(string q)
    {

        if(!string.isBlank(q))
            this.query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<sObject> scope)
    {
        List<Case> casesToDelete = new List<Case>();
        

        for(Case c : (List<Case>)scope)
        {
            if(caseIdsToKeep.contains(c.Call_Manager_Case__c))
                continue;
            
            caseIdsToKeep.add(c.Call_Manager_Case__c);
            casesToDelete.addAll([SELECT Id
                                  FROM Case
                                  WHERE Call_Manager_Case__c = :c.Call_Manager_Case__c
                                  AND Call_Manager_Case__c != null
                                  AND OwnerId = :c.OwnerID
                                  AND Id != :c.Id]);
        }
        
        system.debug(casesToDelete.size());
        Database.DeleteResult[] results = database.delete(casesToDelete, false);
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
        system.debug('Finished running GenericDeleteDuplicateBatch at ' + now);
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