({
	doInit : function(component, event, helper) 
    {
        component.set("v.showSpinner", true);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) 
		{
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: 'KB'
            });
        });
        
        var recId = component.get("v.recordId");
        var action;
        if(recId != null && recId != '')
        {
            action = component.get("c.getAccountKnowledgeTree");    
            action.setParams({recordId : component.get("v.recordId")});
        }
        else
        {
            action = component.get("c.getAllKnowledgeTree");            
        }

        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var obj = response.getReturnValue();
                console.log(JSON.stringify(obj));
                component.set("v.items", obj);
                component.set("v.showSpinner", false);
            }
            else if (state === "INCOMPLETE") 
            {
                component.set("v.showSpinner", false);
            }
            else if (state === "ERROR") 
            {
                component.set("v.showSpinner", false);
                var errors = response.getError();
                if (errors) 
                {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else 
                {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    hidePopOver : function(component, event, helper)
    {
        component.set("v.showPopOver", false);
        component.set("v.selectedRecordId", null);
    },
    selectedRecordChange : function(component, event, helper)
    {
      	if(component.get("v.recordId") != null && component.get("v.selectedRecordId") != null && component.get("v.selectedRecordId").length === 18)
        {
            component.set("v.showPopOver", true);
        }
    },
    attachArticle : function(component, event, helper)
    {
        var action = component.get("c.attachToCase");
        action.setParams({"caseId" : component.get("v.recordId"), 
                          "articleId" : component.get("v.selectedRecordId")});
        
        action.setCallback(this, function(response)
		{
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var res = response.getReturnValue();
                if(res && res === true)
                {
                    var t = $A.get("e.force:showToast");
                    t.setParams({
                        "title": "Success!",
                        "message": "Article successfully attached to Case."
                    });
                    t.fire();
                }
            }
            else
            {
                console.log('Error running Knowledge Attach function.');
            }
        });
        $A.enqueueAction(action);
    },    
    openArticle : function(component, event, helper)
    {
        component.set("v.showPopOver", false);
        var navService = component.find("navService")
        .navigate({
            "type" : "standard__recordPage",
            "attributes": 
            {
                "recordId"      : component.get("v.selectedRecordId"),
                "actionName"    : 'view'   //clone, edit, view
            }}, true);   
    },
    handleRecordSelect : function(component, event, helper)
    {
        var eventName = event.getParam('name');
        component.set("v.selectedRecordId", eventName);
        component.set("v.showPopOver", true);
        /*
        if(eventName != null && eventName != '')
        {
            var navService = component.find("navService")
            .navigate({
                "type" : "standard__recordPage",
                "attributes": 
                {
                    "recordId"      : eventName,
                    "actionName"    : 'view'   //clone, edit, view
                }}, true);   
        }*/
    },
    handleSelect : function(component, event, helper)
    {
        var eventName = event.getParam('name');
        component.set("v.selectedRecordId", eventName);
        helper.getRelatedDocuments(component, event);
        //redirect instead
        /*
        if(eventName != null && eventName != '')
        {
            var navService = component.find("navService")
            .navigate({
                "type" : "standard__recordPage",
                "attributes": 
                {
                    "recordId"      : eventName,
                    "actionName"    : 'view'   //clone, edit, view
                }}, true);   
        }
        */
    },
    handleRedirectToUserRecord: function (component, event, helper) 
    {
        var recordId = event.currentTarget.getAttribute("data-Id")
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },
    handleSelectedDocPreview : function(component,event,helper)
    { 
        var docId = event.currentTarget.getAttribute("data-Id");
        helper.downloadDocument(component, event, docId);
        /*
        $A.get('e.lightning:openFiles').fire({
            recordIds: [event.currentTarget.getAttribute("data-Id")]
        });
        */
    },
    handleSelectedAction: function(component, event, helper) 
    {
        var docId = event.getSource().get("v.value");
        var selectedMenuValue = event.detail.menuItem.get("v.value");
        switch(selectedMenuValue) 
        {
            case "Download":
                helper.downloadDocument(component, event, docId);
                break;
        }
    }    
     
})