public class ReminderQueueBatch implements Database.Batchable<sObject>
{
    private static Log logger = Log.get();
    public string query {get;set;}
    public DateTime now 
    {
        get
        {
        	if(now == null)
                now = DateTime.now().addMinutes(-5);
            
            return now;
        }
        set;
    }
    public static Map<string, Group> groupMap
    {
        get
        {
            if(groupMap == null)
            {
                groupMap = new Map<string, Group>();
                for(Group g : [SELECT Id,
                               Name
                               FROM Group
                               WHERE Type = 'Queue'
                               ORDER BY Name ASC])
                {
                    groupMap.put(g.Name, g);
                }
            }
            
            return groupMap;
        }
        set;
    }
    public static string queueId
    {
        get
        {
            if(queueId == null)
            {
                queueId = groupMap.get('Reminder Queue').Id;                
            }
            return queueId;
        }
        set;
    }
    public ReminderQueueBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
        else
            query = getDefaultQuery();
    }
    public static string getDefaultQuery()
    {
        return 'SELECT Id,OwnerId,ReminderDateTime,WhatId FROM Task WHERE ReminderDateTime <= :now AND OwnerId = :queueId';
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Task> scope)
    {
        Set<Id> whatIds = new Set<Id>();
        for(Task t : scope)
        {
            if(!whatIds.contains(t.WhatId))
                whatIds.add(t.WhatId);
        }
        
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id,
                                                 Parent_Account__c,
                                                 Parent_Account__r.Name
                                                 FROM Case
                                                 WHERE Id IN :whatIds
                                                 AND Parent_Account__c != null]);
        
        List<Task> itemsToUpdate = new List<Task>();
        for(Task t : scope)
        {
            //system.debug('Processing Task ' + t.Id);
            if(cases.containsKey(t.WhatId) && groupMap.containsKey(cases.get(t.WhatId).Parent_Account__r.Name))
            {
                //system.debug('Assigning Task');
                t.OwnerId = groupMap.get(cases.get(t.WhatId).Parent_Account__r.Name).Id;
                itemsToUpdate.add(t);
            }
        }
        if(!itemsToUpdate.isEmpty())
            update itemsToUpdate;
    }
    public void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running ReminderQueueBatch at ' + now);
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