({
	doInit : function(component, event, helper) 
    {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
        component.set("v.userId", userId);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        console.log(today);
	},
    handleOnLoad : function(component, event, helper)
    {
        console.log('Loaded');
    },
    handleOnSubmit : function(component, event, helper) 
    {
        component.set("v.showSpinner", true);
        component.set("v.showSpinner", false);
    },
    handleOnSuccess : function(component, event, helper)
    {
        component.set("v.showSpinner", true);
        var payload = event.getParams();
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Success!",
            "message": "Case " + payload.response.fields.CaseNumber.value + ".",
            "messageTemplate": "Case '{0}' has been created successfully.",
            "messageTemplateData": 
            [{
                "label": payload.response.fields.CaseNumber.value,
                "url": "/" + payload.response.id
            }]

        });
        resultsToast.fire();
        
        // Close the action panel
        var closeMe = $A.get("e.force:closeQuickAction");
        closeMe.fire();
    },
    handleOnError : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
        var error = event.getParam("error");
        //debugger;
    }
})