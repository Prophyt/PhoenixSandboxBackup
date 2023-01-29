public without sharing class AccountTriggerHandler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public AccountTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Account[] triggerNew)
    {
        setStatus(triggerNew);        
    }
    public void OnBeforeUpdate(Account[] triggerOld, Map<Id, Account> triggerOldMap, Account[] triggerNew, Map<ID, Account> triggerNewMap)
    {
        setStatus(triggerNew);
    }
    public void OnAfterInsert(Account[] triggerOld, Map<Id, Account> triggerOldMap, Account[] triggerNew, Map<Id, Account> triggerNewMap)
    {
        if(!system.isBatch() && !system.isQueueable() && !system.isFuture())
            system.enqueueJob(new SetRelatedContactsQueueable(triggerNew));
    }
    public void OnAfterUpdate(Account[] triggerOld, Map<Id, Account> triggerOldMap, Account[] triggerNew, Map<ID, Account> triggerNewMap)
    {
        processWarrantySettings(triggerOldMap, triggerNewMap);
        if(!system.isBatch() && !system.isQueueable() && !system.isFuture())
            system.enqueueJob(new SetRelatedContactsQueueable(triggerNew));
    }
    public static void setStatus(List<Account> triggerNew)
    {
        Date today = Date.today();
        for(Account a : triggerNew)
        {
            if(a.Closed_Date__c != null && a.Closed_Date__c <= today)
                a.Location_Status__c = 'Inactive';
        }
    }
    public static void processWarrantySettings(Map<Id, Account> triggerOldMap, Map<Id, Account> triggerNewMap)
    {

        Set<Id> accountIdsToAdd = new Set<Id>();
        Set<Id> accountIdsToUpdate = new Set<Id>();
        
        for(Account a : triggerNewMap.values())
        {
            Account old = triggerOldMap.get(a.Id);
            if(a.Under_Warranty__c == true && old.Under_Warranty__c == false)
                accountIdsToAdd.add(a.Id);
            if(a.Warranty_Expiration_Date__c != old.Warranty_Expiration_Date__c)
                accountIdsToUpdate.add(a.Id);
        }
        
        List<Client_Alert__c> itemsToInsert = new List<Client_Alert__c>();
        for(Id key : accountIdsToAdd)
        {
            Account a = triggerNewMap.get(key);
            Client_Alert__c ca = new Client_Alert__c();
            ca.Account__c = key;
            ca.Alert_Applies_to__c = 'Corporate Account and ALL its Stores';
            ca.End_Date__c = a.Warranty_Expiration_Date__c != null ? a.Warranty_Expiration_Date__c : null;
            ca.Start_Date__c = date.today();
            ca.Message__c = 'Site under warranty ' + (a.Warranty_Expiration_Date__c != null ? ' until ' + a.Warranty_Expiration_Date__c.format() : '');
            ca.Status__c = 'Active';
            ca.Pop_on_Case__c = 'Yes';
            itemsToInsert.add(ca);
        }
        
        insert itemsToInsert;
        
        List<Client_Alert__c> itemsToUpdate = new List<Client_Alert__c>();
        for(Client_Alert__c ca : [SELECT Id,
                                  Account__c,
                                  Start_Date__c,
                                  End_Date__c,
                                  Message__c,
                                  Status__c
                                  FROM Client_Alert__c
                                  WHERE Account__c IN :accountIdsToUpdate])
        {
            Account a = triggerNewMap.get(ca.Account__c);
            if(a.Warranty_Expiration_Date__c == null)
                continue;
            
            string msg = ca.Message__c;
            Date accountDate = a.Warranty_Expiration_Date__c;
            Date alertDate = ca.End_Date__c;
            if(msg.startsWith('Site under warranty'))
            {
                ca.Message__c = 'Site under warranty ' + (a.Warranty_Expiration_Date__c != null ? ' until ' + a.Warranty_Expiration_Date__c.format() : '');
                ca.End_Date__c = a.Warranty_Expiration_Date__c;
            }
            
            itemsToUpdate.add(ca);
        }
        update itemsToUpdate;
        
    }
}