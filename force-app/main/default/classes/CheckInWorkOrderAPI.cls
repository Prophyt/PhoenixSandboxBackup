public class CheckInWorkOrderAPI {
 @InvocableMethod(label='CheckInAPI')
  public static List<String> CheckInAPI(List<String> woNumList){
      System.debug('woNumList=='+woNumList);
      List<Integration_Message__c> IntegrationMessageList = [select id,Package__c,Integration_Source__c from Integration_Message__c where Integration_Source__c='SMS Assist'];
        set<string> IMids = new set<string>();
        for(Integration_Message__c IM:IntegrationMessageList){    
             IMids.add(IM.id);
        }
       CheckInAPI_FutureCallout(woNumList);
        return null;
  
  }
  @future(callout=true)
  public static void CheckInAPI_FutureCallout(List<String> woNumList){
   list<Case> updateCaseList = new list<Case>();
   list<Case> caseList = [select Id,Customer_WO__c,Integration_Message__c from Case where Id IN: woNumList];
        if(caseList.size()>0){
            for(Case cas:caseList){
                String endPoint1 = 'https://meshlive.smsassist.com/api/v1.0/workorder/reactive/check-in';
                HttpRequest httpReq1 = new HttpRequest();
                HttpResponse httpRes1 = new HttpResponse();
                Http http1 = new Http();
                httpReq1.setMethod('POST');
                httpReq1.setEndPoint(endPoint1);
                httpReq1.setHeader('Content-Type' , 'application/json');
                httpReq1.setHeader('Accept', 'application/json');
                httpReq1.setHeader('Authorization' , 'Bearer '+SMSassistSettings.ReturnAccessToken().replaceAll('"','')); 
                string requestBody = '{'+
                    '"wo_num": "'+cas.Customer_WO__c+'",'+
                    //'"checkin_time": "2008-09-22 14:01:54"'+
                     '"checkin_time": "'+ DateTime.now()+'"'+
                    '}';
                httpReq1.setBody(requestBody);
                httpRes1 = http1.send(httpReq1);
                 cas.X3rd_Party_Update_Error__c = 'CheckIn API Response:   '+httpRes1.getBody();
                updateCaseList .add(cas);
                system.debug('httpRes1-----------'+httpRes1.getBody());
            }
            if(updateCaseList.size()>0){
                update updateCaseList;
            }
            
        }
  }
}