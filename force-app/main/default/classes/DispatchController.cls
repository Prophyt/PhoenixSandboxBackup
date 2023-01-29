public class DispatchController {
    
    @AuraEnabled
    public static Case RedirectToWO (String CaseId){
        
        system.debug('CaseId--------'+CaseId);
        String DispVal = '';
        Case CaseRec = new Case();
        CaseRec = [Select id,Stage__c,Customer_WO__c  from case where id =: CaseId];
        /*if(CaseList.Stage__c == 'Update 3rd Party'){
            DispVal = 'DisplayButton';
        }else{
            DispVal = 'DisableButton';
        }
        system.debug('DispVal------'+DispVal); */
        return CaseRec;
    }
    
    @AuraEnabled
    public static String CustomerSettings(){
        Customer_Settings__mdt SCsettings = new Customer_Settings__mdt ();
        SCsettings = [Select AccountId_Customer__c,ClientId__c,Username__c,Password__c,Secret_Key__c,Url_Endpoint__c from Customer_Settings__mdt where developername = 'PhoenixET_ServiceChannel'];
        String Url_Endpoint = SCsettings.Url_Endpoint__c;
        
        return Url_Endpoint;
    }
}