public class SetRelatedContactsQueueable implements Queueable
{
    private List<Account> records;

    public SetRelatedContactsQueueable(List<Account> recordsList)
    {
        this.records = recordsList;
    }

    public void execute(QueueableContext context) 
    {
        Map<Id, Id> accountIdParentIdMap = new Map<Id, Id>();
        Map<Id, Set<Id>> parentIdAccountIdMap = new Map<Id, Set<Id>>();
        for(Account a : records)
        {
            if(a.ParentId != null)
            {
                accountIdParentIdMap.put(a.Id, a.ParentId);
                if(parentIdAccountIdMap.containsKey(a.ParentId))
                {
                    Set<Id> items = parentIdAccountIdMap.get(a.ParentId);
                    items.add(a.Id);
                    parentIdAccountIdMap.put(a.ParentId, items);
                }
                else
                {
                    Set<Id> items = new Set<Id>();
                    items.add(a.Id);
                    parentIdAccountIdMap.put(a.ParentId, items);                    
                }               
            }
        }
        
        Map<Id, List<AccountContactRelation>> accountIdContacts = getExistingAccountContactRelations(accountIdParentIdMap.keySet());
        Map<Id, List<AccountContactRelation>> parentIdContacts = getExistingAccountContactRelations(parentIdAccountIdMap.keySet());        
        
        List<AccountContactRelation> itemsToInsert = new List<AccountContactRelation>();
        for(Account a : records)
        {
            if(a.ParentId != null && parentIdContacts.containsKey(a.ParentId))
            {
                for(AccountContactRelation acr : parentIdContacts.get(a.ParentId))
                {
                    boolean hasContact = false;
                    if(accountIdContacts.containsKey(a.Id))
                    {
                        for(AccountContactRelation subACR : accountIdContacts.get(a.Id))
                        {
                            if(subACR.ContactId == acr.ContactId)
                            {
                                hasContact = true;
                                break;
                            }
                        }
                    }
                    if(hasContact == true)
                        continue;
                    
                    
                    if(a.Name.containsIgnoreCase('sephora') && acr.Contact.Contact_Type__c == 'Corporate VIP')
                    {
                        system.debug('In Sephora Corporate Check');
                        //only copy Sephora Corporate VIP to other accounts in the same Region__c

                        if(a.Region__c == null || acr.Contact.Contact_Region__c == null || a.Region__c != acr.Contact.Contact_Region__c)
                            continue;
                    }

                    AccountContactRelation acrNew = new AccountContactRelation();
                    acrNew.AccountId = a.Id;
                    acrNew.ContactId = acr.ContactId;
                    acrNew.IsActive = true;
                    acrNew.Roles = acr.Roles;
                    acrNew.StartDate = date.today();
                    itemsToInsert.add(acrNew);
                }
            }
        }
        
        if(!itemsToInsert.isEmpty())
            insert itemsToInsert;
    }
    public static Map<Id, List<AccountContactRelation>> getExistingAccountContactRelations(Set<Id> accountIds)
    {
        Map<Id, List<AccountContactRelation>> accountIdContacts = new Map<Id, List<AccountContactRelation>>();
        for(AccountContactRelation acr : [SELECT Id,
                                          AccountId,
                                          Account.Name,
                                          Account.Region__c,
                                          ContactId,
                                          Contact.Contact_Type__c,
                                          Contact.Contact_Region__c,
                                          Roles
                                          FROM AccountContactRelation
                                          WHERE AccountId IN :accountIds
                                          AND IsActive = TRUE])
        {
            if(accountIdContacts.containsKey(acr.AccountId))
            {
                List<AccountContactRelation> items = accountIdContacts.get(acr.AccountId);
                items.add(acr);
                accountIdContacts.put(acr.AccountId, items);
            }
            else
            {
                List<AccountContactRelation> items = new List<AccountContactRelation>();
                items.add(acr);
                accountIdContacts.put(acr.AccountId, items);
            }
        }
        
        return accountIdContacts;
    }
    
}