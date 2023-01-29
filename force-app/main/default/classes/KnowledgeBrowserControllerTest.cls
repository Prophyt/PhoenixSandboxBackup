@isTest
public class KnowledgeBrowserControllerTest 
{
	public static testMethod void RunTest()
    {
        Knowledge__kav k1 = new Knowledge__kav();
        k1.Title = 'Bed Bath and Beyond: Test';
        k1.Customer_Name__c = 'Bed Bath and Beyond';
        k1.Category__c = 'General';
        k1.UrlName = 'testcom';
        insert k1;
        knowledge__kav k2 = new knowledge__kav(Title='Bed Bath and Beyond: Test 2',summary='test',urlname='test',Customer_Name__c = 'Bed Bath and Beyond',Category__c = 'Customer Specific');
        insert k2;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'a picture';
        cv.PathOnClient = 'Pic.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, 
                                           Title, 
                                           LatestPublishedVersionId 
                                           FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = k1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        k1 = [SELECT Id,PublishStatus,RecordTypeId,KnowledgeArticleId FROM knowledge__kav WHERE Id = :k1.Id];
        KnowledgeUtils.publishArticle(k1.KnowledgeArticleId);
        
        k2 = [SELECT Id,PublishStatus,RecordTypeId,KnowledgeArticleId FROM knowledge__kav WHERE Id = :k2.Id];
        KnowledgeUtils.publishArticle(k2.KnowledgeArticleId);

        Account a = new Account();
        a.Name = 'Bed Bath and Beyond';
        insert a;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'Test';
        c.Description = 'Test';
        insert c;

        Test.startTest();
        KnowledgeBrowserController.getKnowledge(c.Id);
        KnowledgeBrowserController.getAccountKnowledgeTree(c.Id);
        KnowledgeBrowserController.getAllKnowledgeTree();
        KnowledgeBrowserController.attachToCase(c.Id, k1.Id);
        KnowledgeBrowserController.getRelatedDocs(k1.Id);
        KnowledgeBrowserController.getDocURL(cv.Id);
        Test.stopTest();
    }
}