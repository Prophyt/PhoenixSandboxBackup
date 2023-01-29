public class AccountUpdateBatchScheduler implements Schedulable 
{
    Integer intervalMinutes;
    public AccountUpdateBatchScheduler(Integer intervalMinutes) 
    {
        this.intervalMinutes = intervalMinutes;
    }
    public void execute(SchedulableContext sc) 
    {
        // Re-schedule ourself to run again in "intervalMinutes" time
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(AccountUpdateBatchScheduler.class.getName() + '-' + now.format(), cronString, new AccountUpdateBatchScheduler(intervalMinutes));
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);     
        // Launch a batch job or call a future method to do the actual work
        string query = 'SELECT Id,Closed_Date__c,Location_Status__c FROM Account WHERE Closed_Date__c != null AND Location_Status__c != \'Inactive\'';
        if(Test.isRunningTest())
            query = 'SELECT Id,Closed_Date__c,Location_Status__c FROM Account WHERE Closed_Date__c != null';
        Database.executeBatch(new AccountUpdateBatch(query));
    }
}