@isTest
public class ReminderQueueBatchTest 
{
    @testSetup
	public static void runSetup()
    {
        Account ap = new Account();
        ap.Name = 'Best Buy';
        insert ap;
        
        Account a = new Account();
        a.Name = 'TestCo';
        a.ParentId = ap.Id;
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Parent_Account__c = ap.Id;
        c.Subject = 'test';
        c.Description = 'test';
        insert c;
        
        Task t = new Task();
        t.WhatId = c.Id;
        t.ActivityDate = Date.today();
        t.OwnerId = [SELECT Id FROM Group WHERE Type ='Queue' AND Name = 'Reminder Queue'].Id;
        t.ReminderDateTime = datetime.now().addMinutes(-20);
        t.Subject = 'Reminder Task';
        t.IsReminderSet = true;
        insert t;
        
        system.AssertEquals([SELECT OwnerId FROM Task LIMIT 1].OwnerId, [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Reminder Queue'].Id);
    }
    public static testMethod void runTest()
    {
        ReminderQueueBatch b = new ReminderQueueBatch('');
        Test.startTest();
        database.executeBatch(b);
        Test.stopTest();
    }
    public static testMethod void runTestSchedule()
    {
        Test.startTest();
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(5);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        ReminderQueueScheduler sch = new ReminderQueueScheduler(5);
        system.schedule('Test Reminder Queue Scheduler', cronString, sch);
        Test.stopTest();
    }       
}