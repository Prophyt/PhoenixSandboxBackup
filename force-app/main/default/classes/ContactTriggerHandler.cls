public without sharing class ContactTriggerHandler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static Log logger = Log.get();
    public ContactTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Contact[] triggerNew)
    {
    }
    public void OnBeforeUpdate(Contact[] triggerOld, Map<Id, Contact> triggerOldMap, Contact[] triggerNew, Map<ID, Contact> triggerNewMap)
    {
    }
    public void OnAfterInsert(Contact[] triggerOld, Map<Id, Contact> triggerOldMap, Contact[] triggerNew, Map<Id, Contact> triggerNewMap)
    {
        processNewRelatedContacts(triggerNew);
    }
    public void OnAfterUpdate(Contact[] triggerOld, Map<Id, Contact> triggerOldMap, Contact[] triggerNew, Map<ID, Contact> triggerNewMap)
    {
    }
    public static void processNewRelatedContacts(Contact[] triggerNew)
    {
        Set<Id> accountIds = new Set<Id>();
        for(Contact c : triggerNew)
        {
            if(c.AccountId != null && !accountIds.contains(c.AccountId))
                accountIds.add(c.AccountId);
        }
        
        //get all the corporate client accounts for any inserted contacts
        Id corporateAccountId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Corporate Client').getRecordTypeId();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name,
                                                            Region__c,
                                                            RecordTypeId
                                                            FROM Account
                                                            WHERE Id IN :accountIds
                                                            AND RecordTypeId = :corporateAccountId]);
        
        Map<Id, List<Contact>> corporateContacts = new Map<Id, List<Contact>>();
        for(Contact c : triggerNew)
        {
            if(c.AccountId != null && accountMap.containsKey(c.AccountId))
            {
                //we have a corporate contact
                if(corporateContacts.containsKey(c.AccountId))
                {
                    List<Contact> cItems = corporateContacts.get(c.AccountId);
                    cItems.add(c);
                    corporateContacts.put(c.AccountId, cItems);
                }
                else
                {
                    List<Contact> cItems = new List<Contact>();
                    cItems.add(c);
                    corporateContacts.put(c.AccountId, cItems);
                }
            }
        }
        
        
        List<AccountContactRelation> acrs = new List<AccountContactRelation>();
        
        for(Account a : [SELECT Id,
                         Name,
                         ParentId,
                         Region__c
                         FROM Account
                         WHERE ParentId IN :corporateContacts.keySet()])
        {
            List<Contact> cItems = corporateContacts.containsKey(a.ParentId) ? corporateContacts.get(a.ParentId) : null;
            if(cItems == null)
                continue;
            
            //non corporate contacts arent even in this list, but they only go where they are created - no copying ACR
            //corporate sephora contacts specifically only copy to the region they are created under
            for(Contact c : cItems)
            {
                Account contactAccount = accountMap.get(c.AccountId);
                if(a.Name.containsIgnoreCase('sephora') && c.Contact_Type__c != null && c.Contact_Type__c == 'Corporate VIP' && a.Region__c != c.Contact_Region__c)
                    continue;
                
                system.debug('Passed Sephora Filter');
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = a.Id;
                acr.ContactId = c.Id;
                acr.StartDate = Date.today();
                acr.IsActive = true;
                acr.Roles = '';
                acrs.add(acr);
            }            
        }
        
        if(!acrs.isEmpty())
        {
            List<Database.SaveResult> results = database.insert(acrs, false);
            for(Database.SaveResult sr : results)
            {
                if(!sr.isSuccess())
                {
                    for(Database.Error e : sr.getErrors())
                    {
                        logger.publish(e.getMessage(), 'ContactTriggerHandler',LogSeverity.ERROR);
                        system.debug(e.getMessage());
                    }
                }
            }
        }
    }
}