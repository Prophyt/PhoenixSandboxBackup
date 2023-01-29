({
	loadRecordDefaults : function(component, event, helper) 
    {
        var action = component.get("c.getRecordTypeId");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var res = response.getReturnValue();
                component.set("v.recordTypeId", res);
                
                //chain to check if this is an API customer.
                var apiCheckAction = component.get("c.IsNonAPICustomer");
                apiCheckAction.setParams({'recordId': component.get("v.recordId")});
                apiCheckAction.setCallback(this, function(apiResponse)
				{
                    var apiCheckState = apiResponse.getState();
                    if(apiCheckState === 'SUCCESS')
                    {
                        var apiRes = apiResponse.getReturnValue();
                        component.set("v.isNonAPICustomer", apiRes);
                    }
                });
                
                $A.enqueueAction(apiCheckAction);
            }
            else
            {
                console.log('error getting record type');
                console.log(res);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);	
	}
})