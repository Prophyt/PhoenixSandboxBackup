({
    doInit : function(component, event, helper)
    {
        if(component.get("v.recordId") != null && component.get("v.recordId") != '')
            helper.loadAlerts(component, event, helper);
    },
    handleEvent : function(component, event, helper)
    {
        //THIS METHOD ACCEPTS AN INPUT FROM AN EVENT
        //WHICH POPULATES A NEW ALERT
        //IT NEEDS TO DEDUPE THE LIST EVENTUALLY
        //THERE IS ALSO A CONTROLLER THAT WILL POPULATE THIS LIST ON LOAD
        //FROM ACTUAL DATA
        console.log('**************** LOGGING ALERT EVENT ************');
        console.log(event.getParams());
        var message = event.getParam("message");
        var recId = event.getParam("recordId") != null ? event.getParam("recordId") : '';
        //dont run the dynamic event handler if its not meant for the current active record
        //this stops the same component on multiple pages from getting events it shouldnt.
        
        if(recId == null || recId == '' || component.get("v.recordId") != recId)
            return;
        
        // set the handler attributes based on event data
        component.set("v.messageFromEvent", message);
        var type = event.getParam("type");
        
        if(type == 'reload' || type == 'clear' || type == 'refresh')
        {
            helper.resetAlerts(component,event,helper);
            return;
        }
        
        var text = event.getParam("message");
        console.log(type + ': ' + message);

        var alerts = component.get("v.alerts");
        
        var newItem = {};
        newItem.Type = type;
        newItem.Text = text;
        alerts.push(newItem);
        
        //dedupe
        var unique = alerts.filter((obj, pos, arr) => 
		{
            return arr.map(mapObj => mapObj['Text']).indexOf(obj['Text']) === pos;
        });
        
        component.set("v.alerts",unique);
        console.log('**************** DONE LOGGING ALERT EVENT ************');
        event.stopPropagation();//might not need this
    }
})