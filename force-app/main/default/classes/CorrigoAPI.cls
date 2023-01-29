public without sharing class CorrigoAPI 
{
	public static CorrigoOAuthResponse authenticate()
    {
        Corrigo_Settings__c settings = Corrigo_Settings__c.getOrgDefaults();
        string endpoint = settings.OAuth_URL__c;
        String clientId = settings.Client_ID__c;
        String secret = settings.Client_Secret__c;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setMethod('POST');
        req.setEndPoint(endPoint);
        req.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        string body = 'grant_type=' + settings.Grant_Type__c;
        body += '&client_id=' + clientId;
        body += '&client_secret=' + secret;
        req.setBody(body);	
        res = http.send(req);
        system.debug(res.getBody());
        CorrigoOAuthResponse oAuth = (CorrigoOAuthResponse)System.JSON.deserialize(res.getBody(), CorrigoOAuthResponse.class);
        system.debug(oAuth.access_token);
        return oAuth;
    }
    public static List<CorrigoWorkOrder> getWorkOrders()
    {
        return new List<CorrigoWorkOrder>();
    }

    public class CorrigoOAuthResponse
    {
        public string access_token;
        public string token_type;
        public integer expires_in;
    }
    public class CorrigoError
    {
        public integer Code;
        public string Message;
        public string MessageId;
        public List<InputValidationError> ValidationErrors;
    }
    public class InputValidationError
    {
        public string FieldName;
        public string Message;
        public string ErrorType;
    }
    
    
    public class CorrigoWorkOrderSearch
    {
        public CorrigoParameters Parameters;
        public string MessageId;
    }
    public class CorrigoParameters
    {
        public string WorkOrderNumber;
        public integer CustomerId;
        public integer BranchId;
        public CorrigoDate Created;
        public CorrigoDate AcknowledgeBy;
        public CorrigoDate OnSiteBy;
        public CorrigoDate DueDate;
        public CorrigoDate LastUpdate;
        public List<String> Statuses;
    }
    public class CorrigoDate
    {
        public DateTime xFrom; //these are "YYYY-MM-DDTHH:MM:SS.000Z" format and the real property name is "From"
        public DateTime To;
    }
    
    
    public class CorrigoWorkOrders
    {
        public List<CorrigoWorkOrder> WorkOrders;
        public string MessageId;
    }
    public class CorrigoWorkOrder
    {
        public string WorkOrderNumber;
        public integer WorkOrderId;
        public integer BranchId;
        public string xType;
        public CorrigoSLA Sla;
        public string Status;
        public CorrigoCustomer Customer;
        public DateTime LastUpdate;
        public DateTime Created;
    }
    public class CorrigoSLA
    {
        public DateTime DueDate;
        public DateTime OnSiteBy;
        public DateTime AcknowledgeBy;
        public integer PriorityId;
        public string PriorityName;
        public boolean IsEmergency;
    }
    public class CorrigoCustomer
    {
        public integer Id;
        public string Name;
    }

}