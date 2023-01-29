@isTest
public class CorrigoProWorkOrderTest 
{
	public static testMethod void testParse() 
    {
		String json = '{'+
		'  \"body\": {'+
		'    \"Details\": {'+
		'      \"WorkOrderNumber\": \"WN73243\",'+
		'      \"WorkOrderId\": 42,'+
		'      \"BranchId\": 19872,'+
		'      \"IVRInfo\": null,'+
		'      \"Schedule\": {'+
		'        \"ScheduledStart\": \"2022-03-08T12:54:18.0306887Z\",'+
		'        \"Pte\": \"CallFirst\"'+
		'      },'+
		'      \"Type\": \"PMRM\",'+
		'      \"WorkType\": {'+
		'        \"Category\": \"PMRM\",'+
		'        \"Id\": 2,'+
		'        \"Name\": \"PmRm\",'+
		'        \"IsVisit\": false'+
		'      },'+
		'      \"AccompanyingMessage\": \"Here goes accompanying message, description of a Work Order in a plain text format.\",'+
		'      \"Nte\": {'+
		'        \"Amount\": 300,'+
		'        \"Quote\": null,'+
		'        \"IsQuoteMultiline\": false,'+
		'        \"DtLastUpdate\": \"0001-01-01T00:00:00\"'+
		'      },'+
		'      \"Sla\": {'+
		'        \"DueDate\": \"2022-03-09T01:54:18.0306887Z\",'+
		'        \"OnSiteBy\": \"2022-03-08T12:54:18.0306887Z\",'+
		'        \"AcknowledgeBy\": \"2022-03-08T07:54:18.0306887Z\",'+
		'        \"PriorityId\": 2,'+
		'        \"PriorityName\": \"HIGH\",'+
		'        \"IsEmergency\": true'+
		'      },'+
		'      \"WorkDetails\": {'+
		'        \"CheckList\": ['+
		'          {'+
		'            \"SortingIndex\": 1,'+
		'            \"Description\": \"Visual Inspections Task A001 PIPING-HOSE/MECH/VI-01 General\",'+
		'            \"Id\": 6,'+
		'            \"Comment\": null,'+
		'            \"Exception\": null,'+
		'            \"IsDone\": false'+
		'          },'+
		'          {'+
		'            \"SortingIndex\": 2,'+
		'            \"Description\": \"Visual Inspections Task A002 PIPING-HOSE/MECH/VI-01 Hoses/Nozzels/Pipe\",'+
		'            \"Id\": 7,'+
		'            \"Comment\": null,'+
		'            \"Exception\": null,'+
		'            \"IsDone\": false'+
		'          }'+
		'        ],'+
		'        \"Procedures\": null,'+
		'        \"Assets\": ['+
		'          {'+
		'            \"Id\": 46182,'+
		'            \"Path\": \"BUILDING EXTERIOR>BACK LOT\",'+
		'            \"Task\": \"Graffiti\",'+
		'            \"AssetName\": \"Dumpster Area\",'+
		'            \"Comment\": \"Some optional description.\",'+
		'            \"Type\": \"Building\",'+
		'            \"TypeId\": 2,'+
		'            \"Model\": {'+
		'              \"Id\": 49602,'+
		'              \"Name\": \"Base Building\"'+
		'            }'+
		'          },'+
		'          {'+
		'            \"Id\": 45822,'+
		'            \"Path\": \"EQUIPMENT>COOKING\",'+
		'            \"Task\": \"Cleaning problem\",'+
		'            \"AssetName\": \"Combi Oven\",'+
		'            \"Comment\": null,'+
		'            \"Type\": \"Equipment\",'+
		'            \"TypeId\": 8,'+
		'            \"Model\": {'+
		'              \"Id\": 49602,'+
		'              \"Name\": \"Oven\"'+
		'            }'+
		'          }'+
		'        ],'+
		'        \"VisitInfo\": null'+
		'      },'+
		'      \"CompletionDetails\": null,'+
		'      \"Contact\": {'+
		'        \"FullName\": \"Jon Snow\",'+
		'        \"ContactAt\": \"Please, email me at: jon.snow@email.com, or call: 2025550141\",'+
		'        \"Phones\": ['+
		'          \"+12025550141\"'+
		'        ],'+
		'        \"Emails\": ['+
		'          \"jon.snow@email.com\"'+
		'        ]'+
		'      },'+
		'      \"ServiceLocation\": {'+
		'        \"OccupantID\": 327,'+
		'        \"Address\": {'+
		'          \"City\": \"San Mateo\",'+
		'          \"Country\": \"United States\",'+
		'          \"State\": \"CA\",'+
		'          \"Street1\": \"S. Norfolk St. Suite 100\",'+
		'          \"Street2\": null,'+
		'          \"PostalCode\": \"1900\"'+
		'        },'+
		'        \"Geo\": {'+
		'          \"Latitude\": 33.803559,'+
		'          \"Longitude\": -117.930203'+
		'        },'+
		'        \"OccupantName\": \"5340 - 12909 HARBOR BOULEVARD\",'+
		'        \"SpaceName\": \"Restaurant\",'+
		'        \"SpaceId\": 28111'+
		'      },'+
		'      \"Customer\": {'+
		'        \"Id\": 234,'+
		'        \"Name\": \"ABC Inc\"'+
		'      },'+
		'      \"IsPrebilled\": false,'+
		'      \"IsWarranty\": false,'+
		'      \"Created\": \"2022-03-07T15:54:18.0306887Z\",'+
		'      \"LastUpdate\": \"2022-03-07T15:54:18.0306887Z\",'+
		'      \"Feedback\": null,'+
		'      \"Status\": \"New\",'+
		'      \"Currency\": \"USD\",'+
		'      \"TimeZone\": \"Standard Time Zone\",'+
		'      \"WorkZoneNumber\": \"5340\",'+
		'      \"InternalNote\": \"Here goes internal note\",'+
		'      \"AdditionalFields\": null,'+
		'      \"LastAction\": null,'+
		'      \"IsmStatus\": \"Waiting\"'+
		'    },'+
		'    \"Attachments\": ['+
		'      {'+
		'        \"Sender\": {'+
		'          \"Name\": \"Samwell Tarly\",'+
		'          \"Phone\": \"+12025550148\",'+
		'          \"Type\": \"CorrigoPro\"'+
		'        },'+
		'        \"Size\": 234256756,'+
		'        \"SentAt\": \"2022-03-08T15:54:18.0306887Z\",'+
		'        \"DocumentType\": 0,'+
		'        \"Title\": null,'+
		'        \"Subtype\": \"None\",'+
		'        \"Id\": \"7c9e6679-7425-40de-944b-e07fc1f90ae7\",'+
		'        \"Name\": \"test.doc\",'+
		'        \"MimeType\": \"application/msword\"'+
		'      },'+
		'      {'+
		'        \"Sender\": {'+
		'          \"Name\": \"Petyr Baelish\",'+
		'          \"Phone\": \"+12025550149\",'+
		'          \"Type\": \"CorrigoProDirect\"'+
		'        },'+
		'        \"Size\": 754368,'+
		'        \"SentAt\": \"2022-03-07T15:54:18.0306887Z\",'+
		'        \"DocumentType\": 0,'+
		'        \"Title\": null,'+
		'        \"Subtype\": \"None\",'+
		'        \"Id\": \"ba68655d-9e2a-498a-a8c4-7d6f821ded25\",'+
		'        \"Name\": \"test.png\",'+
		'        \"MimeType\": \"image/png\"'+
		'      }'+
		'    ],'+
		'    \"Header\": {'+
		'      \"WorkOrderId\": 42,'+
		'      \"BranchId\": 79493,'+
		'      \"Sender\": {'+
		'        \"Name\": \"Tyrion Lannister\",'+
		'        \"Phone\": \"+12025556632\",'+
		'        \"Type\": \"Customer\"'+
		'      },'+
		'      \"Action\": \"NewWorkOrder\",'+
		'      \"ActionDate\": \"2022-03-09T03:35:14.2428092Z\",'+
		'      \"ApiVersion\": \"1.2\",'+
		'      \"MessageId\": \"e245f047-4a99-4dfa-8a18-276471ae5d7f\"'+
		'    }'+
		'  }'+
		'}';
		CorrigoProWorkOrder r = CorrigoProWorkOrder.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Address objAddress = new CorrigoProWorkOrder.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.City == null);
		System.assert(objAddress.Country == null);
		System.assert(objAddress.State == null);
		System.assert(objAddress.Street1 == null);
		System.assert(objAddress.Street2 == null);
		System.assert(objAddress.PostalCode == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.WorkType objWorkType = new CorrigoProWorkOrder.WorkType(System.JSON.createParser(json));
		System.assert(objWorkType != null);
		System.assert(objWorkType.Category == null);
		System.assert(objWorkType.Id == null);
		System.assert(objWorkType.Name == null);
		System.assert(objWorkType.IsVisit == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.WorkDetails objWorkDetails = new CorrigoProWorkOrder.WorkDetails(System.JSON.createParser(json));
		System.assert(objWorkDetails != null);
		System.assert(objWorkDetails.CheckList == null);
		System.assert(objWorkDetails.Procedures == null);
		System.assert(objWorkDetails.Assets == null);
		System.assert(objWorkDetails.VisitInfo == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Sla objSla = new CorrigoProWorkOrder.Sla(System.JSON.createParser(json));
		System.assert(objSla != null);
		System.assert(objSla.DueDate == null);
		System.assert(objSla.OnSiteBy == null);
		System.assert(objSla.AcknowledgeBy == null);
		System.assert(objSla.PriorityId == null);
		System.assert(objSla.PriorityName == null);
		System.assert(objSla.IsEmergency == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder objCorrigoProWorkOrder = new CorrigoProWorkOrder(System.JSON.createParser(json));
		System.assert(objCorrigoProWorkOrder != null);
		System.assert(objCorrigoProWorkOrder.body == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Attachments objAttachments = new CorrigoProWorkOrder.Attachments(System.JSON.createParser(json));
		System.assert(objAttachments != null);
		System.assert(objAttachments.Sender == null);
		System.assert(objAttachments.Size == null);
		System.assert(objAttachments.SentAt == null);
		System.assert(objAttachments.DocumentType == null);
		System.assert(objAttachments.Title == null);
		System.assert(objAttachments.Subtype == null);
		System.assert(objAttachments.Id == null);
		System.assert(objAttachments.Name == null);
		System.assert(objAttachments.MimeType == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Contact objContact = new CorrigoProWorkOrder.Contact(System.JSON.createParser(json));
		System.assert(objContact != null);
		System.assert(objContact.FullName == null);
		System.assert(objContact.ContactAt == null);
		System.assert(objContact.Phones == null);
		System.assert(objContact.Emails == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Geo objGeo = new CorrigoProWorkOrder.Geo(System.JSON.createParser(json));
		System.assert(objGeo != null);
		System.assert(objGeo.Latitude == null);
		System.assert(objGeo.Longitude == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Sender objSender = new CorrigoProWorkOrder.Sender(System.JSON.createParser(json));
		System.assert(objSender != null);
		System.assert(objSender.Name == null);
		System.assert(objSender.Phone == null);
		System.assert(objSender.Type == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Details objDetails = new CorrigoProWorkOrder.Details(System.JSON.createParser(json));
		System.assert(objDetails != null);
		System.assert(objDetails.WorkOrderNumber == null);
		System.assert(objDetails.WorkOrderId == null);
		System.assert(objDetails.BranchId == null);
		//System.assert(objDetails.IVRInfo == null);
		System.assert(objDetails.Schedule == null);
		System.assert(objDetails.Type == null);
		System.assert(objDetails.WorkType == null);
		System.assert(objDetails.AccompanyingMessage == null);
		System.assert(objDetails.Nte == null);
		System.assert(objDetails.Sla == null);
		System.assert(objDetails.WorkDetails == null);
		//System.assert(objDetails.CompletionDetails == null);
		System.assert(objDetails.Contact == null);
		System.assert(objDetails.ServiceLocation == null);
		System.assert(objDetails.Customer == null);
		System.assert(objDetails.IsPrebilled == null);
		System.assert(objDetails.IsWarranty == null);
		System.assert(objDetails.Created == null);
		System.assert(objDetails.LastUpdate == null);
		System.assert(objDetails.Feedback == null);
		System.assert(objDetails.Status == null);
		System.assert(objDetails.Currency_Z == null);
		System.assert(objDetails.TimeZone == null);
		System.assert(objDetails.WorkZoneNumber == null);
		System.assert(objDetails.InternalNote == null);
		//System.assert(objDetails.AdditionalFields == null);
		System.assert(objDetails.LastAction == null);
		System.assert(objDetails.IsmStatus == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Header objHeader = new CorrigoProWorkOrder.Header(System.JSON.createParser(json));
		System.assert(objHeader != null);
		System.assert(objHeader.WorkOrderId == null);
		System.assert(objHeader.BranchId == null);
		System.assert(objHeader.Sender == null);
		System.assert(objHeader.Action == null);
		System.assert(objHeader.ActionDate == null);
		System.assert(objHeader.ApiVersion == null);
		System.assert(objHeader.MessageId == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.CheckList objCheckList = new CorrigoProWorkOrder.CheckList(System.JSON.createParser(json));
		System.assert(objCheckList != null);
		System.assert(objCheckList.SortingIndex == null);
		System.assert(objCheckList.Description == null);
		System.assert(objCheckList.Id == null);
		System.assert(objCheckList.Comment == null);
		System.assert(objCheckList.Exception_Z == null);
		System.assert(objCheckList.IsDone == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Assets objAssets = new CorrigoProWorkOrder.Assets(System.JSON.createParser(json));
		System.assert(objAssets != null);
		System.assert(objAssets.Id == null);
		System.assert(objAssets.Path == null);
		System.assert(objAssets.Task == null);
		System.assert(objAssets.AssetName == null);
		System.assert(objAssets.Comment == null);
		System.assert(objAssets.Type == null);
		System.assert(objAssets.TypeId == null);
		System.assert(objAssets.Model == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.ServiceLocation objServiceLocation = new CorrigoProWorkOrder.ServiceLocation(System.JSON.createParser(json));
		System.assert(objServiceLocation != null);
		System.assert(objServiceLocation.OccupantID == null);
		System.assert(objServiceLocation.Address == null);
		System.assert(objServiceLocation.Geo == null);
		System.assert(objServiceLocation.OccupantName == null);
		System.assert(objServiceLocation.SpaceName == null);
		System.assert(objServiceLocation.SpaceId == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Schedule objSchedule = new CorrigoProWorkOrder.Schedule(System.JSON.createParser(json));
		System.assert(objSchedule != null);
		System.assert(objSchedule.ScheduledStart == null);
		System.assert(objSchedule.Pte == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Model objModel = new CorrigoProWorkOrder.Model(System.JSON.createParser(json));
		System.assert(objModel != null);
		System.assert(objModel.Id == null);
		System.assert(objModel.Name == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Body objBody = new CorrigoProWorkOrder.Body(System.JSON.createParser(json));
		System.assert(objBody != null);
		System.assert(objBody.Details == null);
		System.assert(objBody.Attachments == null);
		System.assert(objBody.Header == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CorrigoProWorkOrder.Nte objNte = new CorrigoProWorkOrder.Nte(System.JSON.createParser(json));
		System.assert(objNte != null);
		System.assert(objNte.Amount == null);
		System.assert(objNte.Quote == null);
		System.assert(objNte.IsQuoteMultiline == null);
		System.assert(objNte.DtLastUpdate == null);
	}
}