public without sharing class SMSAssistAPI 
{
    private static Log logger = Log.get();
    
    @future(callout=true)
    public static void getWorkOrderDetails(string workOrderNumber)
    {
        string baseUrl = IntegrationUtilities.getBaseUrl();
        string endpoint = baseUrl + '/api/v1.0/workorder/reactive/list?wo_num=' + workOrderNumber;
        HttpRequest req = IntegrationUtilities.requestBuilder('GET', endpoint, 'SMS Assist', '');
        Http http = new Http();
        HttpResponse res = http.send(req);
        system.debug(res.getBody());
        ReactiveWorkOrderList workOrders = ReactiveWorkOrderList.parse(res.getBody());
        system.debug(workOrders);
        List<Case> cases = [SELECT Id,
                            Subject,
                            Description
                            FROM Case
                            WHERE Customer_WO__c = :workOrderNumber
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1];
        
        for(Case c : cases)
        {
            if(workOrders != null && workOrders.totalItemsCount > 0)
            {
                string description = c.Description;
                if(!string.isBlank(description))
                    description = description.trim();
                string workOrderDetail = workOrders.Items[0].additional_detail;
                if(!string.isBlank(workOrderDetail))
                    workOrderDetail = workOrderDetail.trim();
                
                if(!string.isBlank(workOrders.Items[0].main_store_area))
                {
                    c.Main_Store_Area__c = workOrders.Items[0].main_store_area;
                }
                if(!string.isBlank(workOrders.Items[0].store_subarea))
                {
                    c.Store_Sub_Area__c = workOrders.Items[0].store_subarea;
                }
                
                if(workOrderDetail == null || string.isBlank(workOrderDetail) || (description != null && description.containsIgnoreCase(workOrderDetail)))
                {
                    system.debug('Not setting Additional SMS Assist Fields from SMSAssistAPI');
                    continue;   
                }
                else
                {
                    system.debug('Setting Additional SMS Assist Fields from SMSAssistAPI');
                    c.Description = 'Additional Detail:\r\n' + workOrderDetail + '\r\nOriginal Description:\r\n' + (c.Description != null ? c.Description : '');
                }
            }
        }
        update cases;
    }
    @InvocableMethod(label='CaseStatusAcceptAPI')
    public static List<String> CaseStatusAcceptAPI(List<String> workOrderNumbers)
    {
        acceptWorkOrders(workOrderNumbers);
        return null;
    }
    @future(callout=true)
    public static void acceptWorkOrders(List<string> workOrderNumbers)
    {
        //This method accepts a reactive work order in a PENDING VENDOR ACCEPTANCE status and assign a specific technician to the work order.
        //If a schedule window (schedule_start_time and schedule_end_time) is provided, the work order will move to a SCHEDULED status, otherwise a PENDING SCHEDULE status.
        //Field technician_id can be obtained from API /api/v1.0/employee/list
        //#TODO This needs to log errors..it doesnt
        List<Case> cases = [SELECT Id,
                            Customer_WO__c,
                            Integration_Message__c,
                            Status
                            FROM Case 
                            WHERE Customer_WO__c IN :workOrderNumbers
                            AND Customer_WO__c != null
                            AND Customer_WO__c != ''
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        
        List<Case> updateCaseList = new List<Case>();
        List<String> caseIds = new List<String>();
        
        if(!cases.isEmpty())
        {
            for(Case c : cases)
            {
                string requestBody = '{'+
                    '"wo_num": "' + c.Customer_WO__c +'",' +
                    '"schedule_start_time": "' + DateTime.now() + '",' +
                    '"schedule_end_time": "' + DateTime.now().addMinutes(60) + '",' +
                    '"technician_id": "210870"' +
                    '}';
                
                string baseUrl = IntegrationUtilities.getBaseUrl();
                String endpoint = baseUrl + '/api/v1.0/workorder/reactive/accept';
                HttpRequest req = IntegrationUtilities.requestBuilder('POST', endpoint, 'SMS Assist', requestBody);
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                res = http.send(req);
                
                string updateResponse = 'Accept API Response: ' + res.getBody();
                updateResponse = updateResponse.abbreviate(255);
                c.X3rd_Party_Update_Error__c = updateResponse;
                updateCaseList.add(c);
                System.debug('Response Status: ' + res.getStatusCode());
                system.debug('Response Body: ' + res.getBody());
            }
        }
        if(!updateCaseList.isEmpty())
        {
            update updateCaseList;
        }
    }
    @future(callout=true)
    public static void checkInWorkOrder(List<string> workOrderNumbers)
    {
        //This method updates reactive work order status from SCHEDULED or RESCHEDULED to ON SITE.
        List<Case> cases = [SELECT Id,
                            Customer_WO__c,
                            Integration_Message__c 
                            FROM Case 
                            WHERE Customer_WO__c IN :workOrderNumbers
                            AND Customer_WO__c != null
                            AND Customer_WO__c != ''
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        
        List<Case> updateCaseList = new List<Case>();
        List<String> caseIds = new List<String>();
        
        if(!cases.isEmpty())
        {
            for(Case c : cases)
            {
                string requestBody = '{'+
                    '"wo_num": "' + c.Customer_WO__c +'",' +
                    '"checkin_time": "' + DateTime.now() + '"' +
                    '}';
                
                string baseUrl = IntegrationUtilities.getBaseUrl();
                String endpoint = baseUrl + '/api/v1.0/workorder/reactive/check-in';
                HttpRequest req = IntegrationUtilities.requestBuilder('POST', endpoint, 'SMS Assist', requestBody);
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                res = http.send(req);
                
                string updateResponse = 'Check-In API Response: '+ res.getBody();
                updateResponse = updateResponse.abbreviate(255);
                c.X3rd_Party_Update_Error__c = updateResponse;
                updateCaseList.add(c);
                
                System.debug('Response Status: ' + res.getStatusCode());
                system.debug('Response Body: ' + res.getBody());
            }
        }
        if(!updateCaseList.isEmpty())
        {
            update updateCaseList;
        }
    }
    @future(callout=true)
    public static void checkOutWorkOrder(List<string> workOrderNumbers)
    {
        //This method updates reactive work order status from SCHEDULED or RESCHEDULED to ON SITE.
        List<Case> cases = [SELECT Id,
                            Status,
                            IsClosed,
                            Resolution__c,
                            Customer_WO__c,
                            Integration_Message__c 
                            FROM Case 
                            WHERE Customer_WO__c IN :workOrderNumbers
                            AND Customer_WO__c != null
                            AND Customer_WO__c != ''
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        
        List<Case> updateCaseList = new List<Case>();
        List<String> caseIds = new List<String>();
        
        if(!cases.isEmpty())
        {
            for(Case c : cases)
            {
                string checkoutStatus = getCheckoutStatus(c);
                system.debug('CheckoutStatus: ' + checkoutStatus);
                if(checkoutStatus == null)
                    continue;
                
                string requestBody = '{'+
                    '"wo_num": "' + c.Customer_WO__c +'",' +
                    '"checkout_status": "' + checkoutStatus + '",' +
                    '"checkout_time": "' + DateTime.now() + '"' +
                    '}';
                
                
                system.debug(requestBody);
                string baseUrl = IntegrationUtilities.getBaseUrl();
                String endpoint = baseUrl + '/api/v1.0/workorder/reactive/check-out';
                HttpRequest req = IntegrationUtilities.requestBuilder('POST', endpoint, 'SMS Assist', requestBody);
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                res = http.send(req);
                
                string updateResponse = 'Check-Out API Response: '+ res.getBody();
                updateResponse = updateResponse.abbreviate(255);
                c.X3rd_Party_Update_Error__c = updateResponse;
                updateCaseList.add(c);
                
                System.debug('Response Status: ' + res.getStatusCode());
                system.debug('Response Body: ' + res.getBody());
            }
        }
        if(!updateCaseList.isEmpty())
        {
            update updateCaseList;
        }
    }
    public static string getCheckoutStatus(Case c)
    {
        //1 = WORK COMPLETE PENDING VENDOR INVOICE
        //2 = RETURN TRIP NEEDED
        //3 = PENDING VENDOR QUOTE
        //4 = RESOLVED WITHOUT INVOICE
        //5 = CANCELLED, available affiliates: Phoenix Energy Technologies, Inc. (DE), Motili, Inc. (DE)        
        if(c == null || c.Status == null || c.Status == '')
            return null;
        
        if(c.Resolution__c != null && c.Resolution__c == 'Dispatched to Vendor' && c.IsClosed == true)
            return '5';
        else if(c.Resolution__c != null && c.Resolution__c != '' && c.Resolution__c != 'Dispatched to Vendor' && c.IsClosed == true)
            return '4';
        else
            return null;
    }
    public static string getDefaultAccountId()
    {
        //default customer ID needs handled better
        Customer_Settings__mdt settings = [SELECT AccountId_Customer__c 
                                           FROM Customer_Settings__mdt 
                                           WHERE DeveloperName = 'PhoenixET_ServiceChannel'];
		
        String accId = settings.AccountId_Customer__c;
        return accId;
    }
}