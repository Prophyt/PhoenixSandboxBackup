@isTest
public class EmailServiceTest
{
    public static testMethod void runNewTest()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.email = 'test@test.com';
        con.AccountId = a.Id;
        insert con;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'Reply-To';
        header.value = 'testsomething@pet.com';
        email.headers.add(header);
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TEST Subject';
        email.fromName = 'Test Test';
        email.fromAddress = 'test@test.com';
        email.toAddresses = new string[]{'support@pet.com'};
        email.ccAddresses = new string[]{'testcc@pet.com'};
        email.plainTextBody = 'This is a test';
        env.fromAddress = 'test@test.com';

        Messaging.InboundEmail.TextAttachment ta = new Messaging.InboundEmail.TextAttachment();
        ta.body = 'test';
        ta.fileName = 'test.txt';
        ta.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { ta };

        Messaging.InboundEmail.BinaryAttachment ba = new Messaging.InboundEmail.BinaryAttachment();
        ba.body = blob.valueOf('this is a fake string');
        ba.fileName = 'Test.txt';
        ba.mimeTypeSubType = 'text/plain';

        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{ba};

        EmailService service = new EmailService();
        service.handleInboundEmail(email, env);
    }
    public static testMethod void runExistingOpenCaseTest()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.email = 'test@test.com';
        con.AccountId = a.Id;
        insert con;

        Case c = new Case();
        c.AccountId = a.Id;
        c.ContactId = con.Id;
        c.Subject = 'TEST Subject';
        c.Description = 'This is a test';
        c.Origin = 'Email - support@pet.com';
        c.Status = 'New';
        insert c;

        string caseNumber = [SELECT Id,CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'Reply-To';
        header.value = 'testsomething@pet.com';
        email.headers.add(header);

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = caseNumber + ': TEST Subject';
        email.fromName = 'Test Test';
        email.fromAddress = 'test@test.com';
        email.toAddresses = new string[]{'support@pet.com'};
        email.plainTextBody = 'This is a test';
        env.fromAddress = 'test@test.com';

        Messaging.InboundEmail.TextAttachment ta = new Messaging.InboundEmail.TextAttachment();
        ta.body = 'test';
        ta.fileName = 'test.txt';
        ta.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { ta };

        Messaging.InboundEmail.BinaryAttachment ba = new Messaging.InboundEmail.BinaryAttachment();
        ba.body = blob.valueOf('this is a fake string');
        ba.fileName = 'Test.txt';
        ba.mimeTypeSubType = 'text/plain';

        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{ba};

        EmailService service = new EmailService();
        service.handleInboundEmail(email, env);
    }
    public static testMethod void runTestBlock()
    {
        Account a = new Account();
        a.Name = 'TestCo';
        insert a;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.email = 'test@test.com';
        con.AccountId = a.Id;
        insert con;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'Reply-To';
        header.value = 'testsomething@pet.com';
        email.headers.add(header);

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TEST Subject';
        email.fromName = 'Test Test';
        email.fromAddress = 'testblock@test.com';
        email.toAddresses = new string[]{'support@pet.com'};
        email.plainTextBody = 'This is a test';
        env.fromAddress = 'test@test.com';

        Messaging.InboundEmail.TextAttachment ta = new Messaging.InboundEmail.TextAttachment();
        ta.body = 'test';
        ta.fileName = 'test.txt';
        ta.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { ta };

        Messaging.InboundEmail.BinaryAttachment ba = new Messaging.InboundEmail.BinaryAttachment();
        ba.body = blob.valueOf('this is a fake string');
        ba.fileName = 'Test.txt';
        ba.mimeTypeSubType = 'text/plain';

        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{ba};

        EmailService service = new EmailService();
        service.handleInboundEmail(email, env);
    }
    public static testMethod void runSendErrorEmailTest()
    {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'Reply-To';
        header.value = 'testsomething@pet.com';
        email.headers.add(header);

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TEST Subject';
        email.fromName = 'Test Test';
        email.fromAddress = 'test@test.com';
        email.toAddresses = new string[]{'support@pet.com'};
        email.plainTextBody = 'This is a test';
        env.fromAddress = 'test@test.com';
        
        try
        {
            Lead l = new Lead();
            insert l;
            
        }
        catch(Exception ex)
        {
            EmailService.sendErrorEmail(ex, email);            
        }

    }
    public static Email_Block__mdt getEmailBlock() 
    {
        Email_Block__mdt block = new Email_Block__mdt();
        block.DeveloperName = 'TestEmail';
        block.Blocked_Address__c = 'testblock@test.com';
        block.Blocked_Subject__c = 'Test Email';
        return block;
    }
}