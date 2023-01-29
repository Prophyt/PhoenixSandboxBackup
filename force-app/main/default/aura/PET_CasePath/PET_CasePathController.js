({
	doInit : function(component, event, helper) 
    {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
        component.set("v.userId", userId);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        console.log(today);
        
		helper.loadRecordDefaults(component, event, helper);
	},
    recordUpdated : function(component, event, helper)
    {
        var accId = component.get("v.CaseObject").AccountId;
        if(accId != null && accId != '')
        {
            var accName = component.get("v.CaseObject").Account.Name;
            component.set("v.accountName", accName);
            var accountParent = component.get("v.CaseObject").Account.ParentId != null ? component.get("v.CaseObject").Account.Parent.Name : '';
            //do custom account name mapping here to simplify long or complex naming across account structures
            if(accountParent != null && accountParent.includes('HSBC'))
            {
                accountParent = 'HSBC';
                component.set("v.accountParent", accountParent);                
            }
            if(accName.toLowerCase().includes('office'))
            {
                accountParent = 'Office Depot';
                component.set("v.accountParent", accountParent);
            }            
        }
    },
    handleOnLoad : function(component, event, helper)
    {
        console.log('Loaded');
        var recordUi = event.getParam("recordUi");
        var vStage = recordUi.record.fields["Stage__c"].value;
        var vStatus = recordUi.record.fields["Status"].value;
        var vIntegrationMessage = recordUi.record.fields["Integration_Message__c"].value != null ? recordUi.record.fields["Integration_Message__c"].value : '';
        var vThirdPartySystem = recordUi.record.fields["X3rd_Party_System__c"].value != null ? recordUi.record.fields["X3rd_Party_System__c"].value : '';
        
		helper.loadRecordDefaults(component, event, helper);
        component.set("v.currentStage", vStage);
        //commented out status so it is not constantly overwriting itself
        //component.set("v.caseStatus", vStatus);
        component.set("v.integrationMessage", vIntegrationMessage);
        component.set("v.thirdPartySystem", vThirdPartySystem);
        //console.log(JSON.stringify(recordUi));
        //var caseStage = component.find("caseStage").get("v.value");
        //alert(caseStage);
    },
    handleOnSubmit : function(component, event, helper) 
    {
        component.set("v.showSpinner", true);
    },
    handleOnSuccess : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
        var appEvent = $A.get("e.c:PET_GlobalRefreshEvent");
        //appEvent.setParams({ "myParam" : myValue });
        appEvent.fire();


        //component.set("v.showSpinner", true);
        /*
        var payload = event.getParams();
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Success!",
            "message": "Case " + payload.response.fields.CaseNumber.value + ".",
            "messageTemplate": "Case '{0}' has been updated successfully.",
            "messageTemplateData": 
            [{
                "label": payload.response.fields.CaseNumber.value,
                "url": "/" + payload.response.id
            }]

        });
        resultsToast.fire();
        */
        // Close the action panel
        //var closeMe = $A.get("e.force:closeQuickAction");
        //closeMe.fire();
    },
    handleOnError : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
        var error = event.getParam("error");
        debugger;
    }
})