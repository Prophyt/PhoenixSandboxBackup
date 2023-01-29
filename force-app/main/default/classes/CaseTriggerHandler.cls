public without sharing class CaseTriggerHandler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public static Map<string, Group> groupNameMap 
    {
        get
        {
            if(groupNameMap == null)
            {
                groupNameMap = new Map<string, Group>();
                
                for(Group g : [SELECT Id,
                               Name 
                               FROM Group 
                               WHERE Type = 'Queue'])
                {
                    groupNameMap.put(g.Name, g);
                }
            }
            
            return groupNameMap;
        }
        set;
    }
    
    public static Map<string, MilestoneType> milestoneTypeMap
    {
        get
        {
            if(milestoneTypeMap == null)
            {
                milestoneTypeMap = new Map<string, MilestoneType>();
                for(MilestoneType mt : [SELECT Id,
                                        Name
                                        FROM MilestoneType])
                {
                    milestoneTypeMap.put(mt.Name, mt);
                }
            }
            
            return milestoneTypeMap;
        }
        set;
    }
    
    public static Map<string, Emergency_Keywords__mdt> emergencyKeywordMap
    {
        get
        {
            if(emergencyKeywordMap == null)
            {
                emergencyKeywordMap = new Map<string, Emergency_Keywords__mdt>();
                for(Emergency_Keywords__mdt e : [SELECT Id,
                                                 MasterLabel, 
                                                 Keyword__c,
                                                 Exclude__c
                                                 FROM Emergency_Keywords__mdt])
                {
                    emergencyKeywordMap.put(e.Keyword__c, e);
                }
            }
            return emergencyKeywordMap;
        }
        set;
    }

    public static Map<Id, Entitlement> entitlementMap
    {
        get
        {
            if(entitlementMap == null)
            {
             	entitlementMap = new Map<Id, Entitlement>();
                for(Entitlement e : [SELECT Id,
                                     Name,
                                     AccountId,
                                     Type,
                                     Status,
                                     StartDate,
                                     EndDate
                                     FROM Entitlement])
                {
                    entitlementMap.put(e.AccountId, e);
                }
            }
            
            return entitlementMap;
        }
        set;
    }
    
    public CaseTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Case[] triggerNew)
    {
        processBeforeInsertActions(triggerNew);
    }
    public void OnBeforeUpdate(Case[] triggerOld, Map<Id, Case> triggerOldMap, Case[] triggerNew, Map<ID, Case> triggerNewMap)
    {
        setIntegrationFields(triggerNew);
        processBeforeUpdateActions(triggerOldMap, triggerNewMap);
    }
    public void OnAfterInsert(Case[] triggerOld, Map<Id, Case> triggerOldMap, Case[] triggerNew, Map<Id, Case> triggerNewMap)
    {
        processIntegrationCallsAfterInsert(triggerNewMap);
        
    }
    public void OnAfterUpdate(Case[] triggerOld, Map<Id, Case> triggerOldMap, Case[] triggerNew, Map<ID, Case> triggerNewMap)
    {
        processIntegrationCallsAfterUpdate(triggerOldMap, triggerNewMap);
        processAfterUpdateActions(triggerOldMap, triggerNewMap);
        generateFollowupReminders(triggerOldMap, triggerNewMap);
    }
    public static void processBeforeInsertActions(List<Case> triggerNew)
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Case c : triggerNew)
        {
            if(c.AccountId != null && !accountIds.contains(c.AccountId))
                accountIds.add(c.AccountId);
            if(c.ContactId != null && !contactIds.contains(c.ContactId))
                contactIds.add(c.ContactId);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,
                                                           Name,
                                                           AccountId,
                                                           Account.Name,
                                                           Contact_Type__c
                                                           FROM Contact
                                                           WHERE Id IN :contactIds]);
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name,
                                                            ParentId,
                                                            Parent.Name 
                                                            FROM Account 
                                                            WHERE Id IN :accountIds]);
                
        for(Case c : triggerNew)
        {
            //Set Parent Account Values
            if(c.Parent_Account__c == null && c.AccountId != null && accountMap.containsKey(c.AccountId) && accountMap.get(c.AccountId).ParentId != null)
            {
                c.Parent_Account__c = accountMap.get(c.AccountId).ParentId;
                c.Parent_Account_Name__c = accountMap.get(c.AccountId).Parent.Name;
            }
            
            //API Created Case
            if(c.Integration_Message__c != null && c.AccountId != null && c.Parent_Account_Name__c != null && groupNameMap.containsKey(c.Parent_Account_Name__c))
            {
                c.OwnerId = groupNameMap.get(c.Parent_Account_Name__c).Id;
            }
           
            //emergency keywords
            for(string keyword : emergencyKeywordMap.keySet())
            {
                if((!string.isBlank(c.Subject) && c.Subject.containsIgnoreCase(keyword)) || (!string.isBlank(c.X3rd_Party_Priority__c) && c.X3rd_Party_Priority__c.containsIgnoreCase(keyword)))
                {
                    c.Priority = 'Emergency';
                }  
            }
            //handle VIP Contact
            if(c.ContactId != null && contactMap.containsKey(c.ContactId) && contactMap.get(c.ContactId).Contact_Type__c == 'Corporate VIP' && c.Priority != 'Emergency')
            {
                c.Priority = 'Emergency';
            }
            system.debug(c.Parent_Account__c + '*****');
            system.debug(c.EntitlementId + '****');
            system.debug(entitlementMap);
            system.debug(entitlementMap.containsKey(c.Parent_Account__c));
            //handle entitlement
            if(c.Parent_Account__c != null && c.EntitlementId == null && entitlementMap.containsKey(c.Parent_Account__c))
            {
                c.EntitlementId = entitlementMap.get(c.Parent_Account__c).Id;
            }
        }
    }
    public static void processBeforeUpdateActions(Map<Id, Case> triggerOldMap, Map<Id, Case> triggerNewMap)
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Case c : triggerNewMap.values())
        {
            if(c.AccountId != null && !accountIds.contains(c.AccountId))
                accountIds.add(c.AccountId);
            if(c.ContactId != null && !contactIds.contains(c.ContactId))
                contactIds.add(c.ContactId);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,
                                                           Name,
                                                           AccountId,
                                                           Account.Name,
                                                           Contact_Type__c
                                                           FROM Contact
                                                           WHERE Id IN :contactIds]);
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name,
                                                            ParentId,
                                                            Parent.Name 
                                                            FROM Account 
                                                            WHERE Id IN :accountIds]);
        
        for(Case c : triggerNewMap.values())
        {
            Case oldCase = triggerOldMap.get(c.Id);
            //handle comment stage update
            if(!string.isBlank(c.Case_Comment__c) && oldCase.Case_Comment__c != c.Case_Comment__c)
            {
                c.Stage__c = 'Reminder / Follow Up';
                c.Case_Comment__c = '';
            }
            //if reportback is true, or sent email count is changed
            if(c.No_Report_Back__c == true || oldCase.Sent_Email_Count__c != c.Sent_Email_Count__c)
            {
                c.Stage__c = 'Review / Escalation';
            }
            //update third party decision
            if(c.X3rd_Party_Updated__c == true || c.No_3rd_Party_Update_Dispatch_Not_Neede__c == true || c.Vendor_Relationship__c != null)
            {
                c.Stage__c = 'Case Status';
            }
            //handle subject changed
            if((oldCase.Subject != c.Subject && !string.isBlank(c.Subject)) || (oldCase.X3rd_Party_Priority__c != c.X3rd_Party_Priority__c && !string.isBlank(c.X3rd_Party_Priority__c)))
            {
                //emergency keywords
                for(string keyword : emergencyKeywordMap.keySet())
                {
                    if(c.Subject.containsIgnoreCase(keyword) || c.X3rd_Party_Priority__c.containsIgnoreCase(keyword))
                    {
                        c.Priority = 'Emergency';
                    }  
                }
            }
            //handle VIP Contact
            if(c.ContactId != null && contactMap.containsKey(c.ContactId) && contactMap.get(c.ContactId).Contact_Type__c == 'Corporate VIP' && c.Priority != 'Emergency')
            {
                c.Priority = 'Emergency';
            }
            //handle entitlement
            if(c.Parent_Account__c != null && c.EntitlementId == null && entitlementMap.containsKey(c.Parent_Account__c))
            {
                c.EntitlementId = entitlementMap.get(c.Parent_Account__c).Id;
            }
            if(oldCase.Escalate_To__c != c.Escalate_To__c && !string.isBlank(c.Escalate_To__c))
            {
                //emails still send in flow
                c.Stage__c = 'Update 3rd Party';
                c.Status = 'Escalated';
                c.IsEscalated = true;    
            }
            if(c.No_Review_Escalation__c == true)
            {
                c.Stage__c = 'Update 3rd Party';
            }
        }
    }
    public static void processAfterUpdateActions(Map<Id, Case> triggerOldMap, Map<Id, Case> triggerNewMap)
    {
        Set<Id> accountIds = new Set<Id>();
        for(Case c : triggerNewMap.values())
        {
            if(c.AccountId != null)
                accountIds.add(c.AccountId);
        }
                
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name,
                                                            OwnerId,
                                                            ParentId,
                                                            Parent.Name,
                                                            Parent.OwnerId
                                                            FROM Account 
                                                            WHERE Id IN :accountIds]);
                
        List<CaseMilestone> milestones = new List<CaseMilestone>();
        List<Task> tasksToInsert = new List<Task>();
        for(Case c : triggerNewMap.values())
        {
            Case oldCase = triggerOldMap.get(c.Id);
            
            //handle accept milestone
            if(oldCase.Status != 'Accepted' && c.Status == 'Accepted')
            {

                for(CaseMilestone cm : [SELECT Id,
                                        CaseId,
                                        IsCompleted,
                                        MilestoneTypeId,
                                        CompletionDate
                                        FROM CaseMilestone
                                        WHERE CaseId = :c.Id
                                        AND MilestoneType.Name IN ('Accept Emergency','Accept Non-Emergency')
                                        AND IsCompleted = FALSE])
                {
                    cm.CompletionDate = DateTime.now();
                    milestones.add(cm);
                }
            }
            
            //handle Resolution Note
            if(oldCase.Resolution_Note__c != c.Resolution_Note__c)
            {
                //the flow will still send emails since that is cleaner in flow
                //but this will handle the data create/update portion
                
                if(c.AccountId != null && accountMap.containsKey(c.AccountId))
                {
					string accountName = accountMap.get(c.AccountId).Name;
                    system.debug(accountName + ' | ' + c.Resolution__c);
                    if(accountName.containsIgnoreCase('petco') && c.Resolution__c == 'Dispatched to Vendor')
                    {
                        Task t = new Task();
                        t.ActivityDate = Date.today();
                        t.Description = c.Resolution_Note__c;
                        t.OwnerId = UserInfo.getUserId();
                        t.Status = 'Completed';
                        t.Subject = 'Resolution';
                        t.WhatId = c.Id;
                        tasksToInsert.add(t);
                    }
                }
            }
            
            //handle Comments
            if(oldCase.Case_Comment__c != c.Case_Comment__c && !string.isBlank(c.Case_Comment__c))
            {
                Task t = new Task();
                t.ActivityDate = Date.today();
                t.Description = c.Case_Comment__c;
                t.OwnerId = UserInfo.getUserId();
                t.Status = 'Completed';
                t.Subject = 'Findings / Notes';
                t.WhatId = c.Id;
                tasksToInsert.add(t);
            }
            
            system.debug(oldCase.Escalate_To__c + ' | ' + c.Escalate_To__c);
            //handle escalate to changes
            if(oldCase.Escalate_To__c != c.Escalate_To__c && !string.isBlank(c.Escalate_To__c))
            {
                //emails are still being sent in FLOW
                if(c.Escalate_To__c == 'Account Lead')
                {
                    Task t = new Task();
                    t.ActivityDate = Date.today();
                    t.Description = c.Escalation_Notes__c;
                    t.OwnerId = (accountMap.containsKey(c.AccountId) && accountMap.get(c.AccountId).Parent.OwnerId != null) ? accountMap.get(c.AccountId).Parent.OwnerId : UserInfo.getUserId();
                    t.Subject = '';
                    t.WhatId = c.Id;
                    t.Subject = 'ESCALATION: ' + c.Store_and_Subject_for_lookup__c.abbreviate(70);
                    tasksToInsert.add(t);
                }
                else if(c.Escalate_To__c == 'Tech Lead / Engineer')
                {
                    Task t = new Task();
                    t.ActivityDate = Date.today();
                    t.Description = c.Escalation_Notes__c;
                    t.OwnerId = groupNameMap.containsKey('Engineer') ? groupNameMap.get('Engineer').Id : UserInfo.getUserId();
                    t.Subject = 'ESCALATION: ' + c.Store_and_Subject_for_lookup__c.abbreviate(70);
                    t.WhatId = c.Id;
                    tasksToInsert.add(t);
                }
                else if(c.Escalate_To__c == 'Supervisor')
                {
                    Task t = new Task();
                    t.ActivityDate = Date.today();
                    t.Description = c.Escalation_Notes__c;
                    t.OwnerId = groupNameMap.containsKey('Supervisors') ? groupNameMap.get('Supervisors').Id : UserInfo.getUserId();
                    t.Subject = 'ESCALATION: ' + c.Store_and_Subject_for_lookup__c.abbreviate(70);
                    t.WhatId = c.Id;
                    tasksToInsert.add(t);
                }
            }
        }
        
        
        if(!milestones.isEmpty())
        {
            update milestones;            
        }
        if(!tasksToInsert.isEmpty())
        {
            insert tasksToInsert;
            for(Task t : tasksToInsert)
            {
                if(t.subject.contains('ESCALATION'))
                    generateTaskNotification(t);
            }
        }

    }
    public static void generateTaskNotification(Task t)
    {
        List<EmailTemplate> templates = [SELECT Id, 
                                         Body, 
                                         Subject 
                                         FROM EmailTemplate 
                                         WHERE DeveloperName = 'Task_Notification'];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templates[0].Id); //Required if using a template, optional otherwise. The ID of the template used to create the email.
        mail.setSaveAsActivity(false);
        //mail.setToAddresses(new list<string>{''});
        mail.setWhatId(t.id); // RecordID To perform merge field operation
        mail.setTargetObjectId(t.OwnerId); //Required if using a template, optional otherwise. The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data.
        mail.setBccSender(false); 
        mail.setUseSignature(false); 
        
        if(!Test.isRunningTest())
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    public static void generateFollowupReminders(Map<Id, Case> triggerOldMap, Map<Id, Case> triggerNewMap)
    {
        Map<string, Group> queueMap = new Map<string, Group>();
        for(Group g : [SELECT Id,Name FROM Group WHERE Type = 'Queue' ORDER BY Name ASC])
        {
            queueMap.put(g.Name, g);
        }
        Set<Id> accountIds = new Set<Id>();
        Set<Id> vendorRelationIds = new Set<Id>();
        for(Case c : triggerNewMap.values())
        {
            if(c.AccountId != null && !accountIds.contains(c.AccountId))
                accountIds.add(c.AccountId);
            
            if(c.Parent_Account__c != null && !accountIds.contains(c.Parent_Account__c))
                accountIds.add(c.Parent_Account__c);
            
            //vendors are also accounts..
            if(c.Vendor_Relationship__c != null && !vendorRelationIds.contains(c.Vendor_Relationship__c))
                vendorRelationIds.add(c.Vendor_Relationship__c);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name,
                                                            BillingStreet
                                                            FROM Account
                                                            WHERE Id IN :accountIds]);
        
        Map<Id, Vendor_Relationship__c> vendorMap = new Map<Id, Vendor_Relationship__c>([SELECT Id,
                                                                                         Vendor__c,
                                                                                         Vendor__r.Name
                                                                                         FROM Vendor_Relationship__c
                                                                                         WHERE Id IN :vendorRelationIds]);
        
        List<Task> existingTasks = [SELECT Id,
                                    WhatId,
                                    ActivityDate,
                                    Subject
                                    FROM Task
                                    WHERE WhatId IN :triggerNewMap.keySet()];
        
        Map<String, Task> existingTaskMap = new Map<string, Task>();
        for(Task t : existingTasks)
        {
            string hashMatch = t.WhatId + (t.ActivityDate != null ? string.valueOf(t.ActivityDate) : '') + t.Subject;
            existingTaskMap.put(hashMatch, t);
        }
        
        List<Case> casesToUpdate = new List<Case>();
        List<Task> tasksToInsert = new List<Task>();
        for(Case c : triggerNewMap.values())
        {
            Case oldCase = triggerOldMap.get(c.Id);
            if(c.Reminder_Date_Time__c == null)
                continue;
               
            DateTime reminderDate = c.Reminder_Date_Time__c;
            string hashMatch = c.Id + (reminderDate != null ? string.valueOf(reminderDate.date()) : '') + c.Subject;
            if(existingTaskMap.containsKey(hashMatch))
                continue;
            
            
            Task t = new Task();
            t.ActivityDate = reminderDate != null ? reminderDate.date() : date.today();
            t.Description = c.Reminder_Note__c;
            t.IsReminderSet = true;
            t.ReminderDateTime = c.Reminder_Date_Time__c;           
            if(c.Reminder_Date_Time__c != null && c.Reminder_Date_Time__c > DateTime.now())
                t.OwnerId = queueMap.get('Reminder Queue').Id;
            else
                t.OwnerId = accountMap.containsKey(c.Parent_Account__c) && queueMap.containsKey(accountMap.get(c.Parent_Account__c).Name) ? queueMap.get(accountMap.get(c.Parent_Account__c).Name).Id : UserInfo.getUserId();
            
            t.WhatId = c.Id;

            string taskSubject = 'Service Call: ' +
                c.CaseNumber + ' - ' +
                (accountMap.containsKey(c.AccountId) ? accountMap.get(c.AccountId).Name : '') + 
                ' ' + 
                (accountMap.containsKey(c.AccountId) ? accountMap.get(c.AccountId).BillingStreet : '') + 
                ' for ' +
                (vendorMap.containsKey(c.Vendor_Relationship__c) ? vendorMap.get(c.Vendor_Relationship__c).Vendor__r.Name : '');
            
            t.Subject = taskSubject;
            tasksToInsert.add(t);
            
            casesToUpdate.add(new Case(
            Id = c.Id,
            Stage__c = 'Report Back',
            Reminder_Date_Time__c = null,
            Reminder_Note__c = null));
        }
        
        if(!tasksToInsert.isEmpty())
            insert tasksToInsert;
        if(!casesToUpdate.isEmpty())
            update casesToUpdate;
    }
    public static void processIntegrationCallsAfterInsert(Map<Id, Case> triggerNewMap)
    {
        //all of this only runs on an insert call
        if(System.isFuture() || System.isBatch())
            return;
        
        for(Case c : triggerNewMap.values())
        {   
            //SMS ASSIST
            if(!string.isBlank(c.Customer_WO__c) && c.X3rd_Party_System__c == 'SMS Assist' && c.Status == 'New')
            {
                //if its a new Case, go accept it, or if the status is new and the WO # is changing go accept it)
                SMSAssistAPI.acceptWorkOrders(new List<string>{c.Customer_WO__c});
                //pull back the WorkOrder Additional Details or other data
                SMSAssistAPI.getWorkOrderDetails(c.Customer_WO__c);
            }
            else if(c.Customer_WO__c != null && c.X3rd_Party_System__c == 'SMS Assist' && !string.isBlank(c.Customer_WO__c) && c.Status == 'Accepted')
            {
                SMSAssistAPI.checkInWorkOrder(new List<string>{c.Customer_WO__c});
            }
            else if(c.IsClosed == true && c.Resolution__c != null && c.Resolution__c != '' && c.X3rd_Party_System__c == 'SMS Assist')
            {
                SMSAssistAPI.checkOutWorkOrder(new List<string>{c.Customer_WO__c});
            }
            else if(c.IsClosed == true || c.Status == 'Accepted' && (c.X3rd_Party_System__c == 'ServiceChannel' || c.X3rd_Party_System__c == 'Service Channel'))
            { 
                ServiceChannelAPI.updateWorkOrder(c.Id);
            }
        }
    }
    public static void processIntegrationCallsAfterUpdate(Map<Id, Case> triggerOldMap, Map<Id, Case> triggerNewMap)
    {
        if(System.isFuture() || System.isBatch())
            return;
                    
        for(Case c : triggerNewMap.values())
        {   
            //SMS ASSIST
            if(!string.isBlank(c.Customer_WO__c) && c.X3rd_Party_System__c == 'SMS Assist' && c.Status == 'New')
            {
                //if its a new Case, go accept it, or if the status is new and the WO # is changing go accept it
                if(triggerOldMap.containsKey(c.Id) && triggerOldMap.get(c.Id).Status != c.Status)
                    SMSAssistAPI.acceptWorkOrders(new List<string>{c.Customer_WO__c});
                
                SMSAssistAPI.getWorkOrderDetails(c.Customer_WO__c);
            }
            else if(!string.isBlank(c.Customer_WO__c) && c.X3rd_Party_System__c == 'SMS Assist' && c.Status == 'Accepted' && triggerOldMap.get(c.Id).Status != c.Status)
            {
                SMSAssistAPI.checkInWorkOrder(new List<string>{c.Customer_WO__c});
            }
            else if(c.IsClosed == true && !string.isBlank(c.Resolution__c) && c.X3rd_Party_System__c == 'SMS Assist' && triggerOldMap.get(c.Id).Status != c.Status)
            {
                SMSAssistAPI.checkOutWorkOrder(new List<string>{c.Customer_WO__c});
            }
            else if(c.IsClosed == true || c.Status == 'Accepted' && (c.X3rd_Party_System__c == 'ServiceChannel' || c.X3rd_Party_System__c == 'Service Channel') && triggerOldMap.get(c.Id).Status != c.Status)
            { 
                ServiceChannelAPI.updateWorkOrder(c.Id);
            }
        }
    }
    public static void setIntegrationFields(Case[] triggerNew)
    {
        Map<Id, Id> caseIdAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> caseIdIntegrationMsgIdMap = new Map<Id, Id>();
        for(Case c : triggerNew)
        {
            if(c.AccountId != null)
                caseIdAccountIdMap.put(c.Id, c.AccountId);
            
            if(c.Status == 'Accepted' && c.Has_Been_Accepted__c == false)
            {
                c.Has_Been_Accepted__c = true;
                c.Accepted_Date_Time__c = DateTime.now();                
            }

            if(c.Integration_Message__c != null && c.X3rd_Party_System__c == null)
            {
                caseIdIntegrationMsgIdMap.put(c.Id, c.Integration_Message__c);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,
                                                            Name 
                                                            FROM Account
                                                            WHERE Id IN :caseIdAccountIdMap.values()]);
        
        for(Case c : triggerNew)
        {
            if(caseIdAccountIdMap.containsKey(c.Id))
            {
                Account a = accountMap.containsKey(caseIdAccountIdMap.get(c.Id)) ? accountMap.get(caseIdAccountIdMap.get(c.Id)) : null;
                if(a != null && a.Name != null && a.Name.containsIgnoreCase('sephora'))
                    c.X3rd_Party_System__c = 'ServiceNow';
            }
        }
        
        
        if(caseIdIntegrationMsgIdMap.isEmpty())
            return;
        
        Map<Id, Integration_Message__c> integrationMessages = new Map<Id, Integration_Message__c>([SELECT Id,
                                                                                                   Integration_Source__c
                                                                                                   FROM Integration_Message__c
                                                                                                   WHERE Id IN :caseIdIntegrationMsgIdMap.values()]);
        
        
        if(integrationMessages.isEmpty())
            return;
        
        for(Case c : triggerNew)
        {
            if(caseIdIntegrationMsgIdMap.containsKey(c.Id) && integrationMessages.containsKey(caseIdIntegrationMsgIdMap.get(c.Id)))
            {
                Integration_Message__c msg = integrationMessages.get(caseIdIntegrationMsgIdMap.get(c.Id));
                c.X3rd_Party_System__c = msg.Integration_Source__c;
            }
        }
    }  
}