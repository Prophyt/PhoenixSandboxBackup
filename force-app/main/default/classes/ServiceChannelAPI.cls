public without sharing class ServiceChannelAPI 
{
    private static Log logger = Log.get();
    //this is all ServiceChannel and needs to be moved into ServiceChannel API
    @future(callout=true) 
    public static void updateWorkOrder(String caseId)
    { 
        Customer_Settings__mdt customerSettings = [SELECT AccountId_Customer__c,
                                                   ClientId__c,
                                                   Username__c,
                                                   Password__c,
                                                   Secret_Key__c,
                                                   Url_Endpoint__c 
                                                   FROM Customer_Settings__mdt 
                                                   WHERE DeveloperName = 'PhoenixET_ServiceChannel'];
        
        String clientId = customerSettings.ClientId__c;
        String consumerSecret = customerSettings.Secret_Key__c;
        String endpoint = customerSettings.Url_Endpoint__c;
        
        Case c = [SELECT Id, 
                  AccountId,
                  Account.Name,
                  Parent_Account__c,
                  Parent_Account__r.Name,
                  X3rd_Party_System__c, 
                  X3rd_Party_WO_Id__c, 
                  X3rd_Party_Update_Error__c,
                  Description, 
                  Resolution__c,
                  Resolution_Note__c, 
                  Status,
                  Integration_Message__c 
                  FROM Case 
                  WHERE Id = :caseId];
        
        if(c.Integration_Message__c != null)
        {
            Integration_Message__c msg = [SELECT Id,
                                          Integration_Source__c 
                                          FROM Integration_Message__c 
                                          WHERE Id = :c.Integration_Message__c];
            
            system.debug('Integration Message: ' + msg);
            
            if(msg.Integration_Source__c == 'ServiceChannel' || c.X3rd_Party_System__c == 'ServiceChannel')
            {
                String tpId = c.X3rd_Party_WO_Id__c; //thirdPartyId
                List<Case> caselist = new List<Case>();
                String resolutionNotes = c.Resolution_Note__c;
                String note = '{"Resolution": "' + resolutionNotes + '"' + '}';
                String accessToken = ProcessServiceChannelRequest.ReturnAccessToken();
                system.debug('accessToken-------'+accessToken);
                
                boolean isPetco = false;
                String body;

                string accountName = c.AccountId != null ? c.Account.Name : '';
                string parentAccountName = c.Parent_Account__c != null ? c.Parent_Account__r.Name : '';
                if((!string.isBlank(accountName) && accountName.containsIgnoreCase('petco')) || (!string.isBlank(parentAccountName) && parentAccountName.containsIgnoreCase('petco')))
                    isPetco = true;
                

                endpoint = 'https://api.servicechannel.com/v3/workorders/' + tpId + '/status';
                if(isPetco == true)
                {
                    if(c.Status == 'Accepted')
                    { 
                        body = '{"Status": {"Primary": "IN PROGRESS","Extended": "DISPATCH CONFIRMED"} }';
                    }
                    else if(c.Status != 'Accepted' && c.Resolution__c != null && c.Resolution__c.contains('Remotely Resolved'))
                    {
                        body = '{"Status": {"Primary": "COMPLETED","Extended": "COST AVOIDANCE"} }';                    
                    }
                    else if(c.Status != 'Accepted' && c.Resolution__c != null && c.Resolution__c.contains('Dispatched to Vendor'))
                    {
                        body = '{"Status": {"Primary": "COMPLETED","Extended": "DISPATCHED"} }';                    
                    }
                    else if(c.Status != 'Accepted' && c.Resolution__c != null)
                    {
                        body = '{"Status": {"Primary": "COMPLETED","Extended": "NO CHARGE"} }';
                    }
                }
                else
                {
                    if(c.Status == 'Accepted')
                    { 
                        body = '{"Status": {"Primary": "IN PROGRESS","Extended": "DISPATCH CONFIRMED"} }';
                    }
                    else if(c.Status != 'Accepted' && c.Resolution__c != null && c.Resolution__c.contains('Dispatched to Vendor'))
                    {
                        //PER PET-164 - Do NOTHING
                        return;
                    }
                    else if(c.Resolution__c != null && c.Resolution__c != '')
                    {
                        body = '{"Status": {"Primary": "COMPLETED","Extended": "NO CHARGE"} }';    
                    }
                }
                
                try
                {
                    //if we have not compiled a body its because it didnt match any rules, so we exit
                    if(string.isBlank(body))
                        return;
                    
                    system.debug('endPoint------'+endPoint);
                    HttpResponse response = HttpRequestMethod(endpoint,accessToken,body);
                    system.debug('httpRes-----------'+response);
                    system.debug('httpRes-----------'+response.getBody());
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    system.debug('responseMap: ' + responseMap);
                    string errorMessage = (String)responseMap.get('ErrorMessage');
                    
                    if(errorMessage != null)
                    {
                        if(errorMessage.length() >= 255)
                            errorMessage = errorMessage.Substring(0,255);
                        
                        c.X3rd_Party_Update_Error__c = errorMessage;
                        caselist.add(c);
                        update caselist;
                    }
                    
                    if(c.Status != 'Accepted')
                    {
                        if(response.toString().contains('StatusCode=200'))
                        {
                            endpoint = 'https://api.servicechannel.com/v3/workorders/' + tpId + '/resolution';
                            body = note;
                            HttpResponse response1 = HttpRequestMethodResolution(endpoint, accessToken, body);
                            Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                            system.debug('response_Map1' + responseMap1);
                            if(responseMap1.containsKey('Error'))
                            {
                                system.debug('Error?:' + responseMap1.get('Error'));
                                logger.publish((string)responseMap1.get('Error'), 'ServiceChannelAPI', LogSeverity.ERROR);
                            }
                        } 
                    }
                }
                catch(Exception ex)
                {
                    system.debug(ex);
                    logger.publish(ex.getMessage(), 'ServiceChannelAPI', LogSeverity.ERROR);
                }
            }
        }
        
    }
    public static HttpResponse HttpRequestMethod(String endPoint,String accessToken,String body)
    {
        //[B] this code does not belong here...needs moved eventually
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('PUT');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Content-Type' , 'application/json');
        httpReq.setBody(body);
        httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
        httpRes = http.send(httpReq);
        system.debug('httpRes-----------'+httpRes);
        system.debug('httpRes-----------'+httpRes.getBody());
        return httpRes;
    }
    public static HttpResponse HttpRequestMethodResolution(String endPoint,String accessToken,String body)
    {
        //[B] this code does not belong here...needs moved eventually
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Content-Type' , 'application/json');
        httpReq.setBody(body);
        httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
        httpRes = http.send(httpReq);
        system.debug('httpRes-----------'+httpRes);
        system.debug('httpRes-----------'+httpRes.getBody());
        return httpRes;
    }	
}