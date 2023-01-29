@isTest
public class ClientAlertBatchTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        
        Client_Alert__c alert = new Client_Alert__c();
        alert.Account__c = a.Id;
        alert.Status__c = 'Active';
        alert.Start_Date__c = Date.today().addDays(-5);
        alert.End_Date__c = Date.today().addDays(-1);
        insert alert;
        
        Test.startTest();

        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(5);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        ClientAlertScheduler sch = new ClientAlertScheduler(5);
        system.schedule('Test Client Alert Scheduler', cronString, sch);
        Test.stopTest();
    }
}