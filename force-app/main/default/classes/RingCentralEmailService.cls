@RestResource(urlMapping='/RingCentralEmailService')
global without sharing class RingCentralEmailService 
{
    private static Log logger = Log.get();

    @HttpGet
    global static void getLinkForWorkOrder() 
    {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        
        RestRequest req = RestContext.request;
        string requestBody = RestContext.request.requestBody != null ? RestContext.request.requestBody.toString() : '';
        system.debug(requestBody);
        requestBody = requestBody.replace('\\','').replace('\\','');
        system.debug(requestBody);
        Map<String, String> paramsMap = RestContext.request.params != null ? RestContext.request.params : new Map<string, string>();
        logger.add(requestBody, 'RingCentralEmailService');
        string response = '';
        
        if(paramsMap != null && paramsMap.containsKey('WorkOrderNumber')  && !string.isBlank(paramsMap.get('WorkOrderNumber')))
        {
            List<Case> cases = [SELECT Id,
                                CaseNumber
                                FROM Case
                                WHERE Customer_WO__c = :paramsMap.get('WorkOrderNumber')
                                ORDER BY CreatedDate DESC
                                LIMIT 1];
            if(!cases.isEmpty())
            {
                string link = URL.getOrgDomainUrl().toExternalForm() + '/' + cases[0].Id;
                response = '{"isSuccess":true,"reason":"Located matching Work Order Number", "link": "' + link + '","caseNumber": "' + cases[0].CaseNumber + '"}';
            }
            else
            {
                response = '{"isSuccess":false,"reason":"No matching workordernumber found"}';
            }
        }
        else   
        {
            response = '{"isSuccess":false,"reason":"No matching workordernumber found"}';
        }
        RestContext.response.responseBody = Blob.valueOf(response);
        logger.publish();
        return;
        
        /*         
        logger.publish(e);
        system.debug(e.getLineNumber() + ': ' + e.getMessage());
        system.debug(e.getStackTraceString());
        RestContext.response.statusCode = 500;
        string response = '{"isSuccess": false}';
        RestContext.response.responseBody = Blob.valueOf(response);
        
        logger.publish();
        return;
        */
    }

}