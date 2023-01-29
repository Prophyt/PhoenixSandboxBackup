@isTest
public class CorrigoProEventTest 
{
    public static string getJson()
    {
        string json = '{';
        json += '"Comment": "WorkOrder has been put on hold.",';
        json += '"Status": "OnHold",';
        json += '"Header": {';
        json += '    "WorkOrderId": 42,';
        json += '    "BranchId": 79493,';
        json += '    "Sender": {';
        json += '        "Name": "Tyrion Lannister",';
        json += '        "Phone": "+12025556632",';
        json += '        "Type": "Customer"';
        json += '    }},';
        json += '    "Action": "PutOnHold",';
        json += '    "ActionDate": "2022-03-09T05:25:06.9425871Z",';
        json += '    "ApiVersion": "1.2",';
        json += '    "MessageId": "1a021204-6d9a-4f34-90e3-dd658ef50494"';
        json += '}';
        return json;
    }
	public static testMethod void runTest()
    {
        CorrigoProEvent e = CorrigoProEvent.parse(getJson());
    }
    public static testMethod void runTestCases()
    {

        Integration_Message__c im = new Integration_Message__c();
        im.Header__c = 'OnHold';
        im.Integration_Source__c = 'CorrigoPro';
        im.Package__c = getJson();
        insert im;
        
        Case c = new Case();
        c.Integration_Message__c = im.Id;
        c.X3rd_Party_WO_Id__c = '42';
        c.X3rd_Party_System__c = 'CorrigoPro';
        insert c;
        
        CorrigoProEvent.createCaseCommentFromNote(im);
        CorrigoProEvent.updateCaseStatus(im);
    }
}