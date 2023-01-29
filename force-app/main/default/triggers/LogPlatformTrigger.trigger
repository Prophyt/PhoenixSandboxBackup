trigger LogPlatformTrigger on Log__e (after insert) 
{
    if (trigger.isAfter && trigger.isInsert) 
    {
        System.debug('After Insert LogPlatform Trigger');
        LogPlatformTriggerHandler.afterInsert(trigger.new);
    }
}