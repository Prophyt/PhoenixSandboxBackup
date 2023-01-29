public without sharing class SMSAssistWorkOrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    
    public string finalEndpoint {get;set;}
    public SMSAssistWorkOrderBatch(string endpoint)
    {
        if(!string.isBlank(endpoint))
        {
            this.finalEndpoint = endpoint;            
        }
        else
        {
            DateTime dt = DateTime.now().addHours(-48);
            String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'GMT');
            //https://meshlive.smsassist.com/api/v1.0/workorder/reactive/list?call_time_after=<dt>
            endPoint = IntegrationUtilities.getBaseUrl() + '/api/v1.0/workorder/reactive/list?call_time_after=' + formattedDt;
            this.finalEndpoint = endPoint;
        }   
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        string query = 'SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1'; //we need a query to start the batch, its unrelated
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('Starting Callout for Endpoint:');
        system.debug(finalEndpoint);
        SMSAssistWorkOrderQueueable.processAPIResults(finalEndpoint);
    }
    public void finish (Database.BatchableContext BC) 
    { 
        
    }
}