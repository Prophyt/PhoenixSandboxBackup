public without sharing class AlertBarController 
{
    @AuraEnabled
    public static List<Client_Alert__c> getAlerts(string recordId)
    {
        Schema.SObjectType token = Id.valueOf(recordId).getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        String objectName = dr.getName();
        System.debug('Alerts object name: ' + objectName);
        if(objectName == 'Account')
            return getAccountAlerts(recordId);
        else if(objectName == 'Case')
            return getCaseAlerts(recordId);
        else
            return new List<Client_Alert__c>();

    }
	private static List<Client_Alert__c> getAccountAlerts(string accountId)
    {
        if(string.isBlank(accountId))
            return new List<Client_Alert__c>();
        
        Account a = [SELECT Id,
                    ParentId
                    FROM Account
                    WHERE Id = :accountId];
        
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(a.Id);
        if(a.ParentId != null)
            accountIds.add(a.ParentId);
        
        List<Client_Alert__c> allAlerts = [SELECT Id,
                                           Account__c,
                                           Start_Date__c,
                                           End_Date__c,
                                           Message__c,
                                           Status__c,
                                           Alert_Applies_To__c
                                           FROM Client_Alert__c
                                           WHERE Status__c != 'Inactive'
                                           AND Account__c IN :accountIds
                                           AND Alert_Applies_To__c IN ('Corporate Account and ALL its Stores','This Store Only')
                                           AND Pop_on_Case__c = 'Yes'
                                           ORDER BY Sort_Order__c ASC];   
        
        return allAlerts;
    }
    private static List<Client_Alert__c> getCaseAlerts(string caseId)
    {
        if(string.isBlank(caseId))
            return new List<Client_Alert__c>();
        
        List<Case> cases = [SELECT Id,
                            AccountId,
                            Account.ParentId,
                            Account.Name,
                            OwnerId,
                            Owner_Is_Queue__c
                            FROM Case
                            WHERE Id = :caseId];
        if(cases.isEmpty())
            return new List<Client_Alert__c>();

		Case c = cases[0];        
        if(c.AccountId == null)
            return new List<Client_Alert__c>();
                
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(c.AccountId);
        if(c.AccountId != null && c.Account.ParentId != null)
            accountIds.add(c.Account.ParentId);
        
        List<Client_Alert__c> allAlerts = [SELECT Id,
                                           Account__c,
                                           Start_Date__c,
                                           End_Date__c,
                                           Message__c,
                                           Status__c,
                                           Alert_Applies_To__c
                                           FROM Client_Alert__c
                                           WHERE Status__c != 'Inactive'
                                           AND Account__c IN :accountIds
                                           AND Alert_Applies_To__c IN ('Corporate Account and ALL its Stores','This Store Only')
                                           AND Pop_on_Case__c = 'Yes'
                                           ORDER BY Sort_Order__c ASC];   
        
        
        if(c.AccountId != null && c.Account.Name.containsIgnoreCase('office depot') && c.Owner_Is_Queue__c == false)
        {
            Client_Alert__c ca = new Client_Alert__c();
            ca.Account__c = c.AccountId;
            ca.Start_Date__c = date.today();
            ca.End_Date__c = date.today().addDays(1);
            ca.Message__c = 'As the case owner, you must now manually "Accept" the work order in FM Pilot.';
            ca.Status__c = 'Active';
            ca.Alert_Applies_to__c = 'Corporate Account and ALL its Stores';
            ca.Pop_on_Case__c = 'Yes';
            allAlerts.add(ca);
        }
        system.debug(allAlerts);
        return allAlerts;
    }
}