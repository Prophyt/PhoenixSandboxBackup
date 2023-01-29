public class EDXAPI 
{
	public class AccountPayload
    {
        public string Id;
        public string Name;
        public string SiteNumber;
        public string ParentAccountName;
        public string StreetAddress;
        public string City;
        public string State;
        public string Zip;
        public string EMSType;
        public string IPAddress;
        public double SquareFootage;
        public string LocationStatus;
        public Date OpenedDate;
        public Date ClosedDate;
    }
    public static Account getAccount(string accountId)
    {
        return [SELECT Id,
                Name,
                Site_Number__c,
                ParentId,
                Parent.Name,
                BillingCity,
                BillingStreet,
                BillingState,
                BillingPostalCode,
                EMS_Type__c,
                Modem_IP__c,
                Square_Footage__c,
                Location_Status__c,
                Opened_Date__c,
                Closed_Date__c
                FROM Account
                WHERE Id = :accountId];
    }
    public static AccountPayload convertAccountToEDX(Account a)
    {
        AccountPayload ap = new AccountPayload();
        ap.Id = a.Id;
        ap.Name = a.Name;
        ap.SiteNumber = a.Site_Number__c;
        ap.ParentAccountName = a.ParentId != null && a.Parent.Name != null ? a.Parent.Name : '';
        ap.StreetAddress = a.BillingStreet;
        ap.City = a.BillingCity;
        ap.State = a.BillingState;
        ap.Zip = a.BillingPostalCode;
        ap.EMSType = a.EMS_Type__c;
        ap.IPAddress = a.Modem_IP__c;
        ap.SquareFootage = a.Square_Footage__c;
        ap.LocationStatus = a.Location_Status__c;
        ap.OpenedDate = a.Opened_Date__c;
        ap.ClosedDate = a.Closed_Date__c;
        return ap;
    }
}