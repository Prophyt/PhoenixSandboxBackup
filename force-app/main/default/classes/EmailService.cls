global without sharing class EmailService implements Messaging.InboundEmailHandler 
{
    public Account senderAccount {get;set;}
    public Contact senderContact {get;set;}
    public boolean isCorporateContact {get;set;}
    public boolean isEmergency {get;set;}
    public string supportTier {get;set;}
    public string customer {get;set;}
    

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) 
    {
        this.isEmergency = false;
        this.isCorporateContact = false;
        this.senderAccount = null;
        this.senderContact = null;
        this.supportTier = '';
        this.customer = getCustomer(email, env);
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        string fromAddress = email.fromAddress.toLowerCase();

        List<Contact> contacts = [SELECT Id,
                                  AccountId,
                                  Account.Name,
                                  Account.RecordTypeId,
                                  Account.RecordType.Name,
                                  Account.Customer_Support_Model__c,
                                  FirstName,
                                  LastName,
                                  Email
                                  FROM Contact
                                  WHERE Email = :fromAddress];
        
        system.debug('Found Contacts: ' + contacts);
        
        if(!contacts.isEmpty() && contacts[0].AccountId != null)
        {
            this.senderContact = contacts[0];
            
            List<Account> accounts = [SELECT Id,
                                      Name,
                                      Customer_Support_Model__c,
                                      RecordTypeId,
                                      RecordType.Name
                                      FROM Account
                                      WHERE Id = :contacts[0].AccountId];
            
            system.debug('Found Accounts: ' + accounts);
            
            this.senderAccount = accounts.isEmpty() ? null : accounts[0];
            if(this.senderAccount != null && this.senderAccount.RecordTypeId != null && this.senderAccount.RecordType.Name == 'Corporate Client')
            {
                this.isCorporateContact = true;
                this.isEmergency = true;                
            }
            
            if(this.senderAccount != null && this.senderAccount.Customer_Support_Model__c != null)
            {
                this.supportTier = this.senderAccount.Customer_Support_Model__c;
            }
        }
        
        
        string cleanSubject = '';
        if (!string.isBlank(email.subject))
            cleanSubject = email.subject.toLowerCase();

        
        if(cleanSubject.containsIgnoreCase('emergency'))
            this.isEmergency = true;
        
        system.debug('Corporate Contact: ' + this.isCorporateContact);
        system.debug('Is Emergency: ' + this.isEmergency); 
        system.debug('Support Tier: ' + this.supportTier);

        
        Set<string> toAddresses = new Set<string>();
        try 
        {
            if (isEmailBlocked(email) == true) 
            {
                system.debug('THIS EMAIL WAS BLOCKED');
                result.success = false;
                return result;
            }
            
            system.debug(email);
            system.debug(env);
            
            string emailBody = '';
            if (!string.isBlank(email.plainTextBody))
                emailBody = email.plainTextBody;
            else
                emailBody = email.htmlBody;
            
            
            //we have multiple tiers of matching attempts
            //1. we try to find a match by headers - salesforce preferred method
            //2. we will try to match by case number in the subject line
            //3. we will try to match by the email address and subject line
            //4. we will give up and just create a new one
            
            Id headerCaseId = email.headers != null ? System.Cases.getCaseIdFromEmailHeaders(email.headers) : null;
            system.debug(headerCaseId + ' email Header Case ID');
            
            if (headerCaseId != null) 
            {
                system.debug('Starting Case Header Lookup');
                List<Case> cases = [SELECT
                                    Id,
                                    AccountId,
                                    Account.OwnerId,
                                    Account.Owner.Name,
                                    Account.Owner.IsActive,
                                    ContactId,
                                    OwnerId,
                                    Status,
                                    ClosedDate,
                                    RecordTypeId,
                                    RecordType.Name,
                                    Type,
                                    Date_Time_Incoming_Email__c
                                    FROM Case
                                    WHERE Id = :headerCaseId
                                    FOR UPDATE];
                
                system.debug('Found existing Case By Email Headers' + cases[0]);
                updateCaseValues(email, cases[0].Id);
            } 
            else if (!string.isBlank(cleanSubject)) 
            {
                system.debug('attempting to match by Case number');
                //case number subject line matching method
                system.debug(cleanSubject);
                //{00000000}
                string regx = '([0-9]{8})';
                Pattern p = Pattern.compile(regx);
                Matcher m = p.matcher(cleanSubject);
                if (m.find()) 
                {
                    system.debug('Regex Groups: ' + m.groupCount());
                    for (integer x = 0; x < m.groupCount(); x++)
                        system.debug(m.group(x));
                    
                    string caseNumber = m.group(0) != null ? m.group(0) : '';
                    system.debug(caseNumber);
                    
                    //find existing case
                    List<Case> cases = [SELECT
                                        Id,
                                        AccountId,
                                        ContactId,
                                        Account.OwnerId,
                                        Account.Owner.Name,
                                        Account.Owner.IsActive,
                                        CaseNumber,
                                        OwnerId,
                                        RecordTypeId,
                                        RecordType.Name,
                                        Status,
                                        IsEscalated,
                                        Origin,
                                        Type,
                                        ClosedDate,
                                        Date_Time_Incoming_Email__c
                                        FROM Case
                                        WHERE CaseNumber = :caseNumber
                                        ORDER BY LastModifiedDate DESC];
                    
                    if (cases.isEmpty()) 
                    {
                        system.debug('Did not find any matching cases by case number');
                        //did not find a case by case number, create one
                        processNewItems(email, null);
                    } 
                    else 
                    {
                        //found a case by case number, update and append
                        system.debug('Found existing Case ' + cases[0].Id);
                        system.debug('Updating existing case');
                        updateCaseValues(email, cases[0].Id);
                    }
                } 
                else 
                {
                    system.debug('Subject Line did not have a case number in it. Try matching by subject/email combo');
                    //no case number in subject line

                    cleanSubject = cleanSubject.remove('fw:'); //remove forward tags
                    cleanSubject = cleanSubject.remove('re:'); //remove re tags
                    cleanSubject = cleanSubject.removeStart(' '); //remove any starting spaces
                    cleanSubject = cleanSubject.removeEnd(' '); //remove any trailing spaces
                    cleanSubject = '%' + cleanSubject + '%';
                    
                    system.debug('Attempting to find case by ' + email.fromAddress + ' and Case Subject LIKE ' + cleanSubject);
                    //try to find case by email address/subject match
                    
                    List<Case> cases = [SELECT
                                        Id,
                                        AccountId,
                                        ContactId,
                                        Account.OwnerId,
                                        Account.Owner.Name,
                                        Account.Owner.IsActive,
                                        CaseNumber,
                                        OwnerId,
                                        RecordTypeId,
                                        RecordType.Name,
                                        Status,
                                        IsEscalated,
                                        Origin,
                                        Type,
                                        ClosedDate,
                                        Date_Time_Incoming_Email__c
                                        FROM Case
                                        WHERE Contact.Email = :email.fromAddress 
                                        AND Subject LIKE :cleanSubject
                                        ORDER BY LastModifiedDate DESC];
                    
                    if (cases.isEmpty()) 
                    {
                        system.debug('Found no matching cases by subject/email combo');
                        processNewItems(email, null);
                    } 
                    else 
                    {
                        system.debug('Found a matching case by subject/email combo, running logic');
                        system.debug('Updating existing case');
                        updateCaseValues(email, cases[0].Id);
                    }
                }
            } 
            else 
            {
                system.debug('There was no subject line at all');
                //no subject line at all, no case header ID
                processNewItems(email, null);
            }
            
            result.success = true;
            return result;
        } 
        catch (Exception ex) 
        {
            system.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            sendErrorEmail(ex, email);
            result.success = false;
            return result;
        }
    }
    public static string getCustomer(Messaging.InboundEmail email, Messaging.InboundEnvelope env)
    {
        string fromAddress = email.fromAddress;
        fromAddress = fromAddress.toLowerCase();
        List<string> toAddresses = email.toAddresses;
        for(string t : toAddresses)
        {
            t = t.toLowerCase();
        }
        
        if(fromAddress.containsIgnoreCase('officedepot'))
            return 'Office Depot';
        for(string t : toAddresses)
        {
            if(t.containsIgnoreCase('officedepot'))
                return 'Office Depot';
        }
        
        return '';
    }
    public void processNewItems(Messaging.InboundEmail email, Case originalCase) 
    {
        system.debug('ProcessNewItems started');
        //createCase is the pre-support form method.
        Case c = createCase(email, originalCase);

        List<Case> cases = [SELECT
                            Id,
                            AccountId,
                            Account.OwnerId,
                            Account.Owner.Name,
                            Account.Owner.IsActive,
                            ContactId,
                            RecordTypeId,
                            RecordType.Name,
                            Status,
                            Date_Time_Incoming_Email__c,
                            Type
                            FROM Case
                            WHERE Id = :c.Id
                            FOR UPDATE];
        
        createEmailMessage(email, cases[0].Id, getContactId(cases), false);
        processBinaryAttachments(email, cases[0].Id);
        processTextAttachments(email, cases[0].Id);
    }
    public Id getContactId(List<Case> cases) 
    {
        system.debug('Lookup Contact Id for EmailMessageRelation');
        system.debug(cases[0]);
        Id contactId = null;
        if(cases[0].ContactId != null)
            contactId = cases[0].ContactId;
        else
            contactId = null;
        
        system.debug('Found ' + contactId);
        return contactId;
    }
    public Set<string> getEmailAddressSet(Messaging.InboundEmail email) 
    {
        Set<string> emailAddresses = new Set<string>();
        string replyToAddress = getReplyToAddress(email);
        emailAddresses.add(email.fromAddress);
        if (!string.isBlank(replyToAddress))
            emailAddresses.add(replyToAddress);
        
        return emailAddresses;
    }
    public Contact findContactByEmail(Messaging.InboundEmail email) 
    {
        Set<string> emailAddresses = getEmailAddressSet(email);
        
        List<Contact> contacts = [SELECT Id,
                                  AccountId,
                                  Account.Name,
                                  Account.Customer_Support_Model__c,
                                  Name, 
                                  OwnerId, 
                                  Owner.Name, 
                                  Owner.IsActive
                                  FROM Contact
                                  WHERE Email IN :emailAddresses
                                  ORDER BY LastModifiedDate DESC];
        
        system.debug(contacts.size() + ' Contact Matches for ' + emailAddresses);
        
        return contacts.isEmpty() ? null : contacts[0];
    }
    public Case createCase(Messaging.InboundEmail email, Case originalCase) 
    {
        system.debug('Starting CreateCase');
        List<BusinessHours> businessHours = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Default'];
        
        Set<string> emailAddresses = getEmailAddressSet(email);
        Contact con = findContactByEmail(email);
        
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Email';

        string subject = email.subject;
        if (!string.isBlank(subject) && subject.length() >= 255)
            subject = subject.abbreviate(252);

        c.Subject = subject;        
        c.BusinessHoursId = businessHours.isEmpty() ? null : businessHours[0].Id;
        c.AccountId = con == null || con.AccountId == null ? null : con.AccountId;
        c.ContactId = con == null ? null : con.Id;
		//some customer accounts get set by case body below in code
        string logicalOwnerId = processOwnerLogic(email, con);
        system.debug(logicalOwnerId + ' is logicalOwnerId');
        c.OwnerId = logicalOwnerId;
        
        string caseBody = '';
        if (email.plainTextBody != null && !string.isBlank(email.plainTextBody))
            caseBody = email.plainTextBody;
        else if (email.htmlBody != null && !string.isBlank(email.htmlBody))
            caseBody = email.htmlBody;
        else
            caseBody = '';
        
        if (caseBody.length() >= 32000)
            caseBody = caseBody.abbreviate(31995);
        
        system.debug(customer);
        if(customer.startsWithIgnoreCase('office depot'))
        {
            c.Origin = 'Third Party';
            //office depot check
            //check for Location ID then check for work order number
            Pattern p = Pattern.compile('(?ims).*LocationID:\\s+(\\S+).*');
            Matcher pm = p.matcher(caseBody);
            system.debug(pm.matches());
            if(pm.matches())
            {
                string locationID = pm.group(1);
                locationID = locationID.trim();
                string locationIDWithoutPadding = locationID.replaceFirst('^0+','');
                system.debug(locationID);
                List<Account> matchingLocations = [SELECT Id,
                                                   ParentId
                                                   FROM Account
                                                   WHERE Name like 'Office%'
                                                   AND (Site_Number__c = :locationID
                                                   OR Site_Number__c = :locationIDWithoutPadding)];
                
                system.debug(matchingLocations);
                if(!matchingLocations.isEmpty())
                {
                    c.AccountId = matchingLocations[0].Id;
                    c.Parent_Account__c = matchingLocations[0].ParentId != null ? matchingLocations[0].ParentId : null;
                }
            }
            
            //work order number check
            Pattern p2 = Pattern.compile('(?ims).*(WEB\\S+).*');
            Matcher pm2 = p2.matcher(caseBody);
            system.debug(pm2.matches());
            if(pm2.matches())
            {
                system.debug('Found Work Order Match');
                c.Customer_WO__c = pm2.group(1);
            }
            
            string workOrderDescription = '';
            Pattern p3 = Pattern.compile('(?is)(WorkOrder\\s+Description\\s+)(.*)(?>Contacts)');
            Matcher pm3 = p3.matcher(caseBody);
            if(pm3.find())
            {
                //only grabbing the WorkOrder Description section of Office Depot cases
                c.Description = pm3.group(1) + '\r\n' + pm3.group(2);
            }            
        }

        if(c.Description == null || string.isBlank(c.Description))
            c.Description = caseBody;

        c.SuppliedEmail = email.replyTo;
        c.SuppliedName = email.fromName;

        //be sure to trigger auto response when necessary
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerAutoResponseEmail = true;
        c.setOptions(dmo);
        insert c;
        
        system.debug(c.ID + ' Case Created');
        
        return c;
    }
    public void updateCaseValues(Messaging.InboundEmail email, Id caseId) {
        //this method only fires when we find an existing case during email processing
        //put logic around that cases special handling here
        system.debug('Starting UpdateCaseValues');
        List<BusinessHours> businessHours = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Default'];
        
        List<Group> queues = [SELECT Id, 
                              Name 
                              FROM Group 
                              WHERE Type = 'Queue' 
                              ORDER BY Name ASC];
        
        Map<string, id> queueNameMap = new Map<string, id>();
        for (Group g : queues) 
        {
            queueNameMap.put(g.Name, g.Id);
        }
        
        Case c = [SELECT
                  Id,
                  Status,
                  Origin,
                  Type,
                  CreatedDate,
                  AccountId,
                  Account.Name,
                  ContactId,
                  Contact.Name,
                  Contact.Email,
                  OwnerId,
                  Owner.IsActive,
                  Owner.Name,
                  RecordTypeId,
                  RecordType.Name,
                  Subject,
                  Date_Time_Incoming_Email__c,
                  (SELECT Id FROM EmailMessages)
                  FROM Case
                  WHERE Id = :caseId
                  FOR UPDATE];
        
        string ownerId = c.OwnerId;
        string ownerName = c.Owner.Name != null ? c.Owner.Name : '';
        string recordTypeName = c.RecordTypeId != null ? c.RecordType.Name : '';
        string caseType = c.Type != null ? c.Type : '';
        string caseSubject = !string.isBlank(c.Subject) ? c.Subject.toLowerCase() : '';
        boolean ownerIsActive = true;
        
        if (ownerId.startsWith('005') && c.Owner.IsActive == false)
            ownerIsActive = false;
        
        string origin = c.Origin.toLowerCase();
        string status = c.Status.toLowerCase();
        Long daysPassed = (DateTime.now().getTime() - c.CreatedDate.getTime()) / 86400000;

        c.Date_Time_Incoming_Email__c = DateTime.now();        
        c.Status = 'Customer Replied';
        
        update c;
        
        system.debug('Updated ' + c.Id + ' existing case');
        
        //requery here sucks but we need the values.
        c = [SELECT Id,
             CaseNumber,
             Date_Time_Incoming_Email__c,
             Status,
             Origin,
             Type,
             AccountId,
             ContactId,
             Contact.Email,
             OwnerId,
             Owner.IsActive
             FROM Case
             WHERE Id = :c.Id];
        
        createEmailMessage(email, c.Id, getContactId(new List<Case>{ c }), false);
        processBinaryAttachments(email, c.Id);
        processTextAttachments(email, c.Id);
    }
    public string processOwnerLogic(Messaging.InboundEmail email, Contact con) 
    {
        system.debug('Starting ProcessOwnerLogic');
        List<string> toAddresses = email.toAddresses != null ? email.toAddresses : new List<string>();
        string fromAddress = email.fromAddress;
        string subject = email.subject;
        string body = email.plainTextBody != null ? email.plainTextBody : email.htmlBody != null ? email.htmlBody : '';
        string replyToAddress = getReplyToAddress(email);
        string caseOwnerId = processFallbackRouting(toAddresses, con, email);
        //List<string> lines = body.split('\r\n');
        //system.debug(lines.size());
        return caseOwnerId;
    }
    public string processFallbackRouting(List<string> toAddresses, Contact con, Messaging.InboundEmail email) 
    {
        system.debug('Starting ProcessFallbackRouting');
        string caseOwnerId = '';
        if (toAddresses == null || toAddresses.isEmpty()) 
        {
            caseOwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Email - Bronze'].Id;
            return caseOwnerId;
        }
        
        List<Group> queues = [SELECT Id, 
                              Name 
                              FROM Group 
                              WHERE Type = 'Queue' 
                              ORDER BY Name ASC];
        
        Map<string, id> queueNameMap = new Map<string, id>();
        for (Group g : queues) 
        {
            queueNameMap.put(g.Name, g.Id);
        }
        
        for (string toAddress : toAddresses) 
        {
            //stack these in order of priority so you hit the most important first
            //and then if we already have a value it just skips out the rest
            if (!string.isBlank(caseOwnerId))
                return caseOwnerId;
            
            if(isEmergency)
            {
                caseOwnerId = queueNameMap.get('Email - Emergency');
            }
            else if(customer.toLowerCase() == 'office depot')
            {
                caseOwnerId = queueNameMap.get('Office Depot');
            }
            else if(supportTier.toLowerCase() == 'Bronze')
            {
                caseOwnerId = queueNameMap.get('Email - Bronze');
            }
            else if(supportTier.toLowerCase() == 'Silver')
            {
                caseOwnerId = queueNameMap.get('Email - Silver');
            }
            else if(supportTier.toLowerCase() == 'Gold')
            {
                caseOwnerId = queueNameMap.get('Email - Gold');
            }
            else if(supportTier.toLowerCase() == 'Platinum')
            {
                caseOwnerId = queueNameMap.get('Email - Platinum');
            }
            else
            {
             	caseOwnerId = queueNameMap.get('Email - Bronze');   
            }            
        }
        
        //failsafe
        if (string.isBlank(caseOwnerId))
            caseOwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Email - Bronze'].Id;
        
        return caseOwnerId;
    }
    
    public string getReplyToAddress(Messaging.InboundEmail email) 
    {
        system.debug('Starting GetReplyToAddress');
        
        if (email.headers == null && email.replyTo == null)
            return '';
        
        if (!string.isBlank(email.replyTo))
            return email.replyTo;
        
        string alternateFromAddress = '';
        for (Messaging.InboundEmail.Header header : email.headers) 
        {
            string headerName = header.name;
            headerName = headerName.toLowerCase();
            if (headerName == 'reply-to') 
            {
                string alternateFrom = header.value;
                alternateFrom = alternateFrom.toLowerCase();
                alternateFromAddress = alternateFrom;
            } 
            else 
            {
                //we dont care about other headers right now
                continue;
            }
        }
        
        return alternateFromAddress;
    }
    public void createEmailMessage(Messaging.InboundEmail email, Id parentId, Id contactId, boolean useRelatedToInsteadOfParent) 
    {
        try 
        {
            system.debug('Starting CreateEmailAttachment - Generating EmailMessage record');
            EmailMessage e = new EmailMessage();
            e.FromAddress = email.fromAddress;
            e.Incoming = true;
            e.Status = '0';
            if (email.headers != null) 
            {
                string headers = '';
                for (Messaging.InboundEmail.Header h : email.headers) 
                {
                    headers += h + '\r\n';
                }
                e.Headers = headers;
            }
            e.FromName = email.fromName;
            e.ToAddress = email.toAddresses != null ? email.toAddresses[0] : null;
            e.Subject = email.subject;
            
            if (useRelatedToInsteadOfParent == true)
                e.RelatedToId = parentId;
            else
                e.ParentId = parentId;
            
            
            string ptBody = email.plainTextBody != null ? email.plainTextBody : '';
            if (ptBody.length() >= 131072)
                ptBody = ptBody.abbreviate(131000);
            
            //this could corrupt html, but at least it will save and not crash out
            string htmlBody = email.htmlBody != null ? email.htmlBody : '';
            if (htmlBody.length() >= 131072)
                htmlBody = htmlBody.abbreviate(131000);
            
            e.TextBody = email.plainTextBody != null ? ptBody : null;
            e.HtmlBody = email.htmlBody != null ? htmlBody : null;
            
            insert e;
            
            List<EmailMessageRelation> relations = new List<EmailMessageRelation>();
            if (contactId != null) 
            {
                EmailMessageRelation er = new EmailMessageRelation();
                er.EmailMessageId = e.Id;
                er.RelationId = contactId;
                er.RelationAddress = email.FromAddress;
                er.RelationType = 'FromAddress';
                relations.add(er);
            } 
            else 
            {
                EmailMessageRelation er = new EmailMessageRelation();
                er.EmailMessageId = e.Id;
                er.RelationAddress = email.FromAddress;
                er.RelationType = 'FromAddress';
                relations.add(er);
            }
            if (email.toAddresses != null) 
            {
                for (string to : email.toAddresses) 
                {
                    EmailMessageRelation er = new EmailMessageRelation();
                    er.EmailMessageId = e.Id;
                    er.RelationAddress = to;
                    er.RelationType = 'ToAddress';
                    relations.add(er);
                }
            }
            if (email.ccAddresses != null) 
            {
                for (string cc : email.ccAddresses) 
                {
                    EmailMessageRelation er = new EmailMessageRelation();
                    er.EmailMessageId = e.Id;
                    er.RelationAddress = cc;
                    er.RelationType = 'CcAddress';
                    relations.add(er);
                }
            }
            
            if (!relations.isEmpty())
                insert relations;
        } 
        catch (Exception ex) 
        {
            system.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            sendErrorEmail(ex, email);
        }
    }
    public void processBinaryAttachments(Messaging.InboundEmail email, Id caseId) 
    {
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        if (email.binaryAttachments == null)
            return;
        
        for (Messaging.InboundEmail.BinaryAttachment f : email.binaryAttachments) 
        {
            if (f.Body == null || f.Body.size() == 0)
                continue;
            
            ContentVersion c = new ContentVersion();
            c.Title = f.fileName != null && f.fileName.length() < 255 ? f.fileName : f.fileName.right(250);
            c.VersionData = f.body;
            c.PathOnClient = '/' + f.fileName;
            cvs.add(c);            
        }
        insert cvs;
        
        cvs = [SELECT Id, 
               ContentDocumentId 
               FROM ContentVersion 
               WHERE Id IN :cvs];
        
        for (ContentVersion cv : cvs) 
        {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = caseId; //Shared with record ID
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdls.add(cdl);
        }
        
        insert cdls;
		/* older attachment version
        if(email.textAttachments != null && !email.textAttachments.isEmpty())
        {
        for(integer i = 0; i < email.textAttachments.size(); i++)
        {
        if(email.textAttachments[i].fileName != null)
        {
        Attachment a = new Attachment(ParentId = caseId,
        Name = email.textAttachments[i].fileName,
        Body = blob.valueOf(email.textAttachments[i].body));
        insert a;
        }
        }
        }
        */
    }
    public void processTextAttachments(Messaging.InboundEmail email, Id caseId) 
    {
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        if (email.textAttachments == null)
            return;
        
        for (Messaging.InboundEmail.TextAttachment f : email.textAttachments) 
        {
            if (f.Body == null || f.Body.length() == 0)
                continue;
            
            ContentVersion c = new ContentVersion();
            c.Title = f.fileName != null && f.fileName.length() < 255 ? f.fileName : f.fileName.right(250);
            c.VersionData = blob.valueOf(f.body);
            c.PathOnClient = '/' + f.fileName;
            cvs.add(c);
        }
        insert cvs;
        
        cvs = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvs];
        
        for (ContentVersion cv : cvs) 
        {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = caseId; //Shared with record ID
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdls.add(cdl);
        }
        insert cdls;
    }
    public static void sendErrorEmail(Exception e, Messaging.InboundEmail email) 
    {
        string[] toAddresses = new List<string>{ 'brad.overlund@gmail.com' };
		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(toAddresses);
        msg.setReplyTo('noreply@phoenixet.com');
        msg.setSenderDisplayName('Salesforce Error');
        msg.setSubject('Phoenix Email Service Error');
        msg.setPlainTextBody(e.getLineNumber() + '\r\n' + e.getMessage() + '\r\n\r\n' + e.getStackTraceString());
        if (!test.isRunningTest()) 
        {
            Messaging.reserveMassEmailCapacity(1);
            
            if (e != null && !e.getMessage().contains('blocked'))
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ msg });
        }
    }
    public static boolean isEmailBlocked(Messaging.InboundEmail email) 
    {
        //get blocking rules, check address and subject rules
        //if we return true here, its a blocked email and discard it
        //if we return false her, its a good email to continue processing
        
        List<Email_Block__mdt> blockRules = [SELECT Id, 
                                             MasterLabel, 
                                             Blocked_Address__c, 
                                             Blocked_Subject__c, 
                                             Block_All__c 
                                             FROM Email_Block__mdt];
        if (test.isRunningTest()) 
        {
            blockRules.add(EmailServiceTest.getEmailBlock());
        }
        
        Map<string, Email_Block__mdt> blockRuleMap = new Map<string, Email_Block__mdt>();
        for (Email_Block__mdt r : blockRules) {
            blockRuleMap.put(r.Blocked_Address__c.toLowerCase(), r);
        }
        
        if (blockRuleMap.containsKey(email.fromAddress) || blockRuleMap.containsKey(email.replyTo)) 
        {
            system.debug('Incoming Email Matches a Block Rule');
            system.debug(email);
            Email_Block__mdt rule = blockRuleMap.containsKey(email.fromAddress) ? blockRuleMap.get(email.fromAddress) : blockRuleMap.get(email.replyTo);
            string subject = email.Subject.toLowerCase();
            string blockedSubject;
            if (!string.isBlank(rule.Blocked_Subject__c))
                blockedSubject = rule.Blocked_Subject__c.toLowerCase();
            
            if (rule.Block_All__c == true || (!string.isEmpty(blockedSubject) && subject.contains(blockedSubject))) 
            {
                return true;
            } 
            else 
            {
                return false;
            }
        } 
        else 
        {
            return false;
        }
    }
}