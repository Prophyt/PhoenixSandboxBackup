global class EDXLocationBatch implements Database.Batchable<sObject>
{
    private static Log logger = Log.get();
    public string query {get;set;}
    public EDXLocationBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
        else
            query = 'SELECT Id,Name,Site_Number__c,EDX_ID__c,Parent.Name FROM Account WHERE Site_Number__c != null ORDER BY Name,Site_Number__c ASC';
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Account> scope)
    {
        Map<string, account> mymap = new Map<string, account>();
        List<Account> accountsToUpdate = new List<Account>();
        for(Account a : scope)
        {
            string accountName = a.parent.name == null ? a.name.toLowercase() : a.parent.name.tolowercase();
            string site = a.site_number__c;
            if(accountName.contains(site))
                accountName = accountName.replace(site, '');
            
            accountName = accountName.trim();
            
            
            string parentSiteKey = accountName + site;
            mymap.put(parentSiteKey, a);
        }
        
        for(EDX_Location__c e : [SELECT Id,Customer_Name__c,EDX_ID__c,Site_Number__c
                                 FROM EDX_Location__c
                                 ORDER BY Customer_Name__c, Site_Number__c ASC])
        {
            
            string eKey = e.customer_name__c.toLowerCase() + e.Site_Number__c;
            if(mymap.containsKey(eKey))
            {
                account a = mymap.get(eKey);
                a.EDX_ID__c = e.EDX_ID__c;
                accountsToUpdate.add(a);
            }
        }
        
        system.debug(accountsToUpdate.size() + ' ** RECORDS TO UPDATE');
        database.update(accountsToUpdate, false);
        
    }
    global void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running EDXLocationBatch at ' + now);
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