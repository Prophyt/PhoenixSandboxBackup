global class KnowledgeUtilsBatch implements Database.Batchable<sObject>
{
    //pass in the query to select the knowledge articles you want - MUST use the KnowledgeArticleId
    //and pass in a knowledge article template - just create one with all the properties set
    //and it will use that for this batch
    public string query {get;set;}
    public Knowledge__kav articleTemplate {get;set;}
    public KnowledgeUtilsBatch(string q, Knowledge__kav articleTemplateRecord)
    {
        if(!string.isBlank(q))
            this.query = q;
        if(articleTemplateRecord != null)
            this.articleTemplate = articleTemplateRecord;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Knowledge__kav> scope)
    {
        for(Knowledge__kav k : scope)
        {
         	string newVersionId = KnowledgeUtils.updateArticleFlags(string.valueOf(k.KnowledgeArticleId), articleTemplate);
            system.debug(newVersionId);
        }
    }
    global void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running KnowledgeUtilsBatch at ' + now);
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