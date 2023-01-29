public without sharing class OpportunityPathController 
{
    @AuraEnabled
    public static Opportunity getOpportunity(string recordId)
    {
        //this method is just a placeholder because we need logic eventually
        return [SELECT Id FROM Opportunity WHERE Id = :recordId];
    }
}