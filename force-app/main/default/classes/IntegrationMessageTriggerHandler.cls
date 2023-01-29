public without sharing class IntegrationMessageTriggerHandler
{
    private static Log logger = Log.get();
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public IntegrationMessageTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Integration_Message__c[] triggerNew)
    {
        
    }
    public void OnBeforeUpdate(Integration_Message__c[] triggerOld, Map<Id, Integration_Message__c> triggerOldMap, Integration_Message__c[] triggerNew, Map<ID, Integration_Message__c> triggerNewMap)
    {
        
    }
    public void OnAfterInsert(Integration_Message__c[] triggerOld, Map<Id, Integration_Message__c> triggerOldMap, Integration_Message__c[] triggerNew, Map<Id, Integration_Message__c> triggerNewMap)
    {
        for(Integration_Message__c m : triggerNew)
        {
            if(m.Integration_Source__c == 'ServiceChannel')
            {
                processServiceChannelMessage(m);
            }
            else if(m.Integration_Source__c == 'SMS Assist')
            {
                processSMSAssistMessage(m);
            }
            else if(m.Integration_Source__c == 'CorrigoPro')
            {
                processCorrigoProMessage(m);
            }
        }
    }
    public void OnAfterUpdate(Integration_Message__c[] triggerOld, Map<Id, Integration_Message__c> triggerOldMap, Integration_Message__c[] triggerNew, Map<ID, Integration_Message__c> triggerNewMap)
    {
        for(Integration_Message__c m : triggerNew)
        {
            if(m.Integration_Source__c == 'ServiceChannel')
            {
                processServiceChannelMessage(m);
            }
            else if(m.Integration_Source__c == 'SMS Assist')
            {
                processSMSAssistMessage(m);
            }
            else if(m.Integration_Source__c == 'CorrigoPro')
            {
                processCorrigoProMessage(m);
            }
        }
    }
    public static void processSMSAssistMessage(Integration_Message__c m)
    {
        string packageData = m.Package__c;
        
        //this is weird, not my code
        Customer_Settings__mdt settings = [SELECT AccountId_Customer__c 
                                           FROM Customer_Settings__mdt 
                                           WHERE DeveloperName = 'PhoenixET_ServiceChannel'];
        
        String accId = settings.AccountId_Customer__c;
        packageData = m.Package__c;
        Map<String, Object> WebhookDataMap = (Map<String, Object>)JSON.deserializeUntyped(packageData);
        System.debug('WO Status==' + WebhookDataMap.get('AfterStatus'));
        string woNumber = String.valueOf(WebhookDataMap.get('WorkOrderNumber'));
        
        List<Case> casesList = [SELECT Id,
                                AccountId,
                                Account.Third_Party_FM_Id__c,
                                Customer_WO__c,
                                IsClosed,
                                Status,
                                Origin,
                                X3rd_Party_Priority__c,
                                X3rd_Party_Issue_Type__c,
                                X3rd_Party_WO_Id__c,
                                Integration_Message__c,
                                X3rd_Party_Problem__c,
                                Subject,
                                Description
                                FROM Case 
                                WHERE Customer_WO__c = :woNumber];
        
        String locationId = String.valueof(WebhookDataMap.get('LocationId'));
        system.debug('LocationID--------'+locationID);
        List<Account> accCaseLookUpList = [SELECT Id
                                           FROM Account 
                                           WHERE Third_Party_FM_Id__c = :locationId];
        
        
        String customerWOId = WebhookDataMap.get('WorkOrderNumber').toString();
        String thirdPartyId = WebhookDataMap.get('WoId').toString();
        String priority = WebhookDataMap.containsKey('Priority') ? WebhookDataMap.get('Priority').toString() : '';
        String issueType = WebhookDataMap.containsKey('TradeName') ? WebhookDataMap.get('TradeName').toString() : '';
        String serviceCategory = WebhookDataMap.containsKey('ServiceCategory') ? WebhookDataMap.get('ServiceCategory').toString() : '';
        
        if(!casesList.IsEmpty())
        {
            for(Case c : casesList)
            {
                if(c.Status == 'New')
                {
                    
                    c.Customer_WO__c = customerWOId;
                    c.X3rd_Party_WO_Id__c = ThirdPartyId;
                    c.Origin = 'Third Party';
                    if(!accCaseLookUpList.isEmpty())
                    {
                        c.AccountId = accCaseLookUpList[0].Id;
                    }
                    else
                    {
                        c.AccountId = accId;
                    }
                    
                    c.Integration_Message__c = m.Id;
                    c.X3rd_Party_Priority__c =  !string.isBlank(priority) ? priority : c.X3rd_Party_Priority__c;
                    c.X3rd_Party_Issue_Type__c =  !string.isBlank(issueType) ? issueType : c.X3rd_Party_Issue_Type__c;
                    c.X3rd_Party_Problem__c =  !string.isBlank(serviceCategory) ? serviceCategory : c.x3rd_Party_Problem__c;
                    
                    if(WebhookDataMap.containsKey('ProblemDescription'))
                    { 
                        c.Subject = WebhookDataMap.containsKey('ProblemDescription') ? WebhookDataMap.get('ProblemDescription').toString() : c.Subject; 
                    }
                    else
                    { 
                        c.Subject = WebhookDataMap.containsKey('TradeName') ? WebhookDataMap.get('TradeName').toString() : c.Subject;
                    }
                    if(WebhookDataMap.containsKey('AdditionalDetail'))
                    {
                        c.Description = string.valueOf(WebhookDataMap.get('AdditionalDetail'));
                    }
                    
                }
                /*
				else if(c.IsClosed == false && WebhookDataMap.get('AfterStatus') == 'On Site')
                {
                //Per Farrah - 11.23.21 DO NOTHING when On Site - we are done
                //c.Status = 'Cancelled';
                }
                */
            }
            update casesList;
        }
        else
        {
            //duplicate prevention per Farrah 11/23/2021 - if we find an existing case
            //from the same location, for the same issue type
            //that was closed in the last 5 minutes
            //prevent this new WO from creating a case because its a duplicate due to how the
            //webhooks and cancelling a WO creates a new WO in SMS Assist works.
            
            DateTime fiveMinutesAgo = DateTime.now().addMinutes(-5);
            List<Case> existingCases = [SELECT Id,
                                        Status,
                                        CaseNumber,
                                        Customer_WO__c,
                                        X3rd_Party_System__c,
                                        X3rd_Party_Problem__c,
                                        X3rd_Party_Priority__c,
                                        X3rd_Party_Issue_Type__c,
                                        AccountId,
                                        Account.Third_Party_FM_Id__c,
                                        Subject,
                                        CreatedDate,
                                        LastModifiedDate,
                                        Description
                                        FROM Case
                                        WHERE LastModifiedDate >= :fiveMinutesAgo
                                        AND Customer_WO__c != null
                                        AND IsClosed = true
                                        AND X3rd_Party_System__c = 'SMS Assist'
                                        AND X3rd_Party_Problem__c = :serviceCategory
                                        AND X3rd_Party_Issue_Type__c = :issueType
                                        AND X3rd_Party_Priority__c = :priority
                                        AND AccountId != null
                                        AND Account.Third_Party_FM_Id__c = :locationId
                                        AND Account.Third_Party_FM_Id__c != null];
            
            if(!existingCases.isEmpty())
            {
                sendWarningEmail(m);
                return;                
            }
            
            
            
            Case c = new Case();
            c.Customer_WO__c = customerWOId;
            c.X3rd_Party_WO_Id__c = thirdPartyId;
            c.Origin = 'Third Party';
            
            if(!accCaseLookUpList.isEmpty())
            {
                c.AccountId = accCaseLookUpList[0].Id;
            }
            else
            {
                c.AccountId = accId;
            }
            
            c.Integration_Message__c = m.Id;
            c.X3rd_Party_Priority__c = !string.isBlank(priority) ? priority : c.X3rd_Party_Priority__c;
            c.X3rd_Party_Issue_Type__c = !string.isBlank(issueType) ? issueType : c.X3rd_Party_Issue_Type__c;
            c.X3rd_Party_Problem__c = !string.isBlank(serviceCategory) ? serviceCategory : null;
            c.X3rd_Party_System__c = 'SMS Assist';
            
            if(WebhookDataMap.containsKey('ProblemDescription'))
            { 
                c.Subject = WebhookDataMap.containsKey('ProblemDescription') ? WebhookDataMap.get('ProblemDescription').toString() : c.Subject; 
            }
            else
            { 
                c.Subject = WebhookDataMap.containsKey('TradeName') ? WebhookDataMap.get('TradeName').toString() : c.Subject;
            }
            if(WebhookDataMap.containsKey('AdditionalDetail'))
            {
                c.Description = string.valueOf(WebhookDataMap.get('AdditionalDetail'));
            }
            
            insert c;
        }
    }
    public static void processServiceChannelMessage(Integration_Message__c m)
    {
        logger.publish(m.package__c, 'IntegrationMessageTriggerHandler', LogSeverity.INFO);
        ServiceChannelPayload s = ServiceChannelPayload.parse(m.Package__c);
        ServiceChannelPayload.Object_Z payload = s.Object_Z;
        
        system.debug(payload);
        
        Customer_Settings__mdt settings = [SELECT AccountId_Customer__c 
                                           FROM Customer_Settings__mdt 
                                           WHERE DeveloperName = 'PhoenixET_ServiceChannel'];
        
        String accId = settings.AccountId_Customer__c;        
        String customerWOId = payload.Number_Z != null ? string.valueOf(payload.Number_Z) : '';
        String thirdPartyId = payload.Id != null ? string.valueOf(payload.Id) : '';
        String subscriberId = payload.SubscriberId != null ? string.valueOf(payload.SubscriberId) : '';
        String locationId = payload.LocationStoreId;
        if(locationId == null || string.isEmpty(locationId))
            locationId = payload.LocationId != null ? string.valueOf(payload.LocationId) : '';
        
        String action = payload.Action != null ? payload.Action : '';
        String trade = payload.Trade != null ? payload.Trade : '';
        String priority = payload.Priority != null ? payload.Priority : '';
        String problem = payload.Category != null ? Payload.Category : '';
		String problemCode = payload.ProblemCode != null ? payload.ProblemCode : '';
        String description = payload.Description != null ? payload.Description : '';
        String category =  payload.Category != null ? payload.Category : '';
        String area = '';
        
		if(payload.IssueTicketInfo != null && payload.IssueTicketInfo.AreaName != null)
        {
            area = payload.IssueTicketInfo.AreaName;
        }
        if(string.isBlank(area) && !string.isBlank(description) && description.contains('/'))
        {
            area = description.substringBefore('/');
        }
        if(!string.isBlank(area) && area.length() >= 255)
            area = area.abbreviate(255);
        
        
        if(!string.isBlank(action))
            action = action.toUpperCase();
        
        string dtTime = payload.ScheduledDate;
        String rplDtTime = !string.isBlank(dtTime) ? dtTime.replace('T',' ') : '';
        Datetime dtTimeFieldValue = !string.isBlank(rplDtTime) ? Datetime.valueOf(rplDtTime) : DateTime.now();
        
        
        string tempLocationID = locationID + '%';
        List<Account> accountList = [SELECT Id
                                     FROM Account 
                                     WHERE Third_Party_FM_Id__c LIKE :tempLocationID 
                                     AND Third_Party_FM_ID__c != null
                                     AND Parent.Third_Party_FM_Id__c = :subscriberID];
        
        system.debug('Found ' + accountList.size() + ' Location Accounts by LocationId ' + locationId);
        
        List<Account> parentAccountList = [SELECT Id 
                                           FROM Account 
                                           WHERE Third_Party_FM_Id__c = :subscriberID];
        
        system.debug('Found ' + parentAccountList.size() + ' Parent Accounts by Subscriber ID : ' + subscriberID);
        
        List<Case> existingCases = [SELECT Id,
                                    AccountId,
                                    Parent_Account__c,
                                    Priority,
                                    Issue_Type__c,
                                    Scheduled_New__c,
                                    Subject,
                                    Customer_WO__c,
                                    Description,
                                    CaseNumber,
                                    X3rd_Party_System__c,
                                    X3rd_Party_WO_Id__c,
                                    Integration_Message__c,
                                    X3rd_Party_Priority__c,
                                    X3rd_Party_Problem__c,
                                    X3rd_Party_Issue_Type__c,
                                    X3rd_Party_Area__c,
                                    Origin
                                    FROM Case 
                                    WHERE CreatedDate >= LAST_QUARTER
                                    AND X3rd_Party_WO_Id__c != null
                                    AND X3rd_Party_WO_Id__c != ''
                                    AND X3rd_Party_WO_Id__c = :thirdPartyId];
        
        
        
        List<Case> petcoCases = [SELECT Id,
                                 AccountId,
                                 Priority,
                                 Issue_Type__c,
                                 Scheduled_New__c,
                                 Subject,
                                 Customer_WO__c,
                                 Description,
                                 CaseNumber,
                                 X3rd_Party_System__c,
                                 X3rd_Party_WO_Id__c,
                                 Integration_Message__c,
                                 X3rd_Party_Priority__c,
                                 X3rd_Party_Problem__c,
                                 X3rd_Party_Issue_Type__c,
                                 X3rd_Party_Area__c
                                 FROM Case
                                 WHERE Customer_WO__c != null
                                 AND Customer_WO__c = :customerWOId
                                 AND (Account.Name like 'Petco%' OR Parent_Account__r.Name = 'Petco')
                                 ORDER BY CreatedDate DESC LIMIT 1];
        
        
        //special petco handling
        //reps create cases manually, then go into ServiceChannel and spin up a corresponding ServiceChannel Item
        //The API sends it in, and creates a duplicate. This stops that from happening, and populates the values into
        //the existing manually created case instead.
        
        Case cs = new Case();
        if(!petcoCases.isEmpty())
        {
            //update petco case logic only
            Case existingPetcoCase = petcoCases[0];
            cs.Id = petcoCases[0].Id;
            cs.X3rd_Party_System__c = 'ServiceChannel';
            cs.X3rd_Party_Issue_Type__c = !string.isBlank(trade) && existingPetcoCase.X3rd_Party_Issue_Type__c != trade ? trade : existingPetcoCase.X3rd_Party_Issue_Type__c;
            cs.X3rd_Party_Priority__c = !string.isBlank(priority) && existingPetcoCase.X3rd_Party_Priority__c != priority ? trade : existingPetcoCase.X3rd_Party_Priority__c;
            cs.X3rd_Party_Problem__c = !string.isBlank(problem) && existingPetcoCase.X3rd_Party_Problem__c != problem ? problem : existingPetcoCase.X3rd_Party_Problem__c;
            cs.X3rd_Party_WO_Id__c = thirdPartyId;
            cs.X3rd_Party_Area__c = area;
            cs.Integration_Message__c = m.Id;
        }
        else if(!existingCases.isEmpty())
        {
            //update existing non-petco case
            cs = existingCases[0];
            cs.Id = existingCases[0].Id;
            cs.Integration_Message__c = m.Id;            
            cs.Origin = 'Third Party';
            cs.X3rd_Party_System__c = 'ServiceChannel';
            
            if(!accountList.isEmpty() && cs.AccountId == null)
                cs.AccountId = accountList[0].Id;
            
            if(!parentAccountList.isEmpty() && parentAccountList[0].Id != cs.Parent_Account__c)
                cs.Parent_Account__c = parentAccountList[0].Id;
            
            cs.X3rd_Party_Priority__c = !string.isBlank(priority) ? priority : cs.X3rd_Party_Priority__c;
            cs.X3rd_Party_Issue_Type__c = !string.isBlank(trade) ? trade : cs.X3rd_Party_Issue_Type__c;
            cs.Scheduled_New__c = dtTimeFieldValue != null && dtTimeFieldValue != cs.Scheduled_New__c ? dtTimeFieldValue : cs.Scheduled_New__c; 
            cs.Customer_WO__c = !string.isBlank(customerWOId) && customerWOId != cs.Customer_WO__c ? customerWOId : cs.Customer_WO__c;
            cs.X3rd_Party_WO_Id__c = !string.isBlank(thirdPartyId) && thirdPartyId != cs.X3rd_Party_WO_Id__c ? thirdPartyId : cs.X3rd_Party_WO_Id__c;
            cs.Subject = cs.Subject != null && !string.isBlank(cs.Subject) && !string.isBlank(problemCode) && cs.Subject != problemCode ? problemCode : !string.isBlank(trade) && cs.Subject != trade ? trade : 'ServiceChannel Case';
            cs.Description = !string.isBlank(description) && cs.Description != description ? description : cs.Description;
            cs.X3rd_Party_Problem__c = !string.isBlank(category) && cs.X3rd_Party_Problem__c != category ? category : cs.X3rd_Party_Problem__c;
            cs.X3rd_Party_Area__c = !string.isBlank(area) && cs.X3rd_Party_Area__c != area ? area : cs.X3rd_Party_Area__c;
        }
        else
        {
            //create a new case
            cs.Integration_Message__c = m.Id;
            cs.Origin = 'Third Party';
            cs.X3rd_Party_System__c = 'ServiceChannel';
            cs.AccountId = !accountList.isEmpty() ? accountList[0].Id : accId;
            cs.Parent_Account__c = !parentAccountList.isEmpty() ? parentAccountList[0].Id : accId;
            cs.X3rd_Party_Priority__c = !string.isBlank(priority) ? priority : null;
            cs.X3rd_Party_Issue_Type__c = !string.isBlank(trade) ? trade : null;
            cs.Scheduled_New__c = dtTimeFieldValue != null ? dtTimeFieldValue : null; 
            cs.Customer_WO__c = !string.isBlank(customerWOId) ? customerWOId : null;
            cs.X3rd_Party_WO_Id__c = !string.isBlank(thirdPartyId) ? thirdPartyId : null;
            cs.Subject = !string.isBlank(problemCode) ? problemCode : !string.isBlank(trade) ? trade : 'ServiceChannel Case';            
			cs.Description = !string.isBlank(description) ? description : null;    
            cs.X3rd_Party_Problem__c = !string.isBlank(category) ? category : null;            
            cs.X3rd_Party_Area__c = !string.isBlank(area) ? area : null;
        }

        Database.UpsertResult sr = database.upsert(cs, false);
        string errors = '';
        if(!sr.isSuccess())
        {
            for(Database.Error e : sr.getErrors())
            {
                system.debug(e);
                errors += e.getMessage() + '\r\n';
            }
        }
        
        if(!string.isBlank(errors))
            logger.publish(errors, 'IntegrationMessageTriggerHandler', LogSeverity.ERROR);
    }
    public static void processCorrigoProMessage(Integration_Message__c m)
    {
        if(m.Header__c != null && !string.isBlank(m.Header__c))
        {
            string header = m.Header__c;
            Set<string> caseUpdateTypes = new Set<string>();
            caseUpdateTypes.add('putonhold');
            caseUpdateTypes.add('accepted');
            caseUpdateTypes.add('rejected');
            caseUpdateTypes.add('recalled');
            caseUpdateTypes.add('reopened');
            caseUpdateTypes.add('closed');
            caseUpdateTypes.add('resolved');
            caseUpdateTypes.add('completed');            
            caseUpdateTypes.add('checkedout');
            
            if(header.toLowerCase() == 'newworkorder')
            {
                Case c = CorrigoProWorkOrder.createCaseFromWorkOrder(m);
            }
            else if(header.toLowerCase() == 'internalnotechanged')
            {
                CaseComment cc = CorrigoProEvent.createCaseCommentFromNote(m);
            }
            else if(caseUpdateTypes.contains(header.toLowerCase()))
            {
                Case c = CorrigoProEvent.updateCaseStatus(m);
            }
        }

    }
    public static void sendWarningEmail(Integration_Message__c m)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('brad@nexuscloudconsulting.com');
        sendTo.add('fgreig@phoenixet.com');
        mail.setToAddresses(sendTo);
        mail.setReplyTo('SFSMSAssistAPI@phoenixet.com');
        mail.setSenderDisplayName('Salesforce SMS Assist API');
        mail.setSubject('SMS Assist - Potential Duplicate Case Blocked');
        String body = 'Please see below for payload that was blocked\r\n\r\n'  + m.Name + ':\r\n';
        body += m.Package__c;
        mail.setHtmlBody(body);
        mails.add(mail);
        if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
    }
}