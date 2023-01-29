@isTest
public with sharing class AutoCompleteControllerTest 
{
    @TestSetup
    static void makeData()
    {
        Account acc = new Account(Name='Salesforce');
        insert acc;
        
        knowledge__kav art = new knowledge__kav(Title='test',summary='test',urlname='test',Customer_Name__c = 'Bed Bath and Beyond',Category__c = 'Customer Specific');
        insert art;
        
        art = [SELECT Id,PublishStatus,RecordTypeId,KnowledgeArticleId FROM knowledge__kav WHERE Id = :art.Id];
        knowledge__kav template = new knowledge__kav();
        template.Category__c = 'General Troubleshooting';
		KnowledgeUtils.getAllArticles();
        KnowledgeUtils.publishArticle(art.KnowledgeArticleId);
    }

    @isTest
    public static void testGetKnowledge()
    {
        List<Knowledge__kav> items = AutoCompleteController.searchKnowledge('test');
        System.assertEquals(1, items.size());
    }
    @isTest
    public static void testGetRecords()
    {
        List<SObject> accounts = AutoCompleteController.getRecords('sales', 'Account', 'Id', 'Name', null, 10);
        System.assertEquals(1, accounts.size());
        accounts = AutoCompleteController.getRecords('abc', 'Account', 'Id', 'Name', '', 100);
        System.assertEquals(0, accounts.size());
    }
}