public with sharing class AutoCompleteController 
{
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> searchKnowledge(string searchString)
    {
        string query = 'SELECT Id,Title,Category__c,Customer_Name__c,Procedure_Steps__c FROM Knowledge__kav WHERE PublishStatus = \'Online\'';
        //query += 'AND (Title LIKE \'%' + searchString +'%\'';
        //query += ' OR Category__c LIKE \'%' + searchString +'%\'';
        //query += ' OR Procedure_Steps__c LIKE \'%' + searchString + '%\')';
		query += ' ORDER BY Title ASC';
        List<Knowledge__kav> items = database.query(query);
        List<Knowledge__kav> matches = new List<Knowledge__kav>();

        //regex might be faster here ..or not.
        searchString = searchString.toLowerCase();
        for(Knowledge__kav k : items)
        {
            string title = k.Title;
            string category = k.Category__c;
            string customer = k.Customer_Name__c;
            string body = k.Procedure_Steps__c;
            
            if(!string.isBlank(title) && title.containsIgnoreCase(searchString))
            {
                matches.add(k);
            }
            else if(!string.isBlank(category) && category.containsIgnoreCase(searchString))
            {
                matches.add(k);
            }
            else if(!string.isBlank(customer) && customer.containsIgnoreCase(searchString))
            {
                matches.add(k);
            }
            else if(!string.isBlank(body) && body.containsIgnoreCase(searchString))
            {
                matches.add(k);
            }
        }
        return matches;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords)
    {
        searchString = String.escapeSingleQuotes(searchString);
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        
        if(extendedWhereClause == null)
        {
            extendedWhereClause = '';
        }
        
        String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
        return Database.query(query);
    }
}