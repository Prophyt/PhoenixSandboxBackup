public without sharing class KnowledgeBrowserController 
{
    @AuraEnabled
    public static boolean attachToCase(string caseId, string articleId)
    {
        Knowledge__kav k = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articleId];
        
        CaseArticle ca = new CaseArticle();
        ca.CaseId = Id.valueOf(caseId);
        ca.KnowledgeArticleId = k.KnowledgeArticleId;
        try
        {
            insert ca;
            return true;            
        }
        catch(Exception ex)
        {
            system.debug(ex);
            return false;
        }

    }
    @AuraEnabled
    public static List<Knowledge__kav> getKnowledge(string recordId)
    {
        List<Case> cases = [SELECT Id,
                            CaseNumber,
                            AccountId,
                            Account.Name,
                            Account.Location_Name__c,
                            Account.ParentId,
                            Account.Parent.Name
                            FROM Case
                            WHERE Id = :recordId];
        
        if(cases.isEmpty() || cases[0].AccountId == null)
            return new List<Knowledge__kav>();
        
        string titleKey = cases[0].Account.Name;
        //used regex to trim store numbers off end of strings: \\d+$
        string titleRegex = '\\d+$';
        titleKey = titleKey.replaceAll('\\s+\\d+$','');
        system.debug(titleKey);
        titleKey = titleKey + '%';
        system.debug(titleKey);
        List<Knowledge__kav> items = [SELECT Id,
                                      Title,
                                      UrlName,
                                      VersionNumber,
                                      Summary,
                                      PublishStatus,
                                      Customer_Name__c,
                                      Category__c,
                                      Sub_Category__c,
                                      ArticleTotalViewCount,
                                      ArticleNumber,
                                      ArticleCreatedDate,
                                      LastPublishedDate,
                                      RecordTypeId,
                                      RecordType.Name
                                      FROM Knowledge__kav
                                      WHERE PublishStatus = 'Online'
                                      AND (Title LIKE :titleKey
                                      OR Customer_Name__c LIKE :titleKey
                                      OR Category__c IN ('General'))
                                      ORDER BY Title,Category__c];
        return items;
    }
    @AuraEnabled
    public static List<Item> getAccountKnowledgeTree(string recordId)
    {
        List<Item> items = new List<Item>();
        List<Knowledge__kav> kItems = getKnowledge(recordId);
        List<Item> generalTroubleChildItems = new List<Item>();
        for(Knowledge__kav k : kItems)
        {
            if(k.Category__c == 'General')
            {
                system.debug('adding general item');
                generalTroubleChildItems.add(new Item(k.Title, String.valueOf(k.Id), false, null));
            }
            else
            {
                Item i = new Item(k.Title, String.valueOf(k.Id), false, null);
                items.add(i);
            }
        }
        
        List<Item> finalItems = new List<Item>();
        Item genItem = new Item('General Troubleshooting', null, false, generalTroubleChildItems);
        finalItems.add(genItem);
        finalItems.addAll(items);
        return finalItems;
    }
    public static Map<string, string> getPicklistValues(string objectName, string fieldName)
    {
        Map<String, String> values = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objResult = objType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry item : picklistValues) 
        {
            values.put(item.getLabel(), item.getValue());
        }
        return values;
    }
    @AuraEnabled
    public static List<Item> getAllKnowledgeTree()
    {
        Map<string, string> categoryTypesMap = getPicklistValues('Knowledge__kav','Category__c');
        Map<string, string> subCategoryTypesMap = getPicklistValues('Knowledge__kav','Sub_Category__c');
        
        Map<string, Set<string>> categoryMap = new Map<string, Set<string>>();
        for(string key : categoryTypesMap.keySet())
        {
            if(key == 'Customer Specific')
                categoryMap.put(key, subCategoryTypesMap.keySet());
            else
                categoryMap.put(key, new Set<string>());
        }
        
        List<Knowledge__kav> kItems = [SELECT Id,
                                       Title,
                                       UrlName,
                                       VersionNumber,
                                       Summary,
                                       PublishStatus,
                                       Customer_Name__c,
                                       Category__c,
                                       Sub_Category__c,
                                       ArticleTotalViewCount,
                                       ArticleNumber,
                                       ArticleCreatedDate,
                                       LastPublishedDate,
                                       RecordTypeId,
                                       RecordType.Name
                                       FROM Knowledge__kav
                                       WHERE PublishStatus = 'Online'
                                       ORDER BY Customer_Name__c, Title];
        

        Map<string, List<Knowledge__kav>> nonCustomerNamesArticles = new Map<string, List<Knowledge__kav>>();
        Map<string, List<Knowledge__kav>> customerNamesArticles = new Map<string, List<Knowledge__kav>>();
        for(Knowledge__kav k : kItems)
        {
            string title = k.Title;
            string category = k.Category__c;
            string modTitle = k.Title.contains(':') ? k.Title.substringBefore(':') : '';
            string customerName = k.Customer_Name__c;
            
            if(string.isBlank(customerName) && string.isBlank(modTitle))
            {
                if(string.isBlank(category))
                    category = 'General';
                
                if(nonCustomerNamesArticles.containsKey(category))
                {
                    List<Knowledge__kav> items = nonCustomerNamesArticles.get(category);
                    items.add(k);
                    nonCustomerNamesArticles.put(category, items);
                }
                else
                {
                    List<Knowledge__kav> items = new List<Knowledge__kav>();
                    items.add(k);
                    nonCustomerNamesArticles.put(category, items);
                }
            }
            else if(customerNamesArticles.containsKey(customerName))
            {
                List<Knowledge__kav> items = customerNamesArticles.get(customerName);
                items.add(k);
                customerNamesArticles.put(customerName, items);
            }
            else if(!string.isBlank(modTitle) && customerNamesArticles.containsKey(modTitle))
            {
                List<Knowledge__kav> items = customerNamesArticles.get(modTitle);
                items.add(k);
                customerNamesArticles.put(modTitle, items);
            }
            else
            {
                string keyVal = !string.isBlank(customerName) ? customerName : !string.isBlank(modTitle) ? modTitle : '';
                if(string.isBlank(keyVal))
                    continue;
                
                List<Knowledge__kav> items = new List<Knowledge__kav>();
                items.add(k);
                customerNamesArticles.put(keyVal, items);
            }            
        }
        Map<string, Item> itemMap = new Map<string, Item>();
        for(string key : categoryMap.keySet())
        {
            Item p = new Item(key, null, false, new List<Item>());

            List<Item> items = new List<Item>();
            if(key == 'Customer Specific')
            {
                for(string customerKey : customerNamesArticles.keySet())
                {
                    Item ci = new Item(customerKey, null, false, new List<Item>());
                    Set<String> subCats = categoryMap.get(key);
                    for(string sc : subCats)
                    {
                        Item i = new Item(sc, null, false, new List<Item>());
                        List<Knowledge__kav> customerItems = customerNamesArticles.get(customerKey);
                        for(Knowledge__kav ck : customerItems)
                        {
                            if(ck.Sub_Category__c == sc)
                            {
                                Item cxi = new Item(ck.Title, string.valueOf(ck.Id), false, null);
                                i.items.add(cxi);
                            }
                        }
                        ci.items.add(i);
                    }
                    items.add(ci);
                }
                p.items = items;
            }
            else
            {
                List<Knowledge__kav> categorizedItems = nonCustomerNamesArticles.containsKey(key) ? nonCustomerNamesArticles.get(key) : new List<Knowledge__kav>();
                for(Knowledge__kav ci : categorizedItems)
                {
                    Item i = new Item(ci.Title, string.valueOf(ci.Id), false, null);
                    items.add(i);
                }
                p.items = items;
            }
            
            itemMap.put(key, p);
        }
        
        return itemMap.values();
    }
    @AuraEnabled
    public static List<ContentVersion> getRelatedDocs(Id recordId)
    {
        List<ContentVersion> cds = new List<ContentVersion>();
        
        //system.debug(recordId);
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId 
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId = :recordId];
        //system.debug(cdls.size());
        
        Set<Id> cdIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) 
        {
            cdIds.add(cdl.ContentDocumentId); 
        }
        
        cds = [SELECT Id, 
               Title, 
               FileType, 
               OwnerId, 
               Owner.Name, 
               CreatedDate,
               CreatedById, 
               CreatedBy.Name, 
               ContentSize,
               ContentDocumentId
               FROM ContentVersion 
               WHERE ContentDocumentId IN :cdIds
               AND IsLatest = true];
        
        //system.debug(cds.size());
        
        return cds;
    }
    @AuraEnabled
    public static string getDocURL(Id docId)
    {
        ContentVersion cv = [SELECT Id 
                             FROM ContentVersion 
                             WHERE Id = :docId 
                             AND IsLatest = true];
        
        String cvURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id;
        return cvURL;
    }
     
    public class Item
    {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
        @AuraEnabled
        public List<Item> items {get; set;}
         
        public item(String label, String name, Boolean expanded, List<Item> items)
        {
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            this.items = Items;
        }
    }
}