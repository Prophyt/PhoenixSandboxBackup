public class ProcessServiceChannelRequest 
{    
    public static string ReturnAccessToken()
    {    
        //Service_Channel_Settings__c SCsettings = new Service_Channel_Settings__c();
        //SCsettings = [Select id,ClientId__c,Password__c,Secret_Key__c,Username__c from Service_Channel_Settings__c];
        
        //String client_Id = SCsettings.ClientId__c;
        //String consumer_Secret = SCsettings.Secret_Key__c;
        Customer_Settings__mdt SCsettings = new Customer_Settings__mdt ();
        SCsettings = [Select AccountId_Customer__c,ClientId__c,Username__c,Password__c,Secret_Key__c,Url_Endpoint__c from Customer_Settings__mdt where developername = 'PhoenixET_ServiceChannel'];
        String client_Id = SCsettings.ClientId__c;
        String consumer_Secret = SCsettings.Secret_Key__c;
        String Url_Endpoint = SCsettings.Url_Endpoint__c;
        
        String encodedString = EncodingUtil.base64Encode(Blob.valueOf(client_Id+':'+consumer_Secret));
        String endPoint = Url_Endpoint+'/oauth/token';
        //String endPoint = 'https://sb2login.servicechannel.com/oauth/token';
        String USNme = SCsettings.Username__c;
        String Pass = SCsettings.Password__c;
        String requestBody = 'username=' + USNme +'&password='+ Pass +'&grant_type=password';
  
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Authorization' , 'Basic '+encodedString);        
        httpReq.setBody(requestBody);	
        httpRes = http.send(httpReq);
  
        Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());            
        String accessToken = (String)response_Map.get('access_token');
        system.debug('accessToken-------------'+accessToken);
        return accessToken;
    }
    public static void getWO(){
        String accessToken = ReturnAccessToken();
        String endPoint1 = 'https://sb2api.servicechannel.com/v3/workorders/185984882';
        HttpRequest httpReq1 = new HttpRequest();
        HttpResponse httpRes1 = new HttpResponse();
        Http http1 = new Http();
        httpReq1.setMethod('GET');
        httpReq1.setEndPoint(endPoint1);
        httpReq1.setHeader('Content-Type' , 'application/json');
        httpReq1.setHeader('Accept', 'application/json');
        httpReq1.setHeader('Authorization' , 'Bearer '+accessToken);  	   
        httpRes1 = http1.send(httpReq1);
        system.debug('httpRes1-----------'+httpRes1.getBody());
        String IsCheckData = httpRes1.getBody();
        system.debug('IsCheckData----------'+IsCheckData); 
        Map<String, Object> ResponseDataMap = (Map<String, Object>)JSON.deserializeUntyped(IsCheckData);  
        system.debug('ResponseDataMap----------'+ResponseDataMap);
        system.debug('ResponseDataMap----------'+ResponseDataMap.get('CheckInDeniedReason'));
        if(ResponseDataMap.get('CheckInDeniedReason') != null){
            system.debug('In Creating Case');
            Case cs = new Case();
            cs.Priority = 'Normal';
            cs.Status = 'New';
            cs.Origin = 'Third Party';
            cs.Description = ResponseDataMap.get('CheckInDeniedReason').toString();
            //insert cs; 
        } 
    }
    
    public static void test(){
        string strbody = '{"Object":{"Id":188291754,"Number":"188291754","PurchaseNumber":"188291754","SubscriberId":2014917243,"ProviderId":2000087045,"ProviderName":"General Parts Corporate Dispatch","LocationId":2006137159,"LocationName":"GP-API test","LocationStoreId":"106","Status":{"Primary":"OPEN","Extended":""},"Caller":"SC-Dev1","CreatedBy":"SC-Dev1","CallDate":"2021-09-27T06:47:29","Priority":"P3 - 24 HOURS","Trade":"ELECTRICAL","ScheduledDate":"2021-09-28T06:47:29","UpdatedDate":"2021-09-27T07:01:03.407","ScheduledDate_DTO":"2021-09-28T06:47:29-04:00","ExpirationDate":"2021-09-28T06:47:29","Description":"EXECUTIVE/MANAGERS OFFICE / Lighting-Inside / Light(s) / Row of lights are out / List the area where the row of lights are out.: sd / Moving down the electrical panel, check for any partially tripped breakers, if you find a breaker that is tripped, move the switch to the off position completely, then back to the on position. (There may be electrical panels in more than one location).: Yes / The store is responsible to check and replace all bulbs/lamps that are out. Bulbs/lamps that are out continue to draw power, causing pre-mature ballasts failure. Have the burnt out bulbs/lamps been replaced?:  No / sd","Category":"REPAIR","Nte":500.0,"CurrencyAlphabeticalCode":"USD","ProblemCode":"Row of lights are out","Source":"dashboard1775","Notes":[{"Id":1146890961,"Number":1,"NoteData":"Service Request has been dispatched to General Parts Corporate Dispatch via Servicechannel@generalparts.com with 500.00 NTE.","DateCreated":"2021-09-27T07:01:00","ScheduledDate":"2021-09-28T06:47:29","ActionRequired":false,"MailedTo":"","CreatedBy":"SC-Dev1","CreatedByUser":{"UserName":"SC-Dev1","FullName":"SC-Dev1","SubscriberId":2014917243}}],"Attachments":[],"LinkedWorOrderIds":[]},"Type":"WoRootNotification","Action":"UPDATE","EventType":"WorkOrderNoteAdded","Version":1}';
        
        string secret = 'bc9d35af6f5c25e0187588383af97e238bd6f262e31440afa43c224913a1f883ade242e6cb26d5fadba6f3dede8a23afc1e29af16026afe1b1f747bf806f35c6';
        string secretdec = string.valueOf(EncodingUtil.base64Decode(secret));
        system.debug('secretdec--->'+secretdec);
        
        string data1 = 'aNQVSjH4LUaFDqGYXxVcGJu1Iv0t+KjqUHvQFRIvmQA=';
        system.debug('data1--->'+data1);

        string signdata = EncodingUtil.base64Encode(blob.valueOf(data1));
        system.debug('signdata--->'+signdata);
        try{
            /*Blob hmac = Crypto.generateMac('HMACSHA256', blob.valueOf(strbody), 
                                           EncodingUtil.base64Decode(secret)); */
            
             Blob hmac = Crypto.generateMac('HMACSHA256', blob.valueOf(strbody), 
                                            blob.valueOf(secretdec)); 
            string hmacstr  = string.valueOf(hmac);
            
            system.debug('::hmacstr::'+hmacstr);
            system.debug('::hmac::'+hmac);
            system.debug('::hmac::'+EncodingUtil.convertToHex(hmac)); 
            
             //Crypto.generateMac('SHA256',);
            /*Blob hmac = Crypto.generateMac('HMACSHA256', blob.valueOf(strbody),blob.valueOf(secret));      
            system.debug('::hmac::'+hmac);        
            system.debug('::sign data::'+'aNQVSjH4LUaFDqGYXxVcGJu1Iv0t+KjqUHvQFRIvmQA=');        
            system.debug('::hmac::'+EncodingUtil.convertToHex(hmac));        */
            
            //value to process
            /*Blob data= Blob.valueOf(strbody);                       
            Blob hash = Crypto.generateDigest('SHA-256', data);
            system.debug('hash->'+hash);
            
            //Convert SHA-256 Hash data to String
            String encryptedString =EncodingUtil.convertToHex(hash);
            system.debug('encryptedString->'+encryptedString);*/
            
        }catch(exception e){
            system.debug('error msg--->'+e.getMessage());        
        }
    }
    
    
}