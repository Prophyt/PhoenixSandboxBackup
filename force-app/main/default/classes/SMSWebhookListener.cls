@RestResource(urlMapping='/SMSWebhook')
global class SMSWebhookListener 
{
    @HttpPost
    global static void handlePost()
    {
        try
        {    
            RestRequest request = RestContext.request;
            system.debug('<---request--->'+request);
            map<String,Object> head = request.headers;
            system.debug('<---request.headers--->' +head);
            system.debug('requestBody--->'+request.requestBody.toString());
            /*Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{'sowndarya.nittala@diligentforcelabs.com','indira.pasalapudi@diligentforcelabs.com'};
            semail.setToAddresses(sendingTo);
            semail.setSubject('SMS Webhook Json');
            semail.setPlainTextBody('SMS webhook');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});*/
            Integration_Message__c IntegrationMessage = new Integration_Message__c(
                Package__c=request.requestBody.toString(),
                Integration_Source__c='SMS Assist');
            insert IntegrationMessage;   
        }
        catch(exception e)
        {
            system.debug(e.getMessage());
            //apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));    
        }
    }
}