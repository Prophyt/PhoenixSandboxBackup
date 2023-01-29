@isTest
public class CallProcessorControllerTest
{
    public static testMethod void RunTest()
    {
        Account a = new Account();
        a.Name = 'Test';
        a.Phone = '1231231234';
       
        insert a;
        //SOSL handling.....
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        PageReference ref = new PageReference('/' + a.Id);
        Test.setCurrentPage(ref);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ANI','1231231234');
        ApexPages.currentPage().getParameters().put('DNIS','1231231234');        
        CallProcessorController controller = new CallProcessorController();
        controller.RedirectUser();
        PageReference ref2 = new PageReference('/' + a.Id);
        Test.setCurrentPage(ref2);
        ApexPages.currentPage().getParameters().put('DNIS','5551231234');
        ApexPages.currentPage().getParameters().put('ANI','1231231234');
        ApexPages.currentPage().getParameters().put('StoreNumber','TEST');
        Test.stopTest();
    }
}