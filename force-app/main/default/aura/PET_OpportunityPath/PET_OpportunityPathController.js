({
	doInit : function(component, event, helper) 
    {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
        component.set("v.userId", userId);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        console.log(today);
        
		//helper.loadRecordDefaults(component, event, helper);
	},
    handleStageChange : function(component, event, helper)
    {
        var childVal = event.getParam("StageName");
        component.set("v.opportunityStage", childVal);
    },
    handleOnLoad : function(component, event, helper)
    {
        console.log('Loaded');
        var recordUi = event.getParam("recordUi");
        var vStage = recordUi.record.fields["StageName"].value;  
		//helper.loadRecordDefaults(component, event, helper);
        component.set("v.currentStage", vStage);
    },
    handleOnSubmit : function(component, event, helper) 
    {
        component.set("v.showSpinner", true);
    },
    handleOnSuccess : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
    },
    handleOnError : function(component, event, helper)
    {
        component.set("v.showSpinner", false);
        var error = event.getParam("error");
        debugger;
    }
})