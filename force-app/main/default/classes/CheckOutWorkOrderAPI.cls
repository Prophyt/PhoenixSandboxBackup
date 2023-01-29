public class CheckOutWorkOrderAPI {
    @InvocableMethod(label='CheckOutAPI')
    public static List<String> CheckOutAPI(List<String> caseId){
        System.debug('caseId=='+caseId);
        List<Integration_Message__c> IntegrationMessageList = [select id,Package__c,Integration_Source__c from Integration_Message__c where Integration_Source__c='SMS Assist'];
        set<string> IMids = new set<string>();
        for(Integration_Message__c IM:IntegrationMessageList){    
            IMids.add(IM.id);
        }
        CheckOutAPI_FutureCallout(caseId);
        return null;
    }
    @future(callout=true)
    public static void CheckOutAPI_FutureCallout(List<String> caseId){
        list<Case> updateCaseList = new list<Case>();
        System.debug('caseId=='+caseId);
        list<Case> caseList = [select Id,Customer_WO__c,Integration_Message__c,IsClosed,Resolution__c from Case where Id IN: caseId];
        
        if(caseList.size()>0){
            for(Case cas:caseList){
                System.debug('case =='+cas);
                string requestBody = '';
                if(cas.Resolution__c!='' && cas.Resolution__c!=null){
                    if(cas.IsClosed==true &&(cas.Resolution__c.contains('Completed') || cas.Resolution__c.contains('Resolved'))){
                        requestBody = '{'+
                            '"wo_num": "'+cas.Customer_WO__c+'",'+
                            '"checkout_status": "ResolvedWithoutInvoice"'+
                            //'"checkout_time":"2008-09-22 14:01:54"'+
                            '}';
                    }else if(cas.IsClosed==true && cas.Resolution__c.contains('Dispatch')){
                        requestBody = '{'+
                            '"wo_num": "'+cas.Customer_WO__c+'",'+
                            '"checkout_status": "PendingVendorQuote"'+
                            //'"checkout_time":"2008-09-22 14:01:54"'+
                            '}';
                    }
                }
                else if(cas.IsClosed==true/* || cas.Status=='Cancelled'*/){
                    requestBody = '{'+
                        '"wo_num": "'+cas.Customer_WO__c+'",'+
                        '"checkout_status": "Cancelled"'+
                        //'"checkout_time":"2008-09-22 14:01:54"'+
                        '}';
                    
                }
                String endPoint1 = 'https://meshlive.smsassist.com/api/v1.0/workorder/reactive/check-out';
                HttpRequest httpReq1 = new HttpRequest();
                HttpResponse httpRes1 = new HttpResponse();
                Http http1 = new Http();
                httpReq1.setMethod('POST');
                httpReq1.setEndPoint(endPoint1);
                httpReq1.setHeader('Content-Type' , 'application/json');
                httpReq1.setHeader('Accept', 'application/json');
                httpReq1.setHeader('Authorization' , 'Bearer '+SMSassistSettings.ReturnAccessToken().replaceAll('"',''));          
                httpReq1.setBody(requestBody);
                httpRes1 = http1.send(httpReq1);
                cas.X3rd_Party_Update_Error__c = 'CheckOut API Response:   '+httpRes1.getBody();
                updateCaseList .add(cas);
                system.debug('httpRes1-----------'+httpRes1.getBody());
            }
            if(updateCaseList.size()>0){
                update updateCaseList;
            }
        }
    }
}