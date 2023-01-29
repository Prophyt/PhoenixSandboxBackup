({
	loadAlerts : function(component, event, helper)
    {
        // Load all contact data
        var action = component.get("c.getAlerts");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var msgs = []; // clear out existing messages and start over component.get("v.alerts");
                for(var x = 0; x < response.getReturnValue().length; x++)
                {
                    msgs.push(response.getReturnValue()[x]);
                }
                
                var unique = msgs.filter((obj, pos, arr) => 
				{
                    return arr.map(mapObj => mapObj['Message__c']).indexOf(obj['Message__c']) === pos;
                });
                
                component.set("v.alerts", unique); //response.getReturnValue());
                component.set("v.alertsList", unique); //response.getReturnValue());
                var msgs = component.get("v.alerts");
                this.updateTotal(component);
                console.log('Successfully loaded alert records.');
            }
            else
            {
                console.log(state + ': Alerts Loading Failed.');
                console.log(JSON.stringify(response));
            }
        });
        $A.enqueueAction(action);		
	},
    updateTotal: function(component, event, helper)
    {
        var messages = component.get("v.alerts");
        component.set("v.alertCount", messages != null ? messages.length : 0);
    },
    resetAlerts: function(component, event, helper)
    {
        component.set("v.alerts",[]);
        component.set("v.alertsList",[]);
        component.set("v.alertCount",0);
        this.loadAlerts(component, event, helper);
    }
})