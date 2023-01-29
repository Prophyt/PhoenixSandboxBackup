public without sharing class SMSAssistWorkOrderQueueable implements Queueable,Database.AllowsCallouts
{
    
	private static Log logger = Log.get();
    public string finalEndpoint {get;set;}
    public SMSAssistWorkOrderQueueable(string endPoint)
    {
        if(string.isBlank(endPoint))
        {
            DateTime dt = DateTime.now().addHours(-6);
            String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'GMT');
            //https://meshlive.smsassist.com/api/v1.0/workorder/reactive/list?call_time_after=<dt>
            endPoint = IntegrationUtilities.getBaseUrl() + '/api/v1.0/workorder/reactive/list?call_time_after=' + formattedDt;
            this.finalEndpoint = endPoint;
        }
        else
        {
            this.finalEndpoint = endPoint;
        }
    }
    public void execute(QueueableContext QC)
    {
        Integer allowedJobs = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();
        if(allowedJobs <= 0) 
           return;
        
        processAPIResults(finalEndpoint);
    }
    public static void processAPIResults(string endpoint)
    {
        system.debug('Starting SMS Assist Work Order API in SMSAssistWorkOrderQueueable');
        Http h = new Http();
        HttpRequest req = IntegrationUtilities.requestBuilder('GET', endpoint, 'SMS Assist', '');
        try 
        {
            
            /*
            DateTime lastCall = system.now();
            //if we need to add throttling
            DateTime waitPeriod = lastCall.addSeconds(3);
            while(system.now() < waitPeriod)
            {
                //waiting waiting
            }
            */
            
            HttpResponse res = h.send(req);
            system.debug('STATUS CODE: ' + res.getStatusCode());
            system.debug(res.getBody());
            if(res.getStatusCode() != 200)
            {
                system.debug('Recieved ' + res.getStatusCode() + ' Status Code. Trying again with a delay.');
                system.enqueueJob(new SMSAssistWorkOrderQueueable(endpoint));   
            }
            else
            {
                
                //# Create Work Order response parser
                //Parse Work Orders coming back in a collection
                ReactiveWorkOrderList workOrders = ReactiveWorkOrderList.parse(res.getBody());
                
                //lots of ways to store everything so we can reference it in a big pile
                List<Case> casesToUpsert = new List<Case>();
                Set<string> workOrderNumbers = new Set<string>();
                Set<string> workOrderNumbersToSkip = new Set<string>(); //duplicate prevention list since WorkOrders are auto created upon closing one out
                Map<string, ReactiveWorkOrderList.Items> workOrderMap = new Map<string, ReactiveWorkOrderList.Items>();
                Map<string, Case> workOrderCaseMap = new Map<string, Case>();
                Map<string, Account> locationAccountMap = new Map<string, Account>();
                Map<string, List<ReactiveWorkOrderList.Items>> locationWorkOrderMap = new Map<string, List<ReactiveWorkOrderList.Items>>();
                
                string defaultAccountId = SMSAssistAPI.getDefaultAccountId();
                
                for(ReactiveWorkOrderList.Items item : workOrders.items)
                {
                    if(!string.isBlank(item.wo_num))
                    {
                        workOrderNumbers.add(item.wo_num);
                        workOrderMap.put(item.wo_num, item);                        
                    }

                    if(!string.isblank(item.location_num))
                    {
                        if(locationWorkOrderMap.containsKey(item.location_num))
                        {
                            List<ReactiveWorkOrderList.Items> woItems = locationWorkOrderMap.get(item.location_num);
                            woItems.add(item);
                            locationWorkOrderMap.put(item.location_num, woItems);
                        }
                        else
                        {
                            List<ReactiveWorkOrderList.Items> woItems = new List<ReactiveWorkOrderList.Items>();
                            woItems.add(item);
                            locationWorkOrderMap.put(item.location_num, woItems);                       
                        }
                    }
                }
                
                for(Account a : [SELECT Id,
                                 Third_Party_FM_Id__c
                                 FROM Account 
                                 WHERE Third_Party_FM_Id__c IN :locationWorkOrderMap.keySet()
                                 AND Third_Party_FM_Id__c != null
                                 AND Third_Party_FM_Id__c != ''])
                {
                    if(a.Third_Party_FM_Id__c != null && a.Third_Party_FM_Id__c != '')
                        locationAccountMap.put(a.Third_Party_FM_Id__c, a);
                }
                
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
                                            IsClosed
                                            FROM Case
                                            WHERE LastModifiedDate >= :fiveMinutesAgo
                                            AND AccountId != null
                                            AND Account.Third_Party_FM_Id__c IN :locationWorkOrderMap.keySet()
                                            AND Account.Third_Party_FM_Id__c != null
                                            AND Customer_WO__c != null
                                            AND X3rd_Party_System__c = 'SMS Assist'];
                
                system.debug('found ' + existingCases.size() + ' existing potential cases');
                for(Case c : existingCases)
                {
                    //create a string of ServiceCategory,IssueType,Priority,LocationId
                    //compare it to the same string from the existing case fields
                    //and if it was within the last 5 minutes, and the case is closed
                    //its a duplicate
                    
                    //do a duplicate check here
                    if(c.isClosed == true && !string.isBlank(c.Customer_WO__c) && locationWorkOrderMap.containsKey(c.Account.Third_Party_FM_Id__c))
                    {
                        system.debug('checking for comparison match');
                        string comparison = '';
                        comparison += c.X3rd_Party_Problem__c + '|';
                        comparison += c.X3rd_Party_Issue_Type__c + '|';
                        comparison += c.X3rd_Party_Priority__c + '|';
                        comparison += c.Account.Third_Party_FM_Id__c;
                        system.debug(comparison.toLowerCase());
                        List<ReactiveWorkOrderList.Items> woItems = locationWorkOrderMap.get(c.Account.Third_Party_FM_Id__c);
                        for(ReactiveWorkOrderList.Items item : woItems)
                        {
                            string woComparison = '';
                            woComparison += item.service_category + '|';
                            woComparison += item.service_type + '|';
                            woComparison += item.priority_name + '|';
                            woComparison += item.location_num;
                            
                            system.debug(woComparison.toLowerCase());
                            if(comparison.toLowerCase() == woComparison.toLowerCase())
                                workOrderNumbersToSkip.add(item.wo_num);
                        }
                    }
                    workOrderCaseMap.put(c.Customer_WO__c, c);
                }
                
                for(ReactiveWorkOrderList.Items item : workOrders.items)
                {
                    //pass in the work order, the potential list of accounts, and the default in case one doesnt match,
                    //after removing cases that already exist by Work Order Number
                    //and removing cases that appear to be the same issue (this handles the close = create new work order issue)
                    if(!workOrderCaseMap.containsKey(item.wo_num) && !workOrderNumbersToSkip.contains(item.wo_num))
                        casesToUpsert.add(ReactiveWorkOrderList.convertWorkOrderToCase(item, locationAccountMap, defaultAccountId));
                }
                
                system.debug(casesToUpsert.size() + ' Cases identified to upsert for SMS Assist.  ' + workOrderNumbersToSkip.size() + ' items being skipped for duplicate prevention:');
                system.debug(workOrderNumbersToSkip);
                
                if(!casesToUpsert.isEmpty())
                {
                    Schema.SObjectField keyField = Case.Fields.Customer_WO__c;
                    Database.UpsertResult[] results = Database.upsert(casesToUpsert, keyField, false);
                    for(Database.UpsertResult sr : results)
                    {
                        if(!sr.isSuccess())
                        {
                            for(Database.Error err : sr.getErrors())
                            {
                                system.debug(err);
                                logger.publish(err.getMessage(), 'SMSAssistWorkOrderQueueable', LogSeverity.ERROR);
                            }
                        }
                    }
                }
            }
        }
        catch (exception e) 
        {
            System.debug('ERROR: ' + e.getLineNumber() + ': ' + e.getMessage());
            logger.publish(e.getLineNumber() + ': ' + e.getMessage(), 'SMSAssistWorkOrderQueueable', LogSeverity.ERROR);
        }
    }
}