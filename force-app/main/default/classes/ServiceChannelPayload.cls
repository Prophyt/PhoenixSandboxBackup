public class ServiceChannelPayload 
{    
    public Object_Z Object_Z {get;set;} // in json: Object
    public String Type {get;set;} 
    public String Action {get;set;} 
    public String EventType {get;set;} 
    public Integer Version {get;set;} 
    
    public ServiceChannelPayload(JSONParser parser) 
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) 
        {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
            {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                {
                    if (text == 'Object') 
                    {
                        Object_Z = new Object_Z(parser);
                    } 
                    else if (text == 'Type') 
                    {
                        Type = parser.getText();
                    } 
                    else if (text == 'Action') 
                    {
                        Action = parser.getText();
                    }
                    else if (text == 'EventType') 
                    {
                        EventType = parser.getText();
                    } 
                    else if (text == 'Version') 
                    {
                        Version = parser.getIntegerValue();
                    } 
                    else 
                    {
                        System.debug(LoggingLevel.WARN, 'ServiceChannelPayload consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Object_Z 
    {
        public Integer Id {get;set;} 
        public string Action {get;set;}
        public string ProblemCode {get;set;}
        public String Number_Z {get;set;} // in json: Number
        public String PurchaseNumber {get;set;} 
        public Integer SubscriberId {get;set;} 
        public Integer ProviderId {get;set;} 
        public String ProviderName {get;set;} 
        public Integer LocationId {get;set;} 
        public String LocationName {get;set;} 
        public String LocationStoreId {get;set;} 
        public Status Status {get;set;} 
        public String Caller {get;set;} 
        public String CreatedBy {get;set;} 
        public String CallDate {get;set;} 
        public String CallDate_DTO {get;set;} 
        public String Priority {get;set;} 
        public String Trade {get;set;} 
        public String ScheduledDate {get;set;} 
        public String CreatedDate_DTO {get;set;} 
        public String UpdatedDate {get;set;} 
        public String UpdatedDate_DTO {get;set;} 
        public String ScheduledDate_DTO {get;set;} 
        public String CompletedDate {get;set;} 
        public String ExpirationDate {get;set;} 
        public String ExpirationDate_DTO {get;set;} 
        public String Description {get;set;} 
        public String Category {get;set;} 
        public Double Nte {get;set;} 
        public String CurrencyAlphabeticalCode {get;set;} 
        public String Resolution {get;set;} 
        public String Source {get;set;} 
        public IssueTicketInfo IssueTicketInfo {get;set;}
        public List<Notes> Notes {get;set;} 
        public List<Attachments> Attachments {get;set;} 
        public List<Attachments> LinkedWorOrderIds {get;set;} 
        public List<Attachments> Assets {get;set;} 
        
        public Object_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Number') {
                            Number_Z = parser.getText();
                        }
                        else if (text == 'Action')
                        {
                            Action = parser.getText();
                        }
                        else if(text == 'ProblemCode')
                        {
                            ProblemCode = parser.getText();
                        }
                        else if (text == 'PurchaseNumber') {
                            PurchaseNumber = parser.getText();
                        } else if (text == 'SubscriberId') {
                            SubscriberId = parser.getIntegerValue();
                        } else if (text == 'ProviderId') {
                            ProviderId = parser.getIntegerValue();
                        } else if (text == 'ProviderName') {
                            ProviderName = parser.getText();
                        } else if (text == 'LocationId') {
                            LocationId = parser.getIntegerValue();
                        } else if (text == 'LocationName') {
                            LocationName = parser.getText();
                        } else if (text == 'LocationStoreId') {
                            LocationStoreId = parser.getText();
                        } else if (text == 'Status') {
                            Status = new Status(parser);
                        } else if (text == 'Caller') {
                            Caller = parser.getText();
                        } else if (text == 'CreatedBy') {
                            CreatedBy = parser.getText();
                        } else if (text == 'CallDate') {
                            CallDate = parser.getText();
                        } else if (text == 'CallDate_DTO') {
                            CallDate_DTO = parser.getText();
                        } else if (text == 'Priority') {
                            Priority = parser.getText();
                        } else if (text == 'Trade') {
                            Trade = parser.getText();
                        } else if (text == 'ScheduledDate') {
                            ScheduledDate = parser.getText();
                        } else if (text == 'CreatedDate_DTO') {
                            CreatedDate_DTO = parser.getText();
                        } else if (text == 'UpdatedDate') {
                            UpdatedDate = parser.getText();
                        } else if (text == 'UpdatedDate_DTO') {
                            UpdatedDate_DTO = parser.getText();
                        } else if (text == 'ScheduledDate_DTO') {
                            ScheduledDate_DTO = parser.getText();
                        } else if (text == 'CompletedDate') {
                            CompletedDate = parser.getText();
                        } else if (text == 'ExpirationDate') {
                            ExpirationDate = parser.getText();
                        } else if (text == 'ExpirationDate_DTO') {
                            ExpirationDate_DTO = parser.getText();
                        } else if (text == 'Description') {
                            Description = parser.getText();
                        } else if (text == 'Category') {
                            Category = parser.getText();
                        } else if (text == 'Nte') {
                            Nte = parser.getDoubleValue();
                        } else if (text == 'CurrencyAlphabeticalCode') {
                            CurrencyAlphabeticalCode = parser.getText();
                        } else if (text == 'Resolution') {
                            Resolution = parser.getText();
                        } else if (text == 'Source') {
                            Source = parser.getText();
                        } else if (text == 'Notes') {
                            Notes = arrayOfNotes(parser);
                        } else if (text == 'Attachments') {
                            Attachments = arrayOfAttachments(parser);
                        } else if (text == 'LinkedWorOrderIds') {
                            LinkedWorOrderIds = arrayOfAttachments(parser);
                        } else if (text == 'Assets') {
                            Assets = arrayOfAttachments(parser);
                        } 
                        else if (text == 'IssueTicketInfo')
                        {
                            IssueTicketInfo = new IssueTicketInfo(parser);
                        }
                        else 
                        {
                            System.debug(LoggingLevel.WARN, 'Object_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class IssueTicketInfo
    {
        public integer Id{get;set;}
        public integer AreaId {get;set;}
        public string AreaName {get;set;}
        public string ProblemGroup {get;set;}
        public string Equipment {get;set;}
        public string ProblemCode {get;set;}
        public string TicketType {get;set;}
        public integer SetupId {get;set;}
        
        public IssueTicketInfo(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'Id') 
                        {    
                            Id = parser.getIntegerValue();
                        }
                        else if (text == 'AreaId') 
                        {
                            AreaId = parser.getIntegerValue();
                        }
                        else if (text == 'AreaName') 
                        {
                            AreaName = parser.getText();
                        }
                        else if(text == 'ProblemGroup')
                        {
                            ProblemGroup = parser.getText();
                        }
                        else if(text == 'Equipment')
                        {
                            Equipment = parser.getText();    
                        }
                        else if(text == 'TicketType')
                        {
                            TicketType = parser.getText();  
                        }
                        else if(text == 'SetupId')
                        {
                            SetupId = parser.getIntegerValue();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'IssueTicketInfo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    public class Status 
    {
        public String Primary {get;set;} 
        public String Extended {get;set;} 
        
        public Status(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'Primary') 
                        {
                            Primary = parser.getText();
                        } 
                        else if (text == 'Extended') 
                        {
                            Extended = parser.getText();
                        }
                        else 
                        {
                            System.debug(LoggingLevel.WARN, 'Status consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class CreatedByUser 
    {
        public String UserName {get;set;} 
        public String FullName {get;set;} 
        public Integer SubscriberId {get;set;} 
        
        public CreatedByUser(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'UserName') {
                            UserName = parser.getText();
                        } else if (text == 'FullName') {
                            FullName = parser.getText();
                        } else if (text == 'SubscriberId') {
                            SubscriberId = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'CreatedByUser consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static ServiceChannelPayload parse(String json) 
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ServiceChannelPayload(parser);
    }
    
    public class Attachments 
    {
        public Attachments(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        {
                            System.debug(LoggingLevel.WARN, 'Attachments consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Notes 
    {
        public Integer Id {get;set;} 
        public Integer Number_Z {get;set;} // in json: Number
        public String NoteData {get;set;} 
        public String DateCreated {get;set;} 
        public String ScheduledDate {get;set;} 
        public Boolean ActionRequired {get;set;} 
        public String MailedTo {get;set;} 
        public String CreatedBy {get;set;} 
        public CreatedByUser CreatedByUser {get;set;} 
        public String DateCreated_DTO {get;set;} 
        
        public Notes(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Number') {
                            Number_Z = parser.getIntegerValue();
                        } else if (text == 'NoteData') {
                            NoteData = parser.getText();
                        } else if (text == 'DateCreated') {
                            DateCreated = parser.getText();
                        } else if (text == 'ScheduledDate') {
                            ScheduledDate = parser.getText();
                        } else if (text == 'ActionRequired') {
                            ActionRequired = parser.getBooleanValue();
                        } else if (text == 'MailedTo') {
                            MailedTo = parser.getText();
                        } else if (text == 'CreatedBy') {
                            CreatedBy = parser.getText();
                        } else if (text == 'CreatedByUser') {
                            CreatedByUser = new CreatedByUser(parser);
                        } else if (text == 'DateCreated_DTO') {
                            DateCreated_DTO = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Notes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static void consumeObject(System.JSONParser parser) 
    {
        Integer depth = 0;
        do 
        {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||  curr == System.JSONToken.START_ARRAY) 
            {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) 
            {
                depth--;
            }
        } 
        while (depth > 0 && parser.nextToken() != null);
    }
    
    private static List<Attachments> arrayOfAttachments(System.JSONParser p) 
    {
        List<Attachments> res = new List<Attachments>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Attachments(p));
        }
        return res;
    }
    
    private static List<Notes> arrayOfNotes(System.JSONParser p) 
    {
        List<Notes> res = new List<Notes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) 
        {
            res.add(new Notes(p));
        }
        return res;
    }
    
}