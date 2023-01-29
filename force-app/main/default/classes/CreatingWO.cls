public with sharing class CreatingWO {
    
    @AuraEnabled
    public static String CreateWorkOrder(String Ids){
        String msg = '';
        String accessToken = ProcessServiceChannelRequest.ReturnAccessToken();
        Case CaseList = new Case();
        CaseList = [Select id,Priority,Issue_Type__c,X3rd_Party_Update_Error__c,Scheduled_New__c,
                    Subject,Customer_WO__c,Description,Problem__c,Parent_Account__r.Third_Party_FM_Id__c,
                    Third_Party_FM_Id__c, Status,IsClosed From Case where Id =: Ids];
        List<Case> caseReclist = new List<Case>();
        //Service_Channel_Settings__c SCsettings = new Service_Channel_Settings__c();
        //SCsettings = [Select id,ProviderID__c from Service_Channel_Settings__c];
        Customer_Settings__mdt SCsettings = new Customer_Settings__mdt ();
        SCsettings = [Select id,ProviderID__c from Customer_Settings__mdt where developername = 'PhoenixET_ServiceChannel'];
        
        String Priority = CaseList.Priority;
        String Trade = CaseList.Issue_Type__c;
        String ScheduledDate = string.valueOfGmt(CaseList.Scheduled_New__c);
        String Description = CaseList.Description;
        String Category = CaseList.Problem__c;
        String LocationId = CaseList.Third_Party_FM_Id__c;
        String ProviderID = SCsettings.ProviderID__c;
        String SubscriberID = CaseList.Parent_Account__r.Third_Party_FM_Id__c;

        
        if(CaseList.Customer_WO__c == null){
            String endPoint = 'https://sb2api.servicechannel.com/v3/workorders';
            //String body = '{"ContractInfo": {"StoreId": "100","TradeName": "HVAC","ProviderId": 2000154845,"LocationId": 2006085096},"Category": "REPAIR","Priority": "P4 - 72 HOURS","Nte": 110,"CallDate": "2021-09-06T05:54:51","ScheduledDate": "2021-09-06T05:54:51","Description": "RESTROOM / HVAC / HVAC / HVAC Leak / Is the HVAC Unit on or off?: On / Are buckets in place to capture the water/leak?: Yes / Is emergency clean-up needed?: No / WO created via New Wizard","Status": {"Primary": "Open"}}';
            //String body = '{"ContractInfo": {"StoreId": "100","TradeName":' +'"'+ Trade +'",' +'"SubscriberId":'+ SubscriberID +',"ProviderId":'+ ProviderID +',"LocationId":'+ LocationId + '},"Category": "REPAIR",'+'"Priority": "'+ Priority +'",'+'"Nte": 110,"CallDate": "'+ ScheduledDate +'",' +'"ScheduledDate": "' + ScheduledDate + '",'+'"Description": "'+ Description +'",' +'"Status": {"Primary": "Open"}}';
            String body = '{"ContractInfo": {"StoreId": "100","TradeName":' +'"'+ Trade +'",' +'"SubscriberId":'+ SubscriberID +',"ProviderId":'+ ProviderID + ',"LocationId":'+ LocationId + '},"Category": "' + Category + '",'+'"Priority": "'+ Priority +'",'+'"Nte": 110,"CallDate": "'+ ScheduledDate +'",' +'"ScheduledDate": "' + ScheduledDate + '",'+'"Description": "'+ Description +'",' +'"Status": {"Primary": "Open"}}';
            //String body = '{"ContractInfo": {"StoreId": "100","TradeName": "HVAC","ProviderId": ,"LocationId": },"Category": "REPAIR","Priority": "P4 - 72 HOURS","Nte": ,"CallDate": "2021-09-06T05:54:51","ScheduledDate": "2021-09-06T05:54:51","Description": "Test@@@@@@@@22","Status": {"Primary": "Open"}}';
            system.debug('body--------'+body);
            
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
            Http http = new Http();
            httpReq.setMethod('POST');
            httpReq.setEndPoint(endPoint);
            httpReq.setHeader('Content-Type' , 'application/json');
            httpReq.setBody(body);
            httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
            httpRes = http.send(httpReq);
            String Response = httpRes.toString();
            system.debug('Response-----------'+Response);
            system.debug('getBody--->'+httpRes.getBody());
            Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
            system.debug('response_Map----->'+response_Map); 
            system.debug('response_Map ErrorMessage-----'+response_Map.get('ErrorMessage')); 
            if(Response == 'System.HttpResponse[Status=Bad Request, StatusCode=400]'){
                String ErrorMsg = response_Map.get('ErrorMessage').toString();
                msg = ErrorMsg ;
            }else if(Response == 'System.HttpResponse[Status=Created, StatusCode=201]'){
                msg = 'Work Order Created ';
                system.debug('response_Map Id-----'+response_Map.get('id'));
                String WOId = string.valueof(response_Map.get('id'));
                CaseList.X3rd_Party_WO_Id__c= WOId;
                CaseList.Customer_WO__c= WOId;
                caseReclist.add(CaseList);
            }
            
            String ErrorMessage = (String)response_Map.get('ErrorMessage');
            system.debug('ErrorMessage------------'+ErrorMessage);
            if(ErrorMessage != null){
                if(ErrorMessage.length() >= 255){  
                    CaseList.X3rd_Party_Update_Error__c = ErrorMessage.Substring(0,255);
                }
                else{
                    CaseList.X3rd_Party_Update_Error__c = ErrorMessage;
                }
                caseReclist.add(CaseList);
             
            }
            update caseReclist; 
        }else{
            if(CaseList.IsClosed == true || CaseList.Status == 'Accepted'  ){
                CaseTriggerHandler.FutureMethodCallout_forWorkOrderUpdate(CaseList.Id); //, CS.X3rd_Party_WO_Id__c                        
            }
        }
        system.debug('msg------'+msg);
        return msg;        
    }
    
    @InvocableMethod(label='Create WO')
    public static List<String> CreateWorkOrderWithFlow(List<String> Ids){
        List<String> msgs = new List<String>();
        String msg = '';
        String accessToken = ProcessServiceChannelRequest.ReturnAccessToken();
        Case CaseList = new Case();
        CaseList = [Select id,Priority,Issue_Type__c,X3rd_Party_Update_Error__c,Scheduled_New__c,Subject,Customer_WO__c,Description,Problem__c,Parent_Account__r.Third_Party_FM_Id__c,Third_Party_FM_Id__c From Case where Id in :ids];
        List<Case> caseReclist = new List<Case>();
        //Service_Channel_Settings__c SCsettings = new Service_Channel_Settings__c();
        //SCsettings = [Select id,ProviderID__c from Service_Channel_Settings__c];
        Customer_Settings__mdt SCsettings = new Customer_Settings__mdt ();
        SCsettings = [Select id,ProviderID__c from Customer_Settings__mdt where developername = 'PhoenixET_ServiceChannel'];
        
        String Priority = CaseList.Priority;
        String Trade = CaseList.Issue_Type__c;
        String ScheduledDate = string.valueOfGmt(CaseList.Scheduled_New__c);
        String Description = CaseList.Description;
        String Category = CaseList.Problem__c;
        String LocationId = CaseList.Third_Party_FM_Id__c;
        String ProviderID = SCsettings.ProviderID__c;
        String SubscriberID = CaseList.Parent_Account__r.Third_Party_FM_Id__c;

        if(CaseList.Customer_WO__c == null){
            String endPoint = 'https://sb2api.servicechannel.com/v3/workorders';
            //String body = '{"ContractInfo": {"StoreId": "100","TradeName": "HVAC","ProviderId": 2000154845,"LocationId": 2006085096},"Category": "REPAIR","Priority": "P4 - 72 HOURS","Nte": 110,"CallDate": "2021-09-06T05:54:51","ScheduledDate": "2021-09-06T05:54:51","Description": "RESTROOM / HVAC / HVAC / HVAC Leak / Is the HVAC Unit on or off?: On / Are buckets in place to capture the water/leak?: Yes / Is emergency clean-up needed?: No / WO created via New Wizard","Status": {"Primary": "Open"}}';
            String body = '{"ContractInfo": {"StoreId": "100","TradeName":' +'"'+ Trade +'",' +'"SubscriberId":'+ SubscriberID +',"ProviderId":'+ ProviderID +',"LocationId":'+ LocationId + '},"Category": "REPAIR",'+'"Priority": "'+ Priority +'",'+'"Nte": 110,"CallDate": "'+ ScheduledDate +'",' +'"ScheduledDate": "' + ScheduledDate + '",'+'"Description": "'+ Description +'",' +'"Status": {"Primary": "Open"}}';
            //String body = '{"ContractInfo": {"StoreId": "100","TradeName": "HVAC","ProviderId": ,"LocationId": },"Category": "REPAIR","Priority": "P4 - 72 HOURS","Nte": ,"CallDate": "2021-09-06T05:54:51","ScheduledDate": "2021-09-06T05:54:51","Description": "Test@@@@@@@@22","Status": {"Primary": "Open"}}';
            system.debug('body--------'+body);
            
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
            Http http = new Http();
            httpReq.setMethod('POST');
            httpReq.setEndPoint(endPoint);
            httpReq.setHeader('Content-Type' , 'application/json');
            httpReq.setBody(body);
            httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
            httpRes = http.send(httpReq);
            String Response = httpRes.toString();
            system.debug('Response-----------'+Response);
            Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
            system.debug('response_Map-----'+response_Map.get('ErrorMessage')); 
            if(Response == 'System.HttpResponse[Status=Bad Request, StatusCode=400]'){
                String ErrorMsg = response_Map.get('ErrorMessage').toString();
                msg = ErrorMsg ;
            }else if(Response == 'System.HttpResponse[Status=Created, StatusCode=201]'){
                msg = 'Work Order Created ';
                system.debug('response_Map Id-----'+response_Map.get('id'));
                String WOId = string.valueof(response_Map.get('id'));
                CaseList.X3rd_Party_WO_Id__c= WOId;
                CaseList.Customer_WO__c= WOId;
                caseReclist.add(CaseList);
            }
            String ErrorMessage = (String)response_Map.get('ErrorMessage');
            system.debug('ErrorMessage------------'+ErrorMessage);
            if(ErrorMessage != null){
                if(ErrorMessage.length() >= 255){  
                    CaseList.X3rd_Party_Update_Error__c = ErrorMessage.Substring(0,255);
                }
                else{
                    CaseList.X3rd_Party_Update_Error__c = ErrorMessage;
                }
                caseReclist.add(CaseList);
                update caseReclist;
            }
            
        }else{
            
        }
        msgs.add(msg);
        system.debug(msgs+'----msg------'+msg);
        return msgs;        
    }
}