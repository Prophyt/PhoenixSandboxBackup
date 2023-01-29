@RestResource(urlMapping='/Webhook')
global class WebhookListner {
    
    @HttpPost
    global static void handlePost(){
        try{
            
            RestRequest request = RestContext.request;
            system.debug('<---request--->'+request);
            map<String,Object> head = request.headers;
            system.debug('<---request.headers--->' +head);
            system.debug('requestBody--->'+request.requestBody.toString());
            map<String,Object> params = (map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());
            system.debug('params---->'+params);
            String SignData = head.get('Sign-Data').toString();
            system.debug('SignData-------'+SignData);
            
            //String accessToken = ProcessServiceChannelRequest.ReturnAccessToken();
            //system.debug('accessToken-------'+accessToken);
            
           /*String endPoint = 'https://sb2api.servicechannel.com/v3/NotificationSubscriptions/SigningKey';
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
            Http http = new Http();
            httpReq.setMethod('GET');
            httpReq.setEndPoint(endPoint);
            httpReq.setHeader('Content-Type' , 'application/json');
            //httpReq.setBody(body);
            httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
            httpRes = http.send(httpReq);
            system.debug('httpRes-----------'+httpRes);
            system.debug('httpRes-----------'+httpRes.getBody());
            string skey = httpRes.getBody().replace('{"Key":"','').replace('"}',''); */
            
            string skey = '4be808c4b4525829e22b232121bfac61d6a54bfa53f5851cc71de493416d73e0d05d8fdd662d80debaef721574cbedf60d76b6c665a80182d53437ff9e34198c';
            Integration_Message__c IntegrationMessage = new Integration_Message__c(
                Package__c=request.requestBody.toString(),Header__c='SignData'+SignData,
                Integration_Source__c='ServiceChannel');
            insert IntegrationMessage;
            //Integration_Message__c IntegrationMessage1 = new Integration_Message__c(Package__c=request.requestBody.toString(),Header__c='key'+skey);
            //insert IntegrationMessage1;  
            
      
            //test sign key
            string secret=skey; // '6e329c166f6536f86297f4a93415861899f33e6d73589c92ad8285f34668cdbf46ed30906ca17882fa64adf501bfa6bea0fffe88472eec4a5f1badc021c1fd47'; //Hex Key
            
            //production sign key
            //secret = '7f7928b2135c608bb51729c0525ad4b86421bb12b1493eba410184921c6bd81aa3414f1628e4ccc4ac34298a0c9026ee53f679dd130a60472dadfd858b2e0222';
            
            String signature =SignData; //'acf36fa939dbbb8e05e94814574caaf64ca73cae0701ba435f1ee0768830ca8c';
           
            Blob hmac = Crypto.generateMac('HMACSHA256', blob.valueOf(request.requestBody.toString()), 
                                           EncodingUtil.base64Decode(skey));  
            
            system.debug('hmac encode---->'+EncodingUtil.base64Encode(hmac));
            
            /*Boolean verified = Crypto.verifyHMac('HmacSHA256', Blob.valueOf(request.requestBody.toString()), EncodingUtil.base64Decode(skey), hmac);
            System.debug('***************'+verified);
            System.debug(EncodingUtil.convertToHex (hmac));
            //System.debug(SignData);

            /*byte[] secretKey = Encoding.UTF8.GetBytes(skey);
            HMACSHA256 hmac = new HMACSHA256(secretKey);
            hmac.Initialize();
            
            
            byte[] bytes = Encoding.UTF8.GetBytes(SignData);
            byte[] rawHmac = hmac.ComputeHash(bytes);
            string hex = BitConverter.ToString(rawHmac).Replace('-','');*/
        
            //System.debug(EncodingUtil.base64Encode(SignData));
            //system.debug('::hmac::'+EncodingUtil.convertToHex(hmac));
            /*Integration_Message__c IntegrationMessage3 = new Integration_Message__c(Package__c=hmac+'',Header__c=EncodingUtil.convertToHex(hmac)+'');
            insert IntegrationMessage3;*/
       }catch(exception e){            
          system.debug('exception--->'+e.getMessage()+'--line no--->'+e.getLineNumber());
        }
        
        
        //String HMACSHA256 = HMAC.generateSignature(httpRes.getBody());
        
      

        
        
    }
     
}