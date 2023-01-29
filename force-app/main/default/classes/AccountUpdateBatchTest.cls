@isTest
public class AccountUpdateBatchTest 
{
	public static testMethod void runTest()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        a.Closed_Date__c = date.today();
        insert a;
                
        Test.startTest();

        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(5);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        AccountUpdateBatchScheduler sch = new AccountUpdateBatchScheduler(5);
        system.schedule('Test Account Update Scheduler', cronString, sch);
        Test.stopTest();
    }
}