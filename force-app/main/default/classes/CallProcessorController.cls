public class CallProcessorController 
{
	public Map<string, string> ParamMap {get;set;}
	public string ANI {get;set;}
	public string DNIS {get;set;}
	public string StoreNumber {get;set;}
    public User CurrentUser {get;set;}
	public CallProcessorController()
	{
		ParamMap = ApexPages.currentPage().getParameters();
		if(ParamMap.get('ANI') != null && ParamMap.get('ANI') != '')
			ANI = ParamMap.get('ANI');
		if(ParamMap.get('DNIS') != null && ParamMap.get('DNIS') != '')
			DNIS = ParamMap.get('DNIS');
		if(ParamMap.get('StoreNumber') != null && ParamMap.get('StoreNumber') != '')
			StoreNumber = ParamMap.get('StoreNumber');

		CurrentUser = [SELECT Id,Name,UserRoleId,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
	}
	public PageReference RedirectUser()
	{
		string parentQuery = 'FIND \'' + DNIS + '\' IN PHONE FIELDS RETURNING Account(Id,Name,AccountNumber,OwnerId)';
		List<List<sObject>> parentSearchList = search.query(parentQuery);
		List<Account> ParentAccounts = ((List<Account>)parentSearchList[0]);
		PageReference ref;
		if(!ParentAccounts.isEmpty())
		{
			//we have an existing account and a parent account, so just go to existing record - this is a placeholder so we can update parent accounts in future if they dont match
			ref = new PageReference('/' + ParentAccounts[0].Id);
		}

        string currentUrl = ApexPages.currentPage().getUrl();
		
		if(currentUrl.contains('Debug'))
			return null;

		ref.setRedirect(true);
		return ref;
	}
}