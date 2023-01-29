public without sharing class KnowledgeUtils 
{
    @AuraEnabled
    public static List<Knowledge__kav> getAllArticles()
    {
        return [SELECT Id, 
                KnowledgeArticleId, 
                RecordTypeId,
                PublishStatus,
                Title, 
                UrlName 
                FROM Knowledge__kav];
    }
 
    @AuraEnabled
    public static string updateArticleFlags(string knowledgeArticleId, Knowledge__kav article)
    {
        //pass in the article with the parameters you want.
        string newVersionId = KnowledgeUtils.unPublishArticle(knowledgeArticleId);
        
        /*
        system.debug('Starting Queueable for Knowledge');
        KnowledgeUtilsQueueable q = new KnowledgeUtilsQueueable(newVersionId, article);
        system.enqueueJob(q);
        */
        
        Knowledge__kav newArticle = [SELECT Id, 
                                     PublishStatus,
                                     KnowledgeArticleId, 
                                     Title, 
                                     UrlName,
                                     RecordTypeId,
                                     RecordType.Name,
                                     Category__c,
                                     Sub_Category__c,
                                     Customer_Name__c
                                     FROM Knowledge__kav 
                                     WHERE KnowledgeArticleId = :newVersionId];
        
        system.debug('** NEW STATUS ** : ' + newArticle.PublishStatus);
        
        if(article.RecordTypeId != newArticle.RecordTypeId)
            newArticle.RecordTypeId = article.RecordTypeId;
        if(article.Category__c != newArticle.Category__c && article.Category__c != null)
            newArticle.Category__c = article.Category__c;
        if(article.Sub_Category__c != newArticle.Sub_Category__c && article.Sub_Category__c != null)
            newArticle.Sub_Category__c = article.Sub_Category__c;
        /*
        if(article.Customer_Name__c != newArticle.Customer_Name__c && article.Customer_Name__c != null)
            newArticle.Customer_Name__c = article.Customer_Name__c;
        */
        
        try
        {
            update newArticle;    
            KnowledgeUtils.publishArticle(newVersionId);
        }
        catch(Exception ex)
        {
            string msg = 'Failed to update Knowledge: Original ID: ' + knowledgeArticleId + ' and New Version ID: ' + newVersionId;
            msg += '\r\nDue to: \r\n';
            msg += ex.getLineNumber() + ': ' + ex.getMessage();
            system.debug(msg);
        }
		
        return newVersionId;
    }
     
    @AuraEnabled
    public static void publishArticle(String recordId) 
    { 
        //must be KnowledgeArticleId
        system.debug('PUBLISH ARTICLE: ' + recordId);
        KbManagement.PublishingService.publishArticle(recordId, true);
    }
 
    @AuraEnabled
    public static String unPublishArticle(String recordId)
    { 
        system.debug('Unpublish Article: ' + recordId);
        //recordId must be be KnowledgeArticleId
        String newArticleId = KbManagement.PublishingService.editOnlineArticle(recordId, true);

        system.debug('Unpublish Success!');
        return [SELECT KnowledgeArticleId 
                FROM Knowledge__kav 
                WHERE Id = :newArticleId].KnowledgeArticleId;
    } 
}