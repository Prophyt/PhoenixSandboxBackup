public class SMSAssistSettings
{
    public static string ReturnAccessToken()
    {    
        SMS_Assist_Settings__c SAsettings = new SMS_Assist_Settings__c();
        SAsettings = [Select id,ClientId__c,Password__c,Username__c from SMS_Assist_Settings__c];
        String endPoint = 'https://meshlive.smsassist.com/auth/token';
        String USNme = SAsettings.Username__c;
        String Pass = SAsettings.Password__c;
        String requestBody = 'username=' + USNme +'&password='+ Pass +'&grant_type=password';
        Blob headerValue = Blob.valueOf(USNme + ':' + Pass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        string accessToken = '';
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Authorization' , authorizationHeader);        
        httpReq.setBody(requestBody); 
        if(!Test.isRunningTest())
        {
            httpRes = http.send(httpReq);
            System.debug(httpRes.getBody());
            /*
            Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());            
            String accessToken = (String)response_Map.get('access_token');
            system.debug('accessToken-------------'+accessToken);
            */
            accessToken = httpRes.getBody();
        }
        return accessToken;
    }
    public static void getWO()
    {
        //System.debug(ReturnAccessToken().replaceAll('"',''));
        String endPoint1 = 'https://meshlive.smsassist.com/api/v1.0/workorder/reactive/list';
        //String endPoint1 = 'https://meshstage.smsassist.com/clientapi/v1/AffiliateWebHook/Get?WebHookId=6152aa0a4658ec8a0bc34aad';
        HttpRequest httpReq1 = new HttpRequest();
        HttpResponse httpRes1 = new HttpResponse();
        Http http1 = new Http();
        httpReq1.setMethod('GET');
        httpReq1.setEndPoint(endPoint1);
        //httpReq1.setTimeout(120000);
        httpReq1.setHeader('Content-Type' , 'application/json');
        httpReq1.setHeader('Accept', 'application/json');
        httpReq1.setHeader('Authorization' , 'Bearer ' + ReturnAccessToken().replaceAll('"',''));
        if(!Test.isRunningTest())
        {
            httpRes1 = http1.send(httpReq1);
            system.debug('httpRes1-----------'+httpRes1.getBody());
        }
    }
}