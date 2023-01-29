@isTest
public class DispatchControllerTest {
    @testSetup
    static void setup() {
        case caserec = new case(Priority='Normal',
                                Stage__c = 'Update 3rd Party',
                                Status='New',
                                Origin='Email',
                                Subject='Test Subject',
                                Description='Testing Problem Description');
        insert caserec;
    }
    static testMethod void test() {
        test.startTest();
        case caseRecord = [select id,Stage__c,Description from case];
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        DispatchController.RedirectToWO(caseRecord.Id);
        DispatchController.CustomerSettings();
        test.stopTest();
    }
}