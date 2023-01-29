public class SMSAssistWorkOrderScheduler implements Schedulable 
{
    Integer intervalMinutes;
    public SMSAssistWorkOrderScheduler(Integer intervalMinutes) 
    {
        this.intervalMinutes = intervalMinutes;
    }
    public void execute(SchedulableContext sc) 
    {
        // Re-schedule ourself to run again in "intervalMinutes" time
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(SMSAssistWorkOrderBatch.class.getName() + '-' + now.format(), cronString, new SMSAssistWorkOrderScheduler(intervalMinutes));
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);     
        // Launch a batch job or call a future method to do the actual work
        // if you want to call the batch for a specific time frame just run it manually, this scheduler is just to keep the job running every X minutes
        Database.executeBatch(new SMSAssistWorkOrderBatch(''));
    }
}