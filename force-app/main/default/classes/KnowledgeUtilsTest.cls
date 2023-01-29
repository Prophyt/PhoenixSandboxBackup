@isTest
public class KnowledgeUtilsTest 
{
	public static testMethod void RunTest()
    {
        knowledge__kav art = new knowledge__kav(Title='test',summary='test',urlname='test',Customer_Name__c = 'Bed Bath and Beyond',Category__c = 'Customer Specific');
        insert art;
        
        art = [SELECT Id,PublishStatus,RecordTypeId,KnowledgeArticleId FROM knowledge__kav WHERE Id = :art.Id];
        knowledge__kav template = new knowledge__kav();
        template.Category__c = 'General Troubleshooting';
		KnowledgeUtils.getAllArticles();
        KnowledgeUtils.publishArticle(art.KnowledgeArticleId);
        Test.startTest();
        string newVersionId = KnowledgeUtils.updateArticleFlags(art.KnowledgeArticleId, template);
        //this is not really how this would run, you would run the batch first and by itself.  you could run updateArticleFlags ad hoc one/off if necessary
        //but we do this to test
        KnowledgeUtilsBatch b = new KnowledgeUtilsBatch('SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE KnowledgeArticleId = \'' + newVersionId + '\'', template);
        database.executeBatch(b, 1);
        Test.stopTest();
    }
}