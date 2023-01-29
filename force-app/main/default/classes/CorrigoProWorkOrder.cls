public class CorrigoProWorkOrder 
{
    public Details Details {get;set;}
    public Body body {get;set;} 
    public class Header 
    {
        public Integer WorkOrderId {get;set;} 
        public Integer BranchId {get;set;} 
        public Sender Sender {get;set;} 
        public String Action {get;set;} 
        public String ActionDate {get;set;} 
        public String ApiVersion {get;set;} 
        public String MessageId {get;set;} 
        
        public Header(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'WorkOrderId') {
                            WorkOrderId = parser.getIntegerValue();
                        } else if (text == 'BranchId') {
                            BranchId = parser.getIntegerValue();
                        } else if (text == 'Sender') {
                            Sender = new Sender(parser);
                        } else if (text == 'Action') {
                            Action = parser.getText();
                        } else if (text == 'ActionDate') {
                            ActionDate = parser.getText();
                        } else if (text == 'ApiVersion') {
                            ApiVersion = parser.getText();
                        } else if (text == 'MessageId') {
                            MessageId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Header consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    public class Body 
    {
        public Details Details {get;set;} 
        public List<Attachments> Attachments {get;set;} 
        public Header Header {get;set;} 
        
        public Body(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Details') {
                            Details = new Details(parser);
                        } else if (text == 'Attachments') {
                            Attachments = arrayOfAttachments(parser);
                        } else if (text == 'Header') {
                            Header = new Header(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Body consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }    
    public class Details 
    {
        public String WorkOrderNumber {get;set;} 
        public Integer WorkOrderId {get;set;} 
        public Integer BranchId {get;set;} 
        //public Object IVRInfo {get;set;} 
        public Schedule Schedule {get;set;} 
        public String Type {get;set;} 
        public WorkType WorkType {get;set;} 
        public String AccompanyingMessage {get;set;} 
        public Nte Nte {get;set;} 
        public Sla Sla {get;set;} 
        public WorkDetails WorkDetails {get;set;} 
        //public Object CompletionDetails {get;set;} 
        public Contact Contact {get;set;} 
        public ServiceLocation ServiceLocation {get;set;} 
        public Model Customer {get;set;} 
        public Boolean IsPrebilled {get;set;} 
        public Boolean IsWarranty {get;set;} 
        public String Created {get;set;} 
        public String LastUpdate {get;set;} 
        public String Feedback {get;set;} 
        public String Status {get;set;} 
        public String Currency_Z {get;set;} // in json: Currency
        public String TimeZone {get;set;} 
        public String WorkZoneNumber {get;set;} 
        public String InternalNote {get;set;} 
        //public Object AdditionalFields {get;set;} 
        public String LastAction {get;set;} 
        public String IsmStatus {get;set;} 
        
        public Details(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'WorkOrderNumber') {
                            WorkOrderNumber = parser.getText();
                        } else if (text == 'WorkOrderId') {
                            WorkOrderId = parser.getIntegerValue();
                        } 
                        else if (text == 'BranchId') 
                        {
                            BranchId = parser.getIntegerValue();
                        } 
                        /*
                        else if (text == 'IVRInfo') 
                        {
                            IVRInfo = parser.getText();
                        } 
                        */
                        else if (text == 'Schedule') {
                            Schedule = new Schedule(parser);
                        } else if (text == 'Type') {
                            Type = parser.getText();
                        } else if (text == 'WorkType') {
                            WorkType = new WorkType(parser);
                        } else if (text == 'AccompanyingMessage') {
                            AccompanyingMessage = parser.getText();
                        } else if (text == 'Nte') {
                            Nte = new Nte(parser);
                        } else if (text == 'Sla') {
                            Sla = new Sla(parser);
                        } else if (text == 'WorkDetails') {
                            WorkDetails = new WorkDetails(parser);
                        } 
                        
                        /*else if (text == 'CompletionDetails') 
                        {
                            CompletionDetails = parser.getText();
                        } 
						*/
                        else if (text == 'Contact') {
                            Contact = new Contact(parser);
                        } else if (text == 'ServiceLocation') {
                            ServiceLocation = new ServiceLocation(parser);
                        } else if (text == 'Customer') {
                            Customer = new Model(parser);
                        } else if (text == 'IsPrebilled') {
                            IsPrebilled = parser.getBooleanValue();
                        } else if (text == 'IsWarranty') {
                            IsWarranty = parser.getBooleanValue();
                        } else if (text == 'Created') {
                            Created = parser.getText();
                        } else if (text == 'LastUpdate') {
                            LastUpdate = parser.getText();
                        } else if (text == 'Feedback') {
                            Feedback = parser.getText();
                        } else if (text == 'Status') {
                            Status = parser.getText();
                        } else if (text == 'Currency') {
                            Currency_Z = parser.getText();
                        } else if (text == 'TimeZone') {
                            TimeZone = parser.getText();
                        } else if (text == 'WorkZoneNumber') {
                            WorkZoneNumber = parser.getText();
                        } else if (text == 'InternalNote') {
                            InternalNote = parser.getText();
                        }
                        /*
                        else if (text == 'AdditionalFields') 
                        {
                            AdditionalFields = parser.getText();
                        }
						*/
                        else if (text == 'LastAction') {
                            LastAction = parser.getText();
                        } else if (text == 'IsmStatus') {
                            IsmStatus = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }    
    
    public class Address 
    {
        public String City {get;set;} 
        public String Country {get;set;} 
        public String State {get;set;} 
        public String Street1 {get;set;} 
        public String Street2 {get;set;} 
        public String PostalCode {get;set;} 
        
        public Address(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'City') {
                            City = parser.getText();
                        } else if (text == 'Country') {
                            Country = parser.getText();
                        } else if (text == 'State') {
                            State = parser.getText();
                        } else if (text == 'Street1') {
                            Street1 = parser.getText();
                        } else if (text == 'Street2') {
                            Street2 = parser.getText();
                        } else if (text == 'PostalCode') {
                            PostalCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class WorkType 
    {
        public String Category {get;set;} 
        public Integer Id {get;set;} 
        public String Name {get;set;} 
        public Boolean IsVisit {get;set;} 
        
        public WorkType(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Category') {
                            Category = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Name') {
                            Name = parser.getText();
                        } else if (text == 'IsVisit') {
                            IsVisit = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'WorkType consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    public class Procedure
    {
        public integer Id;
        public integer Order;
        public string Name;
        public boolean AllowMarkNotApplicable;
        public string Status;
        public integer AssetId;
        public string AssetName;
        public List<Step> Steps;
        
        public Procedure(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'Order') 
                        {
                            Order = parser.getIntegerValue();
                        } 
                        else if (text == 'Name') 
                        {
                            Name = parser.getText();
                        } 
                        else if (text == 'Id') 
                        {
                            Id = parser.getIntegerValue();
                        } 
                        else if (text == 'Status') 
                        {
                            Status = parser.getText();
                        } 
                        else if (text == 'AssetName') 
                        {
                            AssetName = parser.getText();
                        } 
                        else if (text == 'AllowMarkNotApplicable') 
                        {
                            AllowMarkNotApplicable = parser.getBooleanValue();
                        } 
                        else if (text == 'Steps')
                        {
                            Steps = arrayOfSteps(parser);
                        }
                        else 
                        {
                            System.debug(LoggingLevel.WARN, 'Procedure consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }    
	public class Step
    {
        public integer Id;
        public integer Order;
        public boolean IsRequired;
        public string Description;
        public string StepType;
        public string Label;
        public string DataType;
        public string MoneyCulture;
		public string Status;
        public string Value;
        public string Comment;
        public Step(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'Order') 
                        {
                            Order = parser.getIntegerValue();
                        } 
                        else if (text == 'Description') 
                        {
                            Description = parser.getText();
                        } 
                        else if (text == 'Id') 
                        {
                            Id = parser.getIntegerValue();
                        } 
                        else if (text == 'Status') 
                        {
                            Status = parser.getText();
                        } 
                        else if (text == 'StepType') 
                        {
                            StepType = parser.getText();
                        } 
                        else if (text == 'IsRequired') 
                        {
                            IsRequired = parser.getBooleanValue();
                        } 
                        else if (text == 'Label')
                        {
                            Label = parser.getText();
                        }
                        else if(text == 'DataType')
                        {
                            DataType = parser.getText();
                        }
                        else 
                        {
                            System.debug(LoggingLevel.WARN, 'Procedure consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }        
    }

    public class WorkDetails 
    {
        public List<CheckList> CheckList {get;set;} 
        public List<Procedure> Procedures {get;set;} 
        public List<Assets> Assets {get;set;} 
        public String VisitInfo {get;set;} 
        
        public WorkDetails(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) 
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) 
                    {
                        if (text == 'CheckList') 
                        {
                            CheckList = arrayOfCheckList(parser);
                        } 
                        else if (text == 'Procedures') 
                        {
                            Procedures = arrayOfProcedures(parser);
                        } else if (text == 'Assets') {
                            Assets = arrayOfAssets(parser);
                        } else if (text == 'VisitInfo') {
                            VisitInfo = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'WorkDetails consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Sla 
    {
        public String DueDate {get;set;} 
        public String OnSiteBy {get;set;} 
        public String AcknowledgeBy {get;set;} 
        public Integer PriorityId {get;set;} 
        public String PriorityName {get;set;} 
        public Boolean IsEmergency {get;set;} 
        
        public Sla(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'DueDate') {
                            DueDate = parser.getText();
                        } else if (text == 'OnSiteBy') {
                            OnSiteBy = parser.getText();
                        } else if (text == 'AcknowledgeBy') {
                            AcknowledgeBy = parser.getText();
                        } else if (text == 'PriorityId') {
                            PriorityId = parser.getIntegerValue();
                        } else if (text == 'PriorityName') {
                            PriorityName = parser.getText();
                        } else if (text == 'IsEmergency') {
                            IsEmergency = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Sla consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public CorrigoProWorkOrder(JSONParser parser) 
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'body') {
                        body = new Body(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'CorrigoProAPI consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Attachments 
    {
        public Sender Sender {get;set;} 
        public Integer Size {get;set;} 
        public String SentAt {get;set;} 
        public Integer DocumentType {get;set;} 
        public String Title {get;set;} 
        public String Subtype {get;set;} 
        public String Id {get;set;} 
        public String Name {get;set;} 
        public String MimeType {get;set;} 
        
        public Attachments(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Sender') {
                            Sender = new Sender(parser);
                        } else if (text == 'Size') {
                            Size = parser.getIntegerValue();
                        } else if (text == 'SentAt') {
                            SentAt = parser.getText();
                        } else if (text == 'DocumentType') {
                            DocumentType = parser.getIntegerValue();
                        } else if (text == 'Title') {
                            Title = parser.getText();
                        } else if (text == 'Subtype') {
                            Subtype = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else if (text == 'Name') {
                            Name = parser.getText();
                        } else if (text == 'MimeType') {
                            MimeType = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attachments consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Contact 
    {
        public String FullName {get;set;} 
        public String ContactAt {get;set;} 
        public List<String> Phones {get;set;} 
        public List<String> Emails {get;set;} 
        
        public Contact(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'FullName') {
                            FullName = parser.getText();
                        } else if (text == 'ContactAt') {
                            ContactAt = parser.getText();
                        } else if (text == 'Phones') {
                            Phones = arrayOfString(parser);
                        } else if (text == 'Emails') {
                            Emails = arrayOfString(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Contact consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Geo 
    {
        public Double Latitude {get;set;} 
        public Double Longitude {get;set;} 
        
        public Geo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Latitude') {
                            Latitude = parser.getDoubleValue();
                        } else if (text == 'Longitude') {
                            Longitude = parser.getDoubleValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Geo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Sender 
    {
        public String Name {get;set;} 
        public String Phone {get;set;} 
        public String Type {get;set;} 
        
        public Sender(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Name') {
                            Name = parser.getText();
                        } else if (text == 'Phone') {
                            Phone = parser.getText();
                        } else if (text == 'Type') {
                            Type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Sender consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class CheckList 
    {
        public Integer SortingIndex {get;set;} 
        public String Description {get;set;} 
        public Integer Id {get;set;} 
        public String Comment {get;set;} 
        public String Exception_Z {get;set;} // in json: Exception
        public Boolean IsDone {get;set;} 
        
        public CheckList(JSONParser parser) 
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'SortingIndex') {
                            SortingIndex = parser.getIntegerValue();
                        } else if (text == 'Description') {
                            Description = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Comment') {
                            Comment = parser.getText();
                        } else if (text == 'Exception') {
                            Exception_Z = parser.getText();
                        } else if (text == 'IsDone') {
                            IsDone = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'CheckList consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Assets 
    {
        public Integer Id {get;set;} 
        public String Path {get;set;} 
        public String Task {get;set;} 
        public String AssetName {get;set;} 
        public String Comment {get;set;} 
        public String Type {get;set;} 
        public Integer TypeId {get;set;} 
        public Model Model {get;set;} 
        
        public Assets(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Path') {
                            Path = parser.getText();
                        } else if (text == 'Task') {
                            Task = parser.getText();
                        } else if (text == 'AssetName') {
                            AssetName = parser.getText();
                        } else if (text == 'Comment') {
                            Comment = parser.getText();
                        } else if (text == 'Type') {
                            Type = parser.getText();
                        } else if (text == 'TypeId') {
                            TypeId = parser.getIntegerValue();
                        } else if (text == 'Model') {
                            Model = new Model(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Assets consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ServiceLocation 
    {
        public Integer OccupantID {get;set;} 
        public Address Address {get;set;} 
        public Geo Geo {get;set;} 
        public String OccupantName {get;set;} 
        public String SpaceName {get;set;} 
        public Integer SpaceId {get;set;} 
        
        public ServiceLocation(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'OccupantID') {
                            OccupantID = parser.getIntegerValue();
                        } else if (text == 'Address') {
                            Address = new Address(parser);
                        } else if (text == 'Geo') {
                            Geo = new Geo(parser);
                        } else if (text == 'OccupantName') {
                            OccupantName = parser.getText();
                        } else if (text == 'SpaceName') {
                            SpaceName = parser.getText();
                        } else if (text == 'SpaceId') {
                            SpaceId = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ServiceLocation consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Schedule 
    {
        public String ScheduledStart {get;set;} 
        public String Pte {get;set;} 
        
        public Schedule(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ScheduledStart') {
                            ScheduledStart = parser.getText();
                        } else if (text == 'Pte') {
                            Pte = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Schedule consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Model 
    {
        public Integer Id {get;set;} 
        public String Name {get;set;} 
        
        public Model(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'Name') {
                            Name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Model consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Nte 
    {
        public Decimal Amount {get;set;} 
        public Decimal Quote {get;set;} 
        public Boolean IsQuoteMultiline {get;set;} 
        public String DtLastUpdate {get;set;} 
        
        public Nte(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Amount') {
                            Amount = parser.getIntegerValue();
                        } else if (text == 'Quote') {
                            Quote = parser.getDecimalValue();
                        } else if (text == 'IsQuoteMultiline') {
                            IsQuoteMultiline = parser.getBooleanValue();
                        } else if (text == 'DtLastUpdate') {
                            DtLastUpdate = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Nte consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static CorrigoProWorkOrder parse(String json) 
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new CorrigoProWorkOrder(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) 
    {
        Integer depth = 0;
        do 
        {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } 
        while (depth > 0 && parser.nextToken() != null);
    }
    
    private static List<Procedure> arrayOfProcedures(System.JSONParser p)
    {
        List<Procedure> res = new List<Procedure>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) 
        {
            res.add(new Procedure(p));
        }
        return res;
    }
    private static List<Step> arrayOfSteps(System.JSONParser p)
    {
        List<Step> res = new List<Step>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) 
        {
            res.add(new Step(p));
        }
        return res;        
    }
    private static List<CheckList> arrayOfCheckList(System.JSONParser p) 
    {
        List<CheckList> res = new List<CheckList>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) 
        {
            res.add(new CheckList(p));
        }
        return res;
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
    
    private static List<String> arrayOfString(System.JSONParser p) 
    {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
    private static List<Assets> arrayOfAssets(System.JSONParser p) 
    {
        List<Assets> res = new List<Assets>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Assets(p));
        }
        return res;
    }
    
    public static Case createCaseFromWorkOrder(Integration_Message__c m)
    {
        CorrigoProWorkOrder wo = (CorrigoProWorkOrder)System.JSON.deserialize(m.Package__c, CorrigoProWorkOrder.class);
        system.debug(wo);
        CorrigoProWorkOrder.Details wod = wo.body == null ? wo.Details : wo.body.Details;
        string woNumber = wod.WorkOrderNumber;
        string accountSiteNumber = wod.WorkZoneNumber != null && !string.isBlank(wod.WorkZoneNumber) ? wod.WorkZoneNumber : '';
        
        /* when we are ready we turn this on
        if(wod.WorkType.Category != 'Request')
            return null;
        */
        if(wod.Status.toLowerCase() != 'new')
            return null;
        
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
                                    WHERE Customer_WO__c = :woNumber
                                    AND Customer_WO__c != null
                                    AND X3rd_Party_System__c = 'CorrigoPro'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1];
        
        if(!existingCases.isEmpty())
        {
            //found existing case by Work Order Number
            return existingCases[0];
        }
        else
        {
            //We only need to create cases for Work Orders assigned to Specialty of “N-Commissioning”.
            //PET_152
            List<Account> accounts = [SELECT Id,
                                      Name
                                      FROM Account
                                      WHERE Site_Number__c = :accountSiteNumber
                                      AND Site_Number__c != ''
                                      AND Site_Number__c != null
                                      LIMIT 1];
                                      //WHERE Third_Party_FM_Id__c = :string.valueOf(wod.Customer.Id)];
            
            
            Id queueId = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Albertsons' LIMIT 1].Id;
            
            //create a new case
            Case c = new Case();
            c.AccountId = accounts.isEmpty() ? null : accounts[0].Id;
            c.OwnerId = queueId;
            c.Customer_WO__c = wod.WorkOrderNumber;
            c.X3rd_Party_WO_Id__c = string.valueOf(wod.WorkOrderId);
            c.X3rd_Party_System__c = 'CorrigoPro';
            c.Integration_Message__c = m.Id;
            c.Subject = 'New CorrigoPro Case';
            c.Description = wod.AccompanyingMessage;
            c.Status = 'New';
            c.Origin = 'Third Party';
            insert c;
            return c;
        }
    }
}