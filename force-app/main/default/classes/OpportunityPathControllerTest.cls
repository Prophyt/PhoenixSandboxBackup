@isTest
public class OpportunityPathControllerTest 
{
	public static testMethod void runTest()
    {
        Opportunity o = new Opportunity();
        o.Name = 'Test';
        o.Amount = 100;
        o.CloseDate = date.today();
        o.StageName = 'Prospecting';
        insert o;
        
        OpportunityPathController.getOpportunity(o.Id);
    }
}