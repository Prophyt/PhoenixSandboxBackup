trigger CaseTrigger on Case (before insert,before update, after insert, after update)
{
    CaseTriggerHandler handler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        handler.OnBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler.OnAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
}