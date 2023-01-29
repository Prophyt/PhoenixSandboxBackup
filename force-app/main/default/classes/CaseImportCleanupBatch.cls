public class CaseImportCleanupBatch implements Database.Batchable<sObject>
{
    //send in accountid,account.name,ownerid,owner.name,status,resolution__c minimum
    
    public string query {get;set;}
    public CaseImportCleanupBatch(string q)
    {
        if(!string.isBlank(q))
            query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }    
    public void execute (Database.BatchableContext BC, List<Case> scope)
    {
        List<Case> itemsToDelete = new List<Case>();
        List<Case> itemsToUpdate = new List<Case>();
        List<CaseComment> comments = new List<CaseComment>();
        Set<string> statusToCloseAndComment = new Set<string>();
        statusToCloseAndComment.add('Reopen/Assign EMS');
        statusToCloseAndComment.add('NeedsReview');
        statusToCloseAndComment.add('ETA confirmed by vendor');
        statusToCloseAndComment.add('ETA to follow');
        statusToCloseAndComment.add('Parts on Order');
        statusToCloseAndComment.add('Solved - Dispatch Avoided');
        statusToCloseAndComment.add('Pending Customer Response');
        statusToCloseAndComment.add('ETA request');
        statusToCloseAndComment.add('Waiting for returned tech call');
        
        for(Case c : scope)
        {
            if(statusToCloseAndcomment.contains(c.Status))
            {
                c.Status = 'Closed';
                c.Bypass_Validation_Rules__c = true;
                itemsToUpdate.add(c);
                comments.add(newComment(c));
            }
            else if(c.Status == 'Dispatched to Vendor')
            {
                comments.add(newComment(c));
            }
            else if(c.Status == 'Work Deferred')
            {
                c.Status = 'Closed';
                c.Resolution__c = 'Work Deferred';
                c.Bypass_Validation_Rules__c = true;
                itemsToUpdate.add(c);
                comments.add(newComment(c));
            }
            
            if(c.Owner.Name == 'Admin User' && c.AccountId != null && (c.Account.Name == 'Petco' || c.Account.Name == 'Placeholder Account (no match on API create)'))
            {
                itemsToDelete.add(c);
            }
        }
        
        if(!itemsToDelete.isEmpty())
            delete itemsToDelete;
        if(!comments.isEmpty())
            insert comments;
        if(!itemsToUpdate.isEmpty())
            update itemsToUpdate;
    }
    private static CaseComment newComment(Case c )
    {
        CaseComment cc = new CaseComment();
        cc.ParentId = c.ID;
        cc.CommentBody = 'This case was modified on ' + datetime.now().format() + ' as part of a clean-up effort';
        return cc;
    }
    public void finish (Database.BatchableContext BC) 
    {
        DateTime now = DateTime.now();
        system.debug('Finished running CaseImportCleanupBatch at ' + now);
        AsyncApexJob a = [SELECT Id, 
                          Status,
                          ExtendedStatus,
                          NumberOfErrors, 
                          JobItemsProcessed,
                          TotalJobItems, 
                          CreatedBy.Email    
                          FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        system.debug(a);        
    }
}