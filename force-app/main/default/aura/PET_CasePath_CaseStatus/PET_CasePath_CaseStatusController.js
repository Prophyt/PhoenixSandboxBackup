({
	handleOnLoad : function(component, event, helper) 
    {
		
	},
    handleOnSubmit : function(component, event, helper)
    {
        
    },
    handleOnSuccess : function(component, event, helper)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Updated!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    handleOnError : function(component, event, helper)
    {
        
    }
})