@RestResource(urlMapping='/CorrigoPro/webhook')
//http://<site url>/webhook/services/apexrest/CorrigoPro/webhook
global without sharing class CorrigoProWebhook
{
    private static Log logger = Log.get();
    @HttpPost
    global static void receiveMessage() 
    {    
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        Savepoint fullRollbackSP = Database.setSavepoint();
        try
        {
            RestRequest req = RestContext.request;
            string requestBody = RestContext.request.requestBody != null ? RestContext.request.requestBody.toString() : '';
            system.debug(requestBody);
            Map<String, String> paramsMap = RestContext.request.params != null ? RestContext.request.params : new Map<string, string>();
            Map<string, string> headerMap = RestContext.request.headers != null ? RestContext.request.headers : new Map<string, string>();
            
            string eventType = '';
            if(headerMap.containsKey('Event-Type'))
            {
                eventType = headerMap.get('Event-Type');
            }
            logger.add(requestBody, 'CorrigoProWebhook' + (!string.isBlank(eventType) ? '_' + eventType : ''));

            Integration_Message__c im = new Integration_Message__c();
            im.Integration_Source__c = 'CorrigoPro';
            im.Header__c = eventType;
            im.Package__c = requestBody;
            im.OwnerId = [SELECT Id FROM User WHERE FirstName = 'Farrah' AND IsActive = TRUE LIMIT 1].Id;
            insert im;

            RestContext.response.responseBody = blob.valueOf('{"success":true}');

            logger.publish();
            return;
        }
        catch(Exception e)
        {
            logger.publish(e);
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            Database.rollback(fullRollbackSP);
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = blob.valueOf('{"error":"an error occurred"}');
        }

        logger.publish();
        return;
    }
}