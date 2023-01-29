public class CorrigoProEvent 
{
    //could be either of these two
    public string InternalNote;
    public string Comment;
    
    public string UpdatedBy;
	
    public string Status;
    public Header Header;
    public RepairInfo RepairInfo;
    
    public class Header
    {
    	public integer WorkOrderId;
        public integer BranchId;
        public Sender Sender;
        public string Action;
        public string ActionDate;
        public string ApiVersion;
        public string MessageId;
    }

    public class Sender
    {
    	public string Name;
        public string Phone;
        public string Type;
    }
    public class RepairInfo
    {
        public string Code;
        public string Category;
        public integer CodeId;
        public integer CategoryId;
    }
    
    public static CorrigoProEvent parse(String json) 
    {
        CorrigoProEvent e = (CorrigoProEvent)System.JSON.deserialize(json, CorrigoProEvent.class);
        return e;
    }
	
    public static Case updateCaseStatus(Integration_Message__c m)
    {
        CorrigoProEvent ev = (CorrigoProEvent)System.JSON.deserialize(m.Package__c, CorrigoProEvent.class);
        if(ev == null)
            return null;
        
        string woId = string.valueOf(ev.Header.WorkOrderId);
        
        List<Case> existingCases = [SELECT Id,
                                    AccountId,
                                    Account.Third_Party_FM_Id__c,
                                    Customer_WO__c,
                                    IsClosed,
                                    Status,
                                    Origin,
                                    X3rd_Party_Priority__c,
                                    X3rd_Party_Issue_Type__c,
                                    X3rd_Party_WO_Id__c,
                                    Integration_Message__c,
                                    X3rd_Party_Problem__c,
                                    X3rd_Party_System__c,
                                    Subject
                                    FROM Case 
                                    WHERE X3rd_Party_WO_Id__c = :woId
                                    AND X3rd_Party_WO_Id__c != null
                                    AND X3rd_Party_System__c = 'CorrigoPro'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1];
        
        if(existingCases.isEmpty())
        {
            return null;
        }
        else
        {
            Case c = existingCases[0];
            string originalStatus = c.Status;
            Set<string> needsReviewTypes = new Set<string>();
            needsReviewTypes.add('recalled');
            needsReviewTypes.add('rejected');
            needsReviewTypes.add('reopened');
            needsReviewTypes.add('closed');
            needsReviewTypes.add('resolved');
            needsReviewTypes.add('completed');
            needsReviewTypes.add('checkedout');
            
            if(m.Header__c.toLowerCase() == 'putonhold')
                c.Status = 'Pending Response External';
            else if(m.Header__c.toLowerCase() == 'accepted')
                c.Status = 'Accepted';
            else if(m.Header__c.toLowerCase() == 'reopened')
                c.Status = 'Reopened';
            /*removed per Farrah PET-200
             * else if(needsReviewTypes.contains(m.Header__c.toLowerCase()))
                c.Status = 'Needs Review';*/
            
            if(c.Status != originalStatus)
                update c;
            
            return c;
        }
        
    }
        
    public static CaseComment createCaseCommentFromNote(Integration_Message__c m)
    {
        CorrigoProEvent ev = (CorrigoProEvent)System.JSON.deserialize(m.Package__c, CorrigoProEvent.class);
        if(ev == null)
            return null;
        
        string woId = string.valueOf(ev.Header.WorkOrderId);
        
        List<Case> existingCases = [SELECT Id,
                                    AccountId,
                                    Account.Third_Party_FM_Id__c,
                                    Customer_WO__c,
                                    IsClosed,
                                    Status,
                                    Origin,
                                    X3rd_Party_Priority__c,
                                    X3rd_Party_Issue_Type__c,
                                    X3rd_Party_WO_Id__c,
                                    Integration_Message__c,
                                    X3rd_Party_Problem__c,
                                    X3rd_Party_System__c,
                                    Subject
                                    FROM Case 
                                    WHERE X3rd_Party_WO_Id__c = :woId
                                    AND X3rd_Party_WO_Id__c != null
                                    AND X3rd_Party_System__c = 'CorrigoPro'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1];
        
        if(existingCases.isEmpty())
        {
            return null;
        }
        else
        {
            CaseComment cc = new CaseComment();
            cc.ParentId = existingCases[0].Id;
            string body = ev.Header.Sender.Name + ' (' + ev.Header.Sender.Type + ')' + ' wrote:\r\n' + ev.InternalNote + '\r\n\r\nMessage ID:' + ev.Header.MessageId;
            cc.CommentBody = body;
            insert cc;
            return cc;
        }
        
        
    }
}