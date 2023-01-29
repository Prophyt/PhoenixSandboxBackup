public without sharing class IntegrationUtilities 
{
    public static boolean sandbox;
    public static boolean IsSandbox()
    {
        if(sandbox == null)
            sandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        
        return sandbox;
    }
    public static string getCRONExpression(Datetime dt) 
    {
		return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
	}
    public static string getBaseUrl()
    {
        if(IntegrationUtilities.IsSandbox() == true)
            return 'https://meshstage.smsassist.com';
        else
            return 'https://meshlive.smsassist.com';
    }

    public static HttpRequest requestBuilder(string method, string endpoint, string integration, string postBody)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type' , 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(60000);
        
        if(integration == 'SMS Assist')
        {
            string headerKey = SMSAssistAuthorization().replaceAll('"','');
            req.setHeader('Authorization', 'Bearer ' + headerKey);
            system.debug(headerKey);
        }

        
        if(!string.isBlank(postBody))
            req.setBody(postBody);
        
        return req;
    }
	public static string SMSAssistAuthorization()
    {    
        SMS_Assist_Settings__c settings = [SELECT Id,
                                           ClientId__c,
                                           Username__c,
                                           Password__c,
                                           Staging_Client_ID__c,
                                           Staging_Username__c,
                                           Staging_Password__c
                                           FROM SMS_Assist_Settings__c];
        
        string baseUrl = getBaseUrl();
        string endPoint = baseUrl + '/auth/token';
        String userName = IsSandbox() == true ? settings.Staging_Username__c : settings.Username__c;
        String password = IsSandbox() == true ? settings.Staging_Password__c : settings.Password__c;
        
        String requestBody = 'username=' + userName +'&password='+ password + '&grant_type=password';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setMethod('POST');
        req.setEndPoint(endPoint);
        req.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization' , authorizationHeader);        
        req.setBody(requestBody);
        req.setTimeout(120000);
        string accessToken = '';
        if(!Test.isRunningTest())
        {
            res = http.send(req);
            System.debug(res.getBody());
            accessToken = res.getBody();
        }
        return accessToken;
    }
}