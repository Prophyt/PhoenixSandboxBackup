@RestResource(urlMapping='/PhoneAlarmService')
global without sharing class PhoneAlarmService 
{
    private static Log logger = Log.get();

    @HttpPost
    global static void createTicket() 
    {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        Savepoint fullRollbackSP = Database.setSavepoint();
        try 
        {
            RestRequest req = RestContext.request;
            string requestBody = RestContext.request.requestBody != null ? RestContext.request.requestBody.toString() : '';
            system.debug(requestBody);
            
            requestBody = requestBody.replace('\\','').replace('\\','');
                
            system.debug(requestBody);
            Map<String, String> paramsMap = RestContext.request.params != null ? RestContext.request.params : new Map<string, string>();
            logger.add(requestBody, 'PhoneAlarmService');
            logger.add('Successfully created ticket for Phone Alarm Service', 'PhoneAlarmService');
            
            AlarmService a = (AlarmService)JSON.deserialize(requestBody, PhoneAlarmService.AlarmService.class);
            system.debug(a);
            
            List<Account> accounts = [SELECT Id
                                      FROM Account 
                                      WHERE Site_Number__c = :a.StoreLocation];
            
            
            List<Group> groups = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Aldi' LIMIT 1];
            
            Case c = new Case();
            c.AccountId = accounts.isEmpty() ? null : accounts[0].Id;
            c.Subject = 'ALDI Alarm System Notification';
            c.Description = 'A ' + a.AlarmType + ' alarm has been detected at ' + a.StoreLocation + ' and the user has requested this ticket be handled by PhoenixET';
            c.Status = 'New';
            c.OwnerId = groups[0].Id;
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMS').getRecordTypeId();
            insert c;
            c = [SELECT Id,CaseNumber FROM Case WHERE Id = :c.Id LIMIT 1];
            
            string response = '{"isSuccess": true, "CaseNumber": "' + c.CaseNumber + '"}';
            RestContext.response.responseBody = Blob.valueOf(response);
            logger.publish();
            return;
        }
        catch (Exception e)
        {
            logger.publish(e);
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            system.debug(e.getStackTraceString());
            Database.rollback(fullRollbackSP);
            RestContext.response.statusCode = 500;
            string response = '{"isSuccess": false}';
            RestContext.response.responseBody = Blob.valueOf(response);
        }
        logger.publish();
        return;
    }
    public class AlarmService
    {
        public string AlarmType;
        public string StoreLocation;
    }
}