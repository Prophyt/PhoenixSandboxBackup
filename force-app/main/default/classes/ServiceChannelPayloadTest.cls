@IsTest
public class ServiceChannelPayloadTest 
{
	static testMethod void testParse() 
    {
		String json = '{\"Object\":{\"Id\":218135952,\"Number\":\"218135952\",\"PurchaseNumber\":\"218135952\",\"SubscriberId\":2014916423,\"ProviderId\":2000019310,\"ProviderName\":\"Phoenix Energy Technologies, Inc.\",\"LocationId\":2005426284,\"LocationName\":\"Carrollwood FL\",\"LocationStoreId\":\"1737\",\"Status\":{\"Primary\":\"COMPLETED\",\"Extended\":\"DISPATCHED\"},\"Caller\":\"MOD\",\"CreatedBy\":\"MOD\",\"CallDate\":\"2022-10-06T11:14:00\",\"CallDate_DTO\":\"2022-10-06T11:14:00-04:00\",\"Priority\":\"Emergency\",\"Trade\":\"EMS\",\"ScheduledDate\":\"2022-10-06T15:14:00\",\"CreatedDate_DTO\":\"2022-10-06T11:14:30.5430212-04:00\",\"UpdatedDate\":\"2022-10-06T11:21:46.55\",\"UpdatedDate_DTO\":\"2022-10-06T11:21:46.5513199-04:00\",\"ScheduledDate_DTO\":\"2022-10-06T15:14:00-04:00\",\"CompletedDate\":\"2022-10-06T11:21:02\",\"ExpirationDate\":\"2022-10-06T15:14:00\",\"ExpirationDate_DTO\":\"2022-10-06T15:14:00-04:00\",\"Description\":\"PHOENIX CREATED TICKET: Salon is too hot.\",\"Category\":\"REPAIR\",\"Nte\":0.0,\"CurrencyAlphabeticalCode\":\"USD\",\"Resolution\":\"EMS finds RTU 5 grooming not cooling after reset. Please dispatch tech to troubleshoot cooling failure. Please contact Phoenix at 800-386-3696 prior to leaving site. PHOENIX DISPATCHED 218136494\",\"Source\":\"Web Request\",\"Notes\":[{\"Id\":1446277849,\"Number\":6,\"NoteData\":\"PHOENIX DISPATCHED 218136494.\",\"DateCreated\":\"2022-10-06T11:22:00\",\"ScheduledDate\":\"2022-10-06T15:14:00\",\"ActionRequired\":false,\"MailedTo\":\"DL.Store1737AllLeaders@petco.com;Jon-Paul.Muzio@petco.com;reynaldo.valdez@petco.com;danny.henson@petco.com\",\"CreatedBy\":\"Mike Sambor\",\"CreatedByUser\":{\"UserName\":\"mikesamb\",\"FullName\":\"Mike Sambor\",\"SubscriberId\":2014916423},\"DateCreated_DTO\":\"2022-10-06T11:23:00-04:00\"}],\"Attachments\":[],\"LinkedWorOrderIds\":[],\"Assets\":[]},\"Type\":\"WoRootNotification\",\"Action\":\"UPDATE\",\"EventType\":\"WorkOrderNoteAdded\",\"Version\":1}';
		ServiceChannelPayload r = ServiceChannelPayload.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload.Status objStatus = new ServiceChannelPayload.Status(System.JSON.createParser(json));
		System.assert(objStatus != null);
		System.assert(objStatus.Primary == null);
		System.assert(objStatus.Extended == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload objServiceChannelPayload = new ServiceChannelPayload(System.JSON.createParser(json));
		System.assert(objServiceChannelPayload != null);
		System.assert(objServiceChannelPayload.Object_Z == null);
		System.assert(objServiceChannelPayload.Type == null);
		System.assert(objServiceChannelPayload.Action == null);
		System.assert(objServiceChannelPayload.EventType == null);
		System.assert(objServiceChannelPayload.Version == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload.CreatedByUser objCreatedByUser = new ServiceChannelPayload.CreatedByUser(System.JSON.createParser(json));
		System.assert(objCreatedByUser != null);
		System.assert(objCreatedByUser.UserName == null);
		System.assert(objCreatedByUser.FullName == null);
		System.assert(objCreatedByUser.SubscriberId == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload.Object_Z objObject_Z = new ServiceChannelPayload.Object_Z(System.JSON.createParser(json));
		System.assert(objObject_Z != null);
		System.assert(objObject_Z.Id == null);
		System.assert(objObject_Z.Number_Z == null);
		System.assert(objObject_Z.PurchaseNumber == null);
		System.assert(objObject_Z.SubscriberId == null);
		System.assert(objObject_Z.ProviderId == null);
		System.assert(objObject_Z.ProviderName == null);
		System.assert(objObject_Z.LocationId == null);
		System.assert(objObject_Z.LocationName == null);
		System.assert(objObject_Z.LocationStoreId == null);
		System.assert(objObject_Z.Status == null);
		System.assert(objObject_Z.Caller == null);
		System.assert(objObject_Z.CreatedBy == null);
		System.assert(objObject_Z.CallDate == null);
		System.assert(objObject_Z.CallDate_DTO == null);
		System.assert(objObject_Z.Priority == null);
		System.assert(objObject_Z.Trade == null);
		System.assert(objObject_Z.ScheduledDate == null);
		System.assert(objObject_Z.CreatedDate_DTO == null);
		System.assert(objObject_Z.UpdatedDate == null);
		System.assert(objObject_Z.UpdatedDate_DTO == null);
		System.assert(objObject_Z.ScheduledDate_DTO == null);
		System.assert(objObject_Z.CompletedDate == null);
		System.assert(objObject_Z.ExpirationDate == null);
		System.assert(objObject_Z.ExpirationDate_DTO == null);
		System.assert(objObject_Z.Description == null);
		System.assert(objObject_Z.Category == null);
		System.assert(objObject_Z.Nte == null);
		System.assert(objObject_Z.CurrencyAlphabeticalCode == null);
		System.assert(objObject_Z.Resolution == null);
		System.assert(objObject_Z.Source == null);
		System.assert(objObject_Z.Notes == null);
		System.assert(objObject_Z.Attachments == null);
		System.assert(objObject_Z.LinkedWorOrderIds == null);
		System.assert(objObject_Z.Assets == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload.Attachments objAttachments = new ServiceChannelPayload.Attachments(System.JSON.createParser(json));
		System.assert(objAttachments != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ServiceChannelPayload.Notes objNotes = new ServiceChannelPayload.Notes(System.JSON.createParser(json));
		System.assert(objNotes != null);
		System.assert(objNotes.Id == null);
		System.assert(objNotes.Number_Z == null);
		System.assert(objNotes.NoteData == null);
		System.assert(objNotes.DateCreated == null);
		System.assert(objNotes.ScheduledDate == null);
		System.assert(objNotes.ActionRequired == null);
		System.assert(objNotes.MailedTo == null);
		System.assert(objNotes.CreatedBy == null);
		System.assert(objNotes.CreatedByUser == null);
		System.assert(objNotes.DateCreated_DTO == null);
	}
}