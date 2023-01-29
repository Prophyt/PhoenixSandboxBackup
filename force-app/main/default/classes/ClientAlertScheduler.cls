public class ClientAlertScheduler implements Schedulable 
{
    Integer intervalMinutes;
    public ClientAlertScheduler(Integer intervalMinutes) 
    {
        this.intervalMinutes = intervalMinutes;
    }
    public void execute(SchedulableContext sc) 
    {
        // Re-schedule ourself to run again in "intervalMinutes" time
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(ClientAlertScheduler.class.getName() + '-' + now.format(), cronString, new ClientAlertScheduler(intervalMinutes));
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);     
        // Launch a batch job or call a future method to do the actual work
        Database.executeBatch(new ClientAlertBatch('SELECT Id,Status__c,End_Date__c,Pop_on_Case__c FROM Client_Alert__c WHERE Status__c != \'Inactive\' AND End_Date__c < TODAY'));
    }
}