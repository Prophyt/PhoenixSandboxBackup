({
	doInit : function(component, event, helper) 
    {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
        component.set("v.userId", userId);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        console.log(today);
        
        var pr = component.get("v.pageReference");
        if(pr.state != null && pr.state.c__inboundAccountId != null)
        {
            component.set("v.inboundAccountId", pr.state.c__inboundAccountId);
        }
        if(pr.state != null && pr.state.c__inboundParentAccountId != null)
        {
            component.set("v.inboundParentAccountId", pr.state.c__inboundParentAccountId);
        }        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) 
		{
            var focusedTabId = response.tabId;
            component.set("v.focusedTabId", focusedTabId);
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: 'New Case'
            });
        })
        .catch(function(error) 
		{
            console.log(error);
        });
        
	},
    handleOnLoad : function(component, event, helper) 
    {
        component.find("accountLookup").set("v.value", component.get("v.inboundAccountId"));
        component.find("parentAccountLookup").set("v.value", component.get("v.inboundParentAccountId"));

    },
    handleOnSubmit : function(component, event, helper) 
    {
        component.set("v.showSpinner", true);
    },
    handleOnSuccess : function(component, event, helper) 
    {
        var record = event.getParams();
        var caseId = record.response.id;
        var appMode = document.location.href.toLowerCase().indexOf('.app') >= 0;
        if(appMode == false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "New Case has been created successfully."
            });
            
            toastEvent.fire();
        }

        try
        {
            var workspaceAPI = component.find("workspace");
            var tabId = component.get("v.focusedTabId");
            workspaceAPI.openTab({
                pageReference: {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": caseId,
                        "actionName":"view"
                    },
                    "state": {}
                },
                focus: true
            }).then(function(response) 
			{

                workspaceAPI.closeTab({tabId: tabId});
            }).catch(function(error) 
			{
                console.log(error);
            });

            component.find('field').forEach(function(f) 
			{
                f.reset();
            });
                
           
            component.set("v.showSpinner", false);
        }
        catch(error)
        {
            console.log(error);
        }
        
        
    },
    handleOnError : function(component, event, helper) 
    {
        var appMode = document.location.href.toLowerCase().indexOf('.app') >= 0;
        if(appMode == false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Check error messages."
            });
            
            toastEvent.fire();
        }
        component.set("v.showSpinner", false);
    },
    handleContactCancel : function(component, event, helper)
    {
        component.set("v.showNewContact", false);
        component.find('contactField').forEach(function(f)
		{
            f.reset();                                        
        });
    },
    handleNewContact : function(component, event, helper)
    {
        component.set("v.showNewContact", !component.get("v.showNewContact"));
    },
    handleContactSubmit : function(component, event, helper)
    {
        component.set("v.showSpinner", true);
    },
    handleContactSuccess : function(component, event, helper)
    {
        var record = event.getParams();
        component.set("v.contactId", record.response.id);
		var fName = record.response.fields.FirstName.value;
        var lName = record.response.fields.LastName.value;
        var name = fName + ' ' + lName;
        component.set("v.contactName", name);
        var appMode = document.location.href.toLowerCase().indexOf('.app') >= 0;
        if(appMode == false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "New Contact record has been created successfully."
            });
            
            toastEvent.fire();
        }
        component.find('contactField').forEach(function(f)
		{
            f.reset();                                        
        });
        component.set("v.showNewContact", false);
        component.set("v.showSpinner", false);
    },
    handleContactError : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
    }
})